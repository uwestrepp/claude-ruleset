# Proposal: bind branch resolution to the commit, not to the task

```
Date:         2026-07-31
Status:       parked
Origin:       GMP-340 go-live session — nearly committed to the protected branch `staging`
Revisit when: a second near-miss or actual commit on a protected branch, or the next
              /core:rule-friction cycle, whichever comes first
```

## Problem

`General.md` §12 says: "Before the first commit of a task, resolve and name the target
branch (§2.4). If the current branch is in the protected set and no override was given, stop
and ask." Both halves are sound, but the trigger is the *task*, and a task can be long.

In the GMP-340 go-live session the branch was resolved correctly at the start
(`feature/GMP-340-golive`, named in chat, one commit made on it). Hours later, after the user
had merged two pull requests and back-merged `master` into `staging` in their own client, the
working copy sat on `staging`. The agent staged three files and was one call away from
committing to a protected branch. It was caught only because an unrelated check
(`git branch --show-current` before deciding the push target) happened to run first.

The rule was followed and still did not bind. Between resolution and commit lay hours, a
context-heavy workflow and a branch switch the agent never performed and therefore had no
event to react to.

## Proposed change

Two candidate hosts, the second preferred:

- **A: `General.md` §12** — change "before the first commit of a task" to "before every
  commit, and again whenever work resumes after an interruption". Costs always-on budget in a
  file at ~10.5k tokens, and restates something the commits skill is better placed to enforce.
- **B (preferred): the `/core:commits` enforcement checklist** — add a step immediately before
  the existing step 12 (verify staged scope): re-read `git branch --show-current`, confirm it
  matches the branch resolved for this work and is not in the protected set. Costs no
  always-on budget, since the checklist is skill-body content loaded on activation, and it
  sits exactly where the commit actually happens.

B also fits the existing shape of that checklist, which already re-verifies state at commit
time rather than trusting an earlier decision (step 12 exists precisely because the index can
change underneath the agent).

## Expected impact

Closes the gap between "resolved once" and "still true now" for the one decision where being
wrong is hard to undo and violates the repository's own protection model. The check is a
single command and cannot produce a false negative.

## Risk / tradeoff

Under option B the guard only fires when the commits skill is active. That is the normal path
for commit work, but a commit made without activating the skill stays uncovered, so B is
narrower than A. Accepting that narrowness is the price of keeping always-on budget free.

Minor: one more step in a checklist that is already long, and a near-duplicate of the §12
sentence, which `Meta.md` §3.2 asks to avoid. Defensible here because the duplication moves
the constraint to its point of use rather than restating it in place.

## Evidence

- 2026-07-31, gmp project. `git branch --show-current` returned `staging` with three files
  already staged, including a rename. The agent stopped, moved the work to
  `feature/GMP-340-golive-nachweise` cut from `origin/master`, and committed there
  (`f0c696f`, PR #381).
- Contributing factor worth keeping in view: the branch switch came from outside the agent's
  own actions, so no tool result signalled it. Any fix that relies on the agent noticing its
  own state change would not have caught this.

## Why parked

User decision, 2026-07-31: single occurrence, and the existing rule did catch it in the end,
by a margin. Promote on a second instance, which would establish it as a pattern rather than
one long session. See also [[proposal-2026-07-29-implementation-visibility]] for the general
question of which guarantees survive a long session and which quietly stop binding.
