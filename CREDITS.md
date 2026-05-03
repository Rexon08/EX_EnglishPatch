# Credits and Third-Party Licenses

EX_EnglishPatch is a runtime English overlay for the Exwind / EXBoss WoW
addon family. It is an unofficial fan project; it is not affiliated with,
endorsed by, or maintained by EXWIND or Causese.

The release zip is a composite of materials under three different licenses.
This file documents each component and the terms under which it is
redistributed.

## Components and licenses

| Component | Path in release zip | License | Author / source |
| --- | --- | --- | --- |
| Addon code | `EX_EnglishPatch/Core/`, `Patches/`, `UI/`, `Tools/`, `EX_EnglishPatch.toc` | **MIT** (`LICENSE`) | EX_EnglishPatch contributors |
| Translation tables | `EX_EnglishPatch/Translations/*.lua` | MIT for the table structure; the English strings are translations of upstream Chinese strings authored by EXWIND (see "Upstream attribution" below) | EX_EnglishPatch contributors, derived from EXWIND source |
| Voice pack | `EX_EnglishPatch/sound/*.ogg` | **GNU GPL** | Causese ("Causese English" voice pack) |
| Icon | `EX_EnglishPatch/Textures/Icon.png` | MIT | EX_EnglishPatch contributors |

The components are aggregated in a single zip but are independently
licensed. GPL Section 2 ("mere aggregation") applies: bundling GPL audio
samples with MIT-licensed code in the same archive does not relicense the
code, and does not require recipients of the code to accept GPL terms for
the code. Each component is governed by its own license.

## Upstream attribution (Exwind / EXBoss family)

This overlay reads from and translates display strings authored by EXWIND
in the following addons:

- `ExwindCore`
- `ExwindTools`
- `EXBossData`
- `EXBoss`
- `EXBOSS-EXWIND`

Those addons are published by EXWIND under
**Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International
(CC BY-NC-ND 4.0)**. Their license text is preserved at
`addons/upstream/ExwindTools/License.txt` in the source repository.

- Author: EXWIND
- License: <https://creativecommons.org/licenses/by-nc-nd/4.0/>
- Copyright (c) 2025–2026 EXWIND. All rights reserved.

EX_EnglishPatch does not redistribute any EXWIND source files. The release
zip contains only the `EX_EnglishPatch/` directory and does not include the
upstream addons themselves; users obtain those independently from EXWIND.

The English strings in `Translations/*.lua` are translations of upstream
Chinese display strings. Translation is treated under CC BY-NC-ND 4.0 as a
form of derivative work. We distribute these strings:

- with attribution to EXWIND as the original author, in this file;
- for non-commercial use only;
- in the form of a text-only translation table, used at runtime as an
  overlay; we do not redistribute or modify EXWIND's source files.

If EXWIND objects to this translation overlay or this attribution, please
open an issue on the project's repository; the maintainers will respond.

## Voice pack attribution (Causese)

The 202 `.ogg` files under `sound/` are the "Causese English" voice pack
authored by Causese and released under the **GNU General Public License**.

- Author: Causese
- License: GNU GPL — <https://www.gnu.org/licenses/gpl-3.0.html>
- Component: voice samples (`sound/*.ogg`)

The pack is bundled here under the GPL's "mere aggregation" provision
(Section 2). A copy of the GPL applies to the voice samples only; the rest
of the addon is MIT-licensed. Replacing or removing `sound/` does not
affect the licensing or operation of the addon code.

If you redistribute the voice samples (with or without the rest of this
addon), you must comply with the GPL terms — including providing
attribution to Causese and either including a copy of the GPL or a link to
it.

## Libraries

EX_EnglishPatch does not embed any libraries directly. It interacts with
LibSharedMedia (LSM) and the Blizzard FrameXML API at runtime through
already-loaded host addons; no library bytes are bundled.

## Trademarks

"Exwind", "EXBoss", "Causese", and "World of Warcraft" are the property of
their respective owners. Their use in this project's documentation is
nominative and descriptive; this project claims no affiliation or
endorsement.

## Reporting an attribution issue

If you are an upstream author and an attribution above is incorrect or
incomplete, open an issue on the project's repository and the maintainers
will correct it promptly.
