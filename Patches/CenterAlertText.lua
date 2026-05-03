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

local function ClonePayloadWithText(payload)
    if type(payload) ~= "table" then return payload end
    local needsClone = false
    if type(payload.text) == "string" or type(payload.label) == "string" then
        needsClone = true
    end
    if not needsClone then return payload end
    local out = {}
    for k, v in pairs(payload) do out[k] = v end
    if type(out.text) == "string" then out.text = TranslateString(out.text) end
    if type(out.label) == "string" then out.label = TranslateString(out.label) end
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

-- Countdown:Show(spec): spec.displayName is the row label.
local function WrapCountdownShow(target, scopeKey)
    if type(target) ~= "table" or type(target.Show) ~= "function" then return end
    if ns.IsMarked("CenterAlert", scopeKey .. ":Show") then return end
    local original = target.Show
    target.Show = function(self, spec, ...)
        local newSpec = spec
        if type(spec) == "table" and type(spec.displayName) == "string" then
            local cloned = {}
            for k, v in pairs(spec) do cloned[k] = v end
            cloned.displayName = TranslateString(spec.displayName)
            newSpec = cloned
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
