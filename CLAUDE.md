# Project rule-set
* `CLAUDE.md` is the authoritative rule index and rule-maintenance ledger. Keep entries concise and index-like.
* Reusable agent behavior belongs in `./rules/`. Record only project-wide rule-authoring caveats here when no single rule file is the right source of truth.
* Rule authoring note: keep rule-file frontmatter minimal. Use `apply:` and optional `instructions:` for IDE compatibility (PhpStorm AiRulesEditor). Claude Code's native rule-gating uses `paths:` — add it to rule files that should only load when matching file paths are in scope (see https://code.claude.com/docs/en/memory#path-specific-rules). Workflow-scoped content should live in skills, not rules, so it only loads when Claude detects prompt relevance.
* Follow the rules as defined in this explicit rule index:
  * @rules/Meta.md `[CRITICAL]` — always-on meta-rules: knowledge persistence, durable agent memory, labeled rule-set governance/self-improvement checkpoints. Re-read on every revalidation (§3.4).
  * @rules/General.md `[CRITICAL]` — global baseline behavior: assumptions, validation discipline, safety, exec-context routing, upstream-contract verification, commit ticket traceability, output-language policy, skill-invocation gate, sub-agent delegation. Re-read on every revalidation (§3.4).
  * @rules/Persona.md `[CRITICAL]` — additive verification-first engineering stance (facts vs. assumptions, real-target confirmation, minimal scoped edits, execution-path validation, risk communication). Re-read on every revalidation (§3.4).
  * rules/CleanCode.md (path-gated: code files) — clean-code opinions beyond model defaults (searchable names, no flag args, command–query separation, no public mutable state, error-handling, comments). Operating modes per `General.md` §4.6. Ask before auto-refactoring legacy.
  * rules/PER.md (path-gated: `**/*.php`) — PER/PSR coding-style for PHP; operating modes extend `General.md` §4.6 with PHP specifics (7.4 baseline, `strict_types`, 8.0/8.1/8.2/8.4 feature flags).
  * rules/Twig.md (path-gated: `**/*.twig`) — Twig authoring; the target-format-`#`-vs-Twig-`{# #}` comment trap for non-Twig output (`.env`/`.conf`/`.ini`/YAML/SQL) + delete-over-shelve for dead Twig.
* **Exports** — `./exports/` holds condensed or adapted versions of this repo's rule-set for use in external agents or harnesses. Files under `./exports/` are NOT loaded by this harness. When editing files under `./rules/`, check `./exports/` for any condensed version that needs corresponding sync in the same change-set. See `./exports/README.md`.
* **Core skills** — auto-activate on prompt relevance, or invoke explicitly:
  * `/core:commits` (`~/.claude/plugins/marketplaces/local/plugins/core/skills/commits/`) — commit schema `[TYPE] JIRA (scope) summary`, body-decision gate, ticket traceability (extension map / branch override / multi-extension split), pre-commit checklist, nested-repo handling.
  * `/core:composer` (`~/.claude/plugins/marketplaces/local/plugins/core/skills/composer/`) — Composer resolution order, tag-driven releases for private registries, dev-override patterns, canonical-priority trap + diagnostic order, lock-file discipline.
  * `/core:githooks-install` (`~/.claude/plugins/marketplaces/local/plugins/core/skills/githooks-install/`) — installs the native git-hook scaffold (commit-format + ticket traceability); fresh install + `--update`; outcome/opt-out in `.aiassistant/state/githooks-install.yaml`. Auto-suggested by `/core:commits` when no `.githooks/`/`core.hooksPath`.
  * `/core:brainstorm` (`~/.claude/plugins/marketplaces/local/plugins/core/skills/brainstorm/`) — verbalized-sampling: N distinct candidates → ranked shortlist; genuine exploration only (NOT routine/converged work). Complements `advisor` (one opinion vs. N candidates).
  * `/core:grill-me` (`~/.claude/plugins/marketplaces/local/plugins/core/skills/grill-me/`) — adversarial plan elicitation: ground in code → enumerate material decisions → dependency-order → interview only on what code can't answer → terminate on convergence → emit decision record. Auto-activates on plan-pressure-test intent (NOT routine task start/execution). Complements `advisor` (one opinion) and `/core:brainstorm` (N candidates) by converging one plan.
