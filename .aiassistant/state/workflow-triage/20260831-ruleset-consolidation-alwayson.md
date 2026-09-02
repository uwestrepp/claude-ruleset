# Triage packet: rule-set consolidation (always-on surface)

Date: 2026-08-31. Workflow: /core:batch. Revision 3.
History: rev 1 OBJECTIONS (systematic optimism bias); rev 2 OBJECTIONS (cross-reference
missed, unexecutable condition, loose group, missing rung answers). Rev 3 corrects all of
them. Scope reduced by user decision to the always-on rule change plus the proposal
consolidation; the demotion-to-skill atoms are DEFERRED TO A SEPARATE SESSION, not dropped
(user decision 2026-08-31: deferral serves token/session economy, not the wastebasket).

## Resolved scope

  rules/General.md   A5, A10, A12, C1
  rules/Meta.md      B4, B8, B10, C2
  .aiassistant/state/proposals/   D1a, D1b, D1c, D2, D3

## Pre-change baseline

.aiassistant/state/functional-baseline-ruleset-consolidation.md (2026-08-31).
`bin/lint-section-refs.sh` → REF-LINT ok, exit 0.
`npx agnix@0.40.0 validate plugins/marketplaces/local/plugins rules` → 0 errors, 17 warnings, exit 0.

## Impacted runtime surfaces (§9.1)

(1) always-on rule load (General.md + Meta.md, every session); (2) bin/lint-section-refs.sh;
(3) agnix over rules/ + local plugins; (4) the pre-commit hook combining 2+3;
(5) NEW in rev 3: the proposals/README.md contract, which Meta.md §3.1 delegates to
normatively ("see its README.md for header, sections and lifecycle") — this is why D1c is
a rule change, not a state artifact.
C1/C2 change surface (1) by design. Every other atom must leave (1) behaviourally unchanged.

