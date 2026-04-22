# Project rule-set
* `CLAUDE.md` is the authoritative rule index and rule-maintenance ledger. Keep entries concise and index-like.
* Reusable agent behavior belongs in `./rules/`. Record only project-wide rule-authoring caveats here when no single rule file is the right source of truth.
* Rule authoring note: keep rule-file frontmatter minimal. Use `apply:` and optional `instructions:` for IDE compatibility (PhpStorm AiRulesEditor). Claude Code's native rule-gating uses `paths:` — add it to rule files that should only load when matching file paths are in scope (see https://code.claude.com/docs/en/memory#path-specific-rules). Workflow-scoped content should live in skills, not rules, so it only loads when Claude detects prompt relevance.
* Follow the rules as defined in this explicit rule index:
  * @rules/Meta.md `[CRITICAL]`
    * Description: Always-on meta-rules for knowledge persistence, durable agent memory, and visibly labeled rule-set governance/self-improvement checkpoints.
    * When to use: Always; re-read on every context revalidation event (General.md §3.4).
  * @rules/General.md `[CRITICAL]`
    * Description: Global baseline behavior (assumptions, validation discipline, safety, environment-aware command routing, upstream contract verification, ticket traceability for commits, output-language policy for colleague-facing surfaces, skill invocation gate, sub-agent delegation policy).
    * When to use: Always; re-read on every context revalidation event (General.md §3.4).
  * @rules/CleanCode.md
    * Description: Project-specific clean-code opinions not already enforced by model defaults (searchable names / magic-number constants, flag-argument avoidance, command–query separation, no public mutable state, error-handling style, comment policy). Operating-mode split between code generation and legacy review.
    * When to use: Always for code generation/review; ask before auto-refactoring legacy code.
  * rules/PER.md (path-gated: `**/*.php`)
    * Description: Normative PER/PSR coding-style rules for PHP.
    * When to use: Creating/editing/reviewing PHP code.
  * rules/PER-Application.md (path-gated: `**/*.php`)
    * Description: Practical application policy for PER in this project (generation vs legacy mode).
    * When to use: Creating/reviewing PHP code or enforcing PER/PER-CS conventions.
* **Exports** — `./exports/` holds condensed or adapted versions of this repo's rule-set for use in external agents or harnesses. Files under `./exports/` are NOT loaded by this harness. When editing files under `./rules/`, check `./exports/` for any condensed version that needs corresponding sync in the same change-set. See `./exports/README.md`.
* **Core workflow skills** — auto-activate on prompt relevance, or invoke explicitly:
  * `/core:batch` (`~/.claude/plugins/marketplaces/local/plugins/core/skills/batch/`)
    * Description: Shared execution phase template (toolset gate, preflight, scope/inventory/baseline, scan, triage, implementation, validation, documentation, commits, handover), risk-sequenced Pass 1/2/3 model with triage/compliance gates, reviewability and PR-split thresholds, autonomous execution activation protocol, workflow chaining model, final reporting template. Foundation for all domain-specific workflow skills (TYPO3 upgrade/scanner/static-tests layer on this).
    * Activate with: `/core:batch` or let Claude auto-activate on batch-workflow relevance (refactor across N call sites, multi-package migration, scanner/analyzer-driven change batches, scope expansion from small task, autonomous execution requests).
  * `/core:commits` (`~/.claude/plugins/marketplaces/local/plugins/core/skills/commits/`)
    * Description: Commit message schema (`[TYPE] JIRA (scope) summary`), body decision gate, Jira ticket traceability rules (extension-ticket map, branch override, multi-extension split), pre-commit validation checklist, nested-repo handling.
    * Activate with: `/core:commits` or let Claude auto-activate when creating, amending, or rewriting commits.
  * `/core:composer` (`~/.claude/plugins/marketplaces/local/plugins/core/skills/composer/`)
    * Description: Composer version resolution order, tag-driven release flow for private/custom registries, dev-override patterns (narrow registry `exclude` + local path repo, consumer-side dev-constraint), canonical-priority trap and diagnostic order, lock-file discipline.
    * Activate with: `/core:composer` or let Claude auto-activate when editing composer.json/composer.lock, running composer/ddev composer commands, or debugging dependency resolution.
  * `/core:githooks-install` (`~/.claude/plugins/marketplaces/local/plugins/core/skills/githooks-install/`)
    * Description: Installs the reusable native git-hook scaffold (template under `plugins/core/resources/githooks-template/`) into a project — commit-subject format + ticket traceability (branch-name default; optional extension-ticket-map module; optional protected-branch pre-push guard). Handles fresh install and `--update` re-run; records outcome in `.aiassistant/state/githooks-install.yaml` (opt-out marker is respected).
    * Activate with: `/core:githooks-install` or let `/core:commits` auto-suggest when the current project has neither `.githooks/` nor `core.hooksPath` set.
