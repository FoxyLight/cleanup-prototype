# DECISIONS

## D-001 — Adopt SPBT for Cleanup Game
Status: ACCEPTED

## D-002 — Authority split
Status: ACCEPTED

Google Drive is project-documentation authority.
GitHub repository FoxyLight/cleanup-prototype is implementation/source-history authority.

## D-003 — Shared Interaction Baseline freeze
Status: ACCEPTED

Shared Interaction Baseline v0.1.3 remains frozen.

## D-004 — Theme Park Checkpoint 5 closure
Status: ACCEPTED

Checkpoint 5 is PASS / CLOSED.

Authoritative integrated implementation SHA:
797cd169c1e81e3277291af892d5d4014c4acfe2

## D-005 — Final Theme Park payoff scope
Status: ACCEPTED

The final Theme Park checkpoint is limited to the 18-target carousel payoff and preserves the frozen Shared Interaction Baseline.

## D-006 — Saddle accessibility correction
Status: ACCEPTED

Carousel horse saddle face group 21 is excluded from required cleaning because practical access is obstructed by the neck.

This is a bounded accessibility correction. Shared Interaction Baseline v0.1.3 is unchanged.

## D-007 — Final Theme Park payoff closure
Status: ACCEPTED

The final 18-target carousel payoff is PASS / CLOSED.

Candidate commit:
b6b3ae66fc38966832b0899725913b19bb997471

Authoritative integrated implementation SHA:
81694ccc5d1d3fa977bae6940b958dff003992cd

Evidence:
- final-payoff automated tests PASS
- protected regressions PASS
- explicit human approval PASS
- feature candidate committed and pushed
- integration into main completed

Result:
Theme Park Restoration vertical slice is PASS / CLOSED.

## D-008 — Next Evidence Source
Status: ACCEPTED

Prepare the bounded Movie Studio Cleanup implementation checkpoint from the frozen "After the Saloon Fight" design.

Movie Studio implementation has not started. The checkpoint must first be scoped and authorized under SPBT.
