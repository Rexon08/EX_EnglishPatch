---@diagnostic disable: undefined-global
-- DogJumpTracker builds a UIParent-anchored callout panel whose two info
-- lines prefix raw zh ("Current: " / "Next: ") plus a zh fallback body.
-- None route through L[...], and the panel lives outside every root the
-- generic TextReplacement walker visits — so install per-FontString
-- SetText hooks the moment the panel is built.
--
-- Panel is created lazily inside UpdatePanel(), so hook UpdatePanel
-- post-execution: by then the FontStrings exist and have their first
-- SetText. Subsequent calls are no-ops via the per-target watcher marker.

local _, ns = ...

-- Length-descending so longer keys ("Next: None") win over shorter
-- prefixes ("Next: "), and bare zh chars don't match inside player names.
local function SortedKeys(map)
    local keys = {}
    for k in pairs(map) do
        if type(k) == "string" and k ~= "" then
            keys[#keys + 1] = k
        end
    end
    table.sort(keys, function(a, b) return #a > #b end)
    return keys
end

local _cachedMap, _cachedKeys = nil, nil
local function GetMap()
    local map = ns.Translations.ModuleStrings
        and ns.Translations.ModuleStrings.DogJumpPanel
        or nil
    if map ~= _cachedMap then
        _cachedMap = map
        _cachedKeys = map and SortedKeys(map) or {}
    end
    return _cachedMap, _cachedKeys
end

local function ReplaceLiteral(text, needle, replacement)
    local sp, ep = text:find(needle, 1, true)
    if not sp then return text, false end
    local out, cursor = {}, 1
    while sp do
        out[#out + 1] = text:sub(cursor, sp - 1)
        out[#out + 1] = replacement
        cursor = ep + 1
        sp, ep = text:find(needle, cursor, true)
    end
    out[#out + 1] = text:sub(cursor)
    return table.concat(out), true
end

local function Translate(text)
    if type(text) ~= "string" or text == "" then return text, false end
    local map, keys = GetMap()
    if not map or #keys == 0 then return text, false end
    local out, changed = text, false
    for i = 1, #keys do
        local key = keys[i]
        if out:find(key, 1, true) then
            local replaced, didReplace = ReplaceLiteral(out, key, map[key])
            if didReplace then
                out = replaced
                changed = true
            end
        end
    end
    return out, changed
end

local WATCH_OPTS = {
    scopeKey       = "DogJump",
    runSafeLabel   = "DogJumpTracker.SetText",
    skipEditBoxes  = false,  -- targets are known FontStrings on a UIParent panel
    checkAncestors = false,
}

local function HookFontString(fs)
    if type(fs) ~= "table" then return end
    ns.UI.WatchSetText(fs, Translate, WATCH_OPTS)
end

local function InstallPanelHooks()
    if ns.IsMarked("UI", "DogJumpTracker") then return end
    if type(hooksecurefunc) ~= "function" then return end

    local mod = _G.ExBoss
        and _G.ExBoss.Modules
        and _G.ExBoss.Modules.Boss
        and _G.ExBoss.Modules.Boss.DogJumpTracker
    if type(mod) ~= "table" or type(mod.UpdatePanel) ~= "function" then return end

    ns.Mark("UI", "DogJumpTracker")

    hooksecurefunc(mod, "UpdatePanel", function(self)
        local panel = self and self.panel
        if type(panel) ~= "table" then return end
        HookFontString(panel.current)
        HookFontString(panel.candidates)
    end)

    ns.Log("UI: DogJumpTracker hooks installed")
end

ns.OnAddonLoaded("exboss", InstallPanelHooks)
ns.OnPlayerLogin(InstallPanelHooks)
ns.OnPlayerEnteringWorld(function(firstPEW)
    if firstPEW then InstallPanelHooks() end
end)

ns.UI.DogJumpTrackerHooks = InstallPanelHooks
