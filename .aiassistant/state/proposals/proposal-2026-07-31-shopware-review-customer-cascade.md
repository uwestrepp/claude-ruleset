# Proposal: record Shopware's delete behaviour for customer-owned reviews

```
Date:         2026-07-31
Status:       parked
Origin:       GMP-340 go-live session — test-data cleanup after the GMP-343 cross-user check
Revisit when: a second wrong-cascade assumption shows up in any Shopware entity cleanup,
              or rules/Shopware.md §1 is being edited anyway
```

## Problem

`rules/Shopware.md` §1 covers media and thumbnail behaviour but says nothing about the
delete behaviour of dependent entities. Working from the usual assumption that a review is
owned by its customer, I wrote into a result document that reviews are removed by cascade
when the customer is deleted. They are not: Shopware sets `product_review.customer_id` to
`NULL` and keeps the row, including `external_user` (the reviewer's first name) and its
`status`.

The assumption was wrong in a way that survives review, because the storefront hides the
orphan: at `status = 0` it renders nowhere. It stays visible only in the administration's
review list, where it is indistinguishable from a genuine pending review and can be
approved by mistake.

## Proposed change

One line in `rules/Shopware.md` §1 (path-gated, so no always-on cost):

> Deleting a customer does not cascade to `product_review`: `customer_id` goes `NULL` and
> the row survives with `external_user` and its status. Clean test reviews up explicitly,
> before or after the customer.

## Expected impact

Removes one silent-failure mode from test-data cleanup on shared staging systems, where a
leftover pending review is both invisible in the storefront and actionable in the admin.

## Risk / tradeoff

Low risk, but weak justification on its own: this is a single fact, not a pattern, and
`Meta.md` §3.3 treats fact-by-fact accretion as the mechanism by which rule files stop
being read. That is the reason it is parked rather than applied.

## Evidence

- Observed 2026-07-31 on `staging.rom.mosaiq.com`: two customers `gmp343-a/b@example.test`
  deleted via the administration; `SELECT COUNT(*) FROM customer WHERE email LIKE
  'gmp343-%'` returned 0 while both reviews remained with `customer_id IS NULL`,
  `external_user` set and `status = 0`.
- The wrong claim and its correction are in the gmp project at
  `.aiassistant/state/reviews/gmp-343-http-cache.md` (two places, corrected in the same
  session).

## Why parked

User decision, 2026-07-31: hold while it is a one-off. The correction is already captured
where it was needed, in the project's own review document. Promote only if the same class
of assumption bites again, which would make it a pattern rather than a fact.
