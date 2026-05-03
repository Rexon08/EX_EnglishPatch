---@diagnostic disable: undefined-global
-- Translates display strings inside _G.EXBOSS_ENCOUNTER_DATA.
--
-- Translated in place: mapName, bossName, eventName.
-- NOT translated:
--   eventType  — used as a scheme key (Tank/Healer/Mechanic/Cooldown);
--                rewriting it would make every default fall to "cooldown".
--   voiceLabel — used directly as the LSM sound key; the VoicePack patch
--                wraps the catalog so only the *display* is English.
--
-- Originals are stashed under `_eb_orig_<field>` so TimelineRebuild can
-- re-apply translations without losing source data.

local _, ns = ...

local StashOriginal = ns.Patches.StashOriginal

local function TranslateMapRow(mapID, mapRow)
    if type(mapRow) ~= "table" then return end
    local zh = mapRow.mapName
    StashOriginal(mapRow, "mapName")
    local en = ns.Resolver.MapName(mapID or mapRow.mapID, zh)
    if en then mapRow.mapName = en end
end

local function TranslateBossRow(bossRow)
    if type(bossRow) ~= "table" then return end
    StashOriginal(bossRow, "bossName")
    local en = ns.Resolver.EncounterName(bossRow.journalEncounterID, bossRow.bossName)
    if en then bossRow.bossName = en end
end

local function TranslateEventRow(eventRow)
    if type(eventRow) ~= "table" then return end
    -- Events are 1:1 with a spellID, so route through the spell resolver.
    StashOriginal(eventRow, "eventName")
    local en = ns.Resolver.SpellName(
        eventRow.spellID or eventRow.evenSpellID,
        eventRow.nameEN,
        eventRow.eventName
    )
    if en then eventRow.eventName = en end
end

local function PatchEncounterData()
    if ns.IsMarked("EncounterData") then return end
    local data = _G.EXBOSS_ENCOUNTER_DATA
    if type(data) ~= "table" or type(data.maps) ~= "table" then return end

    local mapCount, bossCount, eventCount = 0, 0, 0
    for mapID, mapRow in pairs(data.maps) do
        TranslateMapRow(mapID, mapRow)
        mapCount = mapCount + 1
        if type(mapRow.bosses) == "table" then
            for _, bossRow in pairs(mapRow.bosses) do
                TranslateBossRow(bossRow)
                bossCount = bossCount + 1
                if type(bossRow.events) == "table" then
                    for _, eventRow in pairs(bossRow.events) do
                        TranslateEventRow(eventRow)
                        eventCount = eventCount + 1
                    end
                end
            end
        end
    end

    ns.Mark("EncounterData")
    ns.Log(string.format("EncounterData: maps=%d bosses=%d events=%d",
        mapCount, bossCount, eventCount))
end

ns.Patches.RegisterPostInit { deps = "exbossdata", apply = PatchEncounterData }

-- Exposed for TimelineRebuild's post-rebuild re-apply.
ns.Patches.PatchEncounterData = PatchEncounterData
