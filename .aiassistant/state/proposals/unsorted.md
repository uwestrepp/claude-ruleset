- Vorschlag fürs nächste /core:rule-friction: Demotion-Review nach Meta.md §3.3 über §1–§5 fahren, bevor die nächste Always-on-Addition den Trip-Wire auslöst. Zweite Beobachtung: agnix läuft im Pre-Commit-Hook nur über plugins/ und rules/, nicht über die Memory-Verzeichnisse, obwohl CLAUDE.md Memory-Dateien als validiert benennt. Genau deshalb blieb der <function>-Error unentdeckt. Kandidat für eine Hook-Erweiterung oder eine Korrektur der Ledger-Aussage.
---
- Vorschlag fürs nächste /core:rule-friction: Meta.md §2.4 um einen Satz ergänzen, dass ein aus dem Memory referenziertes Artefakt reboot-sicher und außerhalb von /tmp liegen muss. Impact: verhindert Memories mit toten Zeigern. Risiko: eine Zeile mehr always-on in Meta.md (aktuelles Budget 4500, laut Lint noch nicht ausgereizt).
---
- Rule-set: ein Vorschlag. Problem: Testlauf 208705 lief erfolgreich durch, ohne den zu prüfenden Zweig zu erreichen (Live-Daten machten alle Properties OK); ein solcher Lauf sieht wie ein Beleg aus, ist aber keiner. General.md §5.2 fordert geeignete Prüfpfade, adressiert aber nicht die datenabhängige Erreichbarkeit. Änderung: in §5.2 ergänzen, dass ein Lauf, der den geänderten Zweig nicht durchlaufen hat, kein Beleg ist, und dass die Verzweigung im Test deterministisch erzwungen werden muss. Wirkung: verhindert Scheinbelege in verzweigtem Code. Risiko: minimal, plus rund 40 Token auf einer always-on Datei.
  -- alternative Formulierung:
  Problem: die Testauswahl nach General.md §5.2 prüfte bei zustandsbehafteter
  Logik nur Endzustände. Der Fehler saß im Übergangszustand, und ein einzelner
  Lauf konnte ihn strukturell nicht zeigen. Er ging in Produktion.
  Änderung: ergänzen, dass bei über Läufe fortgeschriebenem Zustand mindestens
  zwei aufeinanderfolgende Zyklen zu prüfen sind, plus der Übergangszustand
  zwischen den Endzuständen.
  Wirkung: fängt eine Fehlerklasse, die Momentaufnahmen nicht zeigen können.
  Risiko: §5.2 ist dicht, Meta.md §3.3 warnt vor Always-on-Zuwachs. Bessere
  Heimat wäre womöglich /core:batch §3.3.
---
- Rule-Vorschlag: General.md §5.6 um Vollständigkeitsnachweise erweitern

Problem. §5.6 adressiert heute Kommandos, deren Erfolgszweig ein Positiv-Signal unabhängig vom Ergebnis liefert, plus die Authoring-Variante über Pipe-Semantik. Nicht abgedeckt ist der Fall, dass die Ausgabe eines Filters oder einer Zählung als Nachweis für Vollständigkeit gelesen wird. Zwei Instanzen in dieser Session, beide von mir konstruiert:

- docker compose logs n8n | grep -iE "migration|error" sollte Migrationen belegen. Der Workflow-Name „KAVO Error Handler" traf den Filter zufällig, seine Aktivierungszeile landete zwischen den Migrationszeilen, und alle anderen Aktivierungszeilen fehlten. Die Trefferliste liest sich wie eine Ereignisliste, ist aber keine.
- n8n list:workflow --active=true --onlyId | wc -l ergab 16 statt 15, weil das Kommando eine Deprecation-Warnung voranstellt. Beinahe hätte ich daraus drei nicht reaktivierte Workflows diagnostiziert.

