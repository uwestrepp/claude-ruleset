---
name: batch
description: "Activate via /core-workflows:batch or let Claude auto-activate when the task matches batch-workflow patterns. Provides the shared execution phase template (toolset gate, preflight, scope/inventory/baseline, scan, triage, implementation, validation, documentation, commits, handover), the risk-sequenced Pass 1 (Batch-Safe) / Pass 2 (Batch-Provable) / Pass 3 (Manual) execution model with mandatory non-skippable triage/compliance gates, reviewability and PR-split escalation thresholds, autonomous execution mode activation protocol, strict sequential workflow chaining model, code-test triage memory, post-commit continuation, and per-pass and final reporting template. Triggers: multi-file refactor across N call sites (N>=5), migration touching multiple packages/extensions/components, scope expansion from small task to multi-file work, scanner-driven or analyzer-driven change batches, upgrade execution spanning multiple findings, rector/fractor/php-cs-fixer/phpstan cycles, 'refactor across all X', 'migrate all Y', 'update N files', 'apply to every', autonomous/unattended/batch execution requests, static-test and remediation cycles, any workflow where Pass 1/Pass 2/Pass 3 classification applies, any larger-scale multi-file multi-step automation-assisted change. Foundation for TYPO3 workflow skills (/typo3-workflows:typo3-upgrade, /typo3-workflows:typo3-scanner, /typo3-workflows:typo3-static-tests, /typo3-workflows:typo3-upgrade-full) — they layer domain specifics on this skill."
argument-hint: [scope]
allowed-tools: [Read, Edit, Write, Glob, Grep, Bash, Agent]
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
| 4     | Triage & Plan               | Classify findings; produce triage packet (§9.1)                     |
| 5     | Implementation              | Apply changes: Pass 1 → Pass 2 → Pass 3                            |
| 6     | Validation                  | Verify functional equivalence against Phase 2 baseline (`General.md` §5.2) |
| 7     | Documentation Sync          | Update migration notes, README, and operator docs                   |
| 8     | Commits                     | Scoped, traceable commits (see `/core-workflows:commits` skill)     |
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
5. **If a baseline artifact from a prior session already exists** for the same scope,
   explicitly verify it is still current before using it as Phase 2 evidence: confirm
   that each documented entry point still exists and that at least one key expected
   behavior per surface still produces the documented result. If the artifact is stale
   or scope has changed, update it. Note the re-verification in the artifact
   (for example: "Re-verified: YYYY-MM-DD, all entry points current").

The baseline artifact is the primary comparison evidence for Phase 6. Work MUST NOT
proceed to Phase 3 if the baseline is incomplete without explicit acknowledgement of
what is missing and why.

This section makes the functional baseline mandatory for all batch workflow cycles
(see also §3.3).

At the conclusion of Phase 2, perform a knowledge persistence and rule-set governance
checkpoint per `Meta.md §2.1` and report it as an explicit labeled user-facing line
(for example `Meta checkpoint: ...`).

### 3.3 Baseline Requirement for Larger-Scale Changes (MUST)

For larger-scale change cycles (for example multi-extension updates, multi-topic analyzer passes, or medium/high-risk migration batches), the agent MUST establish a pre-change baseline before applying code changes.

Baseline requirements:
- run one full, project-defined suite for the targeted scope (static analyzer runs may be part of this suite for compliance baseline),
- establish functional/runtime baseline paths for impacted medium/high-risk surfaces,
- document per-extension functional baseline paths and expected outcomes when such documentation does not already exist,
- use functional baseline as primary comparison evidence for post-change targeted checks and final regression validation,
- treat static baseline comparison as supplementary compliance signal only.

If baseline execution is blocked, the agent MUST state blocker, impact, and exact follow-up command/manual step.

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
the item for individual approval per §9.3 before applying any change
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
- compliance checklist from §9.1
- knowledge persistence and rule-set governance checkpoint result per `Meta.md §2.1` as an explicit labeled line (either concise improvement proposals or "no new relevant knowledge or rule improvements identified")

---

## 9. Risk-Sequenced Change Execution (MUST)

Applicability (MUST):
- This section applies when ANY of the following is true:
  - more than one finding/topic/file is handled in one cycle,
  - analyzer/scanner/fixer/transformer output is used to decide edits,
  - edits are applied in grouped passes/batches,
  - generated or scripted edits are applied.
- If applicability is uncertain, the user MUST be queried to make the decision before edits are applied.

When this section applies, the agent MUST use this shared execution model:

1. Pass 1 (`Batch-Safe`): low/no-impact mechanical or confirmed-safe changes, applied in one initial sweep across selected scope.
2. Pass 2 (`Batch-Provable`): grouped medium-risk changes that are applied only when deterministic proof succeeds.
3. Pass 3 (`Manual`): non-provable or high-risk changes handled one-by-one with explicit approval.

### 9.1 Pre-Apply Risk Classifier + Non-Skippable Triage/Compliance Gates (MUST)

This section is the single authoritative source for hard triage/compliance gates for all large-scale, batch-type, or automation-assisted change workflows.

Before the first code edit in such a cycle, the agent MUST:
- publish a triage packet in chat that includes:
  - resolved scope and extension list,
  - pre-change baseline run id/log path,
  - finding/change groups classified as `safe` / `provable` / `manual` with concise rationale,
  - planned validation depth per group and impacted runtime surfaces,
  - explicit list of `manual` topics requiring approval.
