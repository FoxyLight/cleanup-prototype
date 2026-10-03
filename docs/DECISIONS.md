# DECISIONS

## D-001 — Adopt SPBT for Cleanup Game
Status: ACCEPTED

Cleanup Game uses SPBT for authority, checkpoint verification, explicit human approval, integration, immutable implementation identity, and closure.

## D-002 — Authority split
Status: ACCEPTED

Google Drive is project-documentation authority.
GitHub repository FoxyLight/cleanup-prototype is implementation/source-history authority.

## D-003 — Shared Interaction Baseline freeze
Status: ACCEPTED

Shared Interaction Baseline v0.1.3 remains frozen.

## D-004 — Theme Park Restoration closure
Status: ACCEPTED

Theme Park Restoration vertical slice is PASS / CLOSED.

Authoritative final integrated implementation SHA:
81694ccc5d1d3fa977bae6940b958dff003992cd

## D-005 — Movie Studio slice contract
Status: ACCEPTED

The Movie Studio slice is "After the Saloon Fight".

Frozen composition:
- 5 cleanables
- 7 DISCARD targets
- 4 RETURN targets
- 2 RESET targets
- 18 total required targets

Distinctive cleanup classification:
CLEAN / DISCARD / RETURN / RESET

Shared Interaction Baseline v0.1.3 remains frozen.

## D-006 — Movie Studio checkpoint sequence
Status: ACCEPTED

Movie Studio implementation proceeds:
MS-CP1 Saloon Shell + Five Cleanables
MS-CP2 Seven DISCARD Targets
MS-CP3 Four RETURN Targets
MS-CP4 Two RESET Targets
MS-CP5 18-Target Progress Integration
MS-CP6 Final Set Recovery Payoff

## D-007 — MS-CP1 closure
Status: ACCEPTED

Movie Studio MS-CP1 is PASS / CLOSED.

Candidate SHA:
fc61e8f8b865efbe22b969313a2a19e8971590b7

Authoritative integrated main SHA:
94717afd774bb0f6ab8b6b394d0b4f3addc97c09

## D-008 — MS-CP2 scope
Status: ACCEPTED

MS-CP2 is limited to exactly seven obvious discard objects.

Behavior:
- one-shot E interaction
- object disappears on successful discard
- no carrying
- no bins
- no sorting
- no inventory
- no RETURN
- no RESET
- no final payoff
- no shared-baseline changes

## D-009 — MS-CP2 closure
Status: ACCEPTED

Movie Studio MS-CP2 is PASS / CLOSED.

Candidate SHA:
38a23ecfe61eec9517885320ec29e374f0c55bb7

Authoritative integrated main SHA:
6c75ebac1a3aa686ce34bc813104b8b1f8d5b0cd

Evidence:
- exactly seven DISCARD targets
- automated verification PASS
- protected regressions PASS
- explicit human approval PASS
- duplicate completion rejected
- reset behavior verified
- Godot UID files tracked
- clean candidate integrated into main

## D-010 — Next Evidence Source
Status: ACCEPTED

The next authorized checkpoint is MS-CP3 — Four RETURN Targets.

MS-CP3 must:
- add exactly four reusable props
- use the existing carry/place interaction
- provide one readable destination for each prop
- complete a target only on successful return placement
- add no RESET targets
- add no progress integration
- add no final payoff
- preserve Shared Interaction Baseline v0.1.3
