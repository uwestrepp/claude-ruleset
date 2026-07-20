---
name: rule-friction
description: "Activate via /core:rule-friction to run the rule-set feedback loop over aggregated usage-data facets (bin/rule-friction-report.sh) and emit Meta.md §3.1 improvement proposals. explicit activation required. Triggers: 'rule friction report', 'mine usage data', 'which rules are failing/working', periodic rule-set health review."
argument-hint: ""
allowed-tools: [Bash, Read, Grep, Glob]
---

# /core:rule-friction — Rule-Set Feedback Loop

Closes the measurement gap in rule-set governance (`Meta.md` §3): instead of
anecdote-driven checkpoints, mine the harness's own per-session classifications for
evidence of where the rule-set helps, fails, or is missing.

## Procedure

1. **Aggregate & archive** — run `~/.claude/bin/rule-friction-report.sh --archive`.
   Data source is `~/.claude/usage-data/facets/` (per-session `friction_counts`,
   `friction_detail`, `outcome`, `user_satisfaction_counts`) joined with
   `session-meta/` for project context. Data is rolling and machine-local; treat
   absence as "no signal", not "no friction".
   `--archive` persists the aggregate as a dated artifact under
   `.aiassistant/state/rule-friction/`; commit it with the review's change-set.
   Facets rolling-prune after ~20 days — an unarchived window is unrecoverable.
   Freshness gate: facets are written only by Claude Code's built-in `/insights`
   command (on demand; no background generation, no toggle). Check the newest
   facet's mtime first; if the window is stale, ask the user to run `/insights`
   and re-run the report before classifying (see auto-memory
   `ref-claude-code-insights`).
2. **Classify each recurring pattern** (≥2 sessions, or a single severe case):
   - **adherence failure** — an existing rule covers it but was not followed. First
     check whether the rule was even loaded in that context (path-gating not matched,
     skill not activated, project without the rule-set): a rule that never loaded
     cannot be violated, and the fix is gating/activation, not wording.
   - **coverage gap** — no rule covers it; candidate new rule or skill content.
   - **rule friction** — a rule itself caused the problem (over-asking, ceremony,
     wrong default); candidate for weakening, re-scoping, or removal.
3. **Propose** — emit `Meta.md` §3.1-structured proposals (problem, proposed change,
   expected impact, risk/tradeoff), each tied to its evidence (session ids).
4. **Persist** substantive findings per `Meta.md` §1.1/§2 (audit note or rule
   change-set proposal).

Structural consistency: when the cycle runs after a `rules/` or `skills/` change-set,
or as part of the `Meta.md §3.3` demotion review, delegate an internal-consistency
audit (CLAUDE.md index vs rule files, §-cross-refs, skill-ledger completeness,
exports/ sync drift, agent-reference validity) to the `rule-index-auditor` sub-agent
(`General.md §11.1`) and fold its drift findings into step 3's proposals.

## Effectiveness claims (MUST)

- A per-rule effectiveness claim (a rule "works", "prevented X", "reduced friction")
  requires at least 2 archived report windows AND named incident-class counts
  compared across them. Without that baseline, label the rule **"untested"** — do
  not present retention as evidence of effectiveness.
- Per-skill usage claims require Skill-tool call counts from session transcripts;
  facets do not capture Skill-tool invocations and badly undercount auto-activated
  skills.

## Boundaries (MUST)

- Read-only analysis; applying rule edits is a separate, explicitly approved step.
- Facet data is model-generated classification — treat it as signal and verify
  against session detail before proposing changes on a single data point.
- Do not quote private session content into colleague-facing surfaces.

End of skill.
