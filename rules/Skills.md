---
paths:
   - "**/SKILL.md"
   - "**/agents/*.md"
---

# Skill and Agent Authoring

A `description:` is not documentation, it is the activation trigger, and it is the only
thing the harness matches a prompt against. Every constraint below was measured with
`claude plugin eval`, not reasoned about. Normative keywords per `General.md`.

Applies to agent descriptions too: same mechanism, same budgeted surface.

Why this is a path-gated rule and not a skill, against the default in `CLAUDE.md`: that
default routes workflow-scoped content to skills so it loads on detected prompt relevance.
The measurements below are precisely that such detection has per-skill margins and misses
legitimate requests. Editing a `SKILL.md` is a mechanical trigger, so the path gate is the
more reliable carrier here, and a path-gated file costs no always-on tokens.

## 1. Activation is a margin, not a switch (MUST)

Every description has a **paraphrase margin**: how far a request may drift from the
description's own vocabulary and still activate. Margins differ per skill and are invisible
until measured. The agent MUST NOT treat "the trigger is listed" as evidence that a
paraphrase of it activates.

Measured 2026-09-03 on three sibling skills with graded paraphrases: `grill-me` held at hard
paraphrase, `poke-holes` broke there, `brainstorm` broke already at moderate paraphrase.

## 2. Language is not the axis (MUST NOT)

The agent MUST NOT assume a missed German prompt means missing German triggers. Falsified:
`commits` activates on "einchecken"/"Betreff" and `git-knowledge` on German recovery
questions, neither lexically present in their English-only trigger lists. The margin is per
skill. Where German trigger phrases ARE added, they MUST carry correct umlauts — an ASCII
substitution does not match what the user types.

## 3. A negative clause can over-suppress (SHOULD)

A `DOES NOT trigger on ...` clause competes with the positive triggers and can win against a
legitimate request. When a description misses a request it claims, the effective repair is
SHOULD-level to sharpen the boundary against its own negative clause, not to add keywords:
name what discriminates the wanted case from the excluded one. Adding keywords widens the
margin marginally; the boundary sentence is what moved the measured result.

## 4. Restraint is also a margin (MUST)

For a skill the ledger marks "explicit activation required", holding back is behavior that
MUST be verified, not assumed. Measured: four of six such skills fire on their own topic
(`composer:update`, `typo3:scanner`, `typo3:static-tests`, `typo3:upgrade-full`); two
restrain (`composer:major-upgrade`, `typo3:upgrade`). Every failure carried a NEGATIVE
ablation delta, so the plugin scored worse than no plugin on that prompt.

The literal phrase predicts nothing: `composer:update` carries it and fires, `typo3:upgrade`
lacks it and restrains. The mechanical alternative is frontmatter
`disable-model-invocation: true`, which costs zero always-on tokens because the budget check
measures only the `description:` line. Before applying it to a skill that another skill
INVOKES (for example the three components of `typo3:upgrade-full`), verify the flag's callee
semantics against a real run — a blanket flag breaks orchestration.

## 5. Descriptions are a budgeted always-on surface (MUST)

Skill and agent descriptions are budgeted in aggregate (`Meta.md` §3.3, enforced by
`bin/lint-section-refs.sh`). Keyword padding is therefore not free, and a boundary sentence
that fixes the margin is usually cheaper than a longer trigger list.

## 6. Test a changed description, and test it for breadth (MUST)

Re-reading a description is not a check (`General.md` §5.2). A new or materially changed
description MUST be exercised with `claude plugin eval` against the plugin's `evals/` suite.

Breadth finds defects, depth only validates numbers. A rerun of the existing case proves
almost nothing: the `brainstorm` case passed three consecutive runs while the defect sat one
phrasing away. So the duty is a SECOND input SHAPE, not another run.

Widening a trigger risks OVER-triggering, so the verification run MUST cover the whole suite,
not the changed case alone: should-NOT-fire cases and sibling negative assertions are what
catch it.

Mechanics, grader anatomy and the run flags live in
`plugins/marketplaces/local/plugins/core/evals/README.md`. Two idioms are load-bearing:
`arm: both` on a `tool_used: Skill` grader, without which it is display-only and never moves
the delta; and `input_match` plus `min: 0, max: 0` to assert that one NAMED skill stayed
quiet.

## 7. Cause stays out of reach (MUST)

The activation decision is not observable — the trace carries inputs and outputs only. A
successful repair is evidence that wider or sharper wording widened the margin, and it is NOT
evidence about the mechanism. The agent MUST label any mechanism claim a hypothesis
(`General.md` §1.5) and MUST NOT present a green case as an explanation.

The eval sandbox loads only the plugin under test: no `CLAUDE.md`, no `rules/`. So the suite
tests descriptions in isolation and cannot reach the `General.md` §9.1 invocation gate at all.
