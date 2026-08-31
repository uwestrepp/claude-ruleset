# Paket 1: §1.6 in General.md Verification Reach

Status: designed, NOT applied. Blocked on two design repairs (below).
Origin: consolidation session 2026-08-31. Supersedes 7 proposals (see Paket 2).
Prerequisite for: nothing. Paket 2 can run independently.

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
