---
name: static-tests
description: "Activate with /typo3:static-tests before starting any TYPO3 static code analyzer or fixer run (php-cs-fixer, Rector, Fractor, TypoScript lint, PHPStan). Required before structured static-test cycles begin."
argument-hint: "[scope]"
allowed-tools: [Read, Edit, Write, Glob, Grep, Bash]
---

# TYPO3 Static Code Test Workflow

*Input (`$ARGUMENTS`): optional scope of the static-test run.*

This skill standardizes static code test execution and triage for TYPO3 projects using ddev-based tooling.
It specializes `General.md` section `5.2` and `Batch.md` §1 and must not conflict with either.

This workflow is a `Batch.md` workflow whenever the run spans multiple files, multiple tool phases, repeated remediation loops, or an ordered sequence of package/extension scopes. That includes per-package PR verification runs executed one-by-one inside a larger migration or regression cycle.

Non-skippable triage/compliance gates are defined centrally in `Batch.md` §9.1 and are mandatory for this workflow.

---

## 0. Toolset Availability Gate (MUST)

Apply `Batch.md` §2 general toolset gate. TYPO3 static-test-specific checks:
- step 1 (project type): confirm `composer.json` references `typo3/cms-core` or equivalent.
- step 3 (required commands): confirm project-specific wrapper commands exist and are callable.

**Reference project notice:** All concrete tool commands in this skill (for example `ddev mq-tests-*`, `ddev tests {action}`, directory names like `mqtests/`) originate from the reference project's toolchain. Before first use in any project, the agent MUST validate that these commands exist, identify project-specific equivalents where they differ, and use the validated commands for the remainder of the workflow. Do not assume reference-project commands are universally available.

If any check fails: report which tooling is missing, do not continue the workflow, and ask the user how to proceed.

---

## 1. Scope Source (MUST)

Use `.aiassistant/state/upgraded-extensions.yaml` as the canonical extension scope for migration-era static tests.

If this list expands, all scoped static tests must include the new extension automatically.

Legacy compatibility:
- default direct `ddev tests {static-action}` behavior remains legacy/all-packages compatible.
- migration workflow wrappers (`ddev mq-tests-upgrade`, `ddev mq-tests-rector1-baseline`) must enforce upgraded-scope mode.
- in legacy default runs (no explicit scope), tool config path definitions remain authoritative for tools that define their own path scope (for example php-cs-fixer/fractor/typoscriptlint).
- in scoped extension runs, exclude extension-local test fixture directories (`mqtests/`) from analyzed/fixed paths by default.

---

## 2. Toolchain Prep (MUST)

At the start of each static-test cycle:

- install tools once if missing:
  - `ddev mq-tests-install`
- otherwise update once:
  - `ddev mq-tests-update`

Do not repeat install/update per extension inside the same cycle.

When a larger cycle is intentionally split into one package/extension at a time, treat the whole ordered sequence as one batch workflow and each scoped pass as a phase-level checkpoint opportunity under `Meta.md` and `Batch.md`.

Clarification:
- toolchain install/update may modify test-tool lock files (for example `tests/*/composer.lock`); this is expected baseline churn.
- such lockfile updates may be committed when they belong to the same static-test maintenance cycle.
- when the task is intentionally code-only, either:
  - keep lockfile updates out of scope by skipping toolchain prep if already ready, or
  - split lockfile updates into a dedicated maintenance commit.

---

## 3. Execution Order (MUST)

Run relevant commands in exactly this order:

1. `ddev tests php-cs-fixer-apply {scope}`
2. `ddev tests rector1-dry {scope}`
3. `ddev tests rector2-dry {scope}`
4. `ddev tests fractor-dry {scope}`
5. `ddev tests typoscriptlint {scope}`
6. `ddev tests phpstan {scope}`

Project wrapper (recommended):
- `ddev mq-tests-upgrade {scope}` — runs the ordered sequence above for the given scope.

One-time legacy baseline helper:
- `ddev mq-tests-rector1-baseline --scope=<...>`

`{scope}` is either:
- one extension key (preferred default),
- or `all` for complete upgraded-extension scope.

Only `php-cs-fixer-apply` may auto-apply changes.
All others are dry-run evidence sources unless explicitly approved for application.

After rector1 baseline is completed, regular upgrade cycles may skip rector1 using marker file `.aiassistant/state/rector1-baseline.done`.
Use `--include-rector1` only when explicitly re-running legacy baseline checks.

## 3.1 Pre-Change Full Suite + Functional Baseline (MUST for larger-scale cycles)

For larger-scale static-change cycles, before applying code changes:

- run one full suite in the ordered sequence for full targeted scope (prefer `ddev mq-tests-upgrade all` or explicit multi-extension scope),
- ensure outputs are logged in `var/log/tests/...`,
- treat this suite as analyzer-compliance baseline only (not behavioral regression proof),
- ensure per-extension functional baseline documentation exists; if missing, create/update a lightweight baseline artifact (for example `docs/testing/extension-functional-baseline.md`) containing:
  - touched extension,
  - key FE/BE/API/CLI paths to verify,
  - expected pre-change behavior/result.

This section specializes `Batch.md` §3.3.

At the end of each package/extension pass within a larger cycle, provide the `Batch.md` / `Meta.md` checkpoint line explicitly, even if the result is "no meaningful improvement identified".

---

## 4. Triage Model (MUST)

Apply `Batch.md` §1 Phase 4 and `Batch.md` §9 as the canonical pass/gate model.

Static-test pass specialization:
- Pass 1 typically includes safe formatting/mechanical changes and confirmed false-positive handling.
- Pass 2 typically includes grouped, provable API/signature migrations where deterministic checks can prove equivalence.
- Pass 3 includes behavior-sensitive or ambiguous findings.

For signature/call-site affecting transformations (for example parameter removal or argument reordering), the agent MUST apply `General.md` section `4.5 Upstream Contract Verification` before making changes.

Pre-apply behavior-risk classification and non-skippable pre-edit triage gates MUST follow the shared rule in `Batch.md` §9.1.

---

## 5. Known Catches + False Positives (MUST)

Maintain:
- `.aiassistant/ledger/known-catches.md`
- `.aiassistant/ledger/known-false-positives.md`

Update these when repeated patterns are discovered.
Suppression policy:
- prefer line-level suppression only,
- file-level suppression requires explicit approval.

---

## 6. Logging (MUST)

Persist run outputs under:
- `var/log/tests/{timestamp}/{scope}/{step}.log`

Keep logs for iterative process evaluation; prune policy can be decided later.

---

## 7. Analyzer Re-Run Gate + Functional Validation (MUST)

After applying changes from static-test findings:
- re-run impacted static checks in the same ordered sequence for the affected scope (compliance evidence only),
- execute runtime/functional verification paths selected via `General.md` section `5.2` (risk-based depth is authoritative there),
- apply validation depth by pass from `Batch.md` §9.4.

Static analyzer/lint output is compliance evidence and MUST NOT replace runtime/behavioral validation (`General.md` section `5.2`).

At end of larger-scale cycles:
- re-run the full static suite for analyzer compliance comparison,
- execute final runtime regression comparison against the pre-change functional baseline documentation.
- provide the final labeled `Meta checkpoint:` result for the cycle.
