# Functional Baseline — work/projects Tech-Cluster-Reorg (Item 7)

Erhoben: 2026-07-23. Operation: Filesystem-Cluster-Umzug unter `~/work/projects/`.
Baseline-Charakter für einen Move: pro Projekt muss nach dem Umzug (a) die DDEV-`name`-Identität am neuen approot registriert sein, (b) das/die DB-Volume(s) `<name>-mariadb` (+ ggf. `<name>-postgres`) fortbestehen, (c) git-Hooks weiter greifen. Voller Container-Boot ist NICHT Teil der Baseline (Router vorbestehend "exited/unhealthy").

## Pre-existing Baseline-Breakage (NICHT durch diese Operation verursacht)
- DDEV Router: Status `exited` / "not healthy" — vorbestehend. Voll-Boot je Projekt daher separat/vom User zu prüfen; nicht Move-Verifikationskriterium.
- ssb: `ssb.authoring` und `ssb.update` tragen beide DDEV-`name: ssb12` (Namenskollision) — vorbestehend, unabhängig vom Move.

## DDEV-Registrierungen (approot = Move-Ziel-relevant)

Registry-Datei (verifiziert 2026-07-24): `~/.ddev/project_list.yaml`, Mapping `name: {approot: <abs. Pfad>}`.
Genau dieser approot-Wert wird durch den Move stale. Volume-Schema (verifiziert): `<name>-mariadb`
(+ optional `<name>-postgres`) — **name-basiert, NICHT pfadbasiert → überlebt den Move**.

| ddev name | approot jetzt | approot nach Move | Volume(s) (name-basiert, überleben) |
|---|---|---|---|
| bachert | work/projects/bachert | work/projects/typo3/bachert | bachert-mariadb |
| heller13 | work/projects/heller | work/projects/typo3/heller | heller13-mariadb |
| rbk12 | work/projects/rbk | work/projects/typo3/rbk | rbk12-mariadb |
| sdk13 | work/projects/sdk.neva | work/projects/typo3/sdk.neva | sdk13-mariadb, sdk13-postgres |
| tcon-relaunch | work/projects/tcon | work/projects/typo3/tcon | tcon-relaunch-mariadb |
| garant-immo | work/projects/garant/app | work/projects/typo3/garant/app | garant-immo-mariadb |
| typo3-14 | work/projects/duerr/typo3 | work/projects/typo3/duerr/typo3 | typo3-14-mariadb |
| fein13 | work/projects/fein/13 | work/projects/typo3/fein/13 | fein13-mariadb, fein13-postgres |
| feinupdate | work/projects/fein/10 | work/projects/typo3/fein/10 | feinupdate-mariadb, feinupdate-postgres |
| ssb12 | work/projects/ssb/ssb.authoring | work/projects/typo3/ssb/ssb.authoring | ssb12-mariadb, ssb12-postgres |
| ssb-waldaupark | work/projects/ssb/waldaupark | work/projects/typo3/ssb/waldaupark | ssb-waldaupark-mariadb, ssb-waldaupark-postgres |

**ssb12-Kollision — präzisiert (Audit-Einwand 1):** `ssb.authoring` UND `ssb.update` tragen beide
`name: ssb12`, aber nur `ssb.authoring` ist in `project_list.yaml` registriert; `ssb.update` hat
KEINEN Registry-Eintrag. Es gibt folglich genau EINEN ssb12-approot und EIN gemeinsames Volume-Set
(`ssb12-mariadb`/`ssb12-postgres`). Verify-Kriterium für ssb ist daher: genau ein ssb12-approot
zeigt nach dem Move auf `typo3/ssb/ssb.authoring`, `ssb12-*`-Volumes bestehen fort. Die Kollision
selbst ist vorbestehend und bleibt bestehen — sie ist NICHT Gegenstand dieser Operation.

drupal/shopware/symfony/pimcore-Cluster: KEINE DDEV-Registrierung (psh/devenv/compose).

## Absolute git hooksPath (bricht bei Move — muss umgeschrieben werden)
| projekt | .git/config hooksPath (alt) | neu (Segment eingefügt) |
|---|---|---|
| heller | .../heller/.git/hooks-local | .../typo3/heller/.git/hooks-local |
| rbk | .../rbk/.git/hooks-local | .../typo3/rbk/.git/hooks-local |
| fein/13 | .../fein/13/.git/hooks | .../typo3/fein/13/.git/hooks |
| ssb/ssb.authoring | .../ssb/ssb.authoring/.git/hooks-local | .../typo3/ssb/ssb.authoring/.git/hooks-local |
| gmp | .../gmp/.git/hooks-local | .../shopware/gmp/.git/hooks-local |

Relativer hooksPath (überlebt, kein Handlungsbedarf): mq (`./config/husky`).

## Post-Move-Verifikation je Move (Kriterien)

**Kriterium 1 KORRIGIERT (empirisch 2026-07-24 an Atom H/bachert, §9.1 Reklassifikation bei Widerspruch).**
Ursprünglich angenommen: "ein beliebiges ddev-Kommando re-registriert den neuen approot". **Widerlegt.**
Gemessenes Verhalten:
- `ddev describe` am neuen Pfad funktioniert (exit 0, korrekter name/docroot), aktualisiert die Registry aber NICHT.
- `ddev list` **prunt** einen Eintrag, dessen registrierter approot nicht mehr existiert (Eintragszahl 14 → 13).
- Re-Registrierung ist nur per `ddev start` möglich (DDEV-Meldung: "you may need to use `ddev start` to add it to the project catalog").
- Ein voller `ddev start` ist hier NICHT durchführbar/erwünscht (Router vorbestehend unhealthy, 11 Projekte, außerhalb des Auftragsumfangs).

Gültige Kriterien je DDEV-Projekt:
1. `ddev describe` aus dem NEUEN Projektpfad: exit 0 und korrekter `name`/`docroot`.
2. `docker volume ls` enthält `<name>-mariadb` (+ ggf. `<name>-postgres`) weiterhin (Daten intakt).
3. Katalogeintrag in `project_list.yaml` ist nach dem Move geprunt — das ist ERWARTET, kein Fehler.
   Er wird beim nächsten `ddev start` aus dem neuen Pfad automatisch neu angelegt; wegen name-basierter
   Volumes hängt sich das Projekt dabei wieder an seine bestehende Datenbank.
3. hooksPath-Projekte: neuer Pfad existiert + `git rev-parse --git-path hooks` bzw. Hook-Datei am neuen Ort.
4. Auto-Memory-Dir am neuen encoded-cwd vorhanden, alter weg.
5. Ordner am Zielpfad vorhanden, Quell-Pfad weg.
