# Paket 5: close the always-on budget gap

Status: designed, NOT applied. The single largest finding of the 2026-08-31 session.
Independent of Pakete 1-4, but do it BEFORE the freed budget invites refilling.

## State as of 2026-08-31, after Paket 2

Paket 2 is applied (commit `7743a40`) and freed no budget, so every measurement below is
unchanged and still current. Two things changed for this package:

- The active proposal store is now the consolidation record
  (`.aiassistant/state/proposals/proposal-2026-08-31-verification-reach-consolidation.md`)
  plus the guided-gui proposal. That record is the entry point for everything under
  `proposals/done/`, and it is where any finding of this package belongs that is not applied
  in the same session. `proposals/README.md` now carries the `superseded` status and its
  mandatory `Superseded by:` pointer.
- The record's carried open item 4 (guard pattern precision) is an always-on addition to
  `General.md` §5.6 waiting for budget, and its carried open item 8 wants one sentence in
  `Meta.md` §2.2. Both compete with §1.6 for the same reserve, so this package decides
  whether they are affordable, not Paket 1.

Adjacent finding, made while executing Paket 2 and explicitly NOT part of this package:
`CLAUDE.md` states that agnix validates memory files in the pre-commit hook. It cannot.
`projects/` is gitignored (`.gitignore:32`), so memory files are untracked, and the hook's
scope is `plugins/marketplaces/local/plugins rules`. Widening the scope does not fix it.
Carried as open item 10 in the record.

## The finding

Meta.md §3.3 names three always-on surfaces: "[CRITICAL] rule files, the CLAUDE.md index,
skill descriptions". `bin/lint-section-refs.sh` Check 6 budgets FIVE FILES and nothing else.
Measured 2026-08-31 (chars*10/38, the script's own formula):

  rules/General.md        10272 / 10500   budgeted
  rules/Meta.md            4188 /  4500   budgeted
  skill descriptions (27)  3589 /   ---   NOT BUDGETED
  CLAUDE.md                3055 /  3100   budgeted
  Persona + Organisation    954 / 1600    budgeted
  agent descriptions (6)    446 /   ---   NOT BUDGETED
  ------------------------------------------------
  total                   22504           18 % ungoverned

Skill descriptions alone exceed CLAUDE.md. Fourteen proposals fought over 228 tokens in
General.md while 4035 sat unmeasured next door.

## Do NOT just add a skill-description budget

That was the first plan and it is wrong: it fixes the instance and leaves the class. Adding
a per-file budget for skill descriptions would have left the 446 agent-description tokens
undetected a second time (they were found only by asking whether a FOURTH surface existed).

Better, per the Phase 2 checkpoint: make Check 6 verify budget COVERAGE. Every always-on
surface must have either a budget entry or an explicit "unbudgeted by decision" marker;
neither present → fail closed, exactly as the script already fails closed on a missing
budgeted file.

Known caveat, raised by the checkpoint and shared: lint logic mirroring a prose list in
Meta.md §3.3 can drift from it. Do NOT parse the prose. Keep an explicit surface list in
the script with a comment naming §3.3 as its source.

## Measurements to reuse (chars, then *10/38)

Longest skill descriptions: communication 1041 · comm-calibrate 1021 · poke-holes 1006 ·
grill-me 907 · git-knowledge 859 · brainstorm 778 · blueprint 712 · effort-estimation 688 ·
composer:knowledge 682 · composer:update 651 · composer:major-upgrade 651 · batch 493.
Longest agent descriptions: payload-replay-verifier 427 · migration-pattern-researcher 335 ·
rule-index-auditor 304 · contract-researcher 231 · checkpoint 201 · test-runner 200.
Measure with an awk pass over the YAML frontmatter; a naive `sed` range runs into the body
on multi-line values and reports ~2000 for every pocock skill (that error was made and
caught in-session).

CLAUDE.md skill-ledger lines total 4093 chars = ~1077 tokens, a third of the file. Ten
entries retell their skill's description instead of "activation policy + one boundary line"
as the file itself prescribes: blueprint (436 chars), communication (332), composer:update
(251), comm-calibrate (238), composer:major-upgrade (222), git-knowledge (210), poke-holes
(204), effort-estimation (176), typo3:upgrade (174), composer:knowledge (153).
Tightening to 100-130 chars each frees ~330 tokens, ~350-400 if applied throughout.

## The risk that has no test

A skill's description IS its activation trigger. Shortening it can silently stop a skill
from firing, and nothing in the repo tests that. Treat each description as its own change
with individual review (an audit rejected grouping nine of them as one unit: poke-holes
carries anti-triggers plus grill-me disambiguation, comm-calibrate carries a genuine norm
about self-fetch, communication carries the language-mapping authority). After each edit,
re-read the description and confirm the phrases a user would plausibly type survive.

## Then lower the budgets

Once the surfaces are measured and tightened, lower every budget to the new actual plus
~5 %. Without this the whole exercise is a reset, not a fix: freed space invites refilling
and in four months the same backlog exists one storey lower.
