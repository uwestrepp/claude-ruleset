# Enforce General.md §8.5 mechanically for added Markdown lines and commit bodies

```
Date:         2026-08-17
Status:       superseded
Superseded by: .aiassistant/state/proposals/proposal-2026-08-31-verification-reach-consolidation.md
Origin:       session observation — three §8.5 violations in one session, each caught
              only by a self-initiated grep, none by a gate
Revisit when: a fourth em-dash violation reaches a commit, or the next
              /core:rule-friction cycle, whichever comes first
```

## Problem

§8.5 forbids the em-dash in all agent-authored prose, explicitly including in-repo
docs and commit messages. It is enforced by attention alone, and attention failed
three times in a single session:

1. 26 added lines across 6 files (two READMEs, two dbt YAMLs, two handoffs) plus 2
   commit bodies. Found only because the agent grepped its own diff before pushing.
2. After that fix, 1 more line in a handoff written minutes later.
3. After that fix, 1 more in a README heading the agent had just edited.

The failure mode is specific and repeatable: the pre-existing files use em-dashes
throughout, so matching the surrounding style overrides the rule. That is the exact
pressure §8.5 exists against, and it recurs on every doc edit in a legacy file.

## Proposed change

Extend the existing `hooks/validate-commit-message.sh` (already a `PreToolUse` gate
on `git commit`, already scoped to `~/work`):

1. Reject a commit whose subject or body contains U+2014.
2. Reject a commit whose staged diff adds a U+2014 in a text file, evaluated on
   added lines only (`git diff --cached -U0`), so pre-existing prose is untouched.

Scope carve-outs the check MUST honor, mirroring §8.5:

- `~/.claude` itself is out of scope. The whole repo is agent-facing instruction
  material, where §8.5 does not apply. The hook is already `~/work`-only, so this
  is free.
- Skip fenced code blocks and indented code in Markdown, plus `*.sql`, `*.tf` and
  other source files: code and identifiers are out of scope.
- Provide a documented bypass for quoted external text, the one legitimate
  in-prose case.

Fail-closed vs fail-open must be an explicit decision per §5.6 authoring clause.
Recommendation: fail-closed on the commit message (cheap, unambiguous), warn-only
on the diff until the fence-skipping has run a few weeks without a false positive.

## Expected impact

Removes the most frequent single rule violation from the attention budget. It is a
pure win in the §3.3 sense: enforcement moves from always-on rule text to a
mechanical gate, which is the direction that section asks for.

## Risk / tradeoff

- False positives in Markdown code samples if fence detection is wrong. This is why
  the diff arm starts warn-only. `hooks/guard-pipefail-gates.sh` and the §5.6 guard
  both needed several precision fixes for exactly this reason, see
  `proposal-2026-08-17-guard-pattern-precision.md`.
- No always-on token cost: the rule text stays as it is, only the enforcement layer
  is added.
- Adds one more check to every commit in `~/work`. The subject arm is a single
  string test; the diff arm costs one `git diff --cached`.

## Evidence

- 2026-08-17, `~/work/projects/airbyte`, MQDEV-191 session. First batch fixed by
  rewriting the three commits before push (`1ae747e`, `3fe86dd`, `62f4db7` are the
  corrected ones). Second and third instance fixed in place before their commits.
- The corrective script the agent had to write ad hoc lives in the session
  scratchpad; it replaced `\s*—\s*` with a spaced plain hyphen on added lines only.
  That logic is a usable starting point for the hook.
