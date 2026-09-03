# composer plugin eval suite

Method, grader anatomy, run flags and the reach limits are documented once in
`../../core/evals/README.md`. Read that first; this file records only what is specific to
this plugin.

## Run

    cd <this plugin's root>
    claude plugin eval . --ablation with-without --no-publish

## What this suite tests

Only one of the three skills is auto-activating. `composer:knowledge` is tested positively
(cases 01, 02, the second a German paraphrase that avoids the trigger list's vocabulary).
`composer:update` and `composer:major-upgrade` both declare `explicit activation required`
in their own descriptions, so for them the tested property is RESTRAINT: cases 03 and 04
assert the skill did not fire while the answer still addressed the question.

Restraint is testable here only as a property of the description. The `General.md` 9.1
invocation gate is out of reach in the sandbox, which loads no `CLAUDE.md`.

## Open finding: 04 is red

`composer:update` fires on "roll out a security patch in a heavily customized project",
which is almost verbatim one of the auto-suggest triggers its own description names right
next to "do not auto-run". Delta is NEGATIVE (-0.50): on this prompt the plugin scores worse
than no plugin.

`composer:major-upgrade`, whose description carries the same gating phrase in the same
position, restrains itself (case 03). So the phrase's presence does not predict restraint,
and the standing hypothesis is that a closer lexical match between prompt and trigger list
overpowers the gating clause. Not verified: the activation decision is not observable.

Whether the defect is the behaviour or the policy is undecided. Firing on a security patch
may well be what one wants, in which case the description's gate is the thing to change.
