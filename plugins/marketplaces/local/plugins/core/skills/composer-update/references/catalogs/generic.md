# Collision-vector catalog: generic (ecosystem-agnostic fallback)

Fallback catalog for `/core:composer-update` when no ecosystem-specific catalog exists for the
detected stack. Satisfies `../catalog-contract.md`, but with **deliberately weaker scan power** —
without ecosystem knowledge the workflow cannot find framework-specific override mechanisms
(runtime class replacement, service decoration, event subscribers, template overrides). Be explicit
in the verdict: a clean generic scan is *lower confidence* than a clean catalog scan. When this
catalog is used, offer to author a proper ecosystem catalog (`../catalog-contract.md`).

---

## 1. Detection signature

Used when `composer.json`/lock matches no known ecosystem marker. Applies to plain libraries and
applications with no recognized framework override surface.

## 2. Change-map source strategy

No monorepo/API assumption. Per bumped package, degrade:
1. **CHANGELOG / release notes** between the locked and target versions (most packages ship one).
2. **Git-tag diff** — resolve the source repo (Packagist → `source.url`), fetch, `git diff
   <BASE>..<TARGET>` on the tags. Precise when a CHANGELOG is thin.
3. **GitHub/GitLab compare UI** if hosted there.
4. **Opaque** — no usable source. Record as opaque; scan degrades to public-API/reference checks
   only for that package, and the verdict says so.

Pay special attention to the package's own statement of **breaking changes / BC breaks** and any
security advisory (`composer audit`).

## 3. Collision vectors (descending risk)

`$SCAN` = project-owned source dirs (exclude `vendor/`).

### V1 — Composer patches (project- AND dependency-declared)
- **What:** `cweagans/composer-patches` (or `composer-patches-plugin`) applies patches from the
  project and from dependencies; a patch on a now-changed file may fail or re-open a fix.
- **Scan:**
  ```
  grep -rn '"patches"\|patches-file\|enable-patching' composer.json
  find . -path ./vendor -prune -o -name '*.patch' -print
  grep -rln '"patches"' vendor/*/composer.json vendor/*/*/composer.json
  ```
- **Triage:** patch target file ∈ change-map changed files → inspect; else `no collision`.

### V2 — Hard references to a bumped package's changed public API
- **What:** project code calls classes/functions of a bumped package whose **public** signature or
  behavior changed (`General.md` §4.5).
- **Scan:** identify the bumped package's top-level namespace(s) from its `composer.json`
  `autoload.psr-4`, then grep project imports/usages of those namespaces and intersect with the
  change-map's changed public symbols.
- **Triage:** referenced + public signature/behavior changed → `collision`, apply `General.md` §4.5
  (resolve callee, compare old/new signature, verify semantic mapping). Unchanged public API →
  call-compatible → `inherits fix`.

### V3 — Subclassing / extension points of changed classes
- **What:** project subclasses, decorates, or implements an interface of a changed class. Generic
  scanning can only find subclassing by name; framework DI/decoration is invisible here (the gap a
  real catalog closes).
- **Scan:** `grep -rnE "extends (Class1|Class2|…)\b|implements (Iface1|…)\b" $SCAN` for changed
  classes/interfaces.
- **Triage:** subclass overrides a changed method → `collision`; else `inherits fix`. Flag that
  DI-based overrides were **not** covered.

### V4 — References to moved / renamed / removed symbols
- **What:** a bumped package moved/renamed/removed a public symbol the project references.
- **Scan:** `grep -rn "<Symbol>" $SCAN` for symbols the change-map flags as moved/removed.
- **Triage:** reference to a removed/moved symbol → `collision`; verify resolution at target.

## 4. Regression-smoke surfaces

No ecosystem knowledge → smoke the project's own documented entry points (`Batch.md` §3 inventory):
run the project's test suite if present, plus the surfaces a `collision`/`V2` finding implicates.
State that generic smoke is broad, not targeted.

## 5. Deploy caveats

- Verify the lock diff names **every** expected package transition (use `-W` for transitive bumps).
- Re-verify all composer patches re-apply post-update.
- Confirm the correct target branch before committing the lock; run any project build/compile/cache
  step the update requires.
