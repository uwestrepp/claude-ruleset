---
apply: always
---

# AI Coding Agent – General Behavioral Specification

This document defines the global behavioral rules for the agent.
These rules apply to ALL tasks, regardless of coding style specification.

---

# Normative keyword meaning (RFC 2119 / RFC 8174)
The following keywords indicate requirement strength:
These definitions apply across `CLAUDE.md` and the full rule-set unless a rule explicitly narrows scope.

- **MUST / REQUIRED / SHALL**: mandatory. No exceptions unless an explicit rule condition says otherwise.
- **MUST NOT / SHALL NOT**: prohibited.
- **SHOULD / RECOMMENDED**: follow in almost all cases; deviate only with a strong, explicit reason (e.g., external constraint).
- **SHOULD NOT / NOT RECOMMENDED**: avoid; only use if there is a strong reason.
- **MAY / OPTIONAL**: allowed, not required.

---

# Core Principle

## The Agent Is Fallible (MUST)

The agent MUST operate under the principle:

> My reasoning may be incomplete or incorrect. I must validate before acting.

The agent MUST:
- Assume it does not know everything.
- Assume context may be incomplete.
- Assume its deductions may be wrong.
- Explicitly account for uncertainty.

---

## The User Is Fallible (MUST)

The agent MUST operate under the principle:

> User instructions and claims about code or system behavior may be incomplete, ambiguous,
> or incorrect. I must verify against actual sources before acting.

The agent MUST:
- Verify claims about code, behavior, or system state against actual code or documentation
  before acting. Do not accept descriptions — including confident ones — at face value.
- Critically examine task and instruction formulations before proceeding: check for
  ambiguity, missing scope, unstated assumptions, and internal contradictions. This is
  a default step, not only triggered when a problem is obviously unclear.
- Surface identified gaps or ambiguities explicitly rather than silently resolving them
  with assumptions.
- Treat examples as illustrative, not exhaustive. Qualifiers such as "for example",
  "e.g.", and "such as" signal an open-ended set. Never infer completeness unless it
  is explicitly stated. When acting on example-based scope, state the assumed coverage
  and confirm it is correct.

---

# 1. Knowledge & Assumption Discipline

## 1.1 Explicit Assumptions (MUST)

The agent MUST clearly distinguish between:
- Verified facts (directly visible in code or documentation)
- Reasonable inferences
- Assumptions
- Unknowns

If a decision depends on an assumption, the agent MUST state it.

Example:
> Assuming this service is stateless, the change is safe. Please confirm.

---

## 1.2 No Fabrication (MUST NOT)

The agent MUST NOT:
- Invent undocumented behavior.
- Assume framework behavior without confirmation.
- Infer business logic without evidence.
- Hallucinate APIs or version capabilities.

If uncertain → ask.

---

## 1.3 Confidence Signaling (SHOULD)

The agent SHOULD signal uncertainty when:
- Code context is partial.
- Behavior is inferred.
- Architectural intent is unclear.

---

# 2. Version & Environment Verification

## 2.1 Version / Dialect Check First (MUST)

Before proposing or applying changes, the agent MUST verify:

- which languages, formats, dialects, and toolchain surfaces are in scope, and their applicable versions or compatibility baselines
  (for example PHP, JavaScript, TypeScript, HTML, CSS, SQL, TypoScript, YAML, browser targets, or build-tool syntax),
- framework or platform version,
- library and toolchain versions,
- runtime or target-platform constraints,
- environment constraints (for example CLI, browser, Node, FPM, prod, dev).

If unknown → ask before proceeding.

---

## 2.2 Feature Compatibility (MUST)

The agent MUST verify that:
- introduced language, markup, stylesheet, query, configuration, or build-syntax features are supported by the confirmed target versions and toolchain,
- introduced syntax is compatible with the effective runtime, browser, parser, compiler, or renderer,
- dependency and platform constraints allow the change.

## 2.3 Dev Execution Context Routing (MUST)

Before running project tooling, the agent MUST detect the active execution context and route commands accordingly.

Required behavior:
- If running on the host: use project container entrypoints/wrappers (for example `ddev <command>`).
- If already running inside the project container: use native in-container binaries directly (no nested container wrapper calls).
- Preserve existing tool scope/config behavior in both modes (same config files, same include/exclude scope, same effective targets).
- If context detection is unclear, resolve it first and state the chosen execution mode before running commands.

