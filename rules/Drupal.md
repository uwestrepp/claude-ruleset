---
paths:
  - "**/*.module"
  - "**/*.theme"
  - "**/*.install"
  - "**/*.profile"
  - "**/*.info.yml"
  - "**/web/sites/**"
  - "**/drush/**"
  - "**/config/sync/**"
---

# Drupal Operating Policy for Coding Agent
Applies when working on Drupal projects (core, modules, themes, install profiles).

Drupal-specific behavior layered on the global baseline. Version/identity/exec-context verification per `General.md` §2; operating modes per §4.6; testing per §5.2; Composer work per `/composer:*`; commits per `/core:commits`.

## 1. Version & environment verification (MUST)

Per `General.md` §2.1. For Drupal, verify: core major/minor (`composer.lock` `drupal/core`), PHP version, Composer constraints. Note scaffolded checkouts often omit `web/core` and `vendor/` until `composer install` — do not assume core source is present locally; verify before reading it. If unknown and material → ask.

## 2. Render pipeline facts (verified against core 11.3 source, 2026-07 — MUST respect; re-verify on a newer core major before relying on them)

- `#attached['html_head']` entries render in **insertion order**; Drupal does NOT sort them by `#weight` (`HtmlResponseAttachmentsProcessor::processHtmlHead`). To guarantee one head element precedes another (e.g. an inline config variable before the external script that consumes it), add it earlier in the array.
- Inline content via `html_tag` `#value` is passed through `Xss::filterAdmin()` then wrapped in `Markup::create()` (`Element\HtmlTag`): NOT HTML-escaped, but XSS-filtered. Inline JS is emitted raw; keep it free of `<`/`>` and HTML-entity-like sequences, or wrap the value in a `MarkupInterface` deliberately.
- Output that varies by language/user/role/etc. MUST declare the matching cache context (e.g. `languages:language_interface`) so render/page cache does not serve a wrong-variant response.

## 3. Local environment (SHOULD)

- Bring the site up via the project's own tooling (Makefile / psh / ddev / compose), not ad-hoc command chains.
- `drush site:install --existing-config` needs an empty/clean database; a stale persisted DB volume causes "already installed" errors or installer redirects. Reset the DB (not the whole project) when this occurs.
- In-container execution and file-ownership discipline per `General.md` §2.3: run install/build tooling as the service user whose UID owns the bind-mounted project (not root), and never broad-`chown` a mounted DB data directory or global host caches.

## 4. Verification (MUST)

Per `General.md` §5.2, choose and execute paths per touched surface: frontend render/routes, backend/admin, API/JSON:API, drush/CLI, cron/queue, config-import, `update.php`. For theme/preprocess/render changes, verify the actual rendered markup (request the page, inspect the `<head>`/DOM), not only static reasoning. If a required path cannot be run, state the blocker and the exact follow-up step.

End of policy.
