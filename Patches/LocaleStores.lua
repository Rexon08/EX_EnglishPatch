---@diagnostic disable: undefined-global
-- (1) Merge additive enUS entries into ExwindLocale and ExBoss.Locale.
-- (2) Force the in-memory locale to enUS without writing to any user DB.
--     ExwindLocale.SetCurrentLocale is non-persisting, so we use it.
--     ExBoss:SetLocaleMode would write to ExBossDB; we bypass it and
--     poke ExBoss.Locale._currentLocale directly.

local _, ns = ...

local function MergeStore(store, additions)
    if type(store) ~= "table" or type(additions) ~= "table" then return 0 end
    local count = 0
    for key, value in pairs(additions) do
        if type(key) == "string" and key ~= ""
           and (type(value) == "string" or type(value) == "number") then
            if store[key] ~= value then
                store[key] = value
                count = count + 1
            end
        end
    end
    return count
end

-- ExwindCore + ExwindTools share ExwindLocale.
local function PatchExwindLocale()
    if ns.IsMarked("Locale", "Exwind") then return end
    if type(_G.ExwindLocale) ~= "table" then return end
    local stores = _G.ExwindLocale._stores
    if type(stores) ~= "table" then return end
    stores.enUS = type(stores.enUS) == "table" and stores.enUS or {}
    local n = MergeStore(stores.enUS, ns.Translations.ExwindCoreL)
    ns.Mark("Locale", "Exwind")
    ns.Log("Locale: merged " .. n .. " enUS entries into ExwindLocale")
end

-- EXBoss has its own locale root.
local function PatchExBossLocale()
    if ns.IsMarked("Locale", "EXBoss") then return end
    if type(_G.ExBoss) ~= "table" or type(_G.ExBoss.Locale) ~= "table" then return end
    local stores = _G.ExBoss.Locale._stores
    if type(stores) ~= "table" then return end
    stores.enUS = type(stores.enUS) == "table" and stores.enUS or {}
    local n = MergeStore(stores.enUS, ns.Translations.ExBossL)
    ns.Mark("Locale", "EXBoss")
    ns.Log("Locale: merged " .. n .. " enUS entries into ExBoss.Locale")
end

-- Force the in-memory locale to enUS. Both addons fall back to the raw
-- key on a missing translation, so a partial enUS store is safe.
local function ForceEnUS()
    if ns.IsMarked("Locale", "Force") then return end

    -- ExwindLocale exposes a non-persisting setter.
    if type(_G.ExwindLocale) == "table"
       and type(_G.ExwindLocale.SetCurrentLocale) == "function" then
        local ok, err = pcall(_G.ExwindLocale.SetCurrentLocale, "enUS")
        if not ok then ns.Warn("ExwindLocale.SetCurrentLocale failed: " .. tostring(err)) end
    end

    -- ExBoss.Locale's only setter (SetLocaleMode) writes to ExBossDB,
    -- so we poke the private field directly to avoid persisting.
    if type(_G.ExBoss) == "table" and type(_G.ExBoss.Locale) == "table" then
        _G.ExBoss.Locale._currentLocale = "enUS"
    end

    ns.Mark("Locale", "Force")
    ns.Log("Locale: forced in-memory locale to enUS without DB write")
end

ns.OnAddonLoaded("exwindcore", PatchExwindLocale)
ns.OnAddonLoaded("exwindtools", PatchExwindLocale)
ns.OnAddonLoaded("exboss", PatchExBossLocale)

-- Force enUS at PLAYER_LOGIN, after every dep's saved-variable init.
ns.OnPlayerLogin(function()
    PatchExwindLocale()
    PatchExBossLocale()
    ForceEnUS()
end)
