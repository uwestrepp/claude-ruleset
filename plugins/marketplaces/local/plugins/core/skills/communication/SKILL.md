---
name: communication
description: "Activate via /core:communication or let Claude auto-activate when producing colleague-facing output (directed at other people, not the user's chat): Jira issues/comments, Confluence pages/comments, Bitbucket PR titles/descriptions, the wording/register of git commit messages, or content the user will paste into those. Owns the authoritative language mapping (German for Jira/Confluence/Bitbucket, English for commit messages), prose typography, copy-paste raw-fence format, Atlassian MCP mechanics, Bitbucket PR conventions, and the MOSAIQ house-style / Sprechweise directory (how we communicate per audience: devs, OM, PMs, customers), plus where project-scoped comm-facts live and how to sharpen them. Triggers: \"schreib ein Jira-Ticket / einen Kommentar\", \"Confluence-Seite anlegen/aktualisieren\", \"PR-Beschreibung\", \"formulier das für den Kunden / fürs Team\", \"wie schreiben wir das intern/an den Kunden\". NOT the commit schema/ticket resolution (/core:commits), NOT agent-to-user chat, NOT in-repo README/code comments."
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
- Payload format: for any target that renders Markdown input (Jira, Bitbucket,
  Confluence at minimum), write the payload AS Markdown (headings, bold, lists,
  inline code) so it renders on paste. Fall back to plain text only for a target
  without Markdown support (e.g. plain-text e-mail).
- **No hard wrapping.** Do NOT break payload prose at a column limit: one paragraph
  or list item = one line, newlines only between blocks. Hard wraps survive the
  paste as real newlines and force manual cleanup, which is easily missed (observed
  SSBSITE-1258 2026-07-30: a wrap landed mid-sentence in the posted Jira comment).
  The target wraps by itself. For a long payload, additionally offer the file path
  (`SendUserFile`) so the user can copy from the file instead of the terminal.

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
- **Token scope**: the local token (`~/.claude/.bitbucket-api-token`, valid to
  2027-03) is Bitbucket-only; Jira REST (`/rest/api/3/*`) answers 401/404 with it.
  There is NO local Jira REST fallback: Jira access runs exclusively through the
  Rovo MCP. Auth form is Basic with the Atlassian e-mail as user
  (`curl -u <email>:$TOKEN`); `Authorization: Bearer` and `-u x-token-auth:` are
  both rejected — do not misread either as an expired token.
- **MCP can hang silently**: every call (even `atlassianUserInfo`) may stall to the
  300s idle timeout with no error. Probe with one lightweight call before an
  expensive call series; on timeout do NOT retry (5 min per attempt) — ask the user
  to paste the ticket content instead.

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

**Three tiers of audience:**

- **Technical / internal (dev-to-dev)** — commit messages, PR descriptions, code
  review, technical Jira tickets/comments, technical Confluence (architecture,
  runbooks).
- **Fachseite / internal non-dev** — OM (Online Marketing) and PMs. Internal, but
  the subject matter is theirs, not the implementation.
- **Outward** — customers, and any text a PM forwards to them.

**Register directory (seed — sharpen per project, do NOT invent specifics):**

| Audience | Sprache | Anrede / Register | Ton | Detailtiefe & Jargon | Format |
|----------|---------|-------------------|-----|----------------------|--------|
| Dev (intern) | DE (Jira/Confluence/PR), EN (Commit/Code) | *beobachten* (intern oft `du`) | sachlich, direkt, knapp | hoch; Fachjargon zulässig | strukturiert: Listen, Codeblöcke, Akzeptanzkriterien |
| OM (Online Marketing, intern) | DE | `du` (verifiziert, s. u.) | sachlich, knapp, kein Rechtfertigungston | Ergebnis + Status + nächster Schritt; **keine** Ursachenanalyse, keine technischen Hintergründe, keine Begründungsketten | kurze Nachricht statt Report; höchstens eine Zwischenüberschrift, und nur für einen eigenen Handlungspunkt |
| PM (intern) | DE | *beobachten* | sachlich, ergebnisorientiert | wie OM im Grundsatz; mittel, Jargon reduzieren oder erklären | Zusammenfassung zuerst, dann Details |
| PM (zur Weitergabe an Kunden) | DE | wie Kunde/extern | wie Kunde/extern | **erbt die Kunde/extern-Zeile**: der Text verlässt den internen Raum | kundenfertig; keine internen Verweise, keine Infrastruktur-Interna, keine Namen interner Systeme oder Personen |
| Kunde / extern | DE (sofern nicht anders vereinbart) | `Sie` als konservativer Default — **pro Kunde verifizieren** | professionell, freundlich, verbindlich | outcome-fokussiert; kein internes Jargon, kein Debug-Detail | klar, geführt; Routing beachten (Kunden oft über PM, nicht direkt) |

**OM vs PM is not interchangeable.** OM owns the marketing subject matter (campaigns,
accounts, dashboards, reporting); a coordinating tone (assigning tasks, chasing
status) does NOT make someone a PM. Misfiling an OM contact as PM was a real
2026-08-17 error. Per project, record who is which (§9).

