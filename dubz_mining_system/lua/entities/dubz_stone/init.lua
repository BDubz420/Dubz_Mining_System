AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("autorun/dubz_mining_config.lua")
include("autorun/dubz_mining_init.lua")

function ENT:Initialize()
    self:SetModel(table.Random(DMS.StoneModels))  -- Randomize stone model
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then phys:Wake() end

    -- Choose ore type randomly based on configured ore data
    local totalChance = 0
    for _, ingot in ipairs(DMS.Ores.Ingots) do
        totalChance = totalChance + ingot.chance
    end

    local roll = math.random(1, totalChance)
    local current = 0
    for _, ingot in ipairs(DMS.Ores.Ingots) do
        current = current + ingot.chance
        if roll <= current then
            -- Store the ore data (name, price, color, etc.)
            self.OreData = ingot
            -- Set network variables for easy access on the client side
            self:SetNWString("OreName", ingot.name)
            self:SetNWInt("OrePrice", ingot.price)
            self:SetNWVector("OreColor", ingot.color)
            break
        end
    end
end
--[[
function ENT:Use()
    local oreData = self.OreData  -- Get the OreData of the stone

    if not oreData then return end  -- Ensure OreData exists

    -- Create the ingot based on the ore data stored on the stone
    local ingot = ents.Create("dubz_ingot") -- Your ingot entity
    ingot:SetPos(self:GetPos() + Vector(0, 0, 20))  -- Offset the ingot spawn a bit above
    ingot:SetModel(table.Random(DMS.IngotModels))  -- Set model of the ingot (or use a fixed one)

    -- Set the OreName to the ingot based on the stone's ore
    ingot:SetNWString("OreName", oreData.name)  -- Pass the OreName to the ingot

    -- Set the color of the ingot based on OreData
    ingot:SetColor(oreData.color)
    ingot:SetNWString("IngotName", oreData.name)  -- Set IngotName network variable
    ingot:SetNWInt("OrePrice", oreData.price)  -- Set OrePrice network variable
    ingot:Spawn()  -- Spawn the ingot

    -- Wake the ingot physics (if applicable)
    local phys = ingot:GetPhysicsObject()
    if phys:IsValid() then phys:Wake() end

    -- Remove the stone (stone is consumed when used)
    self:Remove()
end
--]]