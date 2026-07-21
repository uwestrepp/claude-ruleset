---
name: comm-calibrate
description: "Activate via /core:comm-calibrate or let Claude auto-suggest it (propose, never silently run) when a REAL communication artifact from colleagues/PMs/customers enters the session. Inbound counterpart to /core:communication: that skill PRODUCES colleague-facing output; this one INGESTS a real artifact and derives per-audience house-style facts (register/du-Sie, tone, PM-vs-direct routing, ticket/PR structure, glossary) to update the docs. Artifacts: a Jira ticket/comment, Confluence page, Bitbucket PR or comment, a chat message, OR the high-signal correction \"you suggested X, I sent Y\" (draft-vs-sent delta). Sources: paste, Atlassian/Bitbucket MCP/API, relayed text. Triggers: \"werte diesen Kommentar/das Ticket/die PR aus\", \"leite draus ab wie wir kommunizieren\", \"du hast X vorgeschlagen, ich hab Y draus gemacht\", \"kalibrier anhand Ticket GMP-123\". Self-fetch via MCP/API ONLY on user request or agent-offer+confirm. NOT producing output (/core:communication), NOT chat, NOT commits (/core:commits)."
argument-hint: "[artifact-or-ticket]"
---

# Communication Calibration (inbound house-style mining)

The **observe / inbound** arm of the MOSAIQ communication refinement loop. Where
`/core:communication` §8/§9 defines the reactive *pull* (draft output → confirm a
comm-fact → persist), this skill is the *push*: a real communication artifact
arrives → mine it → sharpen the documented Sprechweise. Normative keywords per
`General.md`.

**Authority split (do NOT duplicate).** `/core:communication` remains authoritative
for *WHAT* house-style facts exist (its §8 register schema) and *WHERE* they are
persisted (its §9 targets + scope rules). This skill owns only the *HOW of
extraction*. Per `General.md` §9.3 the agent MUST load `/core:communication` §8 and
§9 into context when running this skill; the schema and persistence rules are not
restated here.

---

## 1. Scope & boundary

- **In scope:** ingest one real communication artifact, classify its audience,
  extract register/routing/format/glossary signals grounded in the actual text,
  diff them against the current documented house-style, and persist the confirmed
  deltas.
- **Out of scope:** producing colleague-facing output (`/core:communication`),
  agent-to-user chat, commit schema/ticket resolution (`/core:commits`).
- **The artifact is ground truth; the recalled house-style is the hypothesis**
  (`General.md` §1.5, Persona). A single artifact refines the profile; it never
  overrides an established fact by assertion alone (§6).

## 2. Activation (auto-suggest, offer-first)

Never run silently. Propose activation on a trigger match; run after the user
acknowledges. When invoked explicitly, `$ARGUMENTS` may carry the artifact text or a
ticket/PR reference to calibrate against.

- **Explicit:** `/core:comm-calibrate`; "werte diesen Kommentar/dieses Ticket/diese
  PR aus"; "leite draus ab, wie wir kommunizieren"; "kalibrier den Haus-Stil".
- **Correction feedback (highest signal):** "du hast X vorgeschlagen, ich hab Y
  draus gemacht"; "so ging das dann raus"; "final verschickt: …". Proactively offer
  here: the draft→sent delta is the most direct evidence of house-style.
- **Artifact paste / MCP-fetch result with no instruction:** offer first, do not
  reinterpret the paste as a calibration order.
- **Do NOT trigger** when the paste clearly has another purpose (a bug to fix, code
  to review, a snippet to use).

**Self-fetch gate.** Pulling the artifact itself via Atlassian/Bitbucket MCP or API
(e.g. "kalibrier anhand Ticket GMP-123") is allowed ONLY when the user explicitly
requests it, or the agent offers and the user confirms. MCP/API pulls are
token-heavy (`General.md` §10.5): offer-first, never autonomous.

## 3. Input channels

Copy-paste in chat · Atlassian MCP (`getJiraIssue` + comments, `getConfluencePage`)
· Bitbucket API (PR description/comments) · user-relayed correction feedback.

## 4. Analysis via sub-agent (`General.md` §11)

- **Long artifacts** (whole ticket thread, long PR, Confluence page): delegate to a
  `general-purpose` sub-agent so the raw text does not enter the main context
  (`General.md` §10.5 self-executable path). The briefing MUST be self-contained
  (`General.md` §11.2): paste the `/core:communication` §8 register schema inline
  (the sub-agent cannot see conversation context), hand over the artifact, and
  restrict it to **read-only** — extract and report, never write.
- **Short artifacts** (a single comment): analyse inline.
- **Evidence-bound (no fabrication, `General.md` §1.2):** every extracted signal
  MUST carry a verbatim quote or concrete structural observation from the artifact.
  A signal with no textual anchor is dropped, not guessed.

## 5. Extraction schema (mapped to `/core:communication` §8)

Extract, per artifact, into the audience/register dimensions §8 already defines:

- **Audience tier** — Dev-intern / PM-intern / Kunde-extern, with the classifying
  evidence.
- **Anrede / register** — `du` vs `Sie`, formality; quote.
- **Ton** — sachlich / verbindlich / …; quote.
- **Routing** — direct-to-customer vs PM-mediated (who the real addressee is).
- **Detailtiefe / Jargon** — level, with an example.
- **Format / structure** — acceptance-criteria form, labels, PR-description layout.
- **Glossar** — product names, house terms, recurring phrasings.
- **Draft→sent delta** (correction-feedback artifacts only) — what the human changed
  vs the agent's proposal, both versions retained. This is the highest-value signal.

## 6. Delta & conflict handling

- **n=1 rule (guard against overfitting):** one artifact is a data point, not a
  policy. Record a new register signal as "beobachtet (1×)"; promote it to a
  "Konvention" only on repeated confirmation or an explicit user statement.
- **New:** a §8 placeholder (`beobachten`, "konservativer Default") becomes a
  grounded fact.
- **Confirmation:** strengthen an existing fact / mark it verified, note the extra
  data point.
- **Conflict:** an observation contradicting an established fact MUST be surfaced
  with both pieces of evidence, not silently overwritten. The user decides; a
  reversal names the specific new evidence (`General.md` "No Capitulation", §1.5).

## 7. Persistence (targets per `/core:communication` §9)

Persist confirmed deltas to the scope §9 defines (do not re-derive the target rules
here):

- **Project-scoped** facts (a contact, a routing rule, a customer's `du`/`Sie`,
  ticket conventions) → the project's `CLAUDE.md` / `CLAUDE.local.md` + the
  project's auto-memory.
- **Globally reusable** style refinement → a **proposal** to update
  `/core:communication` §8 (proposal-only, never auto-applied, per §9).
- **Always store the anchor** (the quote/source) alongside the fact, so later
  sessions can see the grounding.
- **Safety — style, not payload:** persist only the derived *Sprechweise*, NEVER the
  customer/business raw content of the artifact. Do not leak business plaintext into
  auto-memory or `CLAUDE.md`. Pure analysis produces no colleague-visible output, so
  the `/core:communication` §4 MCP safety guards are not engaged here.

## 8. User output

Report a delta list: **new / confirmed / conflict**, each with its evidence anchor
and the target path. Offer-first before persisting larger changes; conflicts are
raised for a decision, not resolved unilaterally.

## 9. Relation to `/core:communication`

Bidirectional loop: `/core:communication` §9 points here for the inbound arm; this
skill writes back to the §8 register directory and §9 project comm-facts. Keep the
two boundaries clean: producing = `/core:communication`, mining = this skill.
