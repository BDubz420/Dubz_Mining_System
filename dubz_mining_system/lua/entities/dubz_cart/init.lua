AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("autorun/dubz_mining_config.lua")

function ENT:Initialize()
    self:SetModel("models/props_wasteland/laundry_cart002.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self.StoredOres = {} -- Store actual ore names here
    self:SetNWInt("StoredStones", 0) -- Display count
    self.MaxStorage = DMS.DefaultCartStorage or 20
end

function ENT:SpawnFunction(ply, tr, ClassName)
    if not tr.Hit then return end

    local spawnPos = tr.HitPos + tr.HitNormal * 16

    local ent = ents.Create(ClassName)
    ent:SetPos(spawnPos)
    ent:SetAngles(Angle(0, ply:EyeAngles().y, 0))
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:StartTouch(ent)
    if not IsValid(ent) or ent:GetClass() ~= "dubz_stone" then return end

    if #self.StoredOres >= self.MaxStorage then return end

    local oreName = ent:GetNWString("OreName", "")
    if oreName == "" then return end

    table.insert(self.StoredOres, oreName)
    self:SetNWInt("StoredStones", #self.StoredOres)

    ent:Remove()
    self:EmitSound("items/ammo_pickup.wav")
end

-- Called by the factory or another system to extract ores from the cart
function ENT:PullStones()
    local ores = table.Copy(self.StoredOres)
    self.StoredOres = {}
    self:SetNWInt("StoredStones", 0)
    return ores
end