---@diagnostic disable: undefined-global
-- Translates display fields in the M+ Spell Info store at _G.EXSP.
--
-- Translated:
--   EXSP.TagDefs[*].name           — spell-row tag pills.
--   EXSP.Database[d][m].type       — creature type line under mob name.
--   EXSP.DungeonAbbr[zh]           — label under each dungeon tab icon.
--
-- NOT translated: EXSP.Database keys — the UI and search box use them
-- as lookup indices. UI/MobSpellsHooks paints English over the display.

local _, ns = ...

local StashOriginal = ns.Patches.StashOriginal

local function TranslateField(row, field, map)
    if type(row) ~= "table" then return end
    local zh = row[field]
    if type(zh) ~= "string" or zh == "" then return end
    local en = map[zh]
    if type(en) == "string" and en ~= "" then
        StashOriginal(row, field)
        row[field] = en
    end
end

local function PatchMobSpells()
    if ns.IsMarked("MobSpellsData") then return end
    local EXSP = _G.EXSP
    if type(EXSP) ~= "table" then return end

    local mob = ns.Translations.MobSpells

    local tagsCount, dbCount, abbrCount = 0, 0, 0

    -- Tag display names
    if type(EXSP.TagDefs) == "table" then
        for _, def in pairs(EXSP.TagDefs) do
            if type(def) == "table" then
                local before = def.name
                TranslateField(def, "name", mob.TagNames)
                if def.name ~= before then tagsCount = tagsCount + 1 end
            end
        end
    end

    -- Creature type strings (mob.type field)
    if type(EXSP.Database) == "table" then
        for _, dungeonRow in pairs(EXSP.Database) do
            if type(dungeonRow) == "table" then
                for _, mobRow in pairs(dungeonRow) do
                    if type(mobRow) == "table" then
                        local before = mobRow.type
                        TranslateField(mobRow, "type", mob.CreatureTypes)
                        if mobRow.type ~= before then dbCount = dbCount + 1 end
                    end
                end
            end
        end
    end

    -- Dungeon abbreviations: keys are zh (lookup indices, leave intact);
    -- only values are translated. Originals stashed in a sibling table to
    -- keep DungeonAbbr's iteration order clean.
    if type(EXSP.DungeonAbbr) == "table" then
        EXSP._eb_orig_DungeonAbbr = EXSP._eb_orig_DungeonAbbr or {}
        for zhKey, zhValue in pairs(EXSP.DungeonAbbr) do
            local en = mob.DungeonAbbr[zhValue]
            if type(en) == "string" and en ~= "" then
                if EXSP._eb_orig_DungeonAbbr[zhKey] == nil then
                    EXSP._eb_orig_DungeonAbbr[zhKey] = zhValue
                end
                EXSP.DungeonAbbr[zhKey] = en
                abbrCount = abbrCount + 1
            end
        end
    end

    ns.Mark("MobSpellsData")
    ns.Log(string.format("MobSpellsData: tags=%d types=%d abbr=%d",
        tagsCount, dbCount, abbrCount))
end

-- EXSP is populated by an ExwindTools submodule; tables exist by ADDON_LOADED.
ns.Patches.RegisterPostInit {
    deps  = "exwindtools",
    login = true,
    apply = PatchMobSpells,
}

ns.Patches.MobSpellsData = PatchMobSpells
