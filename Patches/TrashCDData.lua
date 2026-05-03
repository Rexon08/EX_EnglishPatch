---@diagnostic disable: undefined-global
-- Translates display strings in _G.EXBOSS_TRASH_CD_DATA. Spell rows have
-- an authoritative `nameEN` field; mob names rely on the curated zh→en
-- map and are left Chinese when no curated entry exists.

local _, ns = ...

local StashOriginal = ns.Patches.StashOriginal

local function TranslateMapRow(mapID, mapRow)
    if type(mapRow) ~= "table" then return end
    StashOriginal(mapRow, "mapName")
    local en = ns.Resolver.MapName(mapID or mapRow.mapID, mapRow.mapName)
    if en then mapRow.mapName = en end
end

local function TranslateMobRow(mobRow)
    if type(mobRow) ~= "table" then return end
    StashOriginal(mobRow, "name")
    -- Mobs have no nameEN; rely on the curated zh→en table.
    local en = ns.Resolver.SpellNameByZh(mobRow.name)
    if en then mobRow.name = en end
end

local function TranslateSpellRow(spellRow)
    if type(spellRow) ~= "table" then return end
    StashOriginal(spellRow, "name")
    local en = ns.Resolver.SpellName(spellRow.spellID, spellRow.nameEN, spellRow.name)
    if en then spellRow.name = en end
end

local function PatchTrashCDData()
    if ns.IsMarked("TrashCDData") then return end
    local data = _G.EXBOSS_TRASH_CD_DATA
    if type(data) ~= "table" then return end

    local maps, mobs, spells = 0, 0, 0
    for mapID, mapRow in pairs(data) do
        TranslateMapRow(mapID, mapRow)
        maps = maps + 1
        if type(mapRow.mobs) == "table" then
            for _, mobRow in pairs(mapRow.mobs) do
                TranslateMobRow(mobRow)
                mobs = mobs + 1
                if type(mobRow.spells) == "table" then
                    for _, spellRow in pairs(mobRow.spells) do
                        TranslateSpellRow(spellRow)
                        spells = spells + 1
                    end
                end
            end
        end
    end

    ns.Mark("TrashCDData")
    ns.Log(string.format("TrashCDData: maps=%d mobs=%d spells=%d", maps, mobs, spells))
end

ns.Patches.RegisterPostInit { deps = "exbossdata", apply = PatchTrashCDData }

ns.Patches.PatchTrashCDData = PatchTrashCDData
