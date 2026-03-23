---
apply: by model decision
instructions: Apply for any larger-scale, multi-file, multi-step, batch, or automation-assisted change workflow.
  Foundation for all batch workflows that explicitly refer to this file.
---

# Batch Workflow Foundation

This file defines the shared execution model for all batch workflows in this rule-set.
Specialized workflow files build on this foundation and define what happens inside each phase.

Batch workflow in this rule-set includes any larger-scale or multi-file operation with repeated scan, triage, implementation, validation, or reporting steps, even when executed one package or scope at a time. This includes static-test and remediation cycles.

Complements:
- `General.md` (pass/gate model, validation baseline — non-skippable gates remain there)
- all batch workflows that explicitly refer to this file
- larger-scale or multi-file operations that do not yet have a more specialized workflow file

---

## 1. Execution Phase Template (MUST)

All batch workflows follow this phase sequence. Specialized workflows define what happens
inside each phase. Phases may be omitted when genuinely inapplicable but MUST NOT be
reordered.

| Phase | Name                        | Description                                                         |
|-------|-----------------------------|---------------------------------------------------------------------|
| 0     | Toolset Gate                | Verify environment and required tooling (§2)                        |
| 1     | Preflight                   | Branch/state checks, input confirmation                             |
| 2     | Scope, Inventory & Baseline | Map entry points, dependencies, and verify functional baseline (§3) |
| 3     | Scan / Analysis             | Collect findings (scanner, analyzer, changelog, or plan)            |
| 4     | Triage & Plan               | Classify findings; produce triage packet (`General.md` §5.8.0)      |
| 5     | Implementation              | Apply changes: Pass 1 → Pass 2 → Pass 3                            |
| 6     | Validation                  | Verify functional equivalence against Phase 2 baseline (`General.md` §5.2) |
| 7     | Documentation Sync          | Update migration notes, README, and operator docs                   |
| 8     | Commits                     | Scoped, traceable commits (`Commits.md`)                            |
| 9     | Handover & Reporting        | Final summary and compliance checklist (§7)                         |

---

## 2. Toolset & Environment Gate (MUST)

Before Phase 1, every batch workflow MUST execute this gate.

General steps (identical for all workflows):
1. Confirm the project type matches the workflow's requirements (per workflow specification).
2. Confirm container/tooling is available (e.g. run `ddev describe` and verify it responds).
3. Confirm required workflow commands exist and are callable (per workflow specification).

If any check fails: report which check failed, do not proceed past Phase 0, and ask the
user how to continue.

Each specialized workflow file specifies the project-type check (step 1) and the
command-availability check (step 3). Step 2 is identical for all ddev-based workflows.

---

## 3. Scope, Inventory & Functional Baseline (MUST)

Phase 2 has two mandatory outputs: an inventory and a verified functional baseline.

### 3.1 Inventory

Identify and document:
- entry points: frontend routes, backend modules, API endpoints, CLI commands,
  scheduler tasks, middleware.
- storage/schema touchpoints.
- integration/dependency touchpoints (other components consuming this scope).
- relevant configuration options that can affect behavior (for option-matrix coverage
  in Phase 6).

### 3.2 Functional Baseline (MUST)

For each identified entry point and surface, the agent MUST:

1. **Verify** it is currently functional by executing or invoking it and confirming
   expected behavior. Test path selection follows `General.md` §5.2.
2. **Document** concrete baseline behavior per surface:
   - invocation method (route, command, endpoint, trigger)
   - representative input conditions
   - expected output / response / behavior
3. **Classify** any surface that cannot be verified:
   - pre-existing breakage: document explicitly; decide whether to fix before
     proceeding or carry as known-broken baseline.
   - verification blocked (environment, credentials, etc.): state blocker and
     exact follow-up step; do not silently skip.
4. **Persist** baseline artifact to `.aiassistant/state/functional-baseline-<scope>.md`
   (create or update).

The baseline artifact is the primary comparison evidence for Phase 6. Work MUST NOT
proceed to Phase 3 if the baseline is incomplete without explicit acknowledgement of
what is missing and why.

This section specializes `General.md` §5.2.1 by making the functional baseline mandatory
for all batch workflow cycles, not only larger-scale ones.

At the conclusion of Phase 2, perform a knowledge persistence and rule-set governance
checkpoint per `Meta.md §2.1` and report it as an explicit labeled user-facing line
(for example `Meta checkpoint: ...`).

---

## 4. Reviewability & PR Escalation (MUST)

Batch-scale work MUST remain reviewable. When a workstream grows beyond sensible review
size, the agent MUST recommend creating pull requests or splitting work into multiple
branches instead of continuing indefinite branch accumulation.

The agent MUST evaluate reviewability continuously during batch execution and again at
minimum:
- after Phase 2 baseline/inventory,
- after Phase 4 triage,
- before Phase 8 commits.

### 4.1 Soft escalation threshold (MUST)

The agent MUST recommend a PR/split checkpoint when any of the following is reached:
- `>= 8` commits on the working branch,
- `>= 20` changed files,
- `>= 600` changed lines,
- `>= 2` packages/extensions/components touched,
- `>= 3` concern types touched across one workstream, for example:
  - PHP runtime,
  - Fluid/templates,
  - TypoScript,
  - configuration/infrastructure,
  - tests/tooling,
  - docs/governance.

At soft threshold, the agent MUST:
- state that the workstream has reached review-risk size,
- recommend a PR or split strategy,
- explicitly justify continuing in one branch if the user wants to proceed without splitting.

### 4.2 Hard escalation threshold (MUST)

