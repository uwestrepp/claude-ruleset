# Rule-Set Critical Review, 2026-07-13

Method: hybrid adversarial review (poke-holes style, four parallel lenses: V1+V2
correctness/safety, V3+V4 durability/governance, V5 efficiency quantitative,
index/ledger consistency), findings verified by the main agent against the rule
texts, then Meta.md §3.1 proposals for survivors. Scope per user selection:
`rules/` + `CLAUDE.md` index, always-on token analysis, skill ledger/descriptions.
Materiality floor: only Blocking and Material findings. Salience exception
(Meta §3.2) respected throughout: pressure-failure rules were exempt from
brevity/dedup criticism.

Verification legend: CONFIRMED = re-checked against rule text in main-agent
context or reproduced evidence (quote/grep/frontmatter). PLAUSIBLE = single-lens
evidence, not independently re-checked.

## Verdict (summary)

The set is **effective at evidence-driven addition** (§1.5 and §5.6 demonstrably
trace to logged incidents) and **structurally sound in its cross-references**
(10/10 semantic ref spot-checks accurate, ledger complete for all 22 skills).
Its two systemic weaknesses: the governance loop **cannot validate or remove**
what it adds (add-only ratchet, pruned evidence base), and the always-on load
(~20.2k tokens/session) carries ~20% content that the set's own authoring policy
says belongs elsewhere. Plus four hard rule conflicts that force silent
rule-dropping in realistic scenarios.

## A. Blocking findings

### A1. §10.2 hard-stop deadlocks confirmed-autonomous runs — CONFIRMED
General.md §10.2 mandates a HARD STOP ("end its turn with the question",
"NO substantive work") whenever the escalation test passes, including topic
boundaries; branch (b) of the test (distinguishable next step + feasible
handover) plausibly passes at every phase boundary of a batch cycle. /core:batch
autonomous mode runs unattended by design. No carve-out exists in either text.
Failure: unattended run halts mid-cycle on a question nobody answers.

### A2. §12 branch protection is dead-lettered by the rule-set's own repo — CONFIRMED
§12: protected set incl. `main`, "reach these via PR only", "stop and ask" absent
an override. Every rule-maintenance commit in `~/.claude` lands directly on
`main`; this very session committed to `main` citing "repo practice" without a
recorded override. Habitual silent override of V2's strongest gate normalizes
the bypass pattern for client repos.

### A3. Friction loop can add rules but cannot validate them — CONFIRMED
V4 claims evidence-driven improvement, but: facets rolling-prune (~20 days), no
aggregate baseline is archived, per-theme n is 2-8 in ~48 sessions with shifting
workload mix, and Skill-tool calls are invisible to facets. Testing whether
§1.5 works requires a prior-window comparison whose raw data no longer exists.
The loop will produce confident but unfalsifiable effectiveness claims either
way. Actual mechanism today: evidence-driven addition + anecdote-driven retention.

