# scanner skill — resources

## `typo3-extension-scanner`

Headless CLI runner for the TYPO3 Install-tool ExtensionScanner. Pulls the
matcher configurations from `UpgradeController` via reflection and runs
nikic/php-parser over the requested extensions (or every `packages/*`
when called with no extKey).

Requires the project's `vendor/autoload.php` (the TYPO3 install tool and
nikic/php-parser must be reachable from the project root passed via
`--project-root` or the script's CWD).

### Output modes

- default: human-readable per-extension findings followed by JSON
- `--summary`: one summary line per extension (files/matches/strong/weak)
- `--json`: JSON only

### How to use in a project

This file is the canonical version. Each project keeps its own runtime
copy so other developers (and CI) can run the scanner without depending
on a local Claude Code install.

Typical wiring (matches the fein13 layout):

1. Copy this file to `.aiassistant/scripts/typo3-extension-scanner` in
   the project repo.
2. Add a thin DDEV command wrapper, e.g.
   `.ddev/commands/web/typo3-extensionscanner`:

   ```sh
   #!/usr/bin/env bash
   ## Description: Run the TYPO3 ExtensionScanner headlessly
   ## Usage: typo3-extensionscanner [--summary|--json] [extKey ...]
   set -euo pipefail
   cd /var/www/html
   php ./.aiassistant/scripts/typo3-extension-scanner "$@"
   ```

3. Invoke via `ddev typo3-extensionscanner --summary <extKey...>` — the
   command interface the `/typo3:scanner` skill expects.

### Drift policy

The project copy MAY accumulate project-specific tweaks (additional CLI
flags, extra reporting columns, etc.). When a tweak is project-agnostic
and broadly useful, contribute it back to this canonical version.
