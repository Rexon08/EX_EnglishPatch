---@diagnostic disable: undefined-global
-- WowStyle1DropdownTemplate pools its menu button frames between menus.
-- The source's LSM font dropdown attaches a persistent `lsmFontPreview`
-- child frame and dims `fontString`; texture/sound dropdowns repair this
-- on entry, but the generic / multiselect builders don't — so once a
-- font dropdown opened, later generic menus inherited the stale overlay.
--
-- Fix: replace the font dropdown builder with one that adds no persistent
-- child frames to pooled buttons, and add a per-entry CleanButton
-- initializer to the generic and multiselect builders for safety.

local _, ns = ...

local function HideFrame(frame)
    if frame and type(frame.Hide) == "function" then frame:Hide() end
end

local function RestoreAlpha(region)
    if region and type(region.SetAlpha) == "function" then region:SetAlpha(1) end
end

local function CleanButton(button)
    if not button then return end
    HideFrame(button.playBtn)
    if button.lsmFontPreview then
        HideFrame(button.lsmFontPreview)
        if button.lsmFontPreview.fs and type(button.lsmFontPreview.fs.SetText) == "function" then
            button.lsmFontPreview.fs:SetText("")
        end
    end
    RestoreAlpha(button.fontString)
    RestoreAlpha(button.FontString)
    RestoreAlpha(button.Text)
end

local function TranslateText(text)
    if type(text) ~= "string" or text == "" then return text end
    if type(ns.TranslateDisplayText) ~= "function" then return text end
    local translated = ns.TranslateDisplayText(text)
    return (type(translated) == "string" and translated ~= "") and translated or text
end

local function HookDropdownSetText(dropdown)
    if type(dropdown) ~= "table" then return end
    ns.UI.WatchSetText(dropdown, function(text)
        local translated = TranslateText(text)
        return translated, translated ~= text
    end, {
        scopeKey       = "DropdownPoolCleanup",
        runSafeLabel   = "DropdownPoolCleanup.SetText",
        skipEditBoxes  = false,  -- dropdowns are buttons, not EditBoxes
        checkAncestors = false,
    })
end

local function AttachCleanInitializer(entry)
    if entry and entry.AddInitializer then
        entry:AddInitializer(function(button) CleanButton(button) end)
    end
end

local function GetLSM()
    local libStub = _G.LibStub
    if type(libStub) == "function" then
        local ok, lib = pcall(libStub, "LibSharedMedia-3.0", true)
        if ok and type(lib) == "table" then return lib end
    elseif type(libStub) == "table" and type(libStub.GetLibrary) == "function" then
        local ok, lib = pcall(libStub.GetLibrary, libStub, "LibSharedMedia-3.0", true)
        if ok and type(lib) == "table" then return lib end
    end
    return nil
end

local function SafeLSMCall(lsm, method, mediaType)
    if not lsm or type(lsm[method]) ~= "function" then return nil end
    local ok, result = pcall(lsm[method], lsm, mediaType)
    if ok then return result end
    return nil
end

local function AcquireLSMDropdown(parent)
    local factory = _G.ExwindFactory
    local dropdown

    if type(factory) == "table" and type(factory.Acquire) == "function" then
        local ok, frame = pcall(factory.Acquire, factory, "GridLSMDropdown", parent)
        if ok then dropdown = frame end
    end

    if not dropdown then
        dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
    end

    if not dropdown.labelText then
        dropdown.labelText = dropdown:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        dropdown.labelText:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 0, 2)
    end

    if dropdown.Text and dropdown.Arrow then
        dropdown.Text:ClearAllPoints()
        dropdown.Text:SetPoint("LEFT", 8, 0)
        dropdown.Text:SetPoint("RIGHT", dropdown.Arrow, "LEFT", -2, 0)
    end
    if dropdown.Arrow then
        dropdown.Arrow:ClearAllPoints()
        dropdown.Arrow:SetPoint("RIGHT", -2, -3)
    end

    return dropdown
end

