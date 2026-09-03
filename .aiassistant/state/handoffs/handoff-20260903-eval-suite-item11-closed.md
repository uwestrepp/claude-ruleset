# Session close 2026-09-03: item 11 closed, a nine-case eval suite exists

Status: work complete and committed, tree clean, nothing half-applied. Resume with
"Tomorrow", not by re-reading this whole record.

Five commits on `main`, oldest first:

    d949a86  [TEST] (evals) first plugin-eval suite for core skill activation
    fcaa3b4  [DOCS] (state) item 11 unblocked, plugin eval runs
    5d059f1  [DOCS] (evals) run command and the arm: both lever documented
    7b88f59  [TEST] (evals) disambiguation plus two restraint cases
    d357f5a  [DOCS] (state) item 11 closed, eval-case-duty proposal filed

This supersedes `handoffs/done/handoff-20260902-192049-session-close-p1-done.md`, whose step 1
is done. That file's package matrix and budget table are carried forward below; its step 2 was
not executed, and the user confirmed archiving it on 2026-09-03.

## 1. What shipped

**Carried open item 11 is CLOSED.** Skill activation is testable and tested.

- The early-access gate on `claude plugin eval` is `L("tengu_walnut_spire",!1) ||
  a.CLAUDE_CODE_WALNUT_SPIRE`, read out of the resolved binary rather than obtained from the
  early-access contact as the old handoff assumed. `CLAUDE_CODE_WALNUT_SPIRE=1` is now set in
  the gitignored `~/.claude/settings.json` under `env`. The automatic first-party path was
  FALSIFIED, not merely untried: CLI 2.1.258 -> 2.1.259 plus a fresh session, both variables
  the offline reference named, and it stayed gated.
- Nine cases at `plugins/marketplaces/local/plugins/core/evals/` with a README carrying the
  run command, the case anatomy, the negative-assertion idiom and the reach limit.
- The grader idiom from auto-memory is verified by real runs, with one correction the offline
  reference did not carry: **`arm: both` is load-bearing**. Without it a `tool: Skill` grader
  is display-only and never moves the ablation delta.

## 2. Measured, and do not re-derive

- Cases 01-04 confirmed at `runs: 3`: with-arm 1.00 on every run, no flake, mean delta +0.42
  over 24 runs, 381 s, $1.51. Only the BASELINE arm varied.
- Cases 05-09 piloted at `runs: 1`: 1.00 each. **Not yet confirmed at the `runs: 3` their
  files declare** — that is the one loose end, roughly $2.85.
- Three substantive results about the descriptions themselves:
  - the three-way `grill-me` / `poke-holes` / `brainstorm` guard BINDS — each fired only in
    its own case, 0x in both sibling cases,
  - `commits` did NOT over-trigger on a German prompt containing "nichts committen",
  - `blueprint` restrained itself on a routine class-cut question, in both arms.
- German prompts activate skills whose trigger lists are written in English (case 03).
- Cost model: about $0.19 per case per with/without run-pair.

## 3. The reach limit, and it is structural

Cases run in a sandbox loading ONLY the plugin under test: no `CLAUDE.md`, no `rules/`, no
`CLAUDE.local.md`. So the suite measures description-driven auto-activation and **cannot test
the `General.md` §9.1 invocation gate at all**. Related finding: only three pocock skills
(`zoom-out`, `diagnose`, `grill-with-docs`) carry `disable-model-invocation: true`. For
`core:blueprint`, `core:rule-friction`, `composer:*` and `typo3:*`, "explicit activation
required" is the ledger phrase plus agent behaviour and nothing else. Whether that is a defect
or the intended design is undecided and nobody has been asked.

## 4. Budget state — read before touching any always-on file

    rules/General.md        10484 / 10500   reserve 16    <- AT ITS CEILING
    rules/Meta.md            4276 /  4490   reserve 214
    CLAUDE.md                2905 /  3020   reserve 115
    rules/Persona.md          476 /   500   reserve 24
    rules/Organisation.md     478 /   505   reserve 27

