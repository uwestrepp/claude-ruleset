---
name: upgrade
description: "Activate with /typo3:upgrade before starting any TYPO3 upgrade, migration execution, or deprecation/breaking-change remediation task. Provides the full TYPO3 Upgrade Workflow (Execution + DoD): phase template, preflight, inventory, deprecation/breaking scan, implementation constraints, validation checklist, documentation sync, and commit strategy. Required before any structured TYPO3 version upgrade work begins."
argument-hint: [scope]
allowed-tools: [Read, Edit, Write, Glob, Grep, Bash]
---

# TYPO3 Upgrade Workflow (Execution + DoD)
Applies to extension upgrade tasks (for example TYPO3 major/minor compatibility migrations).

This workflow is mandatory when the task is an upgrade and complements `TYPO3.md`
and `Batch.md` (execution phases, toolset gate, autonomous mode, chaining, reporting).

Non-skippable triage/compliance gates are defined centrally in `General.md` section `5.8.0` and are mandatory for this workflow.

**Changelog reference:** The TYPO3 deprecation/breaking-change index (v10–v14) is available in `references/changelog.md` within this skill. Consult it during Phase 3 scan and Phase 4 triage.

---

## 1. Required inputs before coding (MUST)

Confirm or infer with evidence:

- target TYPO3 version.
- active branch/worktree context.
- extension scope (single extension or explicit set).
- acceptance criteria source (ticket and/or project docs).

If one of these is missing and blocks correctness, ask once and continue with all non-blocked work.

---

## 2. Execution order (MUST)

Follows `Batch.md` §1 phase template. TYPO3 upgrade phase mapping:

| Batch.md phase                  | TYPO3 upgrade step                      |
|---------------------------------|-----------------------------------------|
| 0 — Toolset Gate                | §3 preflight (toolset checks)           |
| 1 — Preflight                   | §3 preflight (remaining checks)         |
| 2 — Scope, Inventory & Baseline | §4 inventory + functional baseline      |
| 3 — Scan / Analysis             | §5 deprecation/breaking scan            |
| 4 — Triage & Plan               | triage packet + implementation plan     |
| 5 — Implementation              | §6 implementation constraints           |
| 6 — Validation                  | §7 validation checklist                 |
| 7 — Documentation Sync          | §8 documentation sync                   |
| 8 — Commits                     | §9 commit strategy                      |
| 9 — Handover & Reporting        | §10 handover                            |

Within Phase 5, apply the shared pass model and pre-apply classifier/gates from `General.md` sections `5.8` and `5.8.0`.
Validation selection/depth for Phase 6 MUST follow `General.md` sections `5.2` and `5.8.3`.
When static-test or scanner workflows are used, chain them per `Batch.md` §6 — activate the `/typo3:scanner` or `/typo3:static-tests` skill at that point.
For grouped Pass 1/Pass 2 batches, validation may be concatenated when items share risk profile and impacted surfaces, but coverage mapping per item/topic MUST be explicit in reporting.

---

## 3. Preflight checklist (MUST)

- apply `Batch.md` §2 toolset gate; TYPO3-specific checks:
  - step 1 (project type): verify `composer.json` references `typo3/cms-core` or equivalent.
  - step 3 (required commands): verify `ddev typo3 list` is callable.
- check git branch and local status.
- verify extension is active (if runtime checks are required).
- verify composer constraints relevant to extension and TYPO3 core.

---

## 4. Inventory checklist (MUST)

Provides the TYPO3-specific content of `Batch.md` Phase 2. After inventory, apply
`Batch.md` §3.2 to verify and document the functional baseline for all identified
entry points before proceeding to Phase 3.

Identify and document:

- entry points (frontend routes, controllers, middleware, CLI commands, scheduler tasks).
- storage/schema touchpoints (`ext_tables.sql`, TCA, repositories, query code).
- integration/dependency touchpoints (other in-house extensions consuming this extension).
- project-level migration docs and extension README migration notes.

---

## 5. Deprecation/breaking scan checklist (MUST)