**Before writing for PM, resolve the fork:** internal, or meant for onward delivery
to a customer? The second case is outward communication with a PM as courier, so it
follows the Kunde/extern row. If it is unclear which one, ask (§1).

**Sister company (see `rules/Organisation.md`):** Funntastic people are the *internal*
tiers (dev-internal, OM or PM-internal), never the "Kunde / extern" row — the
separate Atlassian instance does not make them external. FT's own agency clients do
belong in the external row.

The `du`/`Sie` register, customer-specific tone, PM-vs-direct routing, and any
terminology/glossary are **unknowns until grounded** (§9). The table's non-verified
cells (`beobachten`, "konservativer Default") are placeholders, not house-style
facts; do not present them to a colleague or customer as settled MOSAIQ policy.

**What a non-dev reader's text contains (convention, stated by the user 2026-08-17).**
Three points, in this order, and nothing else:

1. **Konkretes Ergebnis** — what is different or usable now.
2. **Aktueller Status** — what holds right now, including the deliberately open points.
3. **Nächste Schritte mit konkreter Zuständigkeit** — who does what, and what it waits on.

Cause analysis, background reasoning and derivations are out. They explain the author,
not the reader's next step. Verification evidence is not lost, it moves: repo docs, the
commit body, the PR description.

**But "non-technical" is the wrong cut. The criterion is recipient autonomy**
(verbatim user statement, 2026-07-30): *"was muss sie wissen, um ohne mein
Zutun/Beisein mit dem Thema weiterarbeiten zu können; Rückfragen stellt sie im
Zweifelsfall ohnehin direkt"*. Technical detail the recipient operates herself stays,
however technical it looks. Only detail she cannot act on goes.

**The numbers test.** A metric belongs in the text when the metric *is* the subject
(a Pagespeed score in a Pagespeed optimisation, reach in a reach report). It does not
belong there as proof of work: row counts, table coverage, test pass rates, job
durations. Anchor (MQDEV-189, 2026-08-17): an agent draft carrying 303.229/250.831
synced rows, 35/36 refreshed tables, 14/14 green dbt tests and a six-row before/after
table was cut to a status sentence, a next step with an owner, and the one hint that
needed the reader's decision. Every number went.

**Detail-tightening for non-dev readers (observed pattern, anchors: OW-47/OP-45/OW-107 2026-07 + GMP 2026-07 via /core:comm-calibrate).**
The OW/OP anchors are OM (Natalie Pasedach, FT-OM); the GMP tier was never verified.
The moves hold for both non-dev rows. When condensing a technical draft for such a
reader, the draft→sent delta consistently showed these moves; apply them pre-emptively
rather than leaving them for the human:
- **keep, even when technical, because the recipient operates it:** configured values with their unit ("12 Stunden (= 720 Minuten)"), the field / sheet / column she edits, the tool name, the mechanism in one sentence, self-service statements ("weitere Einträge nimmt der Workflow automatisch auf");
- **drop the evidence chain:** measured numbers, volume forecasts, derivations, the reference back to an earlier promise, rhetorical deadline pressure — plus over-precise single-run metrics ("Score 77/83" → "Score Home / Listing"), internal-process labels ("Daily-Zweig", "Punkt 2 des Splits") and API/tooling detail the recipient cannot operate ("eventName-Filter");
- **expectation management stays, but qualitative** ("erst mal Fehlalarme möglich") instead of quantified;
- **asks stay.** That OM/PM ask back directly licenses omitting the evidence chain, NOT omitting concrete questions, open points, or coordination. Drop an ask only when the recipient can check and decide it alone (OW-107: the calibration date);
- collapse internal breakdowns and repo paths into one pointer ("... im Repository dokumentiert");
- keep the honesty calibration explicit: Konjunktiv for hypotheticals ("wäre reine Verbesserung"),
  attribute measurement limits to their source ("vom Agent nicht messbar"), prefer precise terms
  ("nicht beobachtet" statt "ungenutzt"), spell out technical qualifiers ("mit brotli Kompression").
This concretises the non-dev rows' "mittel; Jargon reduzieren"; observed pattern (2 tickets), hardening toward convention.

**Grounded `du` for OM (anchors, mosaiq.atlassian.net, MQDEV-188/189/190).** Mutual and
repeated, so the OM row's register is settled, not a placeholder: "damit ihr zum
Validieren aktuelle Daten habt", "Sag Bescheid, dann räume ich das auf" (dev → OM);
"Magst du nochmal schauen wegen den Berechtigungen", "Kannst du die Frage hier noch
beantworten?" (OM → dev). Greeting frame is NOT settled: one closing comment used
"Hi @Vorname" plus "Viele Grüße", three earlier thread comments by the same author used
a bare mention and no sign-off. Observed 1x each, do not generalise.

**To sharpen per project (do NOT fabricate):**
- who is OM, who is PM, who is dev (the tier itself, before any register question),
- salutation and register per audience (`du`/`Sie`, internal vs external tone),
- PM-mediated vs direct-to-customer routing (who the audience actually is), and for
  PM whether a given text is internal or meant for onward delivery,
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
