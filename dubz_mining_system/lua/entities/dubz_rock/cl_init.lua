include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local pos = self:GetPos()
    local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90) -- Face the player

    local health = self:GetNWInt("health", DMS.RockHealth)
    local maxHealth = DMS.RockHealth
    local healthPercent = math.Clamp((health / maxHealth) * 100, 0, 100)
    local text = "Rock Health: " .. math.Round(healthPercent) .. "%"
    local barColor = Color(255, 50, 50)
    local bgColor = Color(0, 0, 0, 180)

    local ypos = -200

    -- Show only if the player is nearby
    if LocalPlayer():GetPos():Distance(pos) < self:GetNWInt("distance", 500) then
        cam.Start3D2D(pos + Vector(0, 0, 55), ang, 0.1) -- Raised to 55 units above
            draw.RoundedBox(8, -130, -5 -ypos, 260, 50, bgColor)
            draw.SimpleTextOutlined(text, "HUDNumber5", 0, -5 -ypos, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)

            draw.RoundedBox(4, -100, 25 -ypos, 200, 10, Color(40, 40, 40))
            draw.RoundedBox(4, -100, 25 -ypos, 2 * healthPercent, 10, barColor)
        cam.End3D2D()
    end
end
