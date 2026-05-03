---@diagnostic disable: undefined-global
-- Translates display strings in _G.EXBOSS_TRASH_CD_PRESET.
--
-- Translated:
--   customName, timerBarName  — UI display, not used as keys.
-- NOT translated:
--   voice1Label, voice2Label  — LSM sound keys (handled at the catalog).
--   countdownText             — spoken cue text; safest left as-is.
--   mechanismOption, bossStages — internal scheme/storage keys.

local _, ns = ...

local StashOriginal = ns.Patches.StashOriginal

local function TranslateLabelField(row, field)
    if type(row) ~= "table" then return end
    local zh = row[field]
    if type(zh) ~= "string" or zh == "" then return end
    local en = ns.Resolver.VoiceLabel(zh)
    if en then
        StashOriginal(row, field)
        row[field] = en
    end
end

local function PatchTrashCDPreset()
    if ns.IsMarked("TrashCDPreset") then return end
    local data = _G.EXBOSS_TRASH_CD_PRESET
    if type(data) ~= "table" then return end

    local rows = 0
    for _, mapRow in pairs(data) do
        if type(mapRow) == "table" then
            for _, mobRow in pairs(mapRow) do
                if type(mobRow) == "table" then
                    for _, spellRow in pairs(mobRow) do
                        if type(spellRow) == "table" then
                            rows = rows + 1
                            TranslateLabelField(spellRow, "customName")
                            TranslateLabelField(spellRow, "timerBarName")
                        end
                    end
                end
            end
        end
    end

    ns.Mark("TrashCDPreset")
    ns.Log("TrashCDPreset: rows=" .. rows)
end

ns.Patches.RegisterPostInit { deps = "exbossdata", apply = PatchTrashCDPreset }

ns.Patches.PatchTrashCDPreset = PatchTrashCDPreset
