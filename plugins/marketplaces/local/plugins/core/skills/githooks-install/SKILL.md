---
name: githooks-install
description: "Activate via /core:githooks-install to install native git-hook enforcement of the /core:commits schema into the current project. Auto-suggested by /core:commits when a project has no .githooks/ and no core.hooksPath set. Covers: preflight detection, interactive config prompts, template copy from plugins/core/resources/githooks-template/, generation of .githooks/config.sh, activation via core.hooksPath, success/opt-out marker in .aiassistant/state/githooks-install.yaml, and --update mode for re-runs. Triggers: 'install git hooks', 'set up commit hooks', 'add commit validation', '/core:githooks-install', referrals from /core:commits precheck."
argument-hint: "[--update]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

# Git-Hooks Install Skill

Installs the reusable native git-hook scaffold from
`~/.claude/plugins/marketplaces/local/plugins/core/resources/githooks-template/`
into the current git project. Covers commit-subject format validation,
ticket traceability (branch-name and optional extension-map), and an
optional protected-branch pre-push guard.

## Invocation modes

| Form                              | Behavior                                                         |
| --------------------------------- | ---------------------------------------------------------------- |
| `/core:githooks-install`          | Fresh install. Aborts with diagnostic if `.githooks/` or `core.hooksPath` already set. |
| `/core:githooks-install --update` | Re-run against an installed project. Diff each template file vs the installed copy and prompt per file (keep / overwrite / show-diff). Re-reads config answers from `.githooks/config.sh` as defaults. |

No `--force` option. If you really want to nuke an existing install, remove
`.githooks/` and unset `core.hooksPath` manually, then run the bare form.

## Preflight (MUST)

Before prompting for any config, the skill MUST run these checks and abort
with an actionable diagnostic on failure:

1. `git rev-parse --show-toplevel` succeeds (cwd is inside a git repo).
2. Fresh-install mode only:
   - `<repo>/.githooks/` does NOT exist.
   - `git config --get core.hooksPath` returns empty.
3. If `.aiassistant/state/githooks-install.yaml` exists with `status: declined`,
   warn the user ("this project previously opted out") and ask whether to
   proceed; do not auto-install.
4. Write access to `<repo>/.githooks/` and `<repo>/.aiassistant/state/`.

## Configuration prompts

