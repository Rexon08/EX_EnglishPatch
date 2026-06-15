# Changelog

## v1.0.19

- Translate the global edit-mode toggle chat message, which still printed in Chinese.
- Fix overlapping labels on the Target Alert settings page so every option stays readable.
- Fix a Trash CD setting label that overlapped its seconds input box.

## v1.0.18

- Now works with any subset of the EXWIND addons — enable just EXBoss, or just ExwindTools, without needing the rest.
- A disabled EXWIND addon is simply skipped instead of disabling the English patch entirely.

## v1.0.17

- Performance pass: lower memory use and less combat-time garbage.
- Translation caches are now capped and no longer grow for the duration of a session.
- Center-screen countdown and health-threshold alerts no longer allocate on every display tick.
- Text repaints deferred by combat now coalesce into one update per label instead of one per change.
- Settings-panel font enforcement does one less full panel walk per open and tab switch.

## v1.0.16

- Absorb the latest upstream sync (EXBoss Wago integration, Trinket Monitor, Interrupt Tracker, Dungeon Extras page; MDT module removed upstream).
- The EXBoss changelog panel now shows upstream's own English release notes (new bilingual changelog) instead of an older curated snapshot.
- Center-screen boss health-threshold alerts now render in English.
- Translate the trash-shield-bar toggle on the new Dungeon Extras page.
- The Icon Alert Edit Mode anchor tag now shows "[Icon]" instead of Chinese.

## v1.0.15

- Absorb the latest upstream sync (ExwindCore, ExwindTools, EXBoss, EXBossData).
- Translate the new module-browser search box (search field and the "no matching modules" message).
- Fix the new "Player Heal Absorb" module description, which showed in Chinese on the module list.
- Translate the new Icon Alert settings page (Show Text option and the icon-container description).
- Translate the redesigned EXBoss Home page cards (voice-pack list, donation prompt, config-packaging note, feedback and localization links).
- Translate the Instance Notes and Chat Channel Bar panel headers.

## v1.0.14

- Absorb the latest upstream sync (ExwindCore, ExwindTools, EXBoss, EXBossData).
- Translate the new "Player Shield" module: its on-screen shield monitor and all of its settings (display mode, decimal places, abbreviation, hide-at-zero, text style).
- Translate the new "Tools" tab and the Targeted Alert voice settings (single/multi-target sound toggles, sound pickers, detection delay).
- Translate the new Settings Preset and Built-in Author import/export flows on the Voice Pack and Import / Export pages.
- Translate the updated Devourer Transform Timer description and the boss-activation alert in Algeth'ar Academy.

## v1.0.13

- Absorb the 2026-05-24 upstream sync (EXBoss v26.5.24.1035, ExwindCore and EXBOSS-EXWIND).
- Translate the new Extra Shield Bar feature: its settings page and Edit Mode labels.
- Translate the new "Mythic Mob Casts" nearby-cast monitor, the "About" tab, and the Nexus-Point (NPX) auto-gossip toggle.
- Translate the new Home page entries (Livestream link, Testing Support / Special Thanks credits, localization-contributors note).
- Add English labels for the 84 reworked EXBOSS-EXWIND voice cues and route most to bundled English audio.

## v1.0.12

- Absorb the 2026-05-23 upstream sync (EXBoss v26.5.22.0038, ExwindCore / ExwindTools / EXBossData).
- Translate the new "Targeted Alert" settings page (DPS and Healer enable toggles, icon size, time text settings).
- Translate the new Pull Countdown voice option and its "feature not ready" message.
- Translate the new Maisara Caverns shield panels in Global Settings: the Grim Skirmisher trash panel and the separated Vordaza shield bar, with their position-edit descriptions.
- Translate the "Trash Author Preset" import flow on the Voice Pack page (dropdown label, import button, status messages, confirm dialog) and the matching "Export Trash Author Lua" button on Import / Export.
- Translate the extra locale-force entries on Home (Force zhTW / koKR / deDE / esES / esMX / itIT / ptBR / frFR / ruRU).
- Translate the new Timeline-Style dropdown and the raid-only countdown description on General Overview.
- Translate the new "Show Count" and "Count Text" options on the Devourer Transform Timer panel.
- Translate the new "Icon Mode" display option and its size / seconds-font sliders on the M+ Cast monitor.

## v1.0.11

