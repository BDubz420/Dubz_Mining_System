DEFINE_BASECLASS("weapon_base")
include("autorun/dubz_mining_config.lua")

-- Function to apply material and color to upgraded pickaxes
local function SetPickaxeMaterialAndColor(pickaxe)
    -- Check if it's an upgraded pickaxe (for example, based on its name or other property)
    if pickaxe.IsUpgraded then
        -- Set material and color
        pickaxe:SetMaterial("models/debug/debugwhite")  -- Use debug white material for upgraded pickaxes

        -- Set color based on gem type
        local gemColor = pickaxe.GemColor or Color(255, 255, 255)  -- Default to white if no gem color is specified
        pickaxe:SetColor(gemColor)
    end
end

-- Function to initialize the SWEP
function SWEP:Initialize()
    -- Apply material and color if it's an upgraded pickaxe
    if self.IsUpgraded then
        SetPickaxeMaterialAndColor(self)
    end
    self:SendWeaponAnim(ACT_VM_HOLSTER)
end

-- Common Pickaxe Properties
SWEP.Author = "Dubz"
SWEP.Instructions = "Left click to break something"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/c_crowbar.mdl")
SWEP.WorldModel = Model("models/weapons/w_crowbar.mdl")
SWEP.HoldType = "melee"
SWEP.UseHands = true
SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 20
SWEP.Primary.Delay = 0.5
SWEP.Primary.Ammo = ""

-- Initialize the upgraded flag if needed
SWEP.IsUpgraded = false -- Default value; set this to `true` for upgraded pickaxes
SWEP.GemColor = Color(255, 255, 255)  -- Default to white if no gem color is set

function SWEP:Initialize()
    -- Apply the material and color only if it's an upgraded pickaxe
    if self.IsUpgraded then
        SetPickaxeMaterialAndColor(self)
    end
    self:SendWeaponAnim(ACT_VM_HOLSTER)
end

function SWEP:DoHitEffects()
    local trace = self.Owner:GetEyeTraceNoCursor()

    if ((trace.Hit or trace.HitWorld) and self.Owner:GetShootPos():Distance(trace.HitPos) <= 64) then
        self:SendWeaponAnim(ACT_VM_HITCENTER)
        --self:EmitSound("weapons/crossbow/hitbod2.wav")
    else
        self:SendWeaponAnim(ACT_VM_MISSCENTER)
        --self:EmitSound("npc/vort/claw_swing2.wav")
    end
end

function SWEP:DoAnimations(idle)
    if not idle then
        self.Owner:SetAnimation(PLAYER_ATTACK1)
    end
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:DoAnimations()
    self:DoHitEffects()

    if SERVER then
        if self.Owner.LagCompensation then
            self.Owner:LagCompensation(true)
        end

        local trace = self.Owner:GetEyeTraceNoCursor()

        if self.Owner:GetShootPos():Distance(trace.HitPos) <= 64 then
            if IsValid(trace.Entity) and trace.Entity:GetClass() == "dubz_rock" then
                trace.Entity:TakeDamage(self.Primary.Damage, self:GetOwner(), self)        
            end
        end

        if self.Owner.LagCompensation then
            self.Owner:LagCompensation(false)
        end
    end
end

function SWEP:Holster()
    return true
end

function SWEP:Think()
end

function SWEP:DrawHUD()
end

function SWEP:SecondaryAttack()
end
