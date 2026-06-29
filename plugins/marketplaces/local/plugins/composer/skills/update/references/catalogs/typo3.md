# Collision-vector catalog: TYPO3

Ecosystem catalog for `/composer:update`. Satisfies `../catalog-contract.md`. Generalized from
the TYPO3 **13.4.31** security rollout (the worked example, see §6 below) to **any TYPO3 patch/minor
`composer update`** within a major line.

Use this for patch/minor deltas (e.g. 13.4.30 → 13.4.31, 12.4.x → 12.4.y). For a **major** upgrade
(v10 → v13, deprecation/breaking remediation), stop and use `/typo3:upgrade` instead.

---

## 1. Detection signature

- Marker: `typo3/cms-core` present in `composer.lock` (composer mode). Also `typo3/cms-*` sysext
  packages.
- Version line: vectors below are valid for **TYPO3 v10–v13 composer mode**. In v13, XCLASS and
  global config live in `config/system/*.php`; legacy installs may still carry
  `htdocs/typo3conf/AdditionalConfiguration.php`. Confirm which exist per project.
- Multi-package: the same delta can move several `typo3/cms-*` packages plus transitive deps
  (e.g. `typo3/html-sanitizer`); treat each under this catalog.

---

## 2. Change-map source strategy

TYPO3 core is a **GitHub monorepo** → file- and method-precise diffs are available.

1. **Compare API** — `https://api.github.com/repos/TYPO3/typo3/compare/<BASE>...<TARGET>` (tags like
   `v13.4.30`, `v13.4.31`). The compare endpoint caps at ~300 files; for larger deltas aggregate
   per-commit (`/commits/<sha>`) to beat the cap. Unauthenticated API is rate-limited (~60 req/h);
   one release's per-commit fetch fits.
2. **Raw diffs** — `https://github.com/TYPO3/typo3/commit/<sha>.patch` (non-API endpoint) for any
   single commit you need to inspect by hand. SHAs come from the compare result.
3. **Security advisories** — TYPO3 publishes `TYPO3-CORE-SA-*` advisories; cross-reference the
   `[SECURITY]` commit subjects.

