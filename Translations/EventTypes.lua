---@diagnostic disable: undefined-global
-- The four event-type strings consumed by EXBossData's scheme map.
-- Display-only translation — the scheme map still keys off the zh strings.

local _, ns = ...

ns.Translations.EventTypes = {
    ["坦克"] = "Tank",
    ["治疗"] = "Healer",
    ["机制"] = "Mechanic",
    ["其他"] = "Cooldown",
}
