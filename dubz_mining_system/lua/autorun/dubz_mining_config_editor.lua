AddCSLuaFile()

DMS = DMS or {}

local SAVE_DIR = "dubz_mining"
local SAVE_FILE = SAVE_DIR .. "/config.json"

local function isColor(value)
    return IsColor and IsColor(value)
end

local function serializeValue(value)
    if isColor(value) then
        return { __type = "Color", r = value.r, g = value.g, b = value.b, a = value.a }
    elseif istable(value) then
        local copy = {}
        for k, v in pairs(value) do
            copy[k] = serializeValue(v)
        end
        return copy
    else
        return value
    end
end

local function deserializeValue(value)
    if istable(value) then
        if value.__type == "Color" then
            return Color(value.r or 255, value.g or 255, value.b or 255, value.a or 255)
        end

        local copy = {}
        for k, v in pairs(value) do
            copy[k] = deserializeValue(v)
        end
        return copy
    else
        return value
    end
end

local function deepCopy(value)
    if istable(value) then
        local copy = {}
        for k, v in pairs(value) do
            copy[k] = deepCopy(v)
        end
        return copy
    elseif isColor(value) then
        return Color(value.r, value.g, value.b, value.a)
    else
        return value
    end
end

local function mergeTables(base, overrides)
    local result = deepCopy(base)
    for k, v in pairs(overrides or {}) do
        if istable(v) and istable(result[k]) then
            result[k] = mergeTables(result[k], v)
        else
            result[k] = deepCopy(v)
        end
    end
    return result
end

if SERVER then
    util.AddNetworkString("DMS_RequestConfigEditor")
    util.AddNetworkString("DMS_SendConfigEditor")
    util.AddNetworkString("DMS_SaveConfigEditor")
    util.AddNetworkString("DMS_ConfigSaved")
    util.AddNetworkString("DMS_BroadcastConfig")

    local function loadSavedConfig()
        if not file.Exists(SAVE_FILE, "DATA") then return end

        local json = file.Read(SAVE_FILE, "DATA")
        local saved = util.JSONToTable(json or "")
        if not istable(saved) then return end

        local deserialized = deserializeValue(saved)
        DMS = mergeTables(DMS, deserialized)
        print("[DMS] Loaded saved config overrides from data folder.")
    end

    hook.Add("Initialize", "DMS_LoadSavedConfigOverrides", function()
        if file.Exists(SAVE_FILE, "DATA") then
            loadSavedConfig()
        end
    end)

    local function ensureSaveDirectory()
        if not file.IsDir(SAVE_DIR, "DATA") then
            file.CreateDir(SAVE_DIR)
        end
    end

    local function broadcastConfig()
        local serialized = serializeValue(DMS)
        net.Start("DMS_BroadcastConfig")
        net.WriteTable(serialized)
        net.Broadcast()
    end

    net.Receive("DMS_RequestConfigEditor", function(_, ply)
        if not IsValid(ply) or not ply:IsAdmin() then return end

        local serialized = serializeValue(DMS)
        net.Start("DMS_SendConfigEditor")
        net.WriteTable(serialized)
        net.Send(ply)
    end)

    net.Receive("DMS_SaveConfigEditor", function(_, ply)
        if not IsValid(ply) or not ply:IsAdmin() then return end

        local incoming = net.ReadTable()
        if not istable(incoming) then return end

        local newConfig = deserializeValue(incoming)
        DMS = mergeTables({}, newConfig)

        ensureSaveDirectory()
        file.Write(SAVE_FILE, util.TableToJSON(serializeValue(DMS), true))

        net.Start("DMS_ConfigSaved")
        net.WriteBool(true)
        net.Send(ply)

        broadcastConfig()
        hook.Run("DMSConfigUpdated", DMS, ply)
        print("[DMS] Configuration updated and saved by " .. ply:Nick())
    end)
else
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
        for key, value in pairs(data) do
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

                if isColor(value) then
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
                    jsonEntry:SetText(util.TableToJSON(serializeValue(value), true))

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
                        local newValue = deserializeValue(parsed)
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
            net.WriteTable(serializeValue(configData))
            net.SendToServer()
        end
    end

    net.Receive("DMS_SendConfigEditor", function()
        local data = net.ReadTable()
        if not istable(data) then return end
        local config = deserializeValue(data)
        openConfigMenu(config)
    end)

    net.Receive("DMS_ConfigSaved", function()
        notification.AddLegacy("Dubz Mining System config saved.", NOTIFY_GENERIC, 4)
        surface.PlaySound("buttons/button3.wav")
    end)

    net.Receive("DMS_BroadcastConfig", function()
        local data = net.ReadTable()
        if not istable(data) then return end
        DMS = deserializeValue(data)
        hook.Run("DMSConfigUpdated", DMS)
    end)

    concommand.Add("dms_config_menu", function()
        net.Start("DMS_RequestConfigEditor")
        net.SendToServer()
    end)
end
