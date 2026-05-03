---@diagnostic disable: undefined-global
-- Five-tier translation resolver, in priority order:
--   (1) Live Blizzard data — only on an enUS client
--   (2) Curated id table  (Translations.Maps / Encounters / Spells)
--   (3) Author-supplied nameEN
--   (4) Locale store entry (the L[...] proxy)
--   (5) Chinese-name fallback table (Translations.*ByZh)
-- Returns nil only when every tier fails, so callers can tell "no
-- translation" apart from "translation == input". Blizzard calls are
-- pcall-wrapped; secret/opaque returns are discarded.

local _, ns = ...

ns.Resolver = ns.Resolver or {}
local R = ns.Resolver

local function NonEmptyString(s)
    if type(s) ~= "string" then return nil end
    if s == "" then return nil end
    return s
end

local function ClientIsEnglish()
    return type(GetLocale) == "function" and GetLocale() == "enUS"
end

local function CallSafe(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, result = pcall(fn, ...)
    if not ok then return nil end
    return result
end

-- ── Maps ────────────────────────────────────────────────────────────────
function R.MapNameByID(mapID)
    mapID = tonumber(mapID)
    if not mapID then return nil end

    -- (2) curated
    local curated = ns.Translations.Maps[mapID]
    if NonEmptyString(curated) then return curated end

    -- (1) live, only on enUS client
    if ClientIsEnglish() and type(C_Map) == "table" then
        local info = CallSafe(C_Map.GetMapInfo, mapID)
        if type(info) == "table" and NonEmptyString(info.name) then
            return info.name
        end
    end

    return nil
end

function R.MapNameByZh(zh)
    zh = NonEmptyString(zh)
    if not zh then return nil end
    return ns.Translations.MapNamesByZh[zh]
end

function R.MapName(mapID, fallbackZh)
    return R.MapNameByID(mapID) or R.MapNameByZh(fallbackZh)
end

-- ── Encounters ──────────────────────────────────────────────────────────
function R.EncounterNameByJournalID(journalID)
    journalID = tonumber(journalID)
    if not journalID then return nil end

    local curated = ns.Translations.Encounters[journalID]
    if NonEmptyString(curated) then return curated end

    if ClientIsEnglish() and type(EJ_GetEncounterInfo) == "function" then
        local name = CallSafe(EJ_GetEncounterInfo, journalID)
        if NonEmptyString(name) then return name end
    end
    return nil
end

function R.EncounterNameByZh(zh)
    zh = NonEmptyString(zh)
    if not zh then return nil end
    return ns.Translations.EncountersByZh[zh]
end

function R.EncounterName(journalID, fallbackZh)
    return R.EncounterNameByJournalID(journalID) or R.EncounterNameByZh(fallbackZh)
end

-- ── Spells ──────────────────────────────────────────────────────────────
function R.SpellNameByID(spellID)
    spellID = tonumber(spellID)
    if not spellID then return nil end

    local curated = ns.Translations.Spells[spellID]
    if NonEmptyString(curated) then return curated end

    if ClientIsEnglish() and type(C_Spell) == "table" then
        local info = CallSafe(C_Spell.GetSpellInfo, spellID)
        if type(info) == "table" and NonEmptyString(info.name) then
            return info.name
        end
    end
    return nil
end

function R.SpellNameByNameEN(nameEN)
    return NonEmptyString(nameEN)
end

function R.SpellNameByZh(zh)
    zh = NonEmptyString(zh)
    if not zh then return nil end
    return ns.Translations.SpellNamesByZh[zh]
end

function R.SpellName(spellID, nameEN, fallbackZh)
    return R.SpellNameByID(spellID)
        or R.SpellNameByNameEN(nameEN)
        or R.SpellNameByZh(fallbackZh)
end

-- ── Voice labels ────────────────────────────────────────────────────────
function R.VoiceLabel(zh)
    zh = NonEmptyString(zh)
    if not zh then return nil end
    return ns.Translations.VoiceLabels[zh]
end

-- ── Event types (display only; eventType remains a scheme key in data) ──
function R.EventTypeDisplay(zh)
    zh = NonEmptyString(zh)
    if not zh then return nil end
    return ns.Translations.EventTypes[zh]
end

-- ── Generic display strings ───────────────────────────────────────────
-- Display-only: rewrites visible UI text that bypassed the locale proxies.
-- Never feeds translated values back into addon storage.
--
-- Hot path — a single panel show can visit hundreds of FontStrings. Both
-- the merged key list and per-text results are memoized; translation tables
-- are static after file load, so the cache stays valid until /reload.
local function SortKeysByLengthDesc(a, b)
    if #a == #b then return a < b end
    return #a > #b
end

local function ReplaceLiteral(text, needle, replacement)
    local startPos, endPos = text:find(needle, 1, true)
    if not startPos then return text, false end

    local out = {}
    local cursor = 1
    while startPos do
        out[#out + 1] = text:sub(cursor, startPos - 1)
        out[#out + 1] = replacement
        cursor = endPos + 1
        startPos, endPos = text:find(needle, cursor, true)
    end
    out[#out + 1] = text:sub(cursor)
    return table.concat(out), true
end

local _displayCache = nil
local _displayResultCache = nil

local function MergeMap(lookup, map)
    if type(map) ~= "table" then return end
    for key, value in pairs(map) do
        if type(key) == "string" and key ~= ""
           and type(value) == "string" and value ~= ""
           and lookup[key] == nil then
            lookup[key] = value
        end
    end
end

local function BuildDisplayCache()
    local moduleStrings = ns.Translations.ModuleStrings or {}
    local mobSpells = ns.Translations.MobSpells or {}
    local lookup = {}
    -- More specific maps first — first writer wins per key.
    MergeMap(lookup, moduleStrings.DisplayText)
    MergeMap(lookup, moduleStrings)
    MergeMap(lookup, mobSpells.MobNames)
    MergeMap(lookup, ns.Translations.VoiceLabels)
    MergeMap(lookup, ns.Translations.ExBossL)
    MergeMap(lookup, ns.Translations.ExwindCoreL)

    local keys = {}
    for k in pairs(lookup) do keys[#keys + 1] = k end
    table.sort(keys, SortKeysByLengthDesc)

    _displayCache = { keys = keys, lookup = lookup }
    _displayResultCache = {}
    return _displayCache
end

-- Rebuild after runtime mutation of ns.Translations.*. Mainly for probes;
-- the addon itself does not mutate translation tables at runtime.
function R.InvalidateDisplayCache()
    _displayCache = nil
    _displayResultCache = nil
end

-- All zh keys contain a byte >= 0x80, so pure-ASCII text never matches.
local function HasHighByte(s)
    for i = 1, #s do
        if s:byte(i) >= 128 then return true end
    end
    return false
end

function R.DisplayText(text)
    if type(text) ~= "string" or text == "" then return text, false end

    local resultCache = _displayResultCache
    if resultCache then
        local memo = resultCache[text]
        if memo == false then return text, false end
        if memo ~= nil then return memo, true end
    end

    if not HasHighByte(text) then
        if resultCache then resultCache[text] = false end
        return text, false
    end

    local cache = _displayCache or BuildDisplayCache()
    resultCache = _displayResultCache

    local exact = cache.lookup[text]
    if type(exact) == "string" and exact ~= "" and exact ~= text then
        resultCache[text] = exact
        return exact, true
    end

    local out = text
    local changed = false
    local keys = cache.keys
    local lookup = cache.lookup
    for i = 1, #keys do
        local key = keys[i]
        if out:find(key, 1, true) then
            local replaced, didReplace = ReplaceLiteral(out, key, lookup[key])
            if didReplace then
                out = replaced
                changed = true
            end
        end
    end

    if changed then
        resultCache[text] = out
        return out, true
    end
    resultCache[text] = false
    return text, false
end

function ns.TranslateDisplayText(text)
    return R.DisplayText(text)
end
