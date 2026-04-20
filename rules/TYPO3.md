---
apply: by model decision
instructions: Apply only for TYPO3 projects/tasks (TYPO3 core/extensions, Extbase, TypoScript, Fluid, upgrade or migration work).
paths:
  - "**/packages/**"
  - "**/ext_{localconf,tables,emconf}.php"
  - "**/typo3conf/**"
  - "**/config/sites/**"
  - "**/*.typoscript"
  - "**/*.tsconfig"
---

# TYPO3 Upgrade Impact Policy for Coding Agent
Applies when working on TYPO3 projects, extensions, or migrations.

This policy describes general TYPO3 operating behavior. Structured execution workflows are
provided as explicit skills — see §9 for the skill registry and invocation gate.

---

## 1. Operating modes

### 1.1 Code generation mode (MUST)
When generating new code for a TYPO3 project, the agent MUST:

1. Determine the target TYPO3 major/minor version (and PHP version).
2. Avoid deprecated APIs/features for that TYPO3 version line.
3. Avoid patterns that are known breaking changes in the target line.
4. Prefer current APIs documented for the target TYPO3 version.

If the target TYPO3 version is unknown, the agent MUST ask before implementing anything non-trivial.

---

### 1.2 Legacy code review mode (MUST)
When reviewing existing TYPO3 code, the agent MUST:

- Identify usage of APIs listed as *deprecated* or *breaking* for the project’s current/target TYPO3 version.
- Propose a refactoring or migration path.
- **MUST NOT** apply large migrations automatically.
- Only apply changes after explicit confirmation.

---

### 1.3 Autonomous upgrade execution mode (MUST)

For batch workflow tasks, determine the appropriate workflow skill according to §9. If the correct skill is not clear from the task description, ask the user before proceeding. Present the selected skill to the user and wait for explicit confirmation before activating it. Do NOT proceed with any skill activation until the user has explicitly confirmed. The autonomous execution protocol is defined in the `/core-workflows:batch` skill §5 and the activated skill.

The agent MUST still pause and ask if:

- scope is ambiguous in a way that may change business behavior.
- the required action is destructive or not safely reversible.
- credentials, infrastructure state, or external systems are missing/unclear.
- an issue is outside approved extension scope.

---

## 2. Version & constraint verification (MUST)

Before proposing changes, the agent MUST verify:

- TYPO3 core version (exact major/minor, preferably patch line too).
- PHP version.
- Composer constraints for core and extensions (if Composer-based).
- Installation mode (Composer vs legacy) if relevant.

If any of these are unknown, the agent MUST ask.

---

## 2.1 Upgrade documentation synchronization (MUST)

If the task is an update/upgrade and project-level or extension-level update documentation exists
(for example `UPDATE*.md`, extension `README.md` migration sections, or similar),
the agent MUST review and update that documentation with relevant migration steps, follow-up commands,
and one-time upgrade actions introduced by the change.

If no documentation update is needed, the agent SHOULD state that explicitly.

---

## 3. Double-checking & scope control (MUST)

Before changing code, the agent MUST:

- Search for other usages of the modified code path (references, DI wiring, TSConfig/TypoScript, Fluid templates).
- Check if code is part of a public extension API (BC risk).
- Re-read the exact files to be modified right before applying changes.

---

## 4. Deprecations handling (MUST)

When encountering a deprecated item:

- Prefer the replacement API/pattern described in the changelog entry (or official manual for the target version).
- If the deprecation notice includes a migration guide/checklist, the agent MUST follow all required migration steps from that guide, not only the directly visible code replacement.
- If the replacement is not obvious from available context, the agent MUST:
    - locate the official documentation for the replacement, or
    - ask for clarification / project context.

The agent SHOULD propose a staged migration plan if deprecations are numerous:
1) eliminate deprecations in current major,
2) upgrade to next major,
3) repeat.

---

## 5. Breaking changes handling (MUST)

If an item is a breaking change for the target version:

- The agent MUST treat it as blocking: code MUST be adapted.
- The agent MUST describe:
    - what breaks,
    - where it is used in the project,
    - the minimal safe adaptation,
    - how to validate correctness.

---

## 6. Verification requirements (MUST)

For any applied TYPO3 change, the agent MUST follow `General.md` section `5.2 Test Path Selection & Execution`.

In TYPO3 context, suitable verification paths MUST be chosen and executed per touched surface, for example:
- frontend rendering/routes,
- backend module/controller actions,
- API endpoints,
- CLI/scheduler command paths,
- upgrade/schema/migration actions.

If verification scope is unclear, ask before finalizing.

If any required path cannot be executed, report the blocker and exact follow-up command/manual step.

For upgrade-related changes, the agent SHOULD recommend:
- running TYPO3 Upgrade Wizards (if applicable),
- checking system status reports,
- clearing caches appropriately.

---

## 6.1 Upgrade completion criteria (MUST)

The agent MUST treat an extension upgrade as complete only when all of the following are addressed:

