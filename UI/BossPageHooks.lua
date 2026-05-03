---@diagnostic disable: undefined-global
-- After BossPage:Render and :RefreshSpellUI run, walk a small set of
-- known FontString descendants and refit them via UI_FitWidth.
-- hooksecurefunc only — never method replacement.

local _, ns = ...

local function FitDescendantFontStrings(root, opts)
    if type(root) ~= "table" or type(root.GetChildren) ~= "function" then return end
    -- Top-level regions: GetRegions returns Texture/FontString children.
    if type(root.GetRegions) == "function" then
        for _, region in ipairs({ root:GetRegions() }) do
            if type(region) == "table"
               and type(region.GetObjectType) == "function"
               and region:GetObjectType() == "FontString" then
                ns.UI_FitWidth(region, opts)
            end
        end
    end
    -- One level only — deeper frame-tree walking is the old patch's
    -- anti-pattern that this rewrite is meant to avoid.
end

local function HookBossPage()
    if ns.IsMarked("UI", "BossPage") then return end
    if not ns.GetDB().fitWidths then return end
    if type(_G.ExBoss) ~= "table"
       or type(_G.ExBoss.UI) ~= "table"
       or type(_G.ExBoss.UI.Panel) ~= "table"
       or type(_G.ExBoss.UI.Panel.BossPage) ~= "table" then
        return
    end

    local Page = _G.ExBoss.UI.Panel.BossPage
    local hookedAny = false

    if type(Page.Render) == "function" then
        hooksecurefunc(Page, "Render", function(_, leftFrame, contentFrame)
            if not ns.GetDB().fitWidths then return end
            FitDescendantFontStrings(leftFrame,    { padding = 12, maxWidth = 220 })
            FitDescendantFontStrings(contentFrame, { padding = 12, maxWidth = 480 })
        end)
        hookedAny = true
    end

    if type(Page.RefreshSpellUI) == "function" then
        hooksecurefunc(Page, "RefreshSpellUI", function(self)
            if not ns.GetDB().fitWidths then return end
            -- Opportunistic refit — exact spell-card field names aren't
            -- known without live smoke testing.
            FitDescendantFontStrings(self, { padding = 12, maxWidth = 480 })
        end)
        hookedAny = true
    end

    if hookedAny then
        ns.Mark("UI", "BossPage")
        ns.Log("UI: hooked BossPage Render/RefreshSpellUI")
    end
end

ns.OnPlayerLogin(HookBossPage)
ns.OnAddonLoaded("exboss", HookBossPage)
