---@diagnostic disable: undefined-global
-- Shared SetText-watcher primitive. Each watcher is keyed by `scopeKey`
-- so multiple watchers (e.g. TextReplacement + MobSpells) can coexist on
-- the same target; re-installing the same scopeKey is a no-op. Targets
-- are anything with :SetText / :GetText (FontStrings, Dropdown widgets).

local _, ns = ...

ns.UI = ns.UI or {}

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

local function IsUnderEditBox(obj, maxDepth)
    maxDepth = maxDepth or 6
    local parent = SafeCall(obj, "GetParent")
    local depth = 0
    while parent and depth < maxDepth do
        if IsEditBox(parent) then return true end
        parent = SafeCall(parent, "GetParent")
        depth = depth + 1
    end
    return false
end

-- ns.UI.WatchSetText(target, translateFn, opts) -> bool
--
-- translateFn(text) -> (newText, didChange). Called for future SetText
-- writes and (if repaintNow) for the current text after install.
--
-- opts:
--   scopeKey       per-target marker; re-install = no-op (default "default")
--   runSafeLabel   label passed to ns.RunSafe (default "WatchSetText")
--   skipEditBoxes  refuse on EditBox targets (default true)
--   checkAncestors also refuse if a parent is an EditBox (default true)
--   repaintNow     translate the current text on install (default true)
--   afterApply     optional callback(target, newValue) inside RunSafe;
--                  used to refit tab buttons whose width depends on text.
--
-- Returns true iff the hook was installed on this call.
function ns.UI.WatchSetText(target, translateFn, opts)
    if type(target) ~= "table" or type(target.SetText) ~= "function" then return false end
    if type(translateFn) ~= "function" then return false end

    opts = opts or {}
    local scopeKey       = opts.scopeKey       or "default"
    local runSafeLabel   = opts.runSafeLabel   or "WatchSetText"
    local skipEditBoxes  = opts.skipEditBoxes  ~= false
    local checkAncestors = opts.checkAncestors ~= false
    local repaintNow     = opts.repaintNow     ~= false
    local afterApply     = opts.afterApply

    local markerField = "_eb_watch_" .. scopeKey
    if target[markerField] then return false end

    if skipEditBoxes then
        if IsEditBox(target) then return false end
        if checkAncestors and IsUnderEditBox(target) then return false end
    end

    target[markerField] = true

    local suppress = false

    local function emit(self, value)
        suppress = true
        ns.RunSafe(runSafeLabel, function()
            self:SetText(value)
            if afterApply then afterApply(self, value) end
        end)
        suppress = false
    end

    if type(hooksecurefunc) == "function" then
        hooksecurefunc(target, "SetText", function(self, value)
            if suppress then return end
            if skipEditBoxes and IsEditBox(self) then return end
            if type(value) ~= "string" or value == "" then return end
            local out, changed = translateFn(value)
            if not changed or out == nil or out == value then return end
            emit(self, out)
        end)
    end

    if repaintNow then
        local current = SafeCall(target, "GetText")
        if type(current) == "string" and current ~= "" then
            local out, changed = translateFn(current)
            if changed and out ~= nil and out ~= current then
                emit(target, out)
            end
        end
    end

    return true
end

function ns.UI.HasWatchSetText(target, scopeKey)
    if type(target) ~= "table" then return false end
    return target["_eb_watch_" .. (scopeKey or "default")] == true
end