* **Core workflow skills** — explicit activation required; see each skill's description for trigger patterns:
  * `/core:batch` (`~/.claude/plugins/marketplaces/local/plugins/core/skills/batch/`) — shared batch execution template, risk-sequenced Pass 1/2/3 model + triage/PR-split gates, autonomous-mode protocol, chaining model, reporting. Foundation for the typo3 workflow skills.
  * `/core:composer-update` (`~/.claude/plugins/marketplaces/local/plugins/core/skills/composer-update/`) — explicit activation required. Informed, gated Composer updates for *customized* projects (security/patch/minor): baseline → dry-run delta → reusable upstream change-map → intersect with project customizations via a pluggable ecosystem collision-vector catalog (`references/catalogs/<eco>.md`; ships TYPO3 + generic) → document (fat shared map + thin per-project record) → gated rollout. Layers on `/core:batch` (phase/Pass model); references `/core:composer` (resolution/lock mechanics) + `/core:commits`. Self-detects ecosystem; offers to author a new catalog when none exists. Boundary: NOT trivial adds in vanilla projects (`/core:composer`); NOT major-version migrations (`/typo3:upgrade`).
* **TYPO3 projects** — the following rules apply when working on TYPO3-based projects:
  * rules/TYPO3.md (path-gated: `**/packages/**`, `**/ext_{localconf,tables,emconf}.php`, `**/typo3conf/**`, `**/config/sites/**`, `**/*.typoscript`, `**/*.tsconfig`) — TYPO3 operating policy + upgrade-impact behavior; Composer/commits via `/core:*`, workflow-activation via `General.md` §9. For TYPO3 tasks (core/extensions/Extbase/TypoScript/Fluid/migrations).
* **TYPO3 workflow skills** — explicit activation required; see each skill's description for trigger patterns:
  * `/typo3:upgrade` (`~/.claude/plugins/marketplaces/local/plugins/typo3/skills/upgrade/`) — Upgrade Workflow (execution + DoD): phases, preflight, inventory, deprecation/breaking scan (v10–v14 changelog in `references/`), validation, doc sync, commits.
  * `/typo3:scanner` (`~/.claude/plugins/marketplaces/local/plugins/typo3/skills/scanner/`) — ExtensionScanner Workflow: command standard, pass model, false-positive handling, verification gates, reporting.
  * `/typo3:static-tests` (`~/.claude/plugins/marketplaces/local/plugins/typo3/skills/static-tests/`) — Static Code Test Workflow: ordered run (php-cs-fixer → rector1 → rector2 → fractor → typoscriptlint → phpstan), triage, false-positive ledger, re-run gates.
  * `/typo3:upgrade-full` (`~/.claude/plugins/marketplaces/local/plugins/typo3/skills/upgrade-full/`) — orchestrates `/typo3:upgrade` → `/typo3:scanner` → `/typo3:static-tests` (one toolset gate/preflight/autonomous-gate/Phase 9 handover; `/core:batch` §6 chaining). Do NOT pre-activate the components.
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
- **MUST** restrict every Jira comment to internal visibility: pass `commentVisibility: {type: "role", value: "Users"}` on all comment-creating or -updating calls (the same tool updates when given a `commentId`; an edit that omits the param can re-expose a previously restricted comment). If the "Users" role is unavailable in a project, stop and ask instead of posting unrestricted.
  - Failure signal: a posted comment showing `jsdPublic: true` is customer-visible (appears on JSM projects; absent elsewhere) — flag it for manual restriction immediately.