Consult `references/changelog.md` for the full v10–v14 deprecation/breaking-change index.

At minimum, scan for TYPO3 upgrade hotspots:

- Extbase request/response legacy mutation APIs.
- runtime superglobal usage in executable code (`$_SERVER`, `$_GET`, `$_POST`, `$_REQUEST`, `$GLOBALS['TYPO3_REQUEST']`) and safe PSR-7/Extbase replacements.
- deprecated plugin registration and list_type patterns.
- deprecated global/request/environment utility calls.
- deprecated DBAL methods and typed API changes.
- deprecated service resolution via legacy Service API (for example `makeInstanceService()` fallback chains).
- legacy service framework usage (keep wrappers only when required by dependents).

Map each finding to one of:

- blocking (must fix now),
- safe migration path available (should fix now),
- unknown/needs decision (backlog with rationale).

For superglobal findings, the upgrade result MUST explicitly state:

- replaced (safe replacement path applied), or
- retained (no safe replacement in context, with short rationale).

---

## 6. Implementation constraints (MUST)

- preserve behavior unless acceptance criteria explicitly request behavior change.
- prefer least-invasive change.
- keep public extension contracts stable unless explicitly approved.
- when replacing removed APIs, follow official migration path, not ad-hoc rewrites.

---

## 7. Validation checklist (MUST)

Always provide evidence for executed validation paths, following `General.md` section `5.2 Test Path Selection & Execution`.

Behavioral validation policy is inherited from `General.md` sections `5.2` and `5.8.3` (including: static outputs are compliance-only and cannot be sole regression proof).

Always include, where touched:

- syntax/lint for changed PHP files.
- CLI command execution paths touched by the change.
- endpoint-level checks for changed frontend/backend surfaces.
- upgrade wizard and schema actions where applicable.

If any validation cannot run, state exactly why and what to run later.

## 7.1 Configuration Option Coverage (MUST)

For extension upgrades or migration tasks that can be affected by runtime configuration, the agent MUST add option-level verification on top of the baseline in `General.md` section `5.2`.

Applicable option sources include:

- TypoScript setup/constants and plugin settings
- extension configuration (`ext_conf_template.txt` / Extension Configuration)
- plugin/content-element configuration (FlexForm/TCA/content element fields)
- route/site/plugin switches that alter rendering or behavior

Required procedure:

1. identify options that can change behavior (output, layout, data handling, caching, request flow, feature toggles).
2. classify each option by impact:
   - high: can alter runtime behavior or user-visible output substantially
   - medium: localized output/behavior impact
   - low: cosmetic or operational-only impact with minimal functional risk
3. define a minimal but meaningful option matrix per extension:
   - include all high-impact options
   - include representative values for medium-impact options
   - defer low-impact options with rationale if not covered in current cycle
4. execute checks for selected matrix entries on suitable surfaces (FE/BE/API/CLI as applicable).
5. document executed coverage and residual backlog in a persistent artifact (for example `docs/testing/extension-option-test-matrix.md`).

If option semantics are unclear, ask once before finalizing.

---

## 7.2 Baseline + Final Comparison (MUST)

The functional baseline is established in Phase 2 per `Batch.md` §3.2. For larger
upgrade batches (multi-extension or multi-topic), per-extension baseline documentation
MUST exist before Phase 5; create or update it during Phase 2 if missing.

At Phase 6, run the full suite again and compare results against the Phase 2 baseline.

---

## 8. Documentation sync (MUST)

When upgrade-related changes are applied:

- update the relevant `UPDATE*.md` (version-specific, for example `UPDATE13.md`) with one-time migration steps.
- update extension README migration section if public/operator relevant.
- include verification commands and expected outcomes when possible.

---

## 9. Commit strategy (MUST)

Use scoped commits, grouped by concern:

- API/runtime fix,
- migration/wizard/schema step,
- docs/update instructions,
- optional cleanup.

Complex refactors must include explanatory commit body (`Why`, `What`, `How to test`, `Notes`).

---

## 10. Handover template (MUST)

Follow `Batch.md` §8.2 final cycle report template.
