-- Core Hooks for Dubz Mining

local PLAYER = FindMetaTable("Player")
local dataFolder = "dubz_mining"

if not file.IsDir(dataFolder, "DATA") then
    file.CreateDir(dataFolder)
end

function PLAYER:SaveMiningData()
    local data = {
        xp = self:GetMiningXP(),
        level = self:GetMiningLevel()
    }
    file.Write(dataFolder .. "/" .. self:SteamID64() .. ".txt", util.TableToJSON(data))
end

function PLAYER:LoadMiningData()
    local path = dataFolder .. "/" .. self:SteamID64() .. ".txt"
    if file.Exists(path, "DATA") then
        local data = util.JSONToTable(file.Read(path, "DATA"))
        self:SetMiningXP(data.xp or 0)
        self:SetMiningLevel(data.level or 1)
    else
        self:SetMiningXP(0)
        self:SetMiningLevel(1)
    end
end

hook.Add("PlayerInitialSpawn", "DubzMining_LoadXP", function(ply)
    timer.Simple(1, function()
        if IsValid(ply) then
            ply:LoadMiningData()
        end
    end)
end)

hook.Add("PlayerDisconnected", "DubzMining_SaveXP", function(ply)
    ply:SaveMiningData()
end)

timer.Create("DubzMining_Autosave", 60, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        ply:SaveMiningData()
    end
end)

hook.Add("PlayerSay", "CheckMiningStats", function(ply, text)
    if text == "!miningxp" then
        ply:ChatPrint("Mining Level: " .. ply:GetMiningLevel() .. " | XP: " .. ply:GetMiningXP())
        return ""
    end
end)

-- Set default inventory size and XP on player spawn
hook.Add("PlayerInitialSpawn", "Dubz_SetDefaultInventorySize", function(ply)
    ply:SetNWInt("DubzInventorySize", DMS.StartingInventorySize or 20)
    ply:SetNWInt("DubzXP", 0)
    ply:SetNWInt("DubzLevel", 0)
end)