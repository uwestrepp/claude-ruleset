# Collision-vector catalog contract

A **catalog** is the ecosystem-specific knowledge the `/composer:update` workflow needs to turn
a generic "what changed upstream" map into a concrete "does *this* project collide" verdict. The
workflow engine is ecosystem-agnostic; all framework knowledge lives in catalogs
(`references/catalogs/<ecosystem>.md`).

This contract defines what every catalog MUST provide. It was derived against the TYPO3 catalog (the
first real instance). A second ecosystem (Symfony, Shopware, …) is added as one new file satisfying
this contract — **not** as a new skill. Keep catalogs to *stable, release-independent* knowledge; a
specific release's change-map is a generated work artifact, not part of the catalog.

A catalog MUST provide the following five sections.

## 1. Detection signature

How the workflow recognizes that a project (or an in-scope package) belongs to this ecosystem —
e.g. the marker package in `composer.lock` (`typo3/cms-core`, `symfony/framework-bundle`,
`shopware/core`) and the version range this catalog's vectors are valid for. State if the catalog is
version-line-specific (a vector that exists in v13 may not in v10).

## 2. Change-map source strategy

Where to fetch the upstream BASE→TARGET diff for this ecosystem's packages, ordered best-first, so
Phase 4 can produce a precise map. State the *best available* method and how it degrades:

- Is the source a monorepo with a compare API (file/method-precise)? Give the URL shape.
- How are FQCNs / changed methods derived from the diff (e.g. path → namespace mapping)?
- What is the fallback when the API/precise diff is unavailable (CHANGELOG, tag diff)?
- Known rate limits or auth caveats.

If a package in this ecosystem is opaque (no usable source), say how the scan degrades for it.

## 3. Collision vectors (ordered by descending risk)

The core of the catalog: the concrete ways a project in this ecosystem can "touch" changed upstream
code, each with a **scan recipe** (grep/glob pattern or intersection logic) and a **triage rule**
(how to read a hit → verdict). Order by risk so Phase 5 inspects the dangerous vectors first.

Each vector entry MUST state:
- **what it is** (the mechanism — e.g. runtime class replacement, subclassing, patching, template
  override, moved-symbol reference),
- **scan recipe** — the exact command/pattern to find candidate hits in project-owned code (and,
  where relevant, in `vendor/**/composer.json` — but never a behavioral scan of `vendor/`),
- **triage rule** — how to turn a hit into `no collision` / `inherits fix` / `collision`, including
  the "verify project-wide, not just the first file" discipline and the changed-*method* vs
  changed-*class* distinction.

Vectors MUST cover, where the ecosystem supports them: runtime overrides/replacement, subclassing of
a changed class+method, composer patches (**both** project-declared and dependency-declared — the
latter is easy to miss), public-signature/call-site changes (`General.md` §4.5), copied/overridden
shipped resources (templates/config), and references to moved/renamed/extracted symbols.

## 4. Regression-smoke surfaces

The runtime surfaces to exercise after the update for this ecosystem (Phase 7 step 3), so validation
is targeted rather than generic — e.g. which subsystems the typical security surface touches
(backend file module, forms, scheduler, frontend rendering, auth/redirect).

## 5. Deploy caveats

Ecosystem- or workflow-specific rollout traps the engine cannot infer — e.g. the *mid-major-upgrade
branch* trap (the target line lives on a separate branch while production is an older major; merging
the lock onto the wrong branch is destructive and there may be no standalone deploy), patch
re-application order, or cache/compile steps required post-update.

---

## What a catalog is NOT

- **Not** a per-release change-map. The 13.4.30→13.4.31 file list is a generated asset (Phase 4
  output), not catalog content. The catalog tells you *how* to build and read such a map.
- **Not** a workflow. No phases, no Pass model — those live in the skill and `Batch.md`.
- **Not** version mechanics. Resolution order, lock discipline, `-W` semantics belong to
  `/composer:knowledge`; reference it, don't restate it.
