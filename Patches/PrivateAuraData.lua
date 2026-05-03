---@diagnostic disable: undefined-global
-- Translates display strings in _G.EXBOSS_PRIVATE_AURA_DATA.
--
-- Some boss rows ship as "<zh-name> (English)" — we extract the parens.
-- Otherwise route through the Encounters/Spells curated tables.
-- `sources` already holds English creature names; left as-is.

local _, ns = ...

local StashOriginal = ns.Patches.StashOriginal

local function ExtractParenEnglish(s)
    if type(s) ~= "string" then return nil end
    -- "<zh-name> (English)" → "English".
    local en = s:match("%(([^()]+)%)%s*$")
    if en and en ~= "" then return en end
    return nil
end

local function TranslateBossField(row)
    if type(row) ~= "table" then return end
    StashOriginal(row, "boss")
    local paren = ExtractParenEnglish(row.boss)
    if paren then
        row.boss = paren
        return
    end
    local en = ns.Resolver.EncounterName(row.encounterID, row.boss)
    if en then row.boss = en end
end

local function TranslateDungeonField(row)
    if type(row) ~= "table" then return end
    StashOriginal(row, "dungeon")
    local en = ns.Resolver.MapNameByZh(row.dungeon)
    if en then row.dungeon = en end
end

local function TranslateSpellRow(spellRow)
    if type(spellRow) ~= "table" then return end
    StashOriginal(spellRow, "name")
    local en = ns.Resolver.SpellName(spellRow.spellID, nil, spellRow.name)
    if en then spellRow.name = en end
end

local function PatchPrivateAuraData()
    if ns.IsMarked("PrivateAuraData") then return end
    local data = _G.EXBOSS_PRIVATE_AURA_DATA
    if type(data) ~= "table" then return end

    local rows, spells = 0, 0
    for _, scope in pairs(data) do
        if type(scope) == "table" then
            for _, encounterRow in pairs(scope) do
                if type(encounterRow) == "table" then
                    rows = rows + 1
                    TranslateDungeonField(encounterRow)
                    TranslateBossField(encounterRow)
                    if type(encounterRow.spells) == "table" then
                        for _, spellRow in pairs(encounterRow.spells) do
                            TranslateSpellRow(spellRow)
                            spells = spells + 1
                        end
                    end
                end
            end
        end
    end

    ns.Mark("PrivateAuraData")
    ns.Log(string.format("PrivateAuraData: rows=%d spells=%d", rows, spells))
end

ns.Patches.RegisterPostInit { deps = "exbossdata", apply = PatchPrivateAuraData }

ns.Patches.PatchPrivateAuraData = PatchPrivateAuraData
