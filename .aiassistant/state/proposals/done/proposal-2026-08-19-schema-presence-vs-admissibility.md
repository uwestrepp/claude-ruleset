# Extend General.md §2.2: schema presence is not contextual admissibility

```
Date:         2026-08-19
Status:       superseded
Superseded by: .aiassistant/state/proposals/proposal-2026-08-31-verification-reach-consolidation.md
Origin:       session observation — three failures while seeding the Shopify store schema
              in the MO project
Revisit when: a decision on this proposal. The "third instance" trigger has already
              fired (see Evidence), so this is no longer waiting for more cases
```

## Problem

While writing the Shopify seed script I did what §1.4 and §2.2 ask for: I did not write
API field names from memory, I introspected the live GraphQL schema first. Three of the
values I took from that introspection were still rejected at the call site, and each cost
a failed run plus a diagnosis round.

**Instance 1.** `MetaobjectAdminAccess` is declared as
`MERCHANT_READ | MERCHANT_READ_WRITE | PUBLIC_READ_WRITE`. I used `PUBLIC_READ_WRITE`,
which the project documentation also recommended. The API answered *"Expected
\"PUBLIC_READ_WRITE\" to be one of: MERCHANT_READ, MERCHANT_READ_WRITE"*. After switching
to an allowed value it answered `ADMIN_ACCESS_INPUT_NOT_ALLOWED`: *"Admin access can only
be specified on metaobject definitions that have an app-reserved type."* The correct call
omits the field entirely. The enum is real; two thirds of it are unreachable in this
context, and the whole field is unreachable for the ownership model we deliberately chose.

**Instance 2.** `metafieldDefinitionTypes` reports, for `metaobject_reference`, the
supported validations `metaobject_definition_id` **and** `metaobject_definition_type`. I
used the type variant, since it keeps the model file free of environment-specific GIDs. On
a metaobject *field* definition it is rejected with `INVALID_OPTION`, *"Validations require
that you select a metaobject"*. The type variant is presumably admissible for metafield
definitions; the introspection endpoint does not distinguish the two owners.

**Instance 3**, added later the same day. A `list.file_reference` field for mixed image and
PDF attachments: I wrote `file_type_options: ["Image","File"]`, because `File` is the
obvious name and the validation name itself carries no value list. Rejected with
`INVALID_OPTION`: *"Validations must be one of the following file types: Image,
GenericFile, Video, Model3dEnvironmentImage, Model3d."* Same shape again, with a twist that
sharpens the proposal: here the admissible set is not discoverable by introspection **at
all**, because the validation's value is a plain string. The only way to learn it was to be
told by a failed call.

The common shape: **the schema answered "does this value exist", I acted as though it had
answered "may I use this value here".** Those are different questions, and no amount of
care in reading the schema closes the gap, because the schema does not carry the answer.

Where the existing rules sit relative to this:

- **§2.2** is the closest fit and already speaks of the "effective runtime/parser", but it
  frames verification as *version and toolchain* compatibility. All three failures were
  inside one confirmed API version, with a correct introspection in hand. Nothing in the section
  says that a declaration's presence is not a permission.
- **§1.4** got me to introspect instead of recall, and its "AI summary is not a live
  source" clause has the same spirit. But I did fetch the primary artifact. §1.4 has no
  answer for a primary artifact that is authoritative about form and silent about context.
- **§1.5** would have caught it if I had labelled "this value is usable here" as a
  hypothesis. I did not, because it felt like a verified fact: I had just read it from the
  live schema.

**Adjacency worth naming**, per `Meta.md` §3.2's merge check: this is structurally close to
`proposal-2026-08-18-verification-population-completeness.md`, which covers "verified the
reported subset, concluded about the whole". Both are cases of a real check answering a
narrower question than the assertion drawn from it. They differ in the axis: that one is
about *population* (which items were checked), this one is about *modality* (existence
versus admissibility). If both are accepted, consider whether one clause covers both rather
than two near-duplicate additions.

## Proposed change

Add to `General.md` §2.2, after the existing sentence:

> A declaration is evidence of form, not of permission. A type, enum value, field, or
> option that appears in a schema, introspection result, or API reference MAY still be
> inadmissible at the concrete call site, because the constraint lives in the surrounding
> context (ownership model, owner type, resource state, plan or licence tier) rather than
> in the declaration. The agent MUST NOT treat presence in a declaration as proof of
> admissibility; where the difference matters, it MUST confirm against the actual call, or
> label the usage a hypothesis per §1.5 before relying on it.

## Expected impact

Prevents exactly the three failed runs above and the false confidence that produced them.
The behavioural change is small but specific: after introspecting, ask whether the schema
can even express the constraint that would forbid this value, and if not, expect the call
itself to be the only oracle. It also stops the documentation failure mode this session
uncovered, where a wrong snippet was recorded as verified because it was derived from a
correct introspection (`docs/04-datenmodell.md` §4.8 point 1 in the MO project).

## Risk / tradeoff

- Always-on token cost: roughly 90 tokens in a `[CRITICAL]` file. §3.3 budget check needed
  before applying; if §2.2's file is at its budget, the demotion review has to free space
  first.
- Risk of over-application: read literally it could invite a probe call before every
  schema-derived value, which would be waste. The "where the difference matters" qualifier
  is load-bearing and should not be trimmed by a later terseness pass.
- Partly a model-default in the sense that a careful reader might infer it. Three
  instances in a single session argue otherwise, which is the case for writing it down.

## Evidence

- Project `MO` (`/home/uwestrepp/work/projects/shopify/MO`), session 2026-08-19.
- The failures and their corrected form are recorded in `docs/04-datenmodell.md` §4.8,
  point 1 (`ÜBERHOLT`, admin access), point 5 (reference validations) and point 10
  (file type options), and in `store-schema/README.md` points 1, 2 and 7.
- Commits `2b022ee` (the script that encodes the workarounds) and `3f45ba3` (the
  documentation correction).
- The first instance additionally invalidated a snippet that had been in the project
  documentation as verified guidance since 18.08.2026, so the cost was not only the failed
  run.
- Instance 3 is recorded as point 10 of the same section, added under commit `ace89f1` and
  following. Three instances in one session, each costing a failed run plus a diagnosis
  round.