-- Mirrors source's font dropdown, without the lsmFontPreview overlay.
-- The font-name preview isn't worth polluting Blizzard's global menu
-- button pool (shared with unit-frame menus and other addons).
local function CreateSafeFontDropdown(self, parent, mediaType, width, label, currentValue, onSelect)
    if type(currentValue) == "function" and onSelect == nil then
        onSelect = currentValue
        currentValue = nil
    end

    local lsm = GetLSM()
    if not lsm then return nil end

    local dropdown = AcquireLSMDropdown(parent)
    dropdown:SetWidth(width)
    if dropdown.EnableMouse then
        dropdown:EnableMouse(true)
    end
    dropdown.labelText:SetText(label or "")

    dropdown._selectedValue = currentValue or SafeLSMCall(lsm, "GetDefault", mediaType)
    dropdown._onSelect = onSelect
    dropdown._mediaType = mediaType
    dropdown:SetText(dropdown._selectedValue or "")

    dropdown:SetupMenu(function(menuOwner, rootDescription)
        if menuOwner._mediaType ~= "font" then return end
        rootDescription:CreateTitle("Select Font")
        if rootDescription.SetScrollMode then rootDescription:SetScrollMode(400) end

        local list = SafeLSMCall(lsm, "HashTable", "font")
        if type(list) ~= "table" then list = {} end

        local sortedKeys = SafeLSMCall(lsm, "List", "font")
        if type(sortedKeys) ~= "table" then sortedKeys = {} end

        for _, key in ipairs(sortedKeys) do
            local path = list[key]
            local btn = rootDescription:CreateRadio(key,
                function()
                    return menuOwner._selectedValue == key
                end,
                function()
                    menuOwner._selectedValue = key
                    menuOwner:SetText(key)
                    if menuOwner._onSelect then menuOwner._onSelect(key, path) end
                end
            )
            AttachCleanInitializer(btn)
        end
    end)

    return dropdown
end

-- Mirrors source's BuildMenu plus a per-entry CleanButton initializer.
-- Reads state from self._items / self._currentValue (set by the original
-- CreateDropdown), so the menu is otherwise identical.
local function InstallGenericMenuBuilder(dropdown)
    dropdown:SetupMenu(function(self, rootDescription)
        if rootDescription.SetScrollMode then rootDescription:SetScrollMode(400) end

        local function BuildMenu(rootDesc, list)
            if not list then return end
            for _, item in ipairs(list) do
                if type(item) == "table" and item.isMenu then
                    local subMenu = rootDesc:CreateButton(TranslateText(item.text), function() end)
                    AttachCleanInitializer(subMenu)
                    BuildMenu(subMenu, item.menu)
                else
                    local text, value
                    if type(item) == "table" then
                        text, value = item[1], item[2]
                    else
                        text, value = item, item
                    end

                    local displayText = TranslateText(text)
                    local btn = rootDesc:CreateRadio(displayText,
                        function()
                            return (self._currentValue == value)
                                or (tostring(self._currentValue) == tostring(value))
                        end,
                        function()
                            self._currentValue = value
                            self:SetText(displayText)
                            if self._onSelect then self._onSelect(value, displayText) end
                        end
                    )
                    AttachCleanInitializer(btn)
                end
            end
        end

        BuildMenu(rootDescription, self._items)
    end)
end

