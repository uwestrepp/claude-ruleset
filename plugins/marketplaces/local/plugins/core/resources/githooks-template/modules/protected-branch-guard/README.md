# Protected-branch guard module

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
