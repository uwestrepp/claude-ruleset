---
name: batch
description: "Activate via /core:batch, or let Claude auto-suggest it (propose activation, never silently run) when work is batch-shaped: multi-file refactors/migrations (>=5 call sites or multiple packages/extensions), scanner- or analyzer-driven change batches, rector/fractor/php-cs-fixer/phpstan remediation cycles, scope growth from small task to multi-file work, or autonomous/unattended execution requests. Foundation for the /typo3:* workflow skills — they layer domain specifics on this skill."
argument-hint: "[scope]"
allowed-tools: [Read, Edit, Write, Glob, Grep, Bash, Agent]
---

# Batch Workflow Foundation

*Input (`$ARGUMENTS`): optional scope of the batch.*

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
| 8     | Commits                     | Scoped, traceable commits (see `/core:commits` skill)     |
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
- retroactive `General.md` §4.5 items: any signature change already present in the
  working scope from a prior session or base-branch merge — identify it, list it as a
  §4.5 item in the triage packet (§9.1), and verify it before Phase 5 implementation
  begins.

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
4. **Persist** baseline artifact to `.aiassistant/state/functional-baseline-{scope}.md`
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

At the conclusion of Phase 2, perform a combined meta checkpoint per `Meta.md §1.1`
and report it as an explicit labeled user-facing block with both Knowledge and
Rule-set lines (for example `Meta checkpoint:\n  Knowledge: ...\n  Rule-set: ...`).

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

Effort/model recommendations (`General.md` §10.2) do not pause an autonomous run;
they are queued into the handoff note / phase report per the §10.2 carve-out.

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

### 5.4 Autonomous mode and `provable` (MUST)

In autonomous mode, `provable` batches MAY be pre-approved at scope-confirmation time, but
applying them still requires BOTH: the §9.1.2 independent audit returned PASS, and every
atom in the batch has its §9.2 proof-ledger line. The audit + ledger replace the per-batch
human approval; they do not become optional. `manual` (Pass 3) is never pre-approvable
(§5.3, §9.3).

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
- apply §5 autonomous mode protocol if applicable.

---

## 7. Agent Delegation

When custom agents are available (defined in `~/.claude/agents/` or `.claude/agents/`),
the main agent MUST/SHOULD delegate as follows. This section specializes the baseline
delegation policy in `General.md` §11.

- **`checkpoint` (MUST at phases 2, 5, 9)**: spawn in background at each phase boundary
  to handle `Meta.md §1.1` combined meta checkpoint (knowledge persistence + rule-set
  governance evaluation, dual-aspect labeled output).
  Collect results before producing the phase report. Inline checkpoint is acceptable
  ONLY when the phase's work was minimal and no multi-file review is warranted.
  At Phase 5 entry the same agent ALSO performs the §9.1.2 independent triage audit
  (distinct duty from the meta checkpoint); this audit MUST NOT be done inline by the
  executing agent (see §9.1.2 fallback).
- **`test-runner` (SHOULD after applying changes)**: spawn in background after each
  pass or batch to run validation commands while the main agent continues with triage
  or the next topic. Collect results before committing.
- **`contract-researcher` (SHOULD when >10 findings)**: when Phase 4 triage identifies
  a large number of findings requiring upstream contract verification (`General.md §4.5`),
  spawn to process the batch sequentially in isolated context. Below threshold, the main
  agent handles verification inline. Collect classification results before finalizing
  the triage packet.
- **`payload-replay-verifier` (SHOULD after request-path type narrowing)**: when a
  pass narrows a parameter type or changes a call-site on a controller/service fed by
  serialized FE/BE/API payloads, spawn to replay a real captured payload against the
  running app (`General.md §4.5`) before finalizing. Below that specific trigger the
  main agent verifies inline. Collect the pass/fail/blocked verdict before committing.

If a custom agent is unavailable in the current environment, the main agent performs
the task inline and notes the missing agent in the phase report.

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
- combined meta checkpoint per `Meta.md §1.1` as an explicit labeled block with both Knowledge and Rule-set lines (persist any newly confirmed findings before continuing and mention the target path when something was persisted)

