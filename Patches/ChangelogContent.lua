---@diagnostic disable: undefined-global
-- Replaces ExBoss / ExwindTools changelog body text with a curated
-- English version. Upstream ships the body as one literal string in
-- {ExBoss,ExwindTools}_MetaData.changelog.content; the renderer reads
-- that field directly without routing through L[...]. With our font
-- enforcement, untranslated zh in this string renders as boxes.
--
-- Maintenance: when a new upstream version adds a section, prepend a
-- new @H1@ block at the top of the relevant constant. Older sections
-- roll off naturally — players who need deep history can read the
-- upstream metadata file.

local _, ns = ...

local StashOriginal = ns.Patches.StashOriginal

local EXBOSS_CHANGELOG_EN = [[
@H1@ v26.5.6.0635

@H2@ Timer Bar Names
- All unrenamed timer bars now display localized names correctly.

@H2@ Localization Fixes
- Thanks to everyone for the international support. We did not expect this level of global popularity, so we are pushing English-coverage fixes today to ensure at least a basic full-English experience.

@H1@ v26.5.5.1951

@H2@ Cast / Ring Fixes
- Fixed Power Vacuum from Echo of Doragosa in Algeth'ar Academy.
- Fixed Searing Quills from Rukhran in Skyreach.

@H2@ Known Issues
- Corespark Detonation from the first boss in The Nexus (NPX) will be fixed in the next update.

@H1@ v26.5.4.1654

@H2@ New Countdown System
- The Countdown settings page now lets you change the sound effects.
- If you enable a 5-second lead countdown without "Play Text", it plays 5, 4, 3, 2, 1 in the final seconds.
- If you enable a 5-second lead countdown with "Play Text", at 6 seconds remaining it plays the label you selected (e.g. "Prepare AOE"), then 5, 4, 3, 2, 1.
- Hands-on test: set a countdown for Decimate on the first boss of Seat of the Triumvirate and try a few times.

@H2@ Windrunner Spire
- Added a shield-cast alert for Spellguard Magus.

@H2@ Maisara Caverns
- Fixed an issue where Dread Souleater could incorrectly trigger voice alerts while casting.
- Added a built-in cooldown for Hexbound Eagle.
- Added a phase-transition shield percentage progress bar for Boss 2, Vordaza (appearance and position inherit from Cast Progress Bar).

@H1@ v26.5.3.1404

@H2@ Trash CD
- Fixed an issue where spells with unique identifying traits were not being inferred immediately at L2.

@H2@ Configuration
- Fixed an issue where importing very old configurations could cause many voice alerts to fail or not work at all.
- If you downloaded EXBOSS a long time ago and voice alerts have been unstable recently, resetting your settings is recommended. This is a legacy issue from early development.

@H2@ Mob Cast Bar
- If no custom rename is set, the cast bar now uses the spell name by default.

@H2@ Ring System
- Added time countdown display.
- Added name display.
- Fixed inaccurate ring timing for Rukhran in Skyreach.

@H1@ v26.5.1.1342

@H2@ Encounter Timeline
- Encounter timelines now use correctly localized spell names on non-Chinese clients when no custom name override is set.

@H2@ Trash CD
- Fixed an issue where some mobs occasionally could not be inferred at L1 after entering combat.

@H2@ Display
- Fixed an issue where boss/trash rings and timer bars could occasionally fail to appear.
- Added icon borders and related settings to the center 5-second countdown text.
- Cast bar text now renders above the border.

@H1@ v26.4.29.2257

@H2@ User Interface
- Added overall panel UI scaling through the dropdown menu in the top-left corner.

@H2@ Localization
- Most content now supports enUS.

@H2@ Boss Spell Settings Page
- Adjusted positions of UI components for better layout compatibility.
- Fixed an issue where cast-start voice alerts could not be delayed properly.
- Fixed incorrect cast bar skill text on non-CN clients.
- Added cast bar renaming.

@H2@ Settings Page
- Added timer bar icon borders to all timer bar related settings.
- All timer bar text layers now render above the borders.

@H2@ Trash CD
- Optimized the logic for detecting when trash mobs enter combat.
- Added mob caching logic to fix cooldown resets when nameplates are lost.

@H2@ Bug Fixes
- Fixed an issue where fallback voice would still play when an LSM source was selected but no voice was chosen, even if the trigger was unchecked. Thanks to @KIRA for the report.

@H2@ Known Issues
- Phalanx-Breaker (232122) in Windrunner Spire still cannot be identified accurately.
- The boss voice pack logic was significantly reworked recently for better accuracy. A small number of skills are currently incompatible and need manual fixes; resolution is expected within the next couple of days.
]]

