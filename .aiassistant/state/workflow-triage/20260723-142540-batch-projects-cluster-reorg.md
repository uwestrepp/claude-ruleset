# Triage-Packet — work/projects Tech-Cluster-Reorg (Item 7)

Erstellt: 2026-07-23 14:25:40. Workflow: `/core:batch` (Filesystem-Reorg-Spezialisierung).
Baseline: `.aiassistant/state/functional-baseline-projects-cluster-reorg.md`.
Pre-change-Baseline-Log: `ddev list` erfasst (siehe Baseline-Artefakt + Handoff-Note).

## Resolved Scope
Umzug unter `~/work/projects/` (kein einzelnes git-Repo; keine VCS-Commits durch die Moves).
- `drupal/` ← Rename von `deployer/` (base, bbs, dgnb, gelita, gleisslutz, itd, kavo, krempel, mq, vecoplan)
- `typo3/` ← bachert, heller, rbk, sdk.neva, tcon, garant, duerr, fein, ssb
- `shopware/` ← gmp, shopware6.local, vector
- `symfony/` ← gleisslutz.import, porsche
- `pimcore/` ← werit

Ausgeklammert: dgnb (top-level), mosaiq, kosmos-docker, airbyte, krannich, raabe, backup, graylog, inxmail-client, _akeneo-bundles, side-projects, symfony-online, app_dev.ini, lose Dateien.

## Atom-Definition
1 Atom = 1 Projekt-Move (bzw. für drupal: 1 atomares `mv deployer drupal`, das alle 10 Sub-Projekte mitnimmt).
Post-Steps je Atom: Auto-Memory-Dir-Rename (falls vorhanden), ggf. hooksPath-Edit, ggf. DDEV-Re-Register.

## Klassifikation (Ladder L1-L4, Counter-Check)
Ladder-Adaption für Moves: L1 = nur kosmetische/generierte/ignored Refs (kein persistenter Pfadbezug). L2 = persistente Tool-Identität am Pfad (DDEV-approot-Registrierung, absoluter git hooksPath). L3 = würde Laufzeit-State/Daten still brechen (n/a — DB-Volume ist name-basiert, überlebt). L4 = deterministisch prüfbar mit Vollabdeckung.

| # | Atom (Move) | L1 | L2 | L3 | L4 | Klasse | Counter-Check ("warum nicht 1 Stufe riskanter?") |
|---|---|---|---|---|---|---|---|
| A | `deployer/` → `drupal/` (10 Projekte, 1 mv) | ja | nein | nein | — | **safe** | Kein DDEV; alle 10 `.git/config` ohne absoluten hooksPath (mq relativ `./config/husky` → überlebt; via /usr/bin/grep inkl. .git+ignored verifiziert); deployer-Wort-Treffer = deployphp-Tool, nicht Pfad; nur ignored .idea/phpstan (self-heal). Kein persistenter Pfadbezug → echtes L1. |
| B | gmp → `shopware/gmp` | nein | **ja** | nein | provable | **provable** | Absoluter hooksPath `.../gmp/.git/hooks-local` bricht → L2. Kein L3: devenv relativ, keine DB-Identität am Pfad. Fix (Segment einfügen) deterministisch + prüfbar. |
| C | shopware6.local → `shopware/` | ja | nein | nein | — | **safe** | Kein .git, kein DDEV, keine Ref (verifiziert); devenv relativ. |
| D | vector → `shopware/` | ja | nein | nein | — | **safe** | Kein .git, compose relativ; nur ignored .idea. |
| E | gleisslutz.import → `symfony/` | ja | nein | nein | — | **safe** | hooksPath absent; compose relativ; home-Mounts move-fest. |
| F | porsche → `symfony/` (2 Sub-Checkouts) | ja | nein | nein | — | **safe** | Beide Checkouts ohne hooksPath; compose relativ; Submodul relativ; als Ganzes verschieben. |
| G | werit → `pimcore/werit` | ja | nein | nein | — | **safe** | hooksPath absent; nur home-Mount `~/.composer` (move-fest); Checkout in werit/pimcore/. |
| H | bachert → `typo3/bachert` | nein | **ja** | nein | provable | **provable** | DDEV-approot (bachert) wird stale → L2 Re-Register. Kein hooksPath, keine sonstige Ref. Re-Register + DB-Volume-Check deterministisch. |
| I | sdk.neva → `typo3/sdk.neva` | nein | **ja** | nein | provable | **provable** | Wie H (sdk13). Keine Ref. |
| J | tcon → `typo3/tcon` | nein | **ja** | nein | provable | **provable** | Wie H (tcon-relaunch). Nur generierte Treffer. |
| K | garant → `typo3/garant` (ddev in garant/app; verschachteltes git garant + garant/app) | nein | **ja** | nein | provable | **provable** | DDEV garant-immo Re-Register (L2). Kein hooksPath (beide .git ohne). docker-compose `/home/typo3/...` = Remote-Server, move-unabhängig. Ganzen garant/ verschieben. |
| L | duerr → `typo3/duerr` (ddev in duerr/typo3; kein git) | nein | **ja** | nein | provable | **provable** | DDEV typo3-14 Re-Register (L2). Kein git, keine Ref außer Doku-cd-Befehl (informativ). |
| M | heller → `typo3/heller` | nein | **ja** | nein | provable | **provable** | DDEV heller13 Re-Register + absoluter hooksPath-Edit (L2). Beide deterministisch. |
| N | rbk → `typo3/rbk` | nein | **ja** | nein | provable | **provable** | DDEV rbk12 Re-Register + absoluter hooksPath-Edit (L2). |
| O | fein → `typo3/fein` (Sub: 10, 13, +addon-only .ddev) | nein | **ja** | nein | provable | **provable** | 2 DDEV Re-Register (fein13, feinupdate) + hooksPath-Edit fein/13. Top-Level kein Repo; fein/10 kein hooksPath. Alle Fixes deterministisch, aber mehr bewegliche Teile → sorgfältiger Per-Item-Verify. |
| P | ssb → `typo3/ssb` (Sub: ssb.authoring, ssb.update, waldaupark, ssb.old, ssb.ansible) | nein | **ja** | nein | provable | **provable** | **2** DDEV Re-Register (ssb12 @ssb.authoring, ssb-waldaupark) + hooksPath-Edit ssb.authoring. Korrigiert nach Audit-Einwand 1: `ssb.update` trägt zwar `name: ssb12`, hat aber KEINEN Eintrag in `project_list.yaml` → es existiert genau ein ssb12-approot und ein gemeinsames Volume-Set. Kollision vorbestehend + out of scope, daher kein L3. |

