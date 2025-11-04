AddCSLuaFile()
include("autorun/dubz_mining_config.lua")

if CLIENT then
    -- Function to calculate XP required for the next level based on the config
    local function GetXPRequiredForLevel(level)
        if DMS.Levels.XPTable and DMS.Levels.XPTable[level] then
            return DMS.Levels.XPTable[level]
        else
            return DMS.Levels.BaseXP * (level - 1) ^ DMS.Levels.XPMultiplier
        end
    end

    -- Function to draw the XP bar and information
    local function DrawXPBar()
        local scrW, scrH = ScrW(), ScrH()
        local ply = LocalPlayer()

        -- Check if the player is holding the pickaxe
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_dubz_pickaxe_temp" then
            -- Use NWInt to get player XP and level
            local playerXP = ply:GetNWInt("DubzXP", 0)
            local playerLevel = ply:GetNWInt("DubzLevel", 1)
            local xpForNextLevel = GetXPRequiredForLevel(playerLevel + 1)

            local xpProgress = math.Clamp(playerXP / xpForNextLevel, 0, 1)


            local w, h = ScrW(), ScrH()
            local boxWidth = 420
            local boxHeight = 180
            local x = w / 2 - boxWidth / 2
            local y = h - boxHeight - 10

            -- Center the XP bar and level text horizontally
            local xpBarX = scrW * 0.5 - 200  -- Center the bar (half of bar width = 200)
            local xpBarY = y -10  -- Move it above the item HUD
            local barWidth = 400
            local barHeight = 10  -- Thin bar as requested

            -- Background for the XP bar
            surface.SetDrawColor(50, 50, 50, 200)
            surface.DrawRect(xpBarX, xpBarY, barWidth, barHeight)

            -- Foreground for the XP bar (progress)
            surface.SetDrawColor(0, 255, 0, 255)
            surface.DrawRect(xpBarX, xpBarY, barWidth * xpProgress, barHeight)

            -- Level text
            draw.SimpleTextOutlined("Level: " .. playerLevel, "Trebuchet24", scrW * 0.5, xpBarY - 25, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 255))

            -- XP progress text (XP / Next level XP)
            draw.SimpleTextOutlined(playerXP .. " / " .. xpForNextLevel .. " XP", "DermaDefaultBold", scrW * 0.5, xpBarY -2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 255 ))
        end
    end

    -- Client-side HUD paint hook
    hook.Add("HUDPaint", "DMS_CombinedHUD", function()
        local ply = LocalPlayer()
        local allowedJob = DMS and DMS.MiningJob or TEAM_MINER
        if not IsValid(ply) or not ply:Alive() then return end
        if not DMS or not DMS.Levels then return end

        local wep = ply:GetActiveWeapon()
        if not (IsValid(wep) and wep:GetClass() == "weapon_dubz_pickaxe_temp") then return end

        local w, h = ScrW(), ScrH()
        local boxWidth = 420
        local boxHeight = 180
        local x = w / 2 - boxWidth / 2
        local y = h - boxHeight - 10

        draw.RoundedBox(8, x, y, boxWidth, boxHeight, Color(0, 0, 0, 150))

        -- Gems section
        local totalGemWorth, hasGems = 0, false
        for _, gem in ipairs(DMS.Ores.Gems or {}) do
            local amt = ply:GetNWInt("DMS_" .. gem.name .. "_amount", 0)
            local value = amt * (gem.price or 0)
            totalGemWorth = totalGemWorth + value
            if amt > 0 then hasGems = true end
        end

        -- Ingots section
        local totalIngotWorth, hasIngots = 0, false
        for _, ingot in ipairs(DMS.Ores.Ingots or {}) do
            local amt = ply:GetNWInt("DMS_" .. ingot.name .. "_amount", 0)
            local value = amt * (ingot.price or 0)
            totalIngotWorth = totalIngotWorth + value
            if amt > 0 then hasIngots = true end
        end

        -- Display Gems and Ingots worth
        draw.SimpleText(hasGems and ("Gems: " .. DarkRP.formatMoney(totalGemWorth)) or "Gems", "DermaLarge", x + 10, y + 10, Color(255, 255, 255))
        draw.SimpleText(hasIngots and ("Ingots: " .. DarkRP.formatMoney(totalIngotWorth)) or "Ingots", "DermaLarge", x + 10, y + 95, Color(255, 255, 255))

        -- Display each gem's amount
        for i, gem in ipairs(DMS.Ores.Gems or {}) do
            local amt = ply:GetNWInt("DMS_" .. gem.name .. "_amount", 0)
            local row = (i <= 3) and 0 or 1
            local col = (i - 1) % 3
            local gx = x + 20 + col * 130
            local gy = y + 40 + row * 20
            draw.SimpleText(gem.name .. ": " .. amt, "DermaDefaultBold", gx, gy, gem.color or color_white)
        end

        -- Display each ingot's amount
        for i, ingot in ipairs(DMS.Ores.Ingots or {}) do
            local amt = ply:GetNWInt("DMS_" .. ingot.name .. "_amount", 0)
            local row = (i <= 3) and 0 or 1
            local col = (i - 1) % 3
            local ix = x + 20 + col * 130
            local iy = y + 125 + row * 20
            draw.SimpleText(ingot.name .. ": " .. amt, "DermaDefaultBold", ix, iy, ingot.color or color_white)
        end

        local pickaxeLevel = math.Clamp(ply:GetNWInt("DubzLevel", 1), 1, 50)
        
        -- Find the pickaxe tier based on the level
        local pickaxeTier = nil
        for _, tier in ipairs(DMS.PickaxeTiers) do
            if pickaxeLevel >= tier.level then
                pickaxeTier = tier
            end
        end
        
        if pickaxeTier then
            -- Draw the tier info
            local color = pickaxeTier.color or Color(255, 255, 255) -- Default to white if no color set
            local tierText = pickaxeTier.name .. " Tier (" .. pickaxeTier.level .. ")"

            -- Set the font and color
            surface.SetFont("Trebuchet24")
            surface.SetTextColor(color)

            -- Draw the tier name on the screen
            local w, h = surface.GetTextSize(tierText)
            local x, y = ScrW() - w - 10, ScrH() - h - 10  -- Adjust the position as needed

            surface.SetTextPos(x, y)
            surface.DrawText(tierText)
        end

        -- Draw the XP bar above the HUD (centered)
        DrawXPBar()
    end)

    -- 3d2d player hud for above the miner's heads to show level
--[[
    hook.Add("PostPlayerDraw", "DMS_MinerLevel3D2DHUD", function(ply)
        if not IsValid(ply) or not ply:Alive() or ply == LocalPlayer() then return end
        if ply:Team() ~= TEAM_MINER then return end

        local level = ply:GetNWInt("DubzLevel", 1)

        local offset = Vector(0, 0, 85)
        local ang = LocalPlayer():EyeAngles()
        local pos = ply:GetPos() + offset

        ang:RotateAroundAxis(ang:Right(), 90)
        ang:RotateAroundAxis(ang:Up(), 90)

        cam.Start3D2D(pos, Angle(0, ang.y, 90), 0.1)
            draw.RoundedBox(4, -60, -20, 120, 40, Color(0, 0, 0, 160))
            draw.SimpleText("Level: ", "DermaDefault", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end)
    --]]
end
