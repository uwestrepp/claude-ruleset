---
name: composer-update
description: "Activate via /core:composer-update (optional ecosystem hint, e.g. typo3) before any non-trivial Composer update in a customized project — security patches and patch/minor bumps where project customizations (local packages, patches, XCLASS/decoration/overrides) could collide with the update delta. Workflow: baseline → dry-run delta → reusable upstream change-map → intersect with project customizations via a pluggable collision-vector catalog (references/catalogs/<eco>.md; ships TYPO3 + generic; offers to author missing catalogs) → document → gated rollout. Layers on /core:batch; references /core:composer and /core:commits. explicit activation required — auto-suggest (do not auto-run) on requests like 'safely update <package>', 'roll out a security update / CVE fix across projects', 'will this update break our customizations'. NOT trivial adds in vanilla projects (/core:composer); NOT major-version migrations (/typo3:upgrade)."
argument-hint: [ecosystem|scope]
allowed-tools: [Read, Edit, Write, Glob, Grep, Bash, Agent]
---

# Composer Update Workflow (informed, gated)

Safe, informed Composer updates for **customized** projects. The premise: never run
`composer update` blind. First learn the exact version delta, map what upstream changed between
the locked and target versions, intersect that against the project's own customizations to find
collisions, document the result, and only then run the update — gated on a clean or fully-triaged
finding set.

This is a **workflow** skill. It builds on the batch foundation and defers mechanics and discipline
to the existing knowledge skills rather than duplicating them. Resolve every referenced section into
context before relying on it (`General.md` §9.3):

- **`Batch.md` §1 (phase template), §9 (Pass 1/2/3 + non-skippable triage/compliance gates), §2
  (toolset gate), §3 (inventory/baseline), §7 (agent delegation), §8 (reporting).** Activate
  `/core:batch` or read those sections; they are binding here and MUST NOT be weakened (`Batch.md`
  §9.1 non-circumvention).
- **`/core:composer`** — version resolution order, lock-file discipline, `--with-dependencies` vs
  `-W`, dev-overrides. Mechanics live there; do not restate them.
- **`/core:commits`** — commit schema + ticket traceability for the lock commit.
- **`General.md` §2.3** (exec-context routing), **§4.5** (upstream-contract verification),
  **§5.2** (test-path selection), **§8.3** (topic-close commit), **`Meta.md` §1.1** (checkpoints).

## Scope boundary (read first)

- **This skill** = patch/minor updates and security rollouts. The question is *"will pulling this
  delta silently break, or silently re-open, one of my customizations?"*
- **`/typo3:upgrade`** = major-version upgrades. The question there is *"what must I migrate"*
  (deprecations, breaking changes). If the task is a major TYPO3 jump, stop and use that skill.
- **`/core:composer`** = a knowledge reference for resolution/lock questions and trivial
  add/require in vanilla projects. If there are no project customizations at risk, this workflow is
  overkill — say so and defer to `/core:composer`.

When the target sits at a boundary (e.g. a minor bump that also crosses a framework's own
deprecation line), name the ambiguity and ask before proceeding (`General.md` §1.1).

---

## 1. Execution Phase Template (MUST)

Specializes `Batch.md` §1. Phases MUST NOT be reordered; omit only when genuinely inapplicable and
say so.

| Phase | Name | Description |
|-------|------|-------------|
| 0 | Toolset & env gate | `Batch.md` §2 + locate composer root and exec context (§2 below) |
| 1 | Baseline capture | Locked versions of in-scope packages; reconcile with any existing change-map BASE (§3) |
| 2 | Dry-run delta | Authoritative per-package `current→target` set via `--dry-run` (§4) |
| 3 | Ecosystem detect + catalog resolve | Detect ecosystem; load the collision-vector catalog or fall back + offer to author one (§5) |
| 4 | Change-map build | Best-effort per-package upstream diff; build/refresh the reusable change-map asset (§6) |
| 5 | Impact scan | Intersect change-map with project customizations via the catalog vectors; classify per `Batch.md` §9 (§7) |
| 6 | Document | Fat reusable change-map + thin per-project record (§8) |
| 7 | Gated rollout | Only on clean/triaged: run the update, re-verify patches, regression-smoke, commit (§9) |
| 8 | Validation + §4.5 | Upstream-contract verification of any changed public signatures (§10) |
| 9 | Handover & checkpoint | `Batch.md` §8.2 final report + `Meta.md` §1.1 (§11) |

A meta checkpoint (`Meta.md` §1.1) is mandatory at the end of Phase 4 (change-map built) and
Phase 9, per the batch phase-boundary triggers.

---

## 2. Phase 0 — Toolset & environment gate (MUST)

Run the `Batch.md` §2 gate, plus:

