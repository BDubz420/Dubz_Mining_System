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
    frame:SetSize(500, 400)
    frame:SetTitle("Gem & Ore Buyer")
    frame:Center()
    frame:MakePopup()

    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 150))        
    end

    local menuw, menuh = frame:GetWide(), frame:GetTall()

    local shopPanel = vgui.Create("DPanel", frame)
    shopPanel:SetPos(5, 30)
    shopPanel:SetSize(menuw -10, menuh -80)
    shopPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 150))
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

    for _, material in pairs(materials) do
        local materialName = material.name
        local materialColor = material.color
        local materialPrice = material.price

        local materialPanel = vgui.Create("DPanel", scrollPanel)
        materialPanel:SetTall(50)
        materialPanel:Dock(TOP)
        materialPanel:DockMargin(0, 0, 0, 6)
        materialPanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(0, 0, 0, 150))
        end

        local nameLabel = vgui.Create("DLabel", materialPanel)
        nameLabel:SetPos(10, 5)
        nameLabel:SetText(materialName)
        nameLabel:SetTextColor(materialColor)
        nameLabel:SizeToContents()

        local priceLabel = vgui.Create("DLabel", materialPanel)
        priceLabel:SetPos(150, 5)
        priceLabel:SetText("Price: $" .. materialPrice)
        priceLabel:SetTextColor(Color(255, 255, 255))
        priceLabel:SizeToContents()

        local countLabel = vgui.Create("DLabel", materialPanel)
        countLabel:SetPos(250, 5)
        countLabel:SetText("You have: " .. LocalPlayer():GetNWInt("DMS_" .. materialName .. "_amount", 0))
        countLabel:SetTextColor(Color(255, 255, 255))
        countLabel:SizeToContents()

        materialLabels[materialName] = countLabel

        local sellButton = vgui.Create("DButton", materialPanel)
        sellButton:SetPos(370, 5)
        sellButton:SetSize(100, 18)
        sellButton:SetText("Sell 1")
        sellButton:SetTextColor(Color(255, 255, 255))
        sellButton.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(40, 120, 200, 150))
        end
        sellButton.DoClick = function()
            net.Start("DMS_SellMaterial")
            net.WriteString(materialName)
            net.SendToServer()
        end

        local sellAllButton = vgui.Create("DButton", materialPanel)
        sellAllButton:SetPos(370, 26)
        sellAllButton:SetSize(100, 18)
        sellAllButton:SetText("Sell All")
        sellAllButton:SetTextColor(Color(255, 255, 255))
        sellAllButton.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(40, 120, 200, 150))
        end
        sellAllButton.DoClick = function()
            net.Start("DMS_SellAllMaterials")
            net.WriteString(materialName)
            net.SendToServer()
        end
    end

    -- Master Sell All Button
    masterSellButton = vgui.Create("DButton", frame)
    masterSellButton:SetSize(menuw - 20, 35)
    masterSellButton:SetPos(10, menuh - 40)
    masterSellButton:SetText("")
    masterSellButton.Paint = function(self, w, h)
        local value = CalculateTotalValue()
        local text = "Sell All Materials ($" .. value .. ")"
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 120, 200, 150))
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
            return
        end

        -- If label not valid yet, try again in a short loop
        local attempts = 0
        timer.Create("DMS_LabelWait_" .. matName, 0.1, 20, function()
            if IsValid(materialLabels[matName]) then
                materialLabels[matName]:SetText("Amount: " .. newAmount)
                timer.Remove("DMS_LabelWait_" .. matName)
            end

            attempts = attempts + 1
            if attempts >= 20 then
                print("[DMS] Failed to update material label for '" .. matName .. "' (label never valid)")
            end
        end)
    end)
end)