-- Mirrors source's multiselect SetupMenu plus a CleanButton initializer
-- on every checkbox and the Clear-All button.
local function InstallMultiselectMenuBuilder(dropdown, label)
    dropdown:SetupMenu(function(self, rootDescription)
        if rootDescription.SetScrollMode then rootDescription:SetScrollMode(400) end
        rootDescription:CreateTitle(TranslateText(label or ""))

        if not self._options then return end

        local MR = _G.MenuResponse
        for _, key in ipairs(self._options) do
            local cb = rootDescription:CreateCheckbox(TranslateText(key),
                function() return self._selections and self._selections[key] == true end,
                function()
                    if self._selections then
                        self._selections[key] = not self._selections[key]
                    end
                    if type(self.RefreshSelectionDisplay) == "function" then
                        self:RefreshSelectionDisplay()
                    end
                    return MR and MR.Refresh
                end
            )
            AttachCleanInitializer(cb)
        end

        rootDescription:CreateDivider()

        -- Source uses L[<zh>] — the locale-store merge already resolves
        -- this key to "Clear All", but fall back literally if missing.
        local clearLabel = "Clear All"
        if type(_G.ExwindTools) == "table"
           and type(_G.ExwindTools.L) == "table" then
            local resolved = _G.ExwindTools.L["\xe6\xb8\x85\xe7\xa9\xba\xe5\x85\xa8\xe9\x83\xa8"]
            if type(resolved) == "string" and resolved ~= "" then
                clearLabel = resolved
            end
        end

        local clearBtn = rootDescription:CreateButton(clearLabel, function()
            if self._selections then
                for k in pairs(self._selections) do self._selections[k] = nil end
            end
            if type(self.RefreshSelectionDisplay) == "function" then
                self:RefreshSelectionDisplay()
            end
            return MR and MR.Refresh
        end)
        AttachCleanInitializer(clearBtn)
    end)
end

local function ApplyPatch()
    if ns.IsMarked("UI", "DropdownPoolCleanup") then return end
    if type(_G.ExwindTools) ~= "table"
       or type(_G.ExwindTools.UI) ~= "table" then
        return
    end

    local EXUI = _G.ExwindTools.UI
    local origCreate   = EXUI.CreateDropdown
    local origCreateMS = EXUI.CreateMultiSelectDropdown
    local origCreateLSM = EXUI.CreateLSMDropdown
    if type(origCreate) ~= "function" then return end

    if type(origCreateLSM) == "function" then
        EXUI.CreateLSMDropdown = function(self, parent, mediaType, width, label, currentValue, onSelect)
            if mediaType == "font" then
                local ok, dropdown = pcall(CreateSafeFontDropdown, self, parent, mediaType, width, label, currentValue, onSelect)
                if ok and dropdown then
                    return dropdown
                end
                if not ok then ns.Warn("DropdownPoolCleanup(font): " .. tostring(dropdown)) end
            end
            return origCreateLSM(self, parent, mediaType, width, label, currentValue, onSelect)
        end
    end

    EXUI.CreateDropdown = function(self, parent, width, label, items, currentValue, onSelect)
        local dropdown = origCreate(self, parent, width, TranslateText(label), items, currentValue, onSelect)
        if type(dropdown) == "table" and type(dropdown.SetupMenu) == "function" then
            HookDropdownSetText(dropdown)
            local ok, err = pcall(InstallGenericMenuBuilder, dropdown)
            if not ok then ns.Warn("DropdownPoolCleanup(generic): " .. tostring(err)) end
        end
        return dropdown
    end

    if type(origCreateMS) == "function" then
        EXUI.CreateMultiSelectDropdown = function(self, parent, width, label, options, selections, onUpdate)
            local dropdown = origCreateMS(self, parent, width, TranslateText(label), options, selections, onUpdate)
            if type(dropdown) == "table" and type(dropdown.SetupMenu) == "function" then
                HookDropdownSetText(dropdown)
                local ok, err = pcall(InstallMultiselectMenuBuilder, dropdown, label)
                if not ok then ns.Warn("DropdownPoolCleanup(multiselect): " .. tostring(err)) end
            end
            return dropdown
        end
    end

    ns.Mark("UI", "DropdownPoolCleanup")
    ns.Log("UI: dropdown pool cleanup wrappers installed (" ..
        (type(origCreateLSM) == "function" and "CreateLSMDropdown(font), " or "") ..
        "CreateDropdown" ..
        (type(origCreateMS) == "function" and " + CreateMultiSelectDropdown" or "") ..
        ")")
end

-- ExwindTools.UI exists by ExwindCore's ADDON_LOADED. PLAYER_LOGIN is a
-- fallback in case the dispatch order ever changes.
ns.OnAddonLoaded("exwindcore", ApplyPatch)
ns.OnPlayerLogin(ApplyPatch)
