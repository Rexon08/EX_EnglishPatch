---@diagnostic disable: undefined-global
-- EXMD abbreviates damage with zh wan (10⁴) / yi (10⁸) units; its enUS
-- locale renames them W/B but keeps the math, so "10W" is really 100K
-- and "1.50B" is really 150M. We post-process ProcessDamageText and
-- convert to honest K/M/B:
--   <n>W      → (n * 10) K        (10W   → 100K)
--   <n.xx>B   → (n * 100) M       (1.50B → 150M, 12.5B → 1.25B)

local _, ns = ...

local function ConvertWesternUnits(text)
    if type(text) ~= "string" or text == "" then return text end

    text = text:gsub("(%d+)W", function(n)
        local v = tonumber(n)
        if not v then return n .. "W" end
        return tostring(v * 10) .. "K"
    end)

    text = text:gsub("([%d%.]+)B", function(n)
        local v = tonumber(n)
        if not v then return n .. "B" end
        local m = v * 100
        if m >= 1000 then
            local b = m / 1000
            if b == math.floor(b) then return string.format("%dB", b) end
            return string.format("%.2fB", b)
        end
        if m == math.floor(m) then return string.format("%dM", m) end
        return string.format("%.1fM", m)
    end)

    return text
end

local function WrapProcessDamageText()
    if ns.IsMarked("Format", "EXMDProcessDamage") then return end
    if type(_G.EXMD) ~= "table" then return end
    local orig = _G.EXMD.ProcessDamageText
    if type(orig) ~= "function" then return end
    if _G.EXMD._eb_origProcessDamageText then return end

    _G.EXMD._eb_origProcessDamageText = orig
    _G.EXMD.ProcessDamageText = function(text, multiplier)
        local out = orig(text, multiplier)
        return ConvertWesternUnits(out)
    end

    ns.Mark("Format", "EXMDProcessDamage")
    ns.Log("Format: wrapped EXMD.ProcessDamageText for K/M output")
end

ns.OnAddonLoaded("exwindtools", WrapProcessDamageText)
ns.OnPlayerLogin(WrapProcessDamageText)

ns.UI = ns.UI or {}
ns.UI.MythicDamageFormat = { ConvertWesternUnits = ConvertWesternUnits }
