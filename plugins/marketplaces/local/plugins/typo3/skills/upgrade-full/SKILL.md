---
name: upgrade-full
description: "Activate with /typo3:upgrade-full to run all three TYPO3 upgrade workflows consecutively in a single chained session (upgrade execution → ExtensionScanner → static code tests). Also activate /typo3:upgrade, /typo3:scanner, and /typo3:static-tests in the same session to make all workflow content available. Applies Batch.md §6 chaining model with a single toolset gate, single preflight, and one final Phase 9 handover for the full chain."
allowed-tools: [Read, Edit, Write, Glob, Grep, Bash]
---

# TYPO3 Full Upgrade Chain

This skill orchestrates the three TYPO3 workflow skills as a single chained execution
per `Batch.md` §6. It contains no workflow content of its own — activate the three
component skills alongside this one so all workflow content is in session context.

**Required skill activations (invoke all four in the same session):**
- `/typo3:upgrade-full` — this orchestration skill
- `/typo3:upgrade` — upgrade execution + DoD content
- `/typo3:scanner` — ExtensionScanner workflow content
- `/typo3:static-tests` — static code test workflow content

---

## Execution model: `Batch.md` §6 in full

Apply the Workflow Chaining model from `Batch.md` §6 exactly:

1. **Phase 0** (toolset gate): run once for the most demanding toolset requirements
   across all three workflows.
2. **Phase 1** (preflight): run once for the combined scope.
3. **Workflow 1 — `/typo3:upgrade`**: execute phases 2–9 to completion.
   - Produce inter-workflow handoff note: what was completed, what state the scanner
     workflow inherits, any open items.
4. **Workflow 2 — `/typo3:scanner`**: execute phases 2–9 to completion.
   - Produce inter-workflow handoff note: what was completed, what state the
     static-tests workflow inherits, any open items.
5. **Workflow 3 — `/typo3:static-tests`**: execute phases 2–9 to completion.
6. **Phase 9** (final handover): produce once for the full chain — covers all three
   workflows, combined compliance checklist from `General.md` §5.8.0, and final
   `Meta checkpoint:` result.

Each workflow MUST complete all its phases before the next begins. Do NOT interleave
phases across workflows.

---

## Autonomous mode

If the user activates autonomous mode for this chain, apply `Batch.md` §5 protocol
across the full scope. The scope confirmation statement MUST list all three workflows
and their phase sequence. Pass 3 items always suspend implementation for individual
approval regardless of autonomous mode, in any of the three workflows.

---

## Scope boundary

If work outside the declared scope is discovered during any workflow in the chain,
pause, report the item, and ask whether to extend scope before continuing. Do not
silently absorb out-of-scope findings into the running chain.
