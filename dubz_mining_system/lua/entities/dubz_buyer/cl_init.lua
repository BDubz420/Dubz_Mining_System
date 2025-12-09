include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local pos = self:GetPos()
    local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

    local distance = 500
    if LocalPlayer():GetPos():Distance(pos) > distance then return end

    cam.Start3D2D(pos + Vector(0, 0, 77), ang, 0.1)
        draw.RoundedBox(8, -140, -10, 280, 50, Color(0, 0, 0, 180))
        draw.SimpleTextOutlined("Gem & Ore Buyer", "HUDNumber5", 0, -10, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
        draw.RoundedBox(4, -100, 20, 200, 10, Color(40, 40, 40))
        draw.RoundedBox(4, -100, 20, 200, 10, Color(0, 170, 255))
    cam.End3D2D()
end

net.Receive("dubz_buyer_menu", function()
    local ply = net.ReadEntity()

    local frame = vgui.Create("DFrame")
    frame:SetSize(620, 460)
    frame:SetTitle("")
    frame:Center()
    frame:MakePopup()

    frame.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(10, 10, 10, 220))
        draw.RoundedBoxEx(12, 0, 0, w, 52, Color(20, 20, 20, 230), true, true, false, false)
        draw.RoundedBox(0, 0, 48, w, 2, Color(0, 170, 255))
        draw.SimpleText("Gem & Ore Buyer", "Trebuchet24", 16, 26, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Sell your mined haul for quick cash.", "DermaDefault", 16, 46, Color(190, 190, 190), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local menuw, menuh = frame:GetWide(), frame:GetTall()

    local summaryPanel = vgui.Create("DPanel", frame)
    summaryPanel:Dock(TOP)
    summaryPanel:SetTall(54)
    summaryPanel:DockMargin(12, 60, 12, 8)
    summaryPanel.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(16, 16, 16, 220))
        draw.RoundedBox(10, 0, 0, w, h, Color(0, 170, 255, 35))
    end

    local totalLabel = vgui.Create("DLabel", summaryPanel)
    totalLabel:Dock(LEFT)
    totalLabel:DockMargin(12, 0, 0, 0)
    totalLabel:SetWide(menuw * 0.5)
    totalLabel:SetFont("Trebuchet24")
    totalLabel:SetTextColor(color_white)
    totalLabel:SetText("Potential Payout: $0")

    local hintLabel = vgui.Create("DLabel", summaryPanel)
    hintLabel:Dock(RIGHT)
    hintLabel:DockMargin(0, 0, 12, 0)
    hintLabel:SetFont("DermaDefault")
    hintLabel:SetTextColor(Color(200, 200, 200))
    hintLabel:SetText("Tip: Hover items for details.")
    hintLabel:SizeToContents()

    local shopPanel = vgui.Create("DPanel", frame)
    shopPanel:Dock(FILL)
    shopPanel:DockMargin(12, 4, 12, 64)
    shopPanel.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(12, 12, 12, 220))
    end

    local scrollPanel = vgui.Create("DScrollPanel", shopPanel)
    scrollPanel:Dock(FILL)
    scrollPanel:DockMargin(5, 5, 5, 5)

    local vbar = scrollPanel:GetVBar()
    vbar:SetWide(8)
    vbar.Paint = function(self, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 20, 180)) end
    vbar.btnUp.Paint = function(self, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(60, 60, 60, 180)) end
    vbar.btnDown.Paint = function(self, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(60, 60, 60, 180)) end
    vbar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(80, 80, 80, 200)) end

    local materials = {}
    for _, material in pairs(DMS.Ores.Gems) do table.insert(materials, material) end
    for _, material in pairs(DMS.Ores.Ingots) do table.insert(materials, material) end

    local materialLabels = {}

    local function CalculateTotalValue()
        local total = 0
        for _, mat in pairs(materials) do
            local amount = LocalPlayer():GetNWInt("DMS_" .. mat.name .. "_amount", 0)
            total = total + (amount * mat.price)
        end
        return total
    end

    local masterSellButton -- declared early so we can update text

    local function RefreshTotalLabel()
        totalLabel:SetText("Potential Payout: $" .. string.Comma(CalculateTotalValue()))
        totalLabel:SizeToContents()
    end

    RefreshTotalLabel()

    for _, material in pairs(materials) do
        local materialName = material.name
        local materialColor = material.color
        local materialPrice = material.price

        local materialPanel = vgui.Create("DPanel", scrollPanel)
        materialPanel:SetTall(70)
        materialPanel:Dock(TOP)
        materialPanel:DockMargin(0, 0, 0, 8)
        materialPanel.Paint = function(self, w, h)
            local bg = self:IsHovered() and Color(24, 24, 24, 230) or Color(18, 18, 18, 210)
            draw.RoundedBox(8, 0, 0, w, h, bg)
            draw.RoundedBox(8, 0, 0, 6, h, materialColor)
            draw.SimpleText(materialName, "Trebuchet24", 18, 16, materialColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText("$" .. string.Comma(materialPrice) .. " each", "DermaDefaultBold", 18, 44, Color(220, 220, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local countLabel = vgui.Create("DLabel", materialPanel)
        countLabel:SetPos(260, 18)
        countLabel:SetText("Amount: " .. LocalPlayer():GetNWInt("DMS_" .. materialName .. "_amount", 0))
        countLabel:SetTextColor(Color(255, 255, 255))
        countLabel:SetFont("DermaDefaultBold")
        countLabel:SizeToContents()

        local valueLabel = vgui.Create("DLabel", materialPanel)
        valueLabel:SetPos(260, 36)
        valueLabel:SetText("Value: $" .. string.Comma(materialPrice * LocalPlayer():GetNWInt("DMS_" .. materialName .. "_amount", 0)))
        valueLabel:SetTextColor(Color(200, 200, 200))
        valueLabel:SetFont("DermaDefault")
        valueLabel:SizeToContents()

        materialLabels[materialName] = countLabel

        local sellButton = vgui.Create("DButton", materialPanel)
        sellButton:SetPos(materialPanel:GetWide() - 240, 10)
        sellButton:SetSize(110, 24)
        sellButton:SetText("Sell 1")
        sellButton:SetFont("DermaDefaultBold")
        sellButton:SetTextColor(Color(255, 255, 255))
        sellButton.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(60, 150, 230, 220) or Color(40, 120, 200, 200)
            draw.RoundedBox(6, 0, 0, w, h, col)
        end
        sellButton.DoClick = function()
            net.Start("DMS_SellMaterial")
            net.WriteString(materialName)
            net.SendToServer()
        end

        local sellAllButton = vgui.Create("DButton", materialPanel)
        sellAllButton:SetPos(materialPanel:GetWide() - 120, 10)
        sellAllButton:SetSize(110, 24)
        sellAllButton:SetText("Sell All")
        sellAllButton:SetFont("DermaDefaultBold")
        sellAllButton:SetTextColor(Color(255, 255, 255))
        sellAllButton.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(90, 200, 130, 220) or Color(70, 170, 110, 200)
            draw.RoundedBox(6, 0, 0, w, h, col)
        end
        sellAllButton.DoClick = function()
            net.Start("DMS_SellAllMaterials")
            net.WriteString(materialName)
            net.SendToServer()
        end

        materialPanel.PerformLayout = function(self, w, h)
            sellButton:SetPos(w - 235, 14)
            sellAllButton:SetPos(w - 115, 14)
        end

        local lastAmount = -1

        materialPanel.Think = function(self)
            if not IsValid(countLabel) or not IsValid(valueLabel) then return end

            local currentAmount = LocalPlayer():GetNWInt("DMS_" .. materialName .. "_amount", 0)
            if currentAmount ~= lastAmount then
                lastAmount = currentAmount

                countLabel:SetText("Amount: " .. currentAmount)
                countLabel:SizeToContents()

                valueLabel:SetText("Value: $" .. string.Comma(materialPrice * currentAmount))
                valueLabel:SizeToContents()

                RefreshTotalLabel()
            end
        end
    end

    -- Master Sell All Button
    masterSellButton = vgui.Create("DButton", frame)
    masterSellButton:Dock(BOTTOM)
    masterSellButton:DockMargin(12, 8, 12, 12)
    masterSellButton:SetTall(40)
    masterSellButton:SetText("")
    masterSellButton.Paint = function(self, w, h)
        local value = CalculateTotalValue()
        local text = "Sell All Materials ($" .. string.Comma(value) .. ")"
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 170, 255, 200))
        draw.SimpleText(text, "DermaDefaultBold", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    masterSellButton.DoClick = function()
        net.Start("DMS_SellAllMaster")
        net.SendToServer()

        frame:Close()
    end

    -- Update count labels on server message
    net.Receive("DMS_UpdateMaterialAmount", function()
        local matName = net.ReadString()
        local newAmount = net.ReadInt(32)

        -- Try immediately first
        if IsValid(materialLabels[matName]) then
            materialLabels[matName]:SetText("Amount: " .. newAmount)
            materialLabels[matName]:SizeToContents()
            RefreshTotalLabel()
            return
        end

        -- If label not valid yet, try again in a short loop
        local attempts = 0
        timer.Create("DMS_LabelWait_" .. matName, 0.1, 20, function()
            if IsValid(materialLabels[matName]) then
                materialLabels[matName]:SetText("Amount: " .. newAmount)
                materialLabels[matName]:SizeToContents()
                RefreshTotalLabel()
                timer.Remove("DMS_LabelWait_" .. matName)
            end

            attempts = attempts + 1
            if attempts >= 20 then
                print("[DMS] Failed to update material label for '" .. matName .. "' (label never valid)")
            end
        end)
    end)
end)
