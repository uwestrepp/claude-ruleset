---
name: effort-estimation
description: "Use when asked to estimate the effort/time for a task, ticket, or work package, size a change, or produce an \"Aufwandsschätzung\" (AWS = Aufwandsschätzung, the German term, NOT Amazon). Triggers: \"wie lange dauert X\", \"schätz den Aufwand\", \"Aufwandsschätzung / AWS für\", \"how long will this take\", \"estimate effort for\", \"size this ticket\", \"story points / t-shirt size\", sizing a backlog item, filling an effort field on a Jira ticket, comparing scope options by cost. Produces agent-session-wall-clock estimates with explicit scope boundaries and calibration factors; NOT project management scheduling."
argument-hint: "[task-or-ticket]"
allowed-tools: [Read, Grep, Glob, Bash]
---

# Agent-Assisted Effort Estimation (AWS)

*Input (`$ARGUMENTS`): the task or ticket to estimate.*

Method for estimating the effort of a coding/ops task when **an agent (Claude
Code) does the work**. In this house the estimate is called an **AWS**
(*Aufwandsschätzung*; note: in these projects "AWS" never means Amazon).
Normative keywords per `General.md`. Estimates written into colleague-facing
surfaces (Jira, tickets) follow `General.md §8.2` (German).

## 1. What an AWS measures

- **Unit: agent-session wall-clock** — the elapsed time of the agent session that
  does the work, NOT classic human person-days. Small work in hours at ~0.25 h
  granularity; larger packages aggregated to **PT** (Personentag), 1 PT ≈ 8 h.
- **Always a range (min–max), never a point value.** Name the dominant
  uncertainty explicitly (e.g. "Ursache noch offen").
- **Assumes stated settings.** Wall-clock depends on model + `/effort` and on the
  local project setup being ready. State the assumption (the observed baseline was
  *Claude Code, local project setup, `/effort high`*). If the intended run uses a
  different model/effort, say so, because it moves the number (`General.md §10.2`).

## 2. Scope boundary (the load-bearing part)

**Included in the AWS:** implementation + verification/re-measurement
(profiler, Lighthouse, wire measurement, replaying a real payload) + PR
preparation. Writing the measurement scripts counts.

**Excluded from the AWS — report separately as "Durchlaufzeit-Treiber"
(lead-time drivers), never folded into the number:**

- human review / visual regression acceptance,
- deploy / release / customer-approval cycles,
- coordination with external parties (hosting, third-party APIs, SSO test
  accounts, other teams).

Lead time is dominated by these gates, not by agent implementation. Keep them
visible and separate so "2 h of work" is never mistaken for "done in 2 h".

## 3. How to derive the number

1. Decompose the task into concrete sub-steps.
2. Give each sub-step its own min–max band.
3. Sum the bands. Present as "Teil A ~x; Teil B ~y. **Gesamt ~z**."
4. List the excluded lead-time drivers beneath, each labelled.
5. State assumptions (model/effort, setup ready, capabilities relied on).

Output line for a ticket (German, `§8.2`), e.g.:

> **AWS (agent-gestützt, Session-Wall-Clock, `/effort high`):** Decorator+Test ~1 h, Nachmessung ~0,5 h → **~1–1,5 h**. Durchlaufzeit-Treiber (nicht enthalten): menschliche Abnahme, Prod-Deploy-Freigabe.

## 4. Reference bands (seed calibration)

Observed bands from the GMP-304/340 sessions (Shopware/PHP; agent-assisted,
`/effort high`). Treat as a starting prior, not a law. The concrete per-ticket
estimates + outcomes these generalise (agent-made, calibrated against a prior
execution, practitioner-assessed as accurate; no recorded actuals) are the
validated seed baseline in `references/gmp-304-340-baseline.md`.

| Task type | Typical AWS |
|---|---|
| Content/config quick-win, no deploy | ~15–30 min |
| nginx / infra config + verification | ~0.5–1 h |
| Plugin patch / decorator + test + re-measure | ~1–1.5 h |
| Caching insertion + profiler re-measure | ~0.5–1 h |
| Root-cause analysis (cause unknown) + fix | ~1 h analysis + 0.5–1.5 h fix |
| Message-queue rebuild (message+handler+retry+tests) | ~2–3 h + E2E ~0.5–1 h |
| Collection of small findings | ~20–45 min each (N+1 nearer ~1 h) |
| Larger feature / theme package | in PT (~0.5–1.5 PT), split into sub-steps |

Session anchors: full local analysis incl. setup-debugging ≤3 h; staging
measurement + reproduction + ticket drafts ~0.5 h.

## 5. Calibration factors (what systematically moves the estimate)

- **Lead time ≠ effort.** External gates drive the calendar; separate them (§2).
- **UI/CSS work is review-dominated**, not coding-dominated — human visual
  regression across page types is the real cost.
- **Assumed dependencies can vanish** (an expected hosting/coordination step that
  turns out unnecessary) → verify dependency assumptions early; don't inflate lead
  time on an unchecked assumption.
- **Coupled tickets shift each other's value/scope.** Re-estimate after each
  baseline change (an earlier fix can make a later one marginal).
- **Wrong capability assumptions are a systematic error source** (e.g. assuming a
  feature must be built that the framework already provides). Verify capabilities
  (`§1.4`) before sizing.
- **Verification uncovers hidden follow-on work** (guards, extra plugins, edge
  cases) not in the original draft — the first estimate rarely sees it. Widen the
  upper bound when the change touches shared/cached/personalised state.
- **Missing test infrastructure** removes a unit-test sub-step but shifts the load
  onto runtime verification — net effort may not drop.
- There is (yet) **no calibrated effort multiplier**; correction factors require
  recorded estimate-vs-actual data (§6).

## 6. Sharpening over time (calibration record)

The seed above is thin: the GMP-304/340 data has estimates but **no recorded
actual wall-clock**, so no hard correction factors exist yet. To sharpen:

- After a task whose AWS was stated, record **estimate vs actual** (agent-session
  wall-clock) plus a one-line "why it differed" in the project's durable state
  (`.aiassistant/state/notes/effort-calibration.md` or equivalent), per
  `Meta.md §2`.
- Project-specific band adjustments live with the project; a systematic factor
  confirmed across projects is a candidate to fold back into §4/§5 of this skill
  (propose per `Meta.md §3.1`).
- When actuals accumulate, replace qualitative lessons in §5 with numeric
  multipliers (e.g. "review adds ×N to UI tasks").
