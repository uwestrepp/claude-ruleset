---
name: scanner
description: "Activate with /typo3:scanner before starting any TYPO3 ExtensionScanner triage, scanner-driven migration, or scanner pass within an upgrade workflow. Required before structured ExtensionScanner work begins."
argument-hint: [extKey...]
allowed-tools: [Read, Edit, Write, Glob, Grep, Bash]
---

# TYPO3 ExtensionScanner Workflow

This skill defines how to execute and process TYPO3 ExtensionScanner results.

It complements:
- `Batch.md` (execution phases, toolset gate, autonomous mode, chaining, reporting)
- `General.md` (test-path selection and execution)
- `TYPO3.md` (TYPO3 migration policy)
- `/typo3:upgrade` skill (upgrade execution order; activate separately when chaining)

Non-skippable triage/compliance gates are defined centrally in `Batch.md` §9.1 and are mandatory for this workflow.

---

## 0. Toolset Availability Gate (MUST)

Apply `Batch.md` §2 general toolset gate. TYPO3 ExtensionScanner-specific checks:
- step 1 (project type): confirm `composer.json` references `typo3/cms-core` or equivalent.
- step 3 (required commands): confirm `ddev typo3-extensionscanner` exists and is callable. If it does not, this is NOT a blocking tooling gap — the skill ships the runner; install it per §1.1 before proceeding.

If any other check fails: report which tooling is missing, do not continue the workflow, and ask the user how to proceed.

---

## 1. Command Standard (MUST)

Use the project command wrapper:

- Summary mode:
  - `ddev typo3-extensionscanner summary <extKey...>`
  - or `ddev typo3-extensionscanner --summary <extKey...>`
- JSON detail mode:
  - `ddev typo3-extensionscanner json <extKey...>`
  - or `ddev typo3-extensionscanner --json <extKey...>`

If extension scope is not explicitly given, ask once before scanning all extensions.

### 1.1 Runner Bootstrap — install if missing (MUST)

The skill SHIPS the canonical runner as `resources/typo3-extension-scanner`. The agent MUST NOT port it from another project or recreate it by hand — the bundled copy is the single canonical source.

If `ddev typo3-extensionscanner` is not callable and no project copy exists at `.aiassistant/scripts/typo3-extension-scanner`, install it from this skill's bundled resources before scanning:

1. copy this skill's `resources/typo3-extension-scanner` to the project's `.aiassistant/scripts/typo3-extension-scanner`,
2. create the DDEV wrapper `.ddev/commands/web/typo3-extensionscanner` (stub in `resources/README.md`),
3. verify it is callable (e.g. `ddev typo3-extensionscanner --summary <one extKey>`), then proceed.

This writes committable files into the project repo (the copy is meant to be shared with team/CI per `resources/README.md`) — confirm with the user before installing, and surface the new files at the next commit. If a project copy already exists, prefer it (it MAY carry project-specific tweaks per the README drift policy); do not overwrite it from resources without confirmation.

---

## 2. Pass Model (MUST)

Use `Batch.md` §9 Risk-Sequenced Change Execution as the canonical pass/gate model.
Pre-apply behavior-risk classification and non-skippable pre-edit triage/compliance gates MUST follow `Batch.md` §9.1.

Validation selection/depth MUST use `General.md` section `5.2` and `Batch.md` §9.4 (identical to upgrade/static workflows).
For grouped Pass 1/Pass 2 batches, validation may be concatenated when items share risk profile and impacted surfaces, but coverage mapping per topic MUST be explicit.

If work is large, group by identical issue topic across extensions rather than finishing one extension at a time.

Scanner specialization:
- Pass 1 focuses on triage and obvious false positives.
- Pass 2 focuses on safe replacement paths with proven behavior stability.
- Pass 3 handles migrations with likely runtime/content-impact.

---

## 3. Pass 1 Rules (MUST)

Pass 1 goals:
- collect and classify findings by topic (`strong`/`weak`)
- identify obvious false positives
- apply line-level ignore annotations only for confirmed false positives

Pass 1 MUST NOT:
- apply behavior-changing migrations
- use file-level ignore annotations unless explicitly approved

---

## 4. Pass 2 Rules (MUST)

Pass 2 goals:
- resolve findings with safe replacement paths
- keep behavior stable
- apply consistent replacements across all affected extensions in scope

Typical Pass 2 candidates:
- direct API replacements with no data-model change
- mechanical signature/constant updates where runtime behavior is preserved
- safe TYPO3 core API substitutions validated by changelog/migration docs

For signature/call-site affecting updates (for example removed parameters or reordered arguments), the agent MUST apply `General.md` section `4.5 Upstream Contract Verification` per occurrence before applying.

If a finding requires schema/content migration or can alter FE/BE behavior, defer to Pass 3.

Pass 2 grouped application MUST follow deterministic proof requirements from `Batch.md` §9.2.

---

## 5. Pass 3 Rules (MUST)

Pass 3 handles higher-risk migrations (for example `list_type` -> `CType`, content migration, routing implications).

For Pass 3:
- describe behavior impact before change
- implement compatibility layer when needed for transitional runtime safety
- provide/execute required migration wizards
- verify both pre-migration compatibility and post-migration state

If risk is unclear, ask before finalizing.

## 5.1 Medium/High Approval Gate (MUST)

Pass 3 one-by-one approval loop MUST follow `Batch.md` §9.3.
Scanner-specific minimum packet field:
- scanner/rule topic identifier MUST be included as the rule/finding id.

---

## 6. False Positive Handling (MUST)

A finding is a confirmed false positive only if at least one applies:
- scanner matches a technically valid API for current target TYPO3 version
- match is in non-runtime context (for example inert string)
- scanner matcher limitation is known and replacement would be incorrect

When ignoring:
- use `@extensionScannerIgnoreLine` only
- include concise rationale on the same comment line
- keep ignore scoped to the specific statement

Example:
- `// @extensionScannerIgnoreLine false positive: FrontendUserAuthentication::storeSessionData() is valid TYPO3 API.`

`@extensionScannerIgnoreFile` is disallowed by default.
Use only with explicit user approval.

---

## 7. Verification After Each Pass (MUST)

After each pass:
- rerun scanner summary for scoped extensions (finding status only; not behavior proof)
- run suitable runtime/test paths per `General.md` section `5.2` (risk-based depth is authoritative there)
- apply validation depth by pass from `Batch.md` §9.4
- report:
  - what was executed
  - findings reduced/resolved
  - residual backlog for next pass

Static analyzer/scanner output is finding/compliance evidence and MUST NOT replace runtime/behavioral validation (`General.md` section `5.2`).

If a required validation path cannot be run, state blocker and exact follow-up command/manual step.

---

## 7.1 Option-Matrix Regression Check (MUST for Pass 2/3)

When Pass 2 or Pass 3 changes touch extension runtime behavior, the agent MUST run/update configuration-option coverage per the `/typo3:upgrade` skill §4.1 for affected extensions.

Minimum requirement:
- execute at least one high-impact option path per touched extension (if defined),
- document executed paths and residual uncovered options for follow-up.

---

## 8. Reporting Format (SHOULD)

Follow `Batch.md` §8 reporting template. Scanner-specific scope field: include `extKey` list and remaining findings by severity.

---

## 9. Cleanup Policy (SHOULD)

When all findings are resolved:
- keep ignore lines only where still justified
- remove temporary compatibility layers once migration is complete and validated
- keep migration wizards and notes if they are required for deploy/update execution
