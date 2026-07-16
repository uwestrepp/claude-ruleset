# Rule-Set Overview: Intent, Architecture, Skills, Observed Usage

What this rule-set is *for*, how its pieces interact, which skills exist and when to reach
for them, and what actual session data says about how it is used in practice.

Relations to sibling documents:

- `CLAUDE.md` is the authoritative rule and skill **index** (what is loaded, where it lives).
- `ONBOARDING.md` is the paste-into-Claude **team entry point** (setup checklist, first steps).
- `exports/` holds condensed **outbound** adaptations for external agents; never loaded here.
- This document is the **map**: goals, mechanics, decision guidance, and usage evidence.

Usage figures in §6 come from `/insights` usage-data (window 2026-06-11 to 2026-07-10,
86 sessions, 48 with usable friction facets). Facets are rolling-pruned after ~20 days,
so re-derive before trusting old numbers.

## 1. Primary drivers

The set is not a style guide. Its persona file states the design intent directly: each rule
is "the trace of a real wreck", a fence around a known LLM failure mode. Five vectors carry
almost everything:

### 1.1 Verified correctness over confident recall

The core stance: the agent is fallible, the user is fallible, and recall confidence says
nothing about recency. Rules force verification before assertion: explicit assumptions
(General §1.1), no fabrication (§1.2), knowledge-recency checks (§1.4), diagnosis grounding
via runtime evidence instead of static reading (§1.5), version/environment verification
(§2.1-§2.3), target disambiguation (§2.4), and "No Capitulation Without Evidence" (reversals
require a named new fact, not social pressure). §1.5 and §5.6 were added in direct response
to logged failures (see §6.4), which is this vector working as intended.

### 1.2 Gated safety and minimal scope

Change-safety protocol (General §4): re-read before modify, minimal scoped edits, no silent
semantic changes, preserve public contracts, upstream-contract verification per call site.
Operating modes (§4.6) make "propose, don't silently modify" the default for legacy code;
CleanCode/PER/TYPO3 all extend this instead of restating it. Batch-shaped work is
risk-sequenced (Pass 1 safe / Pass 2 mechanical / Pass 3 high-risk, each gated), destructive
steps sit behind snapshot gates, and protected branches are reachable only via PR (§12).
Heavy workflows require explicit activation (§9) so an ambiguous prompt cannot start a
multi-hour migration.

### 1.3 Knowledge durability across sessions

Session memory is transient; `Meta.md` treats preventable information loss as a failure.
Knowledge persistence triggers (§2.1) route confirmed findings to the narrowest durable
scope (§2.2): code comments up to Confluence, with `.aiassistant/state/` (committed) vs
`.aiassistant/scratch/` (gitignored) separating durable from transient artifacts (§2.4).
Meta checkpoints at task start / milestone / end force the evaluation to actually happen.
Handover bundles (General §10.3) make session restarts lossless.

### 1.4 Evidence-driven self-improvement

The set measures itself. Meta checkpoints carry a mandatory rule-set line; `Meta.md` §3
defines the proposal format and change policy; `/core:rule-friction` plus
`bin/rule-friction-report.sh` mine per-session friction facets so rule changes follow
logged failures instead of anecdote. A distinguished diagnosis in that loop: a rule that
never *loaded* is a gating problem, not a wording problem. `bin/lint-section-refs.sh`
keeps cross-references, ledger completeness, and heading anchors intact as the set evolves.

### 1.5 Token and attention economy

Context is a budget. Path-gating keeps CleanCode/PER/Twig/TYPO3 out of sessions that do not
touch matching files; workflow content lives in skills (loaded on relevance) instead of
always-on rules; anti-duplication ("defer to source") keeps a single spine per mechanic;
General §10 governs brevity, effort/model calibration, proactive offload of token-heavy
actions, and §11 delegation of read-heavy work to sub-agents.

## 2. Secondary goals

Subordinate to the five vectors, but deliberate:

- **Traceability / auditability**: deterministic commit-to-ticket resolution
  (`/core:commits`, General §5.5), triage packets and ledgers as committed evidence,
  checkpoints appended to durable artifacts.
- **Team-facing consistency**: German for Jira/Confluence/PR surfaces, English for repo
  content (General §8.2); typography policy (§8.5); Atlassian MCP conventions in `CLAUDE.md`.
