---
apply: always
instructions: Apply for meta-checkpoints, knowledge persistence, durable agent memory, and rule-set governance across all tasks.
---

# Meta Rules

This document defines always-on meta-rules for:

- a unified meta-checkpoint mechanism that ties knowledge and rule-set evaluation together with a single auditable output,
- minimizing preventable information loss between agent sessions,
- storing durable knowledge in the right place with minimal noise,
- improving the rule-set itself without fragmenting it.

Normative keywords are defined in `General.md`.

---

# 1. Meta Checkpoints

## 1.1 Combined checkpoint mechanism (MUST)

At each of: task start, major milestone, and task end, the agent MUST produce a labeled checkpoint output covering BOTH aspects defined in §2 (Knowledge Persistence) and §3 (Rule-Set Governance), in the form:

```
Meta checkpoint:
  Knowledge: <persistence actions taken with target paths | "no persistence-relevant items identified">
  Rule-set:  <improvement proposals | "no meaningful improvement identified">
```

Both lines MUST be present. Collapsing both aspects into a single combined statement (for example "Meta checkpoint: no findings") is NOT sufficient — each aspect must be explicitly addressed in its own line.

Workflow-specific rules MAY concretize these checkpoint triggers into named phase boundaries; when such concretization exists, the phase-level triggers supplement — but do not replace — the baseline triggers defined here.

The agent MUST perform checkpoint evaluations continuously during delivery, but MUST batch non-critical findings only to the next defined checkpoint (major milestone or task end), not beyond, to avoid workflow disruption. The continuous-evaluation requirement of §2.3 still applies between checkpoints: persistence-relevant knowledge MUST be persisted as soon as the §2.3 risk signals warrant, regardless of checkpoint cadence.

For task-end and Phase 9 checkpoints: if the checkpoint produces substantive findings (knowledge persisted at non-trivial targets, or rule-improvement proposals), the findings MUST also be appended to a durable committed artifact (triage packet, closure log, or equivalent named session artifact). A chat-only label is not sufficient evidence for auditability when committed session artifacts exist. The checkpoint is not complete until either (a) no substantive findings were identified and this is stated in the labeled output, or (b) substantive findings are persisted to the named artifact.

At task start, the agent MUST record an initial checkpoint internally and SHOULD surface it immediately when there is a meaningful finding to raise. If there is no meaningful finding at task start, the agent MAY defer a no-op statement to the first major milestone.

At each major milestone, the agent MUST provide one explicit checkpoint result with both lines.

At task end, the agent MUST always provide one explicit batched checkpoint result with both lines.

When a checkpoint involves reviewing multiple files, inspecting rule-set coverage, or drafting substantive proposals, the agent SHOULD delegate to the `checkpoint` sub-agent per `General.md` §11.1 rather than performing the review inline. Inline checkpoint is acceptable only when the result is a brief no-op (no new knowledge persistence, no rule improvements).

---

# 2. Knowledge Persistence

Session memory is transient. Information that is not written to a durable project location will be lost when the session ends.

## 2.1 Relevant knowledge (MUST)

The agent MUST treat newly learned knowledge as persistence-relevant when any of the following triggers apply:

- a non-obvious behavioral constraint, workaround, or integration caveat is confirmed during the task,
- expected and actual behavior of a tool, API, or environment differ from documentation or prior knowledge,
- a manual procedure or one-time step is identified that future sessions or operators will need,
- a migration finding, schema fact, or environment quirk is validated,
- a decision is made that depends on information not recoverable from code or git history alone.

The agent MUST NOT persist temporary hypotheses, one-off scratch notes, or information that is already obvious from code, tests, or existing documentation.

## 2.2 Storage targets (MUST)

The agent MUST store relevant knowledge in the narrowest durable scope that fits the information. Scope layers, narrowest to broadest:

**In-code (maintainer-facing, in-repo)**:

