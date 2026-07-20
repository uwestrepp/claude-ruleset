# Project rule-set
* `CLAUDE.md` is the authoritative rule index and rule-maintenance ledger. Keep entries concise and index-like.
* Reusable agent behavior belongs in `./rules/`. Record only project-wide rule-authoring caveats here when no single rule file is the right source of truth.
* Git workflow override per `General.md` §12: in this repository, `main` is the working branch; rule-maintenance commits land directly on `main` (recorded standing override; no PR flow).
* Rule authoring note: keep rule-file frontmatter minimal. Use `apply:` and optional `instructions:` for IDE compatibility (PhpStorm AiRulesEditor). Claude Code's native rule-gating uses `paths:` — add it to rule files that should only load when matching file paths are in scope (see https://code.claude.com/docs/en/memory#path-specific-rules). Workflow-scoped content should live in skills, not rules, so it only loads when Claude detects prompt relevance.
* Follow the rules as defined in this explicit rule index:
  * @rules/Meta.md `[CRITICAL]` — always-on meta-rules: knowledge persistence, durable agent memory, labeled rule-set governance/self-improvement checkpoints, demotion review + always-on token budgets. Re-read on every revalidation (§3.4).
  * @rules/General.md `[CRITICAL]` — global baseline behavior: assumptions, validation discipline, safety, exec-context + effective-user/group routing, upstream-contract verification, commit ticket traceability, output-language + prose-typography + copy-paste-deliverable policy, skill-invocation gate, sub-agent delegation, git workflow. Re-read on every revalidation (§3.4).
  * @rules/Persona.md `[CRITICAL]` — verification-first engineering persona: known failure modes, researcher-protocol stance, facts vs. assumptions vs. unknowns; procedures live in General.md §1–§5. Re-read on every revalidation (§3.4).
  * rules/CleanCode.md (path-gated: code files) — clean-code opinions beyond model defaults (searchable names, no flag args, command–query separation, no public mutable state, error-handling, comments). Operating modes per `General.md` §4.6. Ask before auto-refactoring legacy.
  * rules/PER.md (path-gated: `**/*.php`) — PER/PSR coding-style for PHP; operating modes extend `General.md` §4.6 with PHP specifics (7.4 baseline, `strict_types`, 8.0/8.1/8.2/8.4 feature flags).
  * rules/Twig.md (path-gated: `**/*.twig`) — Twig authoring; the target-format-`#`-vs-Twig-`{# #}` comment trap for non-Twig output (`.env`/`.conf`/`.ini`/YAML/SQL) + delete-over-shelve for dead Twig.
  * rules/Drupal.md (path-gated: `**/*.{module,theme,install,profile}`, `**/*.info.yml`, `**/web/sites/**`, `**/drush/**`, `**/config/sync/**`) — Drupal operating policy: version/env verification, verified render-pipeline facts (html_head insertion-order, html_tag `#value` XSS-filter-not-escape, language cache-context), local-env + site-install discipline, per-surface verification. Composer via `/composer:*`, commits via `/core:commits`.
* **Exports** — `./exports/` holds condensed or adapted versions of this repo's rule-set for use in external agents or harnesses. Files under `./exports/` are NOT loaded by this harness. When editing files under `./rules/`, check `./exports/` for any condensed version that needs corresponding sync in the same change-set. See `./exports/README.md`.
* **Skill ledger** — skills live at `~/.claude/plugins/marketplaces/local/plugins/<plugin>/skills/<skill>/`; full trigger patterns are in each skill's own description (loaded into every session). Entries below record activation policy + a one-line boundary only.
* **Core skills** — auto-activate on prompt relevance, or invoke explicitly:
  * `/core:commits` — commit schema `[TYPE] JIRA (scope) summary`, ticket traceability, body gate, pre-commit checklist.
  * `/core:githooks-install` — native git-hook scaffold install/`--update`; auto-suggested by `/core:commits`.
  * `/core:git-knowledge` — git operational depth beyond the `General.md` §12 safety baseline: deploy-mapping detection, remote/worktree/baseline disambiguation, rebase/merge/force-with-lease hygiene, reflog recovery. NOT commit drafting (`/core:commits`), NOT hook install (`/core:githooks-install`).
  * `/core:brainstorm` — N distinct candidates → ranked shortlist; genuine exploration only, NOT converged work.
  * `/core:grill-me` — adversarial plan elicitation → decision record; plan-pressure-test intent only, NOT routine task start.
  * `/core:poke-holes` — adversarial critique of a *given* artifact → severity-ranked findings (Blocking/Material, no nitpick bucket); no interview, no alternatives, NOT code-diff review. Disambiguate from grill-me (which interviews) on overlap.
  * `/core:effort-estimation` — agent-session-wall-clock effort estimates (AWS = Aufwandsschätzung): scope boundary (impl+verification in, review/deploy/external out as lead-time drivers), task-type bands, calibration factors. NOT PM scheduling.