- **Composability, single spine**: `/core:batch` is the foundation; `/composer:major-upgrade`
  and `/typo3:*` are faithful specializations that must not restate or weaken parent gates.
- **Portability**: minimal rule frontmatter for IDE compatibility (PhpStorm AiRulesEditor);
  `exports/` adaptations for external harnesses, synced in the same change-set as `rules/`.
- **Deterministic environment handling**: exec-context routing (host vs container,
  General §2.3), git workflow and branch protection (§12).

## 3. How the set works (mechanics)

Loading layers, innermost always-on to outermost on-demand:

| Layer | Content | When loaded |
|---|---|---|
| `CLAUDE.md` (+ `CLAUDE.local.md`) | Index, skill ledger, MCP conventions, local secrets | Always |
| `[CRITICAL]` rules: `Meta.md`, `General.md`, `Persona.md` | Meta-governance, baseline behavior, stance | Always; re-read on revalidation (General §3.4) |
| Path-gated rules: `CleanCode.md`, `PER.md`, `Twig.md`, `TYPO3.md` | Language/platform opinions | Only when matching file paths are in scope |
| Skills (`core`, `composer`, `typo3`, `pocock` plugins) | Workflow and reference content | On prompt relevance or explicit invocation |
| Memory layers | Auto-memory (agent host facts), `.aiassistant/state/` (project agent state), `.aiassistant/scratch/` (transient) | Auto-memory index always; rest on demand |
| Tooling | `bin/lint-section-refs.sh`, `bin/rule-friction-report.sh`, `.githooks/` template | Invoked explicitly or via hooks |
| `exports/` | Outbound condensed rule-set variants | Never (external consumers only) |

Three activation policies for skills (General §9):

- **auto**: fires on prompt relevance (`/core:commits`, `/composer:knowledge`, most pocock).
- **auto-suggest gate**: the agent proposes activation, never silently runs
  (`/core:batch` on batch-shaped work or scope growth, `/composer:update`,
  `/composer:major-upgrade` on matching requests).
- **explicit activation required**: the agent must interrupt and ask for invocation
  (`/typo3:*`, `/core:rule-friction`, `/pocock:zoom-out`, `/pocock:diagnose`,
  `/pocock:grill-with-docs`). The literal ledger phrase "explicit activation required"
  is load-bearing for detection. `/composer:update` and `/composer:major-upgrade` are
  hybrids: their ledger entries carry the literal phrase (General §9.1 detection
  applies), while the agent surfaces them via auto-suggest on matching requests.

Spine and specialization: `/core:batch` defines the phase template (0-9), Pass 1/2/3 risk
model, gates, autonomous protocol, and chaining. `/composer:major-upgrade` specializes it
for major-version jumps with pluggable framework slots; `/typo3:upgrade` fills those slots
for TYPO3; `/typo3:upgrade-full` chains upgrade, scanner, and static-tests with one combined
gate set. Referenced normative content must be resolved, not remembered (General §9.3).

The feedback loop, end to end: run `/insights` (writes usage-data facets on demand) →
`bin/rule-friction-report.sh --archive` aggregates friction/outcome/satisfaction and
persists the window under `.aiassistant/state/rule-friction/` (facets prune ~20 days) →
`/core:rule-friction` classifies each recurring facet (adherence failure vs coverage gap vs
rule friction) → `Meta.md` §3.1 proposals → rule commits → `bin/lint-section-refs.sh` keeps
the structure sound.

## 4. Skill inventory

### core

| Skill | Activation | Use when |
|---|---|---|
| `/core:batch` | auto-suggest gate | Work is batch-shaped: ≥5 call sites, analyzer/rector cycles, scope grew multi-file, autonomous runs. Foundation for composer/typo3 workflows. |
| `/core:commits` | auto | Any commit create/amend/rewrite. Schema `[TYPE] JIRA (scope) summary`, ticket traceability, splitting. |
| `/core:githooks-install` | auto (suggested by `/core:commits`) | Install native git-hook enforcement of the commit schema in a project; suggested by `/core:commits` when hooks are absent. |
| `/core:brainstorm` | explicit / narrow auto | You genuinely want N diverse candidates (designs, hypotheses, test angles), not an answer to a converged question. |
| `/core:grill-me` | explicit / narrow auto | You have a *forming* plan and want to be interviewed until its open decisions are resolved; ends in a decision record. |
| `/core:poke-holes` | explicit / narrow auto | You have a *finished* artifact (plan, spec, doc) and want severity-ranked flaws, no questions asked, no alternatives. |
| `/core:rule-friction` | explicit | Periodic rule-set health review from usage data. Requires fresh `/insights` output. |

