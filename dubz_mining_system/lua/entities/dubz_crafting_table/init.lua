AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("DMS_OpenCraftingMenu")
util.AddNetworkString("DMS_RequestCraftItem")

function ENT:Initialize()
    self:SetModel(table.Random(DMS.CraftingTableModels))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end
end

-- Player presses E on the table
function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    -- Build player materials table
    local playerMaterials = {}
    for _, gem in ipairs(DMS.Ores.Gems) do
        playerMaterials[gem.name] = activator:GetNWInt("DMS_" .. gem.name .. "_amount", 0)
    end
    for _, ing in ipairs(DMS.Ores.Ingots) do
        playerMaterials[ing.name] = activator:GetNWInt("DMS_" .. ing.name .. "_amount", 0)
    end

    -- Send crafting menu request
    net.Start("DMS_OpenCraftingMenu")
        net.WriteEntity(self)
        net.WriteTable(DMS.CraftingRecipes)
        net.WriteTable(playerMaterials)
    net.Send(activator)
end

-- Crafting request from client
net.Receive("DMS_RequestCraftItem", function(len, ply)
    local craftTable = net.ReadEntity()
    local recipeKey = net.ReadString()

    if not IsValid(craftTable) 
    or craftTable:GetClass() ~= "dubz_crafting_table" then
        ply:ChatPrint("Crafting failed: Invalid crafting table.")
        return
    end

    local recipe = DMS.CraftingRecipes[recipeKey]
    if not recipe then return end

    -- LEVEL CHECK
    local playerLevel = ply:GetMiningLevel()
    if playerLevel < recipe.requiredLevel then
        ply:ChatPrint("You need to be level " .. recipe.requiredLevel .. " to craft this item.")
        return
    end

    -- MATERIAL CHECKS
    for mat, needed in pairs(recipe.requiredItems) do
        local amount = ply:GetNWInt("DMS_" .. mat .. "_amount", 0)
        if amount < needed then
            ply:ChatPrint("You don't have enough " .. mat .. ".")
            return
        end
    end

    -- Subtract consumed materials
    for mat, needed in pairs(recipe.requiredItems) do
        local key = "DMS_" .. mat .. "_amount"
        ply:SetNWInt(key, ply:GetNWInt(key, 0) - needed)
    end

    -- Spawn object ON TOP OF TABLE
    local mins, maxs = craftTable:OBBMins(), craftTable:OBBMaxs()
    local spawnPos = craftTable:LocalToWorld(Vector(0, 0, maxs.z + 5))

    if recipe.spawnType == "weapon" then
        local wEnt = ents.Create("spawned_weapon")
        wEnt:SetModel(recipe.model)
        wEnt:SetWeaponClass(recipe.class)
        wEnt:SetPos(spawnPos)
        wEnt:Spawn()

    elseif recipe.spawnType == "entity" then
        local e = ents.Create(recipe.class)
        if IsValid(e) then
            e:SetPos(spawnPos)
            e:Spawn()
        end

    elseif recipe.spawnType == "give" then
        ply:Give(recipe.class)
    end

    ply:ChatPrint("Crafted: " .. recipe.displayName)
end)
