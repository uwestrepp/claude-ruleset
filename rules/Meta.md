---
apply: always
instructions: Apply for knowledge persistence, durable agent memory, and rule-set governance across all tasks.
---

# Meta Rules

This document defines always-on meta-rules for:

- minimizing preventable information loss between agent sessions,
- storing durable knowledge in the right place with minimal noise,
- improving the rule-set itself without fragmenting it.

Normative keywords are defined in `General.md`.

---

# 1. Knowledge Is Transient

Session memory is transient. Information that is not written to a durable project location will be lost when the session ends.

## 1.1 Relevant knowledge (MUST)

The agent MUST treat newly learned knowledge as persistence-relevant when any of the following triggers apply:

- a non-obvious behavioral constraint, workaround, or integration caveat is confirmed during the task,
- expected and actual behavior of a tool, API, or environment differ from documentation or prior knowledge,
- a manual procedure or one-time step is identified that future sessions or operators will need,
- a migration finding, schema fact, or environment quirk is validated,
- a decision is made that depends on information not recoverable from code or git history alone.

The agent MUST NOT persist temporary hypotheses, one-off scratch notes, or information that is already obvious from code, tests, or existing documentation.

## 1.2 Storage targets (MUST)

The agent MUST store relevant knowledge in the narrowest durable scope that fits the information:

- maintainer-facing code rationale belongs in code comments only when future readers cannot reasonably infer it from the code itself,
- API or contract semantics belong in DocBlocks only when that location is the established source of truth,
- package, extension, or subsystem knowledge belongs in an existing local `README.md` or equivalent local documentation when that document is the best durable maintainer-facing location,
- project-wide operational knowledge belongs in an existing project-level documentation file when the impact is project-wide,
- durable project-specific agent memory that is not appropriate for maintainer-facing documentation belongs under `.aiassistant/state/`,
- global reusable agent behavior rules belong under `~/.claude/rules/`; project-level reusable agent behavior rules belong under `.aiassistant/rules/`.

The agent MUST prefer updating an existing source of truth over creating a new one.

If no appropriate durable location exists and creating one would materially change project documentation structure, the agent MUST ask before doing so.

## 1.3 Timing and duplication (MUST)

The agent MUST continuously evaluate whether newly confirmed knowledge should be persisted.

Persistence risk is elevated and deferral to task end is not acceptable when any of the following signals are present:

- the session is long or batch-intensive,
- context compaction has occurred or is approaching,
- many files have been touched in a single session,
- a non-obvious finding or workaround has just been confirmed,
- a tool command's behavior was clarified or an environment quirk resolved.

When a risk signal is present, the agent MUST persist immediately after the triggering event. Otherwise, relevant knowledge MUST be persisted before the task-end checkpoint.

When a persistence action is taken because of this rule, the agent MUST mention the durable target path in the next user-facing update unless the user explicitly asked to suppress such updates.

If relevance or storage target is unclear but plausible, the agent SHOULD persist speculatively and ask if ambiguity remains — deferral is the riskier choice in long sessions.

The agent MUST NOT create duplicate, stale, or low-signal documentation.

Documentation updates MAY be bundled with the related work. If they are outside that scope, they SHOULD be separated into a dedicated documentation change.

## 1.4 Workflow Artifact Retention (MUST)

For agent process artifacts under `.aiassistant/state/workflow-triage/`:

- keep durable final triage packets/evidence summaries only when they remain useful for future audits or continuation,
- treat transient backup/scratch artifacts (for example precompare patches, status snapshots, ad-hoc working-delta dumps) as temporary,
- do not commit transient artifacts by default,
- remove transient artifacts before finalizing unless the user explicitly requests retention.

If retention value is unclear, ask the user before committing artifact files.

---

# 2. Rule-Set Governance

## 2.1 Improvement checkpoints (MUST)

The agent MUST evaluate the project rule-set defined in `CLAUDE.md` for effectiveness and efficiency at defined checkpoints: task start, major milestone, and task end. Workflow-specific rules MAY concretize these checkpoints into named phase boundaries; when such concretization exists, those phase-level triggers supplement — but do not replace — the baseline checkpoints defined here.

The agent MUST perform checkpoint evaluations continuously during delivery, but MUST batch non-critical rule-improvement feedback only to the next defined checkpoint (major milestone or task end), not beyond, to avoid workflow disruption.

Checkpoint results MUST be visibly labeled in user-facing output, for example with the prefix `Meta checkpoint:`. For task-end and Phase 9 checkpoints: if the checkpoint finds substantive improvements or knowledge items, the result MUST also be appended to a durable committed artifact (the triage packet, the closure log, or an equivalent named session artifact). A chat-only label is not sufficient evidence for auditability when committed session artifacts exist. The checkpoint is not complete until either (a) no meaningful improvements were identified and this is stated in the next user-facing update, or (b) substantive findings are persisted to the named artifact.

At task start, the agent MUST record an initial checkpoint internally and SHOULD surface it immediately when there is a meaningful improvement to raise. If there is no meaningful improvement at task start, the agent MAY defer a no-op statement to the first major milestone.

At task end, the agent MUST always provide one explicit batched checkpoint result: either concise improvement proposals or a concise "no meaningful improvement identified" statement.

At each major milestone, the agent MUST provide one explicit checkpoint result line: either concise improvement proposals or a concise "no meaningful improvement identified" statement.

When the checkpoint involves reviewing multiple files, inspecting rule-set coverage, or drafting substantive rule improvements, the agent SHOULD delegate to the `checkpoint` sub-agent per `General.md` §10.1 rather than performing the review inline. Inline checkpoint is acceptable only when the result is a brief no-op (no new knowledge, no rule improvements to propose).

If the agent identifies a meaningful improvement, it MUST propose it in a concise structure: problem, proposed change, expected impact, and risk/tradeoff.

## 2.2 Change policy (SHOULD / MUST)

New rule patterns SHOULD be added when backed by official migration guidance or repeated project-level friction, and SHOULD include a short rationale.

Rule proposals SHOULD be batched to the next defined checkpoint unless the issue is critical/blocking or the user asks for immediate feedback.

If the user explicitly asks for rule/documentation improvement feedback, the agent MUST provide it immediately and MUST NOT defer it to a later checkpoint.

Critical or blocking rule issues MUST be raised immediately and SHOULD interrupt the current workflow so the user can react before execution continues.

Critical means a high-likelihood risk that continuing the current workflow would fail required outcomes/DoD, produce incorrect results, cause irreversible/destructive changes, violate security/compliance constraints, or break required traceability/governance (for example wrong branch/ticket commit attribution).

If criticality is unclear but plausible, the agent MUST treat it as critical and ask immediately.

Updates can include changes, additions, removals, renames, and structural rewrites of single rules or whole rule-sets.

When adding or altering rule-sets, the agent MUST check for overlap and merge rules where viable. Narrower scoped rules SHOULD remain only when they are demonstrably more effective or efficient.

Shared baseline rules SHOULD live in the narrowest always-on file that matches their true scope. Specialized rule files SHOULD reference those shared baselines instead of duplicating them.

Testing requirements MUST be maintained as one general mandatory rule (test-path selection plus execution after changes). Scoped rules should specialize that baseline instead of duplicating or conflicting with it.

When adding, removing, renaming, or materially changing files in the applicable rules directory (`~/.claude/rules/` for global rules, `.aiassistant/rules/` for project-level rules), the agent MUST update the explicit rule index in `CLAUDE.md` in the same change-set.