- persist the same packet to:
  - `.aiassistant/state/workflow-triage/<timestamp>-<workflow>-<scope>.md`
- confirm the triage packet exists at the mandatory path before proceeding: work MUST NOT advance to Phase 5 (Implementation) until this artifact is present with all prescribed fields populated. An informal or equivalently structured triage document at another path does not satisfy this requirement unless explicitly reformatted or mapped into a compliant artifact at the correct path in the same step.
- wait for explicit user approval before applying:
  - any `provable` batch,
  - any `manual` item.

Vocabulary compliance:
- The `safe` / `provable` / `manual` classification labels MUST appear verbatim in the triage packet's finding classification section. Equivalent informal labels (for example `FIX NEEDED / BUSINESS DECISION / MANUAL FOLLOW-UP`) do not satisfy this requirement unless an explicit cross-reference to the three-tier model is included.

Execution clarification:
- `safe` (maps to Pass 1):
  - formatting-only, type-annotation/doc normalization, or deterministic no-op mechanical rewrites with proven equivalence.
- `provable` (maps to Pass 2):
  - grouped changes where equivalence can be demonstrated by contract/signature checks and targeted validation evidence.
- `manual` (maps to Pass 3):
  - behavior-sensitive, business-logic-affecting, environment/credential flow changes, side-effect ordering changes, or ambiguous transformations.

Execution policy:
- `safe` changes may be applied only after triage packet publication.
- only `safe` may be batch-applied directly,
- `provable` may be applied in grouped batches only after proof succeeds (§9.2),
- `manual` MUST be handled one-by-one with explicit approval (§9.3).
- if classification is uncertain, classify as `manual`.
- if any item cannot be confidently proven equivalent, it MUST be classified as `manual`.
- if triage is skipped and later detected, the agent MUST halt immediately, report non-compliance, and backfill triage before continuing.

Final reporting gate:
- final cycle report MUST include a compliance checklist with these exact keys:
  - `triage_packet_published`: `yes|no` (link)
  - `triage_artifact_saved`: `yes|no` (path)
  - `pre_change_baseline_logged`: `yes|no` (path)
  - `approvals_recorded_for_provable_manual`: `yes|no` (link)
  - `static_rerun_green`: `yes|no` (path)
  - `runtime_validation_executed`: `yes|no` (evidence link OR blocker + exact follow-up command)
  - `meta_checkpoint_phase2_executed`: `yes|no` (evidence: labeled output or committed artifact reference)
  - `meta_checkpoint_phase9_executed`: `yes|no` (evidence: labeled committed artifact line or path)

Non-circumvention:
- workflow-specialization rules MUST reference this section.
- workflow-specialization rules MUST NOT duplicate, weaken, or bypass these gates.

### 9.2 Pass 2 Deterministic Proof Gate (MUST)

Before applying grouped Pass 2 changes, the agent MUST verify:
- upstream contract and semantic mapping (`General.md §4.5`),
- interface/inheritance compatibility,
- call-site compatibility (defaults, nullability, variadic, by-reference, accepted types),
- unresolved dynamic dispatch ambiguity is absent (otherwise escalate),
- parser/lint/static checks pass for touched files and impacted scope,
- risk-appropriate runtime/functional checks are selected and executed per `General.md §5.2`.

Static analyzer/lint passes alone are insufficient for Pass 2 proof.

If any proof step is inconclusive, item MUST be escalated to Pass 3 and not batch-applied.

### 9.3 Pass 3 Approval Loop (MUST)

Before applying a Pass 3 topic, present:
1. rule/finding identifier,
2. at least one before/after example,
3. affected file+line list,
4. concrete behavior/regression risk,
5. targeted before/after functionality-test suggestion when risk is high.

Then execute:
1. wait for explicit confirmation,
2. apply change,
3. run selected validation and report,
4. wait for thumbs-up,
5. commit,
6. immediately propose next topic packet.

Pass 3 reporting quality gate:
- validation evidence MUST be scoped to the candidate file(s) and directly impacted paths,
- if output contains substantial unrelated noise, the agent MUST rerun narrowed commands before presenting results.

### 9.4 Validation Depth by Pass (MUST)

After applying findings:
- Pass 1: reduced smoke validation for impacted surfaces.
- Pass 2: grouped impacted-surface validation; escalate to full verification when impact is medium/high.
- Pass 3: full verification, including targeted before/after functionality checks for high-risk impacts.

---

## 10. Code-Test Triage Memory (MUST)

When static code tests/analyzers are used, the agent MUST:
- capture repeated finding patterns in a maintained ledger,
- capture confirmed false positives separately with rationale,
- prefer scoped, line-level suppressions over broad/file-level suppressions.

If a project-specific workflow exists (for example ordered analyzer passes), follow it as a specialization of this baseline.

---

## 11. Post-Commit Continuation (MUST)

After each completed change loop where validation has run and a commit is created, the agent MUST immediately propose the next concrete step.

The proposal MUST include:
- the next topic/rule identifier (or equivalent issue label),
- at least one concise example of the intended change pattern,
- affected file(s) (and lines when available),
- a short risk note.

The agent MUST NOT pause after commit without this explicit next-step proposal unless the user asks to stop.
