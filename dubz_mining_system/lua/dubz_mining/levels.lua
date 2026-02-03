local PLAYER = FindMetaTable("Player")

function PLAYER:GetMiningXP()
    return self.dubz_mining_xp or 0
end

function PLAYER:SetMiningXP(amount)
    self.dubz_mining_xp = amount
end

function PLAYER:GetMiningLevel()
    return self.dubz_mining_level or 1
end

function PLAYER:SetMiningLevel(level)
    self.dubz_mining_level = level
end

function PLAYER:AddMiningXP(amount)
    if not DMS.Levels.Enabled or type(amount) ~= "number" then return end
    self.dubz_mining_xp = self:GetMiningXP() + amount
    local level = self:GetMiningLevel()

    while self:CanLevelUp(level, self.dubz_mining_xp) do
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
        or math.floor(self.BaseXP * (self.XPMultiplier ^ (level - 1)))
end
