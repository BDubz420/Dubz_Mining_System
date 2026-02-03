-- =====================================================
-- Dubz Mining System Initialization (SERVER BOOT)
-- Fires ONCE per server session
-- =====================================================

-- Run-once guard (prevents autorun / gamemode reload spam)
if DMS and DMS.__BOOTED then return end
DMS = DMS or {}
DMS.__BOOTED = true

-- =====================================================
-- SERVER ONLY
-- =====================================================
if SERVER then

    -- ======================
    -- SEND SHARED FILES
    -- ======================
    AddCSLuaFile("autorun/dubz_mining_config.lua")
    AddCSLuaFile("dubz_mining/core.lua")
    AddCSLuaFile("dubz_mining/levels.lua")
    AddCSLuaFile("dubz_mining/utils.lua")
    AddCSLuaFile("dubz_mining/pickaxes.lua")

    -- ======================
    -- LOAD CONFIG FIRST
    -- ======================
    include("autorun/dubz_mining_config.lua")

    -- ======================
    -- LOAD CORE SYSTEM FILES
    -- ======================
    include("dubz_mining/core.lua")
    include("dubz_mining/levels.lua")
    include("dubz_mining/utils.lua")
    include("dubz_mining/pickaxes.lua")

    -- ======================
    -- CONFIG SERIALIZATION FALLBACKS
    -- ======================
    DMS_SerializeValue   = DMS_SerializeValue   or function(v) return v end
    DMS_DeserializeValue = DMS_DeserializeValue or function(v) return v end
    DMS_MergeTables      = DMS_MergeTables      or function(base, overrides)
        base      = base      or {}
        overrides = overrides or {}
        local out = table.Copy(base)
        for k, v in pairs(overrides) do
            out[k] = v
        end
        return out
    end

    -- ======================
    -- LOAD SAVED CONFIG OVERRIDES
    -- ======================
    local SAVE_FILE = "dubz_mining/config.json"

    local function LoadSavedConfig()
        if not file.Exists(SAVE_FILE, "DATA") then
            print("[DMS] No saved config overrides found, using defaults.")
            return
        end

        local raw = file.Read(SAVE_FILE, "DATA")
        local tbl = util.JSONToTable(raw or "")

        if not istable(tbl) then
            print("[DMS] Saved config corrupt, ignoring.")
            return
        end

        local overrides = DMS_DeserializeValue(tbl)
        DMS = DMS_MergeTables(DMS, overrides)

    end

    -- Run once after engine init (file.* is ready here)
    hook.Add("Initialize", "DMS_LoadOverridesOnce", function()
        LoadSavedConfig()
    end)

    DMS.__ConfigOverridesLoaded = true
end

if SERVER then
    resource.AddFile("models/dubz_mining/v_pickaxe.mdl")
    resource.AddFile("models/dubz_mining/v_pickaxe.dx80.vtx")
    resource.AddFile("models/dubz_mining/v_pickaxe.dx90.vtx")
    resource.AddFile("models/dubz_mining/v_pickaxe.sw.vtx")
    resource.AddFile("models/dubz_mining/v_pickaxe.vvd")

    resource.AddFile("models/dubz_mining/w_pickaxe.mdl")
    resource.AddFile("models/dubz_mining/w_pickaxe.dx80.vtx")
    resource.AddFile("models/dubz_mining/w_pickaxe.dx90.vtx")
    resource.AddFile("models/dubz_mining/w_pickaxe.sw.vtx")
    resource.AddFile("models/dubz_mining/w_pickaxe.vvd")
    resource.AddFile("models/dubz_mining/w_pickaxe.phy")
end

if SERVER then

    local BOX_INNER_WIDTH = 53

    local function ulen(s)
        s = tostring(s or "")
        return utf8.len(s) or #s -- fallback
    end

    local function usub(s, i, j)
        s = tostring(s or "")
        if utf8.sub then return utf8.sub(s, i, j) end
        return string.sub(s, i, j) -- fallback
    end

    local function TruncToWidth(text, width)
        text = tostring(text or "")
        if ulen(text) <= width then return text end
        return usub(text, 1, width)
    end

    local function PadLine(text)
        text = TruncToWidth(text, BOX_INNER_WIDTH)
        local padding = BOX_INNER_WIDTH - ulen(text)
        return "║  " .. text .. string.rep(" ", padding) .. "  ║"
    end

    local function CenterLine(text)
        text = TruncToWidth(text, BOX_INNER_WIDTH)
        local totalPad = BOX_INNER_WIDTH - ulen(text)
        local leftPad  = math.floor(totalPad / 2)
        local rightPad = totalPad - leftPad

        return "║  "
            .. string.rep(" ", leftPad)
            .. text
            .. string.rep(" ", rightPad)
            .. "  ║"
    end

    hook.Add("Initialize", "DMS_PrintBootBanner_Once", function()

        if _G.__DMS_BOOT_BANNER_PRINTED then return end
        _G.__DMS_BOOT_BANNER_PRINTED = true

        -- Build dynamic status values
        local configStatus = "Defaults loaded"
        if DMS.__ConfigOverridesLoaded or DMS.__ConfigEditorOverridesLoaded then
            configStatus = "Overrides applied"
        end

        print("")
        print("╔" .. string.rep("═", BOX_INNER_WIDTH + 4) .. "╗")
        print(CenterLine("Dubz Mining System — v1.0.0"))
        print(CenterLine("by Lowkey Networks"))
        print("╠" .. string.rep("═", BOX_INNER_WIDTH + 4) .. "╣")
        print(PadLine("Status: Initialized"))
        print(PadLine("Config: " .. configStatus))
        print(PadLine("Mode:   DarkRP"))
        print("╚" .. string.rep("═", BOX_INNER_WIDTH + 4) .. "╝")
        print("")

        hook.Remove("Initialize", "DMS_PrintBootBanner_Once")
    end)
end