* **Core workflow skills** — activation policy per entry:
  * `/core:batch` — auto-suggest gate: propose on trigger match (incl. `General.md` §3.5 scope growth), never silently run. Foundation for the typo3 workflow skills.
  * `/core:rule-friction` — explicit activation required. Rule-set feedback loop (`bin/rule-friction-report.sh` → `Meta.md` §3.1 proposals).
* **Composer skills** (`composer` plugin) — system-agnostic Composer workflow, activation policy per entry:
  * `/composer:knowledge` — auto-activate on prompt relevance. Composer resolution order, dev-overrides, canonical-priority trap, lock-file discipline.
  * `/composer:update` — explicit activation required. Informed, gated minor/security Composer updates for *customized* projects; NOT trivial adds in vanilla projects (`/composer:knowledge`), NOT major-version migrations (`/composer:major-upgrade`).
  * `/composer:major-upgrade` — explicit activation required. System-agnostic spine for major-version upgrades; layers on `/core:batch`; `/typo3:upgrade` is the TYPO3 specialization. NOT patch/minor (`/composer:update`).
* **TYPO3 projects** — the following rules apply when working on TYPO3-based projects:
  * rules/TYPO3.md (path-gated: `**/packages/**`, `**/ext_{localconf,tables,emconf}.php`, `**/typo3conf/**`, `**/config/sites/**`, `**/*.typoscript`, `**/*.tsconfig`) — TYPO3 operating policy + upgrade-impact behavior; Composer via `/composer:*`, commits via `/core:commits`, workflow-activation via `General.md` §9.
* **TYPO3 workflow skills** — explicit activation required:
  * `/typo3:upgrade` — Upgrade Workflow (execution + DoD); the TYPO3 specialization of `/composer:major-upgrade`; v10–v14 changelog + migration patterns in `references/`.
  * `/typo3:scanner` — ExtensionScanner workflow: command standard, pass model, false-positive handling.
  * `/typo3:static-tests` — ordered static analyzer/fixer run, triage, ledgers.
  * `/typo3:upgrade-full` — orchestrates the three component skills in sequence; do NOT pre-activate the components.
* **Pocock skills** — vendored/adapted subset of `mattpocock/skills` (provenance + upstream-refresh path in `plugins/marketplaces/local/plugins/pocock/UPDATING.md`):
  * `/pocock:prototype`, `/pocock:design-an-interface`, `/pocock:improve-codebase-architecture`, `/pocock:handoff` — auto-activate on prompt relevance; stack-agnostic engineering/prototyping aids.
  * `/pocock:zoom-out`, `/pocock:diagnose`, `/pocock:grill-with-docs` — explicit activation required (`disable-model-invocation`); zoom-out ships upstream-gated, diagnose is a deliberately manual heavyweight loop (baseline diagnosis discipline: `General.md` §1.5), grill-with-docs depends on CONTEXT.md/ADR conventions.
  * `/pocock:caveman` — brevity mode; subordinate to General.md §10.4 / §8.2 (which already govern output brevity and language).
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
- **MUST** create Confluence pages as live pages (`subtype: "live"` on `createConfluencePage`) by default; use a standard page only when the user explicitly requests it. There is no page↔live conversion via MCP — the type must be set at creation; converting afterwards is possible only manually in the Confluence UI.
  - Precedence with `General.md` §10.5 (offer-first): the offer gate governs whether the agent creates the page at all; the live-page MUST binds only the MCP-create path. When offering the paste path, state that the resulting page can become a live page only via manual conversion in the UI, not via MCP.
- **MUST** use cloudId = "https://mosaiq.atlassian.net" (do NOT call getAccessibleAtlassianResources)
- **MUST** use `maxResults: 10` or `limit: 10` for ALL Jira JQL and Confluence CQL search operations.
- **MUST** paginate JQL/CQL queries until the end of result set (or until user asks for a sample only).
- **MUST** restrict every Jira comment to internal visibility: pass `commentVisibility: {type: "role", value: "Users"}` on all comment-creating or -updating calls (the same tool updates when given a `commentId`; an edit that omits the param can re-expose a previously restricted comment). If the "Users" role is unavailable in a project, stop and ask instead of posting unrestricted.
  - Success/failure signal: the authoritative indicator is the `visibility` object in the create/update response — `visibility: {type: "role", value: "Users"}` present means the restriction IS applied. `jsdPublic: true` alongside an applied `visibility` object is a known false positive (mosaiq.atlassian.net returns it on every restricted comment; user-verified in the UI, 2026-07-16 GMP-341/343) — do NOT flag it. Flag for manual restriction only when the response lacks the requested `visibility` object.
