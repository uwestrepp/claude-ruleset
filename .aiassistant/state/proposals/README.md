# Rule-set proposals

Durable home for `Meta.md` §3.1 improvement proposals that are not applied in the session
that produced them. Without this store a proposal exists only in a chat checkpoint and is
gone when the session ends, which is the specific loss this directory prevents.

Not every proposal belongs here. A proposal the user accepts on the spot is applied and
needs no file. This store is for the ones that are **parked** (real, but not yet worth the
change), **open** (awaiting a decision), or **kept as a record** of a decision already taken.

## Naming

`proposal-<YYYY-MM-DD>-<slug>.md`, dated by first authoring. Keep the date on later edits;
record progress in `Status` instead.

## Required header

```
Date:         <YYYY-MM-DD>
Status:       parked | open | accepted | rejected | shipped | superseded
Superseded by: <repo-relative path of the record that absorbed it> (required for `superseded`)
Origin:       where it came from — session observation, friction window, user remark
Revisit when: the concrete trigger that reopens it (required for `parked`)
```

`Revisit when` is what keeps a parked proposal from becoming litter. It must name an
observable event ("a second instance of this failure", "next `/core:rule-friction` cycle",
"when the affected rule file is touched anyway"), never "later".

`Superseded by` is what keeps an archived proposal reachable. It names the absorbing record
by repo-relative path, so the pointer survives a move of either file. Without it the status
is a deletion in disguise.

## Required sections

The four from `Meta.md` §3.1, plus two that only matter once a proposal outlives its
session:

1. **Problem** — what went wrong or is missing, concretely.
2. **Proposed change** — the edit, naming the target file and section.
3. **Expected impact** — what it prevents or improves.
4. **Risk / tradeoff** — including the always-on token cost where applicable
   (`Meta.md` §3.3).
5. **Evidence** — where it was observed: file, session, project, commit. A proposal without
   a traceable incident is a guess, and §3.3 will ask for the incident later.
6. **Why parked** — for `parked` only: the honest reason it is not being applied now.

Terse per `Meta.md` §3.2. A one-fact proposal is allowed to be half a page; the length of
the existing implementation-visibility record is an outlier, not the target.

## Lifecycle

`parked` or `open` → applied, then `shipped`; or dropped, then `rejected`. In both cases
move the file to `done/` per `Meta.md` §2.4, still committed. Archive, never delete: a
rejected proposal is the record that stops the same idea being re-derived from scratch.

A third path: `parked` or `open` → absorbed into a consolidation record, then `superseded`,
and to `done/` like the other terminal states. It is the only status that is not a decision
about the idea. The archived file stays the full-text source; the record carries the
substance forward and becomes the active form. That makes it honest only when it is true —
a proposal whose proposed change is not represented in the absorbing record is not
superseded, it is dropped, and `rejected` with a stated reason is the correct status.

Consolidate when one error has been recorded on n axes as n files: that is cheaper in
always-on tokens and stronger evidence under `Meta.md` §3.3 than n competing additions.
`proposal-2026-08-31-verification-reach-consolidation.md` is the worked case.

Promotion out of `parked` needs the same discipline as any rule change (`Meta.md` §3.2):
check overlap, prefer the narrowest matching file, and update the `CLAUDE.md` rule index in
the same change-set when a rule file is added, removed or renamed.
