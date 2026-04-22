---
name: commits
description: "Activate via /core:commits or let Claude auto-activate when the task involves creating, amending, or rewriting git commits. Enforces the commit message schema ([TYPE] JIRA (scope) summary), Jira ticket traceability rules (extension-ticket map resolution, branch override resolution, multi-extension commit splitting), body decision gate (when to include body vs subject-only), pre-commit validation checklist, and nested-repository commit handling. Triggers: 'commit these changes', 'create a commit', 'commit the fix', 'amend commit', 'git commit', 'write a commit message', preparing PR-worthy commits, splitting mixed changes across tickets, resolving which Jira ticket applies to a commit, any request mentioning commits/committing/amending."
argument-hint: [scope]
allowed-tools: [Read, Edit, Write, Glob, Grep, Bash]
---

# Commit Message Generation Rules

## General

-   Output a **subject line** and **optionally a body**.
-   The **subject line is mandatory**.
-   Add a **body only if required** (see criteria below).

------------------------------------------------------------------------

## Subject Line (Required)

Format exactly:

    [{TYPE}] {JIRA} ({scope}) {summary}

Validation regex (use as hard check):

    ^\[(FEAT|FIX|BUILD|CHORE|CI|DOCS|STYLE|REFACTOR|PERF|TEST)\] [A-Z]+-[0-9]+ \([a-z0-9._/-]+\) .+

### `{TYPE}`

Must be one of (choose the best fit):

    [FEAT] [FIX] [BUILD] [CHORE] [CI] [DOCS] [STYLE] [REFACTOR] [PERF] [TEST]

### `{JIRA}`

-   Must match: `ALLCAPS-123` (e.g. `ABC-42`)
-   Apply branch overrides first from `.aiassistant/state/commit-ticket-overrides.yaml` (if current branch is listed)
-   For extension-scoped commits (per project package layout, e.g., `packages/*/...`), resolve from `.aiassistant/state/extension-ticket-map.yaml` if present
-   If multiple mapped extensions with different tickets are touched, split into separate commits per ticket
-   For non-extension commits, fallback to branch ticket from `$GIT_BRANCH_NAME` (`feature/PROJ-123-...`)
-   If no deterministic ticket can be resolved: ask and do not commit until clarified
-   If user explicitly provides a Jira ticket and it conflicts with resolver output, stop and ask before committing

### Override map maintenance (MUST)

-   Branch-specific ticket exceptions must be stored in `.aiassistant/state/commit-ticket-overrides.yaml` (not hardcoded in scripts/rules)
-   When the agent encounters a new or changed branch-level exception, it MUST update `.aiassistant/state/commit-ticket-overrides.yaml` in the same change-set
-   If the project provides a ticket resolver script (e.g. `bin/script/mq-commit-ticket`), keep its behavior aligned with that file format

### Nested repositories (MUST)

-   If touched files are inside a nested Git repository (for example `packages/<extension>/.git`), commit from that nested repository
-   Do not assume root repository commits include nested-repo file changes
-   Report branch and commit hash from each affected repository

### `{scope}`

-   Lowercase
-   Wrapped in parentheses
-   Follow Conventional Commits scope conventions
-   Use the most relevant affected area (e.g. `api`, `auth`, `ui`, `db`,
    `ci`)

### `{summary}`

-   Brief
-   Imperative mood (start with a verb)
-   No repetition
-   No unnecessary detail
-   Describe what changed in the modified files

------------------------------------------------------------------------

## Body (Optional -- Only If Needed)

Add a body **iff** the change:

-   Is complex or non-obvious
-   Contains multiple distinct changes — defined as: changes addressing 2+ separate findings or topics, OR touching 3+ files with logically distinct purposes, OR a single commit with 200+ insertions across 3+ files
-   Requires explanation of reasoning or trade-offs
-   Includes migration or rollout steps
-   Requires testing instructions
-   Has important side effects, risks, or follow-ups

### Body Decision Gate (MUST)

-   A body is allowed only when **at least one** criterion above is true.
-   If none of the criteria apply, the commit message MUST be **subject-only**.
-   Do not add boilerplate `Why/What/How to test/Notes` sections when body is not required.
-   Typical no-body cases:
    - single-purpose wording/formatting cleanup in one file
    - small mechanical rule/doc maintenance with obvious intent and no side effects

------------------------------------------------------------------------

## Body Format

-   Separate from subject with **one blank line**

-   Use short bullet-style sections

-   Prefer structured headings:

    Why: explanation or context 
    What: grouped key changes 
    How to test: concrete verification steps 
    Notes: risks, migrations, follow-ups

-   `How to test` MUST follow `General.md` section `5.2` and the `/core:batch` skill §9.4:
    - list concrete runtime/functional validation steps actually executed when required by risk/impact,
    - static analyzer/lint commands are supplementary compliance checks and SHOULD be listed only when they provide collaborator-relevant signal (for example: explicitly requested, required by workflow, or reporting notable status such as "phpstan all clear"),
    - static analyzer/lint commands MUST NOT be presented as behavioral/regression proof and MUST NOT replace required runtime/functional validation.

------------------------------------------------------------------------

## Example

    [REFACTOR] ABC-123 (auth) simplify token validation flow

    Why: reduce duplicated validation and edge-case bugs
    What:
    - unify JWT parsing and signature verification
    - centralize clock-skew handling
    How to test:
    - run vendor/bin/phpunit --testsuite Auth
    - verify login + refresh token flow locally
    Notes:
    - follow-up: remove deprecated validator in next release

