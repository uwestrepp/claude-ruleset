---
name: blueprint
description: "Decide the structural cut of a change before code exists: which units emerge, who knows whom, what crosses the boundaries, who holds state, what the error contract is. explicit activation required — via /core:blueprint or by accepting the `CleanCode.md` Architectural Cut Gate offer. Produces a reviewable blueprint record, not an interview. Distinct from /core:grill-me (clarifies WHAT to build; blueprint decides HOW it is cut), /pocock:design-an-interface (exactly one module's interface shape; blueprint is cross-module), /pocock:improve-codebase-architecture (finds opportunities in EXISTING code; blueprint precedes code), and /core:poke-holes (attacks a finished artifact, including a blueprint)."
argument-hint: "<the change whose cut is to be decided — or a reference to its plan/ticket>"
allowed-tools: [Read, Grep, Glob, AskUserQuestion, Write, Agent]
---

# /core:blueprint — Structural Cut Decision

*Input (`$ARGUMENTS`): the change whose structure is to be decided, inline or as a reference.*

## 1. Purpose

Decide the structural cut of a change while it is still cheap: before code exists. The output
is a **blueprint record** naming the cut, separating what was genuinely decided from what an
existing convention already dictated, and ranking the decisions by how hard they are to undo.

Typical position in a chain: `/core:grill-me` (what to build) → `/core:blueprint` (how it is
cut) → plan mode (in which steps) → `/core:poke-holes` (attack the result). **Every neighbour
is optional.** This skill MUST work standalone (§4.1, §4.7): requirements may already be clear
so no grill happened, and the record may be filed for later agreement with no plan following.

## 2. When to use (SHOULD)

- The `CleanCode.md` Architectural Cut Gate fired and the user accepted the offer.
- More than one new unit will emerge, or a responsibility boundary moves, or the data schema is touched.
- The user wants to see or steer the structural decisions instead of receiving finished code.

## 3. When NOT to use (MUST NOT)

- One unit's interface shape is the question → `/pocock:design-an-interface`.
- The code already exists and the goal is improving it → `/pocock:improve-codebase-architecture`.
- The cut is fully determined by an existing convention → state that and proceed (`CleanCode.md`).
- A single new class following an obvious local pattern → just do the work.

## 4. Workflow

Procedure by reference (`General.md` §9.3, binding): apply `/core:grill-me` §4.1 (ground before
interrogating), §4.3 (order by dependency), §4.4 (interrogate by materiality) and §4.6
(terminate). Load those sections before applying this section. The deltas below override
grill-me where they conflict.

### 4.1 Ground, and inherit what exists (MUST)

Run L0 of `references/architecture-lenses.md`: what the codebase structurally dictates, including
which extension mechanism the framework already provides for this case.

Inherit rather than re-elicit: if a `/core:grill-me` decision record or a plan exists for this
change, read it and treat its resolved decisions and non-goals as grounded (this covers L1).
If none exists, L1 is an open lens like any other. Delegate broad structure mapping per
`General.md` §11.1 when the codebase is large; the map, not the file dumps, belongs in context.

### 4.2 Select lenses (MUST)

Pull only the lenses from `references/architecture-lenses.md` whose `Fires when` holds.
Typically two to four, **never all seven**. If none fires, terminate immediately with the
statement that the cut is convention-determined. Marching all seven lenses is the failure mode
this rule prevents (`grill-me` §4.6).

### 4.3 Derive one cut (MUST)

Apply the selected lenses in their fixed order (L1 → L7) and derive **one** proposed cut. Do not
present a menu of whole architectures; that is `/core:brainstorm`. Options belong only at the
individual decisions where a real choice exists (§4.4).

### 4.4 Separate decided from dictated (MUST)

This is the load-bearing rule of the skill. For each lens applied, classify:

- **dictated** — an existing convention, framework mechanism, or inherited decision settles it.
  Record it as a statement with its source. It is NOT a decision and MUST NOT be presented as one.
- **decided** — two or more defensible options existed. Name the options, the chosen one, and
  what flips between them.

Never manufacture a rationale for a non-decision. "No real alternative weighed, standard pattern
from `<file>`" is a complete and expected answer. Inventing deliberation the model did not perform
produces apparent insight the user then acts on, which is worse than opacity.

For every `decided` item where the user's preference genuinely changes the outcome, use
`AskUserQuestion` with the concrete options (use `preview` to contrast code or structure shapes).
Batch independent ones into a single call; serialize only genuinely dependent ones
(`grill-me` §4.5).

### 4.5 Run the probes (MUST)

Apply the probes in `references/architecture-lenses.md` §Probes to the derived cut: testability,
one-sentence responsibility, cycle check, reversibility ranking, known-solution probe. A failing
probe sends you back to the lens it names, not into a caveat.

### 4.6 Terminate (MUST)

Stop when the cut is fixed, boundaries are named, dependency direction is fixed, and non-goals
are recorded. Consequences of a cut only fully surface while building, so do NOT chase certainty
past this checklist.

### 4.7 Emit the record, then offer (MUST)

The record is a standalone artifact, not a hand-off note: it MUST be complete enough to decide on
without this session's context (`Meta.md` §2).

Target: `docs/adr/` where the project uses ADRs (follow its numbering). Otherwise
`.aiassistant/state/blueprint-<topic>.md` — committed, never `scratch/`, because architectural
decisions have durable continuation value. Where no ADR convention exists, offer once to
establish `docs/adr/` rather than creating it unasked (`Meta.md` §2.2).

```
# Blueprint: {topic}

## Cut
- {unit} → {single responsibility, one sentence, no "and"}
- dependency direction: {A → B}, and what must NOT know what

## Dictated by convention (not decisions)
- {lens}: {statement} (source: {file/mechanism})

## Decided
- {lens}: {choice} — alternatives {options}, what flips: {consequence}

## Hardest to reverse (descending)
1. {decision} — {why, what undoing it would cost}

## Probes
- {probe}: {result}

## Open / deferred
- {item} — why it is safe to decide later
```

Then offer, do not assume: proceed to plan mode / implementation, `/core:poke-holes` on the
blueprint, or file it here and stop.

## 5. Anti-patterns (MUST NOT)

- Presenting a `dictated` item as a decision, or inventing a rationale for a non-decision (§4.4).
- Running all seven lenses regardless of trigger (§4.2).
- Offering several whole architectures instead of one cut with per-decision options (§4.3).
- Requiring a preceding `grill-me` or a following plan (§1, §4.1, §4.7).
- Writing the record to `.aiassistant/scratch/`, or creating `docs/adr/` unasked (§4.7).
- Naming a design pattern that only labels the cut instead of simplifying it (lenses §Probes).
- Building an abstraction for a change axis with no admissible evidence (lens L7).

---

End of skill.
