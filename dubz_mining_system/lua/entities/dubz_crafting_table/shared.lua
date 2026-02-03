ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Crafting Table"
ENT.Category = "Dubz Mining System"
ENT.Spawnable = true
ENT.AdminSpawnable = true

local PLAYER = FindMetaTable("Player")

function PLAYER:GetMiningLevel()
    return self:GetNWInt("DMS_MiningLevel", 1)
end