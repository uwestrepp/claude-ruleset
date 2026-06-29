---
name: upgrade
description: "Activate with /typo3:upgrade before starting any TYPO3 upgrade, migration execution, or deprecation/breaking-change remediation task. The TYPO3 specialization of /composer:major-upgrade: it fills that generic spine's framework slots with TYPO3 values and supplies the TYPO3-specific preflight, inventory, deprecation/breaking scan, configuration-option coverage, and documentation steps. Required before any structured TYPO3 version upgrade work begins. NOT a patch/minor/security bump (use /composer:update)."
argument-hint: [scope]
allowed-tools: [Read, Edit, Write, Glob, Grep, Bash, Agent]
---

# TYPO3 Upgrade Workflow (specialization of /composer:major-upgrade)

The TYPO3 specialization of the generic Composer major-upgrade spine. The **phase model, Pass 1/2/3
model, escalation gate, branch/baseline + before/after discipline, runtime-decoupling decision, and
rollout-doc separation live in `/composer:major-upgrade`** — activate it or read it; they are binding
here and MUST NOT be restated or weakened (`General.md` §9.3). This skill supplies what is genuinely
TYPO3-specific: the slot fills below and the detail sections they point to.

The spine is a **faithful `Batch.md` §1 specialization**, so phases here are Batch phases 0–9 — the
same model `/typo3:upgrade-full`'s chain expects when it runs this skill's "phases 2–9". No separate
phase numbering is introduced.

Also complements `TYPO3.md` and `Batch.md` (execution phases, toolset gate, autonomous mode,
chaining, reporting). Non-skippable triage/compliance gates are defined centrally in `Batch.md` §9.1
and are mandatory for this workflow.

**Changelog reference:** the TYPO3 deprecation/breaking-change index (v10–v14) is in
`references/changelog.md`; preferred replacement patterns in `references/migration-patterns.md`.
Consult them during the spine's Phase 3 scan and Phase 4 triage.

---

## 1. Slot fills for /composer:major-upgrade (MUST)

Authoritative TYPO3 values for the spine's `references/framework-slot-contract.md`:

| Slot | TYPO3 fill |
|------|------------|
| `framework-detect` | `typo3/cms-core` in `composer.lock`; installed major via `ddev typo3 --version` |
| `runtime-matrix` | the target's supported PHP / DB range (verify against docs.typo3.org for the exact target, e.g. 13.4: PHP 8.2–8.4, MariaDB 10.4.3–11.4 / MySQL 8.0+) — drives the spine's coupled/decoupled runtime decision |
| `changelog-source` | `references/changelog.md` (v10–v14 index) + docs.typo3.org Changelog for the BASE→TARGET range |
| `deprecation-hotspots` | §3 below (scan checklist) + ExtensionScanner via `/typo3:scanner` |
| `remediation-toolchain` | `/typo3:upgrade-full` chain — `/typo3:scanner` + `/typo3:static-tests` (rector/fractor TYPO3 rulesets) — run in the spine's Phase 5c |
| `schema-wizard-commands` | `ddev typo3 database:updateschema`, `ddev typo3 upgrade:run`; destructive cleanup staged two-step (prefix/rename, then drop) in the spine's gated Phase 5d |
| `config-sources` | §5 below (TypoScript, Extension Configuration, FlexForm/TCA, site/plugin switches) |
| `doc-location` | `UPDATE*.md` (version-specific, e.g. `UPDATE13.md`) + extension README migration section (§6 below) |

When chaining scanner/static-tests, activate `/typo3:scanner` or `/typo3:static-tests` per `Batch.md`
§6 at the spine's Phase 5c. Within the spine's Phase 5, apply `Batch.md` §9 + §9.1 (pass model +
pre-apply gates); validation depth follows `General.md` §5.2 and `Batch.md` §9.4. Grouped Pass 1/2
validation may be concatenated when items share risk profile and surfaces, but per-item coverage MUST
be explicit in reporting.

---

## 2. TYPO3 preflight additions (MUST)

Augments the spine's Phase 0 toolset/env gate (`Batch.md` §2):

