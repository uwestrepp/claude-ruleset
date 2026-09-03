# A working branch's upstream must never be a protected ref

Date:         2026-09-03
Status:       open
Origin:       session observation in project rbk, then a direct user remark ("Ziel sollte
              immer die Feature-Branch sein, nie main oder release")
Revisit when: n/a (open, awaiting a decision)

## Problem

Creating a branch from a base sets its upstream to that base, silently. `git worktree add
-b <new> <base>`, `git branch <new> <base>` and `git checkout -b <new> origin/<base>` all
imply `--track`. When the base is in the `General.md` §12 protected set, the result is a
working branch configured to pull from and push to a ref it may never touch.

The rule-set covers the action and the decision point but not the mechanism:

- §12 forbids a direct commit or push to the protected set.
- §2.4 requires naming the resolved push remote and upstream before a planned push.
- Nothing names the tracking configuration itself, so the trap is created at branch time
  and only becomes visible one command before the damage.

That ordering is what makes it slip: by the time §2.4 fires, the misconfiguration is
already several commits old, and `git status` has been reporting "ahead of origin/main"
the whole time, which invites wrong follow-up decisions.

Exposure depends on config, and the safe case is not the norm to rely on. With
`push.default` unset (effective `simple`, the case in rbk) a bare `git push` is refused
because the upstream name differs from the branch name. Under `push.default=upstream` it
pushes onto the protected ref. Independently of that setting, `git pull` merges the
protected branch into the working branch and drags unrelated commits into the PR.

## Proposed change

Split along the established invariant-vs-mechanics line:

- `General.md` §12, one sentence as an invariant: a working branch's upstream is its own
  remote branch, never a ref in the protected set; create with `--no-track` when branching
  from a base and set the upstream on the first push (`git push -u origin HEAD`).
- `/core:git-knowledge`, the mechanics: which commands track implicitly, the audit line
  `git for-each-ref --format='%(refname:short) -> %(upstream:short)' refs/heads/`, and the
  repair `git branch --unset-upstream <branch>`.

## Expected impact

The class is caught at branch creation instead of at push time, and one command audits a
whole repo for existing cases. The audit is cheap enough to be worth running whenever a
push to a protected-adjacent branch is planned.

## Risk / tradeoff

- One sentence added to always-on `General.md` §12; §3.3 counts the budget. The
  justification for always-on placement is that the failure is produced by a tool default
  rather than by ignorance, so a skill-only home would not be loaded at the moment the
  branch is created.
- Keeping the mechanics in the skill is deliberate: §12 should not grow into a git manual.
- A `--no-track` habit loses the convenience of `git pull` resolving to the base for
  branches where that IS wanted (a long-running integration branch). The invariant is
  scoped to working branches for that reason.

## Evidence

- This session, project `/home/uwestrepp/work/projects/typo3/rbk`: `git worktree add -b
  feature/RBK-22-security-txt origin/main` and the v13 equivalent produced upstreams
  `origin/main` and `origin/release/typo3_13` on the two RBK-22 working branches
  (commits `cf46945`, `3f9b311`).
- Detected by the user, not by the agent, and not by any rule check.
- Repaired in-session with `git branch --unset-upstream`; the audit line above showed all
  other local feature branches in that repo tracking their own remote, so the defect was
  confined to the two branches created this session.
