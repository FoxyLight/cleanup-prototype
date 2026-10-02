# DECISIONS

## D-001 — Adopt SPBT for Cleanup Game
Status: ACCEPTED

Cleanup Game uses SPBT for authority, checkpoint verification, explicit human approval, integration, immutable implementation identity, and closure.

## D-002 — Split documentation and implementation authority
Status: ACCEPTED

Google Drive is the project-documentation authority.

GitHub repository FoxyLight/cleanup-prototype is the implementation/source-history authority.

Repository-local copies of PROJECT_STATUS.md, DECISIONS.md, and DOCUMENTATION_INDEX.md mirror Drive authority at decision and checkpoint boundaries.

## D-003 — Historical CP4A recovery
Status: ACCEPTED

The historically validated implementation at:
C:\Users\jneal\Downloads\cleanup-prototype-validation

was used as the recovery source during existing-project onboarding.

Material drift in project.godot and scenes/neutral_test.tscn was rejected. The validated implementation was restored and verified before repository authority was established.

## D-004 — Shared Interaction Baseline freeze
Status: ACCEPTED

Shared Interaction Baseline v0.1.3 remains frozen.

Frozen values:
- movement speed: 4.5 m/s
- interaction distance: 4.0 m
- cleaning brush radius: 0.22 m
- dirt texel density: 64 texels/m
- cleaning rate: 6.0 dirt units/sec
- cleanable completion threshold: 95%

Changing these values requires explicitly reopening the baseline decision.

## D-005 — Theme Park historical checkpoint authority
Status: ACCEPTED

Theme Park checkpoints through Checkpoint 4A are accepted as validated historical evidence and were reconciled to the recovered implementation tree.

Authoritative CP4A implementation baseline:
60a8d203f6681ad21f3548a2d9c30bf779c26914

## D-006 — Portfolio state
Status: ACCEPTED

Cleanup Game portfolio state:
ACTIVE

## D-007 — Theme Park Checkpoint 5 scope
Status: ACCEPTED

Checkpoint 5 is limited to the Entrance/Plaza local completion cue.

The cue:
- requires entrance_paving and entrance_sign completion
- works in either completion order
- triggers only once per completion cycle
- reuses the existing 18-target progress state
- provides a restrained local visual response on the entrance sign
- resets cleanly
- does not introduce the final carousel payoff
- does not alter the frozen Shared Interaction Baseline
- does not authorize Movie Studio implementation

## D-008 — Theme Park Checkpoint 5 closure
Status: ACCEPTED

Checkpoint 5 is PASS / CLOSED.

Evidence:
- parse/load integrity PASS
- dedicated entrance cue tests PASS
- Theme Park progress regression PASS
- Theme Park loose-mess regression PASS
- Shared Interaction Baseline regression PASS
- explicit human approval PASS
- feature candidate committed and pushed
- feature integrated into main
- final repository hygiene clean
- Godot test UID tracked

Checkpoint 5 candidate commit:
1f9711e

Merge commit:
4a0b941

Authoritative integrated implementation SHA:
797cd169c1e81e3277291af892d5d4014c4acfe2

## D-009 — Authority synchronization rule
Status: ACCEPTED

At project-decision and checkpoint-closure boundaries:
1. Drive authority documents are updated to the verified state.
2. Repository-local authority copies are reconciled to that state.
3. Immutable implementation SHA is recorded where implementation identity matters.
4. A checkpoint is not PASS / CLOSED while either authority surface materially contradicts the other.

## D-010 — Next authorized Theme Park checkpoint
Status: ACCEPTED

The next authorized checkpoint is the final 18-target carousel payoff.

Its design remains bounded to the already frozen payoff direction:
- carousel bulbs illuminate
- a short musical phrase plays
- the carousel horse makes one gentle vertical movement
- trigger only when all 18 required targets are complete

This decision does not authorize Movie Studio implementation or changes to the frozen Shared Interaction Baseline.