- code comments — non-obvious local rationale future readers cannot reasonably infer from the code itself,
- DocBlocks — API or contract semantics where DocBlocks are the established source of truth,
- package/extension `README.md` or equivalent local documentation — subsystem-level knowledge,
- project-level documentation (`docs/`, `CHANGELOG.md`, equivalent) — project-wide operational knowledge,
- per-project `CLAUDE.md` — project-specific agent instructions and rule overrides.

**Agent state (project-specific, in-repo)**:

- `.aiassistant/state/` — durable, committed agent memory not appropriate for maintainer-facing documentation (ticket maps, ledgers, triage packets, evidence summaries),
- `.aiassistant/state/notes/<topic>.md` — project-scoped cross-cutting findings (this project's CI quirks, client-specific deploy peculiarities) without a maintainer-facing home.

**Reusable behavior rules**:

- `~/.claude/rules/` — global agent behavior rules,
- `.aiassistant/rules/` — project-level agent behavior rules.

**Cross-project agent memory (out-of-repo)**:

- auto-memory at `~/.claude/projects/<...>/memory/` — findings about the agent's own host environment, host capabilities, tool quirks, and integration patterns reusable across sessions and projects in this account. Choose memory `type` per the memory-system conventions (user / feedback / project / reference). Distinct from `.aiassistant/state/notes/`: auto-memory is for *agent host* findings, `.aiassistant/state/notes/` is for *project environment* findings.

**Colleague-facing external (MCP-mediated, when available)**:

- Confluence (via atlassian-rovo MCP) — knowledge other team members will need; durable team-wide reference.
- Jira (via atlassian-rovo MCP) — ticket-scoped findings, decisions, follow-ups that should be visible on the ticket.
- Bitbucket PR descriptions — PR-specific rationale, reviewer guidance, and decisions captured at merge time.
- Language for all colleague-facing surfaces per `General.md` §8.2 (German).

The agent MUST prefer updating an existing source of truth over creating a new one.

When the appropriate scope is ambiguous, the agent MUST ask rather than silently default to either extreme. Wider scope (greater discoverability across colleagues/sessions) is often safer than narrower scope (better fit but easier to lose), so ambiguity SHOULD NOT be resolved by reflexively picking the narrowest target.

If no appropriate durable location exists and creating one would materially change project documentation structure, the agent MUST ask before doing so.

## 2.3 Timing and duplication (MUST)

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

## 2.4 Workflow Artifact Retention (MUST)

Agent process artifacts MUST be organized by durability:

- `.aiassistant/state/` — durable, committed. Holds ticket maps, ledgers, final triage packets, evidence summaries, and any artifact intended to survive the session and remain reviewable.
- `.aiassistant/scratch/` — transient, gitignored. Holds WIP notes, backups, snapshots, precompare patches, ad-hoc working-delta dumps, and any artifact not intended to outlive the current task.

The agent MUST:

- write new transient artifacts under `.aiassistant/scratch/` by default,
- only promote an artifact into `.aiassistant/state/` when it has durable audit or continuation value,
- not commit `.aiassistant/scratch/` contents,
- remove `.aiassistant/scratch/` artifacts before finalizing unless the user explicitly requests retention.

For the legacy `.aiassistant/state/workflow-triage/` location: keep only durable final packets and evidence summaries there; transient working artifacts MUST move to `.aiassistant/scratch/`.

Projects SHOULD add `.aiassistant/scratch/**` to `.gitignore`.

If retention value is unclear, ask the user before committing artifact files.

---

# 3. Rule-Set Governance

## 3.1 Improvement policy (MUST)

Rule-set effectiveness and efficiency MUST be evaluated at each meta-checkpoint per §1.1. The Rule-set line of the checkpoint output reports the result.

If the agent identifies a meaningful improvement, it MUST propose it in a concise structure:

- problem,
- proposed change,
- expected impact,
- risk/tradeoff.

## 3.2 Change policy (SHOULD / MUST)

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
