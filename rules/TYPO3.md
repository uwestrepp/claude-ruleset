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
provided as explicit skills — see the `CLAUDE.md` skill ledger (registry) and `General.md` §9 (invocation gate).

## 1. Operating modes

Operating-mode baseline (generation / legacy-review / uncertainty) is `General.md` §4.6. TYPO3-specific extensions:

### 1.1 Code generation mode (MUST)
When generating new code for a TYPO3 project, the agent MUST:

1. Determine the target TYPO3 major/minor version (and PHP version).
2. Avoid deprecated APIs/features for that TYPO3 version line.
3. Avoid patterns that are known breaking changes in the target line.
4. Prefer current APIs documented for the target TYPO3 version.

If the target TYPO3 version is unknown, the agent MUST ask before implementing anything non-trivial.

### 1.2 Legacy code review mode (MUST)
Per `General.md` §4.6 (propose, don't auto-modify, confirm first). TYPO3 specifics: identify usage of APIs listed as *deprecated* or *breaking* for the project’s current/target TYPO3 version, propose a refactoring or migration path, and MUST NOT apply large migrations automatically.

### 1.3 Autonomous upgrade execution mode (MUST)

For batch workflow tasks, determine the appropriate workflow skill from the `CLAUDE.md` skill ledger, observing the `General.md` §9 invocation gate. If the correct skill is not clear from the task description, ask the user before proceeding. Present the selected skill to the user and wait for explicit confirmation before activating it. Do NOT proceed with any skill activation until the user has explicitly confirmed. The autonomous execution protocol is defined in the `/core:batch` skill §5 and the activated skill.

The agent MUST still pause and ask if:

- scope is ambiguous in a way that may change business behavior.
- the required action is destructive or not safely reversible.
- credentials, infrastructure state, or external systems are missing/unclear.
- an issue is outside approved extension scope.

## 2. Version & constraint verification (MUST)

Per `General.md` §2.1 (verify versions/toolchain before changes). In TYPO3 terms, verify:

- TYPO3 core version (exact major/minor, preferably patch line too).
- PHP version.
- Composer constraints for core and extensions (if Composer-based).
- Installation mode (Composer vs legacy) if relevant.

If any of these are unknown, the agent MUST ask.

## 2.1 Upgrade documentation synchronization (MUST)

If the task is an update/upgrade and project-level or extension-level update documentation exists
(for example `UPDATE*.md`, extension `README.md` migration sections, or similar),
the agent MUST review and update that documentation with relevant migration steps, follow-up commands,
and one-time upgrade actions introduced by the change.

If no documentation update is needed, the agent SHOULD state that explicitly.

## 3. Double-checking & scope control (MUST)

Per `General.md` §3.1/§3.2 (surrounding-code and cross-file dependency awareness), §4.1 (re-read before modify), and §4.3 (preserve public contracts). TYPO3-specific search surfaces:

- other usages of the modified code path: references, DI wiring, TSConfig/TypoScript, Fluid templates,
- public extension API exposure (BC risk).

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

## 5. Breaking changes handling (MUST)

If an item is a breaking change for the target version:

- The agent MUST treat it as blocking: code MUST be adapted.
- The agent MUST describe:
    - what breaks,
    - where it is used in the project,
    - the minimal safe adaptation,
    - how to validate correctness.

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

## 6.1 Upgrade completion criteria (MUST)

The agent MUST treat an extension upgrade as complete only when all of the following are addressed:

- code adaption for identified blocking breaking changes in target TYPO3 version.
- code adaption for deprecations that have a known clean migration path.
- validation evidence (CLI/tests/manual steps) documented, including what could not be validated.
- update/migration documentation synchronized (`UPDATE*.md`, extension README migration notes, or equivalent).
- unresolved items captured explicitly as backlog with rationale and required follow-up.

## 7. Output format expectations (SHOULD)

When reporting findings, the agent SHOULD output:

- Current TYPO3/PHP versions (confirmed vs assumed).
- A per-version checklist of impacted items:
    - Deprecations to resolve
    - Breaking changes to handle
- Suggested order of work (staged upgrades)

## 8. Practical migration patterns (SHOULD)

Preferred replacement patterns for update/cleanup/migration work (Extbase request/response immutability, PSR-7 over superglobals/`getIndpEnv()`, DI over `makeInstanceService()`, `makeInstance()` typing, TypoScript `traverse()` conditions) live in the `/typo3:upgrade` skill at `references/migration-patterns.md`. Consult them during upgrade/migration phases; they are workflow content and intentionally not loaded with this policy file.

## 9. Composer version layering for extensions (MUST understand before version edits)

An extension's version can live in several layers; bumping only one is the classic source of stale or inconsistent releases. Composer-generic resolution and dev-override hygiene: `/core:composer` §1–§2. TYPO3 specifics:

- `extra."typo3/cms".extension-key` maps package name → extension key; it is NOT a version source.
- `ext_emconf.php` `version` counts only for legacy (non-Composer) installs and TER packaging. Composer-mode TYPO3 (v11.4+) treats composer.json as authoritative — bumping only `ext_emconf.php` there changes nothing Composer sees; v12+ extensions installed via Composer may omit the file.
- Releases are tagged (`/core:composer` §1.2; TER publishes via `tailor` from tags). When `ext_emconf.php` is present, align its `version` with the tag in the same release commit.

End of policy.
