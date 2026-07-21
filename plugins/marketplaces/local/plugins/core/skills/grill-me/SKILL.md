---
name: grill-me
description: "Activate via /core:grill-me or let Claude auto-activate when the user asks to pressure-test or interrogate a plan/design they are still forming, BEFORE building — by being interviewed, not by receiving a critique. Triggers: '/core:grill-me', 'grill me on', 'help me firm up my plan', 'interview me about this design', 'pressure-test this approach', 'what am I missing', 'challenge my assumptions', 'stress-test the plan before we build'. DOES NOT auto-trigger on routine task start, on 'implement/fix/refactor X', or on a converged plan the user has already decided to execute — fires only on explicit plan-critique intent. Distinct from /core:poke-holes (attacks an already-supplied artifact and returns findings WITHOUT interviewing — use that when an artifact exists and no Q&A is wanted) and /core:brainstorm (generates N divergent candidates) — grill-me interviews to converge a single plan."
argument-hint: "<the plan, design, or topic to grill — or reference to it>"
allowed-tools: [Read, Grep, Glob, AskUserQuestion, Write]
---

# /core:grill-me — Adversarial Plan Elicitation

*Input (`$ARGUMENTS`): the plan or design to grill, inline or as a reference.*

## 1. Purpose

Pressure-test a plan by resolving its *material, decision-altering* uncertainties in dependency order, before any code is written. The goal is convergence: turn a half-formed plan into a spec where every load-bearing decision is either resolved or recorded as an explicit assumption.

Complementary to the other thinking primitives — not a substitute:
- `advisor` — ONE strong opinion on the direction you already have.
- `/core:brainstorm` — N divergent candidate approaches when diversity is the goal.
- `/core:grill-me` — convergence on ONE plan by interrogating its decision points.

Use this when the plan exists but is soft, and the risk is building the wrong thing because an assumption went unexamined.

---

## 2. When to use (SHOULD)

Invoke when the user wants a forming plan stress-tested *by interview* before execution (for critique of an already-supplied artifact without interview, use `/core:poke-holes`):
- "interview me until we agree on what to build",
- "help me firm up this plan before I start",
- "what am I missing before I start",
- "challenge my assumptions about X",
- pre-implementation design reviews where the cost of a wrong decision is high.

---

## 3. When NOT to use (MUST NOT)

Do NOT invoke for:
- routine task start or execution ("fix this bug", "implement this function", "rename X") — just do the work,
- a plan the user has already decided to execute and only wants carried out,
- questions answerable directly from the code without any user input — read and answer, don't interview,
- trivial scope where a single clarifying question (General.md §10.1) suffices — ask it inline, don't run the skill.

If invocation is borderline, ask once whether the user wants the plan *grilled* or *executed*. Do not auto-fire on generic task phrasing.

---

## 4. Workflow

### 4.1 Ground before interrogating (MUST)

The user is fallible (General.md "User Is Fallible"); the codebase is the source of truth. Before asking anything, read what the code can already answer:
- locate the files, modules, and contracts the plan touches,
- confirm versions/toolchain/conventions in scope (General.md §2),
- note where the plan's stated facts and the actual code diverge.

Anything the code answers is NOT a question for the user — it is a finding to surface. Only genuine unknowns (intent, priorities, external constraints, business rules not in the repo) become interview questions. Grounding-first is what separates this skill from typing "interview me".

### 4.2 Enumerate decision points (MUST)

Extract the plan's load-bearing decisions — the choices that, if made differently, would change the design, scope, or risk. Discard cosmetic choices. For each, note what it depends on.

### 4.3 Order by dependency (MUST)

Build the decision tree: topologically sort decisions so upstream choices are resolved before the downstream choices that depend on them. Resolving an upstream decision often prunes whole downstream branches — do not ask a question whose relevance hinges on an unresolved parent.

### 4.4 Interrogate by materiality (MUST)

Walk the ordered decisions. For each, apply the materiality test (General.md §10.1): ask ONLY if the answer would change the recommended approach, the change set, or the risk. For each question:
- state why it matters (what flips depending on the answer),
- offer your own recommended default and reasoning — grilling is not interrogation-for-its-own-sake; a sharp default the user can accept or reject moves faster than an open prompt,
- record the answer and propagate its consequences to downstream decisions immediately (a resolved parent may close or reopen children).

### 4.5 Cadence — batch vs. serialize (SHOULD)

- Use `AskUserQuestion` (up to 4 options) for **independent** decisions that can be resolved in parallel in one turn.
- Serialize only **genuinely dependent** decisions, where the next question's content depends on this answer.
- Do not march one-by-one through questions that could have been batched — that is the "relentless" failure mode, and it is exhausting without being more rigorous.

### 4.6 Terminate (MUST)

Stop when **no unresolved decision would still change the design** — i.e. every remaining open item is either (a) resolved, (b) an explicit, recorded assumption the user accepts, or (c) immaterial. State that the termination condition is met. Do NOT grill "relentlessly" past this point; continued questioning past convergence is noise, not diligence.

### 4.7 Emit the decision record (MUST)

Convergence that lives only in chat evaporates (Meta.md §2 knowledge persistence). At the end, produce a written record and tell the user where it is. Default location: the plan/topic's own doc, or `.aiassistant/scratch/grill-{topic}.md` (transient) — promote to `.aiassistant/state/` only if it has durable continuation value. Ask if the target scope is ambiguous (Meta.md §2.2). The record contains:

```
# Grill: {topic}
## Resolved decisions
- {decision} → {choice} (rationale)
## Stated assumptions (accepted, unverified)
- {assumption} — revisit if {condition}
## Rejected alternatives
- {option} — why dropped
## Open / deferred
- {anything explicitly punted, with why it's safe to defer}
```

Then offer the next step: proceed to `EnterPlanMode`/implementation, or grill a remaining branch.

---

## 5. Question-quality bar (MUST)

Every question must pass: *"If the user answered either way, would my recommended plan actually differ?"* If no, don't ask it — answer it from the code, assume a stated default, or drop it. Prefer questions that:
- expose a hidden dependency or ordering constraint,
- force a priority/tradeoff the user hasn't articulated (cost vs. time vs. completeness),
- surface an assumption the plan silently relies on,
- pin down a boundary, failure mode, or success criterion.

Avoid questions that merely confirm what the code shows, restate the plan, or chase cosmetic detail.

---

## 6. Anti-patterns (MUST NOT)

- Interviewing the user on facts the codebase already answers — ground first (§4.1).
- "Relentless" one-by-one questioning past the termination condition (§4.6) — convergence ends it.
- Asking everything ("every aspect") instead of only material decisions (§5).
- Serializing questions that could be batched via `AskUserQuestion` (§4.5).
- Ending in chat with no written decision record (§4.7).
- Auto-firing on routine task start or execution phrasing (§3).
- Replacing `advisor` or `/core:brainstorm` — different goals (§1).

---

End of skill.
