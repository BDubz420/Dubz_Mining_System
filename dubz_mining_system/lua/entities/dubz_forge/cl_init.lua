include("shared.lua")

local function GetOreColor(oreName)
    -- Check both Gems and Ingots tables for the ore
    for _, ore in ipairs(DMS.Ores.Gems) do
        if ore.name == oreName then
            return ore.color
        end
    end
    for _, ore in ipairs(DMS.Ores.Ingots) do
        if ore.name == oreName then
            return ore.color
        end
    end
    return Color(255, 0, 0)  -- Default color if ore is not found
end

function ENT:Draw()
    self:DrawModel()

    local ply = LocalPlayer()
    local distance = ply:GetPos():Distance(self:GetPos())
    if distance > 300 then return end

    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 90)

    local pos = self:GetPos() + Vector(0, 0, 50)

    cam.Start3D2D(pos, ang, 0.1)
        -- Background for status text
        draw.RoundedBox(8, -100, -30, 200, 30, Color(20, 20, 20, 200))

        -- Get the machine's processing status and ore
        local isProcessing = self:GetNWBool("Processing", false)
        local currentOre = self:GetNWString("CurrentIngot", "No Ore")
        local statusText = "Forge"  -- Default status is Forge

        -- Add buffer phase before dispensing the ingot
        local bufferPhase = self:GetNWBool("Buffering", false)
        local bufferTime = self:GetNWFloat("BufferEndTime", 0)
        
        -- If in buffer phase, show "Buffering..."
        if bufferPhase then
            statusText = "Dispensing..."
            if CurTime() > bufferTime then
                self:SetNWBool("Buffering", false)  -- End buffering phase
                self:SetNWBool("Processing", true)  -- Start actual forging
            end
        elseif isProcessing then
            -- If the machine is processing, update the status to Forging
            if currentOre ~= "No Ore" then
                statusText = "Forging..."
            else
                statusText = "Forge"  -- No ore, revert to Forge
            end
        end

        local statusColor = bufferPhase and Color(255, 255, 0) or (isProcessing and Color(0, 255, 100) or Color(255, 255, 255))

        draw.SimpleText(statusText, "HUDNumber5", 0, -15, statusColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Background for time text
        draw.RoundedBox(8, -125, 10, 250, 30, Color(20, 20, 20, 200))

        -- Display remaining time for forging
        local remainingTime = self:GetNWInt("ForgeTime", 0)
        if isProcessing then
            local forgeEndTime = self:GetNWFloat("ForgeEndTime", 0)
            remainingTime = math.max(forgeEndTime - CurTime(), 0)
        end
        draw.SimpleText("Time Left: " .. math.Round(remainingTime) .. "s", "HUDNumber5", 0, 25, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Background for power status text
        draw.RoundedBox(8, -125, 50, 250, 30, Color(20, 20, 20, 200))

        -- Power status display
        local powerStatus = self:GetNWBool("PoweredOn", true) and "Power On" or "Power Off"
        local powerColor = self:GetNWBool("PoweredOn", true) and Color(0, 255, 0) or Color(255, 0, 0)

        draw.SimpleText(powerStatus, "HUDNumber5", 0, 65, powerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)


        -- Display the ore being processed, or show "No Ore"
        if self:GetNWBool("PoweredOn", true) then
            -- If the machine is powered on and processing, show ore or "No Ore"
            -- Background for ore processing text
            if currentOre == "Titanium" then

                draw.RoundedBox(8, -125, 90, 250, 30, Color(20, 20, 20, 200))
            else
                draw.RoundedBox(8, -125, 90, 250, 30, Color(20, 20, 20, 200))
            end

            if isProcessing then
                if currentOre ~= "No Ore" then
                    local oreColor = GetOreColor(currentOre)  -- Get the color for the current ore
                    draw.SimpleText("Processing: " .. currentOre, "HUDNumber5", 0, 105, oreColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                else
                    draw.SimpleText("Insert stone.", "HUDNumber5", 0, 105, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            else
                draw.SimpleText("Status: Idle", "HUDNumber5", 0, 105, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    cam.End3D2D()
end