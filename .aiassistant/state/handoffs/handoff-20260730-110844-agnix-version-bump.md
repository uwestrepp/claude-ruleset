# Handoff — agnix pin bump 0.40.0 → 0.41.1

- **Date:** 2026-07-30
- **Repo:** `~/.claude` (rule-set + skills; `main` is the working branch, direct commits per `CLAUDE.md`)
- **Focus for the next session:** decide and execute the agnix version bump. Non-urgent, cleanly separable, one change-set.

## Why this exists

The pre-commit hook's once-a-day update notice fired during commit `4adcdf2` (2026-07-30):

```
agnix: newer release available — 0.41.1 (pinned 0.40.0 in .agnix-version).
```

The pin in `.agnix-version` is authoritative and the `.agnix.toml` `disabled_rules`
entries are keyed to it, so a bump is a conscious decision, not a routine update. It
was deliberately not done in that session (out of scope: the session added
`rules/Organisation.md`).

## Verified state (2026-07-30)

- Pinned: `0.40.0` (`.agnix-version`). Latest on npm: `0.41.1` (`npm view agnix version`).
- Baseline on the pinned version, over the hook's exact scope:
  `npx agnix@0.40.0 validate plugins/marketplaces/local/plugins rules`
  → **0 errors, 17 warnings, 2 info** (13 auto-fixable).
- Warning classes in that baseline: `CC-SK-007` unrestricted Bash (13×), `AS-013`
  file reference deeper than one level (3×), `AS-012` skill > 500 lines (1×,
  `core/skills/batch/SKILL.md` at 545), `VER-001` info (no tool/spec versions pinned).
- `.agnix.toml` currently disables exactly one rule: `XP-SK-001` (`argument-hint` is
  used on purpose; Claude Code surfaces it).
- Hook contract (`.githooks/pre-commit`): non-strict, blocks on **errors** only;
  warnings are shown. Scope is `plugins/marketplaces/local/plugins rules` — NOT
  `CLAUDE.md` (which fails `0.40.0` with "Import path escapes project root:
  @CLAUDE.local.md", a deliberate design decision; keep it out of hook scope or that
  error becomes blocking).
- Notice cadence: throttled via `$(git rev-parse --git-path agnix-update-check.stamp)`,
  at most once per day, never affects the commit exit status.

## Steps

1. Read the upstream changelog / release notes for 0.41.x (repo `agent-sh/agnix`,
   `https://github.com/agent-sh/agnix`). Unknown at handoff time: whether 0.41
   adds rules, renames rule IDs, or changes severities. Do not assume.
2. Dry-run the new version WITHOUT touching the pin:
   `npx --yes agnix@0.41.1 validate plugins/marketplaces/local/plugins rules`
   and diff against the baseline above (0 errors / 17 warnings / 2 info).
3. Classify any delta: new **errors** must be resolved or consciously suppressed
   before bumping (they would block every commit). New warnings are non-blocking and
   may be accepted.
4. Re-key `.agnix.toml` if a disabled rule ID was renamed or split; `XP-SK-001` is
   the only entry to check. `agnix explain <ID>` on the new version helps.
5. Only then write `0.41.1` into `.agnix-version` and commit
   (`[CI] AGENT (ci) bump agnix pin to 0.41.1`, or `[CHORE]` if nothing behavioral
   changes). The version string is also stated as a fact outside the pin, verified
   2026-07-30 by `grep -rn '0\.40\.0'`: memory
   `ref_skill_frontmatter_argument_hint.md` (3×, incl. "currently `0.40.0`") and its
   `MEMORY.md` index line. Update those in the same change-set. One further occurrence
   sits in §9.2 of
   `.aiassistant/state/proposals/done/proposal-2026-07-29-implementation-visibility.md`
   (path corrected 2026-08-31: the file was archived, and the old pointer also named the
   wrong directory). That sentence records which command was run when that change-set
   shipped, so it is history and MUST NOT be bumped. `.agnix.toml` and `CLAUDE.md` do NOT
   hardcode it (they point at `.agnix-version`), so they need no edit.
6. Validation for the commit itself: run the pre-commit path (a real commit
   exercises it) and record the new baseline counts in the commit body.

## Adjacent open points (do NOT bundle)

- **Older agnix follow-ups** live in `handoffs/done/handoff-20260721-111135-agnix-followups.md`
  (best-practice warning triage, the CC-MEM-012 / AiRulesEditor decision, the skipped
  agnix MCP, global-install robustness). That document is archived as consumed; treat
  its open points as still-open background, not as this handoff's scope.
- **CLAUDE.md always-on budget.** History shows a ratchet worth naming: the budget was
  raised 3000 → 3100 on 2026-07-21, later returned to 3000 after trimming, and raised
  to 3100 again on 2026-07-30 for the `@rules/Organisation.md` index line (~3036 used,
  explicit user decision). The `Meta.md` §3.3 demotion review over the CLAUDE.md index
  is genuinely due at the next `/core:rule-friction` cycle; the skill-ledger entries are
  the obvious demotion candidate. Also tracked in memory `project_open_workstreams.md`.

## Suggested skills

- None required for the bump itself; agnix runs via Bash.
- `/core:commits` for the commit (repo convention `[TYPE] AGENT (scope) summary`, direct to `main`).
- `/core:rule-friction` only if the budget item above is picked up instead.

## Trigger prompt for the next session

> Read `.aiassistant/state/handoffs/handoff-20260730-110844-agnix-version-bump.md`.
> Check the upstream changelog for agnix 0.41.x, then dry-run
> `npx --yes agnix@0.41.1 validate plugins/marketplaces/local/plugins rules` and diff
> against the recorded baseline (0 errors, 17 warnings, 2 info on 0.40.0). Report the
> delta and your recommendation before changing `.agnix-version`. Recommended:
> `/effort medium | claude-opus-5[1m]`.
