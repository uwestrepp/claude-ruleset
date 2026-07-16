# Handover: Rule-Set Review Implementation (Proposals P1-P12)

Continuation doc for implementing the proposals from
`.aiassistant/state/ruleset-critical-review-2026-07-13.md` (committed `653e2d8`).
That file is the single source of truth for problem statements, evidence, and
proposal content (§C); this doc adds only the iteration protocol, ordering,
per-step target hints, and the status ledger. Do not restate review content here.

## Process protocol (user-defined)

Iterate the steps below **one at a time, in order**. For each step:

1. **Problem**: restate the problem concisely from the review doc (§A/§B refs).
2. **Solution**: present the concrete change at diff level (files, sections,
   proposed wording) BEFORE editing anything.
3. **Decision**: ask the user Ja / Nein / Vielleicht (AskUserQuestion).
   - **Ja** → implement, validate, commit (one commit per step, `/core:commits`
     schema, repo convention `[TYPE] AGENT (scope) ...`), update the ledger
     below in the same commit.
   - **Nein** → record `declined` + one-line reason in the ledger; move on.
   - **Vielleicht** → record `deferred` + open question in the ledger; move on.
4. Only then proceed to the next step.

Do not batch multiple steps into one decision or commit, except Step 1
(P11+P12 bundled by explicit user instruction; still one decision round per
sub-item group if they diverge).

## Standing constraints (apply to every step)

- Meta.md §3.2 salience exception: never weaken anti-capitulation /
  premature-closure / recency-pressure rules; P10 trims must route around them.
- Rules-file changes: update the `CLAUDE.md` index in the same change-set
  (Meta §3.2) and check `exports/` for a condensed version needing sync
  (`exports/README.md`).
- Run `bin/lint-section-refs.sh` before every commit (also enforced by hook).
- Numbered section headings in rules are stable anchors: do not renumber;
  additions get new numbers.
- All edits happen in `~/.claude` on `main` (recorded working-branch practice;
  P2 formalizes this).

## Step order and target hints

| Step | Proposals | Target files (hint, verify before editing) | Note |
|---|---|---|---|
| 1 | P11 + P12 | CLAUDE.md (ledger: zoom-out, githooks-install, Atlassian precedence note); docs/RULESET-OVERVIEW.md §3/§4 (activation columns); bin/lint-section-refs.sh (RE_SKILL + resolve_target → composer/pocock); rules/Meta.md §2.2/§2.3; rules/CleanCode.md (precedence clause); rules/General.md §8.2 (optional override); pocock brainstorm/design-an-interface descriptions (NOT-clauses); "built-in diagnose" mentions (CLAUDE.md:36, pocock/UPDATING.md:10, RULESET-OVERVIEW.md:163) | Bundled per user. Mostly mechanical; decide githooks-install policy (auto vs explicit) as an explicit sub-decision. |
| 2 | P2 | CLAUDE.md (one-line §12 override for this repo) | Trivial. |
| 3 | P3 | core:rule-friction SKILL.md; possibly bin/rule-friction-report.sh (archive step) | Governance pair with Step 4. |
| 4 | P4 | rules/Meta.md §3.2 (demotion review + token budget trip-wire) | Fold in review §B4 checkpoint findings (milestone definition, delegation restriction) if user agrees; review §D notes this interaction. |
| 5 | P1 | rules/General.md §10.2; cross-check /core:batch autonomous-mode section | Carve-outs: confirmed-autonomous + trivial task-start. |
| 6 | P5 | rules/General.md §10.3; core:batch SKILL.md §11.1; pocock:handoff SKILL.md; CLAUDE.md ledger (handoff activation) | Three files + ledger; export sync check. |
| 7 | P6 | rules/General.md §1.5 | State-claims + act-on-hypothesis gate. |
| 8 | P7 | rules/General.md §2.4 (push remote) + §5.2 (push-time clause); optionally githooks template pre-push module | Split rule change vs hook work if needed. |
| 9 | P8 | hookify rule or ~/.claude/hooks/ PreToolUse Bash hook for §5.6 shapes | Soft-block/warn, not hard-block (false positives). |
| 10 | P9 | rules/General.md §4.5 (non-batch recording + replay fallback) + §4.6 (mode trigger) | |
| 11 | P10 | 22 SKILL.md descriptions (per plugin change-sets); CLAUDE.md ledger; rules/General.md §4.5/§12 moves; rules/Persona.md; F5 dup pairs | Largest rebuild; recommend own session; one plugin per change-set; NOT-clauses must survive; re-measure with wc after. |

## Status ledger

| Proposal | Status | Decision / commit | Note |
|---|---|---|---|
| P11 | done | Ja (2026-07-16), Step-1 commit | githooks-install decided **auto** (ledger+frontmatter win; RULESET-OVERVIEW corrected). NOT-clauses written without cross-skill references per user instruction (positive own-scope wording instead). |
| P12 | done | Ja (2026-07-16), Step-1 commit | Live-page note corrected per user: conversion IS possible manually in the UI, just not via MCP. §8.2 override sentence included. Meta §2.2 resolved to speculative-persist+flag with 3 tie-breakers; global CLAUDE.md added as layer. exports/OnlineAgent.md deliberately NOT synced (KB writes are colleague-facing; ask-first stays correct there). |
| P2 | done | Ja (2026-07-16), Step-2 commit | User extension bundled in: §12 gained a generic override-persistence mechanism (project CLAUDE.md/CLAUDE.local.md MAY grant direct commits to a protected branch; agent offers once to persist after a first concrete user authorization). |
| P3 | done | Ja (2026-07-16), Step-3 commit | `--archive` flag added to report script; skill gains archive step + "Effectiveness claims (MUST)" section (≥2 archived windows or label "untested"; per-skill claims need transcript Skill-tool counts). First window archived: `.aiassistant/state/rule-friction/2026-07-16-report.md` (48 sessions, matches the review's evidence base). |
| P4 | pending | | |
| P1 | pending | | |
| P5 | pending | | |
| P6 | pending | | |
| P7 | pending | | |
| P8 | pending | | |
| P9 | pending | | |
| P10 | pending | | |

## Session bootstrap

Read first, in order:
1. This file.
2. `.aiassistant/state/ruleset-critical-review-2026-07-13.md` (findings + proposal content).
3. `docs/RULESET-OVERVIEW.md` §1 (the five vectors, as evaluation frame) — skim.

Then start at the first `pending` ledger row with the process protocol above.
Recommended setting: `/effort high`, model claude-fable-5 (normative rule edits,
high blast radius, precision over speed).
