# EX_EnglishPatch

Runtime English overlay for the **Exwind / EXBoss** addon family on
World of Warcraft **Midnight 12.0.5**.

```
zh source addons   ─►   EX_EnglishPatch   ─►   English UI on screen
                            (overlay only)
                                  │
            saved variables (ExBossDB, ExwindToolsDB) untouched
```

## Highlights

- **Pure overlay, not a fork.** Translations apply at runtime via
  `hooksecurefunc` and additive locale merges. The upstream Chinese
  addons stay byte-for-byte intact, so addon-manager auto-updates
  keep working — no merge step, no version pinning, no manual
  re-translation after every upstream release.
- **Zero writes to user databases.** Never touches `ExwindToolsDB`,
  `ExBossDB`, or `EXBossDataDB`. The only saved variable owned by
  this addon is `EX_EnglishPatchDB` (three checkboxes). Uninstall
  is clean — no orphan locale state in your existing SavedVariables.
- **Bundled English voice pack** (Causese, GPL). 202 `.ogg` files;
  the default Exwind voice pack is auto-flipped to English on first
  load without any saved-variable migration.
- **Tiny CPU footprint.** AddOnProfiler peak **0.865 ms /
  total < 0.1 %**.
- **Taint-safe.** No `forceinsecure()`, no method replacement on
  Blizzard tables, no `SetText` / `SetWidth` / `SetPoint` during
  combat lockdown. Combat-time text changes queue and apply on
  `PLAYER_REGEN_ENABLED`.
- **Resilient to upstream changes.** A static preflight (lint,
  sandbox loadtest, resolver probe, untranslated-key audit,
  data-table drift, upstream sha256 manifest) flags renamed or
  removed hook targets after every upstream pull, so silent
  regressions surface before reload.

## What it translates

| Layer | Where | Strategy |
| --- | --- | --- |
| Locale stores | `L[...]` lookups in source | Additive enUS merge + non-persisting force-locale |
| Generated data | Map / boss / event names in `EXBossData` | In-place mutation, originals preserved under `_eb_orig_<field>` |
| Voice labels | Chinese label catalog | LSM alias registration + `LabelCatalog` wrap |
| Voice audio | Default-pack `.ogg` | LSM hash table re-points at English files |
| Static popups | `StaticPopupDialogs[...]` | Pre-populated before lazy init |
| Render-time text | Boss page, panel tabs, dropdowns, M+ Spell Info, center alerts | `hooksecurefunc` on render methods + `SetText` hooks |

## Compatibility

- **WoW Midnight 12.0.5** (TOC `120005, 120001`).
- Required addons (loaded first via `## RequiredDeps`):
  `ExwindCore`, `ExwindTools`, `EXBossData`, `EXBoss`, `EXBOSS-EXWIND`.
- Lua 5.1 (FrameXML runtime).

## Install

1. Download or clone the repo.
2. Drop the `EX_EnglishPatch/` folder into
   `World of Warcraft/_retail_/Interface/AddOns/`.
3. Make sure the five Exwind/EXBoss addons are also installed.
4. Launch WoW. The overlay auto-loads after the target addons.
5. **Settings → AddOns → "EX English Patch"**, or click the addon's
   minimap-compartment entry.

## Settings

Three checkboxes — no slash commands. Translation issues are visible
on screen, so there is no runtime diagnostic to gate behind a dev flag.

| Toggle | Effect |
| --- | --- |
| Enable English overlay | Master switch (off = stop translating on next `/reload`) |
| Resize widgets to fit English | Adjust label widths on supported pages so longer text doesn't clip |
| Show English voice labels | Offer English aliases in voice pickers (existing zh-saved selections keep playing) |

## License

A composite of three licenses — full breakdown in
[`CREDITS.md`](CREDITS.md):

| Component | License |
| --- | --- |
| Addon code (`Core/`, `Patches/`, `UI/`, `Translations/`, TOC, icon) | **MIT** ([`LICENSE`](LICENSE)) |
| Voice pack (`sound/*.ogg`) — Causese English | **GNU GPL** ([`sound/LICENSE.txt`](sound/LICENSE.txt)) |
| Translation overlay of upstream Chinese display strings | derivative work, distributed for non-commercial overlay use only with attribution to EXWIND (CC BY-NC-ND 4.0) |

The components are aggregated in a single zip but are independently
licensed (GPL § "mere aggregation"). EX_EnglishPatch does **not**
redistribute any EXWIND source files; users obtain the upstream
addons independently from EXWIND.

## Acknowledgements

- **EXWIND** — author of the Exwind / EXBoss addon family this
  overlay translates.
- **Causese** — author of the bundled English voice pack.
- Maintainers of [warcraft.wiki.gg](https://warcraft.wiki.gg) for the
  canonical Midnight 12.0.x API reference.

This is an unofficial fan project. Not affiliated with, endorsed by,
or maintained by EXWIND or Causese.