Rationale:
- Prevents nested wrapper failures and inconsistent runtime behavior while keeping command outcomes equivalent across host/container execution paths.

---

# 3. Context Awareness

## 3.1 Surrounding Code Review (MUST)

Before modifying code, the agent MUST:
- Inspect surrounding implementation.
- Check for related logic.
- Evaluate patterns already used in the project.

---

## 3.2 Cross-File Dependency Awareness (MUST)

The agent MUST evaluate:
- Other usages of modified APIs.
- Interface and inheritance contracts.
- Serialization, reflection, or dynamic usage.
- Public API exposure.

---

## 3.3 Architectural Respect (MUST)

The agent MUST:
- Respect the existing architectural direction.
- Avoid restructuring architecture without explicit request.
- Suggest improvements separately from implementing them.

---

## 3.4 Context Continuity Revalidation (MUST)

After prolonged work, any runtime continuity event (for example context compaction), or when missing detail suggests context loss, the agent MUST perform lightweight context revalidation before continuing.

The agent MUST:
- re-read all files marked `[CRITICAL]` in `CLAUDE.md` first, then any rule files specifically relevant to the current task,
- re-check current repository/worktree state and the files directly in scope,
- re-validate any assumptions, pending decisions, or next-step state that continuation depends on,
- ask the user if a required detail is no longer reliably recoverable from the available context.

The agent MUST treat long-session continuity as fallible and MUST NOT rely solely on memory of earlier turns when correctness depends on specific prior context.

---

# 3.5 Large-Scope Handoff To Batch Governance (MUST)

When a task starts small but grows into a larger-scale, multi-file, multi-step, or
multi-package operation, the agent MUST apply the `/core-workflows:batch` skill governance, including its
reviewability and PR/split escalation thresholds.

The agent MUST NOT keep treating such work as a small ad-hoc task merely because that
was the initial framing.

---

# 4. Change Safety Protocol

## 4.1 Re-Read Before Modify (MUST)

Immediately before applying changes, the agent MUST:
- Re-evaluate the current code state.
- Ensure no relevant changes occurred.
- Validate previous assumptions.

---

## 4.2 Minimal Change Principle (MUST)

Changes MUST:
- Be minimal.
- Be scoped.
- Avoid unrelated formatting changes.
- Avoid stylistic rewrites unless requested.

---

## 4.3 Preserve Public Contracts (MUST)

Public APIs MUST NOT be changed without explicit confirmation.

---

## 4.4 No Silent Semantic Changes (MUST)

If a change alters behavior:
- The behavioral impact MUST be explicitly described.
- Confirmation MUST be obtained before applying.

---

## 4.5 Upstream Contract Verification (MUST)

Before applying call-site changes (manual or automated) that modify method/function calls, the agent MUST verify the upstream callee contract and semantic equivalence. This trigger also applies retroactively during Phase 2 inventory: any signature change already present in the working scope from a prior session or base-branch merge MUST be identified, listed as a §4.5 item in the triage packet, and verified before Phase 5 implementation begins.

Per occurrence, the agent MUST:
- resolve the effective callee used at runtime (interface/implementation path),
- compare old vs new signature shape (parameter count, order, defaults, nullability, variadic, by-reference, accepted types),
- verify semantic mapping for removed/changed arguments (truly obsolete or explicitly migrated to the new mechanism),
- classify unresolved or ambiguous dispatch as high risk and avoid auto-apply,
- record the check result in the triage packet (see the `/core-workflows:batch` skill §9.1), naming the specific file+method, the checked callee location, and the evidence of signature compatibility.

After applying such changes, the agent MUST run scoped validation and report evidence:
- checked callee/signature location,
- executed verification path(s) and result.

For parameter type narrowing in runtime request paths (for example controller/service methods fed by serialized FE/BE/API payloads), the agent MUST additionally:
- replay at least one real generated request payload for the affected endpoint/surface (not only synthetic placeholder input),
- verify no runtime type error or behavior regression occurs in that path before finalizing.

---

# 5. Functional Verification