Unchanged by this session: nothing always-on was touched. `bin/lint-section-refs.sh` check 6
fails closed. Three additions are now queued against `rules/General.md`: record items 4 and
12, plus the new proposal below.

## 5. One new proposal, open and undecided

`proposals/proposal-2026-09-03-eval-case-duty.md` — a SHOULD that a new or materially changed
skill description gains or updates an eval case in the same change-set. The open question is
the target: `General.md` §9.2 is topically correct but unaffordable at reserve 16, so it
queues behind Paket 4; the `CLAUDE.md` ledger preamble is affordable at reserve 115 but reads
as an index entry rather than a rule. **This is the user's call, not agent work.**

## Tomorrow — pick one, they are independent

| Option | Content | Cost |
|---|---|---|
| Confirm the whole suite | 20 cases at `runs: 3`; only 01-04, 17 and 19 have ever run at 3 | about $10, no token cost |
| Extend coverage | cases for `composer` and `typo3` (each needs its own suite); three Paket 5 descriptions still uncovered | run budget only |
| Paket 3 | `Meta.md` pointer clause + item 8 + three removals | 214 tokens free; carries ONE undecided design question, written up in its handoff |
| Paket 4 | demotions, THEN spend the space on items 4 + 12 | unblocks three queued additions incl. the new proposal |
| Paket 8 | four skill/hook fixes | no always-on cost |
| Paket 6 | governance fixes (item 2 already done) | |
| Paket 7 | path-gated hygiene + item 7 | |

Recommendation: **Paket 4**. It was already the higher-leverage option, and the new proposal
is the third addition queued behind the space it frees, which strengthens the case. Paket 3
remains next in the recorded run order if you prefer the order.

**Update, later on 2026-09-03: the suite grew to 20 cases and found a real defect.**
`core:brainstorm` and `core:poke-holes` both missed requests squarely inside what their
descriptions claim. Both repaired, both verified at `runs: 3`, no over-triggering across the
full suite (commits `d98deaf`, `2ccb10e`, `b7e8f9b`). The durable lesson, and it changes how to
use this tool: **breadth finds defects, depth only validates numbers.** The existing
`brainstorm` case had passed three runs in a row with the defect one phrasing away. Every
description has a paraphrase margin, the margins differ per skill, and they are invisible
until measured. Full worked example in `core/evals/README.md`; reusable form in auto-memory
`ref_claude_plugin_eval.md`. The eval-case-duty proposal now carries this as its incident.

Carried item 1 (pairing mode part B) was REJECTED by the user later on 2026-09-03 and needs
nothing further: dropped on M2, since the narrow core would surface only main-agent decisions
the user already reads while staying blind to delegated work. Gap 2 stays open and named. Of
the twelve carried items, 1, 10 and 11 are now terminal.

Still open and unchanged: item 7 (deployer->drupal move, resumes in `~/work/projects`) and the
agnix 0.40.0 -> 0.41.1 pin bump (`handoff-20260730-110844-agnix-version-bump.md`).

## Validation for any follow-up work

    bash bin/lint-section-refs.sh
    npx --yes agnix@0.40.0 validate plugins/marketplaces/local/plugins rules

Expect `REF-LINT: ok` exit 0, and 0 errors / 17 warnings. The eval `.md` files add no
findings. To run the suite:

    cd plugins/marketplaces/local/plugins/core
    claude plugin eval . --ablation with-without --no-publish

`--no-publish` is required: publishing the HTML report to claude.ai is the harness default.
`--case <glob>` takes `*` but NOT character classes. `--keep-temp` preserves the sandbox and
`out/trace.jsonl`, which is the only place the agent's last message is visible when a grader
verdict looks wrong; the kept dir is mode 000 sealed and needs `chmod 700`.

Commit per `/core:commits` (bare `AGENT` ticket in this repo). Branch: main, documented
override in `CLAUDE.md`.
