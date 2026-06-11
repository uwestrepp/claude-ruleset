---
name: rule-friction
description: "Activate via /core:rule-friction to run the rule-set feedback loop: aggregate per-session usage-data facets (friction_counts, friction_detail, outcomes, satisfaction) via bin/rule-friction-report.sh, map recurring friction onto the rule-set, and emit Meta.md §3.1 improvement proposals. explicit activation required. Triggers: 'rule friction report', 'mine usage data', 'which rules are failing/working', periodic rule-set health review."
argument-hint: ""
allowed-tools: [Bash, Read, Grep, Glob]
---

# /core:rule-friction — Rule-Set Feedback Loop

Closes the measurement gap in rule-set governance (`Meta.md` §3): instead of
anecdote-driven checkpoints, mine the harness's own per-session classifications for
evidence of where the rule-set helps, fails, or is missing.

## Procedure

1. **Aggregate** — run `~/.claude/bin/rule-friction-report.sh`. Data source is
   `~/.claude/usage-data/facets/` (per-session `friction_counts`, `friction_detail`,
   `outcome`, `user_satisfaction_counts`) joined with `session-meta/` for project
   context. Data is rolling and machine-local; treat absence as "no signal", not
   "no friction".
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

## Boundaries (MUST)

- Read-only analysis; applying rule edits is a separate, explicitly approved step.
- Facet data is model-generated classification — treat it as signal and verify
  against session detail before proposing changes on a single data point.
- Do not quote private session content into colleague-facing surfaces.

End of skill.
