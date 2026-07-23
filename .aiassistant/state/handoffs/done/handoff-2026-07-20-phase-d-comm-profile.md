# Handoff — Phase D: Colleague-facing Communication Profile

> **DONE 2026-07-20 (commit `7ed0473`).** Built `/core:communication` (core plugin):
> two-layer global/project profile for Jira/Bitbucket/Confluence output. Trimmed the
> CLAUDE.md "Atlassian Rovo MCP" block to keep only the two safety MUST-guards
> always-on (live-page-default, Jira comment-visibility); mechanics moved into the
> skill. Ledger + plugin.json updated; lint + rule-index-auditor clean. Skill name
> `/core:communication` and "always-on rule suffices (no hook now)" were user
> decisions. Comment-visibility PreToolUse-hook option recorded in the skill for
> later. Document retained for audit; no further action.

Created 2026-07-20. Resume target: `~/.claude` (rule-set repo, working branch `main`).
Recommended settings: `/effort high | claude-opus-4-8` (design-heavy).

## Goal

Build an **on-demand skill** capturing the profile for agent output directed at
**other people** (Jira, Bitbucket, Confluence) — NOT agent-to-user chat. Analog to
`/composer:knowledge` and the `/core:git-knowledge` built this session. Original
item: "Kommunikations-Profil bauen … inkl. Sprache, Markdown für Copy&Paste, load
on demand, entschlackt".

## Decisions already made (this session)

- **Two-layer split (confirmed with user):**
  - *Global* (the skill): colleague-facing German (§8.2 part), copy-paste raw-fence
    format (§8.6), typography (§8.5 part), the Atlassian MCP mechanics (live pages,
    `maxResults 10`, pagination, cloudId) and Bitbucket PR conventions, plus a
    learned MOSAIQ house-style/tone.
  - *Project-specific* (per-project `CLAUDE.md` / that project's auto-memory):
    contacts, PM-vs-direct-to-customer, Jira project key / Confluence spaceId,
    project ticket conventions.
- **Auto-memory is per-cwd (verified this session)** — so global comm-rules CANNOT
  live in auto-memory; only project-scoped comm-facts do.
- **SAFETY CAVEAT (load-bearing, do not violate):** the hard MUST-guards with damage
  potential — above all the Jira **comment-visibility restriction**
  (`commentVisibility: {type:"role", value:"Users"}`) and **live-page-by-default** —
  MUST NOT be moved off always-on onto a prompt-relevance-activated skill: a missed
  activation could leak a customer-visible comment. Keep those MUST-guards always-on
  (in `CLAUDE.md`) or enforce via a PreToolUse hook matching the MCP tool; only the
  *style/mechanics* migrate to the on-demand skill.
- **german-drafter (brainstorm also-ran) belongs here, not as a standalone agent:**
  a drafting sub-agent has weak §11.1 isolation value (the draft IS the deliverable
  that must surface). Treat drafting as skill guidance, optionally a companion agent.
- "Entschlacken" is real but modest: §8.5 (em-dash) and the chat-language part of
  §8.2 apply to *every* output and must stay always-on. Only the colleague-facing
  mechanics/style genuinely move on-demand.

## Open design questions (resolve in a design step BEFORE building)

1. Exactly which always-on lines move to the skill vs stay: the `CLAUDE.md`
   "Atlassian Rovo MCP" block (which parts are MUST-safety vs mechanics?), and the
   colleague-facing portions of §8.2/§8.5/§8.6.
2. How the always-on residual points to the skill — reuse the terse header-pointer
   pattern established for §12 → `/core:git-knowledge` (no content enumeration).
3. The "laufend schärfen" mechanism: where project comm-facts live and how they get
   updated from Jira/Bitbucket/Confluence history; whether a global house-style seed
   is captured now (and from where).
4. Whether comment-visibility should become a **hook** (PreToolUse matching the
   Atlassian comment MCP tool) so the guarantee is mechanical, not skill-dependent.
   (Note: hooks fire on tool calls; verify an MCP tool matcher is supported before
   relying on it — cf. `hooks/` + memory `ref_claude_code_hooks`.)

## Recommended plan

1. Design step first: `/core:grill-me` or `/core:poke-holes` on the two-layer design
   + the safety-guard placement, then converge.
2. Build the skill (structural template = `core/skills/git-knowledge/SKILL.md`),
   likely `/core:comms` (or `/core:communication`) in the core plugin.
3. Trim the migrated mechanics out of `CLAUDE.md`/§8.x, leave header pointers; keep
   MUST-guards always-on (or move to hook).
4. Update the `CLAUDE.md` skill ledger (§9.2) + core `plugin.json`; sync
   `exports/OnlineAgent.md` if the colleague-facing content is mirrored there.
5. Validate: `bash bin/lint-section-refs.sh`; optionally spawn `rule-index-auditor`
   for index/ledger/exports drift. Commit on `main` (standing override).

## Key files

- `rules/General.md` §8.2 / §8.5 / §8.6
- `CLAUDE.md` "Atlassian Rovo MCP" block (MUST-guards + mechanics)
- `CLAUDE.local.md` Bitbucket PR block (machine-local; do not commit its secrets)
- `exports/OnlineAgent.md` (has the §8.6 paste rule inline already)
- template: `plugins/marketplaces/local/plugins/core/skills/git-knowledge/SKILL.md`

## Trigger prompt (paste to resume)

> Lies `~/.claude/.aiassistant/state/handoffs/handoff-2026-07-20-phase-d-comm-profile.md`
> und den darin referenzierten Kontext. Setze Phase D um: das on-demand
> Kommunikations-Profil-Skill für colleague-facing Output (Jira/Bitbucket/Confluence),
> zweischichtig global/projekt, mit der Safety-Caveat für die MUST-Guards. Starte mit
> dem Design-Schritt (offene Fragen 1–4), dann bauen. `/effort high | claude-opus-4-8`.
