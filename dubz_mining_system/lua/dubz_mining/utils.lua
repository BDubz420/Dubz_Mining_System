include("autorun/dubz_mining_config.lua")

function DMS.GetRandomFromTable(tbl)
    local total, roll, cumulative = 0, 0, 0
    for _, data in ipairs(tbl) do total = total + (data.chance or 1) end
    roll = math.Rand(0, total)
    for _, data in ipairs(tbl) do
        cumulative = cumulative + (data.chance or 1)
        if roll <= cumulative then return data end
    end
end
