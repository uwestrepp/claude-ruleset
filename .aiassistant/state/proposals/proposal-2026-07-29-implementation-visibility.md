# Proposal: Implementation Visibility (pairing mode vs. architecture grill)

Date: 2026-07-29.
Status: **Part A (architecture pre-flight) DECIDED AND BUILT as `/core:blueprint`, see §9.
Part B (always-on pairing mode) remains proposal only, nothing built.**
Origin: user observation that the plan-then-implement default makes the *genesis* of
implementation decisions opaque, and that being "closer to" those decisions is
sometimes wanted (accompanying them, or merely seeing them).

Two candidate answers are on the table and are NOT substitutes for each other:
(A) a pre-flight architecture grill, (B) an always-on pairing mode. This document
records both, the landscape they sit in, and the findings against (B).

---

## 1. The stated need

Verbatim intent, decomposed:

1. "closer to the decisions the agent makes while implementing certain tasks"
2. "the implementation itself is fairly / fully opaque in its genesis"
3. "sometimes I would like to resolve it more finely, accompany it, or just see it"
4. proposed shape: pair-programming skill, always-on until switched off (caveman-like),
   with levels: 1 architecture (cross-class), 2 structure (class detail, functions),
   3 detail (inside functions, code structure, control structures)

Note the two distinct modes hidden in (3): **accompany** (blocking) and **just see**
(non-blocking). They have very different cost and failure profiles (see §5, B3).

---

## 2. Landscape: what already exists

| Primitive | Timing | Scope | Interaction mode |
|---|---|---|---|
| Plan mode (native) | before | whole task | agent proposes, user approves once |
| `/core:brainstorm` | before | one open question | N divergent candidates |
| `/core:grill-me` | before | one forming plan, domain-agnostic | interview, converges to a decision record |
| `/pocock:grill-with-docs` | before | plan vs. domain model / ADRs | interview + inline doc update |
| `/core:poke-holes` | before or after | one given artifact | critique, asks nothing |
| `/pocock:design-an-interface` | before | **exactly one module**, interface shape | N parallel designs, compared |
| `/pocock:prototype` | before | design explored via throwaway runnable code | build to learn |
| `/pocock:improve-codebase-architecture` | after | **existing** codebase | find deepening/refactor opportunities |
| `/core:batch` §5.3 / §9.3 | during | Pass-3 items inside a batch cycle | per-item approval, mandatory |
| `advisor` (referenced) | before | direction already held | one strong opinion |

Referenced-but-absent: `advisor` is cited as a sibling primitive by `/core:brainstorm`,
`/core:grill-me`, `/core:poke-holes` and the composer skills, but exists neither as a
skill nor as an agent in this repo. Separate rule-set finding, out of scope here.

### 2.1 Two genuine gaps

**Gap 1 (pre-flight, structural):** no primitive decides how work is *cut* across
several classes/modules: responsibility split, dependency direction, boundaries and
seams, extension points, what deliberately stays out.
`design-an-interface` is explicitly scoped to one module. `grill-me` is
domain-agnostic and carries no architectural vocabulary.
`improve-codebase-architecture` works on code that already exists.
=> This is the user's "grill-with-architecture" intuition. **Confirmed as a real gap.**

**Gap 2 (during implementation):** nothing covers decisions made *while* writing code,
outside an active `/core:batch` cycle. Plan mode and the grills all sit strictly before.
=> This is the original pairing need. **Also a real gap, but far harder to fill (§5).**

---

## 3. Key decomposition insight

Decision layers differ in whether they can be settled *in advance*:

| Layer | Settleable pre-flight? | Right form |
|---|---|---|
| 1 architecture (cross-class cut, dependency direction) | yes, largely exhaustively | pre-flight artifact (Gap 1). Cheap, no drift risk. |
| 2 structure (class detail, function signatures) | partly. Signatures yes (`design-an-interface`), internal split no | mixed |
| 3 detail (inside functions, control flow) | no. These decisions only come into existence as the code is written | only an always-on mechanism (Gap 2) |