## Ladder translation (§9.1.1 specialised to rule text; rev 3)

  L1  prose with no normative content AND no inbound reference.
  L2  alters a referenced element: section number, load-bearing literal, cross-file
      reference, budget value, or text an external file depends on by phrase.
  L3  alters what the agent must DO. Triggers, non-exhaustively: removes/weakens an
      obligation (any MUST/SHOULD/MAY token in the moved text); moves an obligation to a
      surface not guaranteed loaded when it must bind; changes ordering/state semantics;
      removes repetition or emphasis protected by Meta.md §3.2's salience exception.
  L4  provable iff the target already carries the SAME obligation AND is loaded whenever
      it applies.

  REV-3 CORRECTION (rev 2 put this on the wrong hook): the phrase sweep is NOT tied to
  class `provable`. It is tied to the CLAIM. Any atom whose justification contains "is not
  referenced" / "no §-anchor depends on this" MUST carry a sweep line proving it, whatever
  its class. Rev 2 asserted non-reference for A5 without a sweep; the audit ran one and
  found comm-calibrate/SKILL.md:66. That is the failure this correction closes, and it is
  §1.6 in General.md (this cycle's own new rule) applied to the triage packet itself.

  Decisive asymmetry (unchanged): moving always-on text into a skill body is L3 by default,
  because a skill that is not activated cannot bind.

## Classification table (rev 3, all four rungs answered per atom)

| # | Atom | L1 | L2 | L3 | L4 | Class | Counter-check + salience answer |
|---|---|---|---|---|---|---|---|
| A5 | §10.5: shorten the self-executable list from 5 items to 2, KEEPING the sub-agent item and the criterion sentence | no | **yes** | no | prov | provable | Sweep: 4 inbound refs to §10.5 (communication:113, comm-calibrate:55+66, CLAUDE.md:60); only comm-calibrate:66 depends on list content, and its item is retained verbatim. Not salience-protected: §10.5 guards token economy, not behaviour under pressure. Not L3: the MUST-NOT-ask vs MUST-offer distinction lives in the criterion sentence and the two-branch structure, both untouched. |
| A10 | §2.4: drop the parenthetical git commands | **yes** | no | no | n/a | safe | Sweep: no file references §2.4 by command name. Only the commands go; the list of WHAT must be named (paths, execution layer, branch, remote, baseline) is the obligation and stays verbatim. Not salience-protected: §2.4 is a disambiguation duty, not a pressure guard. |
| A12 | §2.1: drop the parenthetical language/runtime enumerations | **yes** | no | no | n/a | safe | Sweep: inbound refs to §2.1 (TYPO3.md, Drupal.md, PER.md) cite the version-check duty, not the examples. "in-scope languages/formats/dialects and their versions" states the obligation and is strictly broader. Not salience-protected. |
| B4 | Meta.md header: remove the four-item purpose list TOGETHER WITH its colon lead-in ("This document defines always-on meta-rules for:"), replacing both with one sentence | **yes** | no | no | n/a | safe | Rev-2 defect fixed: lead-in and list are one unit; removing only the list leaves a dangling colon. Sweep: nothing references the header. No MUST/SHOULD/MAY. Not salience-protected. |
| B8 | Meta §2.4: condense the content enumerations (WIP notes, backups, snapshots, precompare patches) | **yes** | no | no | n/a | safe | The transient-vs-durable criterion is the obligation and stays; the list is illustrative and narrower. Sweep: §2.4 inbound refs (General.md §10.3, batch §11.1) cite the scratch-vs-state split, not the examples. Not salience-protected: artifact hygiene, not pressure. |
| B10 | Meta §3.2: fold "Updates can include changes, additions, removals, renames, and structural rewrites" into the adjacent sentence | no | **yes** | no | prov | provable | Rev-2 defect fixed: the audit is right that this is permissive (MAY-character), defining what counts as an update, not rationale. Folding preserves the permission while removing the standalone sentence. Sweep: no inbound reference to this sentence. Not salience-protected. |
| C1 | NEW §1.6 in General.md Verification Reach (text below, ~270 tokens) | no | no | **yes** | no | manual | New always-on obligation. Never batchable (§5.3). |
| C2 | NEW Meta.md §2.4 clause: artifacts point, not snapshot (text below, ~110 tokens) | no | no | **yes** | no | manual | New always-on obligation. Never batchable (§5.3). |
| D1a | Write the consolidation record under proposals/ | **yes** | no | no | n/a | safe | Adds a state artifact. Removes no text. Not read by lint or agnix. |
| D1b | Move 15 proposals to done/ with Status + pointer to the record | **yes** | no | no | n/a | safe | File moves within a state directory. Meta.md §2.4 mandates archival, so this executes an existing obligation rather than changing one. |
| D1c | proposals/README.md: add status `superseded` + mandatory `Superseded by:` line | no | no | **yes** | no | manual | Rev-2 defect fixed: Meta.md §3.1 delegates header/sections/lifecycle to this README normatively, so a new status changes future agent behaviour. Requires individual approval. |
| D2 | Correct the advisor claim in proposal-2026-07-29 (2 places) | **yes** | no | no | n/a | safe | Corrects a false statement in a record being archived. Wording must stay reach-faithful: no sub-agent under agents/ (verified); `/advisor <model>` observed as a harness command 2026-08-31 via its own error output. Claim nothing beyond that. |
| D3 | Correct the new-skill cost undercount in guided-gui-configuration | **yes** | no | no | n/a | safe | Adds the omitted description cost (~150-270 tokens) to a parked proposal's risk section. |

Counts: safe 8 · provable 2 · manual 3. Total 13.
`manual` topics requiring §9.3 approval: C1, C2, D1c.
Note on the D-atoms: D1a, D1b, D2, D3 ADD or CORRECT text; they free no budget. Only
A5, A10, A12 (General.md) and B4, B8, B10 (Meta.md) affect the budget arithmetic.

## provable proof ledger (§9.2) — populated at apply time

| Atom | Target/sweep verified at | Old → new | Check result |
|---|---|---|---|
| A5 | 2026-09-02, `rules/General.md` §10.5; sweep over the 4 rule/skill-surface refs | list dissolved entirely (radical variant), sub-agent case folded into the criterion sentence verbatim ("whose intermediate reads need not enter context"); −420 +54 = −366 bytes | `comm-calibrate/SKILL.md:66` resolves on the folded clause; `communication:113`, `comm-calibrate:55`, `CLAUDE.md:60` cite the offer list, untouched. Both gates green. |
| A10 | 2026-09-02, `rules/General.md` §2.4 | two parenthetical git commands removed, the WHAT-list verbatim; −119 bytes | Inbound §2.4 refs cite the naming duty, not the commands. Both gates green. |
| A12 | 2026-09-02, `rules/General.md` §2.1 | two parenthetical enumerations removed; −108 bytes | Inbound §2.1 refs (TYPO3, Drupal, PER, Shopware:13, major-upgrade:35/110) cite the version-check duty. Both gates green. |
| A8 (pulled forward from Paket 4) | 2026-09-02, `rules/General.md` §9.3 → `typo3/skills/static-tests/SKILL.md` §4 | example paragraph removed from always-on, reworded as a local obligation at the site it described; −278 bytes always-on, skill body unbudgeted | The relocation is stronger at the target: it now binds where the reader is instead of describing that site from elsewhere. Both gates green. |
| A11a (pulled forward from Paket 4) | 2026-09-02, `rules/General.md` header note | "; do not renumber (see `bin/lint-section-refs.sh`)" removed; "they remain binding" and the stable-anchor clause kept; −50 bytes | Machine-enforced by lint Check 5, which still passes. Both gates green. |
| C1 | 2026-09-02, `rules/General.md` §1.6 inserted after §1.5 | new section, +1726 bytes | Both blocking repairs applied (see below). File 39036 → 39841 bytes = 10484 est. tokens against budget 10500, reserve 16. |
| B10 | | standalone sentence → folded | |

## C1 as applied (rev-4, 2026-09-02) — supersedes the rev-3 draft below

The rev-3 draft was NOT applied. Both `/core:poke-holes` blocking defects were repaired and
the four Material findings resolved; the applied text is `rules/General.md` §1.6. What
changed against the draft:

- **Blocking 1 (trigger).** The primary trigger now sits at the inference step ("when a
  check result becomes a statement about system state, it inherits the check's reach"), with
  the grammatically-innocent sentence named as the typical defect and the grammar cues
  demoted to "only a second, cheaper cue".
- **Blocking 2 (asymmetry).** Extension is the default and cost-bounded; narrowing is
  "the fallback, not an equal option — cheap and unfalsifiable" and carries the duty to name
  what stays unverified.
- **Material, trace.** Bound to the existing §1.5 label instead of a new output block: a
  claim narrowed instead of extended "leaves a §1.5 hypothesis, not a diagnosis". No extra
  always-on tokens.
- **Material, §10.4 conflict.** Stated explicitly: "A reach qualifier is content, not
  hedging: §10.4 and `Persona.md` bind performative caution, never a claim's scope."
- **Material, §5.6.** Narrowed to "§5.6's *evidence clause* is this rule applied to command
  construction".
- **Material, repair cues.** Three repairs are named in the extension sentence (enumerate the
  population from the system, check the second surface, force the branch). The verbatim
  completeness bullet for §5.6 did NOT land — see the consolidation record's decision.
- **Cut to fit** (the designated cut target per the rev-3 note): the "Recurring limits" list
  went from five items to three, keeping the least inferable ones (tool-report vs population,
  filter hit list vs event list, declaration vs admissibility). The delegation paragraph was
  kept whole, as instructed.

## Full text of the manual atoms (rev-3 addition; the rev-2 audit could not price these)

### C1 — §1.6 in General.md

    ## 1.6 Verification Reach (MUST)

    Every check has a reach: the set of facts for which it could have failed. An
    assertion MUST NOT exceed the reach of the check behind it. A genuine check
    standing next to a wider claim is the mechanism by which this hides — the
    evidence is real, the conclusion is not, and no amount of care in reading the
    source closes the gap.

    The trigger is the grammar of the claim, not a feeling of doubt: a universal
    quantifier (all, every, none, nothing), a negative existence claim (not
    possible, there is no X), or an unqualified verification verb (verified,
    confirmed) each asserts a reach the agent MUST have established. Before such an
    assertion the agent MUST name what the executed check could have failed for,
    and either extend the reach or narrow the claim to what was covered ("not found
    in <source>, other surfaces unchecked"; "verified for <the exercised case>").

    Reach is bounded by the check, never by its subject. Recurring limits: a
    population a tool reported about its own work is not the population the system
    holds; one surface is not every surface; one execution path is not the branch;
    a declaration is evidence of form, not of admissibility in context. §5.6 is
    this rule applied to command construction.

    This binds delegated checks too: a sub-agent inherits the reach of its briefing,
    and its clean negative reads exactly like a wide one. The delegating agent MUST
    state the claim the check is meant to support, and MUST treat the result as
    bounded by what was actually asked.

### C2 — Meta.md §2.4, appended clause

    A durable artifact records what it controls and points at the source for what it
    does not. Findings, mechanisms, verified contracts, decisions and their reasons
    are stable and belong in the artifact. State the artifact does not own — branch
    and commit state, PR and ticket state, whether someone has answered, where
    another artifact lives — is a pointer, not a copy. Where a snapshot is genuinely
    useful it MUST carry its date and name the source to re-check, and any path it
    points at MUST survive a reboot (never a temp dir or session scratchpad). A
    sentence a later event can silently falsify is rework already scheduled.

## Budget arithmetic (corrected)

Rev 2 claimed "C1+C2 fit only because Pass 1 freed space". FALSE, and the audit caught it:
C2 (~110) fits inside Meta.md's existing 312-token headroom with no demotion at all, and
C1 at its original 210 would have fitted inside General.md's 228. Pass 1 supplies margin,
not necessity. What DID change the arithmetic is C1's fourth paragraph (delegated checks,
~60 tokens), added after the Phase 2 checkpoint, which puts C1 at ~270 against 228 free.

  General.md  10272 now · A5 ~63 + A10 ~31 + A12 ~28 = ~122 freed → ~10150
              + C1 ~270 = ~10420 against budget 10500. Reserve ~80.
  Meta.md      4188 now · B4 ~90 + B8 ~38 + B10 ~31 = ~159 freed → ~4029
              + C2 ~110 = ~4139 against budget 4500. Reserve ~361.

Reserve on General.md is thin (~80). If the applied text measures larger than estimated,
the fallback is to shorten C1's third paragraph ("Recurring limits"), NOT the fourth: the
category list is a recognition aid, the delegation paragraph closes a path that demonstrably
fired in this very session. Decide by measurement after applying, not in advance.

## Validation depth per group (§9.4)

- Pass 1 (`safe`): apply, then run both gates; confirm no §-anchor removed; confirm the
  B4 colon lead-in went with its list.
- Pass 2 (`provable`): per atom, run the phrase sweep, record the ledger line above, then
  both gates. A5 must additionally re-verify comm-calibrate:66 still resolves meaningfully.
- Pass 3 (`manual`, C1/C2/D1c): per item present text, target section, measured token cost
  against budget, and the behaviour change; approval; apply; both gates.
- Budget gate is load-bearing: run `bin/lint-section-refs.sh` after Pass 1, after Pass 2,
  and after each Pass 3 item.

## Deferred to a separate session (NOT dropped)

A1, A2, A3, A4, A6, A7, A8, A9, A11, B1, B2, B3, B5, B6, B7, B9, E1, E2, F1, plus:
General §11.2 delegation-briefing clause; lint Check 6 budget-COVERAGE check; the two
unbudgeted always-on surfaces (skill descriptions ~3589, agent descriptions ~446);
path-gated redundancies in TYPO3/Drupal/CleanCode/PER; Shopware.md project-fact extraction;
Meta.md §3.1 governance fix (proposals must name their axis).
The rev-1 and rev-2 audit objections against these atoms are recorded in the consolidation
record so the next session does not re-derive them.

## Meta-finding for the consolidation record

Three revisions, two OBJECTIONS verdicts. Every rev-1 misclassification made an atom look
SAFER than it was; §9.1.1's counter-check was filled in for each and caught none of them.
A counter-check written by the classifying agent is weak evidence. The independent audit
found, in order: a systematic optimism bias, a live cross-reference that would have been
broken, and a false necessity claim in the budget rationale. Separately: /core:batch §9 has
no proportionality floor ("more than one finding/topic/file" covers nearly any task), which
is why a two-file prose edit ran a full code-batch gate. That is a rule-set finding in its
own right and belongs in the deferred list above.
