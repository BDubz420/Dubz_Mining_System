-- Core Hooks for Dubz Mining
include("autorun/dubz_mining_config.lua")

local PLAYER = FindMetaTable("Player")
local dataFolder = "dubz_mining"

-- Create data folder if it doesn't exist
if not file.IsDir(dataFolder, "DATA") then
    file.CreateDir(dataFolder)
end

-- Set default XP, level, and ores values
function PLAYER:SetMiningXP(xp)
    self:SetNWInt("DubzXP", xp)
end

function PLAYER:GetMiningXP()
    return self:GetNWInt("DubzXP", 0)
end

function PLAYER:SetMiningLevel(level)
    self:SetNWInt("DubzLevel", level)
end

function PLAYER:GetMiningLevel()
    return self:GetNWInt("DubzLevel", 1)
end

-- Save the player's mining data including XP, level, ingots, and gems
function PLAYER:SaveMiningData()
    local data = {
        xp = self:GetMiningXP(),
        level = self:GetMiningLevel(),
        Ingots = {},
        Gems = {}
    }

    if DMS and DMS.Ores then

        -- Save Ingots
        for _, ingot in ipairs(DMS.Ores.Ingots) do
            local key = "DMS_" .. ingot.name .. "_amount"
            local count = self:GetNWInt(key, 0)
            -- Only save if count is greater than 0 to avoid saving empty values
            if count > 0 then
                data.Ingots[ingot.name] = count
            end
        end

        -- Save Gems
        for _, gem in ipairs(DMS.Ores.Gems) do
            local key = "DMS_" .. gem.name .. "_amount"
            local count = self:GetNWInt(key, 0)
            -- Only save if count is greater than 0 to avoid saving empty values
            if count > 0 then
                data.Gems[gem.name] = count
            end
        end

        -- Save data to file
        local jsonData = util.TableToJSON(data, true)
        if jsonData then
            file.Write("dubz_mining/" .. self:SteamID64() .. ".txt", jsonData)
            --print("[DubzMining] Saved data for " .. self:Nick())
        else
            print("[DubzMining] Failed to serialize player data for", self:Nick())
        end
    end
end

-- Load the player's mining data, including XP, level, ingots, and gems
function PLAYER:LoadMiningData()
    local path = "dubz_mining/" .. self:SteamID64() .. ".txt"
    if file.Exists(path, "DATA") then
        local data = util.JSONToTable(file.Read(path, "DATA"))
        if data then
            -- Load XP and Level
            self:SetMiningXP(data.xp or 0)
            self:SetMiningLevel(data.level or 1)

            -- Load Ingots
            for ingotName, amount in pairs(data.Ingots or {}) do
                local key = "DMS_" .. ingotName .. "_amount"
                self:SetNWInt(key, amount)
            end

            -- Load Gems
            for gemName, amount in pairs(data.Gems or {}) do
                local key = "DMS_" .. gemName .. "_amount"
                self:SetNWInt(key, amount)
            end

            --print("[DubzMining] Loaded data for " .. self:Nick())
        else
            print("[DubzMining] Failed to decode mining data for", self:Nick())
        end
    else
        -- First-time setup if no data exists
        self:SetMiningXP(0)
        self:SetMiningLevel(1)

        -- Initialize the ingots and gems to 0 for first-time players
        for _, ingot in ipairs(DMS.Ores.Ingots) do
            self:SetNWInt("DMS_" .. ingot.name .. "_amount", 0)
        end
        for _, gem in ipairs(DMS.Ores.Gems) do
            self:SetNWInt("DMS_" .. gem.name .. "_amount", 0)
        end

        print("[DubzMining] No data found for " .. self:Nick() .. ", initialized to default.")
    end
end

-- Load player data on spawn
hook.Add("PlayerInitialSpawn", "DubzMining_InitialSetup", function(ply)
    timer.Simple(1, function()
        if IsValid(ply) then
            ply:LoadMiningData()
        end
    end)

    timer.Simple(1.1, function()
        if IsValid(ply) and ply:GetNWInt("DubzInventorySize", 0) == 0 then
            ply:SetNWInt("DubzInventorySize", DMS.StartingInventorySize or 20)
        end
    end)
end)

-- Save player data on disconnect
hook.Add("PlayerDisconnected", "DubzMining_SaveXP", function(ply)
    ply:SaveMiningData()
end)

-- Periodically save mining data for all players
timer.Create("DubzMining_Autosave", 60, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        ply:SaveMiningData()
    end
end)

-- Command to check mining stats
hook.Add("PlayerSay", "CheckMiningStats", function(ply, text)
    if text == "!miningxp" then
        ply:ChatPrint("Mining Level: " .. ply:GetMiningLevel() .. " | XP: " .. ply:GetMiningXP())
        return ""  -- Suppress the chat message from showing
    end
end)
