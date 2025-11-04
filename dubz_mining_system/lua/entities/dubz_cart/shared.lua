ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Minecart"
ENT.Author = "Dubz"
ENT.Category = "Dubz Mining System"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
	self:NetworkVar("Entity",0,"owning_ent")
end