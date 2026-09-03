---
name: brainstorm
description: "Use when the user explicitly asks for diversity/alternatives/hypotheses — genuine exploration where diversity is the goal. Triggers: 'brainstorm N approaches/alternatives/hypotheses', 'give me distinct ways to', 'list debugging hypotheses for', 'explore design alternatives for', 'what are different angles for', 'use verbalized sampling', 'welche grundsätzlich verschiedenen Wege/Ansätze gibt es', 'zeig mir die Bandbreite'. A request for the RANGE of options counts even as a question and even without the word 'brainstorm'; the discriminator against 'how do I solve X' is whether several options are wanted rather than one answer. DOES NOT trigger on generic 'how do I solve X' or routine task-execution phrasing, nor on converged decisions where the agent should answer directly. NOT for deciding one module's interface/API shape by comparing concrete designs, NOT for building runnable prototypes — brainstorm returns a ranked list of candidate approaches, not designs or code."
argument-hint: "[n=5] <question or topic>"
allowed-tools: [Read, Grep, Glob, Agent]
---

# /core:brainstorm — Verbalized-Sampling Brainstorming

*Input (`$ARGUMENTS`): the question or topic to explore, optionally prefixed `n={count}`.*

## 1. Purpose

This skill provides a deliberate, scoped brainstorming primitive based on the *verbalized sampling* technique: surface N distinct candidate approaches in parallel — not the single most-likely-correct answer — then condense to a ranked shortlist using an explicit rubric.

Complementary to the existing `advisor` pattern:
- `advisor` returns ONE strong opinion from a stronger reviewer with full conversation context.
- `/core:brainstorm` returns N diverse candidates from a generator sub-agent, judged on a rubric.

Use `/core:brainstorm` when diversity is the goal. Use `advisor` when a second strong opinion is the goal. They are not substitutes.

---

## 2. When to use (SHOULD)

Invoke for:
- design alternatives ("what are the different ways to structure X?"),
- debugging hypotheses ("what could plausibly cause this failure?"),
- test-case diversity ("what distinct cases should this test cover?"),
- code-review angles ("what classes of issue should reviewers look for here?"),
- architectural tradeoff exploration before committing to one approach.

---

## 3. When NOT to use (MUST NOT)

Do NOT invoke for:
- routine task execution ("fix this bug", "implement this function", "rename this") — converge directly on the right answer,
- single-best-answer problems where the correct solution is narrow (e.g. "what's the idiomatic PHP 8.4 syntax for X?"),
- decisions already converged earlier in the conversation,
- trivial questions where a single direct answer is faster than generation + judging.

If invocation seems borderline, ask the user once whether they want exploration or convergence before proceeding. Do not auto-trigger on generic "how do I solve X" phrasing.

---

## 4. Workflow

### 4.1 Confirm exploration-worthiness (MUST)

Before sampling, verify the question is genuinely exploration-worthy:
- Is there plausibly more than one acceptable approach?
- Is the user asking for diversity, or for a single best answer?

If unclear, ask one focused clarifying question. If the question converges to a single right answer, say so and answer it directly rather than running the skill.

### 4.2 Determine N (SHOULD)

Default `N = 5`. Acceptable range 3–7.

- narrow question space → `N = 3`,
- open-ended brainstorming → `N = 7`.

Higher N rarely improves the final shortlist — the judge step collapses near-duplicates anyway.

### 4.3 Generate via sub-agent (MUST)

Delegate generation to a sub-agent (default `general-purpose`) using the prompt template in §5. The sub-agent MUST be briefed to:
- produce N **distinct** approaches (not minor variations),
- include rationale, confidence (low/medium/high), main tradeoff per approach,
- return structured YAML output suitable for the judge step.

Do not perform generation inline in the main context — that defeats the diversity goal (RLHF mode collapse pulls inline output toward a single mode) and burns visible tokens.

### 4.4 Condense with rubric (MUST)

Apply the rubric in §6 to score each candidate, then condense to a ranked shortlist (top 2–3). Drop or merge near-duplicates. Condensation happens in the main context using the sub-agent's structured output.

### 4.5 Present (MUST)

Present the shortlist with:
- ranked order,
- one-line rationale per approach,
- decisive tradeoff for the top pick,
- explicit next-step prompt (proceed with #1, discuss #2/#3, or regenerate).

Do not silently pick #1 and start implementing. Brainstorming is exploration; commitment is a separate user decision.

---

## 5. Generation prompt template (sub-agent briefing)

Substitute `{N}`, `{QUESTION}`, `{CONTEXT}`:

```
Generate {N} DISTINCT candidate approaches to the following question. The goal is
diversity — surface approaches a default greedy answer would miss. Avoid minor
variations on a single underlying approach.

Question: {QUESTION}

Context: {CONTEXT}

For each approach, output a YAML record in this shape:

- id: approach-N
  name: {short label, 2-5 words}
  summary: {one sentence}
  rationale: <2-3 sentences — why this approach, what problem it actually solves>
  confidence: {low | medium | high}
  main_tradeoff: {the single sharpest cost or risk}
  distinct_from_others: {one sentence: what makes this NOT a variant of approach-1..N-1}

Return ONLY the YAML list. No preamble, no commentary.
```

The `distinct_from_others` field forces active differentiation rather than paraphrase.

---

## 6. Judging rubric

Score each candidate on four dimensions (1–3 each, 12 max):

- **Viability** (1–3): does the approach actually work for the stated constraints? `1` = plausible but unproven, `3` = proven idiom for this problem class.
- **Distinctness** (1–3): how different is it from the others? `1` = near-duplicate of another candidate, `3` = genuinely different mechanism.
- **Fit** (1–3): how well does it match the stated context (codebase conventions, target version, scope)? `1` = generic, `3` = tailored.
- **Cost** (1–3, inverted): implementation and maintenance cost. `1` = high cost or complexity, `3` = low cost, minimal blast radius.

Shortlist rule:
- keep candidates scoring **≥ 9**, OR
- scoring **≥ 7 with at least one `3`**,
- always keep the highest-distinctness candidate even if its overall score is mid-range — that's the contrarian option worth surfacing.

If two candidates score within 1 point of each other AND share two dimensions of strength, merge them and note the synthesis.

---

## 7. Output format

Final user-facing output, compact:

```
Brainstorm (N={N}, judged):

#1 {name} — score X/12
   {one-line rationale}
   Tradeoff: {decisive cost}

#2 {name} — score Y/12
   {one-line rationale}
   Tradeoff: {decisive cost}

#3 {name} — score Z/12 (contrarian)
   {one-line rationale}
   Tradeoff: {decisive cost}

Next: proceed with #1, discuss #2/#3, or regenerate?
```

Detailed per-candidate rationale stays in the sub-agent's output; surface on request.

---

## 8. Anti-patterns (MUST NOT)

- Auto-invoking on any "how do I" question. This skill activates only on explicit diversity/exploration triggers (see description), not on generic task-execution phrasing.
- Generating N inline in the main context — defeats diversity and wastes visible tokens.
- Picking #1 silently and implementing. Always present the shortlist and prompt.
- N > 7. Diminishing returns; the judge collapses near-duplicates anyway.
- Using for converged questions. If the right answer is narrow, just answer it.
- Replacing `advisor` with this skill. Different tools, different goals.

---

End of skill.
