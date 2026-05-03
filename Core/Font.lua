---@diagnostic disable: undefined-global
-- Resolves a single UI font path used to repaint the upstream Boss/Tools
-- panels. Why: ExwindCore picks AR ZhongkaiGBK as MAIN_FONT on non-CJK
-- clients when LibSharedMedia is present, which renders Latin glyphs in a
-- thinner CJK design and makes translated labels look mismatched.
--
-- Resolution order — first path that SetFont accepts wins:
--   1. bundled  Interface\AddOns\EX_EnglishPatch\Fonts\Expressway.TTF
--   2. LibSharedMedia "Expressway" entry (EllesmereUI / ElvUI / others)
--   3. STANDARD_TEXT_FONT
--   4. Fonts\FRIZQT__.TTF                      (always-available WoW font)
--
-- Probing happens lazily on first ns.GetUIFont() call so file load works
-- under the sandbox loadtest (no UIParent / no FontString factory).

local _, ns = ...

local BUNDLED_PATH = [[Interface\AddOns\EX_EnglishPatch\Fonts\Expressway.TTF]]
local FINAL_FALLBACK = [[Fonts\FRIZQT__.TTF]]

local _resolved        -- cached path, set after first probe
local _probe           -- reused FontString for SetFont validation

local function CandidatePaths()
    local out = { BUNDLED_PATH }

    if type(LibStub) == "function" then
        local ok, lsm = pcall(LibStub, "LibSharedMedia-3.0", true)
        if ok and lsm and type(lsm.Fetch) == "function" then
            local ok2, path = pcall(lsm.Fetch, lsm, "font", "Expressway")
            if ok2 and type(path) == "string" and path ~= "" then
                out[#out + 1] = path
            end
        end
    end

    local std = rawget(_G, "STANDARD_TEXT_FONT")
    if type(std) == "string" and std ~= "" then
        out[#out + 1] = std
    end
    out[#out + 1] = FINAL_FALLBACK
    return out
end

-- Reuses one hidden FontString to call SetFont; SetFont returns false if
-- the engine cannot load the file, true otherwise. UIParent always exists
-- after PLAYER_LOGIN; the lazy guard covers earlier callers and sandbox.
local function GetProbe()
    if _probe then return _probe end
    local parent = rawget(_G, "UIParent")
    if type(parent) ~= "table" or type(parent.CreateFontString) ~= "function" then
        return nil
    end
    local ok, fs = pcall(parent.CreateFontString, parent, nil, "BACKGROUND")
    if not ok or type(fs) ~= "table" or type(fs.SetFont) ~= "function" then
        return nil
    end
    _probe = fs
    return _probe
end

local function PathLoads(path)
    if type(path) ~= "string" or path == "" then return false end
    local probe = GetProbe()
    if not probe then
        -- Pre-UIParent / sandbox: assume bundled path works, refuse others.
        return path == BUNDLED_PATH
    end
    local ok, accepted = pcall(probe.SetFont, probe, path, 12, "")
    if not ok then return false end
    if accepted == false then return false end
    -- Some Blizzard builds return nil even on success; also verify GetFont.
    local got = pcall(probe.GetFont, probe) and probe:GetFont() or nil
    if type(got) == "string" and got ~= "" then return true end
    return accepted == true
end

local function Resolve()
    if _resolved then return _resolved end
    for _, candidate in ipairs(CandidatePaths()) do
        if PathLoads(candidate) then
            _resolved = candidate
            if ns.Log then
                ns.Log("Font: resolved UI font -> " .. candidate)
            end
            return _resolved
        end
    end
    _resolved = FINAL_FALLBACK
    if ns.Warn then
        ns.Warn("Font: every candidate failed; using " .. FINAL_FALLBACK)
    end
    return _resolved
end

function ns.GetUIFont()
    return Resolve()
end

-- Forces a re-probe; useful if LibSharedMedia registers Expressway after
-- our first call (rare, but cheap to support).
function ns.InvalidateUIFont()
    _resolved = nil
end

ns.UIFontBundledPath = BUNDLED_PATH
ns.UIFontFallbackPath = FINAL_FALLBACK