------------------------------------------------------------------------

## Enforcement Layers

Commit-schema enforcement runs at two independent layers:

1. **Claude-side PreToolUse hook** (`~/.claude/hooks/validate-commit-message.sh`, `block-forbidden-stages.sh`) — intercepts `git commit` tool calls from any Claude session before the shell runs them. Global, applies in every project, no per-project setup. Covers: subject-format validation, denylisted path soft-blocking (`settings.local.json`, `.aiassistant/scratch/`, override/secret patterns — see `rules/Meta.md` §1.4).
2. **Project-native git hooks** (`<repo>/.githooks/` activated via `core.hooksPath`) — run at the git level regardless of commit source (Claude, IDE, CLI, colleague). Project-specific (ticket map, branch conventions, protected-branch guard). Installed via `/core:githooks-install`.

Neither layer alone is sufficient:
- Claude-side only protects against *this* agent's tool calls.
- Native-hook only protects against `git commit`; it doesn't catch stage-time slips before the command is issued.

Both layers SHOULD be present in any project with real ticket traceability or shared-repo discipline.

Branch-confirmation (checking `git branch --show-current` before committing) is a *workflow* responsibility of this skill, not a hook check. Hooks can verify ticket-branch consistency but cannot decide whether the current branch is the right target for the work.

------------------------------------------------------------------------

## Session Precheck (MUST, once per session)

Before executing the per-commit checklist for the first time in a session, the agent MUST run this precheck against the current project:

1. Resolve repo root: `git rev-parse --show-toplevel`.
2. Detect native-hook state:
   - `<repo>/.githooks/` exists, OR
   - `git config --get core.hooksPath` returns non-empty,
   - → native hooks present; record and skip to step 4.
3. Check opt-out/install marker at `<repo>/.aiassistant/state/githooks-install.yaml`:
   - `status: installed` → treat as installed (skip step 4).
   - `status: declined` → respect opt-out; do NOT suggest (skip step 4).
   - missing → continue to step 4.
4. If neither native hooks nor a marker is present: suggest installation once, with wording like:
   > This project has no native commit-hook scaffold (`.githooks/` absent, `core.hooksPath` unset). `/core:githooks-install` adds format + ticket-traceability enforcement that catches slips from any commit source. Install now?
   > - `yes` → invoke `/core:githooks-install`
   > - `no` → record opt-out in `.aiassistant/state/githooks-install.yaml`; do not ask again
   > - `later` → skip this session; re-ask next session

The agent MUST NOT auto-install without explicit user confirmation (git-config mutation).

The agent MUST NOT repeat the suggestion in the same session after the user has answered it, and MUST NOT repeat across sessions after a `declined` marker is recorded.

------------------------------------------------------------------------

## Enforcement (MUST)

Before running any `git commit`, the agent MUST execute this checklist:

1. Confirm `General.md` section `5.2 Test Path Selection & Execution` is completed (or blocked with explicit reason and follow-up command).
1a. **State runtime evidence** in chat before drafting the subject:
    - (a) executed path/command that exercised the changed code/config (not a form-check or availability probe — see `General.md` §5.2),
    - (b) observed outcome.
    If execution is blocked (environment, tool, privilege, no test env, sudo required): state blocker and the exact follow-up command/manual step per `General.md` §5.2; do not commit without either concrete evidence or an acknowledged blocker.
    Required even for subject-only commits where the body-decision gate produces no "How to test" section. Chat-stated evidence is sufficient; persistence is not required.
2. Resolve expected Jira ticket — if the project provides a resolver script (e.g. `bin/script/mq-commit-ticket`), run it; otherwise apply the resolution rules above manually:
   - branch overrides: `.aiassistant/state/commit-ticket-overrides.yaml` (if applicable)
   - extension-scoped changes: resolver output from `.aiassistant/state/extension-ticket-map.yaml` (if present)
   - non-extension changes: fallback branch ticket from `git branch --show-current`
3. If user-provided ticket conflicts with resolver output, stop and ask before committing.
4. If resolver reports missing mapping or mixed tickets (exit code 4 or 5): determine whether this is a multi-extension feature branch (branch intentionally spans several extensions under one Jira ticket). If yes, add the branch → ticket entry to `.aiassistant/state/commit-ticket-overrides.yaml` in the same commit before retrying. If no, split the commit per ticket or fix the missing map entry.
5. Draft commit subject using required schema.
6. Validate subject against the regex above.
7. Re-check `{TYPE}` is in the allowed list and `{scope}` is lowercase.
8. Ensure subject ticket equals resolved expected ticket.
9. Decide if body is required using the **Body Decision Gate** above.
   - if no criterion matches: commit subject only
   - if one or more criteria match: include concise body sections
10. For TYPO3 upgrade/migration scoped commits: confirm `TYPO3.md` §6.1 completion criteria are all addressed. Criterion 4 (UPDATE*.md synchronized) MUST be explicitly marked as complete or confirmed not applicable with a short rationale before the final commit in the cycle.
11. For nested repositories, run `git commit` in the affected nested repository context.
12. Only then run `git commit`.

If validation fails at any step:

- abort commit creation,
- rewrite the subject,
- re-validate,
- continue only when valid.

If a non-compliant commit was already created in the current session:

- immediately notify the user,
- rewrite the commit message to compliant format before proceeding.