Consequence: the level axis in the original proposal is not one mechanism at three
depths. **Level 1 wants a different mechanism than level 3.** Filling Gap 1 with a
pre-flight skill removes the cheap, robust third of the need and leaves a smaller,
sharper residual gap. That is the argument for doing (A) first, not for doing it
*instead of* (B).

---

## 4. Proposal A: architecture-level pre-flight

Fills Gap 1. Decide the cut before code exists.

Content it must carry (none of it present in `grill-me` today): responsibility split,
dependency direction and acyclicity, boundaries/seams and what crosses them, where
change is expected (extension points), explicit non-goals, mapping onto the codebase's
existing structural conventions.

Three implementation options:

- **A1 new skill** `/core:grill-architecture`, interview-shaped like `grill-me` but with
  architectural lenses. Clearest discoverability. Costs always-on description budget
  (`Meta.md` §3.3) and duplicates most of grill-me's machinery.
- **A2 extend `design-an-interface` to multi-module.** "Design it twice" transfers very
  well to cut decisions: parallel sub-agents cut the same scope differently, then
  compare. The one-module limit is convention, not mechanism. Strongest mechanism,
  medium cost, risks blurring a currently sharp skill.
- **A3 add an architecture lens reference to `grill-me`**
  (`references/architecture-lenses.md`, loaded only when scope is architectural).
  Zero description-budget cost, progressive disclosure, immediately testable.

**Initial recommendation: A3 first, A2 as the upgrade path if A3 proves too thin.**
Rationale: after two or three real uses it is empirically answerable whether a dedicated
skill is warranted, instead of guessing up front.
**Superseded by §7.5 after the feasibility check. A1 is now the recommendation.**

