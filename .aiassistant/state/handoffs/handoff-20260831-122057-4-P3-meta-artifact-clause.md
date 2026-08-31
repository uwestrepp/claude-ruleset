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
