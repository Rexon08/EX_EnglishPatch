---@diagnostic disable: undefined-global
-- The Import/Export page is hand-anchored (running `y` offsets), not Grid,
-- so ModuleLayouts geometry can't reach it and the offline label auditor
-- doesn't model it.
--
-- Upstream stacks the "export appearance profile" checkbox and the profile
-- dropdown 32 px apart, but EXUI dropdowns draw their caption *above*
-- themselves (labelText anchored BOTTOMLEFT -> dropdown TOPLEFT). At 32 px
-- the caption lands on the checkbox label. It is marginal in the zh source
-- and clearly overlapping once both strings are English in Expressway.
--
-- Push the dropdown down so the two rows separate. The row below it sits
-- 48 px lower, so the shift stays inside upstream's own spacing.

local _, ns = ...

-- Upstream's TOPLEFT y for the dropdown, and the offset we move it to.
-- Matching the exact source value is deliberate: it makes the patch
-- idempotent across re-renders (the shifted value never re-triggers) and
-- self-disabling if upstream re-flows the page.
local DROPDOWN_SOURCE_Y = -138
local DROPDOWN_SHIFT    = 14
local MAX_DEPTH         = 6

local function SafeCall(obj, method, ...)
    if type(obj) ~= "table" or type(obj[method]) ~= "function" then return nil end
    local ok, result = pcall(obj[method], obj, ...)
    if ok then return result end
    return nil
end

-- The caption text as the page renders it: the raw zh key if the page was
-- built before the locale overlay merged, otherwise our English value.
local function IsProfileDropdown(frame)
    if type(frame) ~= "table" then return false end
    local label = frame.labelText
    if type(label) ~= "table" then return false end
    local text = SafeCall(label, "GetText")
    if type(text) ~= "string" then return false end
    local known = ns.Translations and ns.Translations.ImportExportDropLabels
    return type(known) == "table" and known[text] == true
end

local function ShiftDropdown(frame)
    local point, relativeTo, relativePoint, x, y = SafeCall(frame, "GetPoint", 1)
    if point ~= "TOPLEFT" or type(y) ~= "number" then return false end
    if math.abs(y - DROPDOWN_SOURCE_Y) > 0.5 then return false end
    frame:SetPoint(point, relativeTo, relativePoint, x, y - DROPDOWN_SHIFT)
    return true
end

local function Walk(frame, depth)
    if type(frame) ~= "table" or depth < 0 then return false end
    if IsProfileDropdown(frame) and ShiftDropdown(frame) then return true end
    if type(frame.GetChildren) ~= "function" then return false end
    for _, child in ipairs({ frame:GetChildren() }) do
        if Walk(child, depth - 1) then return true end
    end
    return false
end

local function InstallHook()
    if ns.IsMarked("UI", "ImportExportPageSpacing") then return end
    local Page = _G.ExBoss and _G.ExBoss.UI and _G.ExBoss.UI.Panel
        and _G.ExBoss.UI.Panel.ImportExportPage
    if type(Page) ~= "table" then return end

    -- HookMethodPost, not hooksecurefunc: Render may run inside a LibAsync
    -- coroutine, and hooksecurefunc's C frame breaks its yields.
    if not ns.HookMethodPost("ImportExportPageHooks:Spacing", Page, "Render",
        function(_, contentFrame)
            ns.RunSafe("ImportExportPage:Spacing", function()
                Walk(contentFrame, MAX_DEPTH)
            end)
        end) then
        return
    end
    ns.Mark("UI", "ImportExportPageSpacing")
end

ns.OnAddonLoaded("exboss", InstallHook)
ns.OnPlayerLogin(InstallHook)
