# Paket 4: the deferred demotion atoms

Status: deferred by user decision 2026-08-31 for session economy, NOT dropped
("gekapselte Themen in getrennte Sessions zu schieben dient der Token-/Session-
Optimierung, nicht der Ablage").

## The governing insight, established at cost

Moving always-on text into a skill body is NOT a free optimisation. A skill that is not
activated cannot bind. Every atom below therefore trades tokens for binding probability,
and that trade must be made per atom, not as a policy. This is why revision 1 of the
triage packet was wrong across the board: every misclassification made an atom look safer
than it was.

## Atoms with their audit objections (do not re-derive these)

- A1 · §10.3 handover-bundle path/format → /pocock:handoff. §10.3 fires at session-restart
  time, exactly when no skill may be active. `manual`.
- A2 · §4.5 payload-replay procedure → agents/payload-replay-verifier.md. Target carries the
  procedure verbatim BUT is loaded only at spawn, and batch §7 makes the delegation SHOULD
  with an inline fallback. Either `manual`, or narrow the atom and keep "real, not synthetic
  payload" plus the §5.2 blocker clause always-on.
- A3 · §4.5 triage-record bullet → batch §9.1. The bullet carries BOTH the batch-packet duty
  AND the out-of-batch chat-evidence duty. A full move deletes an always-on obligation.
- A4 · §10.2 autonomous carve-out → batch §5.1. Removing it changes the default reading of
  a HARD STOP.
- A6 · §10.5 catch-all condensation. Touches the judgment-zone wording of a MUST.
- A7 · §10.5 Confluence + Jira offer items → /core:communication §4. The mandatory-offer
  list is a closed set by design; shrinking it is a semantic change.
- A8 · §9.3 example paragraph → /typo3:static-tests. Contains cross-file references and
  ends in an imperative, so L2, not L1. `provable` with a sweep line.
- A9 · §11.1 "Good candidates" → batch §7. FAILS the L4 test on both halves: batch §7 lists
  only checkpoint, test-runner, contract-researcher, payload-replay-verifier, while §11.1
  additionally names Explore/general-purpose and parallelizable sub-tasks; and §7 loads
  only inside a batch cycle while §11.1 binds always.
- A11 · General.md header note. Split: "do not renumber" is machine-enforced by lint Check 5
  and can go; "they remain binding" is a normative interpretation clause over the whole file
  and is unenforced.
- B1 · Meta §3.3 demotion-review procedure → /core:rule-friction. The always-on ADDITION
  BLOCK must survive the move; the split point needs review.
- B2 · Meta §2.2 in-code storage layer. Contains "per-project CLAUDE.md", not a model
  default, and deleting the lowest layer changes how the "narrowest durable scope" MUST
  resolves.
- B3 · Meta §1.1 delegation paragraph → General §11.1. One sentence is NOT derivable from
  §11.1 (the main agent must supply the candidate list); removing the wrong half loses it.
- B5 · Meta §2.4 legacy workflow-triage paragraph. Carries a literal MUST and still governs
  the directory batch §9.1 mandates. "Already executed" was factually wrong.
- B6 · Meta §2.4 archival detail → handoffs/README. The archival TRIGGER is normative and
  must stay; only the path detail may move.
- B7 · Meta §3.2 testing-requirements sentence. Contains a MUST; target CLAUDE.md is
  always-on, so at least `provable`.
- B9 · Meta §2 intro. Salience candidate under Meta.md §3.2, not plain rationale.

## Note

If Paket 1 needs more budget than options (a)-(c) there provide, pull ONE atom forward
from here rather than raising the budget. A8 and A11's first half are the cleanest.

**Paket 1 took both** (2026-09-02), not one: the repaired §1.6 measured 1726 bytes against
the 1292-byte draft, and A5-radical + A10 + A12 alone left it ~490 bytes over budget. Both
atoms taken are the two this note names as cleanest, and the alternative was raising the
budget or shortening a blocking repair out of the clause. `rules/General.md` closed at
reserve 16 estimated tokens, so this package is now the only source of space for the two
queued always-on additions (carried open items 4 and 12 in the consolidation record).

## Follow-up step this package owns (added 2026-09-02)

Freeing space is not the deliverable; spending it is. Verified 2026-09-02 that no handoff
scheduled the two additions that are waiting on this package, so they are named here as an
explicit final step rather than left as a backlog entry:

1. **Record item 4 — guard-pattern precision.** One sentence in `General.md` §5.6 requiring
   a structural match to be anchored to the structural unit it claims to describe. ~65
   estimated tokens. Evidence: three incidents in `hooks/guard-destructive-commands.sh`,
   most memorably a substring scan finding a phantom `-r` in the path segment `-uwestrepp`,
   which classified every plain `rm -f` under a session scratchpad as recursive-force.
2. **Record item 12 — the §5.6 completeness bullet, repair half.** ~500 bytes as an
   additional §5.6 bullet after the "Instead assert on an explicit count" bullet. The text
   is quoted VERBATIM in the consolidation record under "Proposed change" — do not
   re-derive it. Its recognition half already shipped inside `General.md` §1.6.

Both target §5.6. Apply them together and measure once: `rules/General.md` stood at 10484
of 10500 after Paket 1, so this package must free at least ~200 estimated tokens before
either lands, and `bin/lint-section-refs.sh` check 6 fails closed if it does not.

If this package's atoms free less than that, the decision is the user's: raise the
`General.md` budget by explicit decision, or leave items 4 and 12 queued. Do NOT shorten
either addition to fit — item 12 in particular is a verbatim text whose value is its
precision.
