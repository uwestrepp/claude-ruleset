# Seed calibration baseline — GMP-304 / GMP-340

The concrete agent-made effort estimates ("AWS", *Aufwandsschätzung*) that seed
the bands in `../SKILL.md` §4. Provenance: a Shopware 6 project (GMP), estimates
produced by Claude Code, `/effort high | claude-fable-5`, in the local project
setup. Source: `~/work/projects/gmp/.aiassistant/scratch/gmp-304/ticket-drafts.md`
(estimates) and `.aiassistant/state/gmp-340-umsetzung.md` (outcomes).

**Validity of this baseline.** The estimates were agent-made and *calibrated
against a prior observed execution* (two anchor sessions, see below). No actual
consumed wall-clock was ever recorded, so there is no numeric estimate-vs-actual
table. The accuracy claim rests on: (a) the practitioner's assessment that the
estimates were sufficiently close to the delivered result, and (b) a weak
calendar corroboration — GMP-341/342/343 (estimate sum ~4-6 h) were all
implemented and staging-verified within the single 2026-07-16 session. Treat the
bands as a validated-enough prior, not as measured ground truth.

## Methodology anchor (verbatim, ticket-drafts.md:7)

> AWS-Basis: agent-gestützte Umsetzung (Claude Code) im lokalen Setup dieses
> Projekts, inkl. Verifikation/Nachmessung und PR-Vorbereitung, als
> Session-Wall-Clock. Kalibriert an beobachteten Sessions dieses Projekts
> (2026-07-06: komplette lokale Analyse inkl. Setup-Debugging ≤3 h; 2026-07-07:
> Staging-Messung + PSI-Reproduktion + Ticketentwürfe ~0,5 h). NICHT enthalten:
> menschliches Review, Deploy-/Freigabezyklen, Abstimmung mit Externen (Hosting,
> URM).

Recommended settings under which these hold: `/effort high | claude-fable-5`
(handoff.md:55).

## Estimates and outcomes

| Draft → ticket | Task | AWS estimate | Outcome | Src |
|---|---|---|---|---|
| T1 → GMP-341 | Homepage blog-slider renders ALL entries (missing limit) | ~15-30 min quick-win + ~1-1.5 h plugin patch/decorator+test = **~1.5-2 h** | Staging-verified 2026-07-16, all AK met; done as decorator-clamp + content | :34 |
| T2 → GMP-342 | Theme assets served without gzip/brotli (nginx) | **~0.5-1 h** + hosting-coordination lead-time driver | Staging-verified 2026-07-16. Assumed hosting driver **vanished** (nginx config lives in repo) | :52 |
| T3 → GMP-343 | HTTP-cache bypass for cart/login sessions | trivial config ~15 min + verification ~1-1.5 h; `logged-in` eval separate ~1 h = **~2-3 h** | Staging-verified 2026-07-16. **Unplanned extra**: flash-message guard subscriber needed | :79 |
| — → GMP-343 (logged-in follow-up) | logged-in http-cache via Ajax widget | **~0.5-1 PT** | Implemented+verified locally 2026-07-17. Scope **grew**: own plugin + review decoupling; blocked on SSO test account | note* |
| T4 → GMP-344 | CWV mobile (LCP lazy, render-blocking CSS, CCM19, image formats) | quick-wins ~2-4 h + critical-CSS ~4-8 h (review-dominated) = **~1-1.5 PT** | Partial; critical-CSS **deferred** as marginal after T1-T3 landed | :101 |
| T6 → GMP-345 | EN channel SEO URLs return 404 | analysis ~1 h + fix ~0.5-1.5 h = **~1.5-2.5 h** (cause open) | Open / not started | :134 |
| T5 (not commissioned) | Async URM POST in checkout via message queue | message+handler+retry+tests ~2-3 h + E2E ~0.5-1 h = **~3-4 h** + URM-testenv driver | Discarded: behaviour is customer-wanted | :119 |
| T7 (not commissioned) | Uncached sales_channel query per page load | caching + profiler re-measure = **~0.5-1 h** | Not commissioned | :152 |
| T8 (not commissioned) | Collection of small static-scan findings (5) | ~20-45 min each (N+1 nearer ~1 h) = **~3-4 h** | Not commissioned | :172 |

`*` GMP-343 logged-in follow-up estimate from
`.aiassistant/state/notes/http-cache-logged-in-evaluation.md:83`.

## What the outcomes teach (feeds SKILL.md §5)

- **Two estimates that shifted came from scope discovery, not from mis-sizing the
  known work**: GMP-343 needed an unplanned flash-guard; the logged-in follow-up
  grew into its own plugin + review decoupling. Verification surfaces follow-on
  work the first estimate cannot see → widen the upper bound on changes touching
  shared/cached/personalised state.
- **A lead-time driver that was expected to dominate vanished** (GMP-342 hosting
  coordination): the nginx config was in-repo, so no external gate. Verify
  dependency assumptions early instead of inflating lead time.
- **Coupling made a large posted item marginal** (GMP-344 critical-CSS deferred
  once T1-T3 improved the baseline): re-estimate coupled tickets after each
  baseline change.
- **The estimates that ran to completion (T1-T3) landed in one session, roughly
  matching their summed AWS** — the strongest available signal that the method's
  in-scope numbers were realistic.