1. **Locate the composer root** — the directory holding the in-scope `composer.lock`. This is
   project-specific: repo root for some layouts, a nested `app/` for others (`General.md` §2.4).
   Confirm before any command. **Never operate against `vendor/`'s own composer files as the root.**
2. **Resolve exec context** (`General.md` §2.3): host vs container. If the project uses ddev, all
   composer invocations are `ddev composer …`; inside the container they are native `composer …`.
   State the chosen mode once.
3. **Confirm target intent** — which packages and which target (a named security advisory, a
   specific version, or "latest within the constraints"). If unstated and material, ask.

Do not proceed past Phase 0 if the root or exec context is ambiguous.

---

## 3. Phase 1 — Baseline capture (MUST)

Record the **currently locked** version of every in-scope package (read `composer.lock`, do not
trust `composer.json` constraints). This is the change-map's BASE.

If a reusable change-map already exists for this ecosystem/release (§6), reconcile:

- **Locked == change-map BASE** → the map applies exactly; reuse it.
- **Locked older than BASE** → the real delta is *larger* than the map. Either regenerate the map
  for the project's actual baseline, or treat the map as a lower bound and widen the scan. State
  which.
- **Locked newer/equal to TARGET** → nothing to do for that package; note it.

---

## 4. Phase 2 — Dry-run delta (MUST)

Get the authoritative update set **without changing anything**:

```
composer update <selector> --dry-run --with-dependencies     # scoped
composer update --dry-run -W                                  # or full, incl. transitive
```

Use the dry-run output — not assumptions — to enumerate every package transition `name: A → B`.
Then:

- **Split direct vs transitive.** Transitive bumps are easy to miss and can carry their own
  security fixes. If the headline update pulls a transitive security bump, the rollout MUST use `-W`
  (`/core:composer`).
- **Flag security-relevant transitions** (advisory references, `composer audit` if available).
- **Flag floating dev/branch-constrained packages (ecosystem-independent trap).** A package
  constrained `@dev`/`dev-*`/branch-alias whose lock currently pins a *non-default* branch is
  recomputed by **any** `composer update` — even a single-package, no-`-W` one — to the repo's
  default branch, so the dry-run shows it "upgrading" (e.g. `dev-feature/x → dev-main`). This is a
  lock-recomputation side-effect, **not** an upstream-content change, and it most often hits a
  project's own first-party packages. Surface every such transition explicitly and confirm intent
  before rollout: a feature-branch pin may be deliberate local-dev state that must be preserved (and
  must NOT be committed as `dev-main`). Re-scoping the update does not avoid it; only an explicit
  branch pin or a deliberate decision does. (Verified on the rbk run: three `@dev` first-party
  packages floated to `dev-main` even on a flagless single-package update.)
- This per-package transition list defines the scope of Phases 4–5. A package whose version does
  not move is out of scope.

---

## 5. Phase 3 — Ecosystem detect + catalog resolve (MUST)

1. **Detect the ecosystem** from `composer.json`/lock (e.g. `typo3/cms-core` → TYPO3;
   `symfony/framework-bundle` → Symfony; `shopware/core` → Shopware; otherwise generic library).
   A project may match more than one — handle each in-scope package under the catalog that owns it.
2. **Resolve the catalog**: load `references/catalogs/<ecosystem>.md`. Each catalog states what the
   skill needs per `references/catalog-contract.md`: detection signature, change-map source
   strategy, ordered collision vectors + scan recipes, regression surfaces, deploy caveats.
3. **No catalog for the detected ecosystem** → load `references/catalogs/generic.md` for a
   best-effort scan, AND tell the user no ecosystem catalog exists. Offer to **author one**
   (self-extension): a new `references/catalogs/<ecosystem>.md` satisfying the contract, derived
   from what this run discovers. Do not silently proceed as if the generic scan were complete —
   state the reduced confidence.

Always state which catalog(s) drove the scan, so coverage is auditable.

---

## 6. Phase 4 — Change-map build (MUST)

