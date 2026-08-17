# Handoff: refine the PM/OM detail rule in `/core:communication` §8

- **Date:** 2026-07-30 · **Updated:** 2026-08-17
- **Repo:** `~/.claude` (rule-set + skills; `main` is the working branch, direct commits per `CLAUDE.md`)
- **Status:** **APPLIED** in commit `a4f5f75` (2026-08-17), together with a larger §8 rebuild that arrived from a separate clarification the same day. The original proposal is fully contained in that commit. What remains open is listed under "Still open" and is deliberately small.

> **Read this first if you are picking the file up:** the proposal below is history, not a task. Sections "Why this exists" and "The proposal" are kept verbatim as the grounding record. "Verified state" and "Steps" have been rewritten to the post-change reality, because the block title and the register row they referenced no longer exist in the quoted form.

## Why this exists

`/core:communication` §8 currently instructs the agent to drop "API/tooling
mechanics" when condensing for a PM / non-tech-internal reader. On 2026-07-30 a
draft-to-sent delta in project `mq.n8n-server` (ticket OW-107, recipient Natalie
Pasedach, FT-OM) contradicted that for one half of the rule: the human's sent version
**added** tooling mechanics the agent's draft had deliberately withheld, and **removed**
everything the agent had kept as justification.

The agent's draft, following the current rule, withheld the configured threshold value,
the spreadsheet column name and the tool name, and kept the measured evidence
(visit-gap measurements, a projected mail volume, a dated calibration ask). The sent
version did the opposite. Left uncorrected, the rule keeps producing drafts that strip
exactly what makes the recipient able to act.

A second, adjacent error happened in the same session and belongs in the fix: the agent
inferred from "they ask back directly anyway" that a comment to OM needs no questions at
all. The user corrected this explicitly. The direct-question channel licenses omitting
the evidence chain, not omitting the ask.

## The proposal, in `Meta.md` §3.1 form (kept verbatim, now applied)

**Problem.** §8 tells the agent to drop tooling mechanics for PM/OM readers. For
mechanics the recipient operates herself this is measurably wrong, and the rule offers no
criterion to tell the two kinds apart. Additionally, nothing in §8 protects the ask, so
the agent can infer its way to a question-free comment.

**Proposed change.** Replace the first bullet of the PM detail-tightening block and add
two bullets, keyed to one criterion (verbatim user statement, 2026-07-30): *"was muss sie
wissen, um ohne mein Zutun/Beisein mit dem Thema weiterarbeiten zu können; Rückfragen
stellt sie im Zweifelsfall ohnehin direkt"*.

- **Keep, even when technical, because the recipient operates it:** configured values
  with their unit ("12 Stunden (= 720 Minuten)"), the field / sheet / column she edits,
  the tool name, the mechanism in one sentence, self-service statements ("weitere
  Einträge nimmt der Workflow automatisch auf").
- **Drop the evidence chain:** measured numbers, volume forecasts, derivations, the
  reference back to an earlier promise, rhetorical deadline pressure. Plus, unchanged
  from today, over-precise single-run metrics, internal-process labels, and API/tooling
  detail the recipient cannot operate.
- **Expectation management stays, but qualitative** ("erst mal Fehlalarme möglich")
  instead of quantified.
- **Asks stay.** That PM/OM ask back directly licenses omitting the evidence chain, NOT
  omitting concrete questions, open points, or coordination. Drop an ask only when the
  recipient can check and decide it alone (OW-107: the calibration date).

Update the anchors line to include `OW-107 2026-07-30` and keep the honesty-calibration
bullet as it stands.

**Expected impact.** Removes a rule that actively degrades drafts for the most frequent
non-dev audience, and closes the inference path that produced a question-free comment.
Gives the agent one testable question instead of a genre label ("nicht-technisch").

**Risk / tradeoff.** The "keep operable mechanics" half rests on one artifact plus a user
statement; if a later delta strips mechanics again, the criterion, not the list, is what
should be re-examined. Minor overlap risk: the criterion is close enough to the register
table's PM row that both could drift apart. Mitigation: leave the table cell as the
one-line summary and keep the criterion in the block, referenced from the cell rather
than duplicated.

## What was applied (2026-08-17, commit `a4f5f75`)

All four bullets went in verbatim, the anchors line was extended, and the register cell
was handled per the mitigation (the criterion lives in the block only, the PM-intern cell
keeps its one-line summary and points at OM). Beyond the proposal, the same commit made
these changes, driven by a user statement on 2026-08-17 that OM and PM are distinct
audiences:

- **Three audience tiers instead of two.** New tier "Fachseite / internal non-dev"
  covering OM and PM.
- **New OM row** in the register table, register `du` marked verified. Anchors are mutual
  and repeated, from `mosaiq.atlassian.net` MQDEV-188/189/190: "damit ihr zum Validieren
  aktuelle Daten habt", "Sag Bescheid, dann räume ich das auf" (dev → OM); "Magst du
  nochmal schauen wegen den Berechtigungen", "Kannst du die Frage hier noch beantworten?"
  (OM → dev).
- **PM row split** into "PM (intern)" and "PM (zur Weitergabe an Kunden)". The second
  inherits the Kunde/extern row, because a text meant for onward delivery leaves the
  internal space. Anchor for why this matters: "Airbyte läuft aktuell nur lokal auf meinem
  Rechner" is exactly right internally and unusable in a forwarded text.
- **Content rule for non-dev readers:** Konkretes Ergebnis, Aktueller Status, Nächste
  Schritte mit konkreter Zuständigkeit, and nothing else.
- **The numbers test:** a metric belongs in the text when the metric *is* the subject (a
  Pagespeed score in a Pagespeed optimisation), not as proof of work. Anchor: the
  MQDEV-189 draft-vs-sent delta of 2026-08-17, where an agent draft carrying 303.229 /
  250.831 synced rows, 35/36 refreshed tables, 14/14 green dbt tests and a six-row
  before/after table was cut to a status sentence, a next step with an owner, and the one
  hint needing the reader's decision. Every number went.
- **Anchor correction:** the OW/OP anchors are OM (Natalie Pasedach, FT-OM, per this
  handoff), not PM. The GMP tier was never verified and is now explicitly marked as such
  instead of being guessed.
- **Explicit note** that a coordinating tone (assigning tasks, chasing status) does not
  make someone a PM. That misclassification happened on 2026-08-17 even though this
  handoff already recorded Natalie as FT-OM.

Validation at commit time: `npx agnix@0.40.0 validate plugins/marketplaces/local/plugins rules`
→ 0 errors (one self-inflicted "unclosed XML tag" from a literal `<name>` placeholder was
fixed first); the 17 remaining warnings are pre-existing. `bin/lint-section-refs.sh` →
`REF-LINT: ok`. `communication/SKILL.md` is 316 lines, inside the agnix AS-012 500-line
threshold. `CLAUDE.md`'s skill-ledger entry was updated in the same commit.

## Verified state (post-change)

- Target file: `plugins/marketplaces/local/plugins/core/skills/communication/SKILL.md`, §8.
- The block is now titled **"Detail-tightening for non-dev readers (observed pattern,
  anchors: OW-47/OP-45/OW-107 2026-07 + GMP 2026-07 via /core:comm-calibrate)"**. The old
  title and the old `PM / interne Nicht-Tech` row no longer exist.
