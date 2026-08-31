# Paket 2: consolidate the proposal store

Status: designed, NOT applied. Independent of Paket 1; can run first.
User decision 2026-08-31: the consolidation record REPLACES the individual files.

## Deliverables

1. Write `.aiassistant/state/proposals/proposal-2026-08-31-verification-reach-consolidation.md`
   carrying: the nine incidents on their axes, the reach test ("the set of facts for which
   the check could have failed"), the §1.6 design decision, the measured budget picture,
   and the audit history of this session.
2. `git mv` 15 proposal files into `done/`, each with `Status: superseded` and a
   `Superseded by:` pointer.
3. Extend `.aiassistant/state/proposals/README.md`: new status `superseded` + mandatory
   `Superseded by:` line. THIS IS A RULE CHANGE, not a state edit: Meta.md §3.1 delegates
   header, sections and lifecycle to this README normatively. Treat it as such.
4. Dissolve `unsorted.md` (currently staged, `AM`): each of its 7 raw notes either becomes
   a proposal, folds into the consolidation record, or is dropped with a reason.

## Corrections that MUST land in the same change-set

- `proposal-2026-07-29-implementation-visibility.md`, two places (~line 47-49 and ~488):
  the claim "advisor is referenced by four skills but does not exist" is WRONG twice over.
  It is referenced by THREE skills (brainstorm, grill-me, poke-holes; the composer hits are
  "advisory/advisories", a substring false positive), and `/advisor <model>` exists as a
  harness command.
  Write the correction REACH-FAITHFULLY, or it repeats the error it corrects: there is no
  sub-agent definition under agents/ (verified), and `/advisor <model>` was OBSERVED as a
  harness command on 2026-08-31 via its own error output. Claim exactly that, no more.
- `proposal-2026-08-20-guided-gui-configuration.md`: its risk section says a new skill
  "costs a ledger line always-on". It also costs its description, ~150-270 lint tokens.
  That materially changes its cost/benefit; add it.

## Traps

- Use `git mv`, never plain `mv`. With an unstaged move `git ls-files` still lists the old
  path, `lint-section-refs.sh` Check 5 reads the file as empty, and EVERY numbered heading
  of `proposal-2026-07-29-implementation-visibility.md` (§1 to §8) is reported as removed.
- `lint-section-refs.sh` DOES read the proposal store (it iterates `git ls-files '*.md'`).
  Checks 1, 2 and 5 apply there; the 16 files carry between 1 and 13 file-qualified
  §-references. Run the lint after writing the record, not only after the moves.
  (agnix does not read it; the hook validates only `plugins/... rules`.)
- `handoffs/handoff-20260730-110844-agnix-version-bump.md:58` points at a file that moves.
  Update or the pointer dies.

## Content the record must carry (do not re-derive)

The nine incidents and their axes: population (n8n sequences) · modality-positive
(Shopify enum: presence is not permission) · modality-negative (EmailTemplate: absence is
not impossibility) · generalisation (loop-guard rig) · witness/layer (index vs docs/) ·
completeness (grep hit list is not an event list) · reachability (test run never entered
the branch) · consumer set (global timeout default) · delegation (this session: a sub-agent
briefed to look under agents/ returned a correct negative that was read as a wide one).

Meta-finding worth keeping: the proposal process itself produced this backlog. It creates
one file per incident and assigns pattern-formation to nobody, so seven instances of one
axis sat as seven files while each argued its own ~60-token budget case and the sum was
triple the available space.

## Run order for the whole set (this file is 1 of 7)

The leading number in each filename is the intended execution order; the `P<n>` keeps the
package identity used in cross-references inside the documents.

  1 · P2 proposal consolidation   risk-free, clears the backlog these packages came from
  2 · P5 unbudgeted always-on     close the enforcement gap BEFORE freed budget invites refilling
  3 · P1 verification reach       needs a design round first (two blocking findings)
  4 · P3 Meta.md artifact clause  one open placement question
  5 · P6 governance               item 4 depends on P5's description budget
  6 · P4 deferred demotions       can supply budget to P1 if that is needed earlier
  7 · P7 path-gated hygiene       fully independent, no budget effect

Only two real dependencies exist: P6 item 4 needs P5, and P1 may need P4 for budget.
Everything else is orderable by preference.
