AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("autorun/dubz_mining_config.lua")

function ENT:Initialize()
	self:SetModel(table.Random(DMS.GemModels))
	self:SetMaterial(DMS.Material)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
    phys:Wake()	

    -- Pick a gem based on chance
    local totalChance = 0
    for _, gem in ipairs(DMS.Ores.Gems) do
        totalChance = totalChance + gem.chance
    end

    local roll = math.random(1, totalChance)
    local current = 0
    for _, gem in ipairs(DMS.Ores.Gems) do
        current = current + gem.chance
        if roll <= current then
            self.GemData = gem
            self:SetNWString("GemName", gem.name)
            self:SetColor(gem.color)
            break
        end
    end
end

function ENT:Use(activator, caller)
    if not IsValid(caller) or not caller:IsPlayer() then return end

    local matName = self:GetNWString("GemName")
    if not matName then return end

    local key = "DMS_" .. matName .. "_amount"
    local current = caller:GetNWInt(key, 0)

    caller:SetNWInt(key, current + 1)
    caller:SaveMiningData()

    -- Optional: Notify the player
    caller:ChatPrint("Picked up 1x " .. matName)

    self:Remove()
end