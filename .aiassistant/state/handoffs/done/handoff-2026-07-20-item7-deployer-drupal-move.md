# Handoff — Item 7: cluster `deployer/` → `drupal/` (and TYPO3 analog)

Created 2026-07-20. Resume target: `~/work/projects/` (NOT the `~/.claude` repo).
Recommended settings: `/effort medium | claude-opus-4-8` (mechanical but careful;
escalate to high if a project's reference graph is tangled).

## Goal

Reorganise `~/work/projects/` by tech/purpose: move `deployer/*` under a `drupal/`
cluster (the `deployer/` sub-projects are Drupal), and cluster the TYPO3 projects
under their own dir analogously. Original item: "work/projects/deployer/... nach
work/projects/drupal/... verschieben -> risikolos möglich? analog typo3-projekte
auch unter eigenem ordner clustern?".

## Findings (this session)

- `~/work/projects/deployer/` contains Drupal deploy projects: `base, bbs, dgnb,
  gelita, gleisslutz, itd, kavo, krempel, mq, vecoplan`. Verified Drupal:
  `deployer/base` has `eslint.drupal.mjs`, `stylelint.drupal.mjs`, `psh.phar`,
  `htdocs`.
- The `~/.claude` rule-set does **NOT** reference these paths (grep clean) → safe
  from the rule-set side. Risk lives **inside the projects**.
- **Not risk-free.** Per-project risks to scan before moving:
  - ddev config: `.ddev/config.yaml` `name:` and any absolute `~/work/projects/deployer/...` paths.
  - docker/compose bind-mounts with absolute host paths.
  - IDE configs (`.idea/`) with absolute paths.
  - any tooling/scripts (deploy configs, psh) hardcoding the path.
- **Auto-memory association breaks on move (important):** auto-memory dirs are
  keyed on the project cwd, e.g. `~/.claude/projects/-home-uwestrepp-work-projects-deployer-itd/memory`
  exists. Moving `deployer/itd` → `drupal/itd` changes the cwd, so that memory dir
  will no longer match and the project loses its accumulated memory unless the
  corresponding `~/.claude/projects/<encoded-path>/memory` dir is renamed too.
  Handle this as part of the move.

## Next steps

1. Decide the target layout (`drupal/<project>`; identify which other top-level
   dirs are TYPO3 and their cluster name, e.g. `typo3/<project>`).
2. This is a multi-project operation → propose `/core:batch` governance.
3. Per project: reference scan (ddev name/paths, compose bind-mounts, `.idea`,
   hardcoded paths) → `git mv`/`mv` → fix references → rename the matching
   `~/.claude/projects/*/memory` dir → verify the project still starts (`ddev
   describe`/`ddev start`).
4. Note: `~/work/projects/deployer/` has no top-level `.git` (each sub-project is
   its own checkout) — moving dirs does not touch git remotes.

## Trigger prompt (paste to resume)

> Lies `~/.claude/.aiassistant/state/handoffs/handoff-2026-07-20-item7-deployer-drupal-move.md`.
> Setze Item 7 um: `~/work/projects/deployer/*` in einen `drupal/`-Cluster
> verschieben (+ TYPO3-Projekte analog clustern). Beginne mit dem Ziel-Layout und
> einem Per-Projekt-Referenz-Scan (ddev/docker/.idea/hardcoded Pfade + die
> zugehörigen ~/.claude/projects/*/memory-Dirs), schlage /core:batch-Governance vor,
> dann pro Projekt verschieben + verifizieren. `/effort medium | claude-opus-4-8`.
