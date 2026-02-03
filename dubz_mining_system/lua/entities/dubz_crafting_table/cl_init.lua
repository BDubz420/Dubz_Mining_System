include("autorun/dubz_mining_config.lua")
include("shared.lua")

surface.CreateFont("DMS_CTTFont", {
    font = "HUDNumber5",
    size = 18,
    weight = 800
})

local ent = self
function ENT:Draw()
    self:DrawModel()

    local distance = LocalPlayer():GetPos():Distance(self:GetPos())
    if distance > 512 then return end

    local pos = self:GetPos() + Vector(0, 0, 10)
    local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

    cam.Start3D2D(pos, ang, 0.1)
        draw.WordBox(6, 0, -210, DMS.CraftingTableTitle, "HUDNumber5", DMS.BackgroundColor, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if distance <= 150 then
            draw.SimpleText("Press E to use", "DermaDefault", 0, -180, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    cam.End3D2D()
end

----------------------------------------------------------------------
-- CRAFTING ITEM CARD
----------------------------------------------------------------------
local function CreateCraftingItemCard(layout, recipeKey, recipeData, tableEnt)
    local playerLevel = LocalPlayer():GetMiningLevel() or 1
    local requiredLevel = recipeData.requiredLevel or 1
    local unlocked = playerLevel >= requiredLevel

    local itemCard = vgui.Create("DPanel")
    itemCard:SetSize(180, 260)

    itemCard.Paint = function(self, w, h)
        local bg = unlocked and DMS.BackgroundColor or Color(0,0,0,150)
        draw.RoundedBox(8, 0, 0, w, h, bg)

        draw.SimpleText(
            recipeData.displayName or "Unknown Item",
            "DermaDefaultBold",
            w/2, 10,
            unlocked and Color(255,255,255) or Color(180,180,180),
            TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP
        )

        if not unlocked then
            draw.SimpleText(
                "Requires Level " .. requiredLevel,
                "DermaDefaultBold",
                w/2, 30,
                Color(255,100,100),
                TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP
            )
        else
            draw.SimpleText(
                "Level " .. requiredLevel,
                "DermaDefault",
                w/2, 30,
                Color(150,255,150),
                TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP
            )
        end
    end

    ------------------------------------------------------------------
    -- Model Preview
    ------------------------------------------------------------------
    local modelPanel = vgui.Create("DModelPanel", itemCard)
    modelPanel:SetSize(160, 100)
    modelPanel:SetPos(10, 55)
    modelPanel:SetModel(recipeData.model)

    function modelPanel:LayoutEntity() return end

    local mn, mx = modelPanel.Entity:GetRenderBounds()
    local size = math.max(mx.x - mn.x, mx.y - mn.y, mx.z - mn.z)
    modelPanel:SetFOV(35)
    modelPanel:SetCamPos(Vector(size,size,size))
    modelPanel:SetLookAt((mn + mx) * 0.5)

    ------------------------------------------------------------------
    -- Material List (multi-column)
    ------------------------------------------------------------------
    local matPanel = vgui.Create("DPanel", itemCard)
    matPanel:SetPos(10, 155)
    matPanel:SetSize(160, 70)
    matPanel.Paint = function() end

    local materials = recipeData.requiredItems or {}
    local colWidth = 78
    local lineHeight = 14
    local maxHeight = matPanel:GetTall()

    local currentX = 0
    local currentY = 0
    local maxColumns = math.floor(matPanel:GetWide() / colWidth)

    local function AddMaterial(text, color)
        local lbl = vgui.Create("DLabel", matPanel)
        lbl:SetFont("DermaDefault")
        lbl:SetText(text)
        lbl:SetTextColor(color)
        lbl:SizeToContents()
        lbl:SetPos(currentX, currentY)

        currentY = currentY + lineHeight

        if (currentY + lineHeight) > maxHeight then
            if currentX + colWidth < maxColumns * colWidth then
                currentY = 0
                currentX = currentX + colWidth
            end
        end
    end

    for materialName, amount in pairs(materials) do
        local text = materialName .. " x" .. amount
        local matColor = Color(200,200,200)

        for _, gem in ipairs(DMS.Ores.Gems) do
            if gem.name == materialName then matColor = gem.color break end
        end
        for _, ing in ipairs(DMS.Ores.Ingots) do
            if ing.name == materialName then matColor = ing.color break end
        end

        AddMaterial(text, matColor)
    end

    ------------------------------------------------------------------
    -- Craft Button
    ------------------------------------------------------------------
    local craftButton = vgui.Create("DButton", itemCard)
    craftButton:SetSize(160, 30)
    craftButton:SetPos(10, 225)
    craftButton:SetText("")
    craftButton:SetEnabled(unlocked)

    craftButton.Paint = function(self, w, h)
        local col
        if not unlocked then
            col = Color(120,40,40,180)
            draw.RoundedBox(6,0,0,w,h,col)
            draw.SimpleText("LOCKED","DermaDefaultBold",w/2,h/2,Color(255,180,180),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            return
        end

        col = self:IsHovered() and Color(80,180,80,150) or Color(60,160,60,150)
        draw.RoundedBox(6,0,0,w,h,col)
        draw.SimpleText("Craft","DermaDefaultBold",w/2,h/2,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    craftButton.DoClick = function()
        if not unlocked then return end
        if not IsValid(tableEnt) then return end

        net.Start("DMS_RequestCraftItem")
            net.WriteEntity(tableEnt)
            net.WriteString(recipeKey)
        net.SendToServer()
    end

    layout:Add(itemCard)
end

----------------------------------------------------------------------
-- Grid Layout
----------------------------------------------------------------------
local function CreateCraftingGrid(parent, columns)
    local layout = vgui.Create("DIconLayout", parent)
    layout:Dock(FILL)
    layout:SetSpaceX(15)
    layout:SetSpaceY(15)

    return layout
end

----------------------------------------------------------------------
-- Main Crafting Menu
----------------------------------------------------------------------
local function CreateCraftingMenu(tableEnt, recipes, playerMaterials, columns)
    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW() * 0.305, ScrH() * 0.45)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:DockPadding(0, 25, 0, 0)

    frame.Paint = function(self, w, h)
        draw.RoundedBox(8,0,0,w,h,DMS.BackgroundColor)
        draw.SimpleText(DMS.CraftingTableTitle,"DMS_CTTFont",8,15,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
    end

    local contentBG = vgui.Create("DPanel", frame)
    contentBG:Dock(FILL)
    contentBG:DockMargin(6,6,6,6)
    contentBG.Paint = function(self, w, h)
        draw.RoundedBox(8,0,0,w,h,DMS.BackgroundColor)
    end

    local scroll = vgui.Create("DScrollPanel", contentBG)
    scroll:Dock(FILL)
    scroll:DockMargin(5,5,5,5)

    local vbar = scroll:GetVBar()
    vbar:SetWide(8)
    vbar.Paint = function(self,w,h) draw.RoundedBox(4,0,0,w,h,Color(20,20,20,180)) end
    vbar.btnGrip.Paint = function(self,w,h) draw.RoundedBox(4,0,0,w,h,Color(80,80,80,200)) end

    local grid = vgui.Create("DIconLayout", scroll)
    grid:Dock(FILL)
    grid:SetSpaceX(5)
    grid:SetSpaceY(5)

    for k, v in pairs(DMS.CraftingRecipes) do
        CreateCraftingItemCard(grid, k, v, tableEnt)
    end
end

----------------------------------------------------------------------
-- Open Menu
----------------------------------------------------------------------
net.Receive("DMS_OpenCraftingMenu", function()
    local ent = net.ReadEntity()
    local recipes = net.ReadTable()
    local playerMaterials = net.ReadTable()
    local columns = DMS.CraftingColumns or 4

    if not IsValid(ent) then return end

    CreateCraftingMenu(ent, recipes, playerMaterials, columns)
end)
