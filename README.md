# EX_EnglishPatch

Runtime English overlay for the **Exwind / EXBoss** WoW addon family
on **Midnight 12.0.5**.

## Highlights

- **Pure overlay, not a fork.** Translations apply at runtime via
  `hooksecurefunc` and additive locale merges; the upstream Chinese
  addons stay byte-for-byte intact, so addon-manager auto-updates
  keep working with no merge step.
- **Zero writes to user databases.** Never touches `ExwindToolsDB`,
  `ExBossDB`, or `EXBossDataDB`. Uninstall is clean.
- **Bundled English voice pack** (Causese, GPL) — 202 `.ogg` files;
  the default Exwind voice pack auto-flips to English on first load
  without any saved-variable migration.
- **Tiny CPU footprint** — AddOnProfiler peak 0.865 ms /
  total < 0.1 %.
- **Taint-safe.** No `forceinsecure()`, no method replacement on
  Blizzard tables; combat-time text changes queue and apply on
  `PLAYER_REGEN_ENABLED`.

Requires `ExwindCore`, `ExwindTools`, `EXBossData`, `EXBoss`, and
`EXBOSS-EXWIND` (loaded first via `## RequiredDeps`).

## License

Composite of three licenses — see [`CREDITS.md`](CREDITS.md): addon
code MIT, voice pack GPL, translation overlay attributed to EXWIND
under CC BY-NC-ND 4.0.

Unofficial fan project. Not affiliated with EXWIND or Causese.
