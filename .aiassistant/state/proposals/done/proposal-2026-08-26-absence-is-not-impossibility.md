# Extend General.md §2.2: a source's silence is not a fact about the world

```
Date:         2026-08-26
Status:       superseded
Superseded by: .aiassistant/state/proposals/proposal-2026-08-31-verification-reach-consolidation.md
Origin:       session observation — three wrong "not possible" claims in one session in
              the MO project, two of them already committed as documentation
Revisit when: a decision on this proposal, together with
              proposal-2026-08-19-schema-presence-vs-admissibility (same rule file, and
              this one is its mirror image — see Adjacency)
```

## Problem

Three times in one session I asserted that something was impossible because the one
source I had queried did not mention it. Each time the thing was possible, and twice the
wrong claim had already been written into project documentation as a measured finding.

**Instance 1, inherited.** `docs/12-konfiguration.md` §12.4 read "a seed script for the
store configuration is not possible, not even partially". Origin: the probe app carried
almost only read scopes, so every write was untried. Nine areas turned out to be
writable. The section had carried the claim for a week and had already been quoted into
an effort estimate.

**Instance 2, my own, same day.** Asked whether an app could edit Shopify's notification
templates, I searched all 3552 schema type names for `notification|emailtemplate|...`,
found nothing, and answered "structurally no, no app can do this". The templates are
reachable — through the generic `TranslatableResourceType` enum value `EMAIL_TEMPLATE`.
There is no `EmailTemplate` **type**, which is exactly why a type-name search could not
find them. 60 templates, full `body_html`, readable; writable in every locale except the
primary one.

**Instance 3, my own, same day.** Asked whether Shopify's cookie banner logs consent, I
checked the Admin API, found no query and no consent-record type, and reported
"logging: half — an id, but nothing provable". The user then found
`/settings/privacy/consent-log` in the admin: a complete per-event log with timestamp,
consent id, URL, IP address and a per-category breakdown, including a distinct
"partial consent" state. The API's silence said nothing about the product.

The common shape: **the source answered "is this in me", I reported "is this in the
world".** The three sources were a scope-limited API session, a type-name index, and one
API surface out of two (API and admin UI). None of them was authoritative for the claim
drawn from it.

What the existing rules do and do not cover:

- **§1.4** and **§1.5** are about *recall* versus *ground truth*, and they worked: I did
  query a live source every time. Neither says the live source may be the wrong witness.
- **§5.6** (verification command integrity) is the closest in spirit — it is exactly this
  error for shell commands, where a false fact must produce a visibly negative result. It
  is scoped to command construction, not to reasoning from a source.
- **§1.1** would cover it if "not found in X" were labelled an assumption. It never felt
  like one, because a real check had just been run.

## Proposed change

Add to `General.md` §2.2, adjacent to the clause proposed in
`proposal-2026-08-19-schema-presence-vs-admissibility.md`:

> Absence in a source is not absence in the world. Before asserting that a capability,
> field, or feature does not exist, the agent MUST establish that the queried source is
> authoritative for that claim: that it would have shown the thing if it existed, and
> that the query could have found it. Where it cannot establish that, the finding is
> "not found in <source>", never "not possible", and the assertion MUST name the source
> and the query. This binds hardest where a negative is about to be written into
> documentation or an estimate.

## Expected impact

Turns the three failures above into three "not found in X, other surfaces unchecked"
statements, which cost one clause and prevent a wrong durable fact. The behavioural
change is narrow and checkable: before a negative capability claim, name the witness and
ask whether it could have seen the thing. Generic layers (`TranslatableResource`,
`Metafield`, an admin UI without an API counterpart) are the standing counterexample to
a type-name search.

## Risk / tradeoff

- Always-on token cost: roughly 80 tokens in a `[CRITICAL]` file. §3.3 budget check
  before applying; if §2.2 is at budget, demotion review first.
- Over-application risk: read literally it could demand an exhaustive surface sweep
  before any "no". The "authoritative for that claim" qualifier is what bounds it — a
  schema really is authoritative for "there is no `shopUpdate` mutation", and that
  negative should stay assertable without ceremony.
- Overlaps with the 2026-08-19 proposal on the same section; see below.

## Adjacency, per Meta.md §3.2

Three open proposals now sit on the same underlying error, "a real check answered a
narrower question than the assertion drawn from it", on three axes:

| Proposal | Axis |
|---|---|
| `2026-08-18-verification-population-completeness` | population — which items were checked |
| `2026-08-19-schema-presence-vs-admissibility` | modality — presence does not grant permission |
| this one | modality — absence does not prove impossibility |

The 2026-08-19 file already flagged the merge question. With a third instance the answer
looks clearer: **one clause naming the general shape plus the three named traps reads
better than three near-duplicate additions**, and it is cheaper in always-on tokens.
Recommend deciding all three together, and preferring the consolidated form.

## Evidence

- Project `MO` (`/home/uwestrepp/work/projects/shopify/MO`), session 2026-08-26.
- Instance 1: corrected in `docs/09-abstimmungen.md` V15b and `docs/12-konfiguration.md`
  §12.4, commit `b400d90`.
- Instance 2: corrected in `docs/12-konfiguration.md` §12.4.1 and §12.4.2 and
  `docs/13-aufwandsschaetzung.md` H2, commit `90fe676`.
- Instance 3: corrected in `docs/12-konfiguration.md` §12.3.11a, commits `edc3dfc` and
  the follow-up carrying the log detail.
- Counter-example from the same session, which is the behaviour the rule is meant to
  produce: the hypothesis "the cookie banner's `translations` field behaves like
  `EMAIL_TEMPLATE` and fills up once a second locale exists" was measured rather than
  asserted, and was falsified. Commit `84e7fbf`.
