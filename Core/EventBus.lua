---@diagnostic disable: undefined-global
-- Central event dispatcher. Modules register via OnAddonLoaded / OnPlayerLogin
-- / OnPlayerEnteringWorld / OnRegenEnabled instead of each creating its own
-- frame.

local _, ns = ...

local frame = CreateFrame("Frame", "EX_EnglishPatchEventFrame")

ns._handlers = ns._handlers or {
    addon = {},
    login = {},
    pew = {},
    regen = {},
}

local function PushHandler(bucket, fn)
    if type(fn) ~= "function" then return end
    bucket[#bucket + 1] = fn
end

-- 12.0 prefers C_AddOns.IsAddOnLoaded; the bare global remains as an alias.
local function IsAddOnLoaded(addonName)
    if type(C_AddOns) == "table" and type(C_AddOns.IsAddOnLoaded) == "function" then
        local ok, loaded = pcall(C_AddOns.IsAddOnLoaded, addonName)
        if ok then return loaded == true end
    end
    if type(_G.IsAddOnLoaded) == "function" then
        local ok, loaded = pcall(_G.IsAddOnLoaded, addonName)
        if ok then return loaded == true end
    end
    return false
end

ns.IsAddOnLoaded = IsAddOnLoaded

local ADDON_NAME_BY_LOWER = {
    ["exwindcore"]    = "ExwindCore",
    ["exwindtools"]   = "ExwindTools",
    ["exbossdata"]    = "EXBossData",
    ["exboss"]        = "EXBoss",
    ["exboss-exwind"] = "EXBOSS-EXWIND",
}

function ns.OnAddonLoaded(targetAddonLower, fn)
    PushHandler(ns._handlers.addon, function(addonName)
        if tostring(addonName or ""):lower() == targetAddonLower then
            fn(addonName)
        end
    end)
    -- Deps load before us via RequiredDeps, so their ADDON_LOADED has
    -- already fired. Dispatch immediately if loaded; markers make a later
    -- fire (e.g. /reload) a no-op.
    local realName = ADDON_NAME_BY_LOWER[targetAddonLower] or targetAddonLower
    if IsAddOnLoaded(realName) and ns.IsEnabled and ns.IsEnabled() then
        local ok, err = pcall(fn, realName)
        if not ok then ns.Warn("OnAddonLoaded immediate dispatch: " .. tostring(err)) end
    end
end

function ns.OnPlayerLogin(fn)        PushHandler(ns._handlers.login, fn) end
function ns.OnPlayerEnteringWorld(fn) PushHandler(ns._handlers.pew, fn) end
function ns.OnRegenEnabled(fn)       PushHandler(ns._handlers.regen, fn) end

local function Dispatch(bucket, ...)
    for i = 1, #bucket do
        local ok, err = pcall(bucket[i], ...)
        if not ok then
            ns.Warn("dispatch: " .. tostring(err))
        end
    end
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")

local _bridgeInited = false
local _firstPEW = true

frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if not _bridgeInited and tostring(arg1 or ""):lower() == ns.NAME:lower() then
            _bridgeInited = true
            ns.InitDB()
            ns.Log("DB initialized, schema=" .. tostring(ns.GetDB().schema))
        end
        if not ns.IsEnabled() then return end
        Dispatch(ns._handlers.addon, arg1)
    elseif event == "PLAYER_LOGIN" then
        if not ns.IsEnabled() then return end
        Dispatch(ns._handlers.login)
    elseif event == "PLAYER_ENTERING_WORLD" then
        if not ns.IsEnabled() then return end
        Dispatch(ns._handlers.pew, _firstPEW)
        _firstPEW = false
    elseif event == "PLAYER_REGEN_ENABLED" then
        ns.FlushCombatQueue()
        Dispatch(ns._handlers.regen)
    end
end)

ns._eventFrame = frame
