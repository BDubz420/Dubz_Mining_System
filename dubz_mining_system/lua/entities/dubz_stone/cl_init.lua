AddCSLuaFile("autorun/dubz_mining_config.lua")
include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local distance = LocalPlayer():GetPos():Distance(self:GetPos())
    if distance > 512 then return end  -- Only display UI within 512 units

    local pos = self:GetPos() + Vector(0, 0, 10)
    local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

    cam.Start3D2D(pos, ang, 0.1)
        -- Display the gem's name
        draw.WordBox(6, 0, 0, "Stone", "HUDNumber5", Color(0, 0, 0, 150), Color(140, 140, 140), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end