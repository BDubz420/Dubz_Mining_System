function DMS.GetRandomFromTable(tbl)
    local total, roll, cumulative = 0, 0, 0
    for _, data in ipairs(tbl) do total = total + (data.chance or 1) end
    roll = math.Rand(0, total)
    for _, data in ipairs(tbl) do
        cumulative = cumulative + (data.chance or 1)
        if roll <= cumulative then return data end
    end
end

-- ============================
--  DMS CONFIG SERIALIZATION
-- ============================

-- Acceptable network types
local allowedTypes = {
    ["number"] = true,
    ["string"] = true,
    ["boolean"] = true,
}

local function DMS_Serialize(value)
    local t = type(value)

    if t == "Color" or (istable(value) and value.r and value.g and value.b) then
        return {
            __type = "Color",
            r = value.r, g = value.g, b = value.b, a = value.a or 255
        }
    end

    if t == "table" then
        local out = {}
        for k, v in pairs(value) do
            local vt = type(v)

            -- SKIP BAD TYPES
            if vt ~= "function" and vt ~= "userdata" then
                out[k] = DMS_Serialize(v)
            end
        end
        return out
    end

    if t == "function" or t == "userdata" then
        return nil
    end

    return value
end

function DMS_DeserializeValue(val)
    if istable(val) then
        if val.__color then
            return Color(val.r, val.g, val.b, val.a)
        elseif val.__vector then
            return Vector(val.x, val.y, val.z)
        end

        local out = {}
        for k, v in pairs(val) do
            out[k] = DMS_DeserializeValue(v)
        end
        return out
    end
    return val
end


function DMS_MergeTables(base, override)
    for k, v in pairs(override) do
        if istable(v) and istable(base[k]) then
            base[k] = DMS_MergeTables(base[k], v)
        else
            base[k] = v
        end
    end
    return base
end

