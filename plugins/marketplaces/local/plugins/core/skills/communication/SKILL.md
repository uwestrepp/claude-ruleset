---
name: communication
description: "Activate via /core:communication or let Claude auto-activate when producing colleague-facing output (directed at other people, not the user's chat): Jira issues/comments, Confluence pages/comments, Bitbucket PR titles/descriptions, the wording/register of git commit messages, or content the user will paste into those. Owns the authoritative language mapping (German for Jira/Confluence/Bitbucket, English for commit messages), prose typography, copy-paste raw-fence format, Atlassian MCP mechanics, Bitbucket PR conventions, and the MOSAIQ house-style / Sprechweise directory (how we communicate per audience: devs, PMs, customers), plus where project-scoped comm-facts live and how to sharpen them. Triggers: \"schreib ein Jira-Ticket / einen Kommentar\", \"Confluence-Seite anlegen/aktualisieren\", \"PR-Beschreibung\", \"formulier das für den Kunden / fürs Team\", \"wie schreiben wir das intern/an den Kunden\". NOT the commit schema/ticket resolution (/core:commits), NOT agent-to-user chat, NOT in-repo README/code comments."
argument-hint: "[topic]"
---

# Colleague-facing Communication Profile

*Input (`$ARGUMENTS`): optionally the topic or surface to draft for.*

Operational profile for output the agent produces for **other people** (colleagues,
teams, customers), not for the user's chat. This is where the "how do we talk to
each other and outward" knowledge lives (§8). Normative keywords per `General.md`.

**Authority split with the always-on baseline.** `General.md` §8.2 (language), §8.5
(typography) and §8.6 (paste format) keep only a terse always-on *kernel* (so chat
and commit prose stay covered even when this skill is not loaded); the **full**
rules live here and are authoritative:

- §8.2 language mapping → this skill §2.
- §8.5 prose typography → this skill §2.
- §8.6 copy-paste deliverables → this skill §3.

Two **safety** MUST-guards do NOT live here — they stay always-on in the global
`CLAUDE.md` "Atlassian Rovo MCP" block because a missed skill activation must never
leak customer-visible content: Confluence live-page-by-default and Jira
comment-visibility restriction. This skill references them (§4); `CLAUDE.md` is
authoritative. Do NOT rely on this skill being loaded to apply them.

Two layers: this skill is the **global** layer (reusable rules + house-style).
**Project-scoped** comm-facts (contacts, PM-vs-direct-to-customer routing, Jira
project key, Confluence spaceId, non-MOSAIQ cloudId, per-audience register, ticket
conventions, glossary) live in the project's `CLAUDE.md` / `CLAUDE.local.md` and
that project's auto-memory (auto-memory is per-cwd, so global comm-rules cannot live
there — only project-scoped facts do). See §9.

---

## 1. Scope & boundary

Colleague-facing communication = output addressed to other people. It spans two
language regimes:

- **German surfaces**: Jira (issue summary/description/comments, worklogs),
  Confluence (page content, comments), Bitbucket PR title and description, and any
  content handed to the user to paste into these.
- **English surface**: git commit messages. They are colleague-facing (other devs
  read them), so this skill's typography (§2) and register (§8) apply, but their
  language stays English and their *schema/ticket resolution* is `/core:commits`,
  not this skill.

