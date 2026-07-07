# Updating the `pocock` plugin from upstream

These skills are **vendored** (copied) from [`mattpocock/skills`](https://github.com/mattpocock/skills),
not symlinked, because local copies diverge from upstream (frontmatter flags, Jira/PHP adaptation).
`provenance.json` records the upstream path + the SHA-256 of the **unadapted** `SKILL.md` at vendor time
(2026-06-15), so a future refresh can detect upstream changes.

## Local adaptations applied at vendor time

- `diagnose/SKILL.md` — added `disable-model-invocation: true` (overlaps the built-in diagnose; manual-only).
- `grill-with-docs/SKILL.md` — added `disable-model-invocation: true` (depends on CONTEXT.md/ADR conventions; manual-only).
- `zoom-out/SKILL.md` — upstream already ships `disable-model-invocation: true`; unchanged.
- `handoff/SKILL.md` — save target changed from the OS temp dir to the project's `.aiassistant/state/handoffs/` (OS temp is wiped on reboot → handoff lost); added unitary-file + non-destructive-write rules (one handover = one timestamped file, never overwrite an existing handoff). Re-apply on any upstream refresh.
- All others vendored verbatim. Illustrative Node/pnpm/Stripe examples were left intact (generic enough; "or equivalent task runner").

## Refresh procedure

1. Fetch the current upstream file for a skill at its `skillPath` (see `provenance.json`).
2. Compute its SHA-256 and compare to the recorded `computedHash`.
   - **Unchanged** → nothing to do.
   - **Changed** → review the upstream diff, then re-apply the local adaptations above on top of the new content.
3. Update the skill's `computedHash` (and `vendoredAt`) in `provenance.json`.

## Deliberately NOT ported (with reason)

- `setup-matt-pocock-skills` — rewrites CLAUDE.md/AGENTS.md + scaffolds `docs/agents/`; collides with the governed CLAUDE.md rule index.
- `git-guardrails-claude-code` — blocks ALL `git push`, breaking the feature-branch PR workflow.
- `grill-me` — superseded by `/core:grill-me`.
- `write-a-skill` — superseded by `plugin-dev:skill-development`.
- `review`, `to-issues`, `to-prd`, `triage`, `qa` — GitHub/GitLab-issue-tracker centric; this account uses Jira/Confluence via the Atlassian MCP.
- `tdd`, `setup-pre-commit`, `migrate-to-shoehorn` — TypeScript/Node ecosystem (husky, npx, shoehorn); wrong stack.
- `obsidian-vault`, `edit-article`, `writing-beats`, `writing-fragments`, `writing-shape`, `teach`, `scaffold-exercises`, `ubiquitous-language` — personal/writing/teaching, out of engineering scope.
