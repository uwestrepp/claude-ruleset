# Protected-branch guard module

Two independent, opt-in pre-push protections over the branches matched by
`HOOK_PROTECTED_BRANCHES` (default: `release/* main master dev staging*`):

1. **Built-in direct-push block** (`HOOK_BLOCK_DIRECT_PUSH=1`) — rejects any
   direct push to a protected branch (PR-only model, `General.md` §12). No
   project command required. Override at push time with the bypass env
   (`HOOK_BYPASS_ENV`, default `SKIP_COMMIT_MSG_CHECK`).
2. **Project-specific content guard** (below) — dispatches to a custom command
   for content checks (local overrides, dev URLs, tagging policy).

## Content-guard command

Wires a project-specific guard command into the `pre-push` hook for pushes
that target protected branches (matched against `HOOK_PROTECTED_BRANCHES`).

## Contract

The guard command is invoked as:

```
<command> --branch <local_ref> --rev <local_sha>
```

Non-zero exit rejects the push. The command SHOULD print an actionable error
to stderr explaining why the push was rejected.

## Typical use cases

- Block pushes that still carry local-only Composer overrides (tracked dev
  constraints, path repositories, registry excludes) to a release branch.
- Block pushes that still reference local development URLs, feature flags,
  or debug switches.
- Enforce tagging/changelog policies before promotion.

## Configuration

In `config.sh` next to the hooks:

```bash
HOOK_PROTECTED_BRANCH_GUARD=1
HOOK_PROTECTED_BRANCH_GUARD_COMMAND="/path/to/project/bin/protected-branch-guard"
HOOK_PROTECTED_BRANCHES="release/* main staging*"
```

The command path may be absolute or relative to the project root. If relative,
the pre-push hook resolves it from the repository working directory.

## No template script

No template guard script is provided: the content is inherently
project-specific. Implement the guard in your project repository (for example
under `bin/` or `tools/`) and reference it from `config.sh`.
