---@diagnostic disable: undefined-global
-- Hard rule: dropdown *values* (storage keys) must stay zh; only the
-- displayed *text* may change. The Voice Pack catalog implements this
-- already; other dropdowns route display through ExBoss.L / ExwindLocale,
-- so the locale-store merge handles them for free.
--
-- No per-dropdown hooks today. Exposes RegisterDropdownLabelHook for any
-- new dropdown source that surfaces during smoke testing.

local _, ns = ...

ns.UI.DropdownLabelHooks = ns.UI.DropdownLabelHooks or {}

function ns.UI.RegisterDropdownLabelHook(name, fn)
    if type(name) ~= "string" or type(fn) ~= "function" then return false end
    ns.UI.DropdownLabelHooks[name] = fn
    return true
end

local function NoteAdapterLoaded()
    if ns.IsMarked("UI", "DropdownAdapter") then return end
    ns.Mark("UI", "DropdownAdapter")
    ns.Log("UI: dropdown adapter ready (no extra hooks needed today)")
end

ns.OnPlayerLogin(NoteAdapterLoaded)
