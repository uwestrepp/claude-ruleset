# Project rule-set
* `CLAUDE.md` is the authoritative rule index and rule-maintenance ledger. Keep entries concise and index-like.
* Reusable agent behavior belongs in `./rules/`. Record only project-wide rule-authoring caveats here when no single rule file is the right source of truth.
* Rule authoring note: keep rule-file frontmatter minimal and IDE-compatible. Use `apply` and, when needed, a short `instructions` field; avoid additional custom frontmatter keys because PhpStorm's `AiRulesEditor` may duplicate headers.
* Follow the rules as defined in this explicit rule index (source files are in `./rules/`):
  * `Meta.md` `[CRITICAL]`
    * Description: Always-on meta-rules for knowledge persistence, durable agent memory, and visibly labeled rule-set governance/self-improvement checkpoints.
    * When to use: Always; re-read on every context revalidation event (General.md §3.4).
  * `General.md` `[CRITICAL]`
    * Description: Global baseline behavior (assumptions, validation discipline, safety, environment-aware command routing for host/container execution, larger-scale baseline testing requirement, upstream contract verification for call-site/signature changes, shared Batch-Safe/Batch-Provable/Manual execution model, deterministic commit-ticket traceability).
    * When to use: Always; re-read on every context revalidation event (General.md §3.4).
  * `CleanCode.md`
    * Description: Clean-code operational rules for generated code and legacy-review suggestions.
    * When to use: Always for code generation/review; ask before auto-refactoring legacy code.
  * `Commits.md`
    * Description: Commit message format and pre-commit checklist, including extension-ticket map resolution.
    * When to use: Whenever creating, amending, or rewriting commits/messages.
  * `PER.md`
    * Description: Normative PER/PSR coding-style rules for PHP.
    * When to use: Creating/editing/reviewing PHP code.
  * `PER-Application.md`
    * Description: Practical application policy for PER in this project (generation vs legacy mode).
    * When to use: Creating/reviewing PHP code or enforcing PER/PER-CS conventions.
  * `Batch.md`
    * Description: Shared execution phase template (including mandatory functional baseline in Phase 2), toolset gate protocol, autonomous mode activation protocol, strict sequential workflow chaining model, optional agent delegation for test execution and checkpoints, and per-pass and final reporting/handover template for larger-scale or multi-file operations.
    * When to use: Any larger-scale, multi-file, multi-step batch, scanner, migration, static-test cycle, or automation-assisted change workflow. Foundation for all TYPO3-* workflow files.
* **TYPO3 projects** — the following rules apply when working on TYPO3-based projects (all include a toolset availability gate):
  * `TYPO3.md`
    * Description: TYPO3-specific operating policy and upgrade impact behavior.
    * When to use: TYPO3 project tasks (core/extensions/Extbase/TypoScript/Fluid/migrations).
  * `TYPO3-Changelog.md`
    * Description: TYPO3 deprecation/breaking reference index across versions.
    * When to use: Deprecation analysis and migration impact checks.
  * `TYPO3-Upgrade-Workflow.md`
    * Description: Required execution order + DoD for TYPO3 upgrade tasks, including risk-sequenced execution and configuration-option matrix coverage.
    * When to use: Explicit TYPO3 upgrade/migration execution work.
  * `TYPO3-ExtensionScanner.md`
    * Description: Standardized ExtensionScanner execution specialized on top of General.md shared pass/gate model, including scanner-specific false-positive handling, migration pass behavior, and option-matrix regression checks.
    * When to use: ExtensionScanner triage/fixing and TYPO3 scanner-driven migration work.
  * `TYPO3-Static-Code-Tests.md`
    * Description: Ordered static code test workflow for TYPO3 projects, specialized on top of General.md shared pass/gate model (toolchain prep, full-suite baseline, static-tool execution order, pre-apply behavior-risk classifier, logging, validation gates, and explicit Batch/Meta checkpoints for ordered scoped runs).
    * When to use: Static analyzer/fixer runs during TYPO3 migration and code-quality update cycles, including per-package verification loops inside larger batch work.
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