**Satellite packages are NOT in the `TYPO3/typo3` monorepo.** Several `typo3/*` packages live in
their own repos and ship their own security releases — notably `typo3/html-sanitizer`
(`github.com/TYPO3/html-sanitizer`, namespace `TYPO3\HtmlSanitizer\`), `typo3/phar-stream-wrapper`
(`TYPO3\PharStreamWrapper\`), and `typo3/cms-composer-installers`. For these, the compare URL is the
satellite repo (`…/repos/TYPO3/<repo>/compare/<BASE>...<TARGET>`), and their changed classes are
under their own namespace root, **not** `TYPO3\CMS\`. A patch-line `composer update` frequently moves
a satellite (e.g. `html-sanitizer` 2.3.1→2.3.2 is a `[SECURITY]` bump) *without* moving
`typo3/cms-core` at all — build a separate change-map per satellite and intersect against its own
namespace. (Verified: the rbk run found `html-sanitizer` 2.3.2 as the only security mover while core
was already current.)

**FQCN derivation** (path → namespace), the key to intersecting with project `use` statements:
`typo3/sysext/<ext>/Classes/<Path>.php` → `TYPO3\CMS\<StudlyExt>\<Path-with-\\>`. Map the sysext key
to its namespace segment (`core`→`Core`, `backend`→`Backend`, `extbase`→`Extbase`,
`frontend`→`Frontend`, `filelist`→`Filelist`, `form`→`Form`, `indexed_search`→`IndexedSearch`,
`install`→`Install`, `scheduler`→`Scheduler`, …). `Tests/` files are `export-ignore`d → never in
`vendor/`; exclude them from the override-risk surface.

Per package, record: changed files, the FQCNs of changed classes, and (where it matters) the
**changed method names** — the override risk is real only when a project subclasses a changed class
**and** overrides one of the changed methods.

**Reuse:** build this map once per BASE→TARGET as a portable package
(`~/work/projects/<release>-rollout/` with `change-map.md` + `data/{files_full.json,fqcns.txt,
compare.json}`); later projects reuse it and only re-confirm BASE.

---

## 3. Collision vectors (descending risk)

Scan **project-owned dirs only** — set `SCAN` from the actual layout (e.g.
`packages extensions config src`, or `app/packages app/config …`). **`SCAN` MUST include the
global-config locations** (`config/system/*.php`, package `ext_localconf.php`, and legacy
`htdocs/typo3conf/AdditionalConfiguration.php` where present), or the XCLASS vector under-scans.
Sass/JS-only dirs contribute zero PHP hits — harmless to include, but not coverage. **Never scan
`vendor/`** for overrides; scan `vendor/**/composer.json` only for dependency-declared patches.

Below, `$SCAN` is the project dir set and the change-map's data lives in `$MAP/data/`.

### V1 — Composer patches (project- AND dependency-declared)
- **What:** `cweagans/composer-patches` applies patches from the project *and from dependencies*. A
  patch on a changed file may fail to apply or silently re-open a fix.
- **Scan:**
  ```
  # project-declared
  grep -rn '"patches"\|patches-file\|enable-patching' composer.json packages/*/composer.json extensions/*/composer.json
  find . -path ./vendor -prune -o -name '*.patch' -print
  # dependency-declared (easy to miss)
  grep -rln '"patches"' vendor/*/composer.json vendor/*/*/composer.json
  ```
- **Triage:** for each patch targeting a `typo3/cms-*` file, check whether that file is in the
  change-map's changed-file list. Patched **and** changed → inspect (may fail to apply / re-open).
  Patched but unchanged → `no collision`.

### V2 — XCLASS of a changed class
- **What:** `$GLOBALS['TYPO3_CONF_VARS']['SYS']['Objects'][CoreClass::class] = [...]` replaces a core
  class at runtime.
- **Scan:** `grep -rn "\['SYS'\]\['Objects'\]" $SCAN`
- **Triage:** is the XCLASS *target* a changed class (in the change-map)? If not → `no collision`.
  If yes → drop to V3 (does the replacement override the changed method?).

### V3 — Subclass of a changed class overriding a changed method
- **What:** the project subclasses a changed core class (via XCLASS or plain extension) and overrides
  exactly the method a commit changed.
- **Scan:** for each changed method `m` of changed class `C`, grep project-wide (a subclass can live
  in any package): `grep -rnE "function (m1|m2|…)\b" $SCAN`. Also verify the subclass `__construct`
  is still compatible if the parent constructor changed (usually unchanged in patch releases).
- **Triage:** changed method **not** overridden anywhere → `inherits fix` (the project transparently
  gets the fix). Changed method overridden → `collision`, classify `manual`, inspect against the
  actual diff. **Verify the grep returns empty project-wide** — a subclass overriding *other* methods
  but not the changed one still inherits the fix; only a project-wide empty result proves it.

### V4 — Imported-and-changed (call-site / public-signature, `General.md` §4.5)
- **What:** the project imports/calls a changed class; a public signature or semantics changed.
- **Scan:** intersect the project's imports with the changeset:
  ```
  grep -rhoE '^use TYPO3\\CMS\\[A-Za-z0-9\\]+' $SCAN | sed 's/use //' | sort -u
  #  ∩ change-map FQCNs (security) AND full changed-file FQCNs
  ```
- **Triage:** for each hit not already covered by V2/V3: did a **public** signature change? (In a
  typical patch release, none do — verify, don't assume.) Public signature unchanged → call-compatible
  → `inherits fix`. Public signature changed → `collision`, apply `General.md` §4.5.

### V5 — Overridden shipped Resources/Configuration
- **What:** the project copies/overrides a shipped Fluid template, TypoScript, TCA, or XLF that the
  release changed.
- **Scan:** from the change-map, list changed files under `Resources/`, `Configuration/`,
  `Language/`. Check whether the project overrides any of them (template override paths, TCA
  overrides, `locallang` overrides).
- **Triage:** overridden + changed → `collision` (the project shadows the fix); else `no collision`.

### V6 — References to moved / renamed / extracted symbols
- **What:** non-security bugfix commits sometimes extract/rename a class (e.g. a deserializer split);
  a project referencing the old symbol breaks.
- **Scan:** `grep -rn "<MovedClassA>\|<MovedClassB>" $SCAN` for symbols the change-map flags as
  moved/renamed.
- **Triage:** reference present → verify the symbol still resolves at the target version; else
  `collision`.

---

## 4. Regression-smoke surfaces

After the update, exercise the surfaces the security/bugfix set touches (proportional to the actual
delta): **BE file module** (clipboard, image-process, file-download, metadata), **forms** (custom
`FormRuntime`/finishers), **scheduler**, **indexed-search FE output**, **FE login/redirect**
(`sanitizeLocalUrl`), plus any project surface a `collision` finding implicated. `typo3 --version`
should report the target patch level; FE/BE should return 200 after a cache flush.

---

## 5. Deploy caveats

- **Mid-major-upgrade branch trap.** A project may be live on an older major (e.g. `master`/
  `production` on v10) while the new line lives on a separate branch (e.g. `release/typo3_13`, far
  ahead). The patch belongs **only on the line that carries the target major** — merging a 13.4.x
  lock into a v10 `production` is destructive, and there is no standalone deploy; the fix goes live
  with the broader go-live. Before committing: `git show <branch>:composer.lock` on each candidate
  branch to find the target line, and confirm the deploy mechanism (push-triggered CI vs. manual
  Deployer).
- **Transitive security bumps.** Use `-W` so transitive security deps come along
  (e.g. `typo3/html-sanitizer`); verify the lock diff names **both** the headline `cms-core` bump and
  the transitive one.
- **Patch re-application.** Project/dependency composer patches re-apply at install time; confirm
  they still apply cleanly post-update.

---

## 6. Worked example

`~/work/projects/typo3-13.4.31-security-rollout/` — the 13.4.30→13.4.31 rollout this catalog was
generalized from. Holds the project-independent `change-map.md` (the override-risk surface, exact
changed methods per class, the `EMU::addTcaSelectItemGroup` semantics note), `data/`
(`files_full.json`, `fqcns.txt`, `compare.json`), the portable scan recipe, and per-project records
for `garant`, `fein/13`, `sdk.neva` (all `no collision`, full 311-file changeset checked). Use it as
the reference shape for a fat shared change-map and thin per-project records; reuse its data verbatim
for any other project still on the 13.4.30 baseline.