local EXWINDTOOLS_CHANGELOG_EN = [[
@H1@ v26.5.4.1416

@H2@ Edit Mode System
- All checkbox states are now saved.
- Fixed many cases where positions were not saved after dragging.
- All ExwindTools components are now integrated into the new edit mode system. Please report any issues.

@H2@ Nearby Enemy Cast Monitor
- Added an option to hide boss casts (level 92 enemies).
- If enabled, this option does not hide adds summoned by the boss.

@H1@ v26.5.3.0737

@H2@ Player Stats
- Versatility and movement speed now display correctly in Mythic+ and raid instances.

@H1@ v26.4.23.1800

@H2@ Version Update
- Most APIs have been updated for 12.0.5.

@H2@ ExwindCore — Event Dispatch System
- Split out from ExwindTools.lua to make engine responsibilities clearer.

@H2@ ExwindCore — State Management System
- Player attributes are now protected in 12.0.5, so the delta callback module (including threshold checks) has been removed.
- Known issue: Versatility is the sum of two values; with values currently protected, only the two raw numbers can be shown.
- Known issue: Movement speed can no longer be calculated, so the raw value is displayed for now.
- Note: most other attribute-monitoring addons behave the same way. Attribute protection only takes effect after entering Mythic+, so other stat addons may look fine outside dungeons but error out once a keystone is inserted.

@H2@ ExwindTools — Bloodlust Monitor
- Switched from delta-callback triggering to debuff-based monitoring.

@H2@ ExwindTools — Party Interrupt Tracker
- Blizzard restricted the underlying events, so this is currently non-functional. A temporary fallback that estimates timings is planned within the next couple of days.

@H2@ ExwindTools — Focus Cast / Nearby Enemy Cast Monitor
- Updated for 12.0.5; most error issues fixed.
- Added a 0.1-second in-combat recheck cache so the first cast bar appears even when the server's event order is briefly out of sync.
- (12.0.5) Updated number display: durations under 10 seconds show decimals; very long durations show values like "7 days".

@H1@ v26.4.18.1328

@H2@ Major Update
- EXBOSS now supports trash cooldowns and voice alerts. Search "EXBOSS" on the major addon platforms to download.
- EXBOSS shares the same low-level engine with ExwindTools, reducing duplicate data overhead and improving performance.

@H2@ Announcement
- Over the past few weeks, ExwindTools has been impacted by Blizzard changes, and many features will see fluctuations in 12.0.5. We expect to fix or temporarily disable the most critical functions on launch day and continue restoring them afterwards.

@H2@ No-Movement-Skill Reminder
- Added DH, Paladin, and Evoker.

@H2@ Brewmaster Stagger Bar
- Adjusted text layering.
- Added an option to hide on mounts.

@H2@ Donation Section
- Added a small donation link on the home page, following standard addon practices — no spammy banners.
- ExwindTools and ExBoss are free projects with no paid tier or premium subscription. The version everyone uses is the same regardless of donations.

@H1@ v26.4.5.2019

@H2@ Announcement
- We will begin rolling out more complete enUS and additional locale support over the next week.
- A dedicated locale GitHub repository is planned for translation maintenance. A more detailed plan will follow.

@H2@ [New Feature] Instance Notes
- Disabled by default.
- Add text notes for dungeons and specific bosses; they appear in the matching dungeon or boss encounter.

@H2@ [New Feature] Auto Dialogue
- Enabled by default.
- The addon adds a green + button to the right of in-game dialogue options. Clicking it adds that option to the auto dialogue list.

@H2@ Mythic+ Damage Simulation
- Recalibrated the value multipliers.
- Now correctly distinguishes between trash mob and boss damage multipliers.
- After a second verification pass against WCL, current accuracy is 99.99%.

@H2@ PVE Panel (right of the Mythic+ score page)
- Added detection for the Raider.IO panel; when present, this panel now anchors to its right side.

@H2@ Mythic+ Score Statistics Panel (title cutoff panel opened from PVE Panel)
- Fixed the total CN player population calculation logic.
]]

local function ApplyChangelog(globalName, englishContent)
    local meta = rawget(_G, globalName)
    if type(meta) ~= "table" then return false end
    local cl = meta.changelog
    if type(cl) ~= "table" then return false end
    if type(cl.content) ~= "string" or cl.content == "" then return false end

    StashOriginal(cl, "content")
    cl.content = englishContent
    return true
end

local function PatchExBossChangelog()
    if ns.IsMarked("ChangelogContent", "ExBoss") then return end
    if ApplyChangelog("ExBoss_MetaData", EXBOSS_CHANGELOG_EN) then
        ns.Mark("ChangelogContent", "ExBoss")
        ns.Log("ChangelogContent: ExBoss_MetaData.changelog.content -> EN")
    end
end

local function PatchExwindToolsChangelog()
    if ns.IsMarked("ChangelogContent", "ExwindTools") then return end
    if ApplyChangelog("ExwindTools_MetaData", EXWINDTOOLS_CHANGELOG_EN) then
        ns.Mark("ChangelogContent", "ExwindTools")
        ns.Log("ChangelogContent: ExwindTools_MetaData.changelog.content -> EN")
    end
end

ns.Patches.RegisterPostInit { deps = "exboss",     apply = PatchExBossChangelog }
ns.Patches.RegisterPostInit { deps = "exwindcore", apply = PatchExwindToolsChangelog }

ns.Patches.PatchExBossChangelog = PatchExBossChangelog
ns.Patches.PatchExwindToolsChangelog = PatchExwindToolsChangelog
