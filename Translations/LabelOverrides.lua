---@diagnostic disable: undefined-global
-- (en → shorter-en) overrides for Grid layout labels whose source enUS
-- translation overflows its assigned column width. Labels are captured
-- into RegisteredLayouts at module file load — before locale force —
-- so the locale-store merge can't reach them on an enUS client. The
-- ModuleLayouts patch applies these directly. The zh-keyed counterparts
-- live in ExwindCoreL for zhCN clients.

local _, ns = ...

ns.Translations.LabelOverrides = {
    -- YYSound (Bloodlust Sound) icon-path label overflows the column seam.
    ["Icon Path/ID |cffff2628Spell ID takes priority if set|r"] =
        "Icon Path/ID |cffff2628(Spell ID wins)|r",

    -- FocusCast row 41 — three adjacent labels overflow into each other.
    ["Hide interruptible bars while interrupt is on cooldown"] =
        "Hide bars on CD",
    ["Interrupt CD Color"] =
        "On-CD Color",
    ["Show when interrupt cooldown is below this many seconds (left color)"] =
        "Left-color threshold (s)",

    -- Description sentence below the row.
    ["Example: when interrupt cooldown reaches 2s, the bar uses the left color and changes when interrupt becomes ready."] =
        "Example: at 2s left, bar shows left color; turns ready color when CD ends.",

    -- BrewmasterStagger cooldownIconEnabled checkbox label.
    ["Enable Elixir of Determination Cooldown Tracking"] =
        "Track Elixir of Determination CD",

    -- MiniTools combat-alert toggle — 1 px under the column edge,
    -- pushed over by sub-pixel font variance.
    ["Enable: show text in the center of the screen when entering/leaving combat"] =
        "Enable: center-screen text on combat enter/leave",
}
