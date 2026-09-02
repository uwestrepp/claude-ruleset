# Paket 7: path-gated rule hygiene

Status: designed, NOT applied. Fully independent; no budget impact (path-gated files carry
no token budget). Value is readability: a rule file that becomes a fact list stops being read.

## Verbatim duplications of always-on rules (remove, they add nothing)

- TYPO3.md §2 closing sentence ("If any of these are unknown, the agent MUST ask") repeats
  General.md §2.1. The surface list above it is legitimate specialisation; the sentence is not.
- TYPO3.md §1.1 point 1 (determine target version) duplicates TYPO3.md §2 AND General.md
  §2.1. Threefold.
- TYPO3.md §1.3 restates General.md §9.1; its "MUST still pause and ask" list is a
  reformulation of General.md §1.2, §4.4, §7 plus /core:batch §5, with no TYPO3 content.
- TYPO3.md §5 is General.md §3.2 + §4.4 + §5.2 reordered. Only the word "blocking" is new.
- TYPO3.md §6 closing sentences are verbatim General.md §5.2. Same duplication in
  Drupal.md §4 closing sentence and Drupal.md §1 closing sentence.
- CleanCode.md Operating Modes, bullets "Legacy review" and "Uncertainty": verbatim
  General.md §4.6. Only "Generation into an existing codebase" carries weight.
- PER.md Operating Mode, "Legacy review" is a pure pointer to §4.2/§4.4; the "Uncertainty"
  bullet repeats §2.1 before adding real value with the version ladder.

## Files that drifted into fact collections

- CleanCode.md contradicts its own preamble ("only what model defaults do NOT cover") by
  listing exactly the defaults: `// increment i`, `save($user, true)`, "Do Not Swallow
  Exceptions", "Prefer Self-Documenting Code". Load-bearing parts: the Architectural Cut
  Gate triggers and the "generation into an existing codebase" bullet.
- PER.md is a reference spec, not a behaviour rule. "Well-Known PER-CS Baseline" and
  "PSR-1 Baseline" declare themselves well-established, i.e. model default. Move those to
  `references/`, keep Operating Mode plus "Deviation-Prone Rules" (which genuinely meets
  the example criterion: there the error does not look like an error while being made).
- Shopware.md is effectively one project's incident log. The behaviour facts are strong and
  meet the criterion (exit 0 with "Skipped" and no error; `<picture>` does not fall back to
  `<img>`; a migration without a version bump is not executed). But thumbnail size tables,
  `media_translation.custom_fields` and AVIF CPU load are project specifics that belong in
  that project's `.aiassistant/state/notes/`, not in the global rule-set. §1 bullet 5
  (decorator build instructions) is implementation guidance, not agent behaviour.
- Drupal.md §2 is a declared fact collection with an expiry date and all three entries meet
  the criterion. Risk: it is the seed of a growing list. Move to a skill reference at about
  five entries.

## Addition, not hygiene: the Shopware review cascade (record item 7)

Added 2026-09-02. Verified that no handoff scheduled this, and this package is the one that
opens `rules/Shopware.md`, so it belongs here. Note the direction is OPPOSITE to the rest of
this package: everything above REMOVES from that file, this ADDS one line.

Fact: deleting a customer does not cascade to `product_review`. `customer_id` goes `NULL`
and the row survives with `external_user` and its status — invisible in the storefront at
`status = 0` and indistinguishable from a genuine pending review in the administration.

Change: one line in `rules/Shopware.md` §1. Path-gated, no always-on cost.

The cross-check the record demands is already done and holds: this package proposes moving
project SPECIFICS out of `Shopware.md` (thumbnail size tables, `media_translation`
custom fields, AVIF CPU load). A cascade behaviour of the data model is a behaviour fact,
not a project specific, and it meets the same criterion as the facts this package keeps
(the wrong state does not look wrong while you are looking at it). Apply the removals and
this addition in the SAME change-set so the file is judged once, in its final shape.

## Exemplary, do not touch

- Twig.md §1 is the criterion in pure form: the `#`-commented line is still evaluated, and
  the code example IS the recognition cue.
- Persona.md: the repetition is the mechanism (Meta.md §3.2 salience exception), not
  redundancy. Explicitly out of scope for any dedup pass.
- Organisation.md: every fact is non-derivable and carries a misclassification trigger.
