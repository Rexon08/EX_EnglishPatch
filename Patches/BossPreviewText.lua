---@diagnostic disable: undefined-global
-- ExBoss.TemporaryBossPreview (v26.9.13) revived the Boss page's test
-- buttons. Start() returns (false, reason) with a raw zh reason that
-- BossPage prints through global print() — the one chat path the
-- PrintText seam can't see. Translate the reason on the way out instead.

local _, ns = ...

local function TranslateReason(reason)
    if type(reason) ~= "string" or reason == "" then return reason end
    local out = ns.Resolver.DisplayText(reason)
    if type(out) == "string" and out ~= "" then return out end
    return reason
end

local function WrapStart()
    if ns.IsMarked("BossPreviewText", "Start") then return end
    local preview = _G.ExBoss and _G.ExBoss.TemporaryBossPreview
    if type(preview) ~= "table" or type(preview.Start) ~= "function" then return end
    if preview._eb_orig_Start then return end

    local original = preview.Start
    preview._eb_orig_Start = original
    preview.Start = function(self, ...)
        local ok, reason = original(self, ...)
        if ok == false then return ok, TranslateReason(reason) end
        return ok, reason
    end

    ns.Mark("BossPreviewText", "Start")
    ns.Log("BossPreviewText: wrapped ExBoss.TemporaryBossPreview.Start")
end

ns.OnAddonLoaded("exboss", WrapStart)
ns.OnPlayerLogin(WrapStart)
