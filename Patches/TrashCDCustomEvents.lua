---@diagnostic disable: undefined-global
-- Translates display fields on rows registered through
-- ExBoss.TrashCD.CustomEvents. These rows live outside
-- _G.EXBOSS_TRASH_CD_DATA, so TrashCDData.lua never sees them.
--
-- Translated:
--   _rowsByMap[*][*]: mobName, spellName, customTriggerLabel, description
--   _defsByKey[*]:    mobName, spellName, triggerLabel,        description
--   _mapsByID[*]:     mapName
--
-- The trigger-label values and the description fallback come from
-- upstream BuildTriggerLabel and never route through L[...]. We pull
-- their translations from ns.Translations.ExBossL so the strings stay
-- in Translations/ (Han bytes are not permitted here).

local _, ns = ...

local StashOriginal = ns.Patches.StashOriginal

local function LookupExBossL(zh)
    if type(zh) ~= "string" or zh == "" then return nil end
    local store = ns.Translations.ExBossL
    if type(store) ~= "table" then return nil end
    local en = store[zh]
    if type(en) == "string" and en ~= "" and en ~= zh then
        return en
    end
    return nil
end

local function TranslateField(row, field, lookup)
    if type(row) ~= "table" then return end
    local zh = row[field]
    local en = lookup(zh)
    if en then
        StashOriginal(row, field)
        row[field] = en
    end
end

local function TranslateMobName(row, field)
    TranslateField(row, field, function(zh)
        if type(zh) ~= "string" or zh == "" then return nil end
        local mod = ns.Translations.ModuleStrings
        local en = mod and mod[zh] or nil
        if type(en) == "string" and en ~= "" and en ~= zh then
            return en
        end
        return ns.Resolver.SpellNameByZh(zh)
    end)
end

local function TranslateSpellName(row, idField, nameField)
    if type(row) ~= "table" then return end
    local zh = row[nameField]
    local en = ns.Resolver.SpellName(row[idField], nil, zh)
    if type(en) == "string" and en ~= "" and en ~= zh then
        StashOriginal(row, nameField)
        row[nameField] = en
    end
end

local function TranslateMapName(row, field, mapID)
    if type(row) ~= "table" then return end
    local en = ns.Resolver.MapName(mapID, row[field])
    if type(en) == "string" and en ~= "" and en ~= row[field] then
        StashOriginal(row, field)
        row[field] = en
    end
end

-- Description is a rendered template ("…<triggerLabel>…"). Run it
-- through DisplayText so any zh substrings present in our caches
-- (trigger labels, sentence fragments added to ExBossL) get rewritten.
local function TranslateDescription(row)
    if type(row) ~= "table" then return end
    local zh = row.description
    if type(zh) ~= "string" or zh == "" then return end
    local out, changed = ns.Resolver.DisplayText(zh)
    if changed and out ~= zh then
        StashOriginal(row, "description")
        row.description = out
    end
end

local function PatchCustomEvents()
    if ns.IsMarked("TrashCDCustomEvents") then return end
    local CE = _G.ExBoss and _G.ExBoss.TrashCD and _G.ExBoss.TrashCD.CustomEvents or nil
    if type(CE) ~= "table" then return end

    local rows, defs, maps = 0, 0, 0

    if type(CE._rowsByMap) == "table" then
        for _, mapRows in pairs(CE._rowsByMap) do
            if type(mapRows) == "table" then
                for _, row in ipairs(mapRows) do
                    TranslateMobName(row, "mobName")
                    TranslateSpellName(row, "spellID", "spellName")
                    TranslateField(row, "customTriggerLabel", LookupExBossL)
                    TranslateDescription(row)
                    rows = rows + 1
                end
            end
        end
    end

    if type(CE._defsByKey) == "table" then
        for _, def in pairs(CE._defsByKey) do
            TranslateMobName(def, "mobName")
            TranslateSpellName(def, "spellID", "spellName")
            TranslateField(def, "triggerLabel", LookupExBossL)
            TranslateDescription(def)
            defs = defs + 1
        end
    end

    if type(CE._mapsByID) == "table" then
        for mapID, mapRow in pairs(CE._mapsByID) do
            TranslateMapName(mapRow, "mapName", mapID)
            maps = maps + 1
        end
    end

    ns.Mark("TrashCDCustomEvents")
    ns.Log(string.format("TrashCDCustomEvents: rows=%d defs=%d maps=%d", rows, defs, maps))
end

-- Encounter files register their custom events at ADDON_LOADED for
-- exboss; PEW catches anything registered later in the load sequence.
ns.Patches.RegisterPostInit {
    deps  = "exboss",
    login = true,
    apply = PatchCustomEvents,
}

ns.Patches.PatchTrashCDCustomEvents = PatchCustomEvents
