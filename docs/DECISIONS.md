# DECISIONS

## D-001 — Adopt SPBT for Cleanup Game

Status: ACCEPTED

Cleanup Game uses the current SPBT workflow for repository authority, checkpoint verification, human approval, immutable implementation baselines, and project-state tracking.

## D-002 — Repository authority

Status: ACCEPTED

Authoritative repository:
FoxyLight/cleanup-prototype

Integration branch:
main

Local working root:
C:\Users\jneal\Documents\Projects\cleanup-prototype

## D-003 — Historical CP4A recovery

Status: ACCEPTED

The historically validated implementation from:

C:\Users\jneal\Downloads\cleanup-prototype-validation

was used as the recovery source for existing-project onboarding.

The candidate repository initially contained material implementation drift in:
- project.godot
- scenes/neutral_test.tscn

Those candidate files were not promoted.

The validated historical implementation was restored and then verified before repository authority was established.

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

Changes to these values require explicit reopening of the baseline decision.

## D-005 — Theme Park historical checkpoint authority

Status: ACCEPTED

Historically validated Theme Park checkpoints through Checkpoint 4A are accepted as historical evidence and have been reconciled with the recovered implementation tree.

Checkpoint 5 is not part of this baseline and must proceed as a new SPBT implementation checkpoint.

## D-006 — Project portfolio state

Status: ACCEPTED

Cleanup Game portfolio status:
ACTIVE
