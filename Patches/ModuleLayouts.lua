---@diagnostic disable: undefined-global
-- Many source modules register Grid layouts before we can force enUS, so
-- subsequent renders show the captured zh labels. Mutating each layout's
-- visible label fields in place fixes the render without touching the DB
-- keys or saved values that share those tables.

local _, ns = ...

local function Translate(value)
    if type(value) ~= "string" or value == "" then return value, false end
    -- LabelOverrides handles the (en → shorter-en) case where the source's
    -- enUS label overflows its reserved column width and DisplayText
    -- short-circuits on the pure-ASCII input.
    local overrides = ns.Translations and ns.Translations.LabelOverrides
    if type(overrides) == "table" then
        local short = overrides[value]
        if type(short) == "string" and short ~= "" and short ~= value then
            return short, true
        end
    end
    if type(ns.TranslateDisplayText) == "function" then
        return ns.TranslateDisplayText(value)
    end
    return value, false
end

local function PatchStringField(row, field)
    if type(row) ~= "table" or type(row[field]) ~= "string" then return 0 end
    local translated, changed = Translate(row[field])
    if changed and translated ~= row[field] then
        ns.Patches.StashOriginal(row, field)
        row[field] = translated
        return 1
    end
    return 0
end

local function PatchItems(items)
    if type(items) ~= "table" then return 0 end
    local count = 0
    for _, item in ipairs(items) do
        if type(item) == "table" then
            count = count + PatchStringField(item, 1)
            count = count + PatchStringField(item, "text")
            count = count + PatchStringField(item, "label")
            if type(item.menu) == "table" then
                count = count + PatchItems(item.menu)
            end
        end
        -- Plain-string items double as storage values; translate them at
        -- the dropdown display layer, not here.
    end
    return count
end

local function PatchLayout(layout)
    if type(layout) ~= "table" then return 0 end
    if layout._eb_patched then return 0 end
    local count = 0
    for _, row in ipairs(layout) do
        if type(row) == "table" then
            count = count + PatchStringField(row, "label")
            count = count + PatchStringField(row, "tooltip")
            count = count + PatchStringField(row, "placeholder")
            count = count + PatchItems(row.items)
            count = count + PatchLayout(row.children)
        end
    end
    layout._eb_patched = true
    return count
end

local function PatchRegisteredLayouts()
    local ET = _G.ExwindTools
    local layouts = type(ET) == "table" and ET.RegisteredLayouts or nil
    if type(layouts) ~= "table" then return 0 end

    local count = 0
    for _, layout in pairs(layouts) do
        count = count + PatchLayout(layout)
    end
    return count
end

local function InstallRegisterHook()
    if ns.IsMarked("ModuleLayouts", "RegisterHook") then return end
    local ET = _G.ExwindTools
    if type(ET) ~= "table" or type(ET.RegisterModuleLayout) ~= "function" then return end
    if type(hooksecurefunc) ~= "function" then return end

    hooksecurefunc(ET, "RegisterModuleLayout", function(_, _, layout)
        PatchLayout(layout)
    end)
    ns.Mark("ModuleLayouts", "RegisterHook")
end

local function ApplyPatch()
    InstallRegisterHook()
    local count = PatchRegisteredLayouts()
    if not ns.IsMarked("ModuleLayouts", "InitialPass") then
        ns.Mark("ModuleLayouts", "InitialPass")
        ns.Log("ModuleLayouts: patched " .. tostring(count) .. " visible layout strings")
    end
end

ns.Patches.RegisterPostInit {
    deps     = { "exwindtools", "exboss" },
    login    = true,
    afterPEW = false,
    apply    = ApplyPatch,
}

ns.Patches.ModuleLayouts = {
    PatchLayout = PatchLayout,
    PatchRegisteredLayouts = PatchRegisteredLayouts,
}
