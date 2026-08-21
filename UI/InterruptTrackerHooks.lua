---@diagnostic disable: undefined-global
-- Refits per-player interrupt CD bar labels, which carry class/spell text
-- that is wider in English. Gated by the master fitWidths preference.
--
-- Deliberately inert on 12.1 builds: upstream renamed the anchor to
-- `ExBossInterruptTrackerAnchor` and moved the bars onto EXUI Collections,
-- which size themselves. Do NOT just re-point the global -- the party and
-- self rows now render their name in SECRET mode, and UI_FitWidth calls
-- GetStringWidth() on that FontString, which is a secret-value trap in
-- combat. The lookup below stays on the old name so the scan no-ops until
-- a Collection-safe fit exists.

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
