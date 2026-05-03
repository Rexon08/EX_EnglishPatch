---@diagnostic disable: undefined-global
-- EXBossData rebuilds ExBoss.Timeline._bosses from EXBOSS_ENCOUNTER_DATA.
-- We re-apply translations before each rebuild, wrap the public rebuild
-- function so /reload and profile-switch callers get the same treatment,
-- and call TouchEventConfig() afterward to drop cached scheme/voice
-- lookups built off the old strings.

local _, ns = ...

local function ApplyDataPatchesIfNeeded()
    -- Each patch is marker-guarded; calling them again is a no-op.
    if ns.Patches.PatchEncounterData    then ns.Patches.PatchEncounterData() end
    if ns.Patches.PatchPrivateAuraData  then ns.Patches.PatchPrivateAuraData() end
    if ns.Patches.PatchTrashCDData      then ns.Patches.PatchTrashCDData() end
    if ns.Patches.PatchTrashCDPreset    then ns.Patches.PatchTrashCDPreset() end
end

local function HookRebuildTimeline()
    if ns.IsMarked("Timeline", "RebuildHook") then return end
    if type(_G.EXBossData) ~= "table"
       or type(_G.EXBossData.RebuildTimelineBosses) ~= "function" then
        return
    end

    -- Replace the published function with a wrapper that pre-translates,
    -- calls the original, then refreshes the event-config cache.
    local original = _G.EXBossData.RebuildTimelineBosses
    _G.EXBossData.RebuildTimelineBosses = function(...)
        ApplyDataPatchesIfNeeded()
        local ok, err = pcall(original, ...)
        if not ok then
            ns.Warn("RebuildTimelineBosses original errored: " .. tostring(err))
        end
        if type(_G.EXBossData.TouchEventConfig) == "function" then
            pcall(_G.EXBossData.TouchEventConfig)
        end
    end

    ns.Mark("Timeline", "RebuildHook")
    ns.Log("Timeline: wrapped EXBossData.RebuildTimelineBosses")
end

local function FirstRebuildPass()
    if ns.IsMarked("Timeline", "FirstPass") then return end
    ApplyDataPatchesIfNeeded()
    if type(_G.EXBossData) == "table" then
        if type(_G.EXBossData.RebuildTimelineBosses) == "function" then
            pcall(_G.EXBossData.RebuildTimelineBosses)
        end
        if type(_G.EXBossData.TouchEventConfig) == "function" then
            pcall(_G.EXBossData.TouchEventConfig)
        end
    end
    ns.Mark("Timeline", "FirstPass")
    ns.Log("Timeline: first translation+rebuild pass complete")
end

ns.OnAddonLoaded("exbossdata", function()
    -- EXBossData has already rebuilt synchronously at file load. Just
    -- install the wrapper here; the translated rebuild fires at PEW.
    HookRebuildTimeline()
end)

ns.OnPlayerEnteringWorld(function(firstPEW)
    if not firstPEW then return end
    HookRebuildTimeline()
    FirstRebuildPass()
end)
