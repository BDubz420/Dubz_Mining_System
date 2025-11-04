AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("autorun/dubz_mining_config.lua")

function ENT:Initialize()
    self:SetModel(table.Random(DMS.IngotModels))
    self:SetMaterial(DMS.Material)
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    phys:Wake() 

    -- Get the ore type from the stone or forge (if set)
    local oreName = self:GetNWString("OreName", "")

    if oreName == "" then
        -- If no OreName is set, pick a random ingot
        local totalChance = 0
        for _, ingot in ipairs(DMS.Ores.Ingots) do
            totalChance = totalChance + ingot.chance
        end

        local roll = math.random(1, totalChance)
        local current = 0
        for _, ingot in ipairs(DMS.Ores.Ingots) do
            current = current + ingot.chance
            if roll <= current then
                -- Randomly selected ingot
                self.ingotData = ingot
                self:SetNWString("IngotName", ingot.name)
                self:SetColor(ingot.color)
                break
            end
        end
    else
        -- If OreName is set, find the corresponding ingot and set it
        for _, ore in ipairs(DMS.Ores.Ingots) do
            if ore.name == oreName then
                self.ingotData = {
                    name = ore.name,
                    color = ore.color,
                    price = ore.price,
                    chance = ore.chance
                }
                -- Set the ingot based on the ore data
                self:SetNWString("IngotName", ore.name)
                self:SetColor(ore.color)
                break
            end
        end
    end
end


function ENT:Use(activator, caller)
    if not IsValid(caller) or not caller:IsPlayer() then return end

    local matName = self:GetNWString("IngotName")
    if not matName then return end

    local key = "DMS_" .. matName .. "_amount"
    local current = caller:GetNWInt(key, 0)

    caller:SetNWInt(key, current + 1)
    caller:SaveMiningData()

    -- Optional: Notify the player
    caller:ChatPrint("Picked up 1x " .. matName)

    self:Remove()
end