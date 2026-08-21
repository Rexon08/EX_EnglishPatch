---@diagnostic disable: undefined-global
-- Shared helpers for data-mutation patches:
--   StashOriginal     — capture the upstream value under _eb_orig_<field>
--                       before mutating row[field].
--   RegisterPostInit  — register ADDON_LOADED + optional PLAYER_LOGIN +
--                       PLAYER_ENTERING_WORLD-firstPEW handlers in one call.
--   HookMethodPost    — yield-safe post-hook for upstream Lua methods that
--                       may run inside LibAsync coroutines.

local _, ns = ...

ns.Patches = ns.Patches or {}

-- ns.HookMethodPost(label, owner, method, callback) -> bool
-- Yield-safe post-hook for Lua methods on upstream addon tables.
-- hooksecurefunc inserts a C wrapper frame, so a hooked method that runs
-- inside a LibAsync coroutine dies at its first coroutine.yield with
-- "attempt to yield across metamethod/C-call boundary" (12.1 EXBoss
-- renders Grid content exactly that way). A plain Lua wrapper frame is
-- transparent to yields: the coroutine suspends and resumes straight
-- through it, and the callback fires once the original truly completes —
-- even when that completion is several frames later.
-- Use this for any upstream method that can run inside a coroutine;
-- hooksecurefunc remains fine for C widget methods and load-time seams.
function ns.HookMethodPost(label, owner, method, callback)
    if type(owner) ~= "table"
       or type(owner[method]) ~= "function"
       or type(callback) ~= "function" then
        return false
    end
    local orig = owner[method]
    owner[method] = function(...)
        local nargs = select("#", ...)
        local args = { ... }
        local function finish(...)
            ns.RunSafe(label, function()
                callback(unpack(args, 1, nargs))
            end)
            return ...
        end
        return finish(orig(...))
    end
    return true
end

function ns.Patches.StashOriginal(row, field)
    if type(row) ~= "table" or type(field) ~= "string" then return end
    local origField = "_eb_orig_" .. field
    if row[origField] == nil and row[field] ~= nil then
        row[origField] = row[field]
    end
end

-- ns.Patches.RegisterPostInit { deps = ..., apply = ... [, login, afterPEW] }
--   deps      string | array of lowercase target-addon names
--   apply     function called for each fire (must be marker-guarded internally)
--   login     register OnPlayerLogin too (default false)
--   afterPEW  register OnPlayerEnteringWorld(firstPEW) too (default true)
function ns.Patches.RegisterPostInit(opts)
    if type(opts) ~= "table" or type(opts.apply) ~= "function" then return end
    local apply = opts.apply

    local deps = opts.deps
    if type(deps) == "string" then deps = { deps } end
    if type(deps) == "table" then
        for _, dep in ipairs(deps) do
            if type(dep) == "string" and dep ~= "" then
                ns.OnAddonLoaded(dep, apply)
            end
        end
    end

    if opts.login then
        ns.OnPlayerLogin(apply)
    end

    if opts.afterPEW ~= false then
        ns.OnPlayerEnteringWorld(function(firstPEW)
            if firstPEW then apply() end
        end)
    end
end
