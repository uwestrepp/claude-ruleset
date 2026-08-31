# A pre-action check must be its own tool call to count as a check

```
Date:         2026-08-17
Status:       superseded
Superseded by: .aiassistant/state/proposals/proposal-2026-08-31-verification-reach-consolidation.md
Origin:       session observation — /core:commits step 12 was executed and still
              failed to prevent the thing it exists to prevent
Revisit when: a second instance of a verify-then-act pair collapsed into one tool
              call, in any workflow, or the next /core:rule-friction cycle
```

## Problem

`/core:commits` Enforcement step 12 requires running `git diff --cached --name-only`
and confirming that only the intended files are listed, before committing. The agent
ran it. The commit still swept in 13 unintended files.

Cause: the check and the `git commit` were placed in the **same** Bash invocation.
The output appeared in the result, but by then the commit had already been created.
A check whose result the checker cannot read before the action is not a check, it is
a log line.

The specific damage: `git mv` had staged 13 dbt renames earlier in the session. The
Terraform commit was meant to carry 4 files and carried 17. Recovered with
`git reset --soft HEAD~1` plus `git restore --staged`, so nothing was lost, but only
because the mistake was noticed in the commit output.

This is the temporal sibling of General.md §5.6. §5.6 stops a check whose *exit code*
cannot express failure; this stops a check whose *result* arrives too late to act on.
Both produce the same illusion of verification.

## Proposed change

Primary, narrow, no always-on cost. In the `/core:commits` skill, step 12, add the
load-bearing constraint:

> This MUST be a separate tool call. A `git diff --cached` in the same shell
> invocation as the `git commit` does not satisfy this step: the commit is already
> created by the time the output can be read. The same applies to step 14
> (post-commit scope check) relative to any follow-up action.

Secondary, only if a second instance appears outside commits: generalise it as a
clause in General.md §5.6, along the lines of "when a check gates an action, the
check MUST complete in its own step; a verify-then-act pair in a single invocation
satisfies neither". Deliberately **not** proposed for §5.6 now, per §3.3: §5.6 is
always-on and one incident does not justify the token cost when the narrow skill
edit covers the observed case.

## Expected impact

Closes a gap where following the checklist literally still permits the failure. Step
12 currently reads as satisfiable by any invocation that contains the command, which
is how it was satisfied and still failed.

## Risk / tradeoff

- Costs one extra tool call per commit. Small, and it is the cost the step was
  always meant to have.
- Skill-scoped, so no always-on token cost (`Meta.md` §3.3).
- Does not generalise on its own. A different verify-then-act pair collapsed into
  one call stays uncovered until the §5.6 clause is added. Accepted deliberately,
  see `Revisit when`.

## Evidence

- 2026-08-17, `~/work/projects/airbyte`, branch `feature/MQDEV-191-linkedin-reporting`.
  Intended scope 4 Terraform files; the created commit contained those plus 13 dbt
  renames staged earlier by `git mv`. Rebuilt as `87aceac` (Terraform only) and
  `6d71d97` (dbt only) after `git reset --soft HEAD~1` and
  `git restore --staged dbt docs`.
- The corrected pattern used for the remaining commits in that session: one call for
  `git add` plus `git diff --cached --name-status`, read the list, then a second call
  for `git commit`.
