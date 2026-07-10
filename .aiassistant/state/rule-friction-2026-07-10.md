# Rule-friction audit — 2026-07-10

Source: `bin/rule-friction-report.sh` over 39 classified sessions (+5 excluded as
classifier noise). Facet data window ends **2026-06-10** — see Data-quality below.
Outcome distribution: 22 fully / 13 mostly / 3 partially achieved, 1 unclear.
Friction counts: wrong_approach 10, buggy_code 9, misunderstood_request 4,
excessive_changes 1.

## Pattern 1 — Ungrounded diagnosis / premature closure from static reading

Sessions: 9bc7b884 (rbk, 06-01, CSP-mechanism flip-flopping), 2b2f7171 (waldaupark,
06-09, premature "no ELTS config" + missed dotfile), 3547663c (sdk.neva, 06-10,
wrong deployment promotion path documented), 3a19664d (fein, 05-27, wrong
path-repo-vs-registry diagnosis), 08626643 (airbyte, 06-09, example authored
against legacy Helm chart V1 instead of current V2).

Classification: **coverage gap** (partial). General §1.4 (knowledge recency,
added 2026-06-29, i.e. AFTER all five sessions) covers the stale-knowledge
subcases (08626643, 3a19664d). The remaining mechanism — asserting a
diagnosis/mechanism claim from incremental static reading, then reversing on
more static reading instead of a ground-truth check — has no dedicated rule.
Persona names "premature closure" as stance prose; "No Capitulation" covers
reversal under social pressure, not self-reversal on static re-reads.

Proposal (V1): add General §1.5 "Diagnosis grounding" — before asserting how a
system/mechanism behaves, run the cheapest available ground-truth check
(execute, inspect runtime/installed artifact, targeted probe) or explicitly
label the claim a hypothesis; a stated conclusion MUST NOT be reversed on
further static reading alone — reversal requires ground-truth evidence.
Salience-exception-eligible per Meta §3.2 (pressure failure: premature closure).
Expected impact: targets the dominant wrong_approach/buggy_code cluster.
Risk: hypothesis-labeling ceremony in exploratory phases; scope to
materiality-relevant claims.

## Pattern 2 — Wrong comparison baseline / reference relation

Sessions: b9b8607d (fein, 06-03, diff/review against `master` instead of base
branch `release/typo3_13`; user interrupt), 98c49495 (fein, 05-11, assumed
FEINSITE-1790 was parent when it was a sibling sub-task); adjacent: 08626643
(V1-vs-V2 chart baseline).

Classification: **coverage gap**. General §2.4 lists commit-target-branch
ambiguity but not the comparison/merge baseline of a planned diff, review, or
upgrade, nor referenced ticket relations.

Proposal (V2): extend §2.4 trigger list with: "the comparison/merge baseline
for a planned diff, review, or upgrade (PR base branch, upstream artifact
version/major, referenced ticket relation) is not unambiguous from context" —
name and confirm before substantive work. Risk: one more bullet, minimal
ceremony.

## Already remediated since the data window (no action; watch next report)

- 22cf43a3 (05-21, skipped Pass-3 approval gate) → General §9.3 "resolve
  referenced normative content" (374f594, 2026-05-26).
- a796d621 (05-21, stray staged files swept into commit) → /core:commits steps
  12–14 staged-scope verify (6b155c1, 2026-06-09).
- ce981975 (06-09, skipped §10.2 effort/model gate) → SessionStart hook +
  §10.2 hard-interrupt wording (435e352, 2026-06-29).
- 84baaa41 (rule-edit draft regression; misread intentional duplication) →
  Meta §3.2 salience exception.
- Stale-knowledge subcases of Pattern 1 → General §1.4 (6451226, 2026-06-29).

Success criterion: none of these recur in facets dated after the respective fix.

## Singles — no rule change proposed

- e89e381a (porsche, 05-27, negative satisfaction): country-name request read
  as minimal Twig edit; user needed entity/migration/form-field implementation.
  Adherence failure of §5.1 intent verification / materiality-default-ask;
  single occurrence.
- 887b12e5 (command typo), 3547663c (malformed tool call): mechanical noise,
  not rule-addressable.
- 681364f6 (onboarding-guide scoping rework), 98c49495 (ADF task-list
  conversion): tool/one-off issues.

## Data quality — usage-data pipeline (tooling follow-up, not rule-set)

1. **Data is on-demand, not stalled** (verified 2026-07-10): facets,
   session-meta, and report.html are artifacts of the built-in `/insights`
   command, generated only when it is invoked — there is no background or
   scheduled pipeline, and no enable/disable setting. All files date to a
   single run on 2026-06-10 17:14–17:16 (matching
   `report-2026-06-10-171626.html`). Evidence: official docs list `/insights`
   as a built-in command without a generation daemon; CLI binary strings
   ("insights to generate a usage report", "Your shareable insights report is
   ready") confirm on-demand report generation. Refresh path: run `/insights`
   before each `/core:rule-friction` cycle.
2. **Classifier truncation**: 5 sessions excluded because the classifier hit an
   API output-token maximum (~500). Raise max_tokens or chunk transcripts.

## Status

V1 and V2 approved and applied 2026-07-10: General.md §1.5 "Diagnosis
Grounding" added, §2.4 extended with the comparison/merge-baseline trigger and
statement item; adapted sync in exports/OnlineAgent.md §1.6 "Conclusion
Grounding" (V2 has no export counterpart). Remaining follow-up: classifier
output-token truncation (5 excluded sessions); data refresh is user-driven via
/insights before each /core:rule-friction cycle.