**Open mechanism question for A:** `grill-me` does not auto-trigger on "implement X".
If the user must remember to invoke it, the need ("I do not want to have to think about
it") is only half met. An auto-suggest trigger is probably required: propose the
architecture pass when a task will create several new classes/modules or move a
responsibility boundary. Auto-suggest, never silent activation.

---

## 5. Proposal B: always-on pairing mode, and the findings against it

Fills Gap 2. Reviewed 2026-07-29; four findings are blocking for the *design as
proposed*, not for the idea.

**B1 (blocking) "Always on" cannot be prompt-only; caveman is a misleading model.**
Caveman persists because it governs *output style*: every response is its own reminder,
the agent sees its own caveman tone in context and continues it. A decision gate governs
*actions*, where no such self-reinforcing signal exists and the counter-attractor
(task-completion drive) is strong. Drift after roughly 15 to 20 implementation turns is
expected. Worse: the SKILL.md body is ordinary context, not an `@`-imported always-on
rule, so after compaction the mode is effectively gone.
This failure is **fail-silent**: the user relies on being asked and simply is not asked.
A mechanical anchor is required. Verified-on-this-host options: a state file plus a
`UserPromptSubmit` hook re-injecting mode and level via `additionalContext` every turn
(survives compaction), optionally `PreToolUse` on `Edit|Write` with
`permissionDecision:"ask"` as a backstop. The hook is the value; the skill is its prose.

**B2 (blocking) The level axis is the wrong axis.**
Architecture/structure/detail is "abstraction level of the decision"; the actual need is
selectivity by *consequence*. They correlate poorly: "new class in an existing namespace
following an existing pattern" is level 1 and trivial; "which of three behaviours on an
empty result" is level 3 and the one decision worth seeing. A level filter systematically
gates the wrong things. Additionally, level 3 is cumulative by necessity (otherwise it
would wave architecture through) and therefore unusable: dozens of gates on a 200-line
change, switched off within ten minutes.
Better: the gate *trigger* is "several defensible options / irreversible / not fixed by
codebase convention"; the level is the *threshold* on that scale. Abstraction level may
remain a scope filter, not the sole criterion.

**B3 (blocking) The missing axis: see vs. co-decide.**
- `observe`: agent verbalises decisions as it goes, never blocks. No round trip, cheap,
  and **fail-visible** (if it stops, the user notices immediately).
- `gate`: agent stops and asks. One round trip per decision.

Suspected to cover most real cases: `observe`. This axis is orthogonal to the level and
more important than it.

**B4 (blocking) Forced verbalisation produces post-hoc rationalisation.**
Some of what would be called a "decision" is not a weighed choice but falls out of
sampling. A blanket "justify your decision" requirement manufactures plausible reasons
for deliberations that never happened, and the user then decides on that apparent
insight. Worse than opacity. The skill must explicitly permit and require
"no real alternative weighed, standard pattern from `<file>`" as a complete answer, and
gate only where two nameable options genuinely exist.

**M1 Conflict with `General.md` §8.4, which the always-on rule wins.**
§8.4 mandates minimal narration of routine compliance; an `observe` mode violates it
literally. Since §8.4 is always-on and the skill body is not, the agent resolves the
conflict against the skill, silently. An explicitly scoped suspension is required
("while pairing is active, §8.4 does not apply to decision rationale") plus a
`CLAUDE.md` ledger entry. Weaker but present for §10.1/§10.4.

**M2 Sub-agent hole.** Sub-agents do not see the mode, so delegated implementation
bypasses the gate entirely, while `General.md` §11.1 *mandates* delegation for bounded
work. Resolution needed: either no implementing delegation while gating, or mode carried
into the briefing (§11.2) with gate escalation back to the main agent.

**M3 Overlap resolution is mandatory (`Meta.md` §3.2).** Four neighbours: `/core:batch`
§5.3/§9.3 (already has per-item approval including a presentation format), `/core:grill-me`,
Plan mode, permission mode `default` (native file-level gate). Without a precedence rule,
batch plus pairing yields double gates. Suggested: batch stays owner of the format,
pairing only shifts pass assignment upward.

**M4 `AskUserQuestion` should be mandated over free text.** Structured options cut the
per-gate round-trip cost substantially and `preview` can show concrete code variants side
by side. This is what makes level 2/3 bearable at all.

**M5 Two open specification questions.** Persistence reach: session-scoped or across
sessions? Across sessions needs a state file plus an extension of the existing
`SessionStart` hook; session-scoped must be stated loudly or it creates false safety.
Escape ergonomics: without a per-step opt-out the user fights the skill on trivial edits.

**M6 Timing conflict in the PreToolUse backstop.** An `ask` on `Edit` fires after the
decision is made and the code written. That is rubber-stamping, not accompanying.
Valuable as a drift backstop, wrong as the primary mechanism.

---

## 6. Suggested sequencing

1. **A3** (architecture lenses on `grill-me`) plus its auto-suggest trigger. Cheapest,
   fills the confirmed Gap 1, zero always-on budget.
2. **B in `observe` mode only.** Cheap, fail-visible, and it produces the empirical
   record of which decisions the user actually wants gated.
3. **B gate levels**, defined on that record rather than guessed, with the hook anchor
   from B1 and the precedence rules from M1/M2/M3.

Deliberately not decided here: whether step 3 ever happens. Steps 1 and 2 may well
absorb the need.

---

## 7. Feasibility check: architecture mode in `grill-me` (A3), 2026-07-29

Checked `grill-me/SKILL.md` (128 lines, no `references/` yet) against the requirement.
Verdict: **feasible, and a better fit than expected, but the auto-suggest trigger does
not belong in the skill.**

### 7.1 What fits without change

The skill's workflow is a generic procedure: ground (§4.1), enumerate load-bearing
decisions (§4.2), topologically order (§4.3), interrogate by materiality (§4.4),
terminate (§4.6), emit decision record (§4.7). That procedure is architecture-agnostic
and needs no modification. Architecture is a *decision-candidate* problem, not a
procedure problem.

What is missing is only the candidate source. §4.2 extracts decisions *from the plan the
user supplied*. For architecture that inverts: the point is precisely that the user does
not know which cut decisions are open, otherwise they would already be "close to" them.
So the mode needs a checklist of architectural decision classes to test the plan against:
responsibility split, dependency direction and acyclicity, boundaries/seams and what
crosses them, expected axes of change (extension points), explicit non-goals, mapping
onto existing structural conventions.
=> `references/architecture-lenses.md`, loaded only in architecture mode. Progressive
disclosure keeps the body small. Clean fit into §4.2 as a mode-specific candidate source.

### 7.2 Blocking finding: the trigger cannot live in the skill

Two problems, one structural:

1. **Direct conflict with the skill's own prohibitions.** §3 MUST NOT: "routine task
   start or execution ('fix this bug', 'implement this function', 'rename X'), just do the
   work". §6 anti-pattern: "auto-firing on routine task start or execution phrasing".
   The requested trigger fires on exactly that situation. An exception must be worded so
   it does not hollow out §3. The separating line that works: §3 forbids firing on
   *phrasing*; the new trigger fires on *established structural scope*, i.e. after
   grounding the agent determines that the change introduces several new classes/modules
   or moves a responsibility boundary. Phrasing vs. post-grounding structure is a sharp
   boundary.
2. **Mechanism problem (the blocking one).** Skills activate via their `description`,
   which is always-on context; the body is loaded only *after* activation. A trigger
   written into the body is therefore never read in the case that needs it. And putting
   it in the description does not work reliably either: at prompt time "implement feature
   X" does not reveal whether one or five classes will result. The trigger can realistically
   only fire *after* grounding or plan formulation, at which point the skill is not loaded.

**Resolution: put the trigger in the rules, modelled on `General.md` §3.5.** §3.5 is an
existing, working precedent for exactly this shape: "When a task starts small but grows
into a larger-scale operation, the agent MUST interrupt and propose activating
`/core:batch` (auto-suggest gate, never silently activate)." An architecture analogue:
before applying a change that introduces several new classes/modules or relocates a
responsibility boundary, name the intended cut and offer the architecture pass.
`CleanCode.md` (path-gated to code files) is the natural host, so it costs no always-on
budget. Rejected alternatives: description-only (unreliable, see above), `PreToolUse` hook
on `Write` (too late, the file is already being written, and it cannot see class count in
advance).

### 7.3 Non-blocking adjustments needed

- **§4.7 record target is wrong for architecture.** Default is
  `.aiassistant/scratch/` (transient). Architectural decisions have durable continuation
  value: target `docs/adr/` where the project uses ADRs (cf. `/pocock:grill-with-docs`),
  otherwise `.aiassistant/state/`, never scratch.
- **`allowed-tools` lacks `Agent`.** Architecture grounding (§4.1) is far more expensive
  than for a feature plan: it needs a structure map, not a few files. `General.md` §11.1
  mandates delegation for exactly this. `/core:poke-holes` already carries `Agent`.
- **§1 sibling list omits `/pocock:design-an-interface`.** With an architecture mode the
  boundary becomes load-bearing (one module vs. cross-module cut) and must be stated.
- **§4.6 termination is weaker for architecture**, since consequences only surface while
  building. Needs a fallback checklist: cut fixed, boundaries named, dependency direction
  fixed, non-goals recorded.

### 7.4 Resulting change set (not applied)

1. `rules/CleanCode.md`: §3.5-style auto-suggest gate for architectural scope.
2. `grill-me/references/architecture-lenses.md`: new, the decision-class checklist.
3. `grill-me/SKILL.md`: mode hook in §4.2, architecture record target in §4.7, `Agent` in
   `allowed-tools`, sibling boundary in §1, termination fallback in §4.6.
4. `CLAUDE.md`: ledger boundary line touched only if the skill's description changes.
5. `agnix` validation on all touched skill/rule files (pre-commit hook).

### 7.5 Revised recommendation: A1 (separate skill), not A3

Two facts established by the §7 check reverse the §4 recommendation.

**Fact 1: relocating the trigger removes both arguments against a separate skill.**
Per §7.2 the trigger must live in `CleanCode.md` and name the skill explicitly. A skill
reached that way does not need an auto-activating description with an extensive trigger
list. It can be "explicit activation required" (`General.md` §9.1), which
(a) shrinks the always-on description cost to roughly half of a grill-me-sized one
(measured: grill-me 920 chars, poke-holes 1019, brainstorm 791, driven mostly by trigger
lists and delimitation clauses), and (b) removes the §3/§6 activation conflict entirely
instead of encoding an exception to it.
Note on budget: the `bin/lint-section-refs.sh` BUDGETS table covers only `rules/General.md`,
`rules/Meta.md`, `rules/Persona.md` and `CLAUDE.md`. Skill descriptions are part of the
`Meta.md` §3.3 demotion-review surface but are NOT mechanically budgeted, so a new skill
is a real always-on cost without being a trip-wire.

**Fact 2: four of six workflow steps branch by mode.** Candidate source inverts (§4.2:
extract from the supplied plan vs. test against a checklist), grounding cost and
delegation need differ (§4.1), termination criterion differs (§4.6), record target differs
(§4.7). A3's core claim was "cheap and additive"; the check shows a rebuild with mode
branches across most of the body. At that ratio it is not a mode, it is a second skill
sharing a procedure.

**What still argues against A1, honestly:** disambiguation load. `grill-me`,
`grill-with-docs`, `poke-holes`, `brainstorm`, `design-an-interface` already spend
substantial description text on mutual delimitation; a sixth neighbour raises confusion
risk more than linearly. Mitigation: explicit activation means the skill is not competing
for auto-activation in the first place.

**Procedure duplication is not a real cost:** `General.md` §9.3 makes skill-to-skill
normative references a governed mechanism ("Apply <file> §X" carries the same binding
force as inline rules). The architecture skill references `grill-me` §4.1 to §4.6 for the
procedure and carries only its deltas: lens list, record target, termination fallback.
Expected size well under grill-me's 128 lines.

**Resulting form:** `/core:grill-architecture`, explicit activation required, procedure by
reference to `grill-me`, own `references/architecture-lenses.md`, `Agent` in
`allowed-tools`, suggested by the new `CleanCode.md` gate. `grill-me` itself then needs
only one change: the sibling boundary in §1.

---

## 8. Draft content for `architecture-lenses.md`

Status: draft, user-reviewed 2026-07-29 (count of seven accepted, L6 accepted,
pattern probe and L7 evidence model added on user challenge). Not yet written as a file.

### 8.1 Per-lens format (four fields)

`Question` (the silent pre-decision it exposes) / `Ground first` (what the codebase
already settles: if it does, state it, do NOT ask; this is the §5 B4 countermeasure) /
`Fires when` (materiality trigger, prevents marching all lenses per `grill-me` §4.6) /
`Failure smell` (the symptom of a wrong call, makes the lens checkable).

Usage rule: ground first, then pull only the lenses whose `Fires when` holds. Typically
two to four, never all seven. If none fires, the cut is convention-determined and the
skill terminates with that statement.

### 8.2 L0 Convention grounding (precondition, not a lens)

What the codebase structurally dictates: directory/namespace cut, DI conventions, existing
layering, how comparable features are cut, **and which extension mechanism the framework
provides for this case** (EventListener, DI decoration, middleware, hook). Output is a
statement, not a question. Anything settled here is not an open decision.

### 8.3 The seven decision classes (topologically ordered, order is binding)

| # | Question | Ground first | Fires when | Failure smell |
|---|---|---|---|---|
| L1 | What must this explicitly NOT do? | existing tickets, neighbours already doing it | almost always; prunes the most downstream branches | generic extension points for requirements nobody raised |
| L2 | Which units emerge, and what is the ONE responsibility of each? | is there an established cut pattern for this case? | more than one new unit, or an existing unit grows a foreign responsibility | a unit's responsibility is not describable without "and" |
| L3 | Who knows whom, and who must explicitly not? | existing layering, interfaces, current cycles | the change adds a new edge between existing units | a lower layer knows a higher one; or a new cycle |
| L4 | Which types cross the boundary between units? | does a boundary DTO/contract already exist for this path? | a new boundary appears, or a domain type would become externally visible | internals leak, so every inside change breaks callers |
| L5 | Who holds state, for how long, who may mutate it? | framework DI scoping conventions, existing schema/entity patterns | state outlives one call, or the data schema is touched | request-mutated singleton state; a schema only fixable by migration |
| L6 | Who decides what happens on error/empty/not-found, and what is the outward contract? | how do same-type neighbours handle it already? | more than one defensible behaviour exists (exception, null, empty result, default) | every caller reimplements the same special case |
| L7 | Where will this predictably change, and is the structure soft there? | see §8.5 evidence model | a change axis is nameable AND evidenced | bidirectional: hard where everything changes; abstracted where nothing ever did |

Note on L5: for persistence-touching changes the schema decision belongs to this lens, not
to detail level. It is the least reversible decision in the set.
Note on L6: deliberately crosses into what the user originally called level 3. The decision
feels like a detail but is a contract. Retained on explicit user decision.

### 8.4 Probes (tests on the decisions taken, not decisions themselves)

1. **Testability** — can each unit be exercised in isolation? "Only end-to-end" means L2 or L3 is wrong.
2. **One-sentence test** — every responsibility describable without "and"? Else L2.
3. **Cycle check** — dependency graph acyclic? Else L3.
4. **Reversibility ranking** — which decision taken is hardest to undo? Goes top of the decision record with explicit user acknowledgement.
5. **Known-solution probe (bidirectional)** — see §8.6.

### 8.5 L7 evidence model (added on user challenge)

The anchor is not git history but a **named source**. History is only the hardest of four
admissible kinds, and requiring it alone fails for genuinely new work:

1. git history of the touched areas (retrospectively proven, hardest),
2. an already-recorded but unbuilt requirement: backlog/ticket/roadmap item, or a concrete
   planned extension the user names,
3. structural necessity from the domain, not conjecture (an integration point for payment
   methods will see more than one because the business has more than one),
4. analogy to a neighbour in the same codebase that already carries the same axis.

Inadmissible: "it could be that ..." without one of the four. That keeps the
anti-speculation brake that the history anchor originally provided.

Softness is not binary. Three graded answers, cheapest first:

- **note only** — record the axis in the decision record, change nothing (cost zero, makes the later change conscious),
- **place the cut so the change stays local** — no abstraction (cost near zero; this is the DEFAULT answer),
- **build an abstraction / extension point** — real cost; admissible only on evidence kind 1 or 2 AND more than one known case.

This is the operationalised rule-of-three and is what structurally prevents L7 from
producing over-engineering.

### 8.6 Known-solution probe (design patterns) — resolution of the user's question

Rejected as an eighth lens. "Which pattern fits here?" is a question this model class
answers eagerly and badly: any cut admits three plausible-sounding patterns, which is
exactly the post-hoc rationalisation of §5 B4, and a named pattern reads as an improvement
merely because it has a name. Model defaults already supply pattern *knowledge* in
abundance; what is missing is the *brake*.

Kept as a probe, applied to the cut already derived from L2 to L4, bidirectional:

- Is this cut a known solution, or a reinvention of a worse variant? ("You are building a
  worse version of X" does change the change-set.)
- Is a pattern present where straight code would do?

Admission rule: a pattern name may be introduced only if it **simplifies** the cut (fewer
units, fewer edges, or it is vocabulary already used in this project). Never if it merely
*names* the existing cut. "No pattern, straight code" is an explicitly expected answer.

The genuinely valuable variant in this user's stack (TYPO3/Shopware/Drupal) is not GoF but
framework-provided extension mechanisms: building alongside the mechanism the framework
already provides for this extension case. That check belongs to L0 grounding (§8.2) and is
recorded there.

---

## 9. Decisions taken (2026-07-29) and what shipped

### 9.1 Decisions

- **Gap 1 is built, Gap 2 is deferred.** Part A first, per §6 sequencing.
- **Form: A1**, a separate skill, per §7.5. Not the grill-me mode (A3).
- **Name `/core:blueprint`.** The user's own pipeline framing (`grill-me` → X → plan →
  poke-holes) showed X is not a grill *mode* but a distinct step translating "what" into "how",
  so a `grill-*` name was wrong. Chosen from the user's candidate set
  (draft / sketch / outline / shape / structure / blueprint): artifact-oriented, binding in tone,
  no collision (`shape` is already used by `design-an-interface`, `sketch` reads as
  `/pocock:prototype`).
- **Gate scope: cut + schema.** Fires on more than one new unit, on relocation of a
  responsibility boundary, and on data-schema contact. Schema included because L5 is the least
  reversible class in the set and schema contact is mechanically recognisable (migration, entity,
  TCA), so false-alarm rate stays low. Contract visibility (L4) deliberately NOT a trigger.
- **Record target: `.aiassistant/state/` by default, offer to establish `docs/adr/` once.**
  Per `Meta.md` §2.2 (creating new documentation structure requires asking).
- **Interaction model: draft for review, not interview.** Derived, not picked from the option
  list, from the user's decoupling requirement: "the result may be filed for agreement" needs a
  standalone artifact, and an interview transcript is not one. A draft is one by construction.
  Secondary benefit: it avoids two interview rounds back to back after `grill-me`, and it makes
  the decided-vs-dictated split visible, which is the §5 B4 countermeasure.
- **Decoupling is a hard requirement.** The skill presupposes no predecessor and no successor.
  Consequence discovered from this: if a blueprint is filed and implemented later (possibly in
  another session), the gate must FIND it rather than re-suggest the skill. That check is part of
  the `CleanCode.md` rule.
- **Lens set: seven, L6 retained**, plus the L7 evidence model (§8.5) and the known-solution
  probe instead of a pattern lens (§8.6).

### 9.2 Change-set as shipped

| File | Change |
|---|---|
| `rules/CleanCode.md` | new section "Architectural Cut Gate (MUST)", `General.md` §3.5 pattern, incl. existing-blueprint lookup |
| `core/skills/blueprint/SKILL.md` | new. Procedure by reference to `grill-me` §4.1/§4.3/§4.4/§4.5/§4.6 per `General.md` §9.3 |
| `core/skills/blueprint/references/architecture-lenses.md` | new. L0, L1 to L7, L7 evidence model, probes |
| `core/skills/grill-me/SKILL.md` | §1 sibling list: added `/core:blueprint` and `/pocock:design-an-interface` |
| `CLAUDE.md` | ledger entry with the literal "explicit activation required" (`General.md` §9.2); category heading relaxed to "unless the entry states otherwise" |

Validation: `bin/lint-section-refs.sh` → `REF-LINT: ok` (exit 0), CLAUDE.md at ~2700 of 3000
budgeted tokens. `npx agnix@0.40.0 validate plugins/marketplaces/local/plugins rules` (the exact
pre-commit scope) → 0 errors, exit 0; no finding on any changed file. The 17 warnings are
pre-existing and non-blocking per `.agnix.toml`.

Explicit-activation convention followed from `/core:rule-friction`: the literal phrase in the
description, NOT `disable-model-invocation`, so the agent can still invoke the skill once the user
accepts the gate offer.

### 9.3 Still open

- Part B (pairing mode) in full: `observe` vs. gating, persistence reach (M5), willingness to add
  hooks (B1, the precondition for any credible always-on claim).
- Empirical check of Part A: does the gate fire at the right moments, and does the lens set hold
  in real use? First two or three uses decide whether L1/L7 should merge (§ user review) and
  whether Part B is still needed at all.
- Unrelated finding: `advisor` is referenced by four skills but does not exist (§2).
