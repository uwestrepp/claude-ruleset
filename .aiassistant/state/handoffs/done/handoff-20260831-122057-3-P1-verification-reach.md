# Paket 1: §1.6 in General.md Verification Reach

Status: designed, NOT applied. Blocked on two design repairs (below).
Origin: consolidation session 2026-08-31. Supersedes 7 proposals (see Paket 2).
Prerequisite for: nothing. Paket 2 can run independently.

## State as of 2026-08-31, after Paket 5

Paket 5 is applied (commits `d1f3fed` … `2e000be`). It freed **nothing in
`rules/General.md`**, so the budget block below is unchanged and still exact: the file is
still 39036 chars = 10272, the budget is still 10500, and the drafted change still lands at
reserve 4. Do not re-measure it hoping Paket 5 helped; it did not, by design (a tightening
pass never raises a budget, and General.md was already the tightest file).

What DID change, and what it means for this package:

- **Every always-on surface is now budgeted and the check fails closed.** `Check 6` in
  `bin/lint-section-refs.sh` enumerates surface members mechanically (`@` imports in
  `CLAUDE.md`, tracked `SKILL.md`, tracked `agents/*.md`). If this package creates a new
  always-on rule file and imports it, the lint fails until a `FILE_BUDGETS` entry exists in
  the same change-set. That is a new obligation, not a warning.
- **Budgets sit at actual + ~5 %.** Reserves: `General.md` 228, `Meta.md` 214, `CLAUDE.md`
  148, skill descriptions 163, `Persona.md` 24, `Organisation.md` 27. The small files are one
  sentence from tripping — that is deliberate.
- **Option (c) below got cheaper in one direction only.** Demoting always-on text into a
  skill BODY is still free: skill bodies are not budgeted and never should be, they load on
  activation. Skill DESCRIPTIONS are now budgeted in aggregate (3197 / 3360). So a demotion
  that adds a paragraph to a skill body costs nothing; one that lengthens a description to
  make the skill fire draws on 163 shared tokens.
- **`CLAUDE.md` has room now** (2872 / 3020, was 3055 / 3100). A ledger line for a demoted
  rule is affordable where it was not.
- **`Meta.md`'s 214 is spoken for.** Carried open item 8 in the consolidation record was
  cleared by Paket 5 to spend it. If this package also wants `Meta.md` space, it is competing.
- **Carried open item 4 competes with §1.6 for `General.md`'s 228 and this package decides
  it.** Paket 5 measured the envelope and explicitly did not choose: item 4 (one sentence on
  guard-pattern precision in §5.6) fits only if §1.6 lands under budget. Decide it here,
  either way, and record the verdict in the consolidation record.
- **New: skill activation has no test** (carried open item 11). Relevant the moment this
  package demotes anything into a skill: the record already states that a skill which does
  not activate cannot bind, and Paket 5 confirmed there is no way to verify activation today.
  Treat any demotion-to-skill as an untested change, not a free optimisation.

Unchanged and still binding: the reference-form constraint at the bottom of this file, the
validation commands, and both BLOCKING repairs. Paket 5 touched none of that.

## What this package delivers

One new always-on section replacing seven near-duplicate proposals, plus the three
General.md removals that pay for it.

## Why it is not just "insert the drafted text"

An adversarial pass (/core:poke-holes, Tier 2) found two BLOCKING defects in the draft.
Do not apply the drafted text as-is. Repair both first.

### Blocking 1 — the trigger misses most of its own evidence base

The draft says the trigger is "the grammar of the claim" (universal quantifier, negative
existence, unqualified verification verb). Tested against the nine incidents that motivate
the rule, it fires reliably on TWO: "no app can do this" (EmailTemplate) and "does not
exist" (advisor). It does not fire on: "checkpoint passed" (n8n sequences), "the right
value is PUBLIC_READ_WRITE" (Shopify enum), "theme selection is open" (index drift),
"skill descriptions are the unbudgeted surface" (this session).

Root cause: the error happens at the transition from CHECK RESULT to CONCLUSION, which is
often hours before the sentence is written, and the written sentence then carries no
quantifier at all. "I checked four sequences, they are correct" is grammatically innocent
and is the defect.

