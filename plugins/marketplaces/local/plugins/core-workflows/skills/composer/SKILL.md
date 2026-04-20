---
name: composer
description: "Activate via /core-workflows:composer or let Claude auto-activate when the task involves Composer dependency management. Covers Composer's version resolution order, tag-driven release flows for private/custom registries, dev-override patterns (narrow registry exclude + local path repo, consumer-side dev-constraint), the canonical-priority trap and its diagnostic order, lock-file discipline, and subrepo gating in parent repositories. Triggers: editing composer.json or composer.lock, running composer/ddev composer commands, \"composer update\", \"composer require\", \"composer install\", dev-override setup (local path package editing), debugging \"composer keeps installing the registry version instead of my local path\", canonical-priority conflicts, lock-file surprises during package bumps, tag-driven release confusion, package not resolving as expected, mixed dev/prod dependency questions."
argument-hint: [scope]
allowed-tools: [Read, Edit, Write, Glob, Grep, Bash]
---

# Composer Operational Rules

Project-agnostic rules that apply when editing Composer configuration, running
`composer …`, or wiring a local path package. Normative keywords per `General.md`.
Domain-specific adaptations (for example TYPO3's `extra.version` layering) live in
the corresponding domain rule file (e.g. `TYPO3.md` §10).

---

## 1. Version sources

### 1.1 Composer's version-resolution order (MUST)

Composer resolves a package's version from one of these sources, in order of precedence:

1. A top-level `version` field in the package's `composer.json`.
2. A reachable git tag on the local checkout (for path repositories) or on the upstream repo (for registry repositories whose builder derives dist artifacts from tags).
3. A derived `dev-<branch>` identifier inferred from the current git branch (path repositories) or a dev-constraint alias on the consumer side (registry repositories).

### 1.2 Tag-driven release flow (MUST NOT conflate with dev-override)

For packages published via a registry whose builder derives dist artifacts from git tags (typical for private composer registries), the canonical release action is **pushing a semver git tag** on the upstream repo. The registry then makes that version installable.

- The agent MUST NOT commit a top-level `version` field to an upstream repo as a replacement for tagging. Doing so either pins Composer to a stale version across subsequent tags, or silently overrides the tag-driven flow for downstream consumers.
- The agent MAY add a top-level `version` for **dev-only local overrides** (see §2), but MUST ensure this override does not leak into commits intended for release tagging, unless the convention of the target project already includes a maintained top-level `version` on sibling packages.

---

## 2. Dev Overrides (collapsed)

When a published vendor package needs temporary local edits, pick the narrowest
mechanism:

- **Preferred (SHOULD):** Add a narrow `exclude: [ "vendor/package" ]` entry on the
  canonical registry repo, plus a local `type: path` repo (typically
  `./packages/*` with `symlink: true`). The path clone needs a resolvable version
  per §1.1 (usually a top-level `version` aligned with the planned next release).
  Revert by removing the `exclude` entry plus the clone in one commit. Preferred
  over global reordering (§3.2) because it is scoped, self-documenting, and
  revertible.
- **Alternative (MAY):** Use a consumer-side dev constraint such as
  `"dev-feature/TICKET-XYZ as 13.1.0"` or `"dev-feature/TICKET#<sha>"`. Zero
  changes to the clone's `composer.json`, but the consumer constraint must be
  reverted before merge.
- **Hygiene (MUST):** Distinguish release-destined edits from dev-local
  scaffolding. Do NOT commit ad-hoc top-level `version` bumps or inline `replace`
  stubs to the upstream repo with the release, unless sibling packages already
  carry the same convention. If the release convention includes a top-level
  `version`, aligning with it is preferable to creating inconsistency.
- **Parent repo subrepo gating (SHOULD):** When the path package is a
  separately-versioned upstream repository, exclude `packages/<name>/` from the
  parent's git tracking (via `.gitignore`). Otherwise the parent records a
  submodule gitlink or embeds the subtree. Parent commits only the wiring.

---

## 3. The Canonical-Priority Trap (MUST understand before debugging)

### 3.1 The rule

Composer 2.x treats every repository as `canonical: true` by default. When two repositories both offer a package, the **higher-priority** one (earlier in the `repositories` array) is consulted first. Per https://getcomposer.org/repoprio, if the higher-priority repo provides *any* version satisfying the constraint, the lower-priority repo is **forbidden from contributing** — even if it has a strictly better-fitting version (e.g. a newer one).

Symptom: "composer keeps installing the registry version instead of my local path version." The error message when you force it via `composer require vendor/package:X.Y.Z` reads approximately:

> satisfiable by vendor/package[X.Y.Z] from path repo (./packages/*) but vendor/package[…] from composer repo (…) has higher repository priority. … That repository is canonical so the lower priority repo's packages are not installable.

### 3.2 Fixes, ranked

1. **Add `exclude` on the canonical repo** for the one package (§2). Preferred: narrow, intentional, revertible.
2. Set `"canonical": false` on the canonical repo entry. Broader (affects all packages in that repo) but sometimes appropriate for "registries are advisory, path always wins."
3. Reorder `repositories[]` to put the path repo first. Global change with a broad effect similar to option 2 — use only if the convention "local always overrides registry" is project-wide-desirable.

The agent MUST try option 1 before option 2 or option 3.

### 3.3 Diagnostic order (MUST)

When "composer keeps installing the registry version" surfaces, check in this order before clearing caches or forcing updates:

1. Is the canonical-priority rule biting? (inspect `repositories[]` order and canonicality)
2. Does the local path `composer.json` have a resolvable version — top-level `version`, reachable git tag, or a dev-branch identifier the consumer can accept?
3. Is the consumer constraint compatible with the local version under the project's `minimum-stability` / `prefer-stable`?

Only after these should the agent consider `composer clear-cache` or `composer update -W`.

---

## 4. Lock File Discipline (MUST)

When asked to "update one composer package", the agent MUST use `composer update <vendor>/<name> [--with-all-dependencies]` rather than blanket `composer update`, to keep the lock-file change set minimally scoped. The lock-file diff MUST be reviewable as part of the change.

If `composer update` shows substantial unrelated upgrades (symfony patches etc.), pause and ask before proceeding — the user may want a tighter scope.