### 8.2 Final cycle report (MUST)

At Phase 9, report:
- branch + commit ids (all repositories affected)
- what was done, grouped by concern
- validation evidence per surface, with reference to Phase 2 baseline
- unresolved risks and backlog items with rationale and follow-up
- explicit next commands for operator/developer
- compliance checklist from §9.1
- combined meta checkpoint per `Meta.md §1.1` as an explicit labeled block with both Knowledge and Rule-set lines (each either substantive findings or the explicit no-op statement; substantive findings additionally appended to the durable session artifact)

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
  - a per-atom classification table: each atom with its L1–L4 rung answers, derived class
    (`safe` / `provable` / `manual`), counter-check sentence, and — for pattern-inherited
    atoms — the representative atom and identity-check ledger line (§9.1.1),
  - a `provable` proof ledger section (§9.2): one line per `provable` atom, populated at
    apply time,
  - planned validation depth per group and impacted runtime surfaces,
  - explicit list of `manual` topics requiring approval.
- persist the same packet to:
  - `.aiassistant/state/workflow-triage/{timestamp}-{workflow}-{scope}.md`
- confirm the triage packet exists at the mandatory path before proceeding: work MUST NOT advance to Phase 5 (Implementation) until this artifact is present with all prescribed fields populated. An informal or equivalently structured triage document at another path does not satisfy this requirement unless explicitly reformatted or mapped into a compliant artifact at the correct path in the same step.
- wait for explicit user approval before applying:
  - any `provable` batch,
  - any `manual` item.

#### 9.1.1 Classification Procedure — Escalation Ladder (MUST)

Classification unit: one **atom** = the smallest coherent change (one call-site, one
signature, one finding hit). Classify per atom, never per file or per loose group. Group
atoms for batch application only within the *same* class. Mixed-class groups are prohibited.

Walk ALL four rungs in order — NO early exit. The class is the **highest rung that
triggers**; if nothing above L1 triggers cleanly and any doubt remains, the class is `manual`.

- **L1** — touches only whitespace/formatting/comments/annotations/DocBlocks, no token with
  runtime semantics.
- **L2** — alters an API element: signature, visibility, name, or type.
- **L3** — alters control flow, side effects, ordering, state, or business logic, OR
  dispatches via dynamic/reflection/non-resolvable call paths.
- **L4** — if L2 or L3 triggered: is equivalence provable by a deterministic
  contract/signature check with FULL call-site coverage (`General.md §4.5`)?

Class derivation (highest triggered wins):
- only L1 → `safe`
- L2 triggers, L4 provable, L3 does NOT trigger → `provable`
- L3 triggers, OR L4 not conclusively provable, OR any residual uncertainty → `manual`

Counter-check (MUST — salience, guards the model's optimism bias): before assigning `safe`
or `provable`, the agent MUST answer in writing "Why is this atom NOT one level riskier?".
If the answer is not a concrete, evidence-backed sentence → escalate one level. The burden
is to prove harmlessness, not to detect risk.

Pattern inheritance (scaling): for large sets of structurally identical atoms, classify one
representative atom fully (ladder + counter-check); identical atoms (same transformation
pattern, same callee/signature situation, verified identical and recorded as a ledger line)
inherit its class. The §9.1.2 audit samples the inherited group.

#### 9.1.2 Independent Triage Audit — Phase 5 Entry Gate (MUST)

The classification step is the least reliable step and MUST NOT self-attest. Before Phase 5
begins, an independent verifier (the `checkpoint` sub-agent in a fresh context, §7) MUST
audit the triage packet and return PASS or specific objections:
- each atom's class is plausible against the §9.1.1 ladder (correctness, not mere label
  presence),
- labels appear verbatim AND match the derivation,
- required fields and counter-check sentences are present and non-empty,
- pattern-inheritance groups are sampled.

Phase 5 MUST NOT begin without a PASS. Fallback when the verifier is unavailable
(headless/cron): hard-block — do NOT enter Phase 5 on self-audit. Resolve by a
fresh-session / second-pass audit, or proceed only on explicit user override recorded in
the report. Self-attestation does not satisfy this gate.

