# Paket 8: the carried items whose fix is a skill or a hook, not always-on text

Status: designed, NOT applied. Fully independent of Pakete 1, 3, 4, 6, 7 — none of these
items touches an always-on surface, so no budget competes and this package can run at any
point in the order.

Origin: the four items below sat in the "Carried open items" list of
`.aiassistant/state/proposals/proposal-2026-08-31-verification-reach-consolidation.md`
(items 2, 5, 6, 9) with a named fix and no owner. Verified 2026-09-02: no handoff scheduled
any of them, so they were a backlog entry rather than planned work. This file is the plan.
Each item's full evidence stays in the record; do not re-derive it.

## 1. Branch resolution at commit time (record item 2)

`General.md` §12 resolves the target branch once per *task*, and a task can be long. In the
GMP-340 go-live session the working copy had moved onto `staging` hours later and a commit
to a protected branch was one call away.

Change: one step in the `/core:commits` "Enforcement (MUST)" checklist, immediately BEFORE
the existing staged-scope step (currently 12), re-reading `git branch --show-current` and
confirming it against the branch resolved for the work. Renumber the following steps.

Watch: `/core:commits` is referenced by section number from several places. Run
`bin/lint-section-refs.sh` after renumbering — check 2 resolves `/plugin:skill §N` refs, and
the enforcement list's step numbers are NOT headings, so the lint will NOT catch a broken
step reference. Grep for `/core:commits` step references by hand before renumbering.

## 2. Em-dash gate (record item 5)

`General.md` §8.5 is enforced by attention alone, and attention failed three times in one
session.

Change: extend `hooks/validate-commit-message.sh` (already a `PreToolUse` gate scoped to
`~/work`) to reject U+2014 in a commit subject or body, and in added lines of the staged
diff. Carve-outs: code fences, source files, quoted external text. `~/.claude` itself stays
out of scope — this repo's rule files are agent-facing instruction files and §8.5 exempts
them.

Rollout as designed: fail-closed on the message, warn-only on the diff until fence-skipping
has run clean for a few weeks. Do not ship both fail-closed at once.

Authoring duty: this is a gate, so `General.md` §5.6's authoring clause binds — make the
fail-open vs fail-closed behaviour explicit and do not let a pipe mask an exit status.

## 3. ß versus ss in German output (record item 6)

An entire German documentation set was written in the Swiss `ss` spelling with no rule, gate
or spellchecker objecting: it is valid German carrying every diacritic the rule asks for, so
the rule reads as satisfied while the register is wrong.

Change: `/core:communication` §2, where "including umlauts and ß" already stands — make the
ß requirement explicit rather than implied by "diacritics", plus a carve-out for Swiss and
Liechtenstein recipients to be recorded per project, not globally.

No always-on growth: `General.md` §8.2/§8.5 keep pointing at the skill.

## 4. A single run cannot show a transition-state bug (record item 9)

Distinct from `General.md` §1.6's reachability limit: there the branch was never entered,
here the run entered it but only end states were observed while the defect sat in the state
carried between runs. It reached production.

Change: where state is carried forward across runs, check at least two consecutive cycles
plus the transition between the end states. Home is `/core:batch` §3.3, NOT `General.md`
§5.2 — the record's own argument, and §5.2 is always-on and dense.

## Parked, deliberately: a pre-action check must be its own tool call (record item 3)

NOT a work item in this package. The `/core:commits` staged-scope step ran and the commit
still swept in 13 unintended files, because the check and `git commit` sat in one Bash
invocation: the output existed, but only after the commit. The record parks it on one
incident and says "generalise only if a second instance appears elsewhere". That decision
stands.

Trigger to unpark: a second instance of a pre-action check whose output arrives only after
the action it was meant to gate. Then it becomes a `General.md` §5.6 candidate — and note
it would compete for the same budget as record items 4 and 12, so sequence it behind
Paket 4 if it ever fires.

Item 1 of this package (the branch re-read) is adjacent but not the same fix: it adds a
check, item 3 is about WHERE a check runs relative to the action.

## Validation

Per item: `bash bin/lint-section-refs.sh` (exit 0, "REF-LINT: ok") and
`npx --yes agnix@0.40.0 validate plugins/marketplaces/local/plugins rules`
(expect 0 errors, 17 warnings — the recorded baseline).

Item 2 additionally needs a real hook run, not a read-through: `General.md` §5.2 forbids
treating a syntax check as behavioural proof. Exercise the gate against a commit message
containing U+2014 and one without, and confirm both branches. `General.md` §1.6 applies to
the result — a passing hook run proves the cases you fed it, not the carve-outs you did not.

Commit per `/core:commits`. Branch: main (documented override in `CLAUDE.md`).
