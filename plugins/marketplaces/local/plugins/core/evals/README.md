# core plugin eval suite

Executable test for skill *activation*. A skill description IS its own activation
trigger, so re-reading the text is not a check; this suite runs real prompts and
asserts which skill fired.

## Run

    cd <this plugin's root>
    claude plugin eval . --ablation with-without --no-publish

`--no-publish` is required for a local-only run: the harness publishes its HTML
report to claude.ai by default. Add `--runs 1` for a cheap pilot (a full 3-run
suite over four cases costs roughly $1.60). Add `--keep-temp` to preserve each
run's sandbox and `out/trace.jsonl` when a grader verdict needs diagnosing; the
kept directory is mode 000 sealed and needs `chmod 700` to inspect.

The command is early-access gated. Enablement is `CLAUDE_CODE_WALNUT_SPIRE=1`,
set machine-locally in the gitignored `~/.claude/settings.json` under `env`. A
per-organization rollout would lift it too, but has not reached this host.

## Case anatomy

One directory per case: `prompt.md` (frontmatter `max_turns`, `timeout_seconds`,
`allowed_tools`, `model`, `runs`; body is the prompt) plus `graders/<name>.md`
(frontmatter `type:` selects `regex` | `tool_used` | `tool_order` |
`file_exists` | `llm` | `baseline`).

Activation is asserted with a `tool_used` grader on `tool: Skill` and an
`input_match` regex naming the skill. **`arm: both` is load-bearing**: omit it
and the grader becomes a display-only indicator that never moves the ablation
delta, because the harness assumes activation is a trajectory rather than the
thing under test. Here it IS the thing under test.

## Floor invariants (from the harness's own authoring contract)

- at least one should-NOT-fire case stays in the suite (over-trigger detection),
- every case carries at least one outcome grader, never only `tool_used`,
- `runs: 3` minimum in the case files, `--ablation with-without` on real runs.

A grader that implies a side effect only passes if the case grants the tool that
produces it. Cases run in a sandbox cwd with no repository, so a prompt must
either supply everything the skill needs or expect the agent to ask, which
scores as a miss.

## Asserting that the WRONG skill stayed quiet

A `tool_used` grader with `input_match` naming one skill plus `min: 0`, `max: 0`,
`arm: both` asserts that *that specific* skill did not fire, while leaving other
activations untouched. This is how the grill-me / poke-holes / brainstorm cases
test three-way disambiguation: each names its expected skill positively and the
two confusable siblings negatively. A bare `tool_used` on `tool: Skill` with
`min: 0, max: 0` and no `input_match` is the stronger claim that NO skill fired
at all, which is what an over-trigger case wants.

## What this suite cannot test

Cases run in a sandbox that loads the plugin under test and nothing else: no
`CLAUDE.md`, no `rules/`, no `CLAUDE.local.md`. So the suite measures
description-driven auto-activation only. In particular the `General.md` 9.1
skill-invocation gate is out of reach: "explicit activation required" is
enforced by the ledger phrase plus agent behavior, and only three pocock skills
(`zoom-out`, `diagnose`, `grill-with-docs`) additionally carry
`disable-model-invocation: true`. For every other gated skill a case can ask
whether its *description* is self-restraining, which is a weaker and different
claim than whether the gate holds in a real session.

## Worked example: what this suite is for

The suite has already found and closed one real defect, and the sequence is the argument for
keeping it.

**Found.** `17-brainstorm-indirect` asks for the range of options in German without using the
word "brainstorm". The skill did not fire. Repetition would never have found this: the
existing `brainstorm` case passed three times in a row. Only a second input SHAPE reached it.

**Bounded.** Two probes isolated the boundary before any repair, because the first hypothesis
(missing German triggers) was wrong: `commits` fires on "einchecken"/"Betreff" and
`git-knowledge` on German recovery questions, none of which match their trigger lists
lexically. Measured instead:

| Skill | moderate paraphrase | hard paraphrase |
|---|---|---|
| `grill-me` | fires (06) | fires (20) |
| `poke-holes` | fires (05) | did NOT fire (19) |
| `brainstorm` | did NOT fire (17) | did NOT fire |

So it was a gradient, not a binary: every skill has a paraphrase margin and the margins
differ. `brainstorm` had the narrowest, `grill-me` the widest.

**Repaired.** Both descriptions gained semantic trigger variants including German ones, but
the load-bearing part was sharpening the line against their own negative clause: a request
for the RANGE of options counts even as a question and without the keyword, and asking where
a supplied artifact breaks IS `poke-holes` however phrased. Cost about 112 estimated tokens
against the skill-description surface, which the budget check accepted.

**Verified, including the regression risk.** Widening a trigger can cause over-triggering, so
the check was the whole suite rather than the two repaired cases: 20 cases, no negative
assertion broke, `04` and `09` unchanged at delta 0.00, and the sibling negatives inside 05,
06, 07 and 16 all held. Case 17 was then confirmed at `runs: 3` with the with-arm at 1.00 on
every run.

**What stayed a hypothesis.** Why the margins differ. The activation decision is not
observable in the trace, only inputs and outcomes are, so the repair is evidence that wider
wording widens the margin and NOT evidence about the mechanism. `18-brainstorm-literal-control`
exists to keep 17 interpretable: same skill, same question form, a literal trigger phrase.
Without it a red 17 could equally have meant the skill was broken.

`results/` is gitignored: run artifacts are transient per `Meta.md` 2.4.
