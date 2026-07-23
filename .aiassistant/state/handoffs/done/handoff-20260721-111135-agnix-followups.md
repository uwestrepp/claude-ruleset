# Handoff — agnix / skill-lint follow-ups

- **Date:** 2026-07-21
- **Repo:** `~/.claude` (rule-set + skills; `main` is the working branch, direct commits per `CLAUDE.md`)
- **Focus for the next session:** the open, non-blocking follow-ups left after adopting the real agnix linter. None are urgent; each is a cleanly separable change-set.

## Context (what was just done)

This session added a sibling skill and then hardened SKILL.md/rule quality tooling. Landed commits (newest first):

- `866b0ee` [CI] replace hand-rolled skill linter with real **agnix**
- `e6fea7b` [CI] add SKILL.md/rule linter to pre-commit (the hand-rolled one, now removed)
- `065389c` [FIX] body `<...>` → `{...}` placeholders (unclosed-XML-tag)
- `b59dd1c` [FIX] earlier ALL-CAPS placeholder pass (superseded by `065389c`)
- `864ae11` [FIX] frontmatter across local skills (quote `argument-hint`, trim descriptions, add `$ARGUMENTS`)
- `2945749` [FEAT] add `/core:comm-calibrate` (inbound counterpart to `/core:communication`)

Current linter state: **agnix is the authority.** Config `~/.claude/.agnix.toml`; wired into `~/.claude/.githooks/pre-commit` (non-strict = blocks on errors, warnings visible). Run manually: `npx agnix@0.40.0 validate plugins/marketplaces/local/plugins rules`; explain a rule: `agnix explain <ID>`. Baseline as of this handoff: **0 errors, 18 warnings, 2 info.** Background in memory `ref_skill_frontmatter_argument_hint.md`.

## Open points

### 1. Best-practice agnix warnings (non-blocking; own change-set)
Decision this session: keep them **visible, not suppressed**. Address when wanted:
- **CC-SK-007** unrestricted Bash (13 skills) — scope `Bash` in `allowed-tools` (e.g. `Bash(git status:*)`) where feasible; several are general-purpose skills that legitimately need broad Bash, so this is case-by-case, not a blanket fix.
- **AS-013** file reference deeper than one level (3×) — `composer/update` + `major-upgrade` reference `references/catalogs/{eco}.md`. Restructure or accept.
- **AS-012** skill content > 500 lines (1×) — `core/skills/batch/SKILL.md` (545). Split or accept.
- **CC-SK-012** `argument-hint` set but body has no `$ARGUMENTS` (1×) — `core/skills/rule-friction/SKILL.md` has empty `argument-hint: ""`; **trivial**: drop the empty key (rule-friction takes no args).
- **VER-001** (info) — no tool/spec versions pinned; optionally add `[tool_versions]` / `[spec_revisions]` to `.agnix.toml`.

To triage all at once: `npx agnix@0.40.0 validate plugins/marketplaces/local/plugins rules`.

### 2. Deferred decision: `apply:` / `instructions:` in `rules/*.md` (CC-MEM-012)
User answer this session: "unsicher, vorerst behalten + unterdrücken" → the two keys are **kept** and CC-MEM-012 is **disabled** in `.agnix.toml`. They exist only for **PhpStorm AiRulesEditor** (Claude Code ignores them, gates on `paths:`). **Revisit once JetBrains-AiRules usage is confirmed:** if not used, remove `apply:`/`instructions:` from all 9 rule files, drop the `disabled_rules` entry, and update the `CLAUDE.md` rule-authoring note (which currently mandates them).

### 3. agnix MCP — intentionally skipped
The `agnix-agent-linter` MCP was considered and **skipped** (user token concern + my recommendation): the CLI is runnable via Bash during authoring, so the MCP adds no capability, only overhead. Reconsider only if structured interactive linting is genuinely wanted; would be a `~/.claude.json` `mcpServers` change.

### 4. Hook robustness (optional)
The hook uses `npx --yes agnix@0.40.0` (downloads once, then cached; offline+uncached → deliberate fail-open skip). For absolute robustness, `npm i -g agnix@0.40.0` and call the global binary instead. Not done; current approach is fine for this single host.

### 5. CLAUDE.md always-on budget (Meta.md §3.3)
`CLAUDE.md` is at ~3066 / 3100 tokens (headroom ~34; budget raised 3000→3100 this session). **Before the next always-on addition, run a demotion review** or the `bin/lint-section-refs.sh` trip-wire will block. Not urgent.

## Pre-existing, unrelated open workstreams (not this session)
See memory `project_open_workstreams.md` and the older handoffs in this dir — notably Item 7 (deployer→drupal rule move) still open. Keep separate from the agnix follow-ups above.

## Suggested skills for the next session
- `/core:batch` — if tackling point 1 across many skills (auto-suggest gate; it is batch-shaped: multiple files, mechanical).
- `/core:commits` — for the commit(s); repo convention is `[TYPE] AGENT (scope) summary`, direct to `main`.
- `/core:rule-friction` + demotion review — before any always-on `CLAUDE.md` growth (point 5).
- No skill needed to just run agnix — invoke it via Bash.

## Trigger prompt for the next session
> Read `.aiassistant/state/handoffs/handoff-20260721-111135-agnix-followups.md` and memory `ref_skill_frontmatter_argument_hint.md`. Then run `npx agnix@0.40.0 validate plugins/marketplaces/local/plugins rules` to see the current 18 non-blocking warnings. Start with the trivial CC-SK-012 fix (remove the empty `argument-hint: ""` from `core/skills/rule-friction/SKILL.md`), then let's decide which of the remaining best-practice warnings (CC-SK-007 Bash scoping, AS-013 ref depth, AS-012 batch length) to address. Recommended: `/effort high | claude-opus-4-8[1m]`.
