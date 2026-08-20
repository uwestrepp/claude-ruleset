# Guided GUI configuration: a named pattern for work the agent cannot click itself

```
Date:         2026-08-20
Status:       open
Origin:       session observation, MO Shopify project, working through docs/12 §12.3
Revisit when: a second project needs the same loop (TYPO3/Shopware backend, cloud console,
              SaaS admin), or the next /core:rule-friction cycle
```

## Problem

A recurring class of work has no home in the rule-set: configuration that lives behind a
GUI the agent cannot reach, while the user can. In the MO project this was the Shopify
admin (no CDP session, bot check blocks it). The work is neither "the agent does it" nor
"the user does it" but a tight loop between both, and doing it badly is the default:

- the agent announces a block of ten settings, the user clicks, and nobody knows
  afterwards which of the ten actually took effect;
- the agent documents **the user's report** ("done") instead of the read-back value, which
  quietly turns a measurement into hearsay;
- documentation is saved up until the end, and half of it is lost to context pressure;
- areas where read-back is impossible get documented in the same voice as measured ones,
  so a later reader cannot tell evidence from assertion.

The MO session avoided all four, but only because a hand-written handoff spelled the loop
out. That knowledge is currently project-local prose, not a reusable pattern.

## Proposed change

A skill, `/core:guided-config` (explicit activation required), carrying the loop:

1. **One point at a time.** Announce exactly one setting: path, target value, and why it
   is ordered here. Never a block.
2. **Order by effect, not by document.** Settings that change how everything else looks
   or behaves go first. In MO this was locale before notification templates; getting it
   wrong means doing the templates twice.
3. **Read back, do not transcribe.** Document the value read from the API, not the user's
   report. Where read-back is impossible, mark it explicitly as a visual check by a named
   person on a date.
4. **Write it down before the next point.** Same change-set, every time.
5. **Name the side effect before writing, not after.** Two settings that are each correct
   can combine into a broken state (MO: stock tracking plus DENY at zero stock made a
   shared test store entirely unsellable between two steps).
6. **Distinguish two status markers** in the artefact: read-back-verified versus visual
   check. One word each, and it is what keeps the document honest.

Registration per `General.md` §9.2: ledger entry in `CLAUDE.md` under core workflow skills
with the literal phrase "explicit activation required".

## Expected impact

Makes the loop reusable instead of re-derived per project, and puts the evidence
distinction (step 3) and the side-effect gate (step 5) where they cannot be forgotten.
Both are the steps a session under time pressure drops first, and both are the ones that
decide whether the resulting document can be handed to a colleague.

Step 5 is the one with teeth beyond documentation: it is a `General.md` §4.4 obligation
(no silent semantic changes) applied to a surface where the agent writes through the user's
hands, which is exactly where that rule currently has no concrete procedure.

## Risk / tradeoff

- **Overlap with `/core:batch`.** Batch governs many-item change cycles and already owns
  per-item approval. Guided config is narrower and differently shaped: the constraint is
  not review volume, it is that execution and verification sit with different actors. If
  the overlap turns out to dominate, the honest outcome is a section inside `/core:batch`
  rather than a new skill, and that should be checked before shipping.
- **Skill inflation.** One more explicit-activation skill in an already long ledger. It
  costs a ledger line always-on; the body only loads on invocation, so the `Meta.md` §3.3
  budget impact is one line, not the pattern.
- **Single incident so far.** One project, one session. The pattern is not yet proven to
  generalise beyond a store admin, which is why this is `open` and not applied.

## Evidence

- `MO` project, commit `bf44b08` (`[DOCS] MO-101 (klickarbeit) …`), session of 2026-08-20.
- The loop as written by hand:
  `.aiassistant/state/handoffs/done/handoff-20260819-164942-a5-klickarbeit.md`.
- Its result, including the two status markers that came out of it:
  `docs/12-konfiguration.md` §12.1 and the legend at the top of that chapter.
- Concrete instance of step 5 paying off, and of it half-failing: the stock-tracking step
  left a shared test store fully sold out between two writes, because the second write
  needed a scope the app did not have. Named before the write, so it was recoverable;
  recorded in `docs/12` §12.3.12.
