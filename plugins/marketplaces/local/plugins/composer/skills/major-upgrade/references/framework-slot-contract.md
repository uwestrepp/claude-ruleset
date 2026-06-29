# Framework slot contract

A **slot fill** is the framework-specific knowledge the `/composer:major-upgrade` spine needs to turn
its generic phase model into a concrete, executable upgrade for one ecosystem. The spine is
framework-agnostic; all framework knowledge enters through these slots — supplied by a framework
**specialization** skill (e.g. `/typo3:upgrade`), or, when none exists, by best-effort discovery
during the run.

A specialization conforms to this contract by filling every slot (or marking it `n/a` with a
reason). It is the analogue of the collision-vector catalog contract used by `/composer:update`.

## Required slots

| Slot | Must supply | TYPO3 instance (`/typo3:upgrade`) |
|------|-------------|-----------------------------------|
| `framework-detect` | composer package signature that identifies the framework, and how to read the installed major version | `typo3/cms-core` in `composer.lock`; `ddev typo3 --version` |
| `runtime-matrix` | supported PHP / DB / platform range for the target major (drives the Phase 7 coupled/decoupled decision) | e.g. 13.4: PHP 8.2–8.4, MariaDB 10.4.3–11.4 / MySQL 8.0+ |
| `changelog-source` | where the framework publishes its deprecation/breaking index, and how to scope it to the BASE→TARGET range | the v10–v14 index bundled in `/typo3:upgrade`'s own `references/changelog.md` (resolved by the specialization, not by a cross-plugin path); docs.typo3.org Changelog |
| `deprecation-hotspots` | the concrete API/config patterns that break across majors, plus the scanner/tooling that finds them | `/typo3:upgrade` §3 (Extbase req/resp, superglobals, DBAL, plugin/list_type, service resolution); ExtensionScanner |
| `remediation-toolchain` | the framework's remediation skills/tools applied in Phase 5c | `/typo3:upgrade-full` = `/typo3:scanner` + `/typo3:static-tests` (rector/fractor TYPO3 rulesets) |
| `schema-wizard-commands` | schema-migration + upgrade-wizard CLI, and how destructive cleanup is staged/gated | `ddev typo3 database:updateschema`, `ddev typo3 upgrade:run`; two-stage prefix-then-drop |
| `config-sources` | configuration layers to cover in Phase 6 option-level validation | TypoScript setup/constants, ext_conf_template, FlexForm/TCA, site/plugin switches (`/typo3:upgrade` §4.1) |
| `doc-location` | the migration-doc / version-doc convention for the rollout runbook and one-time steps | `UPDATE*.md` (e.g. `UPDATE13.md`) + extension README migration section (`/typo3:upgrade` §5) |

## What a slot fill is NOT

- **Not** a re-implementation of the spine. Phases, the Pass model, and the escalation gate live in
  the skill and `Batch.md`; a specialization fills slots, it does not re-order or weaken phases.
- **Not** version mechanics. Resolution order, lock discipline, `-W` semantics belong to
  `/composer:knowledge`; reference, don't restate.
- **Not** the collision machinery. The dry-run delta and collision scan come from `/composer:update`
  and its ecosystem catalogs; a major-upgrade specialization reuses them, it does not fork them.

## Discovery fallback (no specialization)

When no specialization exists for the detected ecosystem, the spine fills slots best-effort from the
framework's published upgrade guide and the project itself, and MUST state reduced confidence per the
skill's slot-contract reporting (§1). Authoring a specialization (or extending the shared catalog)
from what a run discovers is the self-extension path, analogous to `/composer:update` §5.
