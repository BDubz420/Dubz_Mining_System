include("autorun/dubz_mining_config.lua")
--[[
if not DMS.Ores or not DMS.Ores.Gems then return end

for _, gem in ipairs(DMS.Ores.Gems) do
    local wep = {
        Base = "weapon_dubz_pickaxe_base",
        PrintName = gem.name .. " Pickaxe",
        Category = "Dubz Mining System",
        Spawnable = true,
        AdminOnly = false,
        Author = "Dubz",
        HoldType = "melee",
        UseHands = true,
        ViewModel = "models/weapons/c_crowbar.mdl",
        WorldModel = "models/weapons/w_crowbar.mdl",
        Primary = {
            ClipSize = -1,
            DefaultClip = -1,
            Automatic = true,
            Ammo = "none",
            Damage = 20 * (gem.multiplier or 1),
            Delay = 1 / (gem.multiplier or 1),
        }
    }

    local basicwep = {
        Base = "weapon_dubz_pickaxe_base",
        PrintName = "Basic Pickaxe",
        Category = "Dubz Mining System",
        Spawnable = true,
        AdminOnly = false,
        Author = "Dubz",
        HoldType = "melee",
        UseHands = true,
        ViewModel = "models/weapons/c_crowbar.mdl",
        WorldModel = "models/weapons/w_crowbar.mdl",
        Primary = {
            ClipSize = -1,
            DefaultClip = -1,
            Automatic = true,
            Ammo = "none",
            Damage = 10,
            Delay = 1,
        }
    }

    weapons.Register(basicwep, "weapon_dubz_pickaxe_basic")
    weapons.Register(wep, "weapon_dubz_pickaxe_" .. string.lower(gem.name))
end

local function GetPickaxePath(ply)
    return "mining_pickaxes/" .. ply:SteamID64() .. ".txt"
end

function LoadPlayerPickaxe(ply)
    local path = GetPickaxePath(ply)
    return file.Exists(path, "DATA") and file.Read(path, "DATA") or "weapon_dubz_pickaxe_basic"
end

function SavePlayerPickaxe(ply, pickaxeClass)
    if not file.IsDir("mining_pickaxes", "DATA") then
        file.CreateDir("mining_pickaxes")
    end
    file.Write(GetPickaxePath(ply), pickaxeClass)
end

hook.Add("PlayerChangedTeam", "GiveMiningPickaxeOnTeam", function(ply, _, newTeam)
    if newTeam == TEAM_MINER then
        local pickaxe = LoadPlayerPickaxe(ply)
        ply:Give(pickaxe)
        ply:SelectWeapon(pickaxe)
    end
end)

hook.Add("PlayerSpawn", "GivePickaxeIfMiner", function(ply)
    if ply:Team() == TEAM_MINER then
        local pickaxe = LoadPlayerPickaxe(ply)
        if not ply:HasWeapon(pickaxe) then
            ply:Give(pickaxe)
            ply:SelectWeapon(pickaxe)
        end
    end
end)

--]]