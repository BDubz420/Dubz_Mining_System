include("shared.lua")

surface.CreateFont("DMS_CraftingFont", {
    font = "HUDNumber5",     -- HUDNumber5 uses this internally
    size = 15,                 -- HUDNumber5 is ~40–42 px, so this is slightly smaller
    weight = 900,
    antialias = true,
    extended = true
})

function ENT:Draw()
    self:DrawModel()

    local distance = LocalPlayer():GetPos():Distance(self:GetPos())
    if distance > 512 then return end  -- Only display UI within 512 units

    local pos = self:GetPos() + Vector(0, 0, 10)
    local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

    cam.Start3D2D(pos, ang, 0.1)
        -- Display the gem's name
        draw.WordBox(6, 0, -210, "Crafting Table", "HUDNumber5", Color(0, 0, 0, 150), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Check if the player is close enough and display "Press E to pick up" message
        if distance <= 150 then  -- Display message only if the player is close (within 150 units)
            draw.SimpleText("Press E to use", "DMS_CraftingFont", 0, -180, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    cam.End3D2D()
end

-- Function to create the crafting item card
local function CreateCraftingItemCard(layout, recipeKey, recipeData, playerMaterials, ent)
    local itemCard = vgui.Create("DPanel")
    itemCard:SetSize(240, 280)
    itemCard:SetBackgroundColor(Color(0, 0, 0, 0))

    local accent = Color(0, 170, 255)

    itemCard.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(15, 15, 15, 200))
        draw.RoundedBoxEx(12, 0, 0, w, 40, Color(20, 20, 20, 220), true, true, false, false)
        draw.RoundedBox(0, 0, 36, w, 2, accent)
        draw.SimpleText(recipeData.displayName or "Unknown Item", "DermaLarge", 12, 20, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(recipeData.description or "Choose materials to craft this item.", "DermaDefault", 12, 55, Color(190, 190, 190), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    -- Add 3D Model Panel
    local modelPanel = vgui.Create("DModelPanel", itemCard)
    modelPanel:SetSize(140, 140)
    modelPanel:SetPos(12, 70)
    modelPanel:SetModel(recipeData.model or "models/props_junk/PopCan01a.mdl")

    function modelPanel:LayoutEntity(ent) return end
    function modelPanel:OnMousePressed() end

    local mn, mx = modelPanel.Entity:GetRenderBounds()
    local size = 0
    if mn and mx then
        size = math.max(mx.x - mn.x, mx.y - mn.y, mx.z - mn.z)
    end

    modelPanel:SetFOV(30)
    modelPanel:SetCamPos(Vector(size, size, size))
    modelPanel:SetLookAt((mn + mx) * 0.5)

    -- Materials list
    local materialsList = vgui.Create("DIconLayout", itemCard)
    materialsList:SetPos(160, 80)
    materialsList:SetSize(80, 110)
    materialsList:SetSpaceX(0)
    materialsList:SetSpaceY(6)
    
    -- Add materials
    if recipeData.requiredItems and next(recipeData.requiredItems) ~= nil then
        for materialName, materialAmount in pairs(recipeData.requiredItems) do
            local materialLabel = vgui.Create("DPanel", materialsList)
            materialLabel:SetSize(80, 24)

            local ownedAmount = (playerMaterials and playerMaterials[materialName]) or 0
            local hasEnough = ownedAmount >= materialAmount

            -- Determine the color based on whether the material is a gem or ingot
            local matColor
            local foundColor = false

            for _, gem in ipairs(DMS.Ores.Gems) do
                if gem.name == materialName then
                    matColor = gem.color
                    foundColor = true
                    break
                end
            end

            if not foundColor then
                for _, ingot in ipairs(DMS.Ores.Ingots) do
                    if ingot.name == materialName then
                        matColor = ingot.color
                        break
                    end
                end
            end

            matColor = matColor or Color(200, 200, 200)

            materialLabel.Paint = function(self, w, h)
                local bgCol = hasEnough and Color(30, 120, 60, 160) or Color(120, 60, 30, 160)
                draw.RoundedBox(6, 0, 0, w, h, bgCol)
                draw.SimpleText(materialName, "DermaDefaultBold", 8, h / 2, matColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(ownedAmount .. "/" .. materialAmount, "DermaDefault", w - 8, h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end
    else
        local noMaterialsLabel = vgui.Create("DLabel", materialsList)
        noMaterialsLabel:SetSize(150, 15)
        noMaterialsLabel:SetText("No materials")
        noMaterialsLabel:SetFont("DermaDefault")
        noMaterialsLabel:SetTextColor(Color(200, 200, 200))
    end

    -- Craft button
    local craftButton = vgui.Create("DButton", itemCard)
    craftButton:SetSize(itemCard:GetWide() - 24, 36)
    craftButton:SetPos(12, 230)
    craftButton:SetText("")

    local function HasAllMaterials()
        if not recipeData.requiredItems then return true end

        for materialName, materialAmount in pairs(recipeData.requiredItems) do
            local ownedAmount = (playerMaterials and playerMaterials[materialName]) or 0
            if ownedAmount < materialAmount then
                return false
            end
        end

        return true
    end

    craftButton.Paint = function(self, w, h)
        local ready = HasAllMaterials()
        local baseCol = ready and Color(40, 140, 70, 220) or Color(140, 70, 40, 220)
        local hoverCol = ready and Color(70, 190, 110, 240) or Color(170, 90, 60, 240)
        draw.RoundedBox(8, 0, 0, w, h, self:IsHovered() and hoverCol or baseCol)

        local label = ready and "Craft Item" or "Missing Materials"
        draw.SimpleText(label, "DermaDefaultBold", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    craftButton.DoClick = function()
        if not HasAllMaterials() then return end

        net.Start("DMS_RequestCraftItem")
            net.WriteString(recipeKey)
            net.WriteEntity(ent)
        net.SendToServer()
    end

    if IsValid(layout) then
        layout:Add(itemCard)
    end
end

-- Grid layout creation using DTileLayout
local function CreateCraftingGrid(parent, columns)
    local layout = vgui.Create("DIconLayout", parent)
    layout:Dock(FILL)
    layout:SetSpaceX(12)  -- Horizontal spacing between items
    layout:SetSpaceY(12)  -- Vertical spacing between items

    -- Calculate the item width to ensure that we get a fixed number of columns
    local screenWidth, screenHeight = ScrW(), ScrH()
    local totalSpacing = 15 * (columns - 1)  -- Total horizontal spacing between items
    local itemWidth = (screenWidth - totalSpacing) / columns  -- Width of each item

    -- Set the layout's width so items will align based on the calculated item width
    layout:SetWidth(itemWidth * columns)

    return layout
end

-- Main crafting menu
local function CreateCraftingMenu(recipes, playerMaterials, columns, ent)
    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW() * 0.45, ScrH() * 0.55)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:DockPadding(16, 56, 16, 16)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(10, 10, 10, 230))
        draw.RoundedBoxEx(12, 0, 0, w, 46, Color(20, 20, 20, 240), true, true, false, false)
        draw.RoundedBox(0, 0, 42, w, 2, Color(0, 170, 255))
        draw.SimpleText("Crafting Table", "Trebuchet24", 12, 23, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Combine your mined resources into useful items.", "DermaDefault", 12, 43, Color(190, 190, 190), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    -- Scroll panel for grid
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(6, 6, 6, 6) -- Padding around the scroll panel

    -- Clean up the scroll bar style
    local vBar = scroll:GetVBar()
    vBar:SetWide(8)

    function vBar:Paint(w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(25, 25, 25, 200))
    end

    function vBar.btnUp:Paint(w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 40))
    end

    function vBar.btnDown:Paint(w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 40))
    end

    function vBar.btnGrip:Paint(w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(120, 120, 120))
    end

    -- Grid layout
    local layout = CreateCraftingGrid(scroll, columns)

    -- Populate cards
    for k, v in pairs(DMS.CraftingRecipes) do
        CreateCraftingItemCard(layout, k, v, playerMaterials, ent)
    end
end

-- Open menu from server
net.Receive("DMS_OpenCraftingMenu", function()
    local recipes = net.ReadTable()
    local playerMaterials = net.ReadTable()
    local ent = net.ReadEntity()
    local columns = DMS.CraftingColumns or 4  -- Default to 4 columns if not configured
    CreateCraftingMenu(recipes, playerMaterials, columns, ent)
end)