Vocabulary compliance:
- The `safe` / `provable` / `manual` classification labels MUST appear verbatim in the triage packet's finding classification section. Equivalent informal labels (for example `FIX NEEDED / BUSINESS DECISION / MANUAL FOLLOW-UP`) do not satisfy this requirement unless an explicit cross-reference to the three-tier model is included.

Pass mapping: `safe` → Pass 1, `provable` → Pass 2, `manual` → Pass 3. The authoritative
criteria for which class an atom receives are the §9.1.1 escalation ladder rungs, not prose
examples; this mapping only ties the resulting class to its pass.

Execution policy:
- `safe` changes may be applied only after triage packet publication AND the §9.1.2 audit PASS.
- only `safe` may be batch-applied directly,
- `provable` may be applied in grouped batches only after proof succeeds (§9.2),
- `manual` MUST be handled one-by-one with explicit approval (§9.3).
- if classification is uncertain, classify as `manual`.
- if any item cannot be confidently proven equivalent, it MUST be classified as `manual`.
- re-classification on contradiction (MUST): if, while applying any atom, behavioral or
  dispatch evidence contradicts its assigned class, the agent MUST halt, reclassify, and
  re-enter the appropriate pass/gate before continuing.
- post-Pass-1 revalidation (MUST): after the Pass 1 sweep mutates code, revalidate the
  `provable`/`manual` classifications against the changed code before Pass 2 begins; stale
  classifications MUST be re-derived.
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
  - `independent_triage_audit_passed`: `yes|no` (evidence: auditor output ref OR user-override note)
  - `provable_proof_ledger_complete`: `yes|no` (path/section)
  - `reclassification_checkpoint_clean`: `yes|no` (note any halts/re-derivations)

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

Per-`provable`-atom proof ledger (MUST): each `provable` atom MUST have a recorded ledger
line in the triage packet before it is applied — at minimum: atom id, resolved callee@path,
signature old→new, and the check result. No ledger line → no apply. The ledger is the
auditable evidence that §9.2 proof actually ran; an unrecorded proof does not count.

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

### 11.1 Resumption-Safe Checkpoints (MUST)

Batch cycles often span hours or multiple sessions and are subject to interruption (usage limits, tool failures, context compaction, user pause). The agent MUST keep work in a resumable state at all times.

At each phase boundary (per §1 Execution Phase Template), the work state MUST be one of:

- a clean commit representing the completed phase, OR
- a persisted handoff note at `.aiassistant/scratch/{scope}-handoff.md` documenting:
  - current phase and step,
  - concrete progress (what was completed, what is in-flight),
  - next concrete step (file, command, or decision),
  - any in-flight triage decisions not yet committed.

For cycles expected to span multiple sessions or where phases exceed a single natural chunk, the agent MUST:

- create the handoff note at Phase 2 (Preflight/Inventory) and update it at each subsequent phase boundary,
- on continuation (new session or resumed after interruption), read the handoff note as the first orientation step, before `General.md` §3.4 revalidation.

When a session restart is proposed at a phase boundary (per `General.md` §10.2/§10.3), the agent MUST offer the full `General.md` §10.3 handover bundle, not just the note: promote this note to the bundle's continuation-doc component at the durable target (`.aiassistant/state/handoffs/handoff-{timestamp}-{slug}.md`, committed, per `General.md` §10.3) — additionally persist memory (`Meta.md` §2) and emit a ready-to-paste trigger prompt that points the next session at the promoted note's path and names the next phase/step plus the recommended effort/model.

The in-cycle scratch note MUST NOT be committed (it lives in `.aiassistant/scratch/` per `Meta.md` §2.4); the durable copy created at a restart proposal lives in `.aiassistant/state/handoffs/` and is committed (`General.md` §10.3).

Rationale:
- Converts session interruption from a recovery event into a bookmark.
- Leverages the `.aiassistant/scratch/` convention from `Meta.md` §2.4.
- Compatible with `General.md` §3.4 revalidation on resume and `General.md` §8.3 topic-close commit proposal at topic boundaries.
