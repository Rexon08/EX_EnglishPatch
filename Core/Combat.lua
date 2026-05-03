---@diagnostic disable: undefined-global
-- Combat-deferred queue. Frame geometry mutations (SetWidth/SetSize/SetPoint)
-- taint during combat lockdown, so route them through RunSafe: if in combat,
-- queue and flush on PLAYER_REGEN_ENABLED; otherwise run immediately.

local _, ns = ...

ns._combatQueue = ns._combatQueue or {}

local function InCombat()
    return type(InCombatLockdown) == "function" and InCombatLockdown() == true
end

-- Returns true if the closure ran immediately, false if deferred.
function ns.RunSafe(label, fn)
    if type(fn) ~= "function" then return false end
    if InCombat() then
        ns._combatQueue[#ns._combatQueue + 1] = { label = tostring(label or "?"), fn = fn }
        return false
    end
    local ok, err = pcall(fn)
    if not ok then
        ns.Warn("RunSafe(" .. tostring(label) .. "): " .. tostring(err))
    end
    return true
end

function ns.FlushCombatQueue()
    if InCombat() then return end
    local queue = ns._combatQueue
    ns._combatQueue = {}
    for i = 1, #queue do
        local entry = queue[i]
        local ok, err = pcall(entry.fn)
        if not ok then
            ns.Warn("FlushCombatQueue(" .. entry.label .. "): " .. tostring(err))
        end
    end
end

function ns.InCombat()
    return InCombat()
end
