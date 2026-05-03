---@diagnostic disable: undefined-global
-- The Voice/Config page draws a "Select Voice Pack" caption that overlaps
-- the dropdown's own label by ~10 px, making both unreadable. The
-- dropdown label conveys the same intent, so hide the caption.

local _, ns = ...

-- Match both the raw zh source key (page may have been built before the
-- locale overlay) and the enUS translation.
local DROP_LABEL_TEXTS = {
    ["\233\128\137\230\139\169\232\175\173\233\159\179\229\140\133"] = true,
    ["Select Voice Pack"] = true,
}

local function ObjectType(obj)
    if type(obj) ~= "table" or type(obj.GetObjectType) ~= "function" then return nil end
    local ok, t = pcall(obj.GetObjectType, obj)
    if ok then return t end
    return nil
end

local function HideMatchingFontStrings(frame, depth)
    if type(frame) ~= "table" or depth < 0 then return end
    if type(frame.GetRegions) == "function" then
        local regions = { frame:GetRegions() }
        for i = 1, #regions do
            local r = regions[i]
            if r and not r._eb_voicePackLabelHidden and ObjectType(r) == "FontString"
               and type(r.GetText) == "function" then
                local ok, text = pcall(r.GetText, r)
                if ok and DROP_LABEL_TEXTS[text] and type(r.Hide) == "function" then
                    pcall(r.Hide, r)
                    r._eb_voicePackLabelHidden = true
                end
            end
        end
    end
    if type(frame.GetChildren) == "function" then
        local children = { frame:GetChildren() }
        for i = 1, #children do
            HideMatchingFontStrings(children[i], depth - 1)
        end
    end
end

local function InstallHook()
    if ns.IsMarked("UI", "VoicePackPageDropLabelHide") then return end
    if type(hooksecurefunc) ~= "function" then return end
    local Page = _G.ExBoss and _G.ExBoss.UI and _G.ExBoss.UI.Panel
        and _G.ExBoss.UI.Panel.VoicePackPage
    if type(Page) ~= "table" or type(Page.Render) ~= "function" then return end

    hooksecurefunc(Page, "Render", function(_, contentFrame)
        ns.RunSafe("VoicePackPageHooks:HideDropLabel", function()
            HideMatchingFontStrings(contentFrame, 6)
        end)
    end)
    ns.Mark("UI", "VoicePackPageDropLabelHide")
end

ns.OnAddonLoaded("exboss", InstallHook)
ns.OnPlayerLogin(InstallHook)