### composer

| Skill | Activation | Use when |
|---|---|---|
| `/composer:knowledge` | auto | Any Composer resolution/lock/dev-override question, trivial adds in vanilla projects. |
| `/composer:update` | explicit (auto-suggest) | Security/patch/minor updates in *customized* projects where the delta may collide with local patches/overrides. |
| `/composer:major-upgrade` | explicit (auto-suggest) | Major-version framework jump crossing a breaking-change line, non-TYPO3 or generic. TYPO3 goes to `/typo3:upgrade`. |

### typo3 (all explicit)

| Skill | Use when |
|---|---|
| `/typo3:upgrade` | Structured TYPO3 major upgrade execution (the TYPO3 specialization of `/composer:major-upgrade`). |
| `/typo3:scanner` | Any ExtensionScanner triage or scanner-driven migration pass. |
| `/typo3:static-tests` | Ordered static toolchain run: php-cs-fixer → rector → fractor → typoscript-lint → phpstan, with triage and ledgers. |
| `/typo3:upgrade-full` | The full chain (upgrade → scanner → static-tests) in one invocation; do not pre-activate components. |

### pocock (vendored third-party)

| Skill | Activation | Use when |
|---|---|---|
| `/pocock:prototype` | auto | Throwaway prototype to answer a design question before committing. |
| `/pocock:design-an-interface` | auto | Compare radically different module/API shapes ("design it twice"). |
| `/pocock:improve-codebase-architecture` | auto | Find shallow→deep module consolidation, guided by CONTEXT.md/ADRs. |
| `/pocock:zoom-out` | explicit | Map the module/caller landscape at a higher abstraction level. |
| `/pocock:handoff` | auto | Compact the conversation into a handoff doc for a fresh agent. |
| `/pocock:diagnose` | explicit | Disciplined reproduce→minimise→hypothesise→fix bug loop; deliberately manual-only. |
| `/pocock:grill-with-docs` | explicit | grill-me variant that challenges a plan against CONTEXT.md/ADR domain language. |
| `/pocock:caveman` | auto | Ultra-compressed output mode; subordinate to General §10.4/§8.2. |

## 5. Choosing between overlapping skills

**Thinking primitives** (the most common confusion):

| I have... | I want... | Use |
|---|---|---|
| An open question / early idea | N genuinely different candidates | `/core:brainstorm` |
| One module whose interface/API needs its shape decided | Radically different interface designs, compared on paper | `/pocock:design-an-interface` |
| A forming plan with open decisions | To be interviewed until it converges | `/core:grill-me` |
| A finished artifact | Flaws found, no interview, no alternatives | `/core:poke-holes` |
| A forming plan + a CONTEXT.md/ADR-driven repo | Interview grounded in the domain model | `/pocock:grill-with-docs` |

**Review surfaces**:

| Target | Use |
|---|---|
| Local working diff | built-in `code-review` (or `/simplify` for quality-only) |
| Bitbucket PR (host-agnostic) | `/pr-review-toolkit:review-pr` |
| GitHub PR | built-in `/review` |
| Design/claim level, not code lines | `/core:poke-holes` |

**Dependency/upgrade routing**:

| Situation | Use |
|---|---|
| Resolution question, lock surprise, trivial add | `/composer:knowledge` |
| Patch/minor/security bump, customized project | `/composer:update` |
| Major jump, generic framework | `/composer:major-upgrade` |
| Major jump, TYPO3 | `/typo3:upgrade`, or `/typo3:upgrade-full` for the whole chain |
| Scanner or static-analysis pass alone | `/typo3:scanner` / `/typo3:static-tests` |

## 6. Observed usage vs intention (2026-06-11 to 2026-07-10)

### 6.1 What carries the load

- **Committing is ubiquitous**: commit-related activity appears in effectively every working
  session; `/core:commits` (auto) is the highest-leverage skill in the set.
