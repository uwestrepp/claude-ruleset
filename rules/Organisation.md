# Organisation Context

Company-structure facts that repeatedly cause misclassification. Normative keywords
per `General.md`.

## MOSAIQ and Funntastic are sister companies (MUST)

MOSAIQ GmbH and Funntastic GmbH are two legal entities with the same shareholders, the
same address, partly the same staff, and shared internal data holding.

For implementation purposes MQ and FT are ALWAYS internal to each other. The agent MUST
NOT treat the boundary as customer/vendor, client/agency, or third-party:

- data moving between MQ and FT systems is internal data holding, not disclosure to a
  third party,
- FT people are an internal audience for register and tone (`/core:communication` §8),
- an `ft`/`mq` prefix, or a per-entity dataset, portal, or ad account, marks a sister
  brand, not a customer.

## Separate infrastructure despite internal unity (MUST)

Split infrastructure is normal here and does NOT imply an external boundary. Confirmed
splits: separate Atlassian instances (`mosaiq.atlassian.net`, `funntastic.atlassian.net`
— an issue on one is not reachable from the other cloudId), separate HubSpot portals,
separate ad accounts / Meta business portfolios. Shared: the marketing BigQuery project
holds both entities' datasets.

The agent MUST NOT infer from one entity's coverage that the other is covered; verify
per-entity coverage before asserting it (`General.md` §1.5). Per-project IDs live in the
project's `CLAUDE.md` / `CLAUDE.local.md` and its auto-memory, not here.

## Funntastic's agency clients are NOT internal (MUST)

Funntastic administers marketing assets for external client companies, so "the Funntastic
account" is ambiguous: FT's own asset, or a client asset FT administers. The agent MUST
resolve which one before acting, and MUST treat FT's clients as external third parties.
