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

External concept comparison remains deferred until the Movie Studio slice is implemented and validated.

## D-007 — MS-CP1 scope
Status: ACCEPTED

MS-CP1 is limited to:
- Western saloon aftermath shell
- exactly five dirty cleanable surfaces
- reuse of the existing shared cleaning system
- no DISCARD, RETURN, RESET, final payoff, or shared-baseline changes

## D-008 — MS-CP1 vertical UV correction
Status: ACCEPTED

During MS-CP1 human review, the saloon doors and back-wall cleanables showed stretched cleaning marks.

The Movie Studio vertical cleanable geometry was corrected so world X maps to UV U and world Y maps to UV V.

This is a bounded MS-CP1 presentation/accessibility correction and does not change Shared Interaction Baseline v0.1.3.

## D-009 — MS-CP1 closure
Status: ACCEPTED

Movie Studio MS-CP1 is PASS / CLOSED.

Candidate SHA:
fc61e8f8b865efbe22b969313a2a19e8971590b7

Authoritative integrated main SHA:
94717afd774bb0f6ab8b6b394d0b4f3addc97c09

Evidence:
- exactly five cleanables
- MS-CP1 automated tests PASS
- protected regressions PASS
- vertical UV correction PASS
- explicit human approval PASS
- Godot UID files tracked
- clean candidate integrated into main

## D-010 — Next Evidence Source
Status: ACCEPTED

The next authorized checkpoint is MS-CP2 — Seven DISCARD Targets.

MS-CP2 must:
- add exactly seven obvious discard objects
- use one-shot E interaction
- remove the object immediately on successful discard
- add no carrying, bins, sorting, inventory, RETURN, RESET, final payoff, or shared-baseline changes
