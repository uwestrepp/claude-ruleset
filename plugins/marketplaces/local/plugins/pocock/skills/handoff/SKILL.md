---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work.

*Input (`$ARGUMENTS`): what the next session will be used for, to focus the handoff.*

This skill produces the continuation-doc component of the `General.md` §10.3 handover bundle. If a `/core:batch` cycle is active, its §11.1 scratch note remains the in-cycle bookmark — incorporate that note's state into the handoff document instead of duplicating or replacing it.

## Where to save

- Save into the project's `.aiassistant/state/handoffs/` directory (repository / working-tree root). Create the directory if it does not exist. NEVER save to the OS temporary directory (`/tmp` or equivalent) — those are wiped on reboot and the handoff is lost.
- One handover = one file. Write a NEW file every time; never overwrite or edit an existing handoff, unless the user explicitly names an existing handoff file to update.
- Use a unique, descriptive filename: `handoff-<YYYYMMDD-HHMMSS>-<short-slug>.md`, where the timestamp comes from `date +%Y%m%d-%H%M%S` and the slug is derived from the handoff topic (or the passed arguments). If the chosen name already exists, pick a different one — do not replace it.

## Content

Include a "suggested skills" section in the document, which suggests skills that the agent should invoke.

Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
