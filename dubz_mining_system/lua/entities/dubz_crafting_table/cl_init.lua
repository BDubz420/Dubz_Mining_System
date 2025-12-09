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
local function CreateCraftingItemCard(layout, recipeKey, recipeData)
    local itemCard = vgui.Create("DPanel")
    itemCard:SetSize(180, 240)
    itemCard:SetBackgroundColor(Color(0, 0, 0, 0))

    itemCard.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 150))
        draw.SimpleText(recipeData.displayName or "Unknown Item", "DermaDefaultBold", w / 2, 10, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        
        draw.SimpleText(recipeData.displayName or "Unknown Item", "DermaDefaultBold", w / 2, 10, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    -- Add 3D Model Panel
    local modelPanel = vgui.Create("DModelPanel", itemCard)
    modelPanel:SetSize(160, 100)
    modelPanel:SetPos(10, 30)
    modelPanel:SetModel(recipeData.model or "models/props_junk/PopCan01a.mdl")

    function modelPanel:LayoutEntity(ent) return end
    function modelPanel:OnMousePressed() end

    local mn, mx = modelPanel.Entity:GetRenderBounds()
    local size = 0
    if mn and mx then
        size = math.max(mx.x - mn.x, mx.y - mn.y, mx.z - mn.z)
    end

    modelPanel:SetFOV(35)
    modelPanel:SetCamPos(Vector(size, size, size))
    modelPanel:SetLookAt((mn + mx) * 0.5)

    -- Materials list
    local materialsList = vgui.Create("DIconLayout", itemCard)
    materialsList:SetPos(10, 135)
    materialsList:SetSize(160, 50) -- You can increase height if needed
    materialsList:SetSpaceX(5)
    materialsList:SetSpaceY(4)    
    
    -- Add materials
    if recipeData.requiredItems and next(recipeData.requiredItems) ~= nil then
        for materialName, materialAmount in pairs(recipeData.requiredItems) do
            local materialLabel = vgui.Create("DLabel", materialsList)
            materialLabel:SetSize(70, 15) -- Width controls how many per row
            materialLabel:SetText(materialName .. " x" .. materialAmount)
            materialLabel:SetFont("DermaDefault")

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
            materialLabel:SetTextColor(matColor)
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
    craftButton:SetSize(160, 30)
    craftButton:SetPos(10, 195)
    craftButton:SetText("Craft")
    craftButton:SetFont("DermaDefaultBold")
    craftButton:SetTextColor(Color(255, 255, 255))
    craftButton.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(80, 180, 80, 150) or Color(60, 160, 60, 150)
        draw.RoundedBox(6, 0, 0, w, h, col)
        draw.SimpleText("Craft", "DermaDefaultBold", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    craftButton.DoClick = function()
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
    layout:SetSpaceX(15)  -- Horizontal spacing between items
    layout:SetSpaceY(15)  -- Vertical spacing between items

    -- Calculate the item width to ensure that we get a fixed number of columns
    local screenWidth, screenHeight = ScrW(), ScrH()
    local totalSpacing = 15 * (columns - 1)  -- Total horizontal spacing between items
    local itemWidth = (screenWidth - totalSpacing) / columns  -- Width of each item

    -- Set the layout's width so items will align based on the calculated item width
    layout:SetWidth(itemWidth * columns)

    return layout
end

-- Main crafting menu
local function CreateCraftingMenu(recipes, playerMaterials, columns)
    local frame = vgui.Create("DFrame")
    -- Dynamically adjust frame size based on screen size, but maintain aspect ratio
    frame:SetSize(ScrW() * 0.35, ScrH() * 0.45)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:DockPadding(10, 40, 10, 10)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 150))
        draw.RoundedBox(8, 0, 0, w, 35, Color(0, 0, 0, 150))
        draw.SimpleText("Crafting Table", "DermaLarge", w / 2, 18, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Scroll panel for grid
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(5, 5, 5, 5) -- Padding around the scroll panel

    -- Clean up the scroll bar style
    local vBar = scroll:GetVBar()
    vBar:SetWide(6)

    function vBar:Paint(w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(30, 30, 30, 200))
    end

    function vBar.btnUp:Paint(w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(50, 50, 50))
    end

    function vBar.btnDown:Paint(w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(50, 50, 50))
    end

    function vBar.btnGrip:Paint(w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(100, 100, 100))
    end

    -- Grid layout
    local layout = CreateCraftingGrid(scroll, columns)

    -- Populate cards
    for k, v in pairs(DMS.CraftingRecipes) do
        CreateCraftingItemCard(layout, k, v)
    end
end

-- Open menu from server
net.Receive("DMS_OpenCraftingMenu", function()
    local recipes = net.ReadTable()
    local playerMaterials = net.ReadTable()
    local ent = net.ReadEntity()
    local columns = DMS.CraftingColumns or 4  -- Default to 4 columns if not configured
    CreateCraftingMenu(recipes, playerMaterials, columns)
end)
