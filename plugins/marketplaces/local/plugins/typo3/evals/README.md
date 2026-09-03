# typo3 plugin eval suite

Method, grader anatomy, run flags and the reach limits are documented once in
`../../core/evals/README.md`. Read that first; this file records only what is specific to
this plugin.

## Run

    cd <this plugin's root>
    claude plugin eval . --ablation with-without --no-publish

## What this suite tests

All four skills require explicit activation per the `CLAUDE.md` skill ledger, so there is no
positive activation case to write: the tested property throughout is RESTRAINT. Cases 01 to
04 assert that the skill did not fire while the answer still addressed the question, and 05
guards against any skill firing on a plain TypoScript question.

Note the asymmetry with the composer plugin: none of these four descriptions contains the
literal phrase `explicit activation required`. The activation policy lives only in the
ledger, and the sandbox loads no `CLAUDE.md`. That makes this suite a test of whether the
descriptions restrain themselves on their own, which is a weaker claim than whether the
`General.md` 9.1 gate holds in a real session.

## Open findings: three of five are red

| Case | Skill | Fired | Delta |
|---|---|---|---|
| 01 | `upgrade` | no | 0.00 |
| 02 | `scanner` | **yes** | -0.50 |
| 03 | `static-tests` | **yes** | -0.50 |
| 04 | `upgrade-full` | **yes** | -0.50 |
| 05 | (any) | no | 0.00 |

So the plugin is net negative on these five prompts. Two facts constrain any explanation:
`upgrade` restrains WITHOUT carrying the gating phrase, while `composer:update` fires WITH
it. The phrase therefore predicts nothing on its own, and restraint behaves like a margin
that differs per skill, the same shape as the paraphrase margin documented in the core
README.

One correction worth keeping: case 04 first measured -1.00 because its `max_turns` was set
to 6, too tight for a skill that orchestrates three others. With a realistic budget the
outcome grader passes and only the activation assertion fails. The inflated figure was a
defect in the case, not in the plugin.

Whether the defect is the behaviour or the policy is undecided. If these skills should fire
on their topic, the ledger's "explicit activation required" is what needs revisiting.
