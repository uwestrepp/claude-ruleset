# Project rule-set
* `CLAUDE.md` is the authoritative rule index and rule-maintenance ledger. Keep entries concise and index-like.
* Reusable agent behavior belongs in `./rules/`. Record only project-wide rule-authoring caveats here when no single rule file is the right source of truth.
* Git workflow override per `General.md` §12: in this repository, `main` is the working branch; rule-maintenance commits land directly on `main` (recorded standing override; no PR flow).
* Rule authoring note: keep rule-file frontmatter minimal — only `paths:` on path-gated rules (Claude Code native gating; see https://code.claude.com/docs/en/memory#path-specific-rules), no frontmatter on always-on rules imported via `@`. Workflow-scoped content should live in skills, not rules, so it only loads when Claude detects prompt relevance. SKILL.md and rule files are validated by `agnix` (`agent-sh/agnix`) in the pre-commit hook; deliberate deviations are configured in `.agnix.toml`. Memory files are NOT covered: `projects/` is gitignored, so widening the hook scope does not help; validate them on demand instead.
* Follow the rules as defined in this explicit rule index:
  * @rules/Meta.md `[CRITICAL]` — always-on meta-rules: knowledge persistence, durable agent memory, labeled rule-set governance/self-improvement checkpoints, demotion review + always-on token budgets. Re-read on every revalidation (§3.4).
  * @rules/General.md `[CRITICAL]` — global baseline behavior: assumptions, validation discipline, safety, exec-context + effective-user/group routing, upstream-contract verification, commit ticket traceability, output-language + prose-typography + copy-paste-deliverable policy, skill-invocation gate, sub-agent delegation, git workflow. Re-read on every revalidation (§3.4).
  * @rules/Persona.md `[CRITICAL]` — verification-first engineering persona: known failure modes, researcher-protocol stance, facts vs. assumptions vs. unknowns; procedures live in General.md §1–§5. Re-read on every revalidation (§3.4).
  * @rules/Organisation.md — organisation context: MOSAIQ GmbH + Funntastic GmbH are sister companies, so MQ↔FT is ALWAYS internal for implementation purposes; split infrastructure (two Atlassian instances, separate portals/ad accounts) is not an external boundary; FT's agency clients ARE external.
  * rules/CleanCode.md (path-gated: code files) — clean-code opinions beyond model defaults (searchable names, no flag args, command–query separation, no public mutable state, error-handling, comments). Operating modes per `General.md` §4.6. Ask before auto-refactoring legacy.
  * rules/PER.md (path-gated: `**/*.php`) — PER/PSR coding-style for PHP; operating modes extend `General.md` §4.6 with PHP specifics (7.4 baseline, `strict_types`, 8.0/8.1/8.2/8.4 feature flags).
  * rules/Twig.md (path-gated: `**/*.twig`) — Twig authoring; the target-format-`#`-vs-Twig-`{# #}` comment trap for non-Twig output (`.env`/`.conf`/`.ini`/YAML/SQL) + delete-over-shelve for dead Twig.
  * rules/Drupal.md (path-gated: `**/*.{module,theme,install,profile}`, `**/*.info.yml`, `**/web/sites/**`, `**/drush/**`, `**/config/sync/**`) — Drupal operating policy: version/env verification, verified render-pipeline facts (html_head insertion-order, html_tag `#value` XSS-filter-not-escape, language cache-context), local-env + site-install discipline, per-surface verification. Composer via `/composer:*`, commits via `/core:commits`.
  * rules/Shopware.md (path-gated: `**/custom/plugins/**`, `**/custom/static-plugins/**`, `**/config/packages/shopware.yaml`, `**/src/Resources/app/{storefront,administration}/**`) — Shopware 6 operating policy: media/thumbnail, storefront-image (`sw_thumbnails`/`<picture>`), and plugin-migration/deploy facts. Composer via `/composer:*`, commits via `/core:commits`.
* **Exports** — `./exports/` holds condensed or adapted versions of this repo's rule-set for use in external agents or harnesses. Files under `./exports/` are NOT loaded by this harness. When editing files under `./rules/`, check `./exports/` for any condensed version that needs corresponding sync in the same change-set. See `./exports/README.md`.
* **Skill ledger** — skills live at `~/.claude/plugins/marketplaces/local/plugins/<plugin>/skills/<skill>/`; full trigger patterns are in each skill's own description (loaded into every session). Entries below record activation policy + a one-line boundary only.
* **Core skills** — auto-activate on prompt relevance unless the entry states otherwise:
  * `/core:commits` — commit schema `[TYPE] JIRA (scope) summary`, ticket traceability, body gate, pre-commit checklist.
  * `/core:githooks-install` — native git-hook scaffold install/`--update`; auto-suggested by `/core:commits`.
  * `/core:git-knowledge` — git depth beyond `General.md` §12: deploy mapping, remote/worktree/baseline disambiguation, rebase hygiene, reflog recovery. NOT commit drafting, NOT hook install.
  * `/core:brainstorm` — N distinct candidates → ranked shortlist; genuine exploration only, NOT converged work.
  * `/core:grill-me` — adversarial plan elicitation → decision record; plan-pressure-test intent only, NOT routine task start.
  * `/core:poke-holes` — critique of a *given* artifact → ranked findings; no interview, no alternatives, NOT code-diff review. vs `/core:grill-me` (interviews).
  * `/core:blueprint` — explicit activation required. Cross-module structural cut before code exists; offered by the `CleanCode.md` Architectural Cut Gate. NOT one module's interface (`/pocock:design-an-interface`).
  * `/core:effort-estimation` — agent-session-wall-clock estimates (AWS = Aufwandsschätzung); scope boundary + calibration. NOT PM scheduling.
  * `/core:communication` — colleague-facing output profile (Jira/Confluence/Bitbucket): language, typography, paste format, MCP mechanics, house-style per audience. NOT agent-to-user chat, NOT the commit schema (`/core:commits`).
  * `/core:comm-calibrate` — auto-suggest gate; inbound counterpart to `/core:communication`: mine a real artifact → house-style facts. Self-fetch only on request or confirmed offer.
* **Core workflow skills** — activation policy per entry:
  * `/core:batch` — auto-suggest gate: propose on trigger match (incl. `General.md` §3.5 scope growth), never silently run. Foundation for the typo3 skills.
  * `/core:rule-friction` — explicit activation required. Rule-set feedback loop (`bin/rule-friction-report.sh` → `Meta.md` §3.1 proposals).
* **Composer skills** (`composer` plugin) — system-agnostic Composer workflow, activation policy per entry:
  * `/composer:knowledge` — auto-activate on prompt relevance. Composer resolution order, dev-overrides, canonical-priority trap, lock-file discipline.
  * `/composer:update` — explicit activation required. Gated minor/security updates for *customized* projects. NOT vanilla adds (`/composer:knowledge`), NOT majors (`/composer:major-upgrade`).
  * `/composer:major-upgrade` — explicit activation required. System-agnostic spine for majors; layers on `/core:batch`, specialized by `/typo3:upgrade`. NOT patch/minor (`/composer:update`).
* **TYPO3 projects** — the following rules apply when working on TYPO3-based projects:
  * rules/TYPO3.md (path-gated: `**/packages/**`, `**/ext_{localconf,tables,emconf}.php`, `**/typo3conf/**`, `**/config/sites/**`, `**/*.typoscript`, `**/*.tsconfig`) — TYPO3 operating policy + upgrade-impact behavior; Composer via `/composer:*`, commits via `/core:commits`, workflow-activation via `General.md` §9.
* **TYPO3 workflow skills** — explicit activation required:
  * `/typo3:upgrade` — Upgrade Workflow (execution + DoD); TYPO3 specialization of `/composer:major-upgrade`; v10–v14 patterns in `references/`.
  * `/typo3:scanner` — ExtensionScanner workflow: command standard, pass model, false-positive handling.
  * `/typo3:static-tests` — ordered static analyzer/fixer run, triage, ledgers.
  * `/typo3:upgrade-full` — orchestrates the three component skills in sequence; do NOT pre-activate the components.
* **Pocock skills** — vendored/adapted subset of `mattpocock/skills` (provenance + upstream-refresh path in `plugins/marketplaces/local/plugins/pocock/UPDATING.md`):
  * `/pocock:prototype`, `/pocock:design-an-interface`, `/pocock:improve-codebase-architecture`, `/pocock:handoff` — auto-activate; stack-agnostic engineering aids.
  * `/pocock:zoom-out`, `/pocock:diagnose`, `/pocock:grill-with-docs` — explicit activation required (`disable-model-invocation`): upstream-gated, heavyweight, or convention-dependent.
  * `/pocock:caveman` — brevity mode; subordinate to General.md §10.4 / §8.2 (which already govern output brevity and language).
* Global MCP servers are configured in `~/.claude.json` under the `mcpServers` key (canonical location).
  * If MCP resources/templates are empty, treat this as a non-blocking beta behavior.
  * Verify MCP availability with one lightweight tool call (instead of relying only on list_mcp_resources/list_mcp_resource_templates).
  * If a tool is not working, try to find a fix or workaround. Otherwise report the issue.

## Local overrides
@CLAUDE.local.md
- The import is machine-wide (account facts, credential pointers), loads in every project, and is gitignored — a fresh machine recreates it (`ONBOARDING.md`); a missing target is skipped silently.
- A project's `./CLAUDE.local.md` loads natively right after its `CLAUDE.md` — never search for it or read it manually; if it is not in context, it does not exist there. Project-specific machine-local facts (repo endpoints, PR targets, sandbox URLs) belong there, gitignored via `.gitignore` or `.git/info/exclude`; it does not follow into a new worktree.
- Built-in `Explore`/`Plan` sub-agents load NO `CLAUDE.md`/`CLAUDE.local.md` — restate rules they must honor in the delegation prompt.

## Atlassian Rovo MCP
Colleague-facing style + full MCP mechanics live in `/core:communication` §4; language/typography/paste baseline in `General.md` §8.2/§8.5/§8.6. Instance cloudId = `https://mosaiq.atlassian.net` (do NOT call getAccessibleAtlassianResources). These two guards stay always-on — a missed skill activation must never leak customer-visible content:
- **MUST** create Confluence pages as live pages (`subtype: "live"` on `createConfluencePage`) by default; standard page only on explicit user request (no page↔live conversion via MCP — the type is set at creation). Offer-first precedence with `General.md` §10.5: the offer gate governs whether to create at all; this MUST binds only the MCP-create path.
- **MUST** restrict every Jira comment to internal visibility: pass `commentVisibility: {type: "role", value: "Users"}` on every comment create AND update (omitting it on an edit re-exposes a previously restricted comment). If the "Users" role is unavailable, stop and ask. Success signal (the `visibility` object) + jsdPublic false-positive handling: `/core:communication` §4.
