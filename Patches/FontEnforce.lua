---@diagnostic disable: undefined-global
-- Forces the Boss/Tools settings panels onto a single Latin font so that
-- translated labels stop rendering in the AR ZhongkaiGBK CJK face that
-- ExwindCore selects via LibSharedMedia on non-CJK clients.
--
-- Three-step enforcement:
--   1. Replace ExwindTools.MAIN_FONT — every lazy SetFont(MAIN_FONT, ...)
--      call in the upstream panels picks up the new path on next build.
--   2. Walk the live panel frames after each Toggle/Refresh/SetTab and
--      repaint FontStrings/EditBoxes whose path captured the old value at
--      file-load time (some upstream files cache MAIN_FONT into a local).
--   3. CJK fallback pass — after step 2 (and after the text-replacement
--      hooks have substituted what they can), revert any FontString whose
--      text still contains a CJK byte back to its captured original font.
--      Untranslated raw zh therefore degrades to "ugly font" rather than
--      ".notdef boxes" on a Latin-only face.
--
-- Font path comes from ns.GetUIFont() (Core/Font.lua), which probes the
-- bundled Expressway.TTF first and falls back through LSM → STANDARD_TEXT_FONT
-- → Fonts\FRIZQT__.TTF, so this never installs a non-loadable font.

local _, ns = ...

local MAX_DEPTH = 14   -- generous; Boss panel nests ~8 deep

-- Per-frame tag so we don't re-walk regions we already touched.
-- Stored as a key on the live frame (FontStrings have no GetUserData).
local TAG = "_eb_fontPainted"
-- Per-region cache of the upstream font path captured on first paint.
-- Used by the CJK fallback pass to restore the original face on regions
-- whose text could not be translated.
local ORIG_FONT = "_eb_origFontPath"
local ORIG_FONT_FLAGS = "_eb_origFontFlags"

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
    if not okGet or type(path) ~= "string" then return end

    -- Capture the upstream font on first paint so the CJK fallback pass
    -- has somewhere to revert to. Only set if not already cached and the
    -- current path isn't already our enforced one (guards against the
    -- second-pass write back to ourselves).
    if region[ORIG_FONT] == nil and path ~= newFont then
        region[ORIG_FONT] = path
        region[ORIG_FONT_FLAGS] = type(flags) == "string" and flags or ""
    end

    if path == newFont then return end

    -- Skip ChatFontNormal-sized values without a size — defensive against
    -- exotic FontInstances that return nil for size.
    size = tonumber(size) or 12
    flags = type(flags) == "string" and flags or ""

    pcall(region.SetFont, region, newFont, size, flags)
end

-- A 3-byte UTF-8 lead (0xE0..0xEF) covers the CJK Unified Ideographs
-- range U+4E00..U+9FFF and the CJK punctuation block U+3000..U+303F,
-- which is what the upstream zh strings actually contain. Pure ASCII
-- (latin contributor handles, version numbers, English) returns false.
local function HasCJKByte(s)
    if type(s) ~= "string" or s == "" then return false end
    for i = 1, #s do
        local b = s:byte(i)
        if b >= 0xE0 and b <= 0xEF then return true end
    end
    return false
end

local function FallbackRegion(region)
    if not region or type(region.GetObjectType) ~= "function" then return end
    local ok, objType = pcall(region.GetObjectType, region)
    if not ok or objType ~= "FontString" then return end

    local origPath = region[ORIG_FONT]
    if type(origPath) ~= "string" or origPath == "" then return end

    -- Only the painted FontStrings need fallback; if we never touched
    -- this region (e.g. it joined the panel after the walk) origPath is
    -- nil and we leave it alone.
    if type(region.GetText) ~= "function" then return end
    local okText, text = pcall(region.GetText, region)
    if not okText or not HasCJKByte(text) then return end

    if type(region.GetFont) ~= "function" or type(region.SetFont) ~= "function" then return end
    local okGet, currentPath, size = pcall(region.GetFont, region)
    if not okGet then return end
    if currentPath == origPath then return end

    size = tonumber(size) or 14
    local flags = region[ORIG_FONT_FLAGS] or ""
    pcall(region.SetFont, region, origPath, size, flags)
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

local function FallbackWalk(frame, depth)
    if not frame or depth > MAX_DEPTH then return end
    if type(frame) ~= "table" then return end

    FallbackRegion(frame)

    if type(frame.GetRegions) == "function" then
        local ok, regions = pcall(function() return { frame:GetRegions() } end)
        if ok and regions then
            for i = 1, #regions do
                FallbackRegion(regions[i])
            end
        end
    end

    if type(frame.GetChildren) == "function" then
        local ok, children = pcall(function() return { frame:GetChildren() } end)
        if ok and children then
            for i = 1, #children do
                FallbackWalk(children[i], depth + 1)
            end
        end
    end
end

local function ScheduleFallback(rootFrame)
    if type(rootFrame) ~= "table" then return end
    -- Defer so the TextReplacementHooks C_Timer.After(0) walk runs first
    -- and substitutes everything it can; whatever still has CJK bytes
    -- after that pass is genuinely untranslated and falls back here.
    if type(C_Timer) == "table" and type(C_Timer.After) == "function" then
        C_Timer.After(0.05, function()
            ns.RunSafe("FontEnforce:Fallback", function()
                FallbackWalk(rootFrame, 0)
            end)
        end)
    else
        ns.RunSafe("FontEnforce:Fallback", function()
            FallbackWalk(rootFrame, 0)
        end)
    end
end

local function EnforceIn(rootFrame)
    if type(rootFrame) ~= "table" then return end
    local newFont = GetTargetFont()
    if not newFont then return end
    ClearTags(rootFrame, 0)
    Walk(rootFrame, newFont, 0)
    ScheduleFallback(rootFrame)
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
