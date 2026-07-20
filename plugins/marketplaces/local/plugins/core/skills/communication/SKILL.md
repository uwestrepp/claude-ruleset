---
name: communication
description: "Activate via /core:communication or let Claude auto-activate when producing colleague-facing output — anything directed at other people rather than the user's chat: Jira issues/comments, Confluence pages/comments, Bitbucket PR titles/descriptions, or content the user will paste into one of those. Covers language (German), prose typography, copy-paste raw-fence format, Atlassian MCP mechanics (cloudId, search paging, page/comment drafting), Bitbucket PR conventions, the MOSAIQ house-style/tone, and where project-scoped comm-facts live and how to sharpen them. Triggers: \"schreib ein Jira-Ticket / einen Kommentar\", \"Confluence-Seite anlegen/aktualisieren\", \"PR-Beschreibung / pull request description\", \"formulier das für den Kunden / fürs Team\", drafting or updating any Jira/Confluence/Bitbucket surface via MCP or for paste. NOT agent-to-user chat replies, NOT git commit messages or in-repo developer docs (those stay English; commit drafting is /core:commits)."
argument-hint: [topic]
---

# Colleague-facing Communication Profile

Operational profile for output the agent produces for **other people** (Jira,
Confluence, Bitbucket), not for the user's chat. Normative keywords per
`General.md`. This skill is ADDITIVE and consolidates *style + mechanics*; it does
NOT restate or relocate the always-on baseline that stays in force whether or not
this skill is loaded:

- **Language / typography / paste format** — `General.md` §8.2 (output language),
  §8.5 (prose typography), §8.6 (copy-paste deliverables). Authoritative there;
  summarized here for application.
- **Two safety MUST-guards** — Confluence live-page-by-default and Jira
  comment-visibility restriction — stay always-on in the global `CLAUDE.md`
  "Atlassian Rovo MCP" block. They are load-bearing (a missed skill activation
  must never leak customer-visible content). This skill references them; the
  `CLAUDE.md` block is authoritative. Do NOT rely on this skill being loaded to
  apply them.

Two layers: this skill is the **global** layer (reusable style + mechanics).
**Project-scoped** comm-facts (contacts, PM-vs-direct-to-customer routing, Jira
project key, Confluence spaceId, non-MOSAIQ cloudId, ticket conventions) live in
the project's `CLAUDE.md` / `CLAUDE.local.md` and that project's auto-memory
(auto-memory is per-cwd, so global comm-rules cannot live there — only
project-scoped facts do). See §7.

---

## 1. Scope & boundary

In scope (write in German, per §2):
- Jira: issue summary/description/comments, worklogs.
- Confluence: page content, comments.
- Bitbucket: PR title and description.
- Any content handed to the user to paste into one of the above.

