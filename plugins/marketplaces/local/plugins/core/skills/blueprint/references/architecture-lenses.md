# Architecture Lenses

Decision-class checklist for `/core:blueprint`. The skill body owns the workflow; this file owns
*what* to decide.

Inverted candidate source: a plan's own text yields the decisions the author already knows about.
These lenses instead expose the ones a plan leaves silently pre-decided.

## Per-lens fields

- **Question** — the silent pre-decision it exposes.
- **Ground first** — what the codebase already settles. If it does, state it as `dictated`
  (SKILL.md §4.4) and do NOT ask.
- **Fires when** — materiality trigger. Only firing lenses are pulled.
- **Failure smell** — the symptom of a wrong call; makes the lens checkable rather than abstract.

## Usage

Ground first, then pull only the lenses whose `Fires when` holds. Typically two to four,
**never all seven**. If none fires, the cut is convention-determined: say so and terminate.
Apply the ones that fire in L1 → L7 order; the order is binding because upstream decisions prune
downstream branches.

---

## L0 Convention grounding (precondition, not a lens)

Establish what the codebase structurally dictates:

- directory / namespace / package cut,
- DI and lifecycle conventions,
- existing layering and its direction,
- how comparable features in this codebase are already cut,
- **which extension mechanism the framework provides for this case** (EventListener, DI
  decoration, middleware, hook, plugin API). Building alongside a provided mechanism is the
  single most expensive avoidable structural mistake in framework codebases.

Output is a statement, not a question. Anything settled here is not an open decision.

---

## L1 Scope boundary and non-goals

- **Question:** What must this explicitly NOT do?
- **Ground first:** existing tickets, a preceding `/core:grill-me` record, neighbours that already
  cover part of it. With a grill record present, this lens is usually inherited, not open.
- **Fires when:** almost always in standalone use. Prunes the most downstream branches.
- **Failure smell:** generic extension points for requirements nobody raised.

## L2 Responsibility split

- **Question:** Which units emerge, and what is the ONE responsibility of each?
- **Ground first:** is there an established cut pattern for this case in the codebase?
- **Fires when:** more than one new unit emerges, or an existing unit grows a foreign responsibility.
- **Failure smell:** a unit's responsibility is not describable without "and".

## L3 Dependency direction

- **Question:** Who knows whom, and who must explicitly not?
- **Ground first:** existing layering, available interfaces, cycles already present.
- **Fires when:** the change adds a new edge between existing units.
- **Failure smell:** a lower layer knows a higher one; or a new cycle appears.

## L4 Boundaries and what crosses them

- **Question:** Which types cross the boundary between the units?
- **Ground first:** does a boundary DTO or contract already exist for this path?
- **Fires when:** a new boundary appears, or a domain type would become externally visible.
- **Failure smell:** internals leak, so every change inside breaks callers.

## L5 State, lifetime, persistence

- **Question:** Who holds state, for how long, and who may mutate it?
- **Ground first:** the framework's DI scoping conventions; existing schema / entity patterns.
- **Fires when:** state outlives a single call, or the data schema is touched.
- **Failure smell:** singleton state mutated per request; a schema only correctable by migration.
- **Note:** for persistence-touching changes the schema decision belongs HERE, not to detail level.
  It is the least reversible decision in this set and ranks first in the reversibility probe.

## L6 Error and edge-case responsibility

- **Question:** Who decides what happens on error / empty / not-found, and what is the outward
  contract?
- **Ground first:** how do same-type neighbours handle it already?
- **Fires when:** more than one defensible behaviour exists (exception, null, empty collection,
  default value).
- **Failure smell:** every caller reimplements the same special case.
- **Note:** deliberately crosses into what looks like implementation detail. The decision feels
  local but is a contract, which is why it belongs in a structural blueprint.

## L7 Expected axes of change

- **Question:** Where will this predictably change, and is the structure soft there?
- **Ground first:** the evidence model below.
- **Fires when:** a change axis is nameable AND evidenced.
- **Failure smell:** bidirectional. Hard where everything changes; abstracted where nothing ever did.

### L7 evidence model (MUST)

The anchor is a **named source**, not git history alone. Admissible, hardest first:

1. git history of the touched areas (retrospectively proven),
2. an already-recorded but unbuilt requirement: backlog / ticket / roadmap item, or a concrete
   planned extension the user names,
3. structural necessity from the domain, not conjecture (an integration point for payment methods
   will see more than one because the business has more than one),
4. analogy to a neighbour in the same codebase that already carries the same axis.

**Inadmissible:** "it could be that ..." without one of the four.

Softness is graded, not binary. Cheapest first:

- **note only** — record the axis, change nothing. Cost zero; makes the later change conscious.
- **place the cut so the change stays local** — no abstraction. Cost near zero. **This is the default.**
- **build an abstraction / extension point** — real cost. Admissible only on evidence kind 1 or 2
  AND more than one known case.

This is the operationalised rule of three, and it is what keeps L7 from producing over-engineering.

---

## Probes

Tests applied to the cut already derived, not decisions in their own right.

1. **Testability** — can each unit be exercised in isolation? "Only end-to-end" means L2 or L3 is wrong.
2. **One-sentence test** — every responsibility describable without "and"? Else L2.
3. **Cycle check** — is the dependency graph acyclic? Else L3.
4. **Reversibility ranking** — which decision taken is hardest to undo? It goes first in the record
   with explicit user acknowledgement.
5. **Known-solution probe** — bidirectional:
   - Is this cut a known solution, or a reinvention of a worse variant?
   - Is a pattern present where straight code would do?

   Admission rule: a pattern name may be introduced only if it **simplifies** the cut (fewer units,
   fewer edges, or it is vocabulary already used in this project). Never if it merely *names* the
   cut you already have. "No pattern, straight code" is an expected answer.

   Deliberately a probe and not a lens: "which pattern fits here?" is a question this model class
   answers eagerly and badly, since any cut admits several plausible-sounding patterns and a named
   pattern reads as an improvement merely for having a name. Pattern knowledge is a model default;
   the brake is what this probe adds. The framework-mechanism variant of this check lives in L0,
   where it is grounded rather than guessed.