The agent MUST pause and present a split/PR strategy before continuing when any of the
following is reached:
- `>= 12` commits on the working branch,
- `>= 30` changed files,
- `>= 1000` changed lines,
- `>= 3` packages/extensions/components touched,
- mixed unrelated tickets/extensions in one branch.

At hard threshold, the agent MUST NOT continue accumulating changes in the same branch
unless the user explicitly overrides after seeing the proposed split strategy.

### 4.3 Weighting rule (MUST)

Package/extension spread takes precedence over raw line count. A smaller diff spanning
multiple unrelated packages is more review-risky than a larger but coherent single-scope
change. When thresholds disagree, the agent MUST bias toward recommending a split.

### 4.4 Reporting (MUST)

Whenever this section triggers, the next user-facing update MUST include:
- which threshold was reached,
- the current scope size in concrete terms,
- whether the recommendation is soft or hard escalation,
- the proposed PR/branch grouping strategy.

---

## 5. Autonomous Execution Mode (MUST)

### 5.1 Activation protocol

When the user expresses intent for autonomous execution, the agent MUST respond with a
scope confirmation statement before switching modes. Casual phrases alone ("go ahead",
"do it") are NOT sufficient triggers.

The scope confirmation statement MUST include:
1. Workflow(s) that will execute and their phase sequence.
2. Which change groups are Pass 1/2 (no per-step confirmation after triage approval)
   vs. Pass 3 (individual approval always required regardless of mode).
3. Explicit list of conditions that will still cause a pause:
   - any Pass 3 item requiring individual approval,
   - any action that is destructive or not safely reversible,
   - any discovery outside the stated scope,
   - any missing required input that blocks correctness.

The agent MUST wait for the user to explicitly confirm the scope statement before
activating autonomous mode.

### 5.2 Scope boundary

Autonomous mode is active only for the explicitly confirmed scope. If work outside
that scope is discovered, the agent MUST pause, report the item, and ask whether to
extend scope before continuing.

### 5.3 Pass 3 always suspends implementation

When a Pass 3 item is encountered, the agent MUST suspend implementation and present
the item for individual approval per `General.md` §5.8.2 before applying any change
to it. This applies regardless of whether autonomous mode is active.

Autonomous mode does not reduce this requirement. Pass 3 items are, by definition,
changes whose functional equivalence is not obvious and cannot be automatically
verified — manual review is the only valid gate.

---

## 6. Workflow Chaining (MUST)

When two or more workflows are composed into a single execution, they run strictly
sequentially: each workflow completes all its phases before the next begins.

**Execution sequence:**
1. **Phase 0** (toolset gate): run once; satisfy the most demanding toolset requirements
   across the full chain.
2. **Phase 1** (preflight): run once for the combined scope.
3. **For each workflow in declared order:**
   a. Execute phases 2–9 of that workflow completely.
   b. Each phase feeds the next within the same workflow.
   c. Do NOT start the next workflow until the current one reaches Phase 9.
   d. Produce a brief inter-workflow handoff note: what was completed, what baseline
      state the next workflow inherits, any open items.
4. **Phase 9** (final handover): produced once for the full chain at the end.

This strict sequencing prevents context bleeding between workflows and keeps each
implementation pass narrowly scoped to one workflow's findings at a time.

Before starting a chained execution, the agent MUST:
- declare the chain: list of workflows and their order,
- confirm the combined scope with the user,
- apply §4 autonomous mode protocol if applicable.

---

## 7. Agent Delegation (SHOULD)

When custom agents are available (defined in `~/.claude/agents/` or `.claude/agents/`),
the main agent SHOULD delegate suitable work to reduce blocking and context pressure:

- **`test-runner`**: spawn in background after applying changes (per pass or per batch)
  to run validation commands while the main agent continues with triage or the next topic.
  Collect results before committing.
- **`checkpoint`**: spawn in background at phase boundaries (phases 2, 5, 9) to handle
  `Meta.md §2.1` knowledge persistence and rule-set governance evaluation.
  Collect results before producing the phase report.
- **`contract-researcher`**: when Phase 4 triage identifies a large number of findings
  requiring upstream contract verification (`General.md §4.5`), spawn to process the
  batch sequentially in isolated context. Recommended threshold: >10 findings needing
  contract verification. Below threshold, the main agent handles verification inline.
  Collect classification results before finalizing the triage packet.

Agent delegation is optional — if agents are unavailable, the main agent performs
these tasks inline as before.

---

## 8. Reporting Template

### 8.1 Per-pass report (SHOULD)

After each pass within Phase 5 (Pass 1 / Batch-Safe, Pass 2 / Batch-Provable,
Pass 3 / Manual), report:
- scope (extension list, file set, or topic group)
- topic clusters addressed
- changes applied (file + line references where relevant)
- residual findings / backlog for subsequent passes
- explicit next-step proposal
- knowledge persistence checkpoint per `Meta.md §2.1` as an explicit labeled line (persist any newly confirmed findings before continuing and mention the target path when something was persisted)

### 8.2 Final cycle report (MUST)

At Phase 9, report:
- branch + commit ids (all repositories affected)
- what was done, grouped by concern
- validation evidence per surface, with reference to Phase 2 baseline
- unresolved risks and backlog items with rationale and follow-up
- explicit next commands for operator/developer
- compliance checklist from `General.md` §5.8.0
- knowledge persistence and rule-set governance checkpoint result per `Meta.md §2.1` as an explicit labeled line (either concise improvement proposals or "no new relevant knowledge or rule improvements identified")