- **Phased upgrade work dominates client sessions** (~55% of sessions are client project
  engineering; rbk and fein TYPO3 v13 upgrades are the largest blocks). The de-facto entry
  point is the **resumption-doc pattern**: a first prompt of the form "Phase N starten, lies
  ZUERST `.aiassistant/state/...`", pointing at the previous session's handover. This is
  vector 1.3 working in practice and is worth treating as the canonical way to start
  workflow sessions.
- Rule-set self-maintenance is a real workload (~10% of sessions), confirming the §1.4 loop
  is exercised, not decorative.

### 6.2 Rarely used (1-2 sessions in window)

`/core:brainstorm`, `/core:grill-me`, `/composer:update`, `/composer:major-upgrade`,
explicit `/core:batch`, `/typo3:upgrade-full`. For the adversarial/diversity primitives this
matches design intent (high-friction, deliberately gated off routine phrasing); for the
composer skills the window simply contained little matching work.

### 6.3 No usage signal in window

`/core:githooks-install`, `/core:poke-holes`, `/core:rule-friction` (as a skill; its
*script* is used), `/typo3:scanner` and `/typo3:static-tests` standalone, and most
`pocock:*` skills. Two readings apply:

- **Measurement caveat**: facets capture first prompts and summaries, not Skill-tool call
  names. The Skill tool fired 65 times across 36 sessions, so auto-activated and chained
  skills (knowledge, commits, scanner/static-tests inside upgrade-full) are badly
  undercounted. Absence of a literal mention is weak evidence.
- **Genuine dead-weight candidates**: `/core:githooks-install`, `/core:poke-holes`, and most
  pocock skills have no signal on any channel. Not an argument for deletion (they are cheap,
  ledger-listed, and gated), but they should not grow further until they earn usage.

### 6.4 Friction evidence, mapped to rules

48 usable sessions: `wrong_approach` 8, `buggy_code` 8, `misunderstood_request` 4, rest ≤1.
Recurring themes and where the set answers them:

| Theme (count) | Rule answer | Status |
|---|---|---|
| Ungrounded diagnosis / assumed state (~4) | General §1.5 diagnosis grounding | Rule added *because of* these incidents |
| Exit-code-masking pipelines, fail-open shell (2) | General §5.6 incl. authoring clause | Rule added because of these incidents |
| Git hygiene slips: pre-staged files, wrong upstream (2) | `/core:commits`, General §12 | Adherence, not coverage; candidate for githooks enforcement |
| Handover written to `/tmp`, lost on reboot (1) | Meta §2.4 scratch/state convention | Fixed in the pocock:handoff skill |
| Skipped local static checks before push (1) | General §5.2, `/typo3:static-tests` | Adherence failure |
| Overlong/misdirected answer (1) | General §10.4 | Adherence failure |
| Context loss after session cut (2) | §10.3 handover bundle, resumption docs | Convention now established |

Outcomes are healthy: 30/48 fully achieved, 13 mostly, 1 not (session-limit cutoff);
4 isolated dissatisfaction signals, all in sessions that ultimately succeeded.

### 6.5 Takeaways

1. The top real-world failure mode this window was **asserting unverified state**; §1.5 is
   the direct countermeasure and should be watched in the next friction window.
2. The **resumption-doc pattern** is the proven session entry point for phased work; keep
   investing in handover quality over session length.
3. Literal-name counting undercounts skills; if per-skill telemetry matters, the friction
   loop needs a Skill-tool-call source, not just facets.
4. Unused-but-cheap skills stay; nothing currently earns promotion from explicit to auto.

## 7. Maintenance pointers

- New/changed rules: update the `CLAUDE.md` index in the same change-set (Meta §3.2), run
  `bin/lint-section-refs.sh`, sync any `exports/` derivative.
- New skills: ledger entry required before the skill counts as complete (General §9.2);
  the literal phrase "explicit activation required" gates §9.1 detection.
- Rule-set health: run `/insights`, then `/core:rule-friction`, roughly every 2-3 weeks
  (facet pruning makes longer intervals lossy). Archive each window (`--archive`);
  per-rule effectiveness claims need ≥2 archived windows, else the rule is "untested".
- Demotion review: at each rule-friction cycle (minimum quarterly) per Meta §3.3;
  always-on token budgets are enforced by `bin/lint-section-refs.sh` (check 6).
