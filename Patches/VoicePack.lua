---@diagnostic disable: undefined-global
-- Voice-label display only.
--
-- 12.1 replaced the per-pack LibSharedMedia registry with a generated
-- manifest: every pack ships the same hashed file names under its own
-- Sounds/ directory, and the engine plays
-- Interface\AddOns\<packAddon>\Sounds\<hash>.ogg directly. Audio is no
-- longer something an overlay can re-point, and it no longer needs to be:
-- upstream ships EXBOSS-ENG (English) beside EXBOSS-EXWIND and falls back
-- to it on English clients on its own.
--
-- What is left for us is the label text. LabelCatalog feeds the label
-- pickers with the manifest's Chinese labels; we map them to English for
-- display, and force English stored values only when the user opted in
-- (so a first-time pick saves an English label).

local _, ns = ...

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

ns.OnAddonLoaded("exboss", WrapLabelCatalog)
ns.OnPlayerLogin(WrapLabelCatalog)
