-- Stone Client-Side: stone_cl_init.lua

include("shared.lua")

-- Function to draw the stone entity
function ENT:Draw()
    self:DrawModel()  -- Draw the stone model

    -- Get position and angle for rendering the 3D2D text
    local pos = self:GetPos()
    local ang = self:GetAngles()

    -- Rotate to ensure the text aligns correctly
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 0)

    -- Check the distance from the player to decide if we should render the UI
    if LocalPlayer():GetPos():Distance(pos) < 300 then
        cam.Start3D2D(pos + ang:Up() * 10, Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.1)
            -- Get the stored ore data
            local oreName = self:GetNWString("OreName", "Unknown")
            local orePrice = self:GetNWInt("OrePrice", 0)
            local oreColorVec = self:GetNWVector("OreColor", Vector(255, 255, 255))
            local oreColor = Color(oreColorVec.x, oreColorVec.y, oreColorVec.z)

            -- Draw ore name and price on the stone in 3D space
            --draw.WordBox(6, -100, -50, "Ore Name: " .. oreName, "DermaDefaultBold", Color(0, 0, 0, 200), oreColor)
            --draw.WordBox(6, -100, 0, "Price: $" .. orePrice, "DermaDefaultBold", Color(0, 0, 0, 200), color_white)
        cam.End3D2D()
    end
end
