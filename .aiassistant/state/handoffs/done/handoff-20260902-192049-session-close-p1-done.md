# Session close 2026-09-02: Paket 1 shipped, carried backlog scheduled, three items decided

Status: session ended deliberately, work is complete and committed, tree clean. Nothing is
half-applied. Resume with the "Tomorrow" section, not by re-reading the whole record.

Four commits on `main`, oldest first:

    b6e1cc2  [REFACTOR] (rules) General.md §1.6 verification reach + five removals
    8719b37  [DOCS] (state) package 1 outcome recorded, handoff archived
    c99d30e  [DOCS] (state) every carried open item given an owning handoff
    53b851e  [DOCS] (rules) agnix scope claim corrected, three item decisions recorded

## 1. What shipped

**`rules/General.md` §1.6 (Verification Reach)** — the clause that replaces seven
near-duplicate proposals. The rev-3 draft was NOT applied: a `/core:poke-holes` pass had
found two blocking defects and both were repaired first.

- Trigger moved to the inference step ("when a check result becomes a statement about system
  state, it inherits the check's reach"). The draft keyed on the grammar of the claim and
  fired on only 2 of the 9 motivating incidents; grammar cues are now "only a second,
  cheaper cue".
- Extension is the default and cost-bounded; narrowing is "the fallback, not an equal option
  — cheap and unfalsifiable" with a duty to name what stays unverified, and it leaves a §1.5
  hypothesis rather than a diagnosis.
- Four Material findings resolved: trace bound to the existing §1.5 label (no new output
  block, no extra tokens); the §10.4 / `Persona.md` conflict stated explicitly ("a reach
  qualifier is content, not hedging"); the §5.6 subsumption narrowed to its evidence clause;
  three repair cues named in the extension sentence.

Paid for by five removals, budget NOT raised. A5 radical (§10.5 self-executable list
dissolved, sub-agent case refolded), A10, A12, plus A8 and A11's first half pulled forward
from Paket 4 because the repaired clause measured 1726 bytes against the 1292-byte draft.

## 2. Budget state — read this before touching any always-on file

    rules/General.md        10484 / 10500   reserve 16    ← AT ITS CEILING
    rules/Meta.md            4276 /  4490   reserve 214
    CLAUDE.md                2905 /  3020   reserve 115
    rules/Persona.md          476 /   500   reserve 24
    rules/Organisation.md     478 /   505   reserve 27

`bin/lint-section-refs.sh` check 6 fails closed. `rules/General.md` has room for nothing:
the next addition there needs a demotion first, which is `Meta.md` §3.3 working as designed,
not a defect. Two additions are already queued against that space (record items 4 and 12).

## 3. The carried backlog is now scheduled, and was not before

Verified 2026-09-02: none of the record's twelve carried open items was scheduled in any
handoff. The record calls the list "their active form", which reads like a plan and is an
archive. Fixed — the consolidation record now carries a per-item scheduling table.

- **New Paket 8** (`handoff-20260902-135856-8-P8-skill-and-hook-fixes.md`): items 2, 5, 6, 9
  — the four whose fix is a skill or a hook and costs no always-on tokens. Independent of
  every other package, runs at any point. Item 3 rides along parked with an unpark trigger.
- **Paket 3** received item 8 (actionable findings need the triggering document as a second
  target). Same file, and `Meta.md` is the only always-on surface with real reserve.
- **Paket 7** received item 7 (Shopware review cascade), flagged as running OPPOSITE to that
  package's direction — everything else there removes from `Shopware.md`, this adds a line.
- **Paket 4** got an explicit follow-up step naming items 4 and 12 with their token cost, so
  freeing space and spending it live in one handoff.
- **Paket 6 item 2 is done** — it proposed the delegation-briefing clause for §11.2 and
  suggested folding it into §1.6 instead, which is what shipped. Marked in the body, not the
  heading: lint check 5 blocked the heading rename, correctly.

## 4. Three items decided by the user this session

- **Item 10 CLOSED.** The ledger claimed agnix validates memory files in the pre-commit hook.
  False, and it had propagated to three places (`CLAUDE.md`, the `.githooks/pre-commit`
  header, the agnix auto-memory) — all corrected, each now also saying that widening the hook
  scope does NOT help, since `projects/` is gitignored. Correction verified by running the
  command the new sentence points at: 0 errors, 21 warnings on the untracked path.
- **Item 1 RE-SCOPED, not closed.** "Willingness to add hooks" was a stale framing: eight
  hooks are already registered. Only `UserPromptSubmit` is missing, and that is exactly the
  event B1 names as the mechanism. The proposal's own B2/B3/B4 findings narrow the
  cost-benefit-positive core to: `UserPromptSubmit` hook + state file, `observe` ONLY,
  trigger on genuine option sets, §8.4 suspension, one ledger line. `gate`, the level ladder
  and cross-session persistence are the expensive parts and none is needed for "just see it".
  **Open and the user's alone:** build that narrow version or drop Part B, given M2 has no
  cheap fix (sub-agents never see the mode, and §11.1 mandates delegation for exactly that
  bounded work).
- **Item 11 CONFIRMED in mechanism, BLOCKED in execution.** See "Tomorrow" — this is the one
  item with a concrete next action.

## Tomorrow — in this order

**1. The one cheap experiment, do it first (record item 11).** This session's `claude plugin
eval` invocations all answered `` `plugin eval` is currently in early access `` and exited 1,
`init --bare` included. CLI is 2.1.258 and `claude update` reports up to date, so a stale
binary is ruled out. Per the offline reference a first-party client is enabled automatically
after `claude update` PLUS a fresh session — and a fresh session is the only untested
variable left. So in the new session, before anything else:

    claude plugin eval --help          # argparse only, proves nothing
    claude plugin eval plugins/marketplaces/local/plugins/core   # the real test

If it runs: skill activation becomes testable, which the record calls the single
highest-value addition to the rule-set's own tooling. Author a fixture for a HANDFUL of
skills with unambiguous triggers first, not all 27 descriptions. Grader idiom and its
uncertainty are in auto-memory `ref_claude_plugin_eval.md` — the syntax there came from an
offline reference and was never type-checked by a run, so treat it as a dated hypothesis.
If it is still gated: the enablement env var's name has to come from the early-access
contact; there is no public doc page. Record the outcome either way in record item 11.

**2. Then pick a package.** Run order and independence:

| Package | Content | Depends on |
|---|---|---|
| Paket 3 | `Meta.md` pointer clause + item 8 + three removals | nothing; 214 tokens free |
| Paket 8 | four skill/hook fixes | nothing; no always-on cost |
| Paket 6 | governance fixes (item 2 already done) | nothing |
| Paket 4 | demotions, THEN spend the space on items 4 + 12 | nothing, but unblocks the two queued additions |
| Paket 7 | path-gated hygiene + item 7 | nothing |

Recommendation: **Paket 3**, it is next in the recorded run order and has the only real
always-on reserve. Paket 4 is the higher-leverage one if you want `rules/General.md` breathing
again. Paket 3 carries ONE undecided design question (does the pointer duty go to §2.2, §2.4,
or split) — decide it before editing, it is written up in that handoff.

**3. Items 1 and 10 need nothing from the agent.** Item 10 is closed. Item 1 needs your
build-or-drop call, and the narrow scope is written down so it does not have to be re-derived.

## What NOT to re-derive

- §1.6's design, its two repairs and the measured budget arithmetic:
  `handoffs/done/handoff-20260831-122057-3-P1-verification-reach.md` plus the triage packet's
  rev-4 section. Nine incidents of evidence are behind the clause; the record says "do not
  re-derive" and means it.
- The reach limitation of this repo's own lint: check 4 skips a bare `§N` sharing a line with
  a cross-file qualifier, so §1.6's `§1.5` and `§10.4` references are NOT machine-guarded and
  were verified by hand. Positive controls were run rather than assumed. In the archived P1
  handoff.
- Paket 4's atom-by-atom audit objections. Each one exists because revision 1 of the triage
  packet made every atom look safer than it was.

## Validation for any follow-up work

    bash bin/lint-section-refs.sh
    npx --yes agnix@0.40.0 validate plugins/marketplaces/local/plugins rules

Expect `REF-LINT: ok` exit 0, and 0 errors / 17 warnings. The hook scope is authoritative; a
wider agnix scope produces scope-artifact errors. Memory files are NOT hook-covered and
validate separately on demand against their own directory.

Commit per `/core:commits` (bare `AGENT` ticket in this repo). Branch: main, documented
override in `CLAUDE.md`.
