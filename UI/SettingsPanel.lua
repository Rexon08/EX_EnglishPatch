---@diagnostic disable: undefined-global
-- Registers the Settings category with the master enable + a few
-- translation-quality toggles, via the 11.0/12.0 Settings API.

local _, ns = ...

local CATEGORY_NAME = "EX English Patch"

local function HasSettingsAPI()
    return type(Settings) == "table"
        and type(Settings.RegisterVerticalLayoutCategory) == "function"
        and type(Settings.RegisterAddOnCategory) == "function"
        and type(Settings.RegisterAddOnSetting) == "function"
        and type(Settings.CreateCheckbox) == "function"
end

-- pcall-wrapped so any future API tweak downgrades to "no checkbox"
-- rather than a hard error.
local function RegisterCheckbox(category, label, tooltip, variableKey, defaultValue)
    local db = ns.GetDB()
    local setting
    local ok, err = pcall(function()
        setting = Settings.RegisterAddOnSetting(
            category,
            ns.NAME .. "_" .. variableKey, -- variable (unique id)
            variableKey,                   -- variableKey
            db,                            -- variableTbl
            type(defaultValue),            -- variableType
            label,                         -- name (display)
            defaultValue                   -- defaultValue
        )
    end)
    if not ok or not setting then
        ns.Warn("Settings.RegisterAddOnSetting failed for " .. variableKey
            .. ": " .. tostring(err))
        return nil
    end

    if type(Settings.CreateCheckbox) == "function" then
        Settings.CreateCheckbox(category, setting, tooltip)
    end

    setting:SetValueChangedCallback(function(_, value)
        db[variableKey] = value and true or false
    end)
    return setting
end

local function BuildPanel()
    if ns.IsMarked("UI", "SettingsPanel") then return end
    if not HasSettingsAPI() then
        ns.Warn("Settings API unavailable; skipping panel registration")
        return
    end
    ns.Mark("UI", "SettingsPanel")

    local category, layout = Settings.RegisterVerticalLayoutCategory(CATEGORY_NAME)

    -- Header / hint
    if type(layout) == "table" and type(layout.AddInitializer) == "function"
        and type(CreateSettingsListSectionHeaderInitializer) == "function" then
        layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(
            "Translation"))
    end

    RegisterCheckbox(category,
        "Enable English overlay",
        "Master switch. When off, the addon stops translating on the next /reload.",
        "enabled", true)

    RegisterCheckbox(category,
        "Resize widgets to fit English",
        "Adjust label widths on supported pages so longer English text does not clip.",
        "fitWidths", true)

    RegisterCheckbox(category,
        "Show English voice labels",
        "Offer English aliases in voice-label pickers. Existing Chinese-saved selections keep playing.",
        "voiceLabelsEnglish", true)

    Settings.RegisterAddOnCategory(category)
    ns._settingsCategory = category
end

ns.OnPlayerLogin(BuildPanel)

function ns.OpenSettings()
    if type(Settings) ~= "table" then return false end
    if type(Settings.OpenToCategory) ~= "function" then return false end
    if not ns._settingsCategory then return false end
    -- OpenToCategory accepts either the category or its ID depending on
    -- the client build; try ID first, then fall back to the object.
    local id
    if type(ns._settingsCategory.GetID) == "function" then
        id = ns._settingsCategory:GetID()
    end
    local ok = id ~= nil and pcall(Settings.OpenToCategory, id)
    if not ok then pcall(Settings.OpenToCategory, ns._settingsCategory) end
    return true
end

-- Global entry point invoked by the TOC's AddonCompartmentFunc.
function _G.EX_EnglishPatch_OnCompartmentClick()
    if not ns.OpenSettings() then
        if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
            DEFAULT_CHAT_FRAME:AddMessage(
                "|cff66ccff[EX-Patch]|r Open Interface > AddOns > EX English Patch.")
        end
    end
end