- Absorb the 2026-05-18 upstream sync (EXBoss v26.5.18.0044, ExwindCore / ExwindTools / EXBossData / EXBOSS-EXWIND).
- Translate the two new strings on EXBoss's Maisara Caverns "Trash Shield Panel" (Trash_248690_AbsorbBar): the Edit-Mode anchor label and the per-bar "Absorb Shield" caption.
- Add English aliases for the eight new EXBOSS-EXWIND voice labels and route them to matching Causese English sound files: Prep Grab, Wake Adds, Watch Step, Control Add, Clear Link, Aim Note, Dodge Repeat, and Approach Boss.

## v1.0.10

- Absorb the 2026-05-17 upstream sync (EXBoss v26.5.17.0431, ExwindCore / EXBossData / EXBOSS-EXWIND).
- Cover EXBoss's mid-release localization rework: upstream removed its built-in English locale file entirely, so the EXBoss settings panels (Global Settings, Boss page, Voice / Config, Import / Export, Trash CD, Conditions, Credits, Changelog, etc.) would have regressed to Chinese on stock 12.0.5. v1.0.10 restores English coverage for ~460 of those strings and adds English for ~50 new strings introduced in v26.5.16 and v26.5.17 (Lindormi's Guidance warning, four reset-mode prompts, "Auto Gossip" page, Edit Mode item picker, Countdown digit toggles, voice fallback removal, etc.).
- Add English aliases for the six new EXBOSS-EXWIND voice labels and route them to the matching Causese English sound files: Prep Dance, Prep Fixate, Summon Clone, Tank Knockback, Watch Knockup, and Stack & Drop.

## v1.0.9

- Absorb the 2026-05-15 upstream sync (EXBoss v26.5.15.0857, ExwindCore / ExwindTools / EXBossData / EXBOSS-EXWIND).
- Translate the new GlobalSettings "Nameplate Icon Strata" dropdown (Background / Low / Medium / High / Fullscreen / Tooltip).
- Translate the new Import / Export rows for built-in Author Lua and Author-Plugin Lua exports (button labels, generated-snippet popups, paste instructions, Boss-slot warning).
- Translate the new Voice Category field on the boss Private Aura detail card.
- Translate Shockwave (1279002) on Araknath in Skyreach.
- Refresh the in-game EXBoss Changelog popup with English entries for v26.5.7 through v26.5.15.

## v1.0.8

- Absorb upstream EXBoss v26.5.9.1813. Boss cast / channel system was reworked upstream and now resolves spell names locale-aware, so EXBoss cast progress bars, ring-progress bars, and the cast-bar "Test Cast / Test Channel" preview render in English without extra patching.
- Translate the new Pit of Saron private aura "Shadow Bomb" (1271679) on Ick and Krick (Shade of Krick).

## v1.0.7

- Absorb the latest EXBoss / EXBossData / ExwindTools upstream sync.
- Translate the new EXBoss Home page "Special Assistance" and "English Localization" credit sections.
- Translate the new "Preset Pack Snippet" export button, popup title, and instructions on the Import / Export page.
- Translate the new TTS voice-source option and TTS Text input label on the Boss spell trigger rows.

## v1.0.6

- Switch CurseForge changelogs to a curated `CHANGES.md` so each release shows clean bullets instead of raw git metadata. No in-game changes.

## v1.0.5

- Translate the EXBoss Credits panel: voice-pack author names, contributor handles, and the Bilibili DM label now render in English instead of as boxes.
- Translate the in-game Changelog popup: ExBoss and ExwindTools changelog bodies now show English content for the recent versions.
- Add a font fallback for any untranslated Chinese strings so they render in a CJK-capable font instead of empty boxes.

## v1.0.4

- Absorb the upstream Exwind sync (EXBoss v26.5.6.0636, ExwindCore/Tools v26.5.6.0515).
- Translate two new boss aura names: "Void Grip" (Alleria, The Voidspire) and "Storm of Grace" (Commander Venel Lightblood, Assault on Quel'Danas).

## v1.0.3

- Close the Windrunner Spire / Trash leak. Spell 1253683 "Spellguard's Protection" added.
- New TrashCD custom-event resolver routes future custom-event registrations through the bridge instead of leaking raw Chinese into the TrashCD detail card.

## v1.0.2

- Absorb the 2026-05-05 EXBoss/EXBossData sync: Derelict Duo and Commander Kroluk encounters, Shredding Talons (1257781), TrashCD custom-event labels.
- Add six new ExwindTools MythicCast indicator labels.

## v1.0.1

- Cover four new ExwindTools strings introduced after the upstream 6.0.0 sync.

## v1.0.0

- Initial public release. Live English overlay for ExwindCore, ExwindTools, EXBossData, EXBoss, and EXBOSS-EXWIND on Midnight 12.0.5. Never writes to user saved variables.
