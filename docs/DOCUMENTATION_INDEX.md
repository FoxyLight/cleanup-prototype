# DOCUMENTATION_INDEX

Project: Cleanup Game
Process: SPBT

## Documentation authority

Google Drive folder:
Cleanup Game

Drive folder:
https://drive.google.com/drive/folders/1Js0W5xkTclsVeg6NLTujLn7TvoUeSmTt

Authoritative documents:
- PROJECT_STATUS.md
  https://docs.google.com/document/d/12R0_F_bCBya6-Iy_FY7PkR3bMDx79bPn46qKNcuO2RQ/edit

- DECISIONS.md
  https://docs.google.com/document/d/18RRyNWi7jcvJG1ucyEcN16dJNkdpVt2GsHjFPYtzx30/edit

- DOCUMENTATION_INDEX.md
  https://docs.google.com/document/d/1SHHfQ8CCsBWA9PqV3cmJjJ2jx2sofkAcRkphIzcDMqQ/edit

Google Drive is authoritative for project documentation.

## Implementation/source-history authority

Repository:
FoxyLight/cleanup-prototype

Integration branch:
main

GitHub is authoritative for executable implementation and source history.

Authoritative CP4A implementation baseline:
60a8d203f6681ad21f3548a2d9c30bf779c26914

SPBT onboarding closure commit:
890dc2d

## Repository-local authority copies

Repository paths:
- docs/PROJECT_STATUS.md
- docs/DECISIONS.md
- docs/DOCUMENTATION_INDEX.md

These are synchronized copies of Drive authority at decision/checkpoint boundaries. They do not replace Drive as project-documentation authority.

## Automated verification

- tests/run_tests.gd
  Shared Interaction Baseline regression suite.

- tests/theme_park_loose_mess_tests.gd
  Theme Park loose-mess regression suite.

- tests/theme_park_progress_tests.gd
  Theme Park 18-target progress regression suite.

- tests/theme_park_entrance_cue_tests.gd
  Theme Park Checkpoint 5 Entrance/Plaza cue verification. Present in the current local checkpoint candidate and awaiting repository commit/integration.

## Current checkpoint routing

Validated / closed:
- Shared Interaction Baseline v0.1.3
- Theme Park Checkpoint 1
- Theme Park Checkpoint 2
- Theme Park Checkpoint 3B
- Theme Park Checkpoint 4
- Theme Park Checkpoint 4A

Active:
- Theme Park Checkpoint 5 — IMPLEMENTED / VERIFIED / HUMAN APPROVAL PASS / AWAITING REPOSITORY COMMIT AND INTEGRATION

Not authorized yet:
- final 18-target carousel payoff
- Movie Studio implementation

## Historical evidence

Historical validated recovery tree:
C:\Users\jneal\Downloads\cleanup-prototype-validation

This path is historical evidence only. GitHub now owns implementation/source history.

## Synchronization requirement

At checkpoint closure, update Drive authority and repository-local authority copies to the same checkpoint state and record the immutable integrated main SHA before declaring PASS / CLOSED.
