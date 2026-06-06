---@diagnostic disable: undefined-global
-- ExwindTools.ModuleList is the module-browser catalog. Its Name/Desc are
-- shown in the sidebar and detail page (ExwindToolsUI: descText:SetText(meta.Desc)).
-- Most rows wrap both in L[...] so they resolve through the forced-enUS store,
-- but some upstream rows ship a raw zh literal (e.g. ExTools.PlayerHealAbsorb's
-- Desc) the locale path can't reach. Re-translate the visible Name/Desc in
-- place via the resolver, exactly as ModuleLayouts does for Grid layouts.
-- find_untranslated can't see these (they aren't L[...] refs), so the leak is
-- silent — repaint defensively rather than rely on the locale merge.

local _, ns = ...

local function PatchField(row, field)
    if type(row) ~= "table" or type(row[field]) ~= "string" then return 0 end
    local translated, changed = ns.TranslateDisplayText(row[field])
    if changed and translated ~= row[field] then
        ns.Patches.StashOriginal(row, field)
        row[field] = translated
        return 1
    end
    return 0
end

local function ApplyPatch()
    if ns.IsMarked("ModuleListMeta", "Applied") then return end
    local ET = _G.ExwindTools
    local list = type(ET) == "table" and ET.ModuleList or nil
    if type(list) ~= "table" then return end

    local count = 0
    for _, row in ipairs(list) do
        count = count + PatchField(row, "Name")
        count = count + PatchField(row, "Desc")
    end

    ns.Mark("ModuleListMeta", "Applied")
    ns.Log("ModuleListMeta: patched " .. tostring(count) .. " catalog strings")
end

ns.Patches.RegisterPostInit {
    deps     = { "exwindcore", "exwindtools" },
    login    = true,
    afterPEW = false,
    apply    = ApplyPatch,
}
