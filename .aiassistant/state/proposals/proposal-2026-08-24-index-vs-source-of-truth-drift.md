# Extend General.md §3.4: reconcile index against source of truth before deriving outward-facing output

```
Date:         2026-08-24
Status:       open
Origin:       session observation — MO project, MO-111, producing a customer-facing
              version of the requirements catalogue
Revisit when: a decision on this proposal, or a second instance in any project that
              keeps a state/index document alongside a source-of-truth directory
```

## Problem

The MO project splits its documentation in two layers, and says so explicitly in its
`CLAUDE.md`: `.aiassistant/state/ARBEITSSTAND.md` is "ein Index, keine zweite Quelle der
Wahrheit; bei Widerspruch gilt `docs/`". The same file carries a maintenance rule: a step
counts as done only once its result is in `docs/`.

On 2026-08-24 a morning session established that the frontend team had named a concrete
theme candidate. It recorded that in the index, and it handled the deferral correctly and
visibly: `ARBEITSSTAND.md` states "Was noch nicht in `docs/` steht: die Lizenz- und
Trial-Befunde. Sie sind Teil von MO-107 und der Schritt gilt bis dahin als nicht
abgeschlossen." **No rule was broken.** The deferral is the project's own sanctioned
mechanism.

What the mechanism does not carry is the cost of the window it opens. During the deferral
the two layers actively contradicted each other: the index said "das **gewählte** Theme
heißt Digital", `docs/` said "Theme-Auswahl offen (I11)" in eleven places. The tie-breaker
("bei Widerspruch gilt `docs/`") resolves such a conflict, but only for a reader who has
noticed it.

In the afternoon session I did not notice it. I read the index at session start as
instructed, then read the six `docs/` sections the task named, and produced from them a
**customer-facing** artifact: a version of the requirements catalogue written so the
project manager can present it to the client without us. Four of its rows say the theme
selection is still pending, with no mention that a concrete candidate exists. That artifact
was finished, verified, committed and handed over. It took the user's remark ("Stand heute
Morgen hatten wir ja einen ersten Vorschlag für das konkrete Theme, im Dok steht noch
'nicht entschieden'") to surface it.

The shape: **I treated the two layers as one corpus and read whichever of them the task
pointed me at, when the task was to derive an outward-facing assertion.** For internal work
that is harmless, because the tie-breaker sorts it out on the next read. For output that
leaves the repository it is not, because the omission ships.

Where the existing rules sit relative to this:

- **§3.4** is the closest fit. It mandates revalidation after continuity events and
  requires re-reading `[CRITICAL]` rule files and "the files directly in scope". The files
  directly in scope were exactly the ones I read. §3.4 has no notion of two in-repo layers
  that may disagree.
- **§1.5** would cover this if I had recognised "the theme selection is open" as a
  diagnosis-class claim about current state. I did not, because I had read it in the
  designated source of truth, four times over.
- **§4.5** has the right instinct one level down: verify the upstream contract before
  changing a call site. This is the documentation analogue, and it is not written anywhere.
- **`Meta.md` §2.2** governs where knowledge is stored and prefers the narrowest durable
  scope. It is silent on what to do while a fact is knowingly sitting in the wrong layer.

## Proposed change

Add to `General.md` §3.4, as a final paragraph:

> Where a project keeps a state or index layer alongside a designated source of truth, the
> two MAY legitimately disagree while an update is pending. Before producing output that
> leaves the repository — customer- or colleague-facing documents, tickets, PR text,
> published artifacts — the agent MUST reconcile the layers for the facts the output
> asserts, and MUST NOT rely on the project's conflict tie-breaker to resolve a
> disagreement it has not looked for. A pending-integration note in either layer is a
> trigger for this check, not a substitute for it.

## Expected impact

Prevents shipping a customer-facing document that is stale in a way the repository already
knew about. The behavioural change is narrow and cheap: when the output is outward-facing,
grep the index layer for the facts the output asserts, instead of trusting that the source
of truth is current. It also gives the deferral mechanism the missing half — the project
rule says when a fact must reach `docs/`, this says what to do in the meantime.

## Risk / tradeoff

- Always-on token cost: roughly 100 tokens in a `[CRITICAL]` file. `Meta.md` §3.3 budget
  check needed before applying; if `General.md` is at its budget, the demotion review has
  to free space first.
- Scope creep risk: read too broadly this could mean re-reading the whole index before any
  output. The "for the facts the output asserts" qualifier is load-bearing and must survive
  a later terseness pass.
- Arguably project-shaped rather than global. The two-layer split is the MO project's
  convention, and it is a `CLAUDE.md` matter there. Counter-argument for the global file:
  the failure is not about that convention but about deriving an outward-facing assertion
  from one of two sources without checking they agree, and any project with a state
  directory plus documentation has the same shape. If the decision goes the other way, the
  narrower home is the MO project's own `CLAUDE.md` under the existing Pflegeregel.
- One instance so far. `Meta.md` §3.2 asks for repeated friction or official guidance
  before adding a pattern; this has neither yet, which is the honest argument for leaving
  it `open` rather than applying it.

## Evidence

- Project `MO` (`/home/uwestrepp/work/projects/shopify/MO`), session 2026-08-24.
- The contradiction: `.aiassistant/state/ARBEITSSTAND.md` before commit `84dcda2` said
  "das gewählte Theme heißt **Digital**"; `docs/09-abstimmungen.md` §9.1.7 (I11),
  `docs/11-roadmap.md`, `docs/12-konfiguration.md`, `docs/13-aufwandsschaetzung.md` and
  others said the selection was open. The deferral was recorded honestly in the same
  ARBEITSSTAND file, so this is a gap in the mechanism, not a lapse in following it.
- The shipped artifact:
  `.aiassistant/state/Anforderungskatalog_Shop_F4M_Umsetzungsstand_sprechend.xlsx`,
  commit `7beb8bb`. Rows 1, 29, 30 of the `Anforderungen` sheet and row 1 of `Ergänzungen`
  asserted an open theme selection with no candidate named.
- The correction, after the user's remark: commit `84dcda2`, eleven files.
- A second fact drifted the same way and was caught in the same pass: the current
  objective (MO-106, building the test store into a demo stand for the client) existed only
  in the index; `docs/` still described the superseded objective from 2026-08-18. That one
  had no pending-integration note at all, so the same reconciliation step is what would
  have found it.
