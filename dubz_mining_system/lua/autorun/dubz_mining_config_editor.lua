AddCSLuaFile()

DMS = DMS or {}

local SAVE_DIR  = "dubz_mining"
local SAVE_FILE = SAVE_DIR .. "/config.json"

-- =========================
--  SHARED HELPER FUNCTIONS
-- =========================

-- expose helpers globally so dubz_mining_init.lua can reuse them
function DMS_IsColor(v)
    return IsColor and IsColor(v)
end

-- Safe deep copy (colors + tables)
function DMS_DeepCopy(v)
    if istable(v) then
        local t = {}
        for k, val in pairs(v) do
            t[k] = DMS_DeepCopy(val)
        end
        return t
    elseif DMS_IsColor(v) then
        return Color(v.r, v.g, v.b, v.a)
    else
        return v
    end
end

-- Only allow primitive / table / Color values to pass through
-- Functions / userdata / entities etc are stripped so net.WriteTable never sees them.
function DMS_SerializeValue(v)
    local t = type(v)

    if DMS_IsColor(v) then
        return { __type = "Color", r = v.r, g = v.g, b = v.b, a = v.a }
    elseif t == "number" or t == "string" or t == "boolean" or v == nil then
        return v
    elseif t == "table" then
        local out = {}
        for k, val in pairs(v) do
            -- skip non-serializable keys
            local kt = type(k)
            if kt == "string" or kt == "number" then
                local sv = DMS_SerializeValue(val)
                if sv ~= nil then
                    out[k] = sv
                end
            end
        end
        return out
    else
        -- function / userdata / thread etc → ignore
        return nil
    end
end

function DMS_DeserializeValue(v)
    if not istable(v) then return v end

    if v.__type == "Color" then
        return Color(v.r or 255, v.g or 255, v.b or 255, v.a or 255)
    end

    local out = {}
    for k, val in pairs(v) do
        out[k] = DMS_DeserializeValue(val)
    end
    return out
end

-- Deep merge: values from 'overrides' win over 'base'
function DMS_MergeTables(base, overrides)
    local result = DMS_DeepCopy(base or {})
    for k, v in pairs(overrides or {}) do
        if istable(v) and istable(result[k]) then
            result[k] = DMS_MergeTables(result[k], v)
        else
            result[k] = DMS_DeepCopy(v)
        end
    end
    return result
end