Ask the user, in order. Every prompt offers a default; the user can accept
by pressing enter. Skip prompts whose values are already captured
unambiguously from the project (for example, if branch naming matches the
default regex, don't re-ask).

1. **Ticket prefix regex** (`HOOK_TICKET_REGEX`)
   - Default: `[A-Z]+-[0-9]+`
   - Narrow it if the project uses a single key, e.g. `FEINSITE-[0-9]+`.
2. **Require ticket?** (`HOOK_REQUIRE_TICKET`)
   - Default: `1`. Set to `0` only for repos with no ticket convention.
3. **Extension-ticket-map module?** (`HOOK_EXTENSION_TICKET_MAP`)
   - Default: `0` (off). Enable only for monorepo/multi-package layouts.
   - If enabled, additionally ask:
     - `HOOK_EXTENSION_PATH_REGEX` (default `^packages/([a-z0-9_]+)/.+`)
     - Map file location (default `.aiassistant/state/extension-ticket-map.yaml`)
     - Whether to seed an empty map file if missing.
4. **Protected-branch guard module?** (`HOOK_PROTECTED_BRANCH_GUARD`)
   - Default: `0` (off).
   - If enabled, additionally ask:
     - `HOOK_PROTECTED_BRANCHES` (default `release/* main master staging*`)
     - `HOOK_PROTECTED_BRANCH_GUARD_COMMAND` (path to project-supplied guard script; no default — if empty, fall back to disabled with a warning)
5. **Bypass env var name** (`HOOK_BYPASS_ENV`)
   - Default: `SKIP_COMMIT_MSG_CHECK`.

Accept all defaults with a single confirmation prompt as a shortcut when the
user indicates "use defaults".

## Install steps (fresh)

Let `REPO="$(git rev-parse --show-toplevel)"` and
`TEMPLATE="$HOME/.claude/plugins/marketplaces/local/plugins/core/resources/githooks-template"`.

1. Create `$REPO/.githooks/`.
2. Copy these template files into it:
   - `commit-msg`
   - `pre-push`
   - `validate-commit-subject.sh`
   - `README.md`
3. Generate `$REPO/.githooks/config.sh` from the answers — include only
   non-default values for clarity; always include a header comment pointing
   to `config.sh.example` in the template for the full reference.
4. If extension-map enabled:
   - Copy `modules/extension-ticket-map/commit-ticket-resolver` into
     `$REPO/.githooks/`.
   - If the map file location doesn't exist, copy
     `modules/extension-ticket-map/extension-ticket-map.yaml.example` to
     the chosen path (without the `.example` suffix) and tell the user to
     fill it in.
5. If protected-branch guard enabled and a command path was given: no file
   copy needed; config.sh wires the command.
6. `chmod +x` the hook scripts (`commit-msg`, `pre-push`,
   `validate-commit-subject.sh`, `commit-ticket-resolver` if present).
7. **Activation** (creates `hooks-local` dir, points `core.hooksPath` at it).
   This modifies `git config` — ALWAYS ask for explicit confirmation before
   running, even in autonomous mode:
   ```bash
   HOOKS_DIR="$(git rev-parse --path-format=absolute --git-common-dir)/hooks-local"
   mkdir -p "$HOOKS_DIR"
   cp "$REPO/.githooks/"* "$HOOKS_DIR/"
   chmod +x "$HOOKS_DIR"/commit-msg "$HOOKS_DIR"/pre-push "$HOOKS_DIR"/*.sh "$HOOKS_DIR"/commit-ticket-resolver 2>/dev/null || true
   git -C "$REPO" config core.hooksPath "$HOOKS_DIR"
   ```
8. Suggest `.gitignore` additions (ask before editing `.gitignore`):
   - `.aiassistant/scratch/**` (per Meta.md §2.4)
9. Write the success marker:
   ```yaml
   # .aiassistant/state/githooks-install.yaml
   status: installed
   recorded: <today's date, absolute ISO>
   template_version: <git describe of template dir, or short SHA>
   modules:
     extension_ticket_map: <true|false>
     protected_branch_guard: <true|false>
   ```
10. Run a smoke test: `bash .githooks/validate-commit-subject.sh '[CHORE] AGENT (install) githooks install smoke test'` — expect exit 0 (format OK; ticket check will fail on branch mismatch but only if require_ticket=1 and branch has no ticket — handle gracefully: if exit is non-zero due to branch check, note it and tell the user the install is functional).

## Install steps (--update)

1. For each template file in use (core + enabled modules):
   - Diff against `$REPO/.githooks/<file>`.
   - If identical: skip.
   - If different: show diff, ask (keep / overwrite / show-full).
2. Re-read `$REPO/.githooks/config.sh` as defaults for config prompts; only
   prompt for values the user wants to change.
3. Re-sync `hooks-local` from `.githooks/` (same copy as fresh step 7 — no
   config change).
4. Update success marker with new `recorded` date.

## Opt-out handling

If the user declines installation (from a `/core:commits` precheck suggestion
or from this skill's fresh-install flow), write:

```yaml
# .aiassistant/state/githooks-install.yaml
status: declined
recorded: <absolute ISO date>
reason: <free-text from user or 'user declined' default>
```

Subsequent `/core:commits` precheck runs see this marker and MUST NOT
re-suggest installation.

To re-enable prompting later, the user removes the marker file (or changes
`status`). The skill MUST surface this instruction when writing the opt-out.

## Post-install user guidance

Emit a short summary:
- What was installed (files, modules, target dirs).
- How to commit with bypass: `<HOOK_BYPASS_ENV>=1 git commit -m "..."`.
- How to sync after editing `.githooks/` (re-copy to `$HOOKS_DIR`, see
  template README.md).
- If extension-map was enabled: reminder to populate the map file.
- If protected-branch guard was enabled: reminder that the guard command is
  project-supplied; verify it exists and is executable.

## Non-goals (MUST NOT)

- MUST NOT modify a project's existing `.githooks/` or `core.hooksPath`
  without the user explicitly confirming (covered by `--update` flow).
- MUST NOT write to `.gitignore` without asking.
- MUST NOT skip the `git config core.hooksPath` confirmation, even when
  operating in autonomous mode — this is a git-config mutation.
- MUST NOT suggest installation repeatedly across sessions after a
  `declined` marker is recorded.
