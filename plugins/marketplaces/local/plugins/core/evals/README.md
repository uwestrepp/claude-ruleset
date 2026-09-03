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

## One case is deliberately red

`17-brainstorm-indirect` records an open defect and FAILS. The suite therefore exits
non-zero under the default `--threshold 1.0`, and that is intentional: the case is the
finding, not a broken test. Do not "fix" it by loosening its graders.

Measured 2026-09-03, four data points:

| Case | Language | Form | Literal trigger token | `brainstorm` |
|---|---|---|---|---|
| 07 | German | imperative | yes ("Brainstorm") | fires |
| 17 | German | question | no | **0x** |
| (probe, removed) | German | imperative | no | **0x** |
| 18 | English | question | yes ("what are different angles for") | fires |

`18-brainstorm-literal-control` exists only to keep 17 interpretable: same skill, same
question form, a literal trigger phrase, and it fires. Without that control a red 17 could
equally mean the skill is broken.

What the data supports: `brainstorm` needs a literal trigger token, and a semantically
equivalent request does not reach it. This is skill-specific rather than a general property
of the harness or of German prompts: `commits` fires on "einchecken"/"Betreff" (case 10) and
`git-knowledge` on German recovery and deploy questions (cases 03, 14), none of which match
their trigger lists lexically.

What the data does NOT support: a cause. The activation decision is not observable in the
trace, only inputs and outcomes are. The standing hypothesis is the combination of
`Use when the user explicitly asks` with the sharp `DOES NOT trigger on generic 'how do I
solve X'` clause in that one description. Testing it means editing the description and
re-measuring, which is a rule-set change and needs a decision.

`results/` is gitignored: run artifacts are transient per `Meta.md` 2.4.
