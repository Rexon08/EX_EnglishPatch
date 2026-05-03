---@diagnostic disable: undefined-global
-- (1a) Re-point each [<DefaultPack>]<zhLabel> LSM hash entry at our
--      bundled English .ogg. The user's stored selectedVoicePack name is
--      untouched, so the default pack just starts playing English audio.
-- (1b) Register English-label aliases on the same pack pointing at the
--      same files, so a user who picks the wrapped catalog's English
--      labels still resolves to audio.
-- (2)  Wrap LabelCatalog.GetStandardLabels/GetPackLabels/GetDropdownItems
--      so display labels and stored values can be English.
-- (3)  Register a "Causese English" pack as a selectable option. When
--      SharedMedia_Causese is loaded its files back the keys; otherwise
--      our bundled copies. On a fresh ExBossDB we flip the user's pick
--      once, gated by a one-shot flag so deliberate picks aren't clobbered.

local _, ns = ...

local SOUND_BASE = "Interface\\AddOns\\EX_EnglishPatch\\sound\\"

local CAUSESE_PACK_NAME = "Causese English"
local CAUSESE_ADDON     = "SharedMedia_Causese"
local CAUSESE_BASE      = "Interface\\AddOns\\SharedMedia_Causese\\sound\\"

-- Pack name lives in the translations module (the only file allowed to
-- carry zh-encoded literals).
local function DefaultPackName()
    return ns.Translations.VoicePackName or "EXWIND"
end

local function GetLSM()
    if not LibStub then return nil end
    return LibStub("LibSharedMedia-3.0", true)
end

-- (1a) ───────────────────────────────────────────────────────────────────
local function OverrideDefaultPackToEnglish()
    if ns.IsMarked("Voice", "DefaultPackEnglish") then return end
    local LSM = GetLSM()
    if not LSM or type(LSM.HashTable) ~= "function" then return end
    local sounds = LSM:HashTable("sound")
    if type(sounds) ~= "table" then return end

    local prefix = "[" .. DefaultPackName() .. "]"
    local files  = ns.Translations.VoiceFileByLabel or {}
    local rewritten, missing = 0, 0

    for zh, file in pairs(files) do
        local key  = prefix .. zh
        local path = SOUND_BASE .. file
        if sounds[key] ~= nil then
            sounds[key] = path
            rewritten = rewritten + 1
        else
            -- Label is in our map but not in the source pack — register it.
            if type(LSM.Register) == "function" then
                pcall(LSM.Register, LSM, "sound", key, path)
            else
                sounds[key] = path
            end
            missing = missing + 1
        end
    end

    ns.Mark("Voice", "DefaultPackEnglish")
    ns.Log(string.format("Voice: pointed %d default-pack labels at English audio (+%d added)",
        rewritten, missing))
end

-- (1b) ───────────────────────────────────────────────────────────────────
local function RegisterEnglishAliases()
    if ns.IsMarked("Voice", "LSMAliases") then return end
    local LSM = GetLSM()
    if not LSM then return end
    if type(LSM.HashTable) ~= "function" or type(LSM.Register) ~= "function" then return end

    local sounds = LSM:HashTable("sound")
    if type(sounds) ~= "table" then return end

    local prefix    = "[" .. DefaultPackName() .. "]"
    local files     = ns.Translations.VoiceFileByLabel or {}
    local registered, skippedDup = 0, 0

    for zh, en in pairs(ns.Translations.VoiceLabels) do
        local file = files[zh]
        if file then
            local enKey = prefix .. en
            local path  = SOUND_BASE .. file
            if sounds[enKey] == nil then
                local ok = pcall(LSM.Register, LSM, "sound", enKey, path)
                if ok then registered = registered + 1 end
            else
                -- Already present (en label collides with a zh label) —
                -- repoint at our English file regardless.
                sounds[enKey] = path
                skippedDup = skippedDup + 1
            end
        end
    end

    ns.Mark("Voice", "LSMAliases")
    ns.Log(string.format("Voice: registered %d EN aliases (refreshed %d existing)",
        registered, skippedDup))
end

