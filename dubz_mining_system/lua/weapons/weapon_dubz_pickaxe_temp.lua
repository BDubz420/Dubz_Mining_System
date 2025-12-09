if CLIENT then
    SWEP.PrintName = "Pickaxe"
    SWEP.Slot = 1
    SWEP.SlotPos = 5
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
end

SWEP.Author = ""
SWEP.Instructions = "Left click to break something"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel      = "models/pickaxe/pickaxe_v.mdl"
SWEP.WorldModel     = "models/pickaxe/pickaxe_w.mdl"
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

SWEP.HitSound = ""
SWEP.MissSound = ""

--SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

include("autorun/dubz_mining_config.lua")
---------------------------------------------------------
-- FIX: Initialize should set hold type, not holster anim
---------------------------------------------------------
function SWEP:Initialize()
    self:SetHoldType("melee")
end

---------------------------------------------------------
-- Hit effects (animation)
---------------------------------------------------------
function SWEP:DoHitEffects()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local trace = owner:GetEyeTrace()
    local hitEnt = trace.Entity
    local distOK = owner:GetShootPos():Distance(trace.HitPos) <= 64

    -- Animation
    if trace.Hit and distOK then
        self:SendWeaponAnim(ACT_VM_HITCENTER)
    else
        self:SendWeaponAnim(ACT_VM_MISSCENTER)
    end

    -- MISS swing
    if not distOK then
        self:EmitSound(table.Random(DMS.Sounds.Swing), 75, math.random(95,110))
        return
    end

    -- === ROCK HIT ===
    if IsValid(hitEnt) and hitEnt:GetClass() == "dubz_rock" then
        self:EmitSound(table.Random(DMS.Sounds.HitRock), 80, math.random(95,110))
        return
    end

    -- === TRUE WORLD HIT (reliable) ===
    if trace.HitWorld 
        or not IsValid(hitEnt)
        or hitEnt:IsWorld()
        or (IsValid(hitEnt) and hitEnt:GetClass() == "worldspawn") 
    then
        self:EmitSound(table.Random(DMS.Sounds.HitWorld), 75, math.random(95,110))
        return
    end

    -- === PROP HIT (any other entity) ===
    if IsValid(hitEnt) then
        self:EmitSound(table.Random(DMS.Sounds.HitWorld), 75, math.random(95,110))
        return
    end

    -- Fallback
    self:EmitSound(table.Random(DMS.Sounds.HitWorld), 75, math.random(95,110))
end

---------------------------------------------------------
-- Attack animation
---------------------------------------------------------
function SWEP:DoAnimations()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    owner:SetAnimation(PLAYER_ATTACK1)
end

---------------------------------------------------------
-- Primary attack (mining)
---------------------------------------------------------
function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local level = math.Clamp(owner:GetNWInt("DubzLevel", 1), 1, 50)

    -- Speed scaling
    local progress = level / 10
    local eased = math.min(progress, 1) + (math.max(level - 10, 0) / 160)
    local delay = math.Clamp(1 - eased * 0.8, 0.2, 1)

    self:SetNextPrimaryFire(CurTime() + delay)
    self:DoAnimations()
    self:DoHitEffects()

    if SERVER then
        owner:LagCompensation(true)

        local trace = owner:GetEyeTrace()

        if owner:GetShootPos():Distance(trace.HitPos) <= 64 then
            if IsValid(trace.Entity) and trace.Entity:GetClass() == "dubz_rock" then
                local damage = self.Primary.Damage + math.floor(level / 10)
                trace.Entity:TakeDamage(damage, owner, self)
            end
        end

        owner:LagCompensation(false)
    end
end

---------------------------------------------------------
-- Prevent weird behavior on holster
---------------------------------------------------------
function SWEP:Holster()
    return true
end

---------------------------------------------------------
-- Tier-based viewmodel coloring (optional)
---------------------------------------------------------
function SWEP:Think()
    if CLIENT then
        local owner = LocalPlayer()
        if not IsValid(owner) then return end

        local level = math.Clamp(owner:GetNWInt("DubzLevel", 1), 1, 50)
        local tier = DMS.PickaxeTiers[1]

        for i = #DMS.PickaxeTiers, 1, -1 do
            if level >= DMS.PickaxeTiers[i].level then
                tier = DMS.PickaxeTiers[i]
                break
            end
        end

        -- VM coloring can be re-enabled if needed
    end
end

---------------------------------------------------------
-- Deploy — FIX: color WORLD MODEL, not the weapon SWEP entity
---------------------------------------------------------
function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return true end

    if SERVER then
        local level = math.Clamp(owner:GetNWInt("DubzLevel", 1), 1, 50)
        local tier = DMS.PickaxeTiers[1]

        for i = #DMS.PickaxeTiers, 1, -1 do
            if level >= DMS.PickaxeTiers[i].level then
                tier = DMS.PickaxeTiers[i]
                break
            end
        end

        -- FIX: Proper way to color worldmodel
        if tier.color then
            self:SetColor(tier.color)
            self:SetMaterial("models/shiny")
        end
    end

    return true
end

function SWEP:FireAnimationEvent(pos, ang, event, options)
    return true -- block all animation-triggered sounds
end

function SWEP:PlayImpactSound()
    -- override default crowbar sound (do nothing)
end

function SWEP:PlaySwingSound()
    -- override default swing sound (do nothing)
end