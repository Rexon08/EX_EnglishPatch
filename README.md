# EX_EnglishPatch

Runtime English overlay for the **Exwind / EXBoss** WoW addon family
on **Midnight 12.1**.

## Highlights

- **Pure overlay, not a fork.** Translations apply at runtime via
  `hooksecurefunc` and additive locale merges; the upstream Chinese
  addons stay byte-for-byte intact, so addon-manager auto-updates
  keep working with no merge step.
- **Zero writes to user databases.** Never touches `EXTOOLS12S2`,
  `EXBOSS12S2`, or `EXBossDataDB`. Uninstall is clean.
- **English voice labels.** Audio itself comes from upstream's own
  `EXBOSS-ENG` pack, which EXBoss selects on English clients; we
  translate the label text that names each cue.
- **Tiny CPU footprint** — AddOnProfiler peak 0.865 ms /
  total < 0.1 %.
- **Taint-safe.** No `forceinsecure()`, no method replacement on
  Blizzard tables; combat-time text changes queue and apply on
  `PLAYER_REGEN_ENABLED`.

Works with any subset of `ExwindCore`, `ExwindTools`, `EXBossData`,
`EXBoss`, and the voice packs. They are `## OptionalDeps` — each
enabled one loads before this addon and gets translated; disabled ones
are simply skipped. With none enabled the patch loads and does nothing.

## License

See [`CREDITS.md`](CREDITS.md): addon code MIT, translation overlay
attributed to EXWIND under CC BY-NC-ND 4.0.