## Klassen-Zusammenfassung (Vokabular verbatim)
- **safe** (Pass 1): A (drupal, 10 Projekte via 1 mv), C, D, E, F, G  → 6 Atome
- **provable** (Pass 2): B (gmp), H, I, J, K, L, M, N, O, P  → 10 Atome
- **manual** (Pass 3): keine

## Absolute-hooksPath-Edits (Teil der provable-Atome)
heller (M), rbk (N), fein/13 (O), ssb/ssb.authoring (P), gmp (B). Jeweils Segment einfügen; alt→neu siehe Baseline-Artefakt.

## Proof-Ledger (provable) — wird bei Apply befüllt
Volume-Schema verifiziert 2026-07-24: `<name>-mariadb` (+ ggf. `<name>-postgres`), name-basiert → move-fest.
Registry: `~/.ddev/project_list.yaml` (`name: {approot}`).

Proof-Kriterium (korrigiert, s. Baseline): `ddev describe` am neuen Pfad exit 0 + korrekter `name`; Volumes vorhanden; hooksPath zeigt auf existierendes Dir. Katalog-Prune ist erwartet.

| Atom | Move (alt→neu) | DDEV name / Volume-Check | hooksPath alt→neu | Verify-Ergebnis |
|---|---|---|---|---|
| B gmp | ~/work/projects/gmp → shopware/gmp | (kein ddev) | .../gmp/... → .../shopware/gmp/... | **PASS** — git-Checkout ok, hooksPath umgeschrieben + Dir existiert. Nebenbefund: `gmp-keycloak-1` (restart=always, vorbestehende Crash-Schleife, RestartCount 38 seit 2026-07-08 wg. fehlendem devenv-MySQL) hielt den Alt-Pfad und ließ Docker ihn als root neu anlegen → Container entfernt. Leerer root-owned Rest `~/work/projects/gmp` verbleibt (sudo nötig, s. Offene Punkte). |
| H bachert | → typo3/bachert | bachert / bachert-mariadb | — | **PASS** (describe exit 0, vols=1) |
| I sdk.neva | → typo3/sdk.neva | sdk13 / sdk13-mariadb+postgres | — | **PASS** (vols=2; stale Container entfernt, s.u.) |
| J tcon | → typo3/tcon | tcon-relaunch / tcon-relaunch-mariadb | — | **PASS** (vols=1) |
| K garant | → typo3/garant | garant-immo / garant-immo-mariadb | — | **PASS** (vols=1) |
| L duerr | → typo3/duerr | typo3-14 / typo3-14-mariadb | — | **PASS** (vols=1; stale Container entfernt) |
| M heller | → typo3/heller | heller13 / heller13-mariadb | .../heller/... → .../typo3/heller/... | **PASS** (vols=1; hooksPath ok; stale Container entfernt) |
| N rbk | → typo3/rbk | rbk12 / rbk12-mariadb | .../rbk/... → .../typo3/rbk/... | **PASS** (vols=1; hooksPath ok; stale Container entfernt) |
| O fein | → typo3/fein | fein13 + feinupdate / je -mariadb+postgres | fein/13 .../fein/13/... → .../typo3/fein/13/... | **PASS** (beide vols=2; hooksPath ok; `ddev stop fein13` VOR dem Move entfernte den laufenden chromium-Container) |
| P ssb | → typo3/ssb | ssb12 (nur @ssb.authoring registriert) + ssb-waldaupark / je -mariadb+postgres | ssb.authoring .../ssb/... → .../typo3/ssb/... | **PASS** (beide vols=2; hooksPath ok; Sperre eingehalten: kein ddev-Kommando in ssb.update) |

