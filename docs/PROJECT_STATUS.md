# PROJECT_STATUS

Project: Cleanup Game
Portfolio status: ACTIVE
Process: SPBT

## Authority model

Documentation authority:
Google Drive / Cleanup Game

Implementation/source-history authority:
GitHub repository FoxyLight/cleanup-prototype

Integration branch:
main

Local working root:
C:\Users\jneal\Documents\Projects\cleanup-prototype

## Frozen Shared Interaction Baseline

Shared Interaction Baseline v0.1.3:
PASS / FROZEN

Frozen values:
- movement speed: 4.5 m/s
- interaction distance: 4.0 m
- cleaning brush radius: 0.22 m
- dirt texel density: 64 texels/m
- cleaning rate: 6.0 dirt units/sec
- cleanable completion threshold: 95%

## Theme Park Restoration

Theme Park Restoration vertical slice:
PASS / CLOSED

Authoritative final integrated implementation SHA:
81694ccc5d1d3fa977bae6940b958dff003992cd

## Movie Studio Cleanup

Frozen slice:
After the Saloon Fight

Frozen total composition:
- 5 cleanables
- 7 DISCARD targets
- 4 RETURN targets
- 2 RESET targets
- 18 total required targets

MS-CP0 — Authority + Slice Contract:
PASS / CLOSED

MS-CP1 — Saloon Shell + Five Cleanables:
PASS / CLOSED

MS-CP1 candidate SHA:
fc61e8f8b865efbe22b969313a2a19e8971590b7

MS-CP1 integrated main SHA:
94717afd774bb0f6ab8b6b394d0b4f3addc97c09

MS-CP1 evidence:
- saloon shell implemented
- exactly five cleanable targets
- shared cleaning system reused
- no DISCARD targets
- no RETURN targets
- no RESET targets
- no Movie Studio progress integration
- no final payoff
- vertical UV stretching on back wall and saloon doors corrected
- automated verification PASS
- protected regressions PASS
- human readability/usability approval PASS
- working tree clean before integration

## Next Evidence Source

Movie Studio MS-CP2 — Seven DISCARD Targets.

MS-CP2 scope:
- add exactly seven obvious discard objects
- one-shot E interaction
- object disappears from the scene on successful discard
- no carrying
- no inventory
- no bins or sorting
- no RETURN targets
- no RESET targets
- no final payoff
- no Shared Interaction Baseline changes

## Current boundary

Theme Park is closed.
MS-CP1 is closed.
MS-CP2 is the next authorized implementation checkpoint.

External Theme Park vs Movie Studio comparison remains deferred until the Movie Studio prototype is implemented and validated.
