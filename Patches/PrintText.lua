---@diagnostic disable: undefined-global
-- ExBoss prints entry/status notices via its own chat facade with raw
-- source literals (locale-store patching can't reach them). Wrapping the
-- facade translates only addon-owned output; global print() is untouched.

local _, ns = ...

local function Translate(text)
    if type(text) ~= "string" or text == "" then return text end
    if type(ns.TranslateDisplayText) ~= "function" then return text end
    local translated = ns.TranslateDisplayText(text)
    if type(translated) == "string" and translated ~= "" then
        return translated
    end
    return text
end

local function WrapExBossPrint()
    if ns.IsMarked("PrintText", "ExBoss.Print.Say") then return end
    local printer = _G.ExBoss and _G.ExBoss.Print or nil
    if type(printer) ~= "table" or type(printer.Say) ~= "function" then return end
    if printer._eb_orig_Say then return end

    local original = printer.Say
    printer._eb_orig_Say = original
    printer.Say = function(msg, ...)
        return original(Translate(msg), ...)
    end

    ns.Mark("PrintText", "ExBoss.Print.Say")
    ns.Log("PrintText: wrapped ExBoss.Print.Say")
end

ns.OnAddonLoaded("exboss", WrapExBossPrint)
ns.OnPlayerLogin(WrapExBossPrint)
