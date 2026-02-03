AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("autorun/dubz_mining_config.lua")
include("autorun/dubz_mining_init.lua")

function ENT:Initialize()
    self:SetModel(table.Random(DMS.StoneModels))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then phys:Wake() end

    -- Choose ore type randomly based on configured ingot list
    local totalChance = 0
    for _, ingot in ipairs(DMS.Ores.Ingots) do
        totalChance = totalChance + ingot.chance
    end

    local roll = math.random(1, totalChance)
    local current = 0

    for _, ingot in ipairs(DMS.Ores.Ingots) do
        current = current + ingot.chance
        if roll <= current then

            self.OreData = ingot

            self:SetNWString("OreName", ingot.name)
            self:SetNWInt("OrePrice", ingot.price)

            -- FIX: Color cannot be networked directly!
            self:SetNWVector("OreColor", Vector(ingot.color.r, ingot.color.g, ingot.color.b))

            break
        end
    end
end
