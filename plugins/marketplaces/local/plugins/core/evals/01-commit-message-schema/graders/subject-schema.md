---
type: regex
target: last_message
match: contains
flags: m
weight: 0.5
---
^\s*\[(FEAT|FIX|BUILD|CHORE|CI|DOCS|STYLE|REFACTOR|PERF|TEST)\] [A-Z][A-Z0-9]+-[0-9]+ \([A-Za-z0-9._/-]+\) .+
