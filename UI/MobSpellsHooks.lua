---@diagnostic disable: undefined-global
-- Display-layer translation for the M+ Spell Info window:
--
--   * Window title — source uses a raw module-local string.
--   * Right-panel "<type>    LV.X(rank)" — elite/boss suffix is
--     concatenated raw in source; post-process via hooksecurefunc.
--   * Mob names + dungeon tab labels — table keys stay zh (they index
--     EXSP.Database lookups); we paint English over the FontString.

local _, ns = ...

local SUFFIX_MAP = nil  -- filled after Translations load
local CREATURE_MAP = nil
local MOB_NAME_MAP = nil

local function CacheMaps()
    SUFFIX_MAP = ns.Translations.MobSpells and ns.Translations.MobSpells.LevelSuffix or {}
    CREATURE_MAP = ns.Translations.MobSpells and ns.Translations.MobSpells.CreatureTypes or {}
    MOB_NAME_MAP = ns.Translations.MobSpells and ns.Translations.MobSpells.MobNames or {}
end

-- Replace zh substrings via literal find/replace; returns (str, changed).
local function ReplaceSubstrings(s, map)
    if type(s) ~= "string" or s == "" or type(map) ~= "table" then
        return s, false
    end
    local out = s
    local changed = false
    for zh, en in pairs(map) do
        if type(zh) == "string" and zh ~= "" and out:find(zh, 1, true) then
            -- Plain find/replace — string.gsub would treat zh as a pattern.
            local result, found = "", 1
            while true do
                local s_pos, e_pos = out:find(zh, found, true)
                if not s_pos then
                    result = result .. out:sub(found)
                    break
                end
                result = result .. out:sub(found, s_pos - 1) .. en
                found = e_pos + 1
            end
            if result ~= out then
                out = result
                changed = true
            end
        end
    end
    return out, changed
end

local function MakeMapTranslator(replaceMaps)
    return function(text)
        if type(text) ~= "string" or text == "" then return text, false end
        local out, changed = text, false
        for _, map in ipairs(replaceMaps) do
            local replaced, didChange = ReplaceSubstrings(out, map)
            if didChange then
                out = replaced
                changed = true
            end
        end
        return out, changed
    end
end

local function HookFontStringSetText(fs, replaceMaps)
    if type(fs) ~= "table" then return end
    ns.UI.WatchSetText(fs, MakeMapTranslator(replaceMaps), {
        scopeKey       = "MobSpells",
        runSafeLabel   = "MobSpells.SetText",
        skipEditBoxes  = false,  -- targets are known label FontStrings
        checkAncestors = false,
        repaintNow     = false,  -- callers do their own initial repaint pass
    })
end

local function PatchTitle()
    local title = ns.Translations.MobSpells and ns.Translations.MobSpells.MainTitle
    if type(title) ~= "table" then return end
    -- The main frame is built lazily on first open; source stores no
    -- back-pointer, so reach it via a tab's parent (single hop only).
    local frame = _G.EXSP and _G.EXSP.MainFrame or nil
    if not frame and _G.EXSP and _G.EXSP.Tabs and #_G.EXSP.Tabs > 0 then
        local firstTab = _G.EXSP.Tabs[1]
        if firstTab and firstTab.GetParent then
            frame = firstTab:GetParent()
            if frame then
                _G.EXSP.MainFrame = frame
            end
        end
    end
    if not frame or not frame.Title then return end
    HookFontStringSetText(frame.Title, { title })
    -- Source already painted the zh title before our hook installed.
    local current = frame.Title.GetText and frame.Title:GetText()
    if type(current) == "string" and current ~= "" then
        frame.Title:SetText(current)
    end
end

local function PatchInfoPanel()
    if not (_G.EXSP and _G.EXSP.NPCInfoPanel) then return end
    local info = _G.EXSP.NPCInfoPanel
    HookFontStringSetText(info.CenterInfo, { SUFFIX_MAP, CREATURE_MAP })
    HookFontStringSetText(info.Name, { MOB_NAME_MAP })

    if info.Name and type(info.Name.GetText) == "function" then
        local current = info.Name:GetText()
        if type(current) == "string" and current ~= "" then
            info.Name:SetText(current)
        end
    end
    if info.CenterInfo and type(info.CenterInfo.GetText) == "function" then
        local current = info.CenterInfo:GetText()
        if type(current) == "string" and current ~= "" then
            info.CenterInfo:SetText(current)
        end
    end