-- (2) ────────────────────────────────────────────────────────────────────
local function MapLabelsToEnglish(labels)
    if type(labels) ~= "table" then return labels end
    local out = {}
    local seen = {}
    for i = 1, #labels do
        local label = labels[i]
        local en = ns.Translations.VoiceLabels[label] or label
        if not seen[en] then
            seen[en] = true
            out[#out + 1] = en
        end
    end
    return out
end

local function PreferEnglish()
    return ns.IsEnabled() and ns.GetDB().voiceLabelsEnglish == true
end

local function WrapLabelCatalog()
    if ns.IsMarked("Voice", "CatalogWrap") then return end
    if type(_G.ExBoss) ~= "table"
       or type(_G.ExBoss.Voice) ~= "table"
       or type(_G.ExBoss.Voice.LabelCatalog) ~= "table" then
        return
    end
    local Catalog = _G.ExBoss.Voice.LabelCatalog

    local origGetStandard = Catalog.GetStandardLabels
    local origGetPack     = Catalog.GetPackLabels
    local origGetDropdown = Catalog.GetDropdownItems

    if type(origGetStandard) ~= "function"
       or type(origGetPack) ~= "function"
       or type(origGetDropdown) ~= "function" then
        return
    end

    Catalog.GetStandardLabels = function(...)
        local labels = origGetStandard(...)
        if PreferEnglish() then
            return MapLabelsToEnglish(labels)
        end
        return labels
    end

    Catalog.GetPackLabels = function(...)
        local labels = origGetPack(...)
        if PreferEnglish() then
            return MapLabelsToEnglish(labels)
        end
        return labels
    end

    -- Source's GetDropdownItems already routes display through ExBoss.L
    -- (so the locale-store merge gives English text), but the stored
    -- value would still be Chinese. Force English values when the pref
    -- is on so first-time picks save English. Existing saved Chinese
    -- values are left alone — we never write the DB.
    Catalog.GetDropdownItems = function(...)
        local items = origGetDropdown(...)
        if not PreferEnglish() then return items end
        if type(items) ~= "table" then return items end
        local out = {}
        local seen = {}
        for i = 1, #items do
            local row = items[i]
            if type(row) == "table" then
                local zh = row[2]
                local en = ns.Translations.VoiceLabels[zh] or zh
                if not seen[en] then
                    seen[en] = true
                    out[#out + 1] = { en, en }
                end
            end
        end
        if #out == 0 then
            out[1] = { "(no labels)", "" }
        end
        return out
    end

    ns.Mark("Voice", "CatalogWrap")
    ns.Log("Voice: wrapped LabelCatalog GetStandardLabels/GetPackLabels/GetDropdownItems")
end

-- (3) ────────────────────────────────────────────────────────────────────
local function CauseseAddonLoaded()
    return ns.IsAddOnLoaded and ns.IsAddOnLoaded(CAUSESE_ADDON) == true
end

local function ChooseCauseseBase()
    if CauseseAddonLoaded() then return CAUSESE_BASE end
    return SOUND_BASE
end

local function RegisterCausesePack()
    if ns.IsMarked("Voice", "CausesePack") then return end
    local LSM = GetLSM()
    if not LSM
       or type(LSM.HashTable) ~= "function"
       or type(LSM.Register) ~= "function" then
        return
    end
    local sounds = LSM:HashTable("sound")
    if type(sounds) ~= "table" then return end

    local prefix    = "[" .. CAUSESE_PACK_NAME .. "]"
    local soundBase = ChooseCauseseBase()
    local files     = ns.Translations.VoiceFileByLabel or {}
    local registered, refreshed = 0, 0

    for zh, file in pairs(files) do
        local key  = prefix .. zh
        local path = soundBase .. file
        if sounds[key] == nil then
            local ok = pcall(LSM.Register, LSM, "sound", key, path)
            if ok then registered = registered + 1 end
        else
            sounds[key] = path
            refreshed = refreshed + 1
        end
    end
    -- English-label aliases so picks made under this pack still play audio.
    for zh, en in pairs(ns.Translations.VoiceLabels or {}) do
        local file = files[zh]
        if file then
            local enKey = prefix .. en
            local path  = soundBase .. file
            if sounds[enKey] == nil then
                pcall(LSM.Register, LSM, "sound", enKey, path)
            else
                sounds[enKey] = path
            end
        end
    end

    ns.Mark("Voice", "CausesePack")
    ns.Log(string.format(
        "Voice: registered Causese English pack (%d labels, +%d refreshed, source=%s)",
        registered, refreshed,
        CauseseAddonLoaded() and "SharedMedia_Causese" or "EX_EnglishPatch"))
end

-- One-shot default-pack flip on a fresh ExBossDB: the EXWIND zh-default
-- placeholder means the user has never picked, so we switch to Causese
-- English. Gated by a DB flag so later deliberate picks aren't overridden.
local function ApplyCauseseDefault()
    local db = ns.GetDB()
    if db.causeseDefaultApplied == true then return end

    _G.ExBossDB = type(_G.ExBossDB) == "table" and _G.ExBossDB or {}
    _G.ExBossDB.voice = _G.ExBossDB.voice or {}
    _G.ExBossDB.voice.global = _G.ExBossDB.voice.global or {}
    local g = _G.ExBossDB.voice.global

    local placeholder = ns.Translations.VoicePackName or "EXWIND"
    if g.selectedVoicePack == nil or g.selectedVoicePack == placeholder then
        g.selectedVoicePack = CAUSESE_PACK_NAME
        local engine = _G.ExBoss and _G.ExBoss.Voice and _G.ExBoss.Voice.Engine
        if engine and type(engine.InvalidateLabelCache) == "function" then
            pcall(engine.InvalidateLabelCache, engine)
        end
        ns.Log("Voice: defaulted selectedVoicePack to Causese English")
    end
    db.causeseDefaultApplied = true
end

-- All packs have populated LSM by PLAYER_LOGIN. Override first, then
-- alias — so aliases point at our English files, not the originals.
ns.OnPlayerLogin(function()
    OverrideDefaultPackToEnglish()
    RegisterEnglishAliases()
    RegisterCausesePack()
    ApplyCauseseDefault()
    WrapLabelCatalog()
    -- Drop the engine's cached label→pack lookups so next play hits us.
    local engine = _G.ExBoss and _G.ExBoss.Voice and _G.ExBoss.Voice.Engine
    if engine and type(engine.InvalidateLabelCache) == "function" then
        pcall(engine.InvalidateLabelCache, engine)
    end
end)

ns.OnAddonLoaded("exboss-exwind", function()
    OverrideDefaultPackToEnglish()
    RegisterEnglishAliases()
    RegisterCausesePack()
end)
ns.OnAddonLoaded("exboss", WrapLabelCatalog)
