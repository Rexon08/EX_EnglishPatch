---@diagnostic disable: undefined-global
-- Shared marker bag. Patch sites guard with Mark/IsMarked so repeated
-- ADDON_LOADED, /reload, and profile switches don't stack hooks or
-- re-run mutations.

local _, ns = ...

ns._patched = ns._patched or {}

local function NormalizeKey(scope, sub)
    if sub == nil then
        return tostring(scope or "")
    end
    return tostring(scope or "") .. ":" .. tostring(sub)
end

function ns.IsMarked(scope, sub)
    return ns._patched[NormalizeKey(scope, sub)] == true
end

function ns.Mark(scope, sub)
    ns._patched[NormalizeKey(scope, sub)] = true
end

-- Returns the closure result on the first call, true on subsequent calls.
function ns.RunOnce(scope, fn)
    if ns.IsMarked(scope) then
        return true
    end
    ns.Mark(scope)
    return fn()
end
