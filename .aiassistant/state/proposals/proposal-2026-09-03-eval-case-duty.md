# Skill-description changes should carry an eval case

Date:         2026-09-03
Status:       open
Origin:       session observation while closing carried open item 11 of the consolidation record
Revisit when: n/a (open, awaiting a decision)

## Problem

A skill description IS its own activation trigger, and until 2026-09-03 there was no
executable check on it. Paket 5 rewrote nineteen `SKILL.md` descriptions across three
plugins (commits `d1f3fed` … `f87be0a`) with no behavioural validation: `General.md` §5.2
asks for one, and for a description the only available "test" was re-reading the text. The
mitigation used was one commit per description so a `git revert` could repair a regression,
which limits blast radius and proves nothing.

That gap is now closable. `claude plugin eval` runs real prompts and scores which skill
fired, and a nine-case suite exists at `plugins/marketplaces/local/plugins/core/evals/`.
Nothing in the rule-set points at it, so the next description change will again ship
unvalidated by default.

## Proposed change

One SHOULD-level sentence: a new or materially changed skill description SHOULD gain or
update a case in its plugin's `evals/` directory in the same change-set, and the suite
SHOULD be run for the affected case before the change is considered complete.

Two candidate targets, and the choice is the open question:

- `General.md` §9.2 (Skill ledger maintenance) is the topically correct home: it already
  governs what must happen when a skill is created. **Blocked** — that file sits at reserve
  16 estimated tokens and the addition costs far more, so it queues behind Paket 4 with
  carried items 4 and 12.
- the `CLAUDE.md` skill-ledger preamble is affordable today at reserve 115 and is where a
  reader already looks for ledger duties, but it is the weaker location: it reads as an index
  entry rather than a normative rule, and §9.2 would then be the rule that does not mention
  its own test.

## Expected impact

Description changes become falsifiable instead of reviewed-by-reading. The measured runs
show the mechanism has real discriminating power: the three-way `grill-me` / `poke-holes` /
`brainstorm` guard was confirmed to bind, and a suspected over-trigger in the `commits`
description was disproved rather than argued about.

## Risk / tradeoff

- Always-on token cost at the chosen target, and `rules/General.md` cannot pay today.
- A real per-change money cost: roughly $0.19 per case per with/without run-pair, so a
  single-case re-run is cents and a full suite at `runs: 3` is dollars. A SHOULD that is
  routinely skipped for cost is worse than no rule, so the wording must scope the duty to
  the affected case rather than the whole suite.
- Coverage is uneven and the duty would expose that: the `composer` and `typo3` plugins have
  no suite at all, so the first change to one of their descriptions pays the setup cost.
- The duty cannot cover what the mechanism cannot reach. Cases run in a sandbox that loads
  only the plugin under test, so `General.md` §9.1's invocation gate is untestable by
  construction; only three pocock skills additionally carry `disable-model-invocation: true`.
  A rule that implied otherwise would be a false assurance.

## Evidence

- Paket 5's nineteen changed `SKILL.md` files: `git diff d1f3fed~1..f87be0a --name-only`.
- Carried open item 11 of `proposal-2026-08-31-verification-reach-consolidation.md`, which
  names this the single highest-value addition to the rule-set's own tooling and is closed
  by the same session that filed this proposal.
- Suite and measurements: commits `d949a86`, `5d059f1`, `7b88f59`; run figures in item 11.