- The recipient-autonomy criterion sits in its own block above the detail-tightening
  bullets, so "non-technical" is no longer the cut anywhere in §8.
- No `exports/` sync needed, re-checked 2026-08-17:
  `grep -rln -iE "detail-tightening|Sprechweise|register directory|comm-calibrate" exports/`
  returns nothing (`exports/` holds only `OnlineAgent.md` and `README.md`).
- No always-on budget effect (`Meta.md` §3.3): skill file, loaded on prompt relevance.
  The `CLAUDE.md` ledger line grew by a few words; `REF-LINT` stays ok.
- Project-side grounding, unchanged and still the anchor to cite: `mq.n8n-server`, commit
  `5f984ba` on branch `feature/OW-47-status`, files `CLAUDE.md` (section "Kommunikation
  (Funntastic)") and `.aiassistant/state/OW-107/06-kommunikation-2026-07-30.md`.
- Second project-side grounding for the OM row and the numbers test: the Airbyte project's
  auto-memory, `airbyte-pm-comment-style` and `airbyte-rollout-routing`.

## Steps (all done)

1. ~~Read §8 in full before editing.~~ done.
2. ~~Apply the four bullets, replacing the current first bullet, keeping the framing
   sentence and the honesty-calibration bullet.~~ done, verbatim.
3. ~~Extend the anchors parenthesis with `OW-107 2026-07-30`.~~ done, plus the OM/GMP
   tier correction.
4. ~~Decide the register-table cell.~~ done: criterion stays in the block only, the
   PM-intern cell keeps a one-line summary. Not restated twice.
5. ~~Measure the file against agnix limits.~~ done: 316 lines.
6. ~~Validate with agnix over the hook scope.~~ done: 0 errors.
7. ~~Commit on `main`.~~ done: `a4f5f75`, subject
   `[DOCS] AGENT (skills) split the non-dev audience into OM and PM, key detail to recipient autonomy`.
8. ~~No project-side follow-up.~~ confirmed, `mq.n8n-server` already carries it.

## Nothing open on this handoff

The proposal is applied and verified. Two things that are **not** open items, recorded so
nobody re-opens them:

- **The GMP anchor's audience tier stays unverified, deliberately.** It predates the
  OM/PM split, §8 marks it as unverified, and the rule works with that marking. Resolving
  it would need the GMP tickets, which live outside `mosaiq.atlassian.net`. This is an
  accepted annotation, not a to-do.
- **This file was untracked, which was an oversight, not an open question.** Every other
  handoff in this repo is committed (`handoff-20260730-110844-agnix-version-bump.md` from
  the same day, plus all three under `done/`), as are all four files in
  `.aiassistant/state/proposals/`. Checked 2026-08-17. That oversight is why a live
  proposal and a recorded audience fact stayed invisible for three weeks: no `git log`, no
  grep hit in a committed path. Committing this file closes it.

Per `Meta.md` §2.4 this handoff has been consumed, so it now lives under
`.aiassistant/state/handoffs/done/`.

## Adjacent open points (do NOT bundle)

- `Meta.md` §3.3 demotion review over the `CLAUDE.md` index is still due at the next
  `/core:rule-friction` cycle. See `handoff-20260730-110844-agnix-version-bump.md`.
- The agnix pin bump (0.40.0 → 0.41.1) from that same handoff is still open and
  independent. Note the pin is still `0.40.0` as of 2026-08-17.

## No trigger prompt

Nothing to hand over. This file is a record, not a task. The two remaining items in the
repo are tracked elsewhere, see "Adjacent open points" above.