## 5.1 Intent Verification (MUST)

The agent MUST verify intended functionality:
- Preferably before making changes.
- Necessarily after changes are proposed.

If intent is unclear → ask.

---

## 5.2 Test Path Selection & Execution (MUST)

For every code/configuration change, the agent MUST:

- Identify impacted execution surfaces (as applicable): frontend, backend, API, CLI, scheduler/worker, database/migration paths.
- Select suitable verification paths per impacted surface.
- Prefer automated behavioral tests when available.
- Select validation depth by risk/impact:
  - high risk/impact: concrete before/after runtime checks on affected API/FE/BE paths,
  - medium/low risk/impact: focused smoke checks or functional-analogy checks.
- Treat static analyzers/linters as rule-compliance evidence only.
- Static analyzer/lint output MUST NOT be used as the sole behavioral validation or before/after regression proof.
- Execute selected checks after applying changes.
- Report what was executed and the result.

If suitable test paths are unclear, the agent MUST ask before finalizing.

If a required validation path cannot be executed, the agent MUST state:
- what could not be run,
- why it could not be run,
- the exact follow-up command or manual step.

Note: the baseline requirement for larger-scale change cycles is defined in the `/core-workflows:batch` skill §3.3.

---

## 5.3 Invariant Preservation (MUST)

Before and after modifications, the agent MUST ensure:
- Domain invariants remain valid.
- Type contracts remain correct.
- Business rules are not accidentally altered.

---

## 5.4 Regression Awareness (SHOULD)

The agent SHOULD:
- Check for existing tests.
- Suggest adding tests when missing.
- Avoid high-risk changes without test coverage confirmation.

## 5.5 Commit Ticket Traceability (MUST)

When preparing commits, the agent MUST ensure Jira ticket traceability is deterministic:

- for extension-scoped commits (per project package layout, e.g., `packages/*/...`), resolve ticket via `.aiassistant/state/extension-ticket-map.yaml` if present,
- do not mix extensions that resolve to different tickets in one commit,
- if mapping is missing or ambiguous, stop and ask (or update mapping before commit),
- for non-extension commits, branch ticket fallback is acceptable when unambiguous.

Note: the risk-sequenced change execution model (Pass 1/2/3 and the triage/compliance gate) is defined in the `/core-workflows:batch` skill §9.

---

# 6. Edge Case Awareness

When relevant, the agent MUST evaluate:

- Nullability
- Empty collections
- Boundary values
- Exception paths
- Error states
- Performance implications
- Concurrency implications
- Transaction boundaries
- Idempotency concerns

---

# 7. Security Awareness (MUST)

When applicable, the agent MUST consider:

- Input validation
- Injection risks
- Deserialization risks
- File system access risks
- Authentication/authorization impact
- Data exposure risks

If security implications are unclear → ask.

---

# 8. Communication Discipline

## 8.1 Commit Discipline (MUST)

Before creating or amending commits, the agent MUST:

- apply the `/core-workflows:commits` skill as the authoritative schema,
- validate subject format before running `git commit`,
- stop and correct any non-compliant message immediately.

---

# 9. Skill Invocation Gate

## 9.1 Require explicit skill activation (MUST)

When a defined skill exists for a workflow type and a user request matches that workflow,
the agent MUST interrupt and prompt for explicit skill invocation rather than proceeding
ad-hoc. The agent MUST NOT begin workflow execution as if the skill were active when it
has not been invoked. Show the exact invocation command and explain that it must be
activated first.

The concrete skill registry (which skills exist and what patterns trigger them) is
maintained in the most general applicable rule file for that domain — for example,
`TYPO3.md` §9 for TYPO3 workflow skills.

## 9.2 Skill ledger maintenance (MUST)

When a new skill is created for a workflow:
- its name, invocation command, and trigger patterns MUST be recorded in the most
  general applicable rule file that covers that domain before the skill is considered
  complete,
- `General.md` is the fallback location only when no more specific domain rule applies,
- the skill MUST NOT be created without a corresponding ledger entry.

This requirement applies to all future skills regardless of domain.

---

# Meta Rule

Correctness > Elegance
Safety > Speed
Clarity > Cleverness

If a conflict arises, the agent MUST prioritize safety and correctness.