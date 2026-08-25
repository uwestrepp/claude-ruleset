# Bind the reach of a verification claim to the reach of the executed check

```
Date:         2026-08-25
Status:       open
Origin:       session observation — SSBSITE-1261, two commit bodies generalised past their
              own test rig, both caught later by an adversarial review
Revisit when: a third instance of a claim exceeding its evidence in any project, or the
              next /core:rule-friction cycle
```

## Problem

`General.md` §5.2 requires selecting verification paths and reporting the evidence. It says
nothing about the **scope** of the resulting claim. The gap is not laziness: the rig proves
the case the fix targeted, and the write-up then describes the fix, which is a wider set.
The claim reads as verified because a real measurement sits next to it.

Two instances in one branch, both authored by the agent, both found only in a later
adversarial pass:

1. `96e87fafe` guards a loop against repeating identical requests. The rig was a stand-in
   API answering the first request with a captured payload and every later one **empty**,
   which is exactly the case the guard covers. The commit body then states the loops "leave
   as soon as a shift adds nothing". They do not: the guard compares whole arrays, so an
   API answering the *same non-empty* payload again keeps the loop running. Recorded as
   finding H, still open.
2. The same branch's PR description claimed the timeout case was covered by that fix. It
   was not: a timeout inside the loop still discarded the journeys already found, because
   the call had no `catch` of its own. Recorded as finding G and fixed later in `092a22251`,
   one day after the claim went out to the reviewer and into a ticket comment.

Both claims were false in the same direction, and both were cheap to falsify once someone
compared the rig against the sentence.

## Proposed change

Add to `General.md` §5.2, in the reporting bullet:

> The reported claim MUST NOT exceed what the executed check covers. When the rig exercises
> one case of a broader change, the evidence line names that case and the claim stays inside
> it; generalising to the fix's intent is a fabrication in the sense of §1.2, even when a
> real measurement sits next to it.

Optionally mirror it in `/core:commits` under the `How to test` rules, where the wording is
already about what may and may not be presented as proof.

## Expected impact

Findings G and H would have surfaced while writing the commit body, not in a review a day
later, and the wrong claim would not have reached a reviewer and a Jira comment that then
needed a marked correction. Applies to every commit body, PR description and ticket comment
the agent authors, which is the highest-frequency surface in the rule-set.

## Risk / tradeoff

- Always-on token cost: `General.md` is `[CRITICAL]`, roughly 55 always-on tokens. Cheaper
  variant: put it only in `/core:commits`, which loads on demand and already owns the
  "static analysers are not behavioural proof" constraint, i.e. the same class of rule. That
  would cost nothing always-on but would not bind chat claims or PR text authored without
  the skill.
- Verbosity: bodies get longer, because "verified for the empty-answer case" replaces
  "verified". That is the intended cost.
- This is close to `Persona.md`'s premature-closure theme and to §1.5's hypothesis label, so
  check overlap per `Meta.md` §3.2 before applying; it may belong as a sentence in §1.5
  rather than §5.2.

## Evidence

- `96e87fafe` and its rig description, versus finding H in
  `.aiassistant/state/handoffs/handoff-20260825-091419-ssbsite-1261-offene-pruefungen.md`
  (`ssb.website`).
- Finding G in the same file, fixed in `092a22251`; the corrected claim is marked as
  KORREKTUR in `.aiassistant/state/SSBSITE-1261-jira-kommentar-entwurf-v2.md`.
- Retrospective naming the pattern in `.aiassistant/state/notes/effort-calibration.md`,
  commit `75177b716`.
