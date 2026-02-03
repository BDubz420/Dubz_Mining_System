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

    weapons.Register(wep, "weapon_dubz_pickaxe_" .. string.lower(gem.name))
end
