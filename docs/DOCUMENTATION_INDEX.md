# DOCUMENTATION_INDEX

Project: Cleanup Game
Process: SPBT

## Documentation authority

Google Drive folder:
Cleanup Game

Drive folder:
https://drive.google.com/drive/folders/1Js0W5xkTclsVeg6NLTujLn7TvoUeSmTt

Authoritative Drive documents:
- PROJECT_STATUS.md
- DECISIONS.md
- DOCUMENTATION_INDEX.md

Google Drive is authoritative for project documentation.

## Implementation/source-history authority

Repository:
FoxyLight/cleanup-prototype

Integration branch:
main

GitHub is authoritative for executable implementation and source history.

Theme Park final integrated implementation SHA:
81694ccc5d1d3fa977bae6940b958dff003992cd

Movie Studio MS-CP1 candidate SHA:
fc61e8f8b865efbe22b969313a2a19e8971590b7

Movie Studio MS-CP1 integrated main SHA:
94717afd774bb0f6ab8b6b394d0b4f3addc97c09

Movie Studio MS-CP2 candidate SHA:
38a23ecfe61eec9517885320ec29e374f0c55bb7

Movie Studio MS-CP2 integrated main SHA:
6c75ebac1a3aa686ce34bc813104b8b1f8d5b0cd

## Repository-local authority copies

- docs/PROJECT_STATUS.md
- docs/DECISIONS.md
- docs/DOCUMENTATION_INDEX.md

## Automated verification

Shared:
- tests/run_tests.gd

Theme Park:
- tests/theme_park_loose_mess_tests.gd
- tests/theme_park_progress_tests.gd
- tests/theme_park_entrance_cue_tests.gd
- tests/theme_park_final_payoff_tests.gd

Movie Studio:
- tests/movie_studio_cp1_tests.gd
- tests/movie_studio_cp2_tests.gd

## Current checkpoint routing

PASS / CLOSED:
- Shared Interaction Baseline v0.1.3
- Theme Park Restoration vertical slice
- Movie Studio MS-CP0 — Authority + Slice Contract
- Movie Studio MS-CP1 — Saloon Shell + Five Cleanables
- Movie Studio MS-CP2 — Seven DISCARD Targets

Next authorized:
- Movie Studio MS-CP3 — Four RETURN Targets

Not yet implemented:
- MS-CP3 RETURN
- MS-CP4 RESET
- MS-CP5 18-target progress integration
- MS-CP6 final set recovery payoff
- external Theme Park vs Movie Studio comparison

## Synchronization state

Drive authority and repository-local authority copies record MS-CP2 closure at integrated SHA 6c75ebac1a3aa686ce34bc813104b8b1f8d5b0cd.