Repair direction (not yet written): the trigger must sit at the inference step, not the
sentence. Something of the shape "when a check result is turned into a statement about
system state, the statement inherits the check's reach". Keep the grammar cues as a
SECOND, cheaper trigger; do not make them the only one.

### Blocking 2 — the rule offers a compliant cheap way out

The draft offers "extend the reach OR narrow the claim" as equals. Narrowing costs nothing
and is unfalsifiable ("not found in X" is always true). Extending costs a pg_depend query,
a second surface, a forced branch. In at least four of the nine incidents extending was the
correct action and narrowing would have preserved the defect while looking like diligence.

Repair direction: make extension the default and narrowing the fallback, with a duty to
name what stays unchecked. Roughly: "extend the reach where its cost is bounded; narrowing
is the fallback and MUST name what remains unverified." Do not ship the symmetric version.

## Also fix while in there (Material)

- No observable trace: "name what the check could have failed for" leaves no artifact.
  Consider binding it to the existing §1.5 hypothesis label rather than inventing a new
  output block, so it costs no extra always-on tokens.
- Conflict with §10.4 / Persona.md: the rule demands qualifiers, §10.4 demands the fewest
  words and Persona.md names performative hedging as the failure mode. Say explicitly that
  a reach qualifier is content, not hedging, or the two rules will fight under pressure.
- §5.6 subsumption is overstated: it holds for §5.6's evidence clause, not its authoring
  clause. Narrow the sentence.
- The consolidation lost the REPAIR instructions the seven proposals carried (enumerate the
  population from the system; confirm against the actual call; grep the index layer). The
  example criterion governs RECOGNITION, not repair. Decide deliberately whether one short
  repair cue belongs in the rule; it was dropped by oversight, not by decision.

## Budget (measured 2026-08-31, NOT estimated)

lint-section-refs.sh Check 6 counts chars*10/38. Do NOT mix that with real-token
estimates; that error already produced a -50 reserve once.

  rules/General.md          39036 chars = 10272 · budget 10500 (= 39900 chars)
  removals A5+A10+A12        -443 chars = -116
  §1.6 draft (condensed)    +1292 chars = +340
  → 39885 chars = 10496 · reserve 4    ← TOO TIGHT, do not ship this way

