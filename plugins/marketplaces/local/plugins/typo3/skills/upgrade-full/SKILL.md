---
name: upgrade-full
description: "Activate with /typo3:upgrade-full to run the full TYPO3 upgrade chain end-to-end in one invocation: upgrade execution → ExtensionScanner → static code tests. This orchestration skill invokes the three component skills (/typo3:upgrade, /typo3:scanner, /typo3:static-tests) in sequence via the Skill tool. Applies the /core:batch skill §6 chaining model with one combined toolset gate, one preflight, one chain-level autonomous-mode gate, and one final Phase 9 handover."
allowed-tools: [Read, Edit, Write, Glob, Grep, Bash, Skill]
---

# TYPO3 Full Upgrade Chain

This is an orchestration skill. It contains no workflow content of its own — it
invokes the three component workflow skills in sequence. The user (or auto-
activation) needs only this one invocation; the orchestrator activates the rest.

When a TYPO3 major upgrade runs under `/composer:major-upgrade`, this chain is the
TYPO3 `remediation-toolchain` invoked at that spine's Phase 5c (framework
remediation). Run standalone, it is the full TYPO3 upgrade chain in its own right.

**Component skills invoked by this orchestrator** (do NOT pre-activate them
manually — this skill invokes each via the `Skill` tool at the right time):

- `/typo3:upgrade` — upgrade execution + DoD
- `/typo3:scanner` — ExtensionScanner workflow
- `/typo3:static-tests` — static code test workflow

---

## Chain-level gates (run ONCE at the start; do NOT repeat per component)

### 0. Combined toolset gate

Run once for the most demanding toolset requirements across all three component
workflows. Component skills MUST NOT re-run their own toolset gate when invoked
from this orchestrator.

### 1. Combined preflight

Run once for the combined scope. Confirm the scope covers all three workflows.

### 2. Chain-level autonomous-mode gate (if autonomous activation is requested)

Apply the `/core:batch` skill §5 autonomous protocol ONCE at the chain level:

- the scope confirmation statement MUST list all three workflows and their phase
  sequence in order,
- user confirmation applies to the entire chain,
- the confirmed autonomous scope is passed to each component-skill invocation as
  context — **component skills MUST NOT re-prompt for autonomous confirmation
  when invoked from this orchestrator.**

Pass 3 items always suspend implementation for individual approval regardless of
autonomous mode, in any of the three workflows.

---

## Execution sequence

Each workflow completes its phases 2–9 before the next begins. Do NOT interleave
phases across workflows.

### Workflow 1 — upgrade

1. Invoke the `typo3:upgrade` skill via the `Skill` tool.
2. Pass in context: confirmed combined scope, chain-level autonomous confirmation
   (if applicable), and the instruction to "skip Phase 0 and Phase 1 — they ran at
   chain level".
3. The component executes its phases 2–9 to completion.
4. Capture the inter-workflow handoff note: what was completed, what state the
   scanner workflow inherits, any open items.

### Workflow 2 — scanner

1. Invoke the `typo3:scanner` skill via the `Skill` tool.
2. Pass in context: Workflow 1 handoff note; chain-level autonomous confirmation.
3. The component executes its phases 2–9 to completion.
4. Capture the handoff note for Workflow 3.

### Workflow 3 — static-tests

1. Invoke the `typo3:static-tests` skill via the `Skill` tool.
2. Pass in context: Workflow 2 handoff note; chain-level autonomous confirmation.
3. The component executes its phases 2–9 to completion.

### Final — chain-level Phase 9

Produce once for the full chain:

- summary spanning all three workflows,
- combined compliance checklist per the `/core:batch` skill §9.1,
- final `Meta checkpoint:` line per `Meta.md` §1.1.

---

## Scope boundary

If work outside the declared scope is discovered during any workflow in the chain,
pause, report the item, and ask whether to extend scope before continuing. Do not
silently absorb out-of-scope findings into the running chain.
