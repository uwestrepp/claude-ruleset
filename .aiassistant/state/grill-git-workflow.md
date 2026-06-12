# Grill: standard git workflow (rule-set + hook encoding)

Date: 2026-06-12. Source: account-standard workflow for TYPO3 projects (fein.website as model).
Purpose: encode the house git workflow as (a) a concise agent-facing rule and (b) a protected-branch git hook.

## Resolved decisions

- **Default topology** → production branch (`master` OR `main`, per project) ← `feature/PROJ-123-slug` working branches. A shared `dev` integration branch MAY exist between features and production but is often absent.
- **Optional integration tiers** → `dev` and `staging` are optional, per-project. When present they sit between features and production and are part of the protected set.
- **Major-upgrade pattern** → a temporary `release/<target>` branch (e.g. `release/typo3_13`) is created as the integration target *for that upgrade only*. Upgrade working branches are cut FROM `release/<target>` and PR'd BACK to `release/<target>`; `release/<target>` alone merges to production at completion, then is retired. This is a recurring pattern, NOT the general PR default.
- **PR-target default** → general work targets the production branch (or `dev` if the project uses one). `release/<target>` is the target only during an active major upgrade. `release/typo3_13` in `CLAUDE.local.md` is the current instance of this pattern, not a permanent global default.
- **Merge / protected policy** → production, `dev`, `staging`, and `release/*` are reached via PR, NOT direct commits. This is the behavioral default **even when git/server does not technically protect the branch**. Override only on explicit user request. Agent commits only on `feature/`|`bugfix/`|`hotfix/` working branches.
- **Protected set (hook guard)** → `{master|main}` ∪ `{dev?}` ∪ `{staging?}` ∪ `{release/*}`. Production branch auto-detected per project; per-project specifics live in the project hook config. Hook hard-blocks direct commits to the set, with a documented override path for the "explicitly requested" case.
- **Working-branch taxonomy** → ticketed branches use `feature/PROJ-123-slug`, `bugfix/PROJ-123-slug`, or `hotfix/PROJ-123-slug`. `release/<target>` is the only integration prefix. Requires widening the `/core:commits` ticket-fallback regex (currently `feature/` only) and the hook's working-branch detection to accept `bugfix/` and `hotfix/`.
- **Encoding split** → rule (agent-facing workflow definition) + git hook (enforcement). Confirmed "both".

## Stated assumptions (accepted, unverified)

- Production branch name varies per project (master vs main); the hook auto-detects rather than assuming one — revisit if a house standard is later mandated.
- `staging` and `dev` are independent optional tiers; a project may have neither, either, or both — the guard includes whichever exist.
- Hook override mechanism (for the "unless explicitly requested" escape) will be a config flag / env var — exact form TBD at implementation.

## Rejected alternatives

- master/staging/dev as *mandatory* three-tier topology — rejected: dev/staging are optional, not always present.
- `release/*` as the *permanent general* PR target — rejected: it is a major-upgrade-only pattern.
- House-wide single branch name (main-only or master-only) — rejected: resolve per project instead.
- Advisory-only hook (warn, no block) — rejected: PR-only is the enforced default, override is explicit.
- `feature/`-only naming — rejected: `bugfix/`/`hotfix/` are in use.

## Resolved at implementation (2026-06-12)

- **Rule location** → new always-on `General.md` §12 "Git Workflow (MUST)"; `CLAUDE.md` index line updated. No new rule file.
- **`/core:commits`** → no regex change needed: `HOOK_TICKET_REGEX` matches the ticket token regardless of prefix, so `bugfix/`/`hotfix/` already validate. Prose example widened to the full taxonomy + cross-ref to §12.
- **Hook** → existing `protected-branch-guard` was a project-specific *content* guard. Added a built-in `HOOK_BLOCK_DIRECT_PUSH` toggle (opt-in, default 0) to `pre-push` that rejects direct pushes to a protected branch; override reuses the existing `HOOK_BYPASS_ENV` (`SKIP_COMMIT_MSG_CHECK`). Added `dev` to default `HOOK_PROTECTED_BRANCHES`. Documented in config.sh.example, module README, and githooks-install skill.
- **Enforcement scope decision** → backstop at *push* time (PR-only promotion layer), not commit time (would block local work on protected branches). Default off = zero impact on existing installs.