-- =========================
--  SERVER SIDE
-- =========================
if SERVER then
    util.AddNetworkString("DMS_RequestConfigEditor")
    util.AddNetworkString("DMS_SendConfigEditor")
    util.AddNetworkString("DMS_SaveConfigEditor")
    util.AddNetworkString("DMS_ConfigSaved")
    util.AddNetworkString("DMS_BroadcastConfig")

    local function ensureSaveDirectory()
        if not file.IsDir(SAVE_DIR, "DATA") then
            file.CreateDir(SAVE_DIR)
        end
    end

    -- Load saved overrides from data/ at startup (dubz_mining_init.lua
    -- will also call this, but it's safe if it runs twice).
    local function loadSavedConfig()
        if not file.Exists(SAVE_FILE, "DATA") then return end

        local json = file.Read(SAVE_FILE, "DATA")
        local saved = util.JSONToTable(json or "")
        if not istable(saved) then return end

        local deserialized = DMS_DeserializeValue(saved)
        DMS = DMS_MergeTables(DMS, deserialized)
        DMS.__ConfigEditorOverridesLoaded = true
    end

    -- Make sure we load overrides when Lua refreshes
    hook.Add("Initialize", "DMS_ConfigEditor_LoadSaved", function()
        loadSavedConfig()
    end)

    -- Send full config to one player (on menu open or join)
    local function sendFullConfig(ply)
        local serialized = DMS_SerializeValue(DMS)
        net.Start("DMS_SendConfigEditor")
        net.WriteTable(serialized)
        net.Send(ply)
    end

    -- When an admin opens the editor
    net.Receive("DMS_RequestConfigEditor", function(_, ply)
        if not IsValid(ply) or not ply:IsAdmin() then return end
        sendFullConfig(ply)
    end)

    -- Save from editor
    net.Receive("DMS_SaveConfigEditor", function(_, ply)
        if not IsValid(ply) or not ply:IsAdmin() then return end

        local incoming = net.ReadTable()
        if not istable(incoming) then return end

        local SAVE_DIR  = "dubz_mining"
        local SAVE_FILE = SAVE_DIR .. "/config.json"

        local function ensureSaveDirectory()
            if not file.IsDir(SAVE_DIR, "DATA") then
                file.CreateDir(SAVE_DIR)
            end
        end

        ---------------------------------------------------------
        --  RESET TO DEFAULTS
        ---------------------------------------------------------
        if table.IsEmpty(incoming) then
            print("[DMS] Resetting config to DEFAULTS...")

            -- delete override file
            ensureSaveDirectory()
            file.Write(SAVE_FILE, "{}")

            -- reload default config fresh
            DMS = {}                                      -- wipe existing
            include("autorun/dubz_mining_config.lua")    -- load default DMS values

            print("[DMS] Defaults reloaded. Broadcasting to clients...")

            -- broadcast defaults to all clients
            local serialized = DMS_SerializeValue(DMS)
            net.Start("DMS_BroadcastConfig")
            net.WriteTable(serialized)
            net.Broadcast()

            -- notify admin user
            net.Start("DMS_ConfigSaved")
            net.WriteBool(true)
            net.Send(ply)

            -- run update hook for live entity refresh
            hook.Run("DMSConfigUpdated", DMS, ply)

            print("[DMS] Config reset to defaults LIVE!")
            return
        end

        ---------------------------------------------------------
        --  SAVE USER CHANGES (non-reset)
        ---------------------------------------------------------
        local newConfig = DMS_DeserializeValue(incoming)

        -- overwrite DMS with the new config
        DMS = DMS_MergeTables({}, newConfig)

        ensureSaveDirectory()
        file.Write(SAVE_FILE, util.TableToJSON(DMS_SerializeValue(DMS), true))

        print("[DMS] Config saved by " .. ply:Nick() .. ". Broadcasting to clients...")

        -- broadcast updated config to ALL clients
        local serialized = DMS_SerializeValue(DMS)
        net.Start("DMS_BroadcastConfig")
        net.WriteTable(serialized)
        net.Broadcast()

        -- notify admin user
        net.Start("DMS_ConfigSaved")
        net.WriteBool(true)
        net.Send(ply)

        -- run hook so ents + sweps can refresh immediately
        hook.Run("DMSConfigUpdated", DMS, ply)
    end)

    -- Also send current config to players when they join so client-side
    -- 3D2D labels / UIs use the overridden values immediately.
    hook.Add("PlayerInitialSpawn", "DMS_SendConfigOnJoin", function(ply)
        local serialized = DMS_SerializeValue(DMS)
        net.Start("DMS_BroadcastConfig")
        net.WriteTable(serialized)
        net.Send(ply)
    end)

else
-- =========================
--  CLIENT SIDE
-- =========================
    local function setValueAtPath(tbl, path, value)
        local current = tbl
        for i = 1, #path - 1 do
            local key = path[i]
            current[key] = current[key] or {}
            current = current[key]
        end
        current[path[#path]] = value
    end

    local function pathToLabel(path)
        return table.concat(path, " → ")
    end

    local function isStringArray(tbl)
        if not istable(tbl) then return false end
        for _, v in pairs(tbl) do
            if not isstring(v) then return false end
        end
        return true
    end

    local function rebuildTree(tree, root, data, onSelect, path)
        path = path or {}

        -- Sort keys alphabetically
        local keys = {}
        for k in pairs(data) do table.insert(keys, k) end
        table.sort(keys, function(a, b) return tostring(a):lower() < tostring(b):lower() end)

        for _, key in ipairs(keys) do
            local value = data[key]

            local node = root:AddNode(tostring(key))
            local currentPath = table.Copy(path)
            table.insert(currentPath, key)

            node.DoClick = function()
                onSelect(currentPath, value)
            end

            if istable(value) then
                rebuildTree(tree, node, value, onSelect, currentPath)
            end
        end
    end

    local function openConfigMenu(configData)
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Dubz Mining System Config")
        frame:SetSize(1100, 750)
        frame:Center()
        frame:MakePopup()

        local tree = vgui.Create("DTree", frame)
        tree:SetPos(10, 35)
        tree:SetSize(280, 705)

        local content = vgui.Create("DScrollPanel", frame)
        content:SetPos(300, 35)
        content:SetSize(790, 665)

        local saveButton = vgui.Create("DButton", frame)
        saveButton:SetText("Save Config")
        saveButton:SetPos(300, 705)
        saveButton:SetSize(790, 35)

        ---------------------------------------------------------
        -- RESET TO DEFAULTS BUTTON
        ---------------------------------------------------------
        local resetButton = vgui.Create("DButton", frame)
        resetButton:SetText("")
        resetButton:SetPos(20, 700)
        resetButton:SetSize(260, 35)
        resetButton:SetTextColor(Color(255, 120, 120))

        resetButton.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(180, 40, 40, 180) or Color(140, 30, 30, 180)
            draw.RoundedBox(6, 0, 0, w, h, col)
            draw.SimpleText("Reset To Default", "Trebuchet24", w/2, h/2, Color(255, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        resetButton.DoClick = function()
            Derma_Query(
                "This will wipe all saved overrides.\nYour server will use the original config next restart.\n\nAre you sure?",
                "Reset All Values",
                "Yes", function()
                    net.Start("DMS_SaveConfigEditor")
                        -- Sending EMPTY TABLE tells server to restore defaults
                        net.WriteTable({})
                    net.SendToServer()

                    surface.PlaySound("buttons/button11.wav")
                    notification.AddLegacy("Config reset!", NOTIFY_GENERIC, 5)
                end,
                "Cancel"
            )
        end

        local pathLabel = vgui.Create("DLabel", content)
        pathLabel:SetText("Select a value to edit")
        pathLabel:SetFont("Trebuchet24")
        pathLabel:Dock(TOP)
        pathLabel:DockMargin(0, 0, 0, 8)

        local function rebuild()
            tree:Clear()
            rebuildTree(tree, tree, configData, function(path, value)
                content:Clear()

                pathLabel = vgui.Create("DLabel", content)
                pathLabel:SetText(pathToLabel(path))
                pathLabel:SetFont("Trebuchet24")
                pathLabel:Dock(TOP)
                pathLabel:DockMargin(0, 0, 0, 8)

                local valuePanel = vgui.Create("DPanel", content)
                valuePanel:Dock(TOP)
                valuePanel:DockMargin(0, 0, 0, 8)
                valuePanel:SetTall(640)
                valuePanel.Paint = function(self, w, h)
                    surface.SetDrawColor(40, 40, 40, 200)
                    surface.DrawRect(0, 0, w, h)
                end

                local inner = vgui.Create("DScrollPanel", valuePanel)
                inner:Dock(FILL)
                inner:DockMargin(8, 8, 8, 8)

                local function addLabel(text)
                    local lbl = inner:Add("DLabel")
                    lbl:SetText(text)
                    lbl:SetFont("Trebuchet18")
                    lbl:Dock(TOP)
                    lbl:DockMargin(0, 0, 0, 6)
                end

                if DMS_IsColor(value) then
                    addLabel("Color value")
                    local mixer = inner:Add("DColorMixer")
                    mixer:Dock(TOP)
                    mixer:SetTall(250)
                    mixer:SetPalette(true)
                    mixer:SetAlphaBar(true)
                    mixer:SetColor(value)
                    mixer.ValueChanged = function(_, col)
                        setValueAtPath(configData, path, col)
                    end
                elseif isbool(value) then
                    addLabel("Boolean value")
                    local checkbox = inner:Add("DCheckBoxLabel")
                    checkbox:SetText("Enabled")
                    checkbox:SetValue(value and 1 or 0)
                    checkbox:Dock(TOP)
                    checkbox:DockMargin(0, 0, 0, 6)
                    function checkbox:OnChange(val)
                        setValueAtPath(configData, path, val)
                    end
                elseif isnumber(value) then
                    addLabel("Number value")
                    local wang = inner:Add("DNumberWang")
                    wang:Dock(TOP)
                    wang:SetValue(value)
                    function wang:OnValueChanged(val)
                        local num = tonumber(val) or value
                        setValueAtPath(configData, path, num)
                    end
                elseif isstring(value) then
                    addLabel("String value")
                    local entry = inner:Add("DTextEntry")
                    entry:Dock(TOP)
                    entry:SetUpdateOnType(true)
                    entry:SetText(value)
                    function entry:OnValueChange(new)
                        setValueAtPath(configData, path, new)
                    end
                elseif isStringArray(value) then
                    addLabel("List (add/remove rows to change counts like models or sounds)")
                    local list = inner:Add("DListView")
                    list:Dock(TOP)
                    list:SetTall(320)
                    list:AddColumn("Value")
                    for _, v in ipairs(value) do
                        list:AddLine(v)
                    end

                    local controls = inner:Add("DPanel")
                    controls:Dock(TOP)
                    controls:SetTall(30)
                    controls:DockMargin(0, 6, 0, 0)
                    controls.Paint = function() end

                    local addEntry = vgui.Create("DTextEntry", controls)
                    addEntry:SetPlaceholderText("Add new value")
                    addEntry:Dock(LEFT)
                    addEntry:SetWide(500)

                    local addBtn = vgui.Create("DButton", controls)
                    addBtn:SetText("Add")
                    addBtn:Dock(LEFT)
                    addBtn:SetWide(80)
                    addBtn.DoClick = function()
                        local newVal = addEntry:GetText()
                        if newVal == "" then return end
                        table.insert(value, newVal)
                        setValueAtPath(configData, path, value)
                        list:AddLine(newVal)
                        addEntry:SetText("")
                    end

                    local removeBtn = vgui.Create("DButton", controls)
                    removeBtn:SetText("Remove Selected")
                    removeBtn:Dock(LEFT)
                    removeBtn:SetWide(140)
                    removeBtn.DoClick = function()
                        local selected = list:GetSelectedLine()
                        if not selected then return end
                        table.remove(value, selected)
                        setValueAtPath(configData, path, value)
                        list:RemoveLine(selected)
                    end
                elseif istable(value) then
                    addLabel("Table value (edit JSON to add/remove entries)")
                    local jsonEntry = inner:Add("DTextEntry")
                    jsonEntry:Dock(TOP)
                    jsonEntry:SetTall(520)
                    jsonEntry:SetMultiline(true)
                    jsonEntry:SetUpdateOnType(false)
                    jsonEntry:SetText(util.TableToJSON(DMS_SerializeValue(value), true))

                    local applyBtn = inner:Add("DButton")
                    applyBtn:Dock(TOP)
                    applyBtn:SetText("Apply JSON")
                    applyBtn:DockMargin(0, 6, 0, 0)
                    applyBtn.DoClick = function()
                        local parsed = util.JSONToTable(jsonEntry:GetText() or "")
                        if not istable(parsed) then
                            notification.AddLegacy("Invalid JSON for this value", NOTIFY_ERROR, 4)
                            return
                        end
                        local newValue = DMS_DeserializeValue(parsed)
                        setValueAtPath(configData, path, newValue)
                        rebuild()
                        notification.AddLegacy("Updated value", NOTIFY_GENERIC, 3)
                    end
                end
            end, {})
        end

        rebuild()

        saveButton.DoClick = function()
            net.Start("DMS_SaveConfigEditor")
            net.WriteTable(DMS_SerializeValue(configData))
            net.SendToServer()
        end
    end

    -- Receive full config when opening the editor
    net.Receive("DMS_SendConfigEditor", function()
        local data = net.ReadTable()
        if not istable(data) then return end
        local config = DMS_DeserializeValue(data)
        openConfigMenu(config)
    end)

    -- Toast when config saved
    net.Receive("DMS_ConfigSaved", function()
        notification.AddLegacy("Dubz Mining System config saved.", NOTIFY_GENERIC, 4)
        surface.PlaySound("buttons/button3.wav")
    end)

    -- Live config broadcast (also on join)
    net.Receive("DMS_BroadcastConfig", function()
        local data = net.ReadTable()
        if not istable(data) then return end
        local overrides = DMS_DeserializeValue(data)
        DMS = DMS_MergeTables(DMS, overrides)
        hook.Run("DMSConfigUpdated", DMS)
    end)

    -- Console command to open editor
    concommand.Add("dms_config_menu", function()
        net.Start("DMS_RequestConfigEditor")
        net.SendToServer()
    end)
end
