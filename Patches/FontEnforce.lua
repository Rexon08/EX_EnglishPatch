---@diagnostic disable: undefined-global
-- Forces the Boss/Tools settings panels onto a single Latin font so that
-- translated labels stop rendering in the AR ZhongkaiGBK CJK face that
-- ExwindCore selects via LibSharedMedia on non-CJK clients.
--
-- Two-step enforcement:
--   1. Replace ExwindTools.MAIN_FONT — every lazy SetFont(MAIN_FONT, ...)
--      call in the upstream panels picks up the new path on next build.
--   2. Walk the live panel frames after each Toggle/Refresh/SetTab and
--      repaint FontStrings/EditBoxes whose path captured the old value at
--      file-load time (some upstream files cache MAIN_FONT into a local).
--
-- Font path comes from ns.GetUIFont() (Core/Font.lua), which probes the
-- bundled Expressway.TTF first and falls back through LSM → STANDARD_TEXT_FONT
-- → Fonts\FRIZQT__.TTF, so this never installs a non-loadable font.

local _, ns = ...

local MAX_DEPTH = 14   -- generous; Boss panel nests ~8 deep

-- Per-frame tag so we don't re-walk regions we already touched.
-- Stored as a key on the live frame (FontStrings have no GetUserData).
local TAG = "_eb_fontPainted"

local function GetTargetFont()
    if type(ns.GetUIFont) ~= "function" then return nil end
    local ok, path = pcall(ns.GetUIFont)
    if not ok or type(path) ~= "string" or path == "" then return nil end
    return path
end

local function PaintRegion(region, newFont)
    if not region or type(region.GetObjectType) ~= "function" then return end
    local ok, objType = pcall(region.GetObjectType, region)
    if not ok then return end
    if objType ~= "FontString" and objType ~= "EditBox" then return end
    if type(region.GetFont) ~= "function" or type(region.SetFont) ~= "function" then return end

    local okGet, path, size, flags = pcall(region.GetFont, region)
    if not okGet or type(path) ~= "string" or path == newFont then return end

    -- Skip ChatFontNormal-sized values without a size — defensive against
    -- exotic FontInstances that return nil for size.
    size = tonumber(size) or 12
    flags = type(flags) == "string" and flags or ""

    pcall(region.SetFont, region, newFont, size, flags)
end

local function Walk(frame, newFont, depth)
    if not frame or depth > MAX_DEPTH then return end
    if type(frame) ~= "table" then return end
    if rawget(frame, TAG) then return end
    rawset(frame, TAG, true)

    -- FontString or EditBox themselves
    PaintRegion(frame, newFont)

    if type(frame.GetRegions) == "function" then
        local ok, regions = pcall(function() return { frame:GetRegions() } end)
        if ok and regions then
            for i = 1, #regions do
                PaintRegion(regions[i], newFont)
            end
        end
    end

    if type(frame.GetChildren) == "function" then
        local ok, children = pcall(function() return { frame:GetChildren() } end)
        if ok and children then
            for i = 1, #children do
                Walk(children[i], newFont, depth + 1)
            end
        end
    end
end

-- Walks freshly each call; `TAG` persists per-region inside one walk root,
-- but we clear at the entrypoint so re-builds (tab switches, content
-- refreshes) get re-painted.
local function ClearTags(frame, depth)
    if not frame or depth > MAX_DEPTH then return end
    if type(frame) ~= "table" then return end
    if rawget(frame, TAG) then rawset(frame, TAG, nil) end
    if type(frame.GetRegions) == "function" then
        local ok, regions = pcall(function() return { frame:GetRegions() } end)
        if ok and regions then
            for i = 1, #regions do
                local r = regions[i]
                if type(r) == "table" and rawget(r, TAG) then rawset(r, TAG, nil) end
            end
        end
    end
    if type(frame.GetChildren) == "function" then
        local ok, children = pcall(function() return { frame:GetChildren() } end)
        if ok and children then
            for i = 1, #children do
                ClearTags(children[i], depth + 1)
            end
        end
    end
