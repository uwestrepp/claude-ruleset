# Paket 3: Meta.md — artifacts point, not snapshot + three removals

Status: designed, NOT applied. Independent of Paket 1 and 2.
Budget is uncritical here: Meta.md 15916 chars = 4188 of 4500; after this package ~4178.

## The clause (drafted, ~587 chars = ~154 lint tokens)

    A durable artifact records what it controls and points at the source for what it does
    not. Findings, mechanisms, verified contracts, decisions and their reasons are stable
    and belong in the artifact. State it does not own — branch and commit state, PR and
    ticket state, whether someone answered, where another artifact lives — is a pointer,
    not a copy. A snapshot MUST carry its date and name the source to re-check, and any
    path it points at MUST survive a reboot (never a temp dir or session scratchpad). A
    sentence a later event can silently falsify is rework already scheduled.

Consolidates: proposal-2026-08-25-handoff-pointers-not-snapshots (three correction passes
over one ticket's handoff set) + the unsorted.md note about memories with dead pointers.

## Open design question (Material finding, /core:poke-holes 2026-08-31)

The clause binds when an artifact is WRITTEN. Meta.md §2.4 governs retention and archival.
An agent writing a handoff does not consult §2.4. Decide before applying:
  (a) §2.4 anyway, accepting weak binding;
  (b) §2.2 (storage targets), which is closer to the writing moment;
  (c) split: the pointer duty into §2.2, the reboot-safe-path duty into §2.4.
This was NOT decided in the originating session.

## Second clause: a finding with an action consequence has two targets (record item 8)

Added 2026-09-02. Verified that no handoff scheduled this, and this is the Meta.md package,
so it belongs here. Full evidence in the consolidation record, carried open item 8 — do not
re-derive it.

Incident: findings were written to a review document and reported as persisted, while the
resulting steps were missing from the operational document that would have triggered them.
`Meta.md` §2.2 requires the narrowest durable scope and says nothing about findings whose
consequence is an action.

Change: one sentence in §2.2 — when a finding implies an action, the document that triggers
the action (runbook, deploy plan, checklist) is checked as a SECOND target, and the
checkpoint is complete only with both.

Why it rides along here: it is one sentence in the same file this package already opens, and
`rules/Meta.md` is the only always-on surface with real reserve (214 estimated tokens, and
nothing else is queued against it). The record calls it "the only carried item this package
clears for spending". Measure both clauses together against the 4490 budget before applying;
`bin/lint-section-refs.sh` check 6 fails closed if the pair overruns.

Note the same open design question applies as for the pointer clause: §2.2 is the writing
moment, §2.4 is retention. This clause targets §2.2 explicitly, which is one input to
deciding (a)/(b)/(c) above.

## The three removals (target texts must be fixed BEFORE editing)

- B4 · header purpose list, lines 3-8. Remove the four-item list TOGETHER WITH its colon
  lead-in ("This document defines always-on meta-rules for:"); replace both with one
  sentence. Brutto 362 chars; net saving depends on the replacement, so measure after.
- B8 · §2.4 content enumerations (WIP notes, backups, snapshots, precompare patches).
  Condense; the transient-vs-durable criterion stays and is broader than the list.
  Inbound refs to §2.4 (pocock/handoff:21, githooks-install:106, batch:545, batch:549,
  commits:138) cite the scratch-vs-state split, not the examples.
- B10 · §3.2 "Updates can include changes, additions, removals, renames, and structural
  rewrites of single rules or whole rule-sets." This is PERMISSIVE (MAY-character), not
  rationale: it defines what counts as an update. Fold it into the adjacent sentence rather
  than deleting it. Which adjacent sentence is NOT yet decided.

## Do not touch

Meta.md §1.1's literal checkpoint block, §2.1/§2.3 trigger lists, and anything the
Meta.md §3.2 salience exception protects. §2 intro ("Session memory is transient") was
withdrawn from the removal set as a salience candidate.
