---
type: regex
target: last_message
match: not_contains
flags: m
weight: 1
---
^(feat|fix|chore|docs|refactor|perf|test|build|ci)(\([^)]*\))?!?:
