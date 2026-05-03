---@diagnostic disable: undefined-global
-- Some source files capture localized strings into file-local tables
-- before this addon loads, so the locale-store patches can't reach them.
-- Repaint named addon-owned roots after their render methods run.
-- Event-driven, bounded by known roots, and skips EditBoxes.

local _, ns = ...

local MAX_DEPTH = 10

local function Translate(text)
    if type(text) ~= "string" or text == "" then return text, false end
    if type(ns.TranslateDisplayText) ~= "function" then return text, false end
    return ns.TranslateDisplayText(text)
end

local function SafeCall(obj, method, ...)
    if type(obj) ~= "table" or type(obj[method]) ~= "function" then return nil end
    local ok, result = pcall(obj[method], obj, ...)
    if ok then return result end
    return nil
end

local function ObjectType(obj)
    return SafeCall(obj, "GetObjectType")
end

local function IsEditBox(obj)
    if type(obj) ~= "table" then return false end
    if ObjectType(obj) == "EditBox" then return true end
    if type(obj.IsObjectType) == "function" then
        local ok, result = pcall(obj.IsObjectType, obj, "EditBox")
        if ok and result == true then return true end
    end
    return false
end

local function IsUnderEditBox(obj)
    local parent = SafeCall(obj, "GetParent")
    local depth = 0
    while parent and depth < 6 do
        if IsEditBox(parent) then return true end
        parent = SafeCall(parent, "GetParent")
        depth = depth + 1
    end
    return false
end

local function ResizeTabButton(button)
    if type(button) ~= "table" then return end
    local name = SafeCall(button, "GetName")
    if type(name) == "string"
       and name:find("^ExBoss_MainPanelTab")
       and type(PanelTemplates_TabResize) == "function" then
        pcall(PanelTemplates_TabResize, button, 0)
    end
    if ns.GetDB and ns.GetDB().fitWidths and type(ns.UI_FitButton) == "function" then
        ns.UI_FitButton(button, { padding = 18, maxWidth = 260 })
    end
end

local function ResizeIfButton(target)
    if ObjectType(target) == "Button" then
        ResizeTabButton(target)
    end
end

local function PatchObjectText(obj, label)
    if type(obj) ~= "table" then return end
    -- An already-hooked FontString self-syncs via its SetText hook;
    -- only walk new ones.
    if obj._eb_walked then return end
    local installed = ns.UI.WatchSetText(obj, Translate, {
        scopeKey       = "TextReplacement",
        runSafeLabel   = label,
        skipEditBoxes  = true,
        checkAncestors = true,
        afterApply     = ResizeIfButton,
    })
    if installed then obj._eb_walked = true end
end

local function PatchRegions(root, label)
    if type(root) ~= "table" or type(root.GetRegions) ~= "function" then return end
    local regions = { root:GetRegions() }
    for i = 1, #regions do
        local region = regions[i]
        if ObjectType(region) == "FontString" then
            PatchObjectText(region, label)
        end
    end
end

local function PatchRoot(root, depth)
    if type(root) ~= "table" or depth < 0 then return end
    if IsEditBox(root) then return end

    PatchObjectText(root, "TextReplacement.Frame")
    PatchRegions(root, "TextReplacement.Region")

    if type(root.GetChildren) ~= "function" then return end
    local children = { root:GetChildren() }
    for i = 1, #children do
        PatchRoot(children[i], depth - 1)
    end
end

local function AddRoot(roots, seen, root)
    if type(root) ~= "table" then return end
    if seen[root] then return end
    seen[root] = true
    roots[#roots + 1] = root
end

local function AddScrollChild(roots, seen, scroll)
    if type(scroll) ~= "table" or type(scroll.GetScrollChild) ~= "function" then return end
    AddRoot(roots, seen, scroll:GetScrollChild())
end

local function CollectKnownRoots()
    local roots, seen = {}, {}

    local panel = _G.ExBoss and _G.ExBoss.UI and _G.ExBoss.UI.Panel or nil
    AddRoot(roots, seen, _G.ExBoss_MainPanel)
    if type(panel) == "table" then
        AddRoot(roots, seen, panel._frame)
        AddRoot(roots, seen, panel.leftFrame)
        AddRoot(roots, seen, panel.contentFrame)
    end

    local EXUI = _G.ExwindTools and _G.ExwindTools.UI or nil
    if type(EXUI) == "table" then
        AddRoot(roots, seen, EXUI.MainFrame)
        AddRoot(roots, seen, EXUI.LeftPanel)
        AddRoot(roots, seen, EXUI.RightPanel)
        AddRoot(roots, seen, EXUI.ActivePageFrame)
        AddRoot(roots, seen, EXUI.ModuleScrollChild)
    end

    local EXSP = _G.EXSP
    if type(EXSP) == "table" then
        AddRoot(roots, seen, EXSP.MainFrame)
        AddRoot(roots, seen, EXSP.NPCInfoPanel)
        AddScrollChild(roots, seen, EXSP.MobScroll)
        AddScrollChild(roots, seen, EXSP.SpellScroll)
    end

    return roots
end

local function TranslateKnownRoots()
    local roots = CollectKnownRoots()
    for i = 1, #roots do
        PatchRoot(roots[i], MAX_DEPTH)
    end
end

-- Per-frame debounce: a single panel show fires Show + Toggle + SetTab +
-- page Render in quick succession; coalesce into one walk.
local _knownPending = nil
local _rootPending = nil

local function ScheduleKnown(reason)
    if _knownPending then
        _knownPending = reason or _knownPending
        return
    end
    _knownPending = reason or "known"
    if type(C_Timer) == "table" and type(C_Timer.After) == "function" then
        C_Timer.After(0, function()
            local r = _knownPending
            _knownPending = nil
            ns.RunSafe("TextReplacement:" .. tostring(r), TranslateKnownRoots)
        end)
    else
        local r = _knownPending
        _knownPending = nil
        ns.RunSafe("TextReplacement:" .. tostring(r), TranslateKnownRoots)
    end
end

local function ScheduleRoot(root, reason)
    if type(root) ~= "table" then return end
    if not _rootPending then _rootPending = {} end
    if _rootPending[root] then return end
    _rootPending[root] = reason or "root"
    if type(C_Timer) == "table" and type(C_Timer.After) == "function" then
        C_Timer.After(0, function()
            local r = _rootPending and _rootPending[root]
            if _rootPending then _rootPending[root] = nil end
            if r then
                ns.RunSafe("TextReplacement:" .. tostring(r), function()
                    PatchRoot(root, MAX_DEPTH)
                end)
            end
        end)
    else
        local r = _rootPending[root]
        _rootPending[root] = nil
        ns.RunSafe("TextReplacement:" .. tostring(r), function()
            PatchRoot(root, MAX_DEPTH)
        end)
    end
end

local function TranslateRootLater(root, reason)
    ScheduleRoot(root, reason)
end

local function TranslateKnownRootsLater(reason)
    ScheduleKnown(reason)
end

local function HookMethod(scope, owner, method, callback)
    if type(hooksecurefunc) ~= "function" then return false end
    if type(owner) ~= "table" or type(owner[method]) ~= "function" then return false end
    local markKey = tostring(scope) .. "." .. tostring(method)
    if ns.IsMarked("TextReplacement", markKey) then return false end
    hooksecurefunc(owner, method, callback)
    ns.Mark("TextReplacement", markKey)
    return true
end

local function HookExwindTools()
    local EXUI = _G.ExwindTools and _G.ExwindTools.UI or nil
    if type(EXUI) ~= "table" then return 0 end

    local count = 0
    local function schedule()
        TranslateKnownRootsLater("ExwindTools")
    end

    if HookMethod("ExwindTools", EXUI, "RefreshContent", schedule) then count = count + 1 end
    if HookMethod("ExwindTools", EXUI, "RefreshContentKeepModuleScroll", schedule) then count = count + 1 end
    if HookMethod("ExwindTools", EXUI, "ShowModuleSettingsPage", schedule) then count = count + 1 end
    return count
end

local function HookGrid()
    local Grid = _G.ExwindGrid
    if type(Grid) ~= "table" then return 0 end

    if HookMethod("ExwindGrid", Grid, "Render", function(_, container)
        TranslateRootLater(container, "Grid")
    end) then
        return 1
    end
    return 0
end

local function HookPanelPage(pageName, page)
    if type(page) ~= "table" then return 0 end
    local count = 0
    local function schedule()
        TranslateKnownRootsLater(pageName)
    end

    for _, method in ipairs({
        "Render",
        "Refresh",
        "RefreshSpellUI",
        "RefreshSelectedSpell",
        "RenderSettingsGrid",
        "SetSelectedKey",
    }) do
        if HookMethod(pageName, page, method, schedule) then count = count + 1 end
    end
    return count
end

-- The EXSP M+ Spell Details panel is built lazily by /EXSP, so frames
-- don't exist at LOGIN/PEW. Hook the public refresh entry points so the
-- known-roots walk re-fires once the panel is built.
local function HookEXSP()
    if type(hooksecurefunc) ~= "function" then return 0 end
    local count = 0
    if type(_G.EXSP_RefreshMobList) == "function"
       and not ns.IsMarked("TextReplacement", "EXSP.RefreshMobList") then
        hooksecurefunc("EXSP_RefreshMobList", function()
            TranslateKnownRootsLater("EXSP.RefreshMobList")
        end)
        ns.Mark("TextReplacement", "EXSP.RefreshMobList")
        count = count + 1
    end
    if type(_G.EXSP_RefreshRightPanel) == "function"
       and not ns.IsMarked("TextReplacement", "EXSP.RefreshRightPanel") then
        hooksecurefunc("EXSP_RefreshRightPanel", function()
            TranslateKnownRootsLater("EXSP.RefreshRightPanel")
        end)
        ns.Mark("TextReplacement", "EXSP.RefreshRightPanel")
        count = count + 1
    end
    return count
end

local function HookExBoss()
    local panel = _G.ExBoss and _G.ExBoss.UI and _G.ExBoss.UI.Panel or nil
    if type(panel) ~= "table" then return 0 end

    local count = 0
    local function schedule()
        TranslateKnownRootsLater("ExBoss.Panel")
    end

    if HookMethod("ExBoss.Panel", panel, "Show", schedule) then count = count + 1 end
    if HookMethod("ExBoss.Panel", panel, "Toggle", schedule) then count = count + 1 end
    if HookMethod("ExBoss.Panel", panel, "SetTab", schedule) then count = count + 1 end

    for _, pageName in ipairs({
        "HomePage",
        "VoicePackPage",
        "BossPage",
        "TrashCDPage",
        "GlobalSettingsPage",
        "GeneralOverviewPage",
        "BatchEditPage",
        "CastProgressBarPage",
        "TimerBarPage",
        "RingProgressPage",
        "FlashTextPage",
        "FlashTextMediumPage",
        "CountdownPage",
        "BunBarPage",
        "ImportExportPage",
        "PrivateAuraPage",
        "PrivateAuraMonitorPage",
        "ConditionsPage",
        "MDTPage",
        "FixedTimelinePage",
    }) do
        count = count + HookPanelPage("ExBoss." .. pageName, panel[pageName])
    end

    return count
end

local function InstallHooks()
    if ns.IsMarked("UI", "TextReplacement") then
        TranslateKnownRootsLater("refresh")
        return
    end

    local count = 0
    count = count + HookExwindTools()
    count = count + HookGrid()
    count = count + HookExBoss()
    count = count + HookEXSP()

    if count > 0 then
        ns.Mark("UI", "TextReplacement")
        ns.Log("UI: text replacement hooks installed (" .. tostring(count) .. " methods)")
    end
    TranslateKnownRootsLater("initial")
end

ns.OnAddonLoaded("exwindcore", InstallHooks)
ns.OnAddonLoaded("exwindtools", InstallHooks)
ns.OnAddonLoaded("exboss", InstallHooks)
ns.OnPlayerLogin(InstallHooks)
ns.OnPlayerEnteringWorld(function(firstPEW)
    if firstPEW then InstallHooks() end
end)
ns.OnRegenEnabled(function()
    TranslateKnownRootsLater("postCombat")
end)

ns.UI.TextReplacementHooks = {
    TranslateKnownRoots = TranslateKnownRoots,
    PatchRoot = PatchRoot,
}
