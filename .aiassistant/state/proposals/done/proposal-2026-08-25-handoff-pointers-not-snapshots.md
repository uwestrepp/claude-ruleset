# Handoffs record what is stable and point at the source for what changes

```
Date:         2026-08-25
Status:       superseded
Superseded by: .aiassistant/state/proposals/proposal-2026-08-31-verification-reach-consolidation.md
Origin:       session observation — SSBSITE-1261, three correction passes over the same
              handoff set, every one caused by an embedded state snapshot
Revisit when: a second project needs a staleness pass over its handoffs, or the next
              /core:rule-friction cycle
```

## Problem

`Meta.md` §2.4 governs where an agent artifact lives and when it is archived. It says
nothing about what makes its content decay. Handoffs written to be helpful embed the current
state of things the author does not control, and every such sentence is guaranteed rework.

Observed on one ticket's handoff set, three separate correction passes:

1. `922ed9f5c` corrected three handoffs whose deferral reasons had turned a confirmation
   into a precondition ("cannot be verified locally", "cross-check in Tideways first"). The
   real reason in all three cases was the spent budget.
2. On 2026-08-25 a staleness pass had to correct: "PRs are not created yet, and that is
   deliberate" (a PR had existed since the previous day), a branch described as carrying two
   commits when it carried thirteen, an "as of 2026-08-24 12:46 nobody has answered"
   snapshot, a list of four open items of which three were done, and four cross-references
   to a file that had since moved into `done/`.
3. A third pass archived two spent handoffs and had to extract four items from them that no
   active handoff covered.

Pass 2 is the avoidable one. Every single correction there was an embedded snapshot of
something with an authoritative source elsewhere: the PR exists or not in Bitbucket, the
branch content is in `git log`, the answer is in the ticket, the file location is in the
directory. A pointer would have aged without becoming wrong.

## Proposed change

Add to `Meta.md` §2.4, after the retention paragraphs:

> A durable handoff records what is stable (the finding, the mechanism, the verified
> contract, the test rig, the decision and its reason) and **points at the source** for
> anything it does not control (branch and commit state, PR and ticket state, whether a
> colleague has answered, the location of another artifact). Where a snapshot is genuinely
> useful, it MUST carry its date and name the source to re-check. A handoff sentence that a
> later event can silently falsify is rework already scheduled.

## Expected impact

Pass 2 above becomes unnecessary; passes 1 and 3 are different classes and stay. Scales with
how long a ticket runs and how many handoffs it spawns: this set had six active files at its
peak, and the staleness pass touched four of them.

## Risk / tradeoff

- Always-on token cost: `Meta.md` is `[CRITICAL]`, roughly 80 always-on tokens.
- A pointer is less useful to read than a snapshot. The next session has to look something
  up instead of being told, which costs a tool call. The counter-argument is that being told
  something false costs more, and the observed failures were all in that direction.
- Possible cheaper home: `/pocock:handoff`, which owns the handoff format and loads on
  demand. Weaker, because handoffs get written without that skill, as they were here.
- Overcorrection risk: taken too literally this strips useful context and produces handoffs
  that are only link lists. The wording above keeps dated snapshots explicitly allowed.

## Evidence

- `ssb.website`, commit `922ed9f5c` (pass 1), `f3f32f7d9` (pass 2, its body lists each
  corrected statement), `8c84a2212` (pass 3, archival plus the extracted remainder).
- The four broken `done/` cross-references and the resolution check are described in
  `f3f32f7d9`.
- Retrospective naming the shared cause in `.aiassistant/state/notes/effort-calibration.md`,
  commit `75177b716`.
