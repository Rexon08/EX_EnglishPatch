# Changelog

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
