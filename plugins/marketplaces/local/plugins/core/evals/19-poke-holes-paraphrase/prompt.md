---
max_turns: 5
timeout_seconds: 240
allowed_tools: [Skill]
runs: 3
---
Ich habe hier ein fertiges Konzept. Wo würde das in der Praxis auseinanderfliegen?
Ich brauche keine Rückfragen und keine Gegenvorschläge.

Konzept: Wir setzen den Session-Store von Dateien auf Redis um, indem wir den
Handler in der Konfiguration umstellen, nachts um 02:00 deployen und die
bestehenden Datei-Sessions über die folgenden 24 Stunden auslaufen lassen.
