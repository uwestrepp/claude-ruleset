---
apply: by model decision
instructions: Apply only for Shopware 6 projects/tasks (custom plugins, ThumbnailService/media, storefront Twig/theme overrides, plugin migrations, deployment-helper).
paths:
  - "**/custom/plugins/**"
  - "**/custom/static-plugins/**"
  - "**/config/packages/shopware.yaml"
  - "**/src/Resources/app/storefront/**"
  - "**/src/Resources/app/administration/**"
---

# Shopware 6 Operating Policy

Normative keywords per `General.md`. Terse per `Meta.md` §3.2. Verify version/env first
(`General.md` §2.1): SW version from `composer.lock` (`shopware/core`); PHP CLI (worker/CLI
SAPI) may differ from FPM per host, verify separately; GD vs Imagick webp/avif delegate support
is per-host, probe before relying on image encoding.

## 1. Media & thumbnails

- Thumbnail sizes are DB state, not config files: `media_thumbnail_size` (global size pool) +
  `media_folder_configuration_media_thumbnail_size` (per-configuration assignment). Admin-managed.
- Folder configurations are frequently shared across differently-named folders via
  `use_parent_configuration`. Assign sizes per *configuration*, never per folder name (a name-based
  assignment leaks to unrelated folders sharing the config).
- `media:generate-thumbnails` returns 0 / "Skipped" (not an error) when the folder config has no
  thumbnail sizes, or the media fails `mediaCanHaveThumbnails` (requires `hasFile()` + `media_type`
  = `ImageType`, non-vector/animated/icon). `--strict` only regenerates a size whose DB record
  exists but whose file is missing; it does NOT create thumbnails for a size-less config.
- `ThumbnailService` is not `final` and has no interface; scaling/encoding is in private methods.
  To add formats: decorate the concrete class (`decorates` the FQCN service id), do NOT re-scale —
  transcode the already-written thumbnail files. The decorator `extends ThumbnailService`, does not
  call the parent constructor, and overrides all three public methods (`generate`,
  `updateThumbnails`, `deleteThumbnails`), delegating to the inner service.
- Media `customFields` are translatable → stored in `media_translation.custom_fields`, not on
  `media`. A repository `customFields` update merges keys (no CustomFieldSet needed for internal keys).

## 2. Storefront images

- `sw_thumbnails` is a TokenParser that always renders
  `@Storefront/storefront/utilities/thumbnail.html.twig` (block `thumbnail_utility_img`). Overriding
  that one block is the central hook covering every image surface (cms-element-image, product-box, …).
  Direct `<img>` in custom templates bypass it (audit custom templates before claiming global coverage).
- `<picture>` does NOT fall back to `<img>` when the chosen `<source>` 404s. Gate any modern-format
  `<source>` per-image on a proven-exists signal; never emit unconditionally.
- Mirror the core template's `load` flag on any added `<source>` (real `srcset` when eager,
  `data-srcset` when lazy) to preserve lazy-loading and any LCP `loading`/`fetchpriority` handling.

## 3. Plugins, migrations, deployment

- `shopware-deployment-helper` runs a plugin's migrations only on a plugin **version change**. A new
  migration added without bumping the plugin's `composer.json` `version` is NOT applied on deploy.
  Bump the version to trigger `plugin:update` (and thus the migration) on the next deploy.
- `bin/console database:migrate <plugin>` does not resolve plugin migration collections. Run plugin
  migrations via `plugin:update <Plugin>` (local/manual) or the version bump (deploy). Migrations are
  tracked in the `migration` table → idempotent across environments.
- `media:generate-thumbnails` is not part of the deploy. After size/thumbnail changes, regenerate
  manually per environment; AVIF encoding is CPU-heavy → off-peak or `--async` (queue). Obsolete
  thumbnails of removed sizes are not auto-deleted.
- Plugin PSR-4 namespace equals the plugin directory name; local packages resolve via the
  `custom/plugins/*` path repositories (Composer via `/composer:*`, commits via `/core:commits`).