Zur Genauigkeit: meinen dritten Punkt aus dem letzten Checkpoint nehme ich zurück. Die zu grobe Trigger-Heuristik gehört unter §1.5 (Hypothese statt Ground Truth), nicht hierher. Es sind zwei Instanzen, nicht drei.

Vorgeschlagene Änderung. Ein zusätzlicher Bullet in §5.6, eingefügt nach dem Instead assert on an explicit count-Bullet und vor This applies to any evidence-bearing check:

- A filter's hit list is not an event list: when the fact is *completeness* ("every migration ran", "every workflow reactivated"), matching lines prove presence, not the absence of gaps. Assert on a count compared against an independent source, and confirm the counted lines are the only thing the command emits — a stray banner or warning line silently inflates `wc -l`, and a keyword filter collects incidental matches (a workflow named "Error Handler" lands among `grep -i error` hits).

Erwarteter Effekt. Schließt die Lücke zwischen „Existenz belegen", das die Regel heute abdeckt, und „Vollständigkeit belegen". Beide Beispiele sind wiedererkennbare Muster statt abstrakter Prinzipien, was bei dieser Regel schon beim head -1 && echo-Antipattern funktioniert hat.

Risiko und Budget. bin/lint-section-refs.sh setzt für rules/General.md 10500 Tokens; die Datei liegt bei geschätzt 10272, also 228 Tokens Reserve, rund 866 Zeichen. Der Bullet braucht etwa 460 Zeichen und damit gut die Hälfte davon. Danach ist der Spielraum für weitere Always-on-Ergänzungen praktisch aufgebraucht, die nächste Erweiterung erzwingt also eine Demotion-Review nach Meta.md §3.3. Wenn dir das zu teuer ist, wäre die schlankere Variante, nur den Halbsatz a filter's hit list is not an event list; count and compare against an independent source an den bestehenden Instead assert-Bullet anzuhängen, ohne die beiden Beispiele. Das kostet rund 100 Zeichen, verliert aber genau die Wiedererkennbarkeit, die die Regel wirksam macht.

Umsetzung, falls du zustimmst. Kein CLAUDE.md-Index-Update nötig, weil keine Rule-Datei hinzukommt oder wegfällt und die Themenliste des Eintrags unverändert bleibt. Kein exports/-Sync nötig, exports/OnlineAgent.md führt §5.6 nicht. Verifikation über bin/lint-section-refs.sh, das den Budget-Check gleich mitprüft. Commit direkt auf main nach dem für dieses Repo dokumentierten Override.
---
~/.claude/.aiassistant/state/handoffs/handoff-20260730-145859-communication-pm-detail-rule.md
---
Problem: Ich hatte Findings in ein Review-Dokument geschrieben und im Checkpoint als "persistiert" gemeldet, obwohl die daraus folgenden Handlungsschritte im operativen Dokument fehlten. Meta.md §2.2 verlangt den narrowest durable scope, sagt aber nichts darüber, dass Befund und Handlungsschritt getrennte Zielorte haben können. Proposed change: in Meta.md §2.2 einen Satz ergänzen, dass bei einem Befund mit Handlungsfolge zusätzlich das Dokument zu prüfen ist, das die Handlung auslöst (Runbook, Deploy-Plan, Checkliste), und der Checkpoint erst mit beiden Zielorten vollständig ist. Expected impact: verhindert Befunde, die dokumentiert aber operativ unwirksam sind. Risk: gering, ein Satz in einem always-on Abschnitt, Budget beachten.
---
Was ich falsch gemacht habe, für die Akte: ich habe git log main als Beleg für den Stand eines Branches genommen, auf dem ich nicht arbeite. Eine lokale Referenz ist ein zwischengespeicherter Wert, kein Branch-Zustand. Richtig ist origin/main oder vorher git fetch. Das steht jetzt als zweite Falle in der Auto-Memory git-stale-index-snapshot-trap neben dem Index-Fallstrick von vorhin, plus eine methodische Notiz im Statusdokument, damit die nächste Session nicht denselben Schluss zieht.