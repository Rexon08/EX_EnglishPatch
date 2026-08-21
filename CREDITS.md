# Credits and Third-Party Licenses

EX_EnglishPatch is a runtime English overlay for the Exwind / EXBoss WoW
addon family. It is an unofficial fan project; it is not affiliated with,
endorsed by, or maintained by EXWIND.

The release zip is MIT-licensed code plus translation tables derived from
upstream Chinese strings. This file documents each component and the terms
under which it is redistributed.

## Components and licenses

| Component | Path in release zip | License | Author / source |
| --- | --- | --- | --- |
| Addon code | `EX_EnglishPatch/Core/`, `Patches/`, `UI/`, `Tools/`, `EX_EnglishPatch.toc` | **MIT** (`LICENSE`) | EX_EnglishPatch contributors |
| Translation tables | `EX_EnglishPatch/Translations/*.lua` | MIT for the table structure; the English strings are translations of upstream Chinese strings authored by EXWIND (see "Upstream attribution" below) | EX_EnglishPatch contributors, derived from EXWIND source |
| Icon | `EX_EnglishPatch/Textures/Icon.png` | MIT | EX_EnglishPatch contributors |

The components are aggregated in a single zip but are independently
licensed; each is governed by its own license.

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

## Libraries

EX_EnglishPatch does not embed any libraries directly. It interacts with
LibSharedMedia (LSM) and the Blizzard FrameXML API at runtime through
already-loaded host addons; no library bytes are bundled.

## Trademarks

"Exwind", "EXBoss", and "World of Warcraft" are the property of
their respective owners. Their use in this project's documentation is
nominative and descriptive; this project claims no affiliation or
endorsement.

## Reporting an attribution issue

If you are an upstream author and an attribution above is incorrect or
incomplete, open an issue on the project's repository and the maintainers
will correct it promptly.
