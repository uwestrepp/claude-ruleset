# Extend General.md §5.6 to the completeness of the verified population

```
Date:         2026-08-18
Status:       open
Origin:       session observation — false all-clear in the MQDEV-195 migration rehearsal
Revisit when: a second instance of "verified the reported subset, concluded about the
              whole" lands in any project, or the next /core:rule-friction cycle
```

## Problem

In the MQDEV-195 rehearsal I had to answer: "are the Postgres identity sequences advanced
after `n8n import:entities`?" The tool printed `Advancing Postgres IDENTITY sequences...
Advanced 4 sequence(s) across 21 table(s)`. I checked those four against `max(id)` of their
tables, found them consistent, and recorded the checkpoint as passed.

The evidence was real and the four sequences were genuinely correct. The conclusion was
still wrong, because the question was universal and the check was not: n8n's step covers
only `GENERATED ... AS IDENTITY` columns, and seven n8n tables still use plain `SERIAL`.
Their sequences were left at 1 while the imported rows already occupied ids up to
`max(id)`. One of them, `workflow_statistics`, is imported by default, so the planned
production migration would have shipped a silent duplicate-key failure surfacing days
later with no visible link to the migration.

I verified the set the tool reported. I never asked whether that set was the whole set. The
check I ran could not fail for a sequence the tool did not name, so it could not have
detected the defect no matter how carefully I read its output.

This is adjacent to, but not covered by, the existing rules:

- **§5.6** guards against a *command* that lies: a success branch emitting a positive
  signal regardless of the actual result. Here the command told the truth. The command was
  not the problem, the scope of my assertion was.
- **§1.5** requires a ground-truth check before asserting a diagnosis. I ran one. It
  answered a narrower question than the one I claimed to have answered.

Nothing currently says that a tool's report of its own work bounds the check to what the
tool knows.

## Proposed change

One clause appended to `General.md` §5.6:

> When the fact being verified is universal ("all X are Y", "nothing is left in state Z"),
> the population MUST be enumerated from the system itself (schema, filesystem, index,
> config), not from the report of the tool whose work is being verified. A tool's account
> of what it did cannot surface what it omitted, so a check bounded by that account cannot
> fail for the omitted case.

## Expected impact

Covers a class that recurs wherever a tool reports its own work and the agent verifies
against that report: import and migration tools naming the tables they touched, codemods
and fixers naming the files they changed, backup tools naming the paths they archived,
`/core:batch` §9.4 validation over an inventory the analyzer produced. In each case the
correct move is the same and cheap: derive the population from the system, then assert over
it. Here that would have been one query over `pg_depend` instead of reading n8n's four-line
summary, and it would have caught the defect on the first rehearsal instead of the third.

## Risk / tradeoff

- **Always-on token cost.** `General.md` is `[CRITICAL]`, so this is roughly 60 always-on
  tokens per session against the `Meta.md` §3.3 budget. That is the main argument against,
  and §5.6 has already absorbed one extension (the authoring clause) on similar grounds.
- **Overcorrection.** Read literally, "enumerate the population from the system" is
  expensive if applied to every verification. The `universal fact` trigger is what keeps it
  bounded; without that qualifier the clause would invite re-deriving whole populations for
  trivial single-fact checks, which §10.1 argues against.
- **Placement alternative.** The failure mode is most likely inside migration and batch
  work, so the `/core:batch` skill §9.4 is a candidate home with zero always-on cost. The
  counter-argument is that this bit me *outside* a batch cycle, in an ordinary rehearsal of
  a single change, and a skill that is not loaded cannot prevent anything.
- **Not a substitute for §5.6.** The two failure modes are independent: a command can lie
  about a complete population, or tell the truth about an incomplete one. Both clauses are
  needed if both are to be covered.

## Evidence

- Project `mq.n8n-server`, branch `feature/MQDEV-195-postgres`, commit `11f4506`
  ([FIX] repair sequences that import:entities leaves behind).
- The false all-clear: `.aiassistant/state/MQDEV-195/01-migrationsplan.md` §3.1,
  checkpoint 2 ("Ja, und n8n macht es selbst"), written 2026-08-18 after two rehearsals.
- The correction and the reproduction: same file, §3.2. Silent form reproduced by resetting
  `workflow_statistics_id_seq` to the post-import state, then calling a newly activated
  webhook workflow: HTTP 200, execution succeeds, no new statistics row, two
  `duplicate key value violates unique constraint` in the log. Fatal form reproduced by
  importing with `--includeExecutionHistoryDataTables=true`: webhook answers HTTP 500,
  execution count unchanged.
- Contributing detail worth remembering separately: `pg_sequence_last_value()` returns
  `NULL` when `is_called = false`, which is neither proof of "never used" nor of "correctly
  set". Reading `last_value, is_called` directly off the sequence is the check that
  distinguishes them.
