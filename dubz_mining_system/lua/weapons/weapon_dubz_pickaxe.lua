if CLIENT then
    SWEP.PrintName = "Pickaxe"
    SWEP.Slot = 1
    SWEP.SlotPos = 5
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false

    -- custom swing animation state
    SWEP.SwingActive = false
    SWEP.SwingEnd = 0

    function SWEP:StartSwing(duration)
        self.SwingActive = true
        self.SwingEnd = CurTime() + duration
    end

    -- Heavy downward swing animation
    function SWEP:GetViewModelPosition(pos, ang)
        if not self.SwingActive then return pos, ang end

        local frac = math.Clamp((self.SwingEnd - CurTime()) / 0.25, 0, 1)
        frac = frac * frac

        ang:RotateAroundAxis(ang:Right(),   Lerp(frac, 0, 55))
        ang:RotateAroundAxis(ang:Up(),      Lerp(frac, 0, -25))
        ang:RotateAroundAxis(ang:Forward(), Lerp(frac, 0, -15))

        pos = pos + ang:Forward() * Lerp(frac, 0, 8)
        pos = pos + ang:Right()   * Lerp(frac, 0, -5)
        pos = pos + ang:Up()      * Lerp(frac, 0, -3)

        if CurTime() >= self.SwingEnd then
            self.SwingActive = false
        end

        return pos, ang
    end
end

SWEP.Base = "weapon_base"

SWEP.Author = ""
SWEP.Instructions = "Left click to mine"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModel  = "models/dubz_mining/v_pickaxe.mdl"
SWEP.WorldModel = "models/dubz_mining/w_pickaxe.mdl"

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.HoldType = "melee"

SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "Dubz Mining System"

SWEP.Primary.Automatic = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 20
SWEP.Primary.Delay = 1

include("autorun/dubz_mining_config.lua")

---------------------------------------------------------
-- Initialize
---------------------------------------------------------
function SWEP:Initialize()
    self:SetHoldType("melee")
end

---------------------------------------------------------
-- Hit visuals (NO DAMAGE HERE)
---------------------------------------------------------
function SWEP:DoHitEffects()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local trace = owner:GetEyeTrace()
    local distOK = owner:GetShootPos():Distance(trace.HitPos) <= 70

    if not distOK or not trace.Hit then
        self:SendWeaponAnim(ACT_VM_MISSCENTER)
        self:EmitSound(table.Random(DMS.Sounds.Swing), 75, math.random(95,110))
        return
    end

    self:SendWeaponAnim(ACT_VM_HITCENTER)
end

---------------------------------------------------------
-- Player animation
---------------------------------------------------------
function SWEP:DoAnimations()
    local owner = self:GetOwner()
    if IsValid(owner) then
        owner:SetAnimation(PLAYER_ATTACK1)
    end
end

---------------------------------------------------------
-- Primary attack (damage + sound synced)
---------------------------------------------------------
local HIT_DELAY = 0.5

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local level = math.Clamp(owner:GetNWInt("DubzLevel", 1), 1, 50)

    local progress = level / 10
    local eased = math.min(progress, 1) + (math.max(level - 10, 0) / 160)
    local cooldown = math.Clamp(1 - eased * 0.8, 0.2, 1)

    self:SetNextPrimaryFire(CurTime() + cooldown)

    self:DoAnimations()

    if CLIENT then
        self:StartSwing(0.15)
    end

    self:DoHitEffects()

    if SERVER then
        local weapon = self

        timer.Simple(HIT_DELAY, function()
            if not IsValid(weapon) then return end
            if not IsValid(owner) then return end
            if owner:GetActiveWeapon() ~= weapon then return end

            owner:LagCompensation(true)

            local trace = owner:GetEyeTrace()
            if owner:GetShootPos():Distance(trace.HitPos) <= 64 then
                local ent = trace.Entity

                if IsValid(ent) and ent:GetClass() == "dubz_rock" then
                    local damage = weapon.Primary.Damage + math.floor(level / 10)
                    ent:TakeDamage(damage, owner, weapon)

                    weapon:EmitSound(
                        table.Random(DMS.Sounds.HitRock),
                        80,
                        math.random(95,110)
                    )
                elseif trace.HitWorld then
                    weapon:EmitSound(
                        table.Random(DMS.Sounds.HitWorld),
                        75,
                        math.random(95,110)
                    )
                end
            end

            owner:LagCompensation(false)
        end)
    end
end

---------------------------------------------------------
-- Deploy — WORLD MODEL COLOR ONLY (SAFE)
---------------------------------------------------------
function SWEP:Deploy()
    if SERVER then
        local owner = self:GetOwner()
        if IsValid(owner) then
            local level = math.Clamp(owner:GetNWInt("DubzLevel", 1), 1, 50)
            local tier = DMS.PickaxeTiers[1]

            for i = #DMS.PickaxeTiers, 1, -1 do
                if level >= DMS.PickaxeTiers[i].level then
                    tier = DMS.PickaxeTiers[i]
                    break
                end
            end

            if tier.color then
                self:SetColor(tier.color)
                self:SetMaterial("models/shiny")
            end
        end
    end

    return true
end

function SWEP:Holster()
    return true
end

function SWEP:FireAnimationEvent()
    return true
end