Options, none applied yet:
  (a) A5 radical: dissolve the §10.5 list entirely and fold the sub-agent case into the
      criterion sentence. ~340 chars saved instead of 216, i.e. ~32 more tokens.
      Permitted by the second audit ("keep the sub-agent item OR pull it into the
      criterion sentence"). comm-calibrate/SKILL.md:66 depends on that case; verify it
      still resolves after the fold.
  (b) Shorten §1.6 further. The repairs above will likely ADD length, so plan for it.
  (c) Pull one deferred demotion atom forward from Paket 3.
  (d) Raise the budget by explicit user decision. Legitimate per the script's own message,
      but it is the ratchet this whole session exists to stop. Only with a commitment to
      land Paket 3 soon.

## The three removals (target texts must be fixed BEFORE editing)

- A5 · General.md §10.5, the list after "Covers, non-exhaustively:". The colon lead-in is
  part of the list; removing only the items leaves a dangling colon.
  Inbound refs to §10.5: 7 repo-wide, 4 in the rule/skill surface. Only
  comm-calibrate/SKILL.md:66 depends on list CONTENT (the sub-agent item). The other three
  (communication:113, comm-calibrate:55, CLAUDE.md:60) concern the offer list; three more
  live in .aiassistant/state review documents and carry an explicit "Do NOT move".
- A10 · General.md §2.4, the parenthetical git commands (119 chars). The list of WHAT must
  be named stays verbatim.
- A12 · General.md §2.1, two parenthetical enumerations (108 chars). Inbound refs to §2.1
  (TYPO3.md, Drupal.md, PER.md, Shopware.md:13, composer/major-upgrade:35,110) all cite the
  version-check duty, not the examples.

## Validation

After every edit: `bash bin/lint-section-refs.sh` (exit 0, "REF-LINT: ok") and
`npx --yes agnix@0.40.0 validate plugins/marketplaces/local/plugins rules`
(0 errors, 17 warnings). Hook scope is authoritative; a wider agnix scope produces
scope-artifact errors (see auto-memory, ref_skill_frontmatter_argument_hint.md).

Commit per /core:commits. Branch: main (documented override in CLAUDE.md).

## Reference-form constraint (discovered 2026-08-31)

Until §1.6 exists in rules/General.md, no tracked file may write the literal
"General.md" immediately followed by "§1.6": lint Check 1 resolves that form and fails
("does not exist"). These handoffs therefore use "§1.6 in General.md" instead. Once the
section is applied, the normal form is available again and may be restored.
This is also the proof that lint-section-refs.sh reads `.aiassistant/state/**`.

---

# Outcome — 2026-09-02, package delivered

`rules/General.md` §1.6 (Verification Reach) is applied. Both BLOCKING repairs are in the
shipped text, all four Material findings are resolved, and both gates are green
(`REF-LINT: ok`; agnix 0 errors / 17 warnings — the recorded baseline).

**Budget, measured not estimated.** The repaired clause came out at 1726 bytes against the
1292-byte draft, so the three designed removals were not enough. Landed:

    baseline                     39036 bytes = 10272 tokens
    A5 radical (list dissolved,
      sub-agent case refolded)    -366
    A10 (§2.4 git commands)       -119
    A12 (§2.1 enumerations)       -108
    A8  (§9.3 example → skill)    -278   pulled forward from Paket 4
    A11a (renumber note)           -50   pulled forward from Paket 4
    §1.6                         +1726
                                 -----------------------------------
                                 39841 bytes = 10484 · budget 10500 · reserve 16

Budget NOT raised. Option (d) was not used.

**Decisions this package owed and made:**

- *Carried open item 4* (guard-pattern precision, §5.6): **not affordable, still open.**
  Reserve 16 tokens against a ~65-token sentence. Queued behind Paket 4.
- *The §5.6 completeness bullet* (Material finding 4): only its recognition half landed, as
  "a filter's hit list is not an event list" in §1.6's recurring limits. The repair half is
  now carried open item 12 in the consolidation record, quoted verbatim there.
- *Two Paket 4 atoms taken, not one* (A8, A11a). Both are the ones Paket 4's own note names
  as cleanest; the alternatives were raising the budget or cutting a blocking repair.
- *Recurring limits cut from five to three* — the cut target the triage packet designated.
  Kept: tool-report vs population, filter hit list vs event list, declaration vs
  admissibility. The delegation paragraph was kept whole, as instructed.

**Consequence for the next session:** `rules/General.md` is effectively at its ceiling
(16 tokens). The next always-on addition there is blocked until Paket 4 frees space —
which is `Meta.md` §3.3 working as designed, not a defect.

**The reference-form constraint is lifted.** §1.6 exists, so the literal
"`General.md` §1.6" resolves in lint Check 1 and is restored in the consolidation record.

**Reach of this package's own validation** (measured, §1.6 applied to itself). "Both gates
green" covers: lint over tracked files in this repo, agnix over
`plugins/marketplaces/local/plugins` and `rules`. Positive controls were run rather than
assumed — a bogus `§5.99` in §1.6's fourth paragraph DID fail lint Check 4 (exit 1), a bogus
`§1.99` in the third paragraph did NOT, because that line also carries `` `Persona.md` `` and
Check 4 skips a bare `§N` sharing a line with a cross-file qualifier (a by-design limitation
stated in the script header). So §1.6's `§5.6` reference is machine-guarded; its `§1.5` and
`§10.4` references are NOT, and were verified by hand against the headings at
`rules/General.md:52` and `:330`. Paragraphs in this file are single lines, so any paragraph
carrying a file-qualified reference hides its bare ones; fixing that means splitting
paragraphs (costs bytes on a file at its ceiling) or extending the lint, neither of which
this package did.

What is NOT covered by either gate: whether §1.6 actually binds agent behaviour. That is
carried open item 11 — rule and skill activation has no executable test in this repo — and
it is stated, not skipped.
