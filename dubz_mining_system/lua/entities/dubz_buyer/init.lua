AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("autorun/dubz_mining_config.lua")

util.AddNetworkString("dubz_buyer_menu")
util.AddNetworkString("DMS_SellMaterial")
util.AddNetworkString("DMS_SellAllMaterials")
util.AddNetworkString("DMS_UpdateMaterialAmount")
util.AddNetworkString("DMS_SellAllMaster")

function ENT:Initialize()
    self:SetModel("models/Humans/Group01/male_09.mdl") -- Change if you want
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:SetUseType(SIMPLE_USE)	
	self:CapabilitiesAdd( CAP_ANIMATEDFACE || CAP_TURN_HEAD )

	self:DropToFloor()
	self:SetTrigger(true)
end

local function UpdateMaterialAmount(ply, materialName)
    local materialKey = "DMS_" .. materialName .. "_amount"
    local materialCount = ply:GetNWInt(materialKey, 0)

    -- Send the updated material count to the client
    net.Start("DMS_UpdateMaterialAmount")
    net.WriteString(materialName)
    net.WriteInt(materialCount, 32)
    net.Send(ply)
end

function DMS.GetPlayerMaterialAmount(ply, itemName, isGem)
    return ply:GetNWInt("DMS_" .. itemName .. "_amount", 0)
end

-- Function to find the material by its name in the config
local function GetMaterialFromConfig(materialName)
    -- Search for the material in the Gems
    for _, material in pairs(DMS.Ores.Gems) do
        if material.name == materialName then
            return material
        end
    end
    
    -- Search for the material in the Ingots
    for _, material in pairs(DMS.Ores.Ingots) do
        if material.name == materialName then
            return material
        end
    end

    return nil  -- Material not found
end

function ENT:Use(ply)
    net.Start("dubz_buyer_menu")
    net.WriteEntity(ply)
    net.Send(ply)
end

-- Selling a single material
net.Receive("DMS_SellMaterial", function(len, ply)
    local materialName = net.ReadString()

    -- Debug: Log the received material name
    print("Selling material: " .. materialName)

    -- Get the material from the config
    local material = GetMaterialFromConfig(materialName)

    -- If material doesn't exist, return and print a message
    if not material then
        print("Material not found: " .. materialName)
        ply:ChatPrint("Invalid material name: " .. materialName)
        return
    end

    local materialKey = "DMS_" .. materialName .. "_amount"
    local materialCount = ply:GetNWInt(materialKey, 0)

    if materialCount > 0 then
        ply:SetNWInt(materialKey, materialCount - 1)

        -- Get the price from the config
        local materialPrice = material.price

        -- Add the money to the player's balance
        ply:addMoney(materialPrice)  -- Correct method to add money

        -- Optional: Send a message to the player
        ply:ChatPrint("You sold 1x " .. materialName .. " for $" .. materialPrice)

        -- Update the material amount on the client's UI
        UpdateMaterialAmount(ply, materialName)
    else
        ply:ChatPrint("You don't have any " .. materialName .. " to sell.")
    end
end)

-- Selling all materials of a specific type
net.Receive("DMS_SellAllMaterials", function(len, ply)
    local materialName = net.ReadString()

    -- Debug: Log the received material name
    print("Selling all materials of: " .. materialName)

    -- Get the material from the config
    local material = GetMaterialFromConfig(materialName)

    -- If material doesn't exist, return and print a message
    if not material then
        print("Material not found: " .. materialName)
        ply:ChatPrint("Invalid material name: " .. materialName)
        return
    end

    local materialKey = "DMS_" .. materialName .. "_amount"
    local materialCount = ply:GetNWInt(materialKey, 0)

    if materialCount > 0 then
        local materialPrice = material.price
        ply:SetNWInt(materialKey, 0)  -- Set material count to 0

        -- Add total money from selling all materials of that type
        local totalPrice = materialPrice * materialCount
        ply:addMoney(totalPrice)  -- Correct method to add money

        -- Optional: Send a message to the player
        ply:ChatPrint("You sold " .. materialCount .. "x " .. materialName .. " for $" .. totalPrice)

        -- Update the material amount on the client's UI
        UpdateMaterialAmount(ply, materialName)
    else
        ply:ChatPrint("You don't have any " .. materialName .. " to sell.")
    end
end)

net.Receive("DMS_SellAllMaster", function(len, ply)
    local totalEarned = 0

    -- Combine both Gems and Ingots
    local allMaterials = {}
    for _, mat in pairs(DMS.Ores.Gems) do table.insert(allMaterials, mat) end
    for _, mat in pairs(DMS.Ores.Ingots) do table.insert(allMaterials, mat) end

    for _, mat in pairs(allMaterials) do
        local matName = mat.name
        local amount = ply:GetNWInt("DMS_" .. matName .. "_amount", 0)

        if amount > 0 then
            local value = amount * mat.price
            totalEarned = totalEarned + value

            ply:SetNWInt("DMS_" .. matName .. "_amount", 0)

            -- Notify client to update label
            net.Start("DMS_UpdateMaterialAmount")
                net.WriteString(matName)
                net.WriteInt(0, 32)
            net.Send(ply)
        end
    end

    if totalEarned > 0 then
        ply:addMoney(totalEarned)
        DarkRP.notify(ply, 0, 5, "You sold all materials for $" .. totalEarned)
    else
        DarkRP.notify(ply, 1, 5, "You have no materials to sell.")
    end
end)