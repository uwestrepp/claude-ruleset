---
type: regex
target: last_message
match: contains
flags: m
weight: 1
---
^\s*(?:[-*>]\s*)?(?:#{1,4}\s*)?(?:\*\*)?(?:Ansatz\s*|Weg\s*|Option\s*)?3[.):]
