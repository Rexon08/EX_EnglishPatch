---@diagnostic disable: undefined-global
-- The InterruptTracker module attaches per-player CD bars to the global
-- anchor `ExInterruptTrackerAnchor`. Bar labels carry class/spell text
-- that's wider in English, so we refit each bar's FontString once the
-- anchor has children. Gated by the master fitWidths preference.

local _, ns = ...

local FIT_OPTS = { padding = 10, maxWidth = 180 }

local function FitTrackerBars()
    if not ns.GetDB().fitWidths then return end
    local anchor = _G.ExInterruptTrackerAnchor
    if type(anchor) ~= "table" or type(anchor.GetChildren) ~= "function" then
        return
    end
    for _, bar in ipairs({ anchor:GetChildren() }) do
        if type(bar) == "table" and type(bar.GetRegions) == "function" then
            for _, region in ipairs({ bar:GetRegions() }) do
                if type(region) == "table"
                   and type(region.GetObjectType) == "function"
                   and region:GetObjectType() == "FontString" then
                    ns.UI_FitWidth(region, FIT_OPTS)
                end
            end
        end
    end
end

local function Schedule()
    if ns.IsMarked("UI", "InterruptTracker") then return end
    ns.Mark("UI", "InterruptTracker")
    -- Anchor is created at module init; wait until first PEW to scan,
    -- by which point the module has populated bars.
end

ns.OnPlayerLogin(Schedule)
ns.OnPlayerEnteringWorld(function(firstPEW)
    if firstPEW then
        ns.RunSafe("InterruptTracker:FitBars", FitTrackerBars)
    end
end)
ns.OnRegenEnabled(function()
    ns.RunSafe("InterruptTracker:FitBars:postCombat", FitTrackerBars)
end)