### A4. The set is structurally add-only; no operative removal path — CONFIRMED
Meta §3 details proposal/addition; removal appears once as a passing noun with
no trigger, owner, or cadence. The only removal channel (rule-friction "rule
friction → removal candidate") requires a rule to cause *logged user friction*,
which dead-weight always-on rules never do. §3.2's salience exception exempts a
growing category from lean passes. Git history: additions only. At the observed
rate (~2 substantive always-on additions/month), the [CRITICAL] files grow
~25-50%/year; every added always-on token dilutes attention on every other rule,
degrading V1-V4 via V5 without any facet flagging it.

## B. Material findings

### B1. Rule conflicts / deadlocks
- **CLAUDE.md live-page MUST vs §10.5 offer-first** — CONFIRMED, downgraded from
  Blocking: not a hard deadlock (one governs *whether/how to route*, the other
  *page type when creating*), but the §10.5 paste-path produces a page the user
  creates manually, which cannot become a live page (no conversion via MCP), so
  following §10.5 silently defeats the live-page MUST. Precedence unstated.
- **Meta §2.2 "MUST ask" vs §2.3 "SHOULD persist speculatively"** on the same
  state (unclear storage target) — CONFIRMED. Also: global `CLAUDE.md` (where
  the repo's own MCP conventions actually live) is missing from §2.2's layer
  list entirely; the same finding class defensibly routes to 4 targets.
- **CleanCode absolute MUSTs (CQS, no flag args) vs §3.1/§3.3 pattern-respect**,
  no precedence rule; PER.md's own fluent-chaining example violates CQS —
  PLAUSIBLE. Generating into a fluent-API legacy codebase forces a rule breach
  either way.

### B2. Coverage gaps (incidents mislabeled "adherence failure" in RULESET-OVERVIEW §6.4)
- **Push remote/upstream is unverified by any rule** — CONFIRMED: §2.4
  disambiguates branch but not remote; commits skill checks staged scope, not
  push target; pre-push hook validates subjects only. The wrong-upstream
  incident was a coverage gap, not adherence.
- **No rule binds checks to push time** — CONFIRMED: §5.2 binds to
  change-time; changes validated mid-session can be pushed hours later past a
  red project lint gate without violating anything.
- **§1.5 overfits to the "diagnosis" claim shape** — CONFIRMED: assumed-state
  claims ("the migration already ran", "env var is set") fall outside its
  root-cause/mechanism/config/resolution definition; the friction theme was
  "ungrounded diagnosis / assumed state".
- **§1.5's hypothesis label gates wording, not action** — CONFIRMED: labeling a
  claim a hypothesis then editing based on it is fully compliant; the logged
  wrecks were wrong *actions*.
- **§3.4/§1.4 rely on the impaired party detecting its own impairment** —
  CONFIRMED; no mechanical trigger forces the [CRITICAL] re-read absent a
  harness signal (SessionStart hook exists; PreCompact does not).
- **Ad-hoc handovers still route to lossy locations** — CONFIRMED: §10.3 names
  no durable target for non-batch continuation docs ("a doc-file or an inline
  brain-dump"); the harness scratchpad directive actively routes temp files to
  `/tmp` (reboot-lossy). The /tmp incident fix landed only in pocock:handoff.

### B3. Enforcement-layer mismatch
- **Mechanically detectable failure modes fenced with prose while owned infra
  idles** — CONFIRMED: §5.6 pipeline shapes are regex-detectable; the set owns
  hookify, `~/.claude/hooks/` (already intercepts commits), and the githooks
  template; RULESET-OVERVIEW §6.4 itself flags "candidate for githooks
  enforcement", unimplemented. Prose fences depend on exactly the fallible
  attention V1 distrusts.
- **§4.5 MUSTs unsatisfiable outside batch context** — CONFIRMED: mandates
  recording into a triage packet that only exists in batch workflows; the
  payload-replay clause has no infeasibility fallback (unlike §5.2). Habitual
  silent skipping erodes the highest-risk V2 rule.
- **§4.6 legacy gate has no operational trigger** — CONFIRMED: nothing states
  whether a direct user change-task constitutes the required confirmation; read
  literally it doubles every interaction, read loosely it never binds.

### B4. Governance mechanics
- **"Major milestone" undefined for ad-hoc work; §1.1 adherence invisible to
  the friction loop** — CONFIRMED: outside workflow skills no definition exists;
  a skipped checkpoint produces no facet, so the loop cannot police its own
  trigger.
- **Checkpoint delegation hands knowledge-persistence review to a context-blind
  sub-agent** — CONFIRMED: the checkpoint's V3 job is catching *unbriefed*
  session knowledge, precisely what a fresh sub-agent cannot see; whatever the
  main agent forgot to brief cannot be surfaced. Worst in long/compacted
  sessions where §2.3 says risk peaks.
- **Handover governance split across three mechanisms with contradictory
  storage mandates** — CONFIRMED: batch §11.1 (scratch, MUST NOT commit,
  overwrite in place) vs pocock:handoff (state/handoffs, committed, never
  overwrite) vs §10.3 (format/location unspecified); CLAUDE.md ledger says
  pocock:handoff auto-activates, so it can fire mid-batch-cycle and violate
  batch's own mandate.

### B5. Efficiency (V5) — always-on load ~20.2k tokens/session
Quantification (chars/3.8): General.md ~9.2k tokens (46%), skill descriptions
~3.5k (18%, 22 skills, top 6 = 53% of description load), Meta.md ~3.5k,
CLAUDE.md ~2.4k, Persona.md ~0.7k, MEMORY.md ~0.5k, CLAUDE.local.md ~0.35k.
Path-gated files healthy (~5k total, correctly gated).
- **F1 Skill descriptions carry workflow content past the trigger surface** —
  CONFIRMED: poke-holes/grill-me/major-upgrade embed tier models and phase
  pipelines; trigger matching needs invocation form + triggers + NOT-clauses
  (~350-450 chars). Saving ~1,800 tokens/session. Disambiguation NOT-clauses
  must survive the trim.
- **F2 Workflow-scoped content in always-on rules** — PARTIALLY CONFIRMED:
  §4.5's batch-phase machinery and §12's release-branch/deploy mechanics are
  movable with §9.3 references (~800-1,300 tokens). REFUTED for §10.5's offer
  list: it is a behavioral MUST that must bind without any skill active;
  moving it would disable the gate.
- **F3 CLAUDE.md ledger duplicates the always-loaded descriptions** —
  CONFIRMED: ~650 tokens; the literal "explicit activation required" phrases
  and one-line boundaries must survive (§9.1 keys on them).
- **F4 Persona.md ~half procedural restatement** — CONFIRMED with guard: the
  anti-capitulation/premature-closure/recency half is salience-protected and
  stays; the 1:1 procedural mappings to §2.x/§4.x/§5.2 (~400 tokens) are not.
- **F5 Non-salience duplication pairs** (brevity stated 3x; Meta §1.1 restates
  §2.3; §1.4 re-derives §2.1/§2.2) — CONFIRMED, ~500 tokens.
Realistic top-3 total: ~3,750 tokens/session (~19% of always-on); with F4/F5
~4,650 (~23%).

### B6. Index/ledger consistency
- **pocock:zoom-out**: frontmatter `disable-model-invocation: true` but ledger
  lists it as auto-activate; §9.1 phrase missing → skill silently unreachable
  except by typed command — CONFIRMED (downgraded from Blocking: small blast
  radius, real mechanism failure).
- **githooks-install three-way policy conflict** — CONFIRMED: ledger = auto,
  RULESET-OVERVIEW §3/§4 = explicit, frontmatter = auto. The overview (written
  2026-07-13) is the wrong side and needs correction.
- **RULESET-OVERVIEW §4 activation column drift** — CONFIRMED: handoff and
  caveman marked "explicit" but are auto per frontmatter/ledger; §3's explicit
  bucket omits the composer skills' hybrid status.
- **lint-section-refs.sh does not lint `/composer:*`/`/pocock:*` section refs**
  — CONFIRMED via regex + live unlinted refs (major-upgrade SKILL.md:86-307,
  TYPO3.md:146,150). Future renumbering drifts silently. All current refs
  spot-checked accurate.
- **Stale "built-in diagnose" rationale** — CONFIRMED against current skill
  list (no built-in diagnose exists): the stated reason for gating
  pocock:diagnose no longer holds; disciplined-debugging prompts trigger nothing.
- **brainstorm vs pocock:design-an-interface/prototype trigger collision**, no
  stated disambiguation — PLAUSIBLE; "explore design alternatives for X's API"
  matches all three, outcomes differ materially in cost.

## C. Proposals (Meta.md §3.1 format)

**P1 — Autonomous/trivial carve-outs for §10.2** (from A1, B: over-broad task-start)
Problem: hard gate deadlocks unattended runs and forces ritual stops before
trivial read-only asks. Change: exempt confirmed-autonomous scope (queue the
recommendation into the handoff note instead); scope the non-discretionary
task-start branch to change-tasks/non-trivial work. Impact: batch autonomy
works as designed; gate signal stops degrading. Risk: marginally later effort
corrections in autonomous runs (bounded: recommendation still surfaces at
handover).

**P2 — Record the ~/.claude branch exemption** (from A2)
Problem: the set's home repo systematically violates §12, normalizing override.
Change: one line in CLAUDE.md ("this repo: `main` is the working branch;
direct commits are the recorded override per §12"). Impact: practice and rule
re-align; §12 regains credibility elsewhere. Risk: none identified.

**P3 — Archive friction baselines; label rule effectiveness honestly** (from A3)
Problem: effectiveness claims are unfalsifiable once facets prune. Change:
rule-friction skill step: commit each `rule-friction-report.sh` aggregate as a
dated artifact under `.aiassistant/state/`; require ≥2 archived windows +
named incident-class counts for any per-rule effectiveness claim, else label
"untested"; note Skill-tool telemetry (transcripts) as the source for
per-skill claims. Impact: V4 becomes falsifiable at near-zero cost. Risk:
small state-dir growth.

**P4 — Add a demotion mechanism to Meta §3.2** (from A4, B5)
Problem: add-only ratchet degrades V5 and attention salience over time.
Change: periodic demotion review piggybacked on the rule-friction cadence:
each always-on section must show a window incident it prevented/answered or
carry a justification tag; candidates demote to path-gated/skill scope; hard
token budget per [CRITICAL] file as trip-wire. Salience-protected rules are
explicitly exempt from demotion, not from justification. Impact: bounds
always-on growth structurally. Risk: review overhead ~quarterly; mis-demotion
possible (mitigated by proposal-not-auto-apply).

**P5 — Unify handover governance** (from B2 /tmp, B4 three-mechanisms)
Problem: three mechanisms, contradictory storage mandates, lossy default for
ad-hoc handovers. Change: §10.3 becomes the spine and names a durable target
(`.aiassistant/state/` in projects; never session scratchpad/tmp); batch §11.1
and pocock:handoff declared producers of §10.3's continuation-doc component
with one reconciled storage rule; fix pocock:handoff ledger activation.
Impact: closes the replayed /tmp incident class. Risk: touching three files;
needs export sync check.

**P6 — Extend §1.5 to state-claims and to actions** (from B2)
Problem: assumed-state assertions and act-on-labeled-hypothesis are compliant
today. Change: §1.5 covers any assertable system-state fact; add: changes
premised on a hypothesis require the ground-truth check (or explicit user ack)
before applying. Impact: covers the actual top friction theme, not just its
first incident shape. Risk: slightly more probe commands per session.

**P7 — Close the push-time gaps** (from B2)
Problem: push remote and pre-push validation are covered by no rule or hook.
Change: add resolved push remote/upstream to §2.4's naming list; add §5.2
clause (or pre-push hook module) binding the project's static gate to push
time when one exists. Impact: converts two mislabeled "adherence failures"
into covered classes. Risk: pre-push hook adds latency; keep it scoped.

**P8 — Mechanize what regex can catch** (from B3)
Problem: §5.6 pipeline shapes and similar mechanical classes are prose-fenced
while hook infra idles. Change: PreToolUse Bash hook (hookify or
~/.claude/hooks/) flagging §5.6 anti-pattern shapes; keep prose as rationale.
Impact: enforcement no longer depends on model attention under pressure; the
exact V1 premise. Risk: false positives → make it a soft-block/warn.

**P9 — Non-batch fallbacks for §4.5, trigger for §4.6** (from B3)
Problem: §4.5 mandates a batch-only artifact and has no infeasibility path;
§4.6's legacy gate lacks an operational trigger. Change: §4.5: chat-stated
evidence line as non-batch recording target + §5.2-style blocker fallback for
payload replay; §4.6: an explicit user change-task IS the confirmation, the
gate binds to agent-initiated changes. Impact: highest-risk V2 rules become
satisfiable, ending silent-skip erosion. Risk: none identified beyond wording.

**P10 — Token diet, salience-guarded** (from B5)
Problem: ~20% of the 20.2k always-on tokens violate the set's own placement
policy or duplicate non-salience content. Change: trim 22 skill descriptions
to trigger surface (~1,800); slim ledger to policy+boundary (~650); move §4.5
batch-machinery and §12 release-mechanics into skills with §9.3 references
(~800-1,300); cut Persona's procedural restatements (~400) and F5 dup pairs
(~500). Do NOT move §10.5's offer list. Impact: ~3,000-4,600 tokens/session,
compounding over every future session. Risk: over-trimming trigger
NOT-clauses causes skill misfires; do descriptions one plugin per change-set
with review.

**P11 — Consistency change-set** (from B6)
Problem: five verified index/tooling drifts. Change: fix zoom-out ledger line
(+ literal phrase); decide githooks-install policy and align three surfaces;
correct RULESET-OVERVIEW §3/§4 activation columns; extend lint RE_SKILL to
composer/pocock; re-verify or drop the "built-in diagnose" rationale (3
mentions); add brainstorm ↔ design-an-interface NOT-clauses. Impact: index
trustworthy again; linter guards all cross-plugin refs. Risk: none identified.

**P12 — Small clarity fixes** (from B1)
Problem: three rule-pair conflicts force silent dropping. Change: precedence
note CLAUDE.md-Atlassian ↔ §10.5 (offer first; on release create live page;
paste-path caveat stated); resolve Meta §2.2/§2.3 in favor of
speculative-persist+flag and add global CLAUDE.md as a §2.2 layer with 2-3
tie-breakers; CleanCode precedence clause (codebase convention wins in
generation-into-legacy); optional §8.2 per-project language override mirroring
§12. Impact: removes contradictory-MUST states. Risk: none identified.

## D. Explicitly not proposed
- Removal of zero-usage skills (githooks-install, poke-holes, pocock set):
  cheap, gated, and the usage-measurement channel is known-blind to Skill-tool
  calls; revisit after P3's telemetry lands.
- Any weakening of salience-protected rules (anti-capitulation, premature
  closure, §1.4/§1.5 closure language): out of scope per Meta §3.2.
- Checkpoint-cadence redesign beyond P-scope: B4's milestone-definition and
  delegation findings are real but interact with P3/P4; fold into that
  change-set when it lands.
