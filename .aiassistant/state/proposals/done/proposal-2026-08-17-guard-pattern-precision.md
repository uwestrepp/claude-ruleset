# Extend General.md §5.6 authoring clause to pattern precision in guards

```
Date:         2026-08-17
Status:       superseded
Superseded by: .aiassistant/state/proposals/proposal-2026-08-31-verification-reach-consolidation.md
Origin:       session observation — third false-positive fix in the same guard file
Revisit when: a fourth pattern-precision false positive lands in any authored gate,
              or the next /core:rule-friction cycle, whichever comes first
```

## Problem

`General.md` §5.6 has an authoring clause, but it covers exactly one failure mode:
exit-status masking in pipelines (`set -o pipefail`, fail-open vs fail-closed). It says
nothing about the *precision* of the patterns a guard matches on, which is what has
actually gone wrong three times in `hooks/guard-destructive-commands.sh`:

1. `97632d0` — the §5.6 guard itself matched too broadly and had to be split by clause.
2. `1cbec67` — `HAS_RECURSIVE` (`-[a-zA-Z]*[rR]`) ran as a substring scan over the whole
   rm segment, so the scratchpad path `…/-home-uwestrepp-work-projects-gmp/…` supplied a
   phantom `-r` via the `r` in `-uwestrepp`. Every plain `rm -f` under a session
   scratchpad was classified recursive-force.
3. `77efd12` — the same class in `git push` / `git clean` / `chmod|chown|chgrp`: flags
   were harvested from anywhere on the command line, so
   `git clean --dry-run; tar -xzf a.tgz` reported "git clean -f deletes untracked files".

Each shipped as a working guard and each produced pure false positives. False positives
are the specific way a guard dies: it gets reflex-approved, then disabled, then catches
nothing. The header of the guard file already names alarm fatigue as its primary design
risk, and the implementation defeated its own design three times.

## Proposed change

Add one sentence to the `General.md` §5.6 authoring clause:

> When an authored gate matches on command *structure* (flags, verbs, paths), the match
> MUST be anchored to the structural unit it claims to describe — a flag to its own
> command's option tokens, a verb to a command position — never a substring scan of the
> whole command line. A pattern that a neighbouring token or an unrelated chained command
> can satisfy is a false-positive generator, and a guard that cries wolf gets disabled.

## Expected impact

Turns three repeat incidents into a stated constraint at authoring time. The concrete
target is any future hook, CI step, or guard script in this rule-set: `hooks/` currently
holds seven of them, and `guard-pipefail-gates.sh` plus `warn-evidence-pipelines.sh`
already lint for the *other* §5.6 failure mode, so this closes the sibling gap.

## Risk / tradeoff

- Always-on token cost: `General.md` is `[CRITICAL]`, so this is roughly 60 always-on
  tokens on every session, against `Meta.md` §3.3's budget. That is the main argument
  against.
- Cheaper alternative worth weighing first: this is arguably shell-craft, not agent
  behaviour, and could live in a path-gated rule or in the guard file's own header
  instead. The counter-argument is that §5.6 already accepted one shell-craft clause on
  exactly the same grounds, and the incident count here is higher.
- Risk of overcorrection: an anchored matcher is more code than a substring grep, and
  more code in a guard is more places to be wrong. The rm/git rework needed two shared
  helpers to stay readable.

## Evidence

- `hooks/guard-destructive-commands.sh`, commits `97632d0`, `1cbec67`, `77efd12`
  (2026-08-17 for the latter two).
- Reproduction for incident 2, identical commands differing only in the path segment:
  `rm -f /tmp/claude-1000/-home-uwestrepp-x/y.txt; echo done` → ask, versus
  `rm -f /tmp/claude-1000/abc-x/y.txt; echo done` → allow.
- Regression coverage now at `hooks/tests/guard-destructive-commands.test.sh`, 62 cases.
