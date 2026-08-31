# Functional baseline: rule-set consolidation cycle

Date: 2026-08-31. Scope: always-on rule surface (rules/, CLAUDE.md, skill descriptions,
bin/lint-section-refs.sh, .aiassistant/state/proposals/).

## Surfaces and how they are verified

This repository has no runtime. Its "execution surfaces" are the integrity gates that
decide whether the rule-set loads correctly and whether a commit is accepted.

| Surface | Invocation | Expected result | Verified 2026-08-31 |
|---|---|---|---|
| Cross-ref / ledger / budget lint | `bash bin/lint-section-refs.sh` | `REF-LINT: ok`, exit 0 | PASS |
| agnix, hook scope (authoritative) | `npx agnix@0.40.0 validate plugins/marketplaces/local/plugins rules` | 0 errors, 17 warnings, exit 0 | PASS |
| agnix, CLAUDE.md alone | `npx agnix@0.40.0 validate CLAUDE.md` | 0 errors, 10 warnings, exit 0 | PASS |
| pre-commit gate | `.githooks/pre-commit` (core.hooksPath=.githooks) | runs the two above, blocks on error | PASS (read, not fired) |

Baseline token estimates (chars/3.8), the figures every change in this cycle moves:

    General.md      10272 / 10500 budget
    Meta.md          4188 / 4500
    CLAUDE.md        3055 / 3100
    Persona.md        476 / 1000
    Organisation.md   478 / 600
    skill descriptions (27, local plugins)  ~3560  NOT BUDGETED

## Scope-dependent agnix finding (not a defect)

`npx agnix validate rules/ CLAUDE.md` reports 1 error:
`CLAUDE.md:53:1 Import path escapes project root: @CLAUDE.local.md`.

Reach of that observation: it appears only when a directory argument precedes CLAUDE.md,
which moves agnix's derived project root. `validate CLAUDE.md` alone and the hook scope are
both clean. `CLAUDE.local.md` exists next to CLAUDE.md and is gitignored by design.
Error counts across scopes are non-monotonic (rules/+CLAUDE.md = 1, local/+CLAUDE.md = 5,
all three = 1), which is consistent with scope-dependent reference resolution rather than a
file defect. Do NOT "fix" the import.

## Known-broken / not verifiable

None. No surface was classified as pre-existing breakage.

## Comparison rule for Phase 6

After every change-set: both authoritative gates above must return exit 0, and the budget
table in `bin/lint-section-refs.sh` must pass for every budgeted file. A budget lowered in
this cycle becomes part of the baseline from that commit onward.
