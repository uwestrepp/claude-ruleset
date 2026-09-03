---
max_turns: 6
timeout_seconds: 180
allowed_tools: [Skill]
runs: 3
---
Ich bin mit dem Fix durch und will die Änderung einchecken. Wie soll der Betreff
lauten? Das Repository liegt hier nicht vor, arbeite mit der Beschreibung und
frag nicht nach.

Ticket: SHOP-882

Geändert: in `src/Storefront/Controller/CheckoutController.php` wurde eine
Division durch null abgefangen, wenn der Warenkorb leer ist.
