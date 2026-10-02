# PROJECT_STATUS

Project: Cleanup Game
Portfolio status: ACTIVE
Process: SPBT

## Authority model

Documentation authority:
Google Drive / Cleanup Game

Authoritative Drive documents:
- PROJECT_STATUS.md
- DECISIONS.md
- DOCUMENTATION_INDEX.md

Implementation/source-history authority:
GitHub repository FoxyLight/cleanup-prototype

Integration branch:
main

Local working root:
C:\Users\jneal\Documents\Projects\cleanup-prototype

## Immutable repository baseline

Authoritative CP4A implementation baseline SHA:
60a8d203f6681ad21f3548a2d9c30bf779c26914

SPBT onboarding closure commit:
890dc2d

Shared Interaction Baseline v0.1.3:
PASS / FROZEN

Frozen values:
- movement speed: 4.5 m/s
- interaction distance: 4.0 m
- cleaning brush radius: 0.22 m
- dirt texel density: 64 texels/m
- cleaning rate: 6.0 dirt units/sec
- cleanable completion threshold: 95%

## Theme Park Restoration state

Closed historical checkpoints:
- Checkpoint 1: PASS
- Checkpoint 2: PASS
- Checkpoint 3B: PASS
- Checkpoint 4: PASS
- Checkpoint 4A: PASS

Validated content:
- 8 cleanable surfaces
- 7 litter objects
- 3 debris clusters
- 18 total required targets

Additional validated findings:
- carousel horse accessibility: PASS
- carousel horse practical full-clean time: approximately 58 seconds, accepted
- table UV correction: PASS
- bench UV correction: PASS
- 18-target progress integration: PASS

## Active checkpoint

Checkpoint:
Theme Park Checkpoint 5 — Entrance/Plaza Local Completion Cue

State:
IMPLEMENTED / VERIFIED / HUMAN APPROVAL PASS / AWAITING REPOSITORY COMMIT AND INTEGRATION

Authorized behavior:
- cue requires both entrance_paving and entrance_sign
- either completion order works
- cue triggers once per completion cycle
- existing 18-target progress controller remains authoritative
- payoff is local to the entrance sign
- reset clears the cue and permits a fresh trigger
- frozen Shared Interaction Baseline remains unchanged

Automated verification:
- Godot parse/load integrity: PASS
- Theme Park entrance cue tests: PASS
- Theme Park progress regression: PASS
- Theme Park loose-mess regression: PASS
- Shared Interaction Baseline regression: PASS

Human approval:
- entrance paving gating: PASS
- entrance sign gating: PASS
- order independence: PASS
- one-shot local cue: PASS
- local visual payoff: PASS
- fresh-run/reset presentation: PASS
- no unintended gameplay regression observed

Candidate checkpoint commit SHA:
NOT YET ESTABLISHED

Integrated main SHA:
NOT YET ESTABLISHED

## Movie Studio Cleanup

Design exists.
Implementation is not authorized during the active Theme Park checkpoint.

## Next Evidence Source

Establish the exact Checkpoint 5 candidate commit on the feature branch, push it, integrate it into main after the approved verification state, capture the immutable integrated main SHA, then update Drive and repository authority copies and mark Checkpoint 5 PASS / CLOSED.

## Current boundary

Do not begin:
- final 18-target carousel payoff
- Movie Studio implementation
- changes to Shared Interaction Baseline v0.1.3

until Checkpoint 5 is integrated and closed under SPBT.
