# Enforce the §9.1 activation gate mechanically, not only in prose

Date:         2026-09-03
Status:       open
Origin:       eval measurement while building the composer and typo3 suites
Revisit when: n/a (open, awaiting a decision)

## Problem

Six skills are marked "explicit activation required" in the `CLAUDE.md` ledger. Measured
2026-09-03 with the plugin eval suites, in a sandbox where only the plugin under test is
loaded and no `CLAUDE.md` is present, **four of them fire on their own topic**:
`composer:update`, `typo3:scanner`, `typo3:static-tests`, `typo3:upgrade-full`. Two restrain
(`composer:major-upgrade`, `typo3:upgrade`). Every failing case carries a NEGATIVE delta, so
on those prompts the plugin scores worse than no plugin at all.

Two facts kill the obvious explanations:

- The literal phrase predicts nothing. `composer:update` carries `explicit activation
  required` in its description and fires; `typo3:upgrade` lacks the phrase and restrains.
- It is not a language or paraphrase artefact. The prompts are the ones the descriptions
  themselves name as auto-suggest triggers.

So the whole gate currently rests on the agent reading `General.md` §9.1 plus the ledger
phrase and choosing to interrupt. Three pocock skills (`zoom-out`, `diagnose`,
`grill-with-docs`) already carry the mechanical alternative, `disable-model-invocation: true`.
The six gated skills in the local plugins do not.

## Proposed change

Add `disable-model-invocation: true` to the frontmatter of the gated skills, so the harness
refuses model invocation and the agent can only tell the user to invoke it. Cost in always-on
tokens: **zero**. The budget check measures the `description:` line, and this is a separate
frontmatter key, so unlike a description edit this repair is free on the surface that is
already at its limits.

Plus a sentence in `General.md` §9.2 requiring the flag wherever the ledger records explicit
activation, so ledger and frontmatter cannot drift apart again. That sentence has an always-on
cost and queues behind Paket 4 like the other §9 additions.

## Expected impact

The gate stops depending on the agent's compliance in the moment. It also becomes testable:
the eval suites already encode the expectation, so the flag turning four red cases green is
the verification, and a regression would show up as a red case rather than as a silently
auto-run workflow.

## Risk / tradeoff

- **Blocking constraint, and it rules out the naive version:** `typo3:upgrade-full` INVOKES
  `typo3:upgrade`, `typo3:scanner` and `typo3:static-tests` in sequence, and
  `/core:commits` auto-suggests `/core:githooks-install`. A blanket flag on the components
  would break the orchestration that is the point of `upgrade-full`. Any application has to
  decide per skill whether it is user-entered only or also a callee, and the flag as it exists
  may not distinguish those. Verify the flag's exact semantics against a real run before
  applying it to a callee.
- The flag is coarser than §9.1 asks for. §9.1 wants the agent to interrupt and prompt;
  the flag simply makes invocation impossible, which is stricter and may be worse ergonomics
  where the agent could have offered a one-key confirmation instead.
- It does not answer the prior question: whether these skills SHOULD restrain. If firing on a
  security patch or on scanner triage is desirable, the policy is the defect and this proposal
  enforces the wrong thing. That decision comes first.

## Evidence

- `plugins/marketplaces/local/plugins/composer/evals/` case 04 and
  `plugins/marketplaces/local/plugins/typo3/evals/` cases 02, 03, 04, with their READMEs.
- Commit `17ff51b`. Measured mean delta: composer +0.10, typo3 -0.30.
- The three pocock skills carrying the flag today, as the proof it works on this host:
  `git grep -l 'disable-model-invocation' plugins/marketplaces/local/plugins`.
