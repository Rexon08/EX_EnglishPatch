---@diagnostic disable: undefined-global
-- Shared helpers for data-mutation patches:
--   StashOriginal     — capture the upstream value under _eb_orig_<field>
--                       before mutating row[field].
--   RegisterPostInit  — register ADDON_LOADED + optional PLAYER_LOGIN +
--                       PLAYER_ENTERING_WORLD-firstPEW handlers in one call.

local _, ns = ...

ns.Patches = ns.Patches or {}

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
