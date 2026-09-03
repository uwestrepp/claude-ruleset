---
max_turns: 6
timeout_seconds: 240
allowed_tools: [Skill]
runs: 3
---
Hier ist mein fertiger Plan. Sag mir, was daran kaputt ist, nach Schwere
sortiert. Stell mir keine Rückfragen und schlag keine Alternativen vor, ich will
nur die Schwachstellen.

Plan: Wir cachen die Produktpreise in Redis mit TTL 24 h. Ein Cronjob wärmt den
Cache nachts um 03:00 vor, indem er alle 80.000 Produkte durchläuft. Preis-
änderungen aus dem ERP kommen per Webhook und löschen den betroffenen Key. Wenn
Redis nicht erreichbar ist, liefert die Anwendung den Preis 0,00 aus, damit die
Seite nicht bricht.
