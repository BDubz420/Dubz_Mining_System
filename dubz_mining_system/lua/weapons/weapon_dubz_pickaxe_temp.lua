-- Client-side code for the SWEP
if CLIENT then
    SWEP.PrintName = "Pickaxe"
    SWEP.Slot = 1
    SWEP.SlotPos = 5
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
end

-- Common variables used both client and server side
SWEP.Author = ""
SWEP.Instructions = "Left click to break something"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/c_crowbar.mdl")
SWEP.WorldModel = Model("models/weapons/w_crowbar.mdl")
SWEP.HoldType = "melee"

SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "Dubz Mining System"

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 20
SWEP.Primary.Delay = 1
SWEP.Primary.Ammo = ""

-- Include config file
include("autorun/dubz_mining_config.lua")

function SWEP:Initialize()
    self:SendWeaponAnim(ACT_VM_HOLSTER)
end

function SWEP:DoHitEffects()
    local trace = self.Owner:GetEyeTraceNoCursor()

    if (trace.Hit or trace.HitWorld) and self.Owner:GetShootPos():Distance(trace.HitPos) <= 64 then
        self:SendWeaponAnim(ACT_VM_HITCENTER)
        self:EmitSound("weapons/crossbow/hitbod2.wav")
    else
        self:SendWeaponAnim(ACT_VM_MISSCENTER)
        self:EmitSound("npc/vort/claw_swing2.wav")
    end
end

function SWEP:DoAnimations(idle)
    if not idle then
        self.Owner:SetAnimation(PLAYER_ATTACK1)
    end
end

function SWEP:PrimaryAttack()
    local level = math.Clamp(self.Owner:GetNWInt("DubzLevel", 1), 1, 50)

    -- Delay scaling (quick up to level 10, then slower)
    local progress = level / 10
    local eased = math.min(progress, 1) + (math.max(level - 10, 0) / 160)
    local delay = math.Clamp(1 - eased * 0.8, 0.2, 1)

    self:SetNextPrimaryFire(CurTime() + delay)
    self:DoAnimations()
    self:DoHitEffects()

    if SERVER then
        if self.Owner.LagCompensation then self.Owner:LagCompensation(true) end

        local trace = self.Owner:GetEyeTraceNoCursor()

        if self.Owner:GetShootPos():Distance(trace.HitPos) <= 64 then
            if IsValid(trace.Entity) and trace.Entity:GetClass() == "dubz_rock" then
                -- Scale damage: +1 per 10 levels (starting at level 10)
                local damage = self.Primary.Damage + math.floor(level / 10)
                trace.Entity:TakeDamage(damage, self:GetOwner(), self)
            end
        end

        if self.Owner.LagCompensation then self.Owner:LagCompensation(false) end
    end
end
function SWEP:Holster()
    return true
end

function SWEP:Think()
    if CLIENT then
        local level = math.Clamp(LocalPlayer():GetNWInt("DubzLevel", 1), 1, 50)
        local tier = DMS.PickaxeTiers[1]

        for i = #DMS.PickaxeTiers, 1, -1 do
            if level >= DMS.PickaxeTiers[i].level then
                tier = DMS.PickaxeTiers[i]
                break
            end
        end

        --local vm = self.Owner:GetViewModel()
        --if IsValid(vm) and tier.color then
        --    vm:SetColor(tier.color)
        --    vm:SetMaterial("models/shiny") -- Optional: shinier material
        --end
    end
end

function SWEP:DrawHUD()
end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
    if SERVER then
        local level = math.Clamp(self.Owner:GetNWInt("DubzLevel", 1), 1, 50)
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

    return true
end