### Zwischenbefund bei Apply: stale DDEV-Container (§9.1 Reklassifikation)
Die zum Move `paused` Projekte (heller13, rbk12, sdk13, typo3-14, ssb12) scheiterten zunächst mit
`Failed to describe project(s): stat <ALT-PFAD>: no such file or directory`. Ursache: noch existierende
Container mit Label `com.ddev.approot` auf den Alt-Pfad; `ddev describe` löst darüber auf.
`ddev stop <name>` war nicht mehr möglich (Katalogeintrag bereits geprunt). Behebung: die 24 exited
Container dieser 5 Projekte per `docker rm` entfernt — exakt das, was `ddev stop` regulär tut.
Volume-Zahl vor/nach identisch (23/23), danach alle 5 `describe` exit 0.

### Pass-1-Ergebnis
A (drupal, 10 Sub-Projekte), C, D, E, F, G: **alle PASS** — Ziel vorhanden, Quelle weg, drupal mit 10 Sub-Projekten, Memory-Dirs umbenannt.

## Validierungstiefe je Pass
- Pass 1 (safe): Move + Memory-Dir-Rename; Verify = Zielordner da / Quelle weg / Memory-Dir umbenannt. Kosmetik (.idea/phpstan) ignoriert (self-heal).
- Pass 2 (provable): Move + hooksPath-Edit + DDEV-Re-Register; Verify je Atom = Baseline-Kriterien 1-5. DDEV-Re-Register-Mechanik am ERSTEN provable-Atom empirisch verifizieren (§1.5), dann Muster anwenden.

### Pass-2-Sperren (Audit-Einwand 2 + eigener Fund)
1. **`ssb.update` ist DDEV-Sperrzone.** `typo3/ssb/ssb.update` trägt `name: ssb12`, hat aber keinen
   Registry-Eintrag. Ein dort abgesetztes `ddev`-Kommando würde `ssb12` auf diesen approot umregistrieren,
   den Eintrag von `ssb.authoring` kapern und sich an dessen Volume-Set `ssb12-mariadb`/`ssb12-postgres`
   hängen — die latente Kollision würde durch unsere Operation aktiv. Re-Register für Atom P ausschließlich
   aus `ssb.authoring` und `waldaupark`. In `ssb.update` während der gesamten Operation KEIN `ddev`-Kommando.
2. **fein13 vor dem Move stoppen.** `ddev-fein13-chromium` lief zum Scan-Zeitpunkt (Stand 2026-07-24) mit
   Bind-Mount `fein/13/htdocs/uploads/tx_mqexportpdf`. Vor Atom O `ddev stop fein13` (bzw. Container stoppen),
   sonst bleibt ein Mount auf den alten Pfad bestehen. Alle übrigen ddev-Container im Scope sind `exited`.
   Generell vor jedem Move prüfen: `docker ps | grep ddev`.

## Reviewability / PR (§4)
N/A für die Moves selbst (kein VCS-Commit; ~/work/projects ist kein Repo). Einzige Commits am Ende im ~/.claude-Repo (Handoff-Archivierung, Memory) — klein, ein Commit.

## Manual-Topics (Pass 3)
Keine.

