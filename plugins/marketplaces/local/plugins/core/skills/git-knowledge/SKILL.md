---
name: git-knowledge
description: "Activate via /core:git-knowledge or let Claude auto-activate when the task involves git branch/workflow mechanics beyond the General.md §12 safety baseline: how to detect a project's real deploy mapping, disambiguate remotes/worktrees/upstreams, choose a diff or merge baseline, rebase/merge/force-push hygiene, or recover lost work. Triggers: \"which branch does this deploy\", \"does merging to main deploy\", CI deploy-mapping questions (bitbucket-pipelines.yml / .gitlab-ci.yml / GitHub Actions branch filters), multiple remotes (origin vs fork vs deploy mirror), git worktree setup, choosing a PR/diff/upgrade baseline, \"undo a bad reset / recover a deleted branch / find a lost commit\", reflog recovery, force-push safety, interactive-rebase alternatives. NOT commit-message drafting (/core:commits), NOT git-hook install (/core:githooks-install)."
argument-hint: "[topic]"
allowed-tools: [Read, Grep, Glob, Bash]
---

# Git Operational Knowledge

*Input (`$ARGUMENTS`): optional git topic to focus on.*

Project-agnostic operational depth for git branch/workflow tasks. Normative
keywords per `General.md`. This skill is ADDITIVE: the always-on safety and
traceability baseline (protected set, PR-only, branch naming, override,
before-first-commit stop-and-ask) lives in `General.md §12` and is NOT repeated
here. Read §12 for what is *allowed*; read this for *how* to do it correctly.

The environment blocks interactive git flags (`git rebase -i`, `git add -i`);
use the non-interactive alternatives in §4/§5.

---

## 1. Branch model & naming (reference)

Baseline definitions (authoritative in `General.md §12`):

- Mainline is `master` or `main` per project. Optional integration tiers
  `dev`/`development` and `staging` may sit between feature branches and mainline.
- Ticketed work: `feature/`, `bugfix/`, or `hotfix/` branch named
  `{prefix}/PROJ-123-slug`, cut from the branch it will merge into.
- During a major upgrade the integration branch is `release/{target}` (mechanics
  in `/composer:major-upgrade`).

Resolve the current branch with `git branch --show-current` before any commit
(§12 requires naming the target first).

## 2. Deploy-mapping detection (MUST verify before assuming a push deploys)

`General.md §12`: merging to mainline ≠ deploying. A push deploys only if the
project wires that branch to a deploy pipeline. Detect the REAL mapping before
asserting a deploy will (or will not) happen (a diagnosis-class claim, `§1.5`):

- **Bitbucket Pipelines** — `bitbucket-pipelines.yml`: look under `pipelines:`
  for `branches:` keys and any `deployment:` steps. The branch key that carries
  the deploy step is the trigger, which is often NOT mainline (e.g. a dedicated
  `production` branch that mainline is merged into).
- **GitLab CI** — `.gitlab-ci.yml`: jobs with `environment:` and `rules:` /
  `only:` / `except:` branch conditions.
- **GitHub Actions** — `.github/workflows/*.yml`: `on.push.branches` filters plus
  an `environment:` in the deploy job.
- **Deployer / other** — check `deploy.php`, `.deployer/`, or CI wrapper scripts
  for the branch each stage checks out.

State the resolved mapping explicitly (`§2.4`) when a commit/merge/push could
trigger a deploy.

## 3. Remote / worktree / baseline disambiguation

Before a push, review, or upgrade diff, resolve which target you mean (`§2.4`):

- **Remotes** — `git remote -v`. Distinguish `origin` from a fork and from a
  deploy mirror. Confirm the push upstream with
  `git rev-parse --abbrev-ref @{upstream}` (or the intended `-u` target); do not
  assume `origin` when several remotes exist.
- **Worktrees** — `git worktree list`. A sibling worktree shares the same repo
  but sits on a different branch; confirm you are editing the intended checkout,
  not a nested/sibling one.
- **Diff / merge / upgrade baseline** — name it explicitly: PR base branch,
  upstream artifact version/major, or the referenced ticket relation (parent vs
  sibling). Example: diff against `release/typo3_13`, not `master`.

## 4. Rebase / merge / force-push hygiene

- Prefer `git rebase {base}` (non-interactive) to linearize; `git rebase -i` is
  blocked in this environment. To reword/squash without `-i`: reset softly
  (`git reset --soft {base}`) and re-commit, or use `git commit --amend` for the
  tip only.
- Force-push only with `--force-with-lease` (rejects if the remote moved);
  the destructive-command hook asks on a bare `--force`/`-f`. Never force-push a
  branch in the `§12` protected set.
- Merge vs rebase: match the project convention; do not rewrite a branch others
  have already based work on.

## 5. Recovery

Most "lost" work is recoverable via the reflog before gc:

- **Undo a bad `reset --hard`** — `git reflog`, find the pre-reset SHA, then
  `git reset --hard {sha}` (or `git branch rescue {sha}` to inspect first).
- **Recover a deleted branch** — `git reflog` (or `git fsck --no-reflogs
  --lost-found` for dangling commits), then `git branch {name} {sha}`.
- **Recover a dropped stash** — `git fsck --unreachable | grep commit`, inspect
  with `git show {sha}`, restore via `git stash apply {sha}`.
- Recovery is time-bounded by `gc.reflogExpire`/`gc.pruneExpire`; act before a
  `git gc --prune=now` (which the hook asks on).

---

Domain- or project-specific git conventions (PR API flow, deploy branch names)
live in the project's `CLAUDE.md` / `CLAUDE.local.md`, not here.