end

local function PatchMobList()
    if not (_G.EXSP and _G.EXSP.MobScroll) then return end
    if type(MOB_NAME_MAP) ~= "table" then return end
    local scroll = _G.EXSP.MobScroll
    if type(scroll.GetScrollChild) ~= "function" then return end
    local container = scroll:GetScrollChild()
    if type(container) ~= "table" or type(container.GetChildren) ~= "function" then return end

    for _, child in ipairs({ container:GetChildren() }) do
        local fs = child and child.nameText
        if fs and type(fs.GetText) == "function" and type(fs.SetText) == "function" then
            local current = fs:GetText()
            -- Cache the zh key now so the search override can map a
            -- button back to its EXSP.Database row after we paint English.
            if type(current) == "string" and current ~= "" and MOB_NAME_MAP[current] then
                child._eb_zhName = current
            end
            local translated = type(current) == "string" and MOB_NAME_MAP[current] or nil
            if type(translated) == "string" and translated ~= "" and translated ~= current then
                ns.RunSafe("MobSpells.MobName", function()
                    fs:SetText(translated)
                end)
            end
        end
    end
end

local function PatchDungeonTabs()
    if not (_G.EXSP and _G.EXSP.Tabs) then return end
    -- DungeonAbbr values were translated in the data pass, but the tabs
    -- render before that runs on first /reload — re-paint here.
    local abbrMap = _G.EXSP.DungeonAbbr or {}
    local list = _G.EXSP.DungeonList or {}
    for i, tab in ipairs(_G.EXSP.Tabs) do
        if tab and tab.text and list[i] then
            local en = abbrMap[list[i]]
            if type(en) == "string" and en ~= "" then
                ns.RunSafe("MobSpells.Tab" .. i, function()
                    tab.text:SetText(en)
                end)
            end
        end
    end
end

-- Source keys icons by C_ChallengeMode.GetMapUIInfo names (client-locale)
-- but looks them up by zh DungeonList values, so non-CN clients fall back
-- to the "?" icon. Try zh, curated en, then a normalized-name match.
local function NormalizeName(s)
    if type(s) ~= "string" then return "" end
    return (s:gsub("[%s%p]", "")):lower()
end

local function BuildDungeonIconMap()
    local cm = _G.C_ChallengeMode
    if type(cm) ~= "table"
       or type(cm.GetMapTable) ~= "function"
       or type(cm.GetMapUIInfo) ~= "function" then
        return {}, {}
    end
    local mapIDs = cm.GetMapTable()
    if type(mapIDs) ~= "table" then return {}, {} end
    local byName, byNorm = {}, {}
    for _, mapID in ipairs(mapIDs) do
        local name, _, _, icon = cm.GetMapUIInfo(mapID)
        if icon and type(name) == "string" and name ~= "" then
            byName[name] = icon
            byNorm[NormalizeName(name)] = icon
        end
    end
    return byName, byNorm
end

local function PatchDungeonIcons()
    if not (_G.EXSP and _G.EXSP.Tabs and _G.EXSP.DungeonList) then return end
    local byName, byNorm = BuildDungeonIconMap()
    if not next(byName) then return end
    local zhToEn = ns.Translations.MobSpells
        and ns.Translations.MobSpells.DungeonNames or {}
    local list = _G.EXSP.DungeonList
    for i, tab in ipairs(_G.EXSP.Tabs) do
        local zh = list[i]
        local fs = tab and tab.icon
        if fs and type(zh) == "string" and zh ~= "" then
            local en = zhToEn[zh]
            local icon = byName[zh] or (en and byName[en])
            if not icon then
                icon = byNorm[NormalizeName(zh)]
                    or (en and byNorm[NormalizeName(en)])
            end
            if icon then
                ns.RunSafe("MobSpells.Icon" .. i, function()
                    fs:SetTexture(icon)
                    fs:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                end)
            end
        end
    end
end