- code adaption for identified blocking breaking changes in target TYPO3 version.
- code adaption for deprecations that have a known clean migration path.
- validation evidence (CLI/tests/manual steps) documented, including what could not be validated.
- update/migration documentation synchronized (`UPDATE*.md`, extension README migration notes, or equivalent).
- unresolved items captured explicitly as backlog with rationale and required follow-up.

---

## 7. Output format expectations (SHOULD)

When reporting findings, the agent SHOULD output:

- Current TYPO3/PHP versions (confirmed vs assumed).
- A per-version checklist of impacted items:
    - Deprecations to resolve
    - Breaking changes to handle
- Suggested order of work (staged upgrades)

---

## 8. Practical migration patterns for TYPO3 13.4 (SHOULD)

When a clean migration path exists, prefer these replacements:

- **Extbase request mutation**:
  - avoid legacy :php:`$this->request->setArgument(...)`
  - use immutable :php:`$this->request = $this->request->withArgument(...)`
- **Extbase response mutation**:
  - avoid mutable response APIs (`setHeader()`, `setStatus()`, `setContent()`, direct send/shutdown handling)
  - return PSR-7 responses and use :php:`withHeader()`, :php:`withStatus()` and body streams
  - use ActionController helpers :php:`htmlResponse()` / :php:`jsonResponse()` where possible
- **URL/env access in runtime code**:
  - avoid introducing new usages of :php:`GeneralUtility::getIndpEnv()` for request data
  - prefer the current PSR-7 request (`ServerRequestInterface`) and read values from :php:`$request->getUri()`, :php:`$request->getQueryParams()`, :php:`$request->getParsedBody()`
- **Runtime superglobals in TYPO3 code**:
  - avoid introducing or keeping runtime reads from :php:`$_SERVER`, :php:`$_GET`, :php:`$_POST`, :php:`$_REQUEST`, or :php:`$GLOBALS['TYPO3_REQUEST']` when a request object is available
  - in Extbase controllers, prefer :php:`$this->request->getHeaderLine()`, :php:`$this->request->getQueryParams()`, and argument APIs (`hasArgument()/getArgument()`) as appropriate
  - keep :php:`$GLOBALS` usage only where TYPO3 bootstrap/config APIs require it (for example `TCA`, `TYPO3_CONF_VARS`) and document retained usages in upgrade notes
- **Legacy service framework**:
  - keeping compatibility wrappers for :php:`AbstractService` / Service API usage is acceptable if required by dependent extensions
  - still migrate deprecated/removed core calls inside those wrappers
- **Service instantiation in upgrade scope**:
  - do not introduce or keep fallback patterns based on :php:`GeneralUtility::makeInstanceService()`
  - prefer constructor or container-based DI for controllers, services, and ViewHelpers where supported
- **`GeneralUtility::makeInstance()` typing in legacy-compatible code**:
  - keep or add inline :php:`@var` type hints directly above assignments from :php:`GeneralUtility::makeInstance(...)`
  - if correcting such annotations, ensure the annotated variable name matches the assigned variable exactly
  - when directly calling a method on a value returned from :php:`GeneralUtility::makeInstance(...)`, prefer :php:`?->` over :php:`->` unless non-nullability is already proven locally and the direct call form is required

---

## 9. TYPO3 Workflow Skills — Invocation Gate (MUST)

The following skills provide structured TYPO3 workflow execution. When a user request
matches a trigger pattern below and the corresponding skill has **not** been invoked in
the current session, the agent MUST interrupt, decline to proceed ad-hoc, show the exact
invocation command, and explain that the skill must be activated first.

| Skill | Invoke with | Trigger patterns |
|---|---|---|
| TYPO3 Upgrade Workflow | `/typo3-workflows:typo3-upgrade` | upgrade task, migration execution, deprecation/breaking-change remediation, version compatibility work, TYPO3 major/minor migration |
| TYPO3 ExtensionScanner | `/typo3-workflows:typo3-scanner` | ExtensionScanner run, scanner triage, scanner findings, scanner pass, scanner-driven migration |
| TYPO3 Static Code Tests | `/typo3-workflows:typo3-static-tests` | static test run, phpstan, rector, fractor, php-cs-fixer, TypoScript lint, static analyzer cycle, static code quality pass |
| TYPO3 Full Upgrade Chain | `/typo3-workflows:typo3-upgrade-full` | full upgrade chain, run all three workflows, consecutive upgrade + scanner + static tests, chained upgrade execution |

The agent MUST NOT begin workflow execution as if the skill were active when it has not
been invoked. This is the primary compliance gate replacing the former `apply: by model
decision` automatic triggering of the retired rule files.

**Skill ledger maintenance:** When a new TYPO3 workflow skill is created, its name,
invocation command, and trigger patterns MUST be added to the table above before the
skill is considered complete. For skills covering non-TYPO3 domains, the equivalent
ledger entry belongs in the most general applicable rule file for that domain; see
`General.md` §9 for the cross-domain skill registration requirement.

---

End of policy.
