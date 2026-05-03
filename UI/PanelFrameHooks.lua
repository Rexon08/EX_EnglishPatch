---@diagnostic disable: undefined-global
-- The main panel's RefreshContent is a file-local closure (not hookable),
-- so per-page hooks live elsewhere. This file currently just widens any
-- recognised tab buttons; it stays in place to attach to a future public
-- panel-level refresh if EXBoss adds one.

local _, ns = ...

-- TabKeysToFit lives in the translations module so this file carries no
-- zh literals.
local function FitKnownTabs()
    if not ns.GetDB().fitWidths then return end
    local fitKeys = ns.Translations.TabKeysToFit
    if type(fitKeys) ~= "table" then return end
    local panel = _G.ExBoss
        and _G.ExBoss.UI
        and _G.ExBoss.UI.Panel
    if type(panel) ~= "table" then return end

    -- No-op rather than recurse if the expected panel root is missing.
    if type(panel.MainFrame) ~= "table"
       or type(panel.MainFrame.GetChildren) ~= "function" then
        return
    end

    for _, child in ipairs({ panel.MainFrame:GetChildren() }) do
        if type(child) == "table"
           and type(child.GetText) == "function" then
            local text = child:GetText()
            if type(text) == "string" and fitKeys[text] then
                ns.UI_FitButton(child, { padding = 18, maxWidth = 220 })
            end
        end
    end
end

local function HookPanel()
    if ns.IsMarked("UI", "PanelFrame") then return end
    -- No public Panel:Refresh today — run on PEW + after combat.
    ns.Mark("UI", "PanelFrame")
    ns.Log("UI: PanelFrame fit pass scheduled (no method to hook)")
end

ns.OnPlayerLogin(HookPanel)
ns.OnPlayerEnteringWorld(function(firstPEW)
    if firstPEW then
        ns.RunSafe("PanelFrame:FitTabs", FitKnownTabs)
    end
end)
ns.OnRegenEnabled(function()
    ns.RunSafe("PanelFrame:FitTabs:postCombat", FitKnownTabs)
end)