-- Source's OnTextChanged filters zh database keys directly, so English
-- queries miss. Replace the script handler so the query matches either
-- the zh key or the curated English. Delegate rendering by calling the
-- source refresher with an empty filter, then hide non-matching rows
-- and re-pack the visible ones to remove layout gaps.
local function PatchSearchBox()
    if ns.IsMarked("UI", "MobSpells.Search") then return end
    local search = _G.EXSP_Search
    if type(search) ~= "table" or type(search.SetScript) ~= "function" then return end

    -- Snapshot the localized placeholder so a future locale change works.
    local placeholder = (type(search.GetText) == "function" and search:GetText()) or ""

    search:SetScript("OnTextChanged", function(self)
        local exsp = _G.EXSP
        local refresh = _G.EXSP_RefreshMobList
        if not exsp or not exsp.CurrentDungeon or type(refresh) ~= "function" then return end

        local text = (type(self.GetText) == "function" and self:GetText()) or ""
        if text == "" or text == placeholder then
            refresh(exsp.CurrentDungeon, nil)
            return
        end

        local mobs = (exsp.Database and exsp.Database[exsp.CurrentDungeon]) or {}
        local q = text:lower()
        local match, anyMatch = {}, false
        local enMap = MOB_NAME_MAP or {}
        for zh in pairs(mobs) do
            if type(zh) == "string" then
                local hit = zh:lower():find(q, 1, true) ~= nil
                if not hit then
                    local en = enMap[zh]
                    hit = type(en) == "string" and en:lower():find(q, 1, true) ~= nil
                end
                if hit then
                    match[zh] = true
                    anyMatch = true
                end
            end
        end

        refresh(exsp.CurrentDungeon, "")

        local scroll = exsp.MobScroll
        if type(scroll) ~= "table" or type(scroll.GetScrollChild) ~= "function" then return end
        local container = scroll:GetScrollChild()
        if type(container) ~= "table" or type(container.GetChildren) ~= "function" then return end

        -- Only freshly-acquired buttons; pooled-but-released ones carry
        -- a stale _eb_zhName from a prior use.
        local visibleIdx = 0
        for _, child in ipairs({ container:GetChildren() }) do
            if child and child.poolType == "SpellInfo_MobButton"
               and type(child.IsShown) == "function" and child:IsShown() then
                local zh = child._eb_zhName
                if anyMatch and zh and match[zh] then
                    local idx = visibleIdx
                    ns.RunSafe("MobSpells.Search.Show", function()
                        child:ClearAllPoints()
                        child:SetPoint("TOPLEFT", 5, -(idx * 70) - 5)
                    end)
                    visibleIdx = visibleIdx + 1
                else
                    ns.RunSafe("MobSpells.Search.Hide", function()
                        child:Hide()
                    end)
                end
            end
        end
    end)

    ns.Mark("UI", "MobSpells.Search")
    ns.Log("UI: MobSpells search override installed")
end

local function HookMobSpellsWindow()
    if ns.IsMarked("UI", "MobSpells") then return end
    if not _G.EXSP then return end
    CacheMaps()

    -- Window builds on first /exsp; render fn is module-local. Hook the
    -- public refresh entry points and re-apply on each open.
    if type(_G.EXSP_RefreshMobList) == "function" then
        hooksecurefunc("EXSP_RefreshMobList", function()
            ns.RunSafe("MobSpells.RefreshList", function()
                PatchTitle()
                PatchDungeonTabs()
                PatchDungeonIcons()
                PatchInfoPanel()
                PatchMobList()
                PatchSearchBox()
            end)
        end)
    end
    if type(_G.EXSP_RefreshRightPanel) == "function" then
        hooksecurefunc("EXSP_RefreshRightPanel", function()
            ns.RunSafe("MobSpells.RefreshRight", function()
                PatchInfoPanel()
                PatchMobList()
            end)
        end)
    end

    ns.Mark("UI", "MobSpells")
    ns.Log("UI: MobSpells hooks installed")
end

ns.OnAddonLoaded("exwindtools", HookMobSpellsWindow)
ns.OnPlayerLogin(HookMobSpellsWindow)
ns.OnPlayerEnteringWorld(function(firstPEW)
    if firstPEW then HookMobSpellsWindow() end
end)

ns.UI.MobSpellsHooks = HookMobSpellsWindow