end

local function EnforceIn(rootFrame)
    if type(rootFrame) ~= "table" then return end
    local newFont = GetTargetFont()
    if not newFont then return end
    ClearTags(rootFrame, 0)
    Walk(rootFrame, newFont, 0)
end

ns.Patches = ns.Patches or {}
ns.Patches.EnforceFontIn = EnforceIn

-- ── ExwindTools.MAIN_FONT swap ──────────────────────────────────────────
local function OverrideMainFont()
    local ET = rawget(_G, "ExwindTools")
    if type(ET) ~= "table" then return false end

    local newFont = GetTargetFont()
    if not newFont then return false end

    if ET.MAIN_FONT ~= newFont then
        ns._originalMainFont = ET.MAIN_FONT
        ET.MAIN_FONT = newFont
        ns.Log("FontEnforce: ExwindTools.MAIN_FONT -> " .. newFont)
    end
    return true
end

-- ── Hook installation ───────────────────────────────────────────────────
local function HookExwindToolsUI()
    if ns.IsMarked("FontEnforce", "ExwindToolsUI") then return end
    local ET = rawget(_G, "ExwindTools")
    local UI = type(ET) == "table" and ET.UI or nil
    if type(UI) ~= "table" then return end

    if type(UI.Toggle) == "function" then
        hooksecurefunc(UI, "Toggle", function(self)
            local f = self and self.MainFrame
            if f and type(f.IsShown) == "function" and f:IsShown() then
                ns.RunSafe("FontEnforce:EXTools:Toggle", function() EnforceIn(f) end)
            end
        end)
    end
    if type(UI.RefreshContent) == "function" then
        hooksecurefunc(UI, "RefreshContent", function(self)
            local f = self and self.MainFrame
            if f then
                ns.RunSafe("FontEnforce:EXTools:Refresh", function() EnforceIn(f) end)
            end
        end)
    end

    ns.Mark("FontEnforce", "ExwindToolsUI")
end

local function HookExBossPanel()
    if ns.IsMarked("FontEnforce", "EXBossPanel") then return end
    local EB = rawget(_G, "ExBoss")
    local Panel = type(EB) == "table" and EB.UI and EB.UI.Panel or nil
    if type(Panel) ~= "table" then return end

    local function rootFrame()
        return Panel._frame or Panel.MainFrame or Panel.mainFrame
    end

    if type(Panel.Toggle) == "function" then
        hooksecurefunc(Panel, "Toggle", function()
            local f = rootFrame()
            if f and type(f.IsShown) == "function" and f:IsShown() then
                ns.RunSafe("FontEnforce:EXBoss:Toggle", function() EnforceIn(f) end)
            end
        end)
    end
    if type(Panel.Show) == "function" then
        hooksecurefunc(Panel, "Show", function()
            local f = rootFrame()
            if f then
                ns.RunSafe("FontEnforce:EXBoss:Show", function() EnforceIn(f) end)
            end
        end)
    end
    if type(Panel.SetTab) == "function" then
        hooksecurefunc(Panel, "SetTab", function()
            local f = rootFrame()
            if f and type(f.IsShown) == "function" and f:IsShown() then
                ns.RunSafe("FontEnforce:EXBoss:SetTab", function() EnforceIn(f) end)
            end
        end)
    end

    ns.Mark("FontEnforce", "EXBossPanel")
end

local function Apply()
    if not (ns.IsEnabled and ns.IsEnabled()) then return end
    if OverrideMainFont() then
        HookExwindToolsUI()
        HookExBossPanel()
    end
end

-- Deps load before us, but ExwindTools.UI / ExBoss.UI.Panel methods are
-- attached during their own file load (already complete at our PEW).
ns.OnPlayerLogin(Apply)
ns.OnPlayerEnteringWorld(function(firstPEW)
    if firstPEW then Apply() end
end)
