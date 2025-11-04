include("autorun/dubz_config.lua") -- Include config

SWEP.PrintName = "Rock Scanner"
SWEP.Author = "BDubz420"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "Dubz Mining System"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ViewModel = "models/weapons/v_slam.mdl"
SWEP.WorldModel = "models/props_lab/reciever01d.mdl"
SWEP.UseHands = true

local nextHackTime = {}

function SWEP:PrimaryAttack()
    if CLIENT then return end

    local ply = self.Owner
    local tr = ply:GetEyeTrace()

    -- Ensure the targeted entity is an ATM
    if not IsValid(tr.Entity) or tr.Entity:GetClass() ~= "dubz_atm" then
        ply:ChatPrint("You must target an ATM!")
        return
    end

    -- Prevent spam hacking
    if nextHackTime[ply] and nextHackTime[ply] > CurTime() then
        ply:ChatPrint("You must wait before hacking again!")
        return
    end

    -- Create the hacking device entity
    local hackDevice = ents.Create("dubz_atm_hacker")
    if not IsValid(hackDevice) then return end

    -- Calculate the position of the device next to the ATM (on the right side of the ATM)
    local trace = ply:GetEyeTrace()
    local Ang = trace.HitNormal:Angle()
    Ang.pitch = Ang.pitch + 90

    -- Set the position and angle
    hackDevice:SetPos(trace.HitPos + trace.HitNormal * 2)
    hackDevice:SetAngles(Ang)  -- Set the angle so that the top faces the player

    hackDevice:SetOwner(ply)  -- Set the owner (hacker)
    hackDevice:Spawn()
    hackDevice:SetParent(tr.Entity)  -- Parent the device to the ATM

    -- Play sound and spark effect when placing the hacking device
    hackDevice:EmitSound("ambient/machines/combine_terminal_idle1.wav") -- Placement sound

    -- Notify the player
    ply:ChatPrint("Hacking device placed! It will steal money over time.")

    -- Set cooldown time to prevent spamming
    nextHackTime[ply] = CurTime() + dubz.hacker["dubz_atm_hacker"].HackCooldown

    -- Strip the weapon (hacker tool)
    ply:StripWeapon("weapon_dubz_hacktool")
end