For each meaningfully-bumped package, build a map of what changed between BASE and TARGET. This is
**best-effort and method-agnostic** — be explicit about which method yielded each package's map and
flag packages that stayed opaque. Source ladder (use the catalog's strategy first, then degrade):

1. **Monorepo compare API** (e.g. TYPO3 on GitHub: `compare/<BASE>...<TARGET>`) → file- and often
   method-precise. Best.
2. **CHANGELOG / release notes between tags** → coarse but usually names the touched areas.
3. **Git-tag diff on the locked source reference** (clone/fetch the package's repo, `git diff
   <BASE>..<TARGET>`) → precise when no API exists.
4. **Packagist → repository link** to locate the source for (3).
5. **Opaque** — no usable source. Record it as opaque; the impact scan for that package falls back
   to public-API/reference checks only, and the verdict says so.

**Reusable-asset discipline (do not flatten).** The change-map is built **once per
release/ecosystem**, project-independently, and reused across every project receiving the same
update. Mirror the proven two-artifact split:

- **Fat shared change-map** — `change-map.md` (override-risk surface, per-method notes, collision
  vectors) + `data/` (machine-readable changed-file list, FQCNs, provenance). Lives in a portable
  package outside any single project (e.g. `~/work/projects/<release>-rollout/`), so any project can
  pick it up. Build it once; on later projects, reuse and only re-confirm the BASE (§3).
- **Thin per-project record** — produced in Phase 6, per project.

If a shared change-map for this exact BASE→TARGET already exists, reuse it instead of regenerating.

---

## 7. Phase 5 — Impact scan (the value step) (MUST)

Intersect the change-map with the project's **own** customizations, using the catalog's ordered
collision vectors. **Scan project-owned code only — never `vendor/`** (except scanning
`vendor/**/composer.json` for dependency-declared patches, which the catalogs call out explicitly).
Identify the project-owned dirs (packages/extensions/config/src + global-config locations) before
scanning; under-scoping silently hides collisions.

For each vector the catalog defines, run its recipe and triage every hit against the actual upstream
diff. Then **classify findings using `Batch.md` §9** (`safe` / `provable` / `manual`) and run the
non-skippable triage/compliance gate (`Batch.md` §9.1) — publish and persist the triage packet
before any rollout. The collision verdict per finding is one of:

- **no collision** — the changed code is not touched by this customization (e.g. a patch targets a
  file outside the changeset; an XCLASS targets an unchanged class).
- **inherits fix** — the customization touches the changed class but not the changed *method*, so
  the fix is inherited transparently (verify project-wide, not just in the one file you happened to
  open).
- **collision** — the customization overrides/patches/copies exactly what changed; manual
  inspection required, classified `manual`.

Delegate large finding sets per `Batch.md` §7 (`contract-researcher` for >10 §4.5 lookups).

---

## 8. Phase 6 — Document (MUST)

Two durable artifacts (`Meta.md` §2.2):

- **Fat shared change-map** (§6) — already project-independent; update its per-project status
  tracker.
- **Thin per-project record** at `.aiassistant/state/<release>-update-map.md` in the project. It
  records only what was checked *here*: BASE/exec-context/app-root, the project dirs scanned (SCAN),
  a findings table (vector → finding → verdict), the conclusion, and the concrete rollout recipe for
  this project. Keep project-independent facts in the shared map; keep project-specific evidence in
  the record.

---

## 9. Phase 7 — Gated rollout (MUST)

**Gate:** proceed only when the impact scan is clean OR every collision is triaged and approved
(`Batch.md` §9.1/§9.3). Otherwise stop and report.

1. **Run the real update** in the resolved exec context, scoped to the dry-run set. Use `-W` when a
   transitive (often security) bump must come along. **Verify the lock diff names *every* expected
   package transition**, not only the headline one — "lock-only, composer.json unchanged" is
   necessary but not sufficient evidence.
2. **Re-verify patches** — every project- and dependency-declared composer patch still applies
   cleanly post-update (a patch on a now-changed file may fail or re-open a fix).
3. **Regression-smoke** the catalog's affected surfaces with concrete before/after checks
   (`General.md` §5.2) — proportional to risk; high-risk collisions get explicit before/after runs.
4. **Confirm the deploy target before assuming a rollout shape** — a project mid-major-upgrade can
   carry the new line on a *separate branch* while its production branch is an older major; merging
   the lock onto the wrong branch is destructive and there may be no standalone deploy. Check the
   core/framework version on each candidate branch (`git show <branch>:composer.lock`), identify
   which branch carries the target line, and confirm the deploy mechanism before committing.
5. **Commit** the lock (lock-only expected) per `/core:commits`, on the correct branch, under the
   resolved ticket.

---

## 10. Phase 8 — Validation + upstream-contract verification (MUST)

Apply `General.md` §4.5 to any changed **public** signature a project calls or subclasses (rare in
patch releases, but verify rather than assume). Record the checked callee/signature location and the
executed verification path. Report validation evidence per `General.md` §5.2 / `Batch.md` §9.4,
referencing the regression surfaces from Phase 7.

---

## 11. Phase 9 — Handover & checkpoint (MUST)

Produce the `Batch.md` §8.2 final cycle report (branch + commit ids, what changed, validation
evidence per surface, residual risk, compliance checklist from `Batch.md` §9.1) and the `Meta.md`
§1.1 combined meta checkpoint. If a new ecosystem catalog was authored (or an existing one extended)
this run, note it as a knowledge-persistence action with its path.