Out of scope (stays English, not this skill):
- agent-to-user chat replies (match the user's language; default English).
- git commit messages, code comments/DocBlocks/TODOs, repo `README.md` and in-repo
  developer docs. Commit drafting is `/core:commits`.

If the target surface is ambiguous (e.g. a release-notes artifact that is both a
repo file and a Confluence page), ask before writing (`General.md` §8.2).

## 2. Language & typography

- **German** for every colleague-facing surface above. Full orthographic
  correctness including umlauts and ß; never ASCII-substitute (`für`, not `fur`).
- **Typography** (`General.md` §8.5): no em-dash (`—`), no en-dash (`–`) as a
  sentence/parenthetical connector. Use comma, colon, parentheses, full stop, or a
  spaced plain hyphen. En-dash only in numeric ranges (10–20). Applies to all
  colleague-facing prose.
- Terse and scannable: lead with the point, lists over paragraphs where they aid
  reading (`General.md` §10.4).

## 3. Copy-paste deliverables (§8.6)

Content the user will paste into an external surface MUST be emitted as **raw
source inside a fenced code block**, never as chat-rendered markup:

- Outer fence longer than any fence inside the payload (four backticks around a
  payload that itself contains triple-backtick blocks).
- Title/summary line in its own fence, separate from the body.
- Payload language German (§2).

Offer-first (`General.md` §10.5): for token-heavy MCP writes (long Confluence
bodies, long Jira descriptions/comments) offer the paste path and wait, rather
than round-tripping the body through context. When offering the paste path for a
Confluence page, state that the pasted result can become a live page only via
manual conversion in the UI, not via MCP (see §5).

## 4. Atlassian MCP mechanics

- **cloudId**: use the project's configured cloudId; do NOT call
  `getAccessibleAtlassianResources`. For MOSAIQ the value is
  `https://mosaiq.atlassian.net` (recorded in the global `CLAUDE.md`); other
  projects record theirs per §7.
- **Search paging**: `maxResults: 10` / `limit: 10` for ALL Jira JQL and
  Confluence CQL searches; paginate until the end of the result set (or until the
  user asks for a sample only).
- **Safety guards (authoritative in `CLAUDE.md`, restated for convenience)**:
  - Confluence pages → live pages (`subtype: "live"`) by default; standard page
    only on explicit request. No page↔live conversion via MCP.
  - Every Jira comment → internal visibility: pass
    `commentVisibility: {type: "role", value: "Users"}` on every comment create
    AND update (an update omitting it can re-expose a restricted comment). If the
    "Users" role is unavailable, stop and ask. Success signal is the `visibility`
    object in the response; `jsdPublic: true` alongside it is a known
    mosaiq.atlassian.net false positive — do not flag.

## 5. Confluence page drafting

- Live page by default (§4). spaceId from the project's `CLAUDE.md` (§7); if
  absent, ask and persist it.
- Re-fetch the current version before editing an existing page; keep edits minimal
  and scoped; describe any semantic change and get confirmation; do not break
  existing anchors/headings/inbound links without flagging (cf. exports
  `OnlineAgent.md` §3 for the KB-write discipline).
- Prefer updating an existing source of truth over creating a parallel page.

## 6. Jira drafting

- Comment-visibility guard on every create/update (§4).
- Project key from the project's `CLAUDE.md` (§7); if absent, ask and persist it.
- Ticket resolution / no mixed-ticket commits is `/core:commits`; this skill
  covers the *prose*, not the ticket-to-commit mapping.
- Persist ticket-scoped findings/decisions on the ticket where team-visible value
  exists (`Meta.md` §2.2), always under the internal-visibility guard.

## 7. Bitbucket PR conventions

Generic pattern (project specifics + secrets live in the project's
`CLAUDE.local.md`, never here):

- Create/check PRs via the Bitbucket REST API.
- Auth: HTTP Basic with the user's e-mail as username and the API token as
  password. Read the token on demand from its gitignored path; never echo it into
  chat or commit it.
- Before creating a PR: verify the source branch is pushed, and check for an
  existing open PR from the same source branch.
- PR title and description in German (§2), raw-fence when handed for paste (§3).
- Base endpoint, workspace/repo, credential path, and the preferred PR target
  branch are project facts — read them from the project's `CLAUDE.local.md`.

## 8. House-style seed (MOSAIQ)

Verified baseline (apply now):
- German, professionally phrased, correct orthography (§2).
- Typography per §8.5; paste format per §8.6.
- Concise and structured; state the point first, avoid filler.

To sharpen per project (do NOT invent — observe from real Jira/Confluence/Bitbucket
history or ask, then persist per §9):
- Salutation and register (Sie vs du; team-internal vs customer-facing tone).
- PM-mediated vs direct-to-customer routing (who the audience actually is).
- Ticket-description structure conventions (acceptance-criteria format, labels).

This section is a seed, not a finished style guide; treat its "to sharpen" items
as unknowns until grounded.

## 9. Project comm-facts & the refinement loop ("laufend schärfen")

- **Before drafting**, read the project's `CLAUDE.md` / `CLAUDE.local.md` and the
  project's auto-memory for comm-facts (§7 list, house-style specifics).
- **When a new comm-fact is confirmed** (a contact, a routing rule, a spaceId, a
  tone convention observed in real history), persist it to the correct scope
  (`Meta.md` §2.2): project-scoped facts → project `CLAUDE.md` / project
  auto-memory; a genuinely reusable global style refinement → propose updating
  §8 of this skill.
- Do not fabricate house-style; ground each convention in observed history or an
  explicit user statement before persisting it.

## 10. Onboarding a new project

If the Jira project key or Confluence spaceId is not yet recorded, ask for it and
persist it in the project's `CLAUDE.md` before the first Atlassian write.

---

Note (deferred): the comment-visibility guard could be hardened into a mechanical
`PreToolUse` hook matching the Atlassian comment MCP tool (fail-closed block when
`commentVisibility` is absent), making the guarantee activation-independent. Not
built (user decision 2026-07-20: always-on rule suffices); recorded here so the
option is not lost. Prerequisite before relying on it: verify an `mcp__*` tool
matcher is supported (cf. memory `ref_claude_code_hooks`).
