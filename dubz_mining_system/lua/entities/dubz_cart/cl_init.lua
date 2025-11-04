include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local ang = self:GetAngles()
    local pos = self:GetPos()

    local owner = self:Getowning_ent()
    owner = (IsValid(owner) and owner:Nick()) or DarkRP.getPhrase("unknown")

    local stored = self:GetNWInt("StoredStones", 0)

    local function drawSide(offset, angOffset)
        local angle = Angle(0, ang.y + angOffset, 90)
        local position = pos + self:GetForward() * offset + Vector(0, 0, 20)

        cam.Start3D2D(position, angle, 0.1)
            --draw.RoundedBox(4, -50, -10, 100, 20, Color(0, 0, 0, 150))
            draw.SimpleText("Owner: " .. owner, "DermaLarge", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            --draw.RoundedBox(4, -50, -40, 100, 20, Color(0, 0, 0, 150))
            draw.SimpleText("Stones: " .. stored, "DermaLarge", 0, -30, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end

    drawSide(0, 0)  -- Right side
    drawSide(0, 180) -- Left side
end