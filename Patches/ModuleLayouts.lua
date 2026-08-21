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

-- Display-only column/row nudges for source layouts whose English labels
-- collide with a neighbouring widget (the cells were sized for narrower
-- Chinese). Keyed by module key + widget key; applied to the registered
-- layout table the renderer reads. Geometry is never persisted — the DB
-- keys off each row's `key`, not its x/y/w/h, and we write no DB. Re-verify
-- when upstream changes a flagged layout (upstream_drift flags the file).
local LAYOUT_GEOMETRY = {
    -- TargetAlertPage: checkbox labels at column 1 overran the column-2/3
    -- widgets. Widen the long column-1 checkboxes to cover their label and
    -- shift the second/third columns right so nothing overlaps. A checkbox
    -- label renders at natural width (Grid never clips it), so a label only
    -- collides when another widget sits in the overrun.
    ["ExBoss.TargetAlert"] = {
        hideLevel92Casts         = { w = 12 },
        hideLevel91Casts         = { w = 12 },
        enableForDps             = { x = 14 },
        locked                   = { x = 14 },
        showSpellName            = { x = 14 },
        enableForHeal            = { x = 25 },
        preview                  = { x = 25 },
        singleTargetSoundEnabled = { w = 14 },
        multiTargetSoundEnabled  = { w = 14 },
        singleTargetLSM          = { x = 15, w = 15 },
        multiTargetLSM           = { x = 15, w = 15 },
    },

    -- Boss-spell editor grid (~3.75 px/col at the 760 px grid child).
    -- ApplyBossSettingsLabelSafety clamps checkbox labels to their own
    -- cell, so English must fit w*cell-39 px: widen each cell to the next
    -- widget's column and drop the tightest labels to 14 pt. Audited
    -- offline via tools/audit_label_overflow.mjs.
    ["ExBoss.BossPage.SpellEditor"] = {
        centralEnabled               = { w = 30, labelSize = 14 },
        countdownEnabled             = { w = 29, labelSize = 14 },
        timerBarRenameEnabled        = { w = 29 },
        ringCastCheckEnabled         = { w = 40 },
        castProgressBarRenameEnabled = { w = 30 },
        tr0Enabled                   = { w = 30, labelSize = 14 },
        tr1Enabled                   = { w = 29, labelSize = 14 },
        tr2Enabled                   = { w = 29, labelSize = 14 },
        tr2PlayTextEnabled           = { w = 29, labelSize = 14 },
        targetAlertVoiceEnabled      = { w = 22 },
    },

    -- Countdown voice page: the GTFO row's labelPos="left" labels hang off
    -- the container's left edge (upstream sized them for 2-glyph zh), and
    -- the per-digit "LSM Sound" label lands on the Source dropdown. Shift
    -- the row right / shrink the Source dropdown so every label has room.
    ["ExBoss.CountdownVoiceSettings"] = {
        floorWarningSource  = { x = 14 },
        floorWarningPack    = { x = 58 },
        floorWarningLSM     = { x = 58 },
        floorWarningPath    = { x = 58 },
        previewFloorWarning = { x = 134 },
        digitSource1  = { w = 30 },
        digitSource2  = { w = 30 },
        digitSource3  = { w = 30 },
        digitSource4  = { w = 30 },
        digitSource5  = { w = 30 },
        digitSource6  = { w = 30 },
        digitSource7  = { w = 30 },
        digitSource8  = { w = 30 },
        digitSource9  = { w = 30 },
        digitSource10 = { w = 30 },
    },

    -- GlobalTrashCD settings page ("Trash Cooldown Nameplate Icons"): the
    -- grid rows below the icongroup sit on a 6-cell pitch, but every widget
    -- there carries a labelPos="top" label (~4 cells above the widget) and
    -- the spacing slider's bar+value box runs ~7 cells tall — so the second
    -- row's labels rendered on top of the first row's widgets. Open the
    -- pitch to 12 cells and shift everything after it down to match.
    ["ExBoss.TrashCD.Settings.Editor"] = {
        nameplateIconStrata           = { y = 75 },
        hideNameplateIconAboveSeconds = { y = 75 },
        screenNameplatePreview        = { y = 82 },
        nameplateIconText             = { y = 89 },
    },

    -- TrashCD spell editor (~4.04 px/col at the 818 px scroll child); same
    -- clamp behavior as the BossPage editor.
    ["ExBoss.TrashCD.SpellEditor"] = {
        enabled                      = { w = 24 },
        showBunBar                   = { w = 28 },
        showTimerBar                 = { w = 31 },
        showNameplate                = { w = 33 },
        tr1Enabled                   = { w = 24 },
        tr2Enabled                   = { w = 24 },
        tr2PlayTextEnabled           = { w = 24, labelSize = 14 },
        castProgressBarRenameEnabled = { w = 24 },
        ringCastCheckEnabled         = { w = 45 },
        targetAlertStealthEnabledV2  = { w = 34, labelSize = 14 },
        tr1ValueTest                 = { w = 11 },
        tr2ValueTest                 = { w = 11 },
        targetAlertStartValueTest    = { w = 11 },
    },
}

-- labelSize is display-only like the box geometry: UpdateLabelStyle reads
-- it per render and it never reaches any DB path.
local GEOMETRY_FIELDS = { "x", "y", "w", "h", "labelSize" }

local function ApplyGeometry(layout, moduleKey)
    local geo = type(moduleKey) == "string" and LAYOUT_GEOMETRY[moduleKey] or nil
    if type(geo) ~= "table" then return 0 end
    local count = 0
    for _, row in ipairs(layout) do
        if type(row) == "table" and type(row.key) == "string" then
            local over = geo[row.key]
            if type(over) == "table" then
                for _, field in ipairs(GEOMETRY_FIELDS) do
                    local value = over[field]
                    if value ~= nil and row[field] ~= value then
                        ns.Patches.StashOriginal(row, field)
                        row[field] = value
                        count = count + 1
                    end
                end
            end
        end
    end
    return count
end

local function PatchLayout(layout, moduleKey)
    if type(layout) ~= "table" then return 0 end
    if layout._eb_patched then return 0 end
    local count = 0
    for _, row in ipairs(layout) do
        if type(row) == "table" then
            count = count + PatchStringField(row, "label")
            count = count + PatchStringField(row, "tooltip")
            count = count + PatchStringField(row, "placeholder")
            count = count + PatchItems(row.items)
            count = count + PatchLayout(row.children, moduleKey)
        end
    end
    count = count + ApplyGeometry(layout, moduleKey)
    layout._eb_patched = true
    return count
end

local function PatchRegisteredLayouts()
    local ET = _G.ExwindTools
    local layouts = type(ET) == "table" and ET.RegisteredLayouts or nil
    if type(layouts) ~= "table" then return 0 end

    local count = 0
    for moduleKey, layout in pairs(layouts) do
        count = count + PatchLayout(layout, moduleKey)
    end
    return count
end

local function InstallRegisterHook()
    if ns.IsMarked("ModuleLayouts", "RegisterHook") then return end
    local ET = _G.ExwindTools
    if type(ET) ~= "table" or type(ET.RegisterModuleLayout) ~= "function" then return end
    if type(hooksecurefunc) ~= "function" then return end

    hooksecurefunc(ET, "RegisterModuleLayout", function(_, moduleKey, layout)
        -- BossPage rebuilds its spell-editor rows in place and re-registers
        -- the same table per selection; the sticky guard would otherwise
        -- skip every rebuild after the first.
        if type(layout) == "table" then layout._eb_patched = nil end
        PatchLayout(layout, moduleKey)
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
