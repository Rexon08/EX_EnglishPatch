---@diagnostic disable: undefined-global
-- Pre-populates StaticPopupDialogs entries before the source's lazy
-- `if not StaticPopupDialogs[key] then ...` branch runs, so our English
-- copy wins. Only used for popups whose source text bypasses L[...];
-- the rest are covered by the locale-store merge.

local _, ns = ...

local function NeedPopup(key)
    return type(_G.StaticPopupDialogs) == "table" and _G.StaticPopupDialogs[key] == nil
end

local function PatchStaticPopups()
    if ns.IsMarked("StaticPopups") then return end
    if type(_G.StaticPopupDialogs) ~= "table" then return end

    -- Confirm dialog shown on every edit-mode toggle.
    if NeedPopup("EXWIND_EDIT_MODE_EXIT") then
        _G.StaticPopupDialogs["EXWIND_EDIT_MODE_EXIT"] = {
            text = "Exit Edit Mode?",
            button1 = "OK",
            OnAccept = function()
                if _G.ExwindTools and _G.ExwindTools.ToggleGlobalEditMode then
                    _G.ExwindTools:ToggleGlobalEditMode(false)
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = false,
            preferredIndex = 3,
        }
    end

    -- Shown when the compartment is opened without ExwindTools loaded.
    -- The %s payload is still raw Chinese (built in source without a
    -- hookable seam) — we just give the dialog an English skeleton.
    if NeedPopup("EXWINDTOOLS_MISSING_WARNING") then
        _G.StaticPopupDialogs["EXWINDTOOLS_MISSING_WARNING"] = {
            text = "%s",
            button1 = "OK",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
    end

    ns.Mark("StaticPopups")
    ns.Log("StaticPopups: pre-populated raw-Chinese dialogs")
end

ns.OnAddonLoaded("exwindcore", PatchStaticPopups)
ns.OnPlayerLogin(PatchStaticPopups)
ns.Patches.StaticPopups = PatchStaticPopups