- step 1 (project type): verify `composer.json` references `typo3/cms-core` or equivalent.
- step 3 (required commands): verify `ddev typo3 list` is callable.
- check git branch and local status.
- record the confirmed comparison base branch in `.aiassistant/state/base-branch` if not yet present
  (activates the global base-branch guard hook for this project).
- verify the extension is active (if runtime checks are required).
- verify composer constraints relevant to the extension and to TYPO3 core.

## 2.1 TYPO3 inventory touchpoints (MUST)

The TYPO3-specific content of the spine's Phase 2 (Scope, Inventory & Baseline). Identify and document:

- entry points (frontend routes, controllers, middleware, CLI commands, scheduler tasks).
- storage/schema touchpoints (`ext_tables.sql`, TCA, repositories, query code).
- integration/dependency touchpoints (other in-house extensions consuming this extension).
- project-level migration docs and extension README migration notes.

---

## 3. Deprecation/breaking scan checklist (MUST)

Fills `deprecation-hotspots` for the spine's Phase 3. Consult `references/changelog.md` (v10–v14) and
`references/migration-patterns.md`. At minimum, scan for:

- Extbase request/response legacy mutation APIs.
- runtime superglobal usage in executable code (`$_SERVER`, `$_GET`, `$_POST`, `$_REQUEST`,
  `$GLOBALS['TYPO3_REQUEST']`) and safe PSR-7/Extbase replacements.
- deprecated plugin registration and list_type patterns.
- deprecated global/request/environment utility calls.
- deprecated DBAL methods and typed API changes.
- deprecated service resolution via legacy Service API (e.g. `makeInstanceService()` fallback chains).
- legacy service framework usage (keep wrappers only when required by dependents).

Map each finding to the spine's classification (blocking / safe path available / needs decision). For
superglobal findings, the result MUST explicitly state **replaced** (safe path applied) or
**retained** (no safe replacement in context, with short rationale).

---

## 4. Implementation & validation — TYPO3 notes (MUST)

Constraints, the staged Pass model, and the validation/before-after protocol are the spine's
(Phase 5 §8, Phase 6 §9). TYPO3-specific additions only:

- when replacing removed APIs, follow the **official TYPO3 migration path** (`migration-patterns.md`),
  not ad-hoc rewrites; keep public extension contracts stable unless approved.
- validation surfaces to include where touched: syntax/lint for changed PHP, CLI paths touched, FE/BE
  endpoint checks, and **upgrade wizard + schema actions** (`ddev typo3 upgrade:run` /
  `database:updateschema`) — the latter run in the spine's gated Phase 5d.

## 4.1 Configuration option coverage (MUST)

Fills `config-sources` for the spine's Phase 6 option coverage. Applicable TYPO3 option sources:

- TypoScript setup/constants and plugin settings,
- extension configuration (`ext_conf_template.txt` / Extension Configuration),
- plugin/content-element configuration (FlexForm / TCA / content-element fields),
- route/site/plugin switches that alter rendering or behavior.

Procedure: (1) identify options that can change behavior (output, layout, data handling, caching,
request flow, feature toggles); (2) classify each high / medium / low impact; (3) define a minimal but
meaningful matrix per extension (all high-impact, representative medium, deferred low with rationale);
(4) execute checks on suitable surfaces (FE/BE/API/CLI); (5) document executed coverage and residual
backlog in a persistent artifact (e.g. `docs/testing/extension-option-test-matrix.md`). If option
semantics are unclear, ask once before finalizing.

---

## 5. Documentation sync — TYPO3 conventions (MUST)

Fills `doc-location` for the spine's Phase 7 (Documentation Sync). When upgrade-related changes are applied:

- update the relevant `UPDATE*.md` (version-specific, e.g. `UPDATE13.md`) with one-time migration
  steps (the spine's separate rollout runbook).
- update the extension README migration section if public/operator relevant.
- include verification commands and expected outcomes when possible.

Commit strategy and handover follow `/core:commits` and the spine's Phase 8/9 — group commits by
concern (API/runtime fix, migration/wizard/schema, docs, cleanup); complex refactors carry an
explanatory body (`Why`, `What`, `How to test`, `Notes`).
