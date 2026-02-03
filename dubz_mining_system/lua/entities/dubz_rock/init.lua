AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("autorun/dubz_mining_config.lua")

util.AddNetworkString("UpdateMiningXP")

function ENT:Initialize()
    self:SetModel(table.Random(DMS.RockModels))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self.Replace = false
    self:SetNWInt("health", DMS.RockHealth)
    self:SetNWInt("distance", DMS.RockDrawDistance)
    self.OriginalPos = self:GetPos()

    -- Fallbacks for gem count
    local gemMin = DMS.GemSpawnAmountMin or 1
    local gemMax = DMS.GemSpawnAmountMax or 5
    local gemCount = math.random(gemMin, gemMax)
end

-- Weighted gem selection function
local function GetWeightedGem()
    local totalChance = 0
    for _, gem in ipairs(DMS.Ores.Gems) do
        totalChance = totalChance + gem.chance
    end

    local roll = math.random(1, totalChance)
    local cumulative = 0

    for _, gem in ipairs(DMS.Ores.Gems) do
        cumulative = cumulative + gem.chance
        if roll <= cumulative then
            return gem
        end
    end

    return DMS.Ores.Gems[1] -- fallback
end

function ENT:Think()
    -- Rock has been mined out
    if not self.Replace and self:GetNWInt("health") <= 0 then
        -- Spawn stones
        local stoneCount = math.random(DMS.StoneSpawnAmountMin, DMS.StoneSpawnAmountMax)
        for i = 1, stoneCount do
            local ore = ents.Create("dubz_stone")
            ore:SetPos(self:GetPos() + Vector(math.Rand(1, 20), math.Rand(1, 20), 20))
            ore:Spawn()
            timer.Simple(DMS.DespawnTime, function()
                if IsValid(ore) then ore:Remove() end
            end)
        end

        -- Spawn gems (weighted)
        local gemCount = math.random(DMS.GemSpawnAmountMin, DMS.GemSpawnAmountMax)
        for i = 1, gemCount do
            local gemData = GetWeightedGem()
            local gem = ents.Create("dubz_gem")
            gem:SetPos(self:GetPos() + Vector(math.Rand(-20, 20), math.Rand(-20, 20), 20))
            gem:SetNWString("GemName", gemData.name)
            gem:SetColor(gemData.color)
            gem:SetNWInt("GemPrice", gemData.price)
            gem:Spawn()

            timer.Simple(DMS.DespawnTime, function()
                if IsValid(gem) then gem:Remove() end
            end)
        end

        -- Begin respawn timer
        self.Replace = true
        self.ReplaceTime = CurTime() + (DMS.RockRespawnTime or 30)
        self.Pos = self:GetPos()
        self:SetPos(self:GetPos() + Vector(0, 0, -300)) -- Drop rock underground
    end

    if self.Replace and self.ReplaceTime < CurTime() then
        self:SetNWInt("health", DMS.RockHealth) -- Reset rock health
        self.Replace = false
        self:SetPos(self.Pos) -- Respawn the rock at original position
    end

    self:NextThink(CurTime())
    return true
end

-- Function to calculate XP required for the next level
local function GetXPRequiredForLevel(level)
    -- If XPTable has a value for this level, use it
    if DMS.Levels.XPTable[level] then
        return DMS.Levels.XPTable[level]
    else
        -- If level isn't defined in the XPTable, fallback to the dynamic formula
        return DMS.Levels.BaseXP * (level ^ DMS.Levels.XPMultiplier)
    end
end

function ENT:GiveMiningXP(ply)
    if not IsValid(ply) then return end

    local xpGain = DMS.XPPerRock or 10
    local currentXP = ply:GetNWInt("DubzXP", 0)
    local level = ply:GetNWInt("DubzLevel", 1)

    currentXP = currentXP + xpGain

    local xpForNext = GetXPRequiredForLevel(level + 1)

    if currentXP >= xpForNext then
        level = level + 1
        currentXP = currentXP - xpForNext
        DarkRP.notify(ply, 0, 6, "[Mining] You leveled up! You are now Level " .. level .. "!")
    end

    -- Update networked values
    ply:SetNWInt("DubzXP", currentXP)
    ply:SetNWInt("DubzLevel", level)

    -- Optional: keep net message if you're using it for something else
    net.Start("UpdateMiningXP")
    net.WriteInt(currentXP, 32)
    net.WriteInt(level, 32)
    net.Send(ply)

    -- Notify XP gain
    DarkRP.notify(ply, 0, 4, "[Mining] You gained " .. xpGain .. " XP!")
end

function ENT:OnTakeDamage(dmg)
    if not dmg or not IsValid(self) then return end

    local inflictor = dmg:GetInflictor()
    local attacker = dmg:GetAttacker()

    -- Check if the tool used to mine is valid
    local isToolValid = table.HasValue(DMS.MiningTools, inflictor:GetClass()) or
        (IsValid(attacker) and IsValid(attacker:GetActiveWeapon()) and table.HasValue(DMS.MiningTools, attacker:GetActiveWeapon():GetClass()))

    if isToolValid then
        local newHealth = self:GetNWInt("health", 100) - DMS.RockDamagePerHit
        self:SetNWInt("health", newHealth)

        if newHealth <= 0 then
            -- Give XP before removing rock
            if IsValid(attacker) and attacker:IsPlayer() then
                self:GiveMiningXP(attacker)
            end

            -- Mark rock for removal
            self:SetNWInt("health", 0)
        end
    end
end

function ENT:OnRemove()
    -- Optionally, clean up or play a sound here
end
