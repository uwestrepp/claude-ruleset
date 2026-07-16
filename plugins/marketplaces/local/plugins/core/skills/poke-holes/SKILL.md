---
name: poke-holes
description: "Activate via /core:poke-holes or let Claude auto-activate when the user supplies an artifact (plan, proposal, design, assumption-set, spec, or implementation) and asks to critique it, find its flaws, or stress-test it WITHOUT being interviewed. Returns a severity-ranked findings list (Blocking / Material) — never nitpicks, never asks questions, never proposes alternatives. Triggers: '/core:poke-holes', 'poke holes in this <doc/proposal/design>', 'critique this', 'find the flaws in this', 'what's wrong with this plan', 'tear this apart', 'any showstoppers in this?', 'red-team this design'. DOES NOT auto-trigger on routine task phrasing, on 'improve/implement/refactor X', or when no concrete artifact is supplied. Distinct from /core:grill-me (INTERVIEWS you to converge a plan — poke-holes asks nothing), /core:brainstorm (GENERATES alternatives), and code-review/pr-review tools (line-level CODE-diff review — poke-holes operates at the design/claim level). On genuine ambiguity with grill-me, disambiguate before invoking."
argument-hint: "<the artifact to attack — inline text, file path, 'the current plan', or a diff/reference> [tier2] [steelman]"
allowed-tools: [Read, Grep, Glob, Agent]
---

# /core:poke-holes — Adversarial Artifact Critique

## 1. Purpose

Ruthlessly attack a *given* artifact and hand back what would make it fail. The artifact already exists; the goal is to surface its load-bearing flaws, unstated assumptions, edge cases, and failure modes — ranked by severity — so the author can decide what to fix.

Complementary to the other thinking primitives — not a substitute:
- `/core:grill-me` — interviews *you* to converge a plan you are about to build (Q&A, ends in a decision record). poke-holes asks nothing and converges nothing.
- `/core:brainstorm` — generates N divergent candidate approaches. poke-holes generates no alternatives.
- `code-review` / `pr-review-toolkit` — line-level review of a code diff. poke-holes is stack/format-agnostic and works at the design/claim level.
- `advisor` — one strong opinion on your direction. poke-holes is a structured attack, not an opinion.

Use this when an artifact is on the table and the risk is shipping it with a flaw nobody named.

## 2. The materiality floor (MUST)

This skill has **no nitpick bucket**. A finding is reported only if it reaches one of two severities:

- **Blocking** — would cause the artifact to fail its stated goal, produce wrong results, or cause an unsafe/irreversible outcome. Must be resolved before proceeding.
- **Material** — could change the approach, the change-set, the decision, or the resulting risk (per the materiality definition in `General.md`). Worth resolving.

Anything below Material is **not emitted** — not as a "minor" note, not in passing. Cosmetic, stylistic, and preference-level observations are out of scope by design. This is the explicit resolution of the ruthless-vs-trivia tension: ruthlessness is aimed at impact, never at dust.

## 3. Input contract (MUST)

Identify the artifact and its goal before attacking:

- Accept the artifact as inline text, a file path, "the current plan"/a conversation artifact, a diff, or a Jira/Confluence reference (fetch it if MCP is available; otherwise ask the user to paste it).
- Establish the artifact's **goal / success criteria** — a finding is material only relative to what the artifact must achieve. Read it from the artifact if stated; ask exactly one focused question only if the goal is absent and unguessable. (One goal-clarifying question is allowed; sustained interviewing is `grill-me` and out of scope here.)
- If no concrete artifact can be identified → stop and point to `/core:grill-me` (which elicits a forming plan). Do not invent an artifact to critique.

## 4. Method — tiered, scaled to artifact size and risk

Mirror `General.md` §5.2 risk-scaled depth: cheap first, deeper only when warranted.

### 4.1 Tier 1 — blocking-only pass (default)

One ruthless pass for **Blocking** issues only. Return the blocking findings, or state plainly "no blocking issues found". Keep it short.

For plans, proposals, designs, and assumption-sets, Tier 1 is **evidence-demanding**: extract the load-bearing claims, classify each as fact / inference / assumption / unknown (per `General.md` §1.1), and flag any *load-bearing* claim that is unbacked, unverifiable, or unfalsifiable. Severity scales with how much of the artifact rests on the unbacked claim.

### 4.2 Tier 2 — multi-lens panel (on request, or when Tier 1 found a fatal flaw and breadth matters)

Escalate to a multi-lens review adding **Material** findings. Run the lenses (delegate to sub-agents via `Agent` when the artifact is large or lenses are independent):

- **correctness** — does it do what it claims, given its own premises?
- **unstated assumptions** — what must be true that is never stated?
- **edge cases & boundaries** — empty/null/limit/concurrent/partial-failure inputs and states.
- **adversarial misuse** — for ship/deploy artifacts, red-team the deployed behavior: concrete attack path → blast radius. A finding here must be a runnable failure story, weighted by likelihood, not an abstract worry.
- **operational & maintenance** — failure visibility, rollback, idempotency, who maintains it.

Drop or merge duplicate findings across lenses before presenting.

### 4.3 Steelman mode (optional — `steelman`, or for contested/defended artifacts)

Reconstruct the artifact's *strongest* reading first (briefly), then attack only what survives that reconstruction. Discard any finding that only works against a weak misreading. Use when the author is defensive or the artifact is contested, so findings cannot be dismissed as strawmen.

## 5. Finding structure (MUST)

Each finding, terse:

- **severity** (Blocking / Material),
- the **claim, assumption, or decision** it attacks (quote/point to it),
- the **concrete failure scenario** — "when X, then Y" — not an abstract concern,
- *optional* one-line remediation, only when the fix is unambiguous. This skill attacks first; proposing fixes is secondary and never replaces naming the flaw.

## 6. Output discipline (MUST)

- Lead with the verdict: blocking count, or "no blocking issues — N material findings".
- Rank by severity; terse per `General.md` §10.4.
- **Honesty over thoroughness:** distinguish a confirmed flaw from a suspected one, and never manufacture findings to look rigorous — a false-positive finding is itself a failure of this skill. If the artifact is sound at the requested tier, say so; do not invent holes to justify the invocation.
- Apply the same ruthlessness when the artifact is the **agent's own** prior output — no self-protection.
- Colleague-facing exports (Jira/Confluence/PR) in German per `General.md` §8.2; chat in the user's language.

## 7. Anti-patterns (MUST NOT)

- Emitting below-Material / nitpick / cosmetic findings — there is no bucket for them.
- Manufacturing or padding findings to appear thorough.
- Interviewing the user beyond one goal-clarifying question (that is `/core:grill-me`).
- Proposing alternative designs (that is `/core:brainstorm`).
- Line-level code-style review (that is `code-review` / `pr-review-toolkit`).
- Critiquing an artifact that was not actually supplied — refuse and point to `grill-me`.

End of skill.
