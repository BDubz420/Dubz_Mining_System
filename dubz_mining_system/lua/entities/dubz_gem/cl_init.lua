AddCSLuaFile("autorun/dubz_mining_config.lua")
include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local distance = LocalPlayer():GetPos():Distance(self:GetPos())
    if distance > 512 then return end  -- Only display UI within 512 units

    local pos = self:GetPos() + Vector(0, 0, 10)
    local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

    local gemName = self:GetNWString("GemName", "")
    local gemColor = Color(255, 255, 255)

    -- Find the gem's color based on its name
    for _, gem in ipairs(DMS.Ores.Gems) do
        if gem.name == gemName then
            gemColor = gem.color
            break
        end
    end

    cam.Start3D2D(pos, ang, 0.1)
        -- Display the gem's name
        draw.WordBox(6, 0, 0, gemName, "DermaLarge", Color(0, 0, 0, 150), gemColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Check if the player is close enough and display "Press E to pick up" message
        if distance <= 150 then  -- Display message only if the player is close (within 150 units)
            draw.SimpleText("Press E to pick up", "DermaDefault", 0, 30, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    cam.End3D2D()
end