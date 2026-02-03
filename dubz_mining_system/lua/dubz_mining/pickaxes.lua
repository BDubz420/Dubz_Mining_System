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