* **TYPO3 projects** — the following rules apply when working on TYPO3-based projects:
  * rules/TYPO3.md (path-gated: `**/packages/**`, `**/ext_{localconf,tables,emconf}.php`, `**/typo3conf/**`, `**/config/sites/**`, `**/*.typoscript`, `**/*.tsconfig`)
    * Description: TYPO3-specific operating policy, upgrade impact behavior, skill invocation gate (§9 — TYPO3 workflow skill registry and triggers). Composer and commit rules are covered by the `/core:*` skills.
    * When to use: TYPO3 project tasks (core/extensions/Extbase/TypoScript/Fluid/migrations).
* **TYPO3 workflow skills** — explicit activation required; see `TYPO3.md` §9 for trigger patterns:
  * `/typo3:upgrade` (`~/.claude/plugins/marketplaces/local/plugins/typo3/skills/upgrade/`)
    * Description: TYPO3 Upgrade Workflow — full execution + DoD: phase template, preflight, inventory, deprecation/breaking scan (v10–v14 changelog in `references/`), implementation constraints, validation checklist, documentation sync, commit strategy.
    * Activate with: `/typo3:upgrade` before any TYPO3 upgrade/migration execution task.
  * `/typo3:scanner` (`~/.claude/plugins/marketplaces/local/plugins/typo3/skills/scanner/`)
    * Description: TYPO3 ExtensionScanner Workflow — command standard, pass model (triage/false-positives/safe replacements/high-risk migrations), false-positive handling, verification gates, reporting.
    * Activate with: `/typo3:scanner` before any ExtensionScanner triage or scanner-driven migration.
  * `/typo3:static-tests` (`~/.claude/plugins/marketplaces/local/plugins/typo3/skills/static-tests/`)
    * Description: TYPO3 Static Code Test Workflow — toolchain prep, ordered execution (php-cs-fixer → rector1 → rector2 → fractor → typoscriptlint → phpstan), triage model, false-positive ledger, logging, re-run/validation gates.
    * Activate with: `/typo3:static-tests` before any static analyzer/fixer cycle.
  * `/typo3:upgrade-full` (`~/.claude/plugins/marketplaces/local/plugins/typo3/skills/upgrade-full/`)
    * Description: TYPO3 Full Upgrade Chain — orchestration skill that invokes `/typo3:upgrade`, `/typo3:scanner`, and `/typo3:static-tests` in sequence via the Skill tool. Single invocation drives the full chain. Applies the `/core:batch` skill §6 chaining model with one combined toolset gate, one preflight, one chain-level autonomous-mode gate, and one final Phase 9 handover.
    * Activate with: `/typo3:upgrade-full` (orchestrates the three component skills automatically — do NOT pre-activate them manually).
* Global MCP servers are configured in `~/.claude.json` under the `mcpServers` key (canonical location).
  * If MCP resources/templates are empty, treat this as a non-blocking beta behavior.
  * Verify MCP availability with one lightweight tool call (instead of relying only on list_mcp_resources/list_mcp_resource_templates).
  * If a tool is not working, try to find a fix or workaround. Otherwise report the issue.

## Local overrides
- If `CLAUDE.local.md` exists, read and apply it after this file as a local override.
- `CLAUDE.local.md` is intended for machine-local or private settings and should remain gitignored.

## Atlassian Rovo MCP
When connected to atlassian mcp:
- **MUST** ask for project-specific Jira project key, and persist it in the project's CLAUDE.md if not already present
- **MUST** ask for project-specific Confluence spaceId, and persist it in the project's CLAUDE.md if not already present
- **MUST** use cloudId = "https://mosaiq.atlassian.net" (do NOT call getAccessibleAtlassianResources)
- **MUST** use `maxResults: 10` or `limit: 10` for ALL Jira JQL and Confluence CQL search operations.
- **MUST** paginate JQL/CQL queries until the end of result set (or until user asks for a sample only).
