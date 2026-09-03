---
max_turns: 6
timeout_seconds: 240
allowed_tools: [Skill]
runs: 3
---
Schätz mir den Aufwand für folgendes Ticket. Das Repository liegt hier nicht vor,
arbeite also allein mit der Beschreibung und frag nicht nach.

Ein Shopware-6-Plugin rendert Produktbilder ohne responsive Varianten. Zu tun:
Storefront-Template auf `sw_thumbnails` umstellen, die Thumbnail-Größen in der
Plugin-Konfiguration ergänzen, danach die ausgelieferten Bildgrößen im Browser
nachmessen. Danach geht es in Review und aufs Kundenfreigabe-Deployment.
