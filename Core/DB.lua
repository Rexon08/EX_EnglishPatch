---@diagnostic disable: undefined-global
-- Owns EX_EnglishPatchDB: master enable, a few toggles, schema version, and
-- a one-shot migration flag. Translation state is never persisted; the
-- locale overlay lives in memory only.

local _, ns = ...

local CURRENT_SCHEMA = ns.SCHEMA

local DEFAULTS = {
    schema               = CURRENT_SCHEMA,
    enabled              = true,
    fitWidths            = true,
    voiceLabelsEnglish   = true,
    migratedFromOldPatch = false,
}

local function ApplyDefaults(db)
    for key, value in pairs(DEFAULTS) do
        if db[key] == nil then
            db[key] = value
        end
    end
    return db
end

local function MigrateFromOldPatch(db)
    if db.migratedFromOldPatch == true then return end
    local old = rawget(_G, "EXEnglishPatchDB")
    if type(old) == "table" then
        -- Old DB only had `language`; treat anything other than enUS/nil
        -- as "user disabled the patch". The old DB is left in place.
        db.enabled = old.language == nil or tostring(old.language) == "enUS"
    end
    db.migratedFromOldPatch = true
end

function ns.InitDB()
    EX_EnglishPatchDB = type(EX_EnglishPatchDB) == "table" and EX_EnglishPatchDB or {}
    ApplyDefaults(EX_EnglishPatchDB)
    if tonumber(EX_EnglishPatchDB.schema) ~= CURRENT_SCHEMA then
        EX_EnglishPatchDB.schema = CURRENT_SCHEMA
    end
    MigrateFromOldPatch(EX_EnglishPatchDB)
    ns.db = EX_EnglishPatchDB
    return ns.db
end

function ns.GetDB()
    if ns.db then return ns.db end
    return ns.InitDB()
end

function ns.IsEnabled()
    local db = ns.GetDB()
    return db.enabled == true
end
