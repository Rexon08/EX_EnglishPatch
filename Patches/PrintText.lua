---@diagnostic disable: undefined-global
-- ExBoss and ExwindCore print entry/status notices via their own chat
-- facades with raw source literals (locale-store patching can't reach them).
-- Wrapping the facades translates only addon-owned output; global print() is
-- untouched. ExBoss.Print.Say and ExwindTools:Print are independent (Say
-- prints directly, never delegating to Print), so a message is wrapped once.

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

-- ExwindTools:ToggleGlobalEditMode prints the edit-mode status line as a raw
-- (non-L[]) literal, so the toggle leaks Chinese into chat. Translating the
-- message before the original formats/prints it keeps any %s specifiers (they
-- are pure ASCII and survive the substring swap).
local function WrapExwindToolsPrint()
    if ns.IsMarked("PrintText", "ExwindTools.Print") then return end
    local ET = _G.ExwindTools
    if type(ET) ~= "table" or type(ET.Print) ~= "function" then return end
    if ET._eb_orig_Print then return end

    local original = ET.Print
    ET._eb_orig_Print = original
    ET.Print = function(self, msg, ...)
        if type(msg) == "string" then msg = Translate(msg) end
        return original(self, msg, ...)
    end

    ns.Mark("PrintText", "ExwindTools.Print")
    ns.Log("PrintText: wrapped ExwindTools:Print")
end

ns.OnAddonLoaded("exboss", WrapExBossPrint)
ns.OnAddonLoaded("exwindcore", WrapExwindToolsPrint)
ns.OnPlayerLogin(WrapExBossPrint)
ns.OnPlayerLogin(WrapExwindToolsPrint)
