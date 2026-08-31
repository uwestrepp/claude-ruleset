# Extend General.md §5.6 to the identity of the observed object

```
Date:         2026-08-31
Status:       superseded
Superseded by: .aiassistant/state/proposals/proposal-2026-08-31-verification-reach-consolidation.md
Origin:       session observation — KSW5-893 in krannich/pim, two false diagnoses from
              runtime observations within one session
Revisit when: a second instance of "observed the wrong object or stale code, concluded
              about the change" in any project, or the next /core:rule-friction cycle
```

## Problem

`General.md` §5.6 makes a command's *output* discriminative: a false fact must produce a
visibly negative result. It says nothing about the *object* the observation is made on, or
about whether the code being observed is the code that was just written. Both failed in
one session, in opposite directions:

1. **Wrong object, indistinguishable.** Verifying the ACL gate on a product where two
   association types happened to hold two entries each. A tab click did not switch the
   type, the grid kept showing the previous type, and the row count matched the expected
   one either way. Conclusion drawn: "the ACL gate checks the wrong association type,
   security defect, blocking". Actual: the gate was correct. Cost: a wrong blocking report
   to the user plus roughly 10 minutes of chasing a non-existent defect.

2. **Stale code, silent.** Verifying the generic drag-and-drop enablement right after a
   webpack build. The browser served the cached bundle. The old code path is
   hard-wired to one association type, so the observation "works for Stueckliste, not for
   Accessories" is exactly what a *correct* new implementation would NOT produce — and
   exactly what the old one does. Conclusion drawn: "my change does not take effect".
   Actual: a hard reload showed it working. Cost: roughly 5 minutes plus a round of
   grepping the bundle.

Both are the §5.6 failure shape — a false fact yielding a plausible-looking positive — but
neither is reachable through the current wording, which is scoped to command construction
and to authored gates.

Note the neighbourhood: §5.6 now carries three open extension proposals
(`proposal-2026-08-18-verification-population-completeness`,
`proposal-2026-08-17-guard-pattern-precision`, and this one), each a different mechanism
of the same shape. That is itself a finding: a fourth bolt-on is probably the wrong move,
and §5.6 may need one restructured statement of the principle — *an observation is
evidence only when a false fact would look different* — with the mechanisms as short
instances rather than separate paragraphs. Whoever promotes any of the three should decide
that first (`Meta.md` §3.2, merge where viable).

## Proposed change

`General.md` §5.6, one added paragraph (or an instance under the restructured statement
above):

> The same integrity requirement binds the *object* of an observation, not only the
> command that produces it. Before concluding from a runtime observation, the agent MUST
> confirm that (a) the observed object is unambiguously the intended one — a test subject
> whose expected and unexpected states look alike is not evidence, so pick one where they
> differ — and (b) the artifact under observation is the current one, where a build,
> compile, cache or browser sits between the edit and the observation. A conclusion that
> the just-written code has no effect MUST NOT be drawn before (b) is established.

## Expected impact

Blocks the specific shape that produced a false security report here: a runtime
observation that is consistent with both the defect and its absence. The (b) half is cheap
and mechanical — it turns "my change does nothing" from a conclusion into a checklist item
behind a hard reload or rebuild.

## Risk / tradeoff

Always-on token cost in a `[CRITICAL]` file that already carries three pending additions;
§3.3 budget applies, which is the main argument for merging rather than appending. Mild
risk of over-verification: re-confirming object identity on every trivial observation
would be noise. The wording is therefore bound to *concluding*, not to observing.

## Evidence

- Project `~/work/projects/krannich/pim`, branch `feature/KSW5-893-association-sorting`,
  session of 2026-08-31.
- Incident 1: reported to the user as a blocking ACL defect, retracted in the same session
  after entitlement was withdrawn for all types instead of one and the gate behaved
  correctly.
- Incident 2: resolved by `navigate_page` with `ignoreCache: true` after the bundle had
  already been confirmed to contain the new code (`Stueckliste` literal absent,
  `model_position` present).
- Both recorded in
  `pim/.aiassistant/state/notes/ksw5-893-step1-findings.md` and the session time log
  (~15 min of the ~38 min spent on cause-clarification in that session).
