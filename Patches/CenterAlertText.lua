---@diagnostic disable: undefined-global
-- Pins center-screen notification text to English at the last possible
-- moment, after the presentation layer's resolver chain
-- (TimelinePresentation:Resolve / ResolveLinkedTextFields /
-- ResolveDefaultCentralText) has pulled from saved DB values, voice
-- triggers, or timer.displayName. The data-layer EncounterData pass
-- can't reach those sources; this is the catch-all display seam.

local _, ns = ...

local function TranslateString(s)
    if type(s) ~= "string" or s == "" then return s end
    local out = ns.Resolver.DisplayText(s)
    if type(out) == "string" and out ~= "" then return out end
    return s
end

-- ShowCountdown re-fires every 0.1s display tick during combat; translate
-- first and clone only on an actual change (memoized, so the common case
-- after the first tick allocates nothing).
local function ClonePayloadWithText(payload)
    if type(payload) ~= "table" then return payload end
    local newText, newLabel
    if type(payload.text) == "string" then
        local t = TranslateString(payload.text)
        if t ~= payload.text then newText = t end
    end
    if type(payload.label) == "string" then
        local t = TranslateString(payload.label)
        if t ~= payload.label then newLabel = t end
    end
    if newText == nil and newLabel == nil then return payload end
    local out = {}
    for k, v in pairs(payload) do out[k] = v end
    if newText ~= nil then out.text = newText end
    if newLabel ~= nil then out.label = newLabel end
    return out
end

-- FlashText:Show / FlashTextMedium:Show: explicit `text` arg wins,
-- otherwise payload.text (medium only).
local function WrapShow(target, scopeKey)
    if type(target) ~= "table" or type(target.Show) ~= "function" then return end
    if ns.IsMarked("CenterAlert", scopeKey .. ":Show") then return end
    local original = target.Show
    target.Show = function(self, payload, text, duration, ...)
        local newText = text
        if type(text) == "string" then
            newText = TranslateString(text)
        end
        local newPayload = ClonePayloadWithText(payload)
        return original(self, newPayload, newText, duration, ...)
    end
    ns.Mark("CenterAlert", scopeKey .. ":Show")
end

-- ShowCountdown drives per-tick "<label> <time>" repaints.
local function WrapShowCountdown(target, scopeKey)
    if type(target) ~= "table" or type(target.ShowCountdown) ~= "function" then return end
    if ns.IsMarked("CenterAlert", scopeKey .. ":ShowCountdown") then return end
    local original = target.ShowCountdown
    target.ShowCountdown = function(self, payload, ...)
        return original(self, ClonePayloadWithText(payload), ...)
    end
    ns.Mark("CenterAlert", scopeKey .. ":ShowCountdown")
end

-- ShowHealthEntries(entries): center-screen health-threshold text; each
-- entry.text comes from boss-preset rule data, zh in CN presets. Entries
-- are cloned so upstream rule tables are never mutated.
local function WrapShowHealthEntries(target, scopeKey)
    if type(target) ~= "table" or type(target.ShowHealthEntries) ~= "function" then return end
    if ns.IsMarked("CenterAlert", scopeKey .. ":ShowHealthEntries") then return end
    local original = target.ShowHealthEntries
    -- Re-fires on a 0.5s ticker; clone lazily, only when a text changed.
    target.ShowHealthEntries = function(self, entries, ...)
        if type(entries) == "table" then
            local cloned
            for i = 1, #entries do
                local entry = entries[i]
                if type(entry) == "table" and type(entry.text) == "string" then
                    local translated = TranslateString(entry.text)
                    if translated ~= entry.text then
                        local copy = {}
                        for k, v in pairs(entry) do copy[k] = v end
                        copy.text = translated
                        if not cloned then
                            cloned = {}
                            for j = 1, #entries do cloned[j] = entries[j] end
                        end
                        cloned[i] = copy
                    end
                end
            end
            if cloned then entries = cloned end
        end
        return original(self, entries, ...)
    end
    ns.Mark("CenterAlert", scopeKey .. ":ShowHealthEntries")
end

-- Countdown:Show(spec): spec.displayName is the row label.
local function WrapCountdownShow(target, scopeKey)
    if type(target) ~= "table" or type(target.Show) ~= "function" then return end
    if ns.IsMarked("CenterAlert", scopeKey .. ":Show") then return end
    local original = target.Show
    target.Show = function(self, spec, ...)
        local newSpec = spec
        if type(spec) == "table" and type(spec.displayName) == "string" then
            local translated = TranslateString(spec.displayName)
            if translated ~= spec.displayName then
                local cloned = {}
                for k, v in pairs(spec) do cloned[k] = v end
                cloned.displayName = translated
                newSpec = cloned
            end
        end
        return original(self, newSpec, ...)
    end
    ns.Mark("CenterAlert", scopeKey .. ":Show")
end

local function ApplyWraps()
    if type(_G.ExBoss) ~= "table" or type(_G.ExBoss.UI) ~= "table" then return end
    local UI = _G.ExBoss.UI
    if type(UI.FlashText) == "table" then
        WrapShow(UI.FlashText, "FlashText")
        WrapShowCountdown(UI.FlashText, "FlashText")
    end
    if type(UI.FlashTextMedium) == "table" then
        WrapShow(UI.FlashTextMedium, "FlashTextMedium")
        WrapShowCountdown(UI.FlashTextMedium, "FlashTextMedium")
        WrapShowHealthEntries(UI.FlashTextMedium, "FlashTextMedium")
    end
    if type(UI.Countdown) == "table" then
        WrapCountdownShow(UI.Countdown, "Countdown")
    end
    ns.Log("CenterAlert: wrapped FlashText / FlashTextMedium / Countdown display entry points")
end

ns.OnAddonLoaded("exboss", ApplyWraps)
ns.OnPlayerEnteringWorld(function(firstPEW)
    if firstPEW then ApplyWraps() end
end)
