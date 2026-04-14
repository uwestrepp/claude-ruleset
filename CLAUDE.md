# Project rule-set
* `CLAUDE.md` is the authoritative rule index and rule-maintenance ledger. Keep entries concise and index-like.
* Reusable agent behavior belongs in `./rules/`. Record only project-wide rule-authoring caveats here when no single rule file is the right source of truth.
* Rule authoring note: keep rule-file frontmatter minimal and IDE-compatible. Use `apply` and, when needed, a short `instructions` field; avoid additional custom frontmatter keys because PhpStorm's `AiRulesEditor` may duplicate headers.
* Follow the rules as defined in this explicit rule index:
  * @rules/Meta.md `[CRITICAL]`
    * Description: Always-on meta-rules for knowledge persistence, durable agent memory, and visibly labeled rule-set governance/self-improvement checkpoints.
    * When to use: Always; re-read on every context revalidation event (General.md §3.4).
  * @rules/General.md `[CRITICAL]`
    * Description: Global baseline behavior (assumptions, validation discipline, safety, environment-aware command routing for host/container execution, larger-scale baseline testing requirement, upstream contract verification for call-site/signature changes, shared Batch-Safe/Batch-Provable/Manual execution model, deterministic commit-ticket traceability).
    * When to use: Always; re-read on every context revalidation event (General.md §3.4).
  * @rules/CleanCode.md
    * Description: Clean-code operational rules for generated code and legacy-review suggestions.
    * When to use: Always for code generation/review; ask before auto-refactoring legacy code.
  * rules/Commits.md
    * Description: Commit message format and pre-commit checklist, including extension-ticket map resolution.
    * When to use: Whenever creating, amending, or rewriting commits/messages.
  * rules/PER.md
    * Description: Normative PER/PSR coding-style rules for PHP.
    * When to use: Creating/editing/reviewing PHP code.
  * rules/PER-Application.md
    * Description: Practical application policy for PER in this project (generation vs legacy mode).
    * When to use: Creating/reviewing PHP code or enforcing PER/PER-CS conventions.
  * rules/Batch.md
    * Description: Shared execution phase template (including mandatory functional baseline in Phase 2), toolset gate protocol, autonomous mode activation protocol, strict sequential workflow chaining model, optional agent delegation for test execution and checkpoints, and per-pass and final reporting/handover template for larger-scale or multi-file operations.
    * When to use: Any larger-scale, multi-file, multi-step batch, scanner, migration, static-test cycle, or automation-assisted change workflow. Foundation for all TYPO3-* workflow files.
* **TYPO3 projects** — the following rules apply when working on TYPO3-based projects:
  * rules/TYPO3.md
    * Description: TYPO3-specific operating policy, upgrade impact behavior, and skill invocation gate (§9) — includes the registry of TYPO3 workflow skills and their trigger patterns.
    * When to use: TYPO3 project tasks (core/extensions/Extbase/TypoScript/Fluid/migrations).
* **TYPO3 workflow skills** — explicit activation required; see `TYPO3.md` §9 for trigger patterns:
  * `/typo3-workflows:typo3-upgrade` (`~/.claude/plugins/marketplaces/local/plugins/typo3-workflows/skills/typo3-upgrade/`)
    * Description: TYPO3 Upgrade Workflow — full execution + DoD: phase template, preflight, inventory, deprecation/breaking scan (v10–v14 changelog in `references/`), implementation constraints, validation checklist, documentation sync, commit strategy.
    * Activate with: `/typo3-workflows:typo3-upgrade` before any TYPO3 upgrade/migration execution task.
  * `/typo3-workflows:typo3-scanner` (`~/.claude/plugins/marketplaces/local/plugins/typo3-workflows/skills/typo3-scanner/`)
    * Description: TYPO3 ExtensionScanner Workflow — command standard, pass model (triage/false-positives/safe replacements/high-risk migrations), false-positive handling, verification gates, reporting.
    * Activate with: `/typo3-workflows:typo3-scanner` before any ExtensionScanner triage or scanner-driven migration.
  * `/typo3-workflows:typo3-static-tests` (`~/.claude/plugins/marketplaces/local/plugins/typo3-workflows/skills/typo3-static-tests/`)
    * Description: TYPO3 Static Code Test Workflow — toolchain prep, ordered execution (php-cs-fixer → rector1 → rector2 → fractor → typoscriptlint → phpstan), triage model, false-positive ledger, logging, re-run/validation gates.
    * Activate with: `/typo3-workflows:typo3-static-tests` before any static analyzer/fixer cycle.
  * `/typo3-workflows:typo3-upgrade-full` (`~/.claude/plugins/marketplaces/local/plugins/typo3-workflows/skills/typo3-upgrade-full/`)
    * Description: TYPO3 Full Upgrade Chain — orchestration skill that chains all three workflows consecutively (upgrade → scanner → static-tests) per Batch.md §6. Activate alongside the three component skills.
    * Activate with: `/typo3-workflows:typo3-upgrade-full` + `/typo3-workflows:typo3-upgrade` + `/typo3-workflows:typo3-scanner` + `/typo3-workflows:typo3-static-tests` for a full chained session.
* Global MCP servers are configured in `~/.claude.json` under the `mcpServers` key (canonical location).
  * If MCP resources/templates are empty, treat this as a non-blocking beta behavior.
  * Verify MCP availability with one lightweight tool call (instead of relying only on list_mcp_resources/list_mcp_resource_templates).
  * If a tool is not working, try to find a fix or workaround. Otherwise report the issue.

## Atlassian Rovo MCP
When connected to atlassian mcp:
- **MUST** ask for project-specific Jira project key, and persist it in the project's CLAUDE.md if not already present
- **MUST** ask for project-specific Confluence spaceId, and persist it in the project's CLAUDE.md if not already present
- **MUST** use cloudId = "https://mosaiq.atlassian.net" (do NOT call getAccessibleAtlassianResources)
- **MUST** use `maxResults: 10` or `limit: 10` for ALL Jira JQL and Confluence CQL search operations.
- **MUST** paginate JQL/CQL queries until the end of result set (or until user asks for a sample only).
