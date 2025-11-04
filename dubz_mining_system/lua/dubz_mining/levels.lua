include("autorun/dubz_mining_config.lua")

local PLAYER = FindMetaTable("Player")

function PLAYER:GetMiningXP()
    return self:GetNWInt("DubzXP", 0) -- Using NWInt to sync XP across client-server
end

function PLAYER:SetMiningXP(amount)
    self:SetNWInt("DubzXP", amount) -- Sync XP using NWInt
end

function PLAYER:GetMiningLevel()
    return self:GetNWInt("DubzLevel", 1) -- Using NWInt for consistency
end

function PLAYER:SetMiningLevel(level)
    self:SetNWInt("DubzLevel", level) -- Sync level using NWInt
end

function PLAYER:AddMiningXP(amount)
    if not DMS.Levels.Enabled or type(amount) ~= "number" then return end
    local currentXP = self:GetMiningXP()
    local newXP = currentXP + amount
    self:SetMiningXP(newXP)
    local level = self:GetMiningLevel()

    while self:CanLevelUp(level, newXP) do
        level = level + 1
        self:SetMiningLevel(level)
        DarkRP.notify(self, 0, 4, "[Mining] You leveled up to level " .. level .. "!")
    end
end

function PLAYER:CanLevelUp(currentLevel, currentXP)
    if currentLevel >= DMS.Levels.MaxLevel then return false end
    return currentXP >= DMS.Levels:GetXPForLevel(currentLevel + 1)
end

function DMS.Levels:GetXPForLevel(level)
    return self.XPTable and self.XPTable[level]
        or math.floor(self.BaseXP * (self.XPMultiplier ^ (level - 1))) -- Ensure proper XP calculation
end

timer.Create("DMS_XPGiveTimer", DMS.XPDropTime, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) or not ply:IsPlayer() then continue end
        if not DMS.MiningJob then continue end

        local job = ply:Team()
        if job == DMS.MiningJob then
            local currentXP = ply:GetNWInt("DubzXP", 0)
            local newXP = currentXP + DMS.XPDropAmount
            ply:SetNWInt("DubzXP", newXP)

            -- Use DarkRP notify (type 0 = generic, 1 = error, 2 = hint)
            DarkRP.notify(ply, 0, 4, "You gained " .. DMS.XPDropAmount .. " XP for mining!")
        end
    end
end)