AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("autorun/dubz_mining_config.lua")

util.AddNetworkString("DMS_OpenCraftingMenu")
util.AddNetworkString("DMS_RequestCraftItem")
util.AddNetworkString("DMS_CraftResult")

function ENT:Initialize()
	self:SetModel(table.Random(DMS.CraftingTableModels))
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
    phys:Wake()
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    -- Collect the player's current inventory
    local playerMaterials = {}
    for _, gem in ipairs(DMS.Ores.Gems) do
        playerMaterials[gem.name] = activator:GetNWInt("DMS_" .. gem.name .. "_amount", 0)
    end
    for _, ingot in ipairs(DMS.Ores.Ingots) do
        playerMaterials[ingot.name] = activator:GetNWInt("DMS_" .. ingot.name .. "_amount", 0)
    end

    -- Send data to the client
    net.Start("DMS_OpenCraftingMenu")
    net.WriteTable(DMS.CraftingRecipes)  -- Send the crafting recipes to the client
    net.WriteTable(playerMaterials)     -- Send the player's materials to the client
    net.Send(activator)
end

net.Receive("DMS_RequestCraftItem", function(len, ply)
    local recipeKey = net.ReadString()

    local recipe = DMS.CraftingRecipes[recipeKey]
    if not recipe then return end

    -- Check materials using NWInts
    for material, amountNeeded in pairs(recipe.requiredItems or {}) do
        local key = "DMS_" .. material .. "_amount"
        local playerAmount = ply:GetNWInt(key, 0)
        if playerAmount < amountNeeded then
            ply:ChatPrint("You don't have enough " .. material .. " to craft " .. (recipe.displayName or recipeKey))
            return
        end
    end

    -- Subtract used materials
    for material, amountNeeded in pairs(recipe.requiredItems or {}) do
        local key = "DMS_" .. material .. "_amount"
        local current = ply:GetNWInt(key, 0)
        ply:SetNWInt(key, current - amountNeeded)
    end

    -- Spawn the result
    local spawnPos = ply:GetPos() + ply:GetForward() * 50 + Vector(0, 0, 60)

    if recipe.spawnType == "weapon" then
        local weaponEnt = ents.Create("spawned_weapon")
        weaponEnt:SetModel(recipe.model or "models/weapons/w_pistol.mdl")
        weaponEnt:SetWeaponClass(recipe.class or recipe.itemName)
        weaponEnt:SetPos(spawnPos)
        weaponEnt:Spawn()
    elseif recipe.spawnType == "entity" then
        local ent = ents.Create(recipe.class or recipe.itemName)
        if not IsValid(ent) then return end
        ent:Setowning_ent(ply)
        ent:SetPos(spawnPos)
        ent:Spawn()
    elseif recipe.spawnType == "give" then
        ply:Give(recipe.class or recipe.itemName)
    end

    ply:ChatPrint("Successfully crafted " .. (recipe.displayName or recipeKey))
end)