## Audit-Historie (§9.1.2)
- Runde 1: OBJECTIONS (1) — Atom-P-Verify wg. ssb12-Kollision nicht erfüllbar. Behoben: Registry-Ground-Truth erhoben, P auf 2 Re-Register korrigiert, Kriterium präzisiert.
- Runde 2: OBJECTIONS (2, beide dokumentarisch, keine Klassifikations-Änderung) — (1) Baseline-Kopfzeile trug noch altes Volume-Schema, (2) `ssb.update` als DDEV-Footgun nicht ausgeschlossen. Beide behoben (s.o. Pass-2-Sperren + Baseline Zeile 4). Auditor: "nach diesen zwei Doc-Fixes Phase-5-entry-fähig".
- Klassifikation über beide Runden unverändert bestätigt: 6 safe, 10 provable, 0 manual.

## Compliance-Checkliste (§9.1 Final Reporting Gate)
- `triage_packet_published`: yes (dieses Dokument, in Chat zusammengefasst)
- `triage_artifact_saved`: yes (`.aiassistant/state/workflow-triage/20260723-142540-batch-projects-cluster-reorg.md`)
- `pre_change_baseline_logged`: yes (`.aiassistant/state/functional-baseline-projects-cluster-reorg.md`)
- `approvals_recorded_for_provable_manual`: yes (User-Freigabe "weitermachen und abschließen" auf vorgelegte Klassifikation; 0 manual-Items)
- `static_rerun_green`: n/a (keine Code-Änderung; Äquivalent = Ordner-/git-/hooksPath-Verify, alle grün)
- `runtime_validation_executed`: yes (`ddev describe` 11/11 exit 0 + Volume-Check; git-Integrität 27/27; kein Voll-Boot wg. vorbestehend unhealthy Router)
- `meta_checkpoint_phase2_executed`: yes (checkpoint-Sub-Agent, Ergebnis in Audit-Historie + Memory-Persistenz)
- `meta_checkpoint_phase9_executed`: yes (siehe unten)
- `independent_triage_audit_passed`: yes (2 Runden, beide Objection-Sets behoben; Auditor: "nach diesen zwei Doc-Fixes Phase-5-entry-fähig")
- `provable_proof_ledger_complete`: yes (Ledger oben, 10/10 PASS)
- `reclassification_checkpoint_clean`: **nein — 2 dokumentierte Halts**: (1) DDEV-Re-Register-Mechanik empirisch widerlegt → Proof-Kriterium neu abgeleitet; (2) stale Container bei 5 paused-Projekten → Behebung ergänzt. Beide behoben, Klassen unverändert.

## Offene Punkte (Übergabe)
1. **Blocker (sudo):** leerer root-owned Rest `~/work/projects/gmp` (von Docker angelegt). Entfernen mit:
   `sudo rmdir -p /home/uwestrepp/work/projects/gmp/keycloak/themes/gmp` (enthält 0 Dateien, verifiziert).
2. **Inert, informativ:** 8 exited Container (`restart=no`) referenzieren noch Alt-Pfade —
   `pimcore_app`, `pimcore-pim_{supervisord,nginx,db,rabbitmq}-1`, `applications-app{,_db}-1`, `optimistic_brown`.
   Sie legen keine Alt-Pfade neu an; `docker compose up` am neuen Pfad erzeugt sie korrekt neu.
   Optional vorab entfernen: `docker rm pimcore_app pimcore-pim_supervisord-1 pimcore-pim_nginx-1 pimcore-pim_db-1 pimcore-pim_rabbitmq-1 applications-app-1 applications-app_db-1 optimistic_brown`
   DB-Daten liegen bind-gemountet IM Projektordner und sind mitgezogen (verifiziert: pimcore-mysql 189M, porsche-mysql 85M, rabbitmq 1,1M).
3. **Selbstheilend:** DDEV-Katalogeinträge sind geprunt; erster `ddev start` je Projekt registriert neu und hängt sich per name-basiertem Volume wieder an die bestehende DB.
4. **Kosmetisch:** `.idea/workspace.xml` (IDE-History, Stylelint-/Drush-Pfade) und phpstan-Caches tragen Alt-Pfade; regenerieren sich.
5. **Vorbestehend, unverändert:** DDEV-Router unhealthy; `ssb12`-Namenskollision (`ssb.update` weiterhin unregistriert — Sperre bleibt sinnvoll); gmp-Keycloak braucht den devenv-MySQL-Dienst.

## Offene Fragen / Risiken
- DDEV-Re-Register-Mechanik: `ddev` speichert approot global; ob ein `ddev` Kommando aus dem neuen Ordner den approot automatisch aktualisiert oder ob `ddev stop --unlist` + Neu-Registrierung nötig ist → am ersten Atom verifizieren, kein Voll-Boot (Router unhealthy).
- Router unhealthy = kein Voll-Funktions-Boot als Move-Kriterium; DB-Volume-Persistenz + Registrierung genügen.