Out of scope (not colleague communication):
- agent-to-user chat replies (match the user's language; default English).
- in-repo developer artifacts: `README.md` and equivalents, code
  comments/DocBlocks/TODOs. English, in-repo docs, not this skill.

If the target surface is ambiguous (e.g. a release-notes artifact that is both a
repo file and a Confluence page), ask before writing (`General.md` §8.2).

## 2. Language & typography

**Language mapping** (`General.md` §8.2 keeps the kernel; this is the full rule):
- German: Jira, Confluence, Bitbucket PR title/description, and paste content for
  those. Full orthographic correctness including umlauts and ß; never
  ASCII-substitute (`für`, not `fur`; `löschen`, not `loeschen`).
- English: git commit messages (colleague-facing but English), plus the in-repo
  artifacts named in §1.
- Chat replies match the user's language (default English).
- A project or the user MAY override these mappings; record the override in the
  project's `CLAUDE.md`.

**Prose typography** (`General.md` §8.5): no em-dash (`—`) in any prose; no en-dash
(`–`) as a sentence or parenthetical connector (both read as machine-generated).
Use a comma, colon, parentheses, full stop, or a spaced plain hyphen. En-dash only
in numeric ranges (10–20); plain hyphen (`-`) unaffected. Out of scope: code,
identifiers, quoted external text, and agent-facing instruction files (rule-set,
`CLAUDE.md`, skill definitions). Applies to every colleague-facing surface AND to
commit messages and chat.

**Brevity**: lead with the point, lists over paragraphs where they aid reading
(`General.md` §10.4).

## 3. Copy-paste deliverables (§8.6)

Content the user will paste into an external surface MUST be emitted as **raw source
inside a fenced code block**, never as chat-rendered markup:

- Outer fence longer than any fence inside the payload (four backticks around a
  payload that itself contains triple-backtick blocks).
- Title/summary line in its own fence, separate from the body.
- Payload language per §2.

Offer-first (`General.md` §10.5): for token-heavy MCP writes (long Confluence
bodies, long Jira descriptions/comments) offer the paste path and wait, rather than
round-tripping the body through context. When offering the paste path for a
Confluence page, state that the pasted result can become a live page only via manual
conversion in the UI, not via MCP (see §5).

## 4. Atlassian MCP mechanics

- **cloudId**: use the project's configured cloudId; do NOT call
  `getAccessibleAtlassianResources`. For MOSAIQ the value is
  `https://mosaiq.atlassian.net` (recorded in the global `CLAUDE.md`); other
  projects record theirs per §9.
- **Search paging**: `maxResults: 10` / `limit: 10` for ALL Jira JQL and Confluence
  CQL searches; paginate until the end of the result set (or until the user asks
  for a sample only).
- **Safety guards (authoritative in `CLAUDE.md`, restated for convenience)**:
  - Confluence pages → live pages (`subtype: "live"`) by default; standard page
    only on explicit request. No page↔live conversion via MCP.
  - Every Jira comment → internal visibility: pass
    `commentVisibility: {type: "role", value: "Users"}` on every comment create AND
    update (an update omitting it can re-expose a restricted comment). If the
    "Users" role is unavailable, stop and ask. Success signal is the `visibility`
    object in the response; `jsdPublic: true` alongside it is a known
    mosaiq.atlassian.net false positive — do not flag.

## 5. Confluence page drafting

- Live page by default (§4). spaceId from the project's `CLAUDE.md` (§9); if absent,
  ask and persist it.
- Re-fetch the current version before editing an existing page; keep edits minimal
  and scoped; describe any semantic change and get confirmation; do not break
  existing anchors/headings/inbound links without flagging (cf. exports
  `OnlineAgent.md` §3 for the KB-write discipline).
- Prefer updating an existing source of truth over creating a parallel page.
- Register per audience (§8): architecture/runbook pages skew technical; status or
  stakeholder pages skew top-line.

## 6. Jira drafting

- Comment-visibility guard on every create/update (§4).
- Project key from the project's `CLAUDE.md` (§9); if absent, ask and persist it.
- Ticket resolution / no mixed-ticket commits is `/core:commits`; this skill covers
  the *prose and register*, not the ticket-to-commit mapping.
- Persist ticket-scoped findings/decisions on the ticket where team-visible value
  exists (`Meta.md` §2.2), always under the internal-visibility guard.
- Register per audience (§8): a dev-facing bug ticket differs in tone and detail
  from a customer-facing or PM-facing ticket.

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

## 8. MOSAIQ house-style & Sprechweise (how we communicate)

This is the directory of *how* communication happens at MOSAIQ, organised by
audience and register. It is the central purpose of this skill: not only mechanics,
but the register and tone we use with each audience. It is a living directory — a
seed with clearly marked unknowns, sharpened over time per §9. Ground every register
choice in observed history (real Jira/Confluence/Bitbucket text) or an explicit user
statement before treating it as settled; until then, treat it as a default to
verify, not a fact.

**Always-on baseline (applies to every audience, verified):**
- Language per §2 (German for colleague surfaces; English for commit messages),
  full orthographic correctness.
- Typography per §2 (no em-dash / connector en-dash).
- Concise and structured: state the point first, then detail; lists over prose
  where they aid reading; no filler.

**Two tiers of audience:**

- **Technical / internal (dev-to-dev)** — commit messages, PR descriptions, code
  review, technical Jira tickets/comments, technical Confluence (architecture,
  runbooks).
- **Top-line / outward** — PMs and internal non-technical stakeholders; customers.

**Register directory (seed — sharpen per project, do NOT invent specifics):**

| Audience | Sprache | Anrede / Register | Ton | Detailtiefe & Jargon | Format |
|----------|---------|-------------------|-----|----------------------|--------|
| Dev (intern) | DE (Jira/Confluence/PR), EN (Commit/Code) | *beobachten* (intern oft `du`) | sachlich, direkt, knapp | hoch; Fachjargon zulässig | strukturiert: Listen, Codeblöcke, Akzeptanzkriterien |
| PM / interne Nicht-Tech | DE | *beobachten* | sachlich, ergebnisorientiert | mittel; Jargon reduzieren oder erklären | Zusammenfassung zuerst, dann Details |
| Kunde / extern | DE (sofern nicht anders vereinbart) | `Sie` als konservativer Default — **pro Kunde verifizieren** | professionell, freundlich, verbindlich | outcome-fokussiert; kein internes Jargon, kein Debug-Detail | klar, geführt; Routing beachten (Kunden oft über PM, nicht direkt) |

The `du`/`Sie` register, customer-specific tone, PM-vs-direct routing, and any
terminology/glossary are **unknowns until grounded** (§9). The table's non-verified
cells (`beobachten`, "konservativer Default") are placeholders, not house-style
facts; do not present them to a colleague or customer as settled MOSAIQ policy.

**PM detail-tightening (observed pattern, anchor: GMP 2026-07 via /core:comm-calibrate).**
When condensing a technical draft for a PM / non-tech-internal reader, the draft→sent delta
consistently showed these moves; apply them pre-emptively rather than leaving them for the human:
- drop over-precise single-run metrics ("Score 77/83" → "Score Home / Listing");
- collapse internal breakdowns and repo paths into one pointer ("... im Repository dokumentiert");
- keep the honesty calibration explicit: Konjunktiv for hypotheticals ("wäre reine Verbesserung"),
  attribute measurement limits to their source ("vom Agent nicht messbar"), prefer precise terms
  ("nicht beobachtet" statt "ungenutzt"), spell out technical qualifiers ("mit brotli Kompression").
This concretises the PM row's "mittel; Jargon reduzieren"; observed pattern (1 ticket), not yet hard policy.

**To sharpen per project (do NOT fabricate):**
- salutation and register per audience (`du`/`Sie`, internal vs external tone),
- PM-mediated vs direct-to-customer routing (who the audience actually is),
- ticket-description structure conventions (acceptance-criteria format, labels),
- domain terminology / glossary (product names, house terms).

## 9. Project comm-facts & the refinement loop ("laufend schärfen")

- **Before drafting**, read the project's `CLAUDE.md` / `CLAUDE.local.md` and the
  project's auto-memory for comm-facts (§7 list, §8 register directory).
- **When a new comm-fact is confirmed** (a contact, a routing rule, a spaceId, a
  `du`/`Sie` convention or tone observed in real history), persist it to the correct
  scope (`Meta.md` §2.2): project-scoped facts → project `CLAUDE.md` / project
  auto-memory; a genuinely reusable global style refinement → propose updating §8 of
  this skill.
- Do not fabricate house-style; ground each convention in observed history or an
  explicit user statement before persisting it. This is how the §8 directory grows
  from a seed into a real MOSAIQ Sprechweise reference.
- **Inbound mining arm:** to derive comm-facts *from* a real received artifact (a
  ticket, PR, comment, or a "you suggested X, I sent Y" correction) rather than as a
  by-product of drafting, use `/core:comm-calibrate`. It extracts against the §8
  schema and writes back to these same §9 targets.

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
