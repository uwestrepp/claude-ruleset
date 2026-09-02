# Consolidation record: verification reach, and the proposal backlog it came from

```
Date:          2026-08-31
Status:        reach cluster shipped 2026-09-02 (Paket 1); carried open items still open
Origin:        rule-set consolidation session 2026-08-31 (/core:batch cycle, triage packet
               revision 3); user decision the same day that one record replaces the
               individual proposal files
Revisit when:  the next /core:rule-friction cycle, or when a carried open item is
               picked up. The reach cluster is closed; do not re-derive it.
Supersedes:    15 proposal files plus `unsorted.md`; see "Register of superseded proposals"
```

This document replaces fifteen proposal files. Their full text stays under `done/`; this is
the active entry point. It carries two things that must not be confused: the
**verification-reach cluster**, which is one always-on clause replacing seven near-duplicate
proposals, and a **register of everything else** that was archived alongside it and is *not*
covered by that clause. The second part exists so that archiving loses nothing — a proposal
whose substance is not represented here would not be superseded, it would be dropped.

## Problem

Two problems, one document.

**1. Nine incidents, one error, nine files.** Between 2026-08-18 and 2026-08-31 the same
failure was recorded nine times on different axes. Each instance produced its own proposal,
each argued its own ~60-token always-on budget case, and the sum (~675) stood against 228
free tokens in `rules/General.md`. Nine competing additions are both more expensive and
weaker evidence under `Meta.md` §3.3 than one clause naming the shape with its recurring
traps.

**2. The proposal process produced the backlog.** It creates one file per incident and
assigns pattern formation to nobody. Seven instances of one axis therefore sat as seven
open files for weeks. The pattern became visible only because one proposal
(`2026-08-26-absence-is-not-impossibility`) voluntarily drew an adjacency table across
three of them. This is a governance defect, not an accident of this particular backlog, and
its fix is Paket 6 item 1 (a proposal names its axis; `/core:rule-friction` gets an explicit
consolidation pass over open proposals sharing one).

## The common shape, and the reach test

Every check has a **reach**: *the set of facts for which the check could have failed.* The
error is not a missing check. In all nine incidents a genuine check was executed and its
result was correct. The defect sits at the transition from check result to conclusion, where
the conclusion silently covers a wider set than the check could ever have falsified. A real
measurement standing next to the wider claim is precisely the mechanism by which this hides:
the evidence is real, the conclusion is not, and no amount of care in re-reading the source
closes the gap.

Reach is bounded by the check, never by its subject.

## The nine axes (established at cost — do not re-derive)

| # | Axis | Incident |
|---|---|---|
| 1 | population | n8n `import:entities` reported "Advanced 4 sequence(s) across 21 table(s)". The four were verified against `max(id)` and were correct; seven `SERIAL` tables were never in the tool's population at all. A tool's report about its own work is not the population the system holds. |
| 2 | modality, positive | Shopify's `MetaobjectAdminAccess` declares `PUBLIC_READ_WRITE`; the API rejected it at the call site. A declaration is evidence of form, not of admissibility in context. Presence is not permission. |
| 3 | modality, negative | A search over all 3552 schema type names for `emailtemplate` found nothing, and produced "no app can do this". The templates are reachable through the `TranslatableResourceType` enum value `EMAIL_TEMPLATE`. A source's silence is a fact about the source, not about the world. |
| 4 | generalisation | A loop-guard rig proved the case the fix targeted; the commit body then described the fix, which is a wider set. Two instances in one branch (`96e87fafe` and its sibling), both found only by a later adversarial pass. |
| 5 | witness / layer | A fact was read from the index layer (`ARBEITSSTAND.md`) and carried outward, while the project's own `CLAUDE.md` names `docs/` as the source of truth on conflict. One layer is not the other. Repeat instance from a different session: `git log main` taken as evidence for a branch's state, where a local ref is a cached value and `origin/main` (or a prior fetch) is the witness. |
| 6 | completeness | `docker compose logs n8n \| grep -iE "migration\|error"` was read as proof that every migration ran. A workflow named "KAVO Error Handler" matched the filter incidentally and its activation line landed among the migration lines, while the other activation lines were absent. A filter's hit list is not an event list. Sibling instance: `n8n list:workflow --active=true --onlyId \| wc -l` returned 16 for 15 workflows because the command prepends a deprecation warning, which nearly produced a diagnosis of three dead workflows. |
| 7 | reachability | Test run 208705 passed without ever entering the changed branch: live data made every property valid, so the new code path was not exercised. A green run that did not reach the change is not evidence about the change. |
| 8 | consumer set | `TYPO3_CONF_VARS['HTTP']['timeout'] = 15` was set globally in one commit; its consumers were then discovered one at a time across two days. `General.md` §3.2 fires on a modified API, and a global default is not one, so nothing required the enumeration. |
| 9 | delegation | This session: a sub-agent was briefed to look for `advisor` under `agents/` and in the plugin directories. It searched exactly there, correctly found nothing, and reported "does not exist". The reach narrowing was produced **by the briefing**, and the delegating agent saw only a clean negative, which is indistinguishable from a wide one. `/advisor <model>` exists as a harness command. |

**Tenth axis, recorded separately the same day and not among the nine above:**
`proposal-2026-08-31-observation-object-identity` — the *identity of the observed object*.
Two false diagnoses in one session (KSW5-893, krannich/pim): once the wrong object was
observed while looking indistinguishable from the right one (a tab click did not switch the
association type and the row count matched either way), once the observed code was not the
code just written. It is the same shape applied to the object rather than to the population
or the modality, and it is carried here so that archiving its file loses nothing.

## Proposed change

**SHIPPED 2026-09-02** as `rules/General.md` §1.6 (Verification Reach), replacing the
seven reach proposals. What follows is the record of the design and its repairs; the
applied text, its deltas against the draft, and the proof ledger are in the triage packet.

One new always-on section, **`General.md` §1.6 (Verification Reach)**, replacing
the seven reach proposals. The drafted text lives in the triage packet
(`.aiassistant/state/workflow-triage/20260831-ruleset-consolidation-alwayson.md`, atom C1)
and its delivery is Paket 1
(`.aiassistant/state/handoffs/done/handoff-20260831-122057-3-P1-verification-reach.md`).

**Do not apply the drafted text as it stands.** An adversarial pass (`/core:poke-holes`,
2026-08-31) found two blocking defects in it:

1. **The trigger misses most of its own evidence base.** The draft keys on the grammar of
   the claim (universal quantifier, negative existence, unqualified verification verb).
   Tested against the nine incidents it fires reliably on two ("no app can do this",
   "does not exist"). It does not fire on "checkpoint passed", "the right value is
   `PUBLIC_READ_WRITE`", "theme selection is open", or "skill descriptions are the
   unbudgeted surface". Root cause: the error happens at the inference step, often hours
   before the sentence is written, and the written sentence then carries no quantifier at
   all. "I checked four sequences, they are correct" is grammatically innocent and is the
   defect. The trigger must sit at the inference step; keep the grammar cues as a second,
   cheaper trigger.
2. **The rule offers a compliant cheap way out.** The draft offers "extend the reach OR
   narrow the claim" as equals. Narrowing costs nothing and is unfalsifiable ("not found in
   X" is always true); extending costs a query, a second surface, a forced branch. In at
   least four of the nine incidents extending was the correct action and narrowing would
   have preserved the defect while looking like diligence. Extension must be the default,
   narrowing the fallback, with a duty to name what stays unchecked.

Material findings from the same pass, to be resolved while repairing the two above:

- **No observable trace.** "Name what the check could have failed for" leaves no artifact.
  Prefer binding it to the existing `General.md` §1.5 hypothesis label over inventing a new
  output block, so it costs no extra always-on tokens.
- **Conflict with `General.md` §10.4 and `Persona.md`.** The clause demands qualifiers;
  §10.4 demands the fewest words and `Persona.md` names performative hedging as a failure
  mode. State explicitly that a reach qualifier is content, not hedging, or the two rules
  fight under pressure.
- **The §5.6 subsumption is overstated.** "§5.6 is this rule applied to command
  construction" holds for §5.6's evidence clause, not for its authoring clause. Narrow the
  sentence.
- **The repair cues were lost by oversight, not by decision.** The seven source proposals
  each carried a concrete repair (enumerate the population from the system, confirm against
  the actual call, grep the index layer). The consolidation kept the recognition cues and
  dropped the repairs. Decide deliberately whether one short repair cue belongs in the rule.

One concrete repair cue is worth keeping verbatim, because it was drafted against two
measured instances and is the sharpest text in the whole set. Paket 1 must decide whether it
lands inside §1.6 or as an additional bullet in `General.md` §5.6, after the
"Instead assert on an explicit count" bullet:

> A filter's hit list is not an event list: when the fact is *completeness* ("every
> migration ran", "every workflow reactivated"), matching lines prove presence, not the
> absence of gaps. Assert on a count compared against an independent source, and confirm the
> counted lines are the only thing the command emits — a stray banner or warning line
> silently inflates `wc -l`, and a keyword filter collects incidental matches (a workflow
> named "Error Handler" lands among `grep -i error` hits).

Delegation (axis 9) must be covered explicitly, either as a paragraph inside §1.6 or as a
clause in `General.md` §11.2: the briefing states the claim the delegated check is meant to
support, and the sub-agent reports the reach of what it actually checked. Applied in-session
for two later audits, it worked immediately — see the audit history below. Keeping it at one
site (§1.6) is the cheaper option at ~40 always-on tokens.

## Expected impact

- Nine competing always-on additions collapse into one, at roughly a third of the token
  cost, with nine incidents of evidence behind it instead of one each.
- The clause is the first rule in the set that binds the *inference*, not the check.
  §1.4 and §1.5 govern recall versus ground truth and worked in every one of these
  incidents: a live source was queried every time. Neither says the live source may be the
  wrong witness, or too small a witness.
- Delegated checks stop being a blind spot: a clean negative from a sub-agent is currently
  indistinguishable from a wide one, and there is no rule anywhere in the set that catches it.

## Risk / tradeoff

**Budget.** `bin/lint-section-refs.sh` Check 6 counts `chars * 10 / 38`. Do not mix that
with real-token estimates; that error already produced a negative reserve once and was
caught only by the third audit. Measured 2026-08-31:

```
rules/General.md          39036 chars = 10272 · budget 10500 (= 39900 chars)
removals A5 + A10 + A12    -443 chars =  -116
§1.6 draft (condensed)    +1292 chars =  +340
                          ------------------------
                          39885 chars = 10496 · reserve 4   ← too tight to ship
```

The two blocking repairs above will most likely make the clause longer, not shorter, so plan
for it. Options, none applied: (a) dissolve the `General.md` §10.5 self-executable list
entirely and fold the sub-agent case into the criterion sentence (~340 chars instead of 216;
`comm-calibrate/SKILL.md:66` depends on that case and must still resolve afterwards);
(b) shorten §1.6 further; (c) pull one deferred demotion atom forward from Paket 4 (A8 and
the first half of A11 are the cleanest); (d) raise the budget by explicit user decision,
which is legitimate per the script's own message but is the exact ratchet this session
exists to stop.

**The larger budget finding.** `Meta.md` §3.3 names three always-on surfaces; Check 6
budgets five files and nothing else. Measured 2026-08-31:

```
rules/General.md        10272 / 10500   budgeted
rules/Meta.md            4188 /  4500   budgeted
skill descriptions (27)  3589 /   ---   NOT BUDGETED
CLAUDE.md                3055 /  3100   budgeted
Persona + Organisation    954 /  1600   budgeted
agent descriptions (6)    446 /   ---   NOT BUDGETED
------------------------------------------------
total                   22504           18 % ungoverned
```

Fourteen proposals fought over 228 tokens in `rules/General.md` while 4035 sat unmeasured
next door. Skill descriptions alone exceed `CLAUDE.md`. The fix is Paket 5, and it must fix
the class (Check 6 verifies budget *coverage*, failing closed on an unbudgeted always-on
surface) rather than the instance (adding one budget line for skill descriptions, which
would have left the agent descriptions undetected a second time).

**Paket 5 is applied** (2026-08-31, commits `d1f3fed` … `f87be0a`). Check 6 now enumerates
each surface's members mechanically — the `@` imports in `CLAUDE.md`, tracked `SKILL.md`,
tracked `agents/*.md` — and fails closed on a member that maps to neither a budget nor an
explicit `UNBUDGETED` marker, so a *fifth* surface added by hand still has to be declared but
a new member of an existing one can no longer slip in. `Meta.md` §3.3 names the fourth
surface and the coverage requirement; the script's surface list is maintained by hand with
§3.3 as its stated source and is deliberately not parsed from that prose. After the demotion
pass over skill descriptions and the `CLAUDE.md` ledger:

```
rules/General.md        10272 / 10500   unchanged (budget kept, not raised)
rules/Meta.md            4276 /  4490   +88, the §3.3 coverage sentence
skill descriptions (27)  3197 /  3360   -386
CLAUDE.md                2872 /  3020   -183, twelve ledger entries
Persona + Organisation    954 /  1005   unchanged
agent descriptions (6)    445 /   467   unchanged, now budgeted
------------------------------------------------
total                   22016           0 % ungoverned
```

Budgets are actual + ~5 %: the headroom is one edit wide by design. Two things were left
undone on purpose. Agent descriptions were budgeted but not shortened — they carry the same
untested activation risk as skill descriptions and the package had no reason to spend it.
And `pocock/` descriptions were not touched: they are vendored, and editing them creates
upstream-refresh drift (`plugins/marketplaces/local/plugins/pocock/UPDATING.md`).

**The risk that still has no test.** A description IS its activation trigger, and nothing in
the repo tests activation. Every tightening was reviewed one description at a time against
the phrases a user would plausibly type, and the nine entries whose only removal was the
`Activate via /plugin:skill …` boilerplate were grouped in one commit on that ground. If a
skill stops firing, `git revert` of its single commit is the intended repair.

**Binding probability.** Moving always-on text into a skill body is not a free optimisation:
a skill that is not activated cannot bind. Every demotion trades tokens against binding
probability, and that trade is per atom, never a policy. This is why revision 1 of the triage
packet was wrong across the board.

## Audit history of this session

Three triage revisions, two OBJECTIONS verdicts. **Every** rev-1 misclassification made an
atom look safer than it was. `/core:batch` §9.1.1 mandates a written counter-check
explicitly as a guard against that bias; it was written for every atom and caught none of
them. The independent audits caught all of them, in order: a systematic optimism bias; a live
cross-reference (`comm-calibrate/SKILL.md:66`) that would have been broken by an atom
justified with "is not referenced"; and a false necessity claim in the budget rationale.

Two consequences worth keeping:

- A counter-check written by the classifying agent is weak evidence. Its value may be as
  input to an audit rather than as a gate in itself.
- The phrase sweep is not tied to an atom's risk class, it is tied to the **claim**. Any
  justification containing "is not referenced" or "no §-anchor depends on this" must carry a
  sweep proving it. That is the verification-reach rule applied to the triage packet that
  proposes the verification-reach rule.

The delegation fix from axis 9 was applied in-session to two later audits and worked at once:
both auditors disclosed what they could and could not falsify, and one thereby exposed that
it had no Bash and had reconstructed file sizes from line lengths. A third audit with
measurement capability was commissioned and found the blocking unit error in the budget
arithmetic.

Separately: `/core:batch` §9 has no proportionality floor. Its trigger ("more than one
finding/topic/file in one cycle") covers nearly any task, so a two-file prose edit ran the
full code-batch gate: three triage revisions, three audits, a proof-ledger schema and an atom
ladder designed for call-site refactors. The gate found three real defects, so it is not
worthless; it is mis-sized. Carried as Paket 6 item 3.

## Register of superseded proposals

Absorbed into `General.md` §1.6 (delivery: Paket 1):

| File (now under `done/`) | Axis |
|---|---|
| `proposal-2026-08-18-verification-population-completeness.md` | 1 population |
| `proposal-2026-08-19-schema-presence-vs-admissibility.md` | 2 modality, positive |
| `proposal-2026-08-26-absence-is-not-impossibility.md` | 3 modality, negative |
| `proposal-2026-08-25-claim-reach-bound-to-verification-reach.md` | 4 generalisation |
| `proposal-2026-08-24-index-vs-source-of-truth-drift.md` | 5 witness / layer |
| `proposal-2026-08-25-consumer-inventory-before-global-default.md` | 8 consumer set |
| `proposal-2026-08-31-observation-object-identity.md` | 10 object identity |

Absorbed into the `Meta.md` §2.4 artifact clause (delivery: Paket 3):

| File (now under `done/`) | Substance |
|---|---|
| `proposal-2026-08-25-handoff-pointers-not-snapshots.md` | An artifact records what it controls and points at the source for what it does not; a snapshot carries its date and names the source; a referenced path must survive a reboot. Open design question there: the clause binds when an artifact is *written*, while §2.4 governs retention — decide between §2.4, §2.2, or a split before applying. |

Note on the count, observed while executing this consolidation: the deliverable list in the
P2 handoff says fifteen files while sixteen were present in the store, and the correct set was
recoverable only by cross-reading three documents (the Phase-2 scratch handoff says "14
proposals + `unsorted.md`", the Paket 1 handoff says "supersedes 7", and one file is not a
reach instance at all). The count was correct when written and decayed as two more proposals
landed. That is the Paket 3 clause failing inside the rule-set's own artifact: a count of
files another actor keeps writing is state the artifact does not own, and belongs in it as a
pointer, not as a number.

## Carried open items (not covered by `General.md` §1.6)

Items 1-7 are the archived proposals whose substance is **not** in the reach clause; 8-10
come from `unsorted.md`; 11 and 12 were appended by Pakete 5 and 1. Each is still open.

**Scheduling, verified 2026-09-02.** Until that date this list was a backlog, not a plan: no
handoff scheduled any of the twelve. That is now fixed, and the owning handoff is named per
item below. `Ownerless` marks the three that need a user decision rather than
implementation — they stay here on purpose.

| # | Item | Owning handoff |
|---|---|---|
| 1 | Pairing mode, part B | none — scoped 2026-09-02 to a narrow `observe`-only core; build-or-drop is the user's call (`Ownerless`) |
| 2 | Branch resolution at commit time | Paket 8 §1 |
| 3 | Pre-action check as its own call | Paket 8, parked with an unpark trigger |
| 4 | Guard-pattern precision | Paket 4, follow-up step 1 |
| 5 | Em-dash gate | Paket 8 §2 |
| 6 | ß versus ss | Paket 8 §3 |
| 7 | Shopware review cascade | Paket 7, "Addition, not hygiene" |
| 8 | Two target documents for actionable findings | Paket 3, second clause |
| 9 | Transition-state bug needs two runs | Paket 8 §4 |
| 10 | agnix ledger claim wrong for memory files | **DONE 2026-09-02** — sentence corrected in `CLAUDE.md` + hook header |
| 11 | Skill activation has no test | blocked: `claude plugin eval` is the right mechanism but gated behind early access here (`Ownerless`) |
| 12 | §5.6 completeness bullet, repair half | Paket 4, follow-up step 2 |

1. **Pairing mode** (`proposal-2026-07-29-implementation-visibility.md`). Part A of that
   document was decided and built as `/core:blueprint`. Part B, an always-on pairing mode
   that makes the genesis of implementation decisions visible, remains proposal only and
   nothing is built. Open sub-questions recorded there: `observe` versus gating, persistence
   reach, and willingness to add hooks (the precondition for any credible always-on claim).
   Also open: whether the blueprint gate fires at the right moments in real use, which
   decides whether Part B is still needed at all.
   **Corrected 2026-09-02 (user).** "Willingness to add hooks" is a stale framing: this repo
   already runs eight registered hooks (seven `PreToolUse`, one `SessionStart`), so the
   question was never *whether* but *what for* and at what cost. Verified the same day: no
   `UserPromptSubmit` hook exists yet, and that is the event B1 names as the mechanism
   (re-inject mode and level via `additionalContext` every turn, so the mode survives
   compaction). Only the event is new; the shape is proven on this host.
   **The decision, restated from the proposal's own findings:**
   - `observe` (B3) never blocks, costs no round trip, and is fail-VISIBLE — if it stops,
     the user notices. `gate` blocks once per decision and is where the cost explodes. B3
     suspects `observe` covers most real cases.
   - The level ladder (B2) is the wrong axis and would gate the wrong things. The right
     trigger is "several defensible options / irreversible / not fixed by codebase
     convention"; abstraction level is at most a scope filter.
   - B4 forbids blanket forced verbalisation: "no real alternative weighed, standard pattern
     from `<file>`" MUST count as a complete answer, else the mode manufactures post-hoc
     rationalisations that the user then decides on — worse than the opacity it cures.
   So the cost-benefit-positive core is narrow: `UserPromptSubmit` hook + state file,
   `observe` only, trigger on genuine option sets, plus the §8.4 suspension (M1) and a
   `CLAUDE.md` ledger line. `gate`, the level ladder and cross-session persistence are the
   expensive parts, and none is required for the stated need ("just see it").
   Still open and NOT answerable by the agent: whether even that narrow version is worth
   building, given that M2 has no cheap resolution — sub-agents do not see the mode, so
   delegated implementation bypasses it entirely while `General.md` §11.1 mandates
   delegation for exactly that kind of bounded work.
2. **Branch resolution at commit time** (`proposal-2026-07-31-branch-resolution-at-commit-time.md`).
   `General.md` §12 resolves the target branch once per *task*, and a task can be long; in
   the GMP-340 go-live session the working copy had moved onto `staging` hours later and a
   commit to a protected branch was one call away. Preferred fix, no always-on cost: a step
   in the `/core:commits` enforcement checklist immediately before the existing staged-scope
   step, re-reading `git branch --show-current` and confirming it against the branch resolved
   for the work.
3. **A pre-action check must be its own tool call** (`proposal-2026-08-17-staging-check-separate-call.md`).
   The `/core:commits` staged-scope step ran and the commit still swept in 13 unintended
   files, because the check and `git commit` sat in one Bash invocation: the output existed,
   but only after the commit. Fix in the skill, not always-on. Deliberately not proposed for
   `General.md` §5.6 on one incident; generalise only if a second instance appears elsewhere.
4. **Guard pattern precision** (`proposal-2026-08-17-guard-pattern-precision.md`). The
   `General.md` §5.6 authoring clause covers exit-status masking and says nothing about the
   precision of the patterns a guard matches on, which has gone wrong three times in
   `hooks/guard-destructive-commands.sh` (most memorably: a substring scan found a phantom
   `-r` in the path segment `-uwestrepp`, classifying every plain `rm -f` under a session
   scratchpad as recursive-force). Proposed: one sentence requiring a structural match to be
   anchored to the structural unit it claims to describe. **Always-on cost, so it competes
   with §1.6 for the same reserve** — sequence it after Paket 1 and Paket 5.
   *Envelope after Paket 5:* `rules/General.md` has 228 estimated tokens of reserve, which one
   sentence fits — but §1.6 (Paket 1) is drawing on the same 228 and is the larger claim. This
   item is affordable only if Paket 1 lands under budget; it is not affordable alongside a
   §1.6 that consumes the reserve. Paket 1 decides, this package does not.
   **Verdict, Paket 1, 2026-09-02: NOT affordable, still open.** §1.6 landed at 10484
   estimated tokens against budget 10500 — reserve 16, and the repaired clause needed two
   Paket 4 atoms pulled forward to get there. One sentence on guard-pattern precision costs
   ~65. It is not shortened away and not dropped: the next `rules/General.md` addition needs
   a demotion first, so this item is queued behind Paket 4, whose atoms are the space it
   would spend. Its evidence (three incidents in `hooks/guard-destructive-commands.sh`) is
   unaffected by the delay.
5. **Em-dash gate** (`proposal-2026-08-17-em-dash-gate.md`). `General.md` §8.5 is enforced by
   attention alone and attention failed three times in one session. Proposed: extend
   `hooks/validate-commit-message.sh` (already a `PreToolUse` gate scoped to `~/work`) to
   reject U+2014 in a commit subject or body, and in added lines of the staged diff, with
   carve-outs for code fences, source files and quoted external text. `~/.claude` itself
   stays out of scope. Fail-closed on the message, warn-only on the diff until fence-skipping
   has run clean for a few weeks.
6. **ß versus ss in German output** (`proposal-2026-08-20-ss-vs-eszett-in-german-output.md`).
   An entire German documentation set was written in the Swiss `ss` spelling with no rule,
   gate or spellchecker objecting: it is valid German carrying every diacritic the rule asks
   for, so the rule reads as satisfied while the register is wrong. Fix in
   `/core:communication` §2 where "including umlauts and ß" already stands, plus a carve-out
   for Swiss and Liechtenstein recipients recorded per project. No always-on growth.
7. **Shopware review cascade** (`proposal-2026-07-31-shopware-review-customer-cascade.md`).
   Deleting a customer does not cascade to `product_review`: `customer_id` goes `NULL` and
   the row survives with `external_user` and its status, invisible in the storefront at
   `status = 0` and indistinguishable from a genuine pending review in the administration.
   One line in `rules/Shopware.md` §1, path-gated, no always-on cost. Cross-check against
   Paket 7, which proposes moving project specifics *out* of that file: this is a behaviour
   fact, not a project specific, so it stays a legitimate addition.

Three further open items come from `unsorted.md` (see below):

8. **A finding with an action consequence has two target documents.** `Meta.md` §2.2 requires
   the narrowest durable scope but says nothing about findings whose consequence is an
   action: findings were written to a review document and reported as persisted, while the
   resulting steps were missing from the operational document that would have triggered them.
   Proposed: one sentence in §2.2 — when a finding implies an action, the document that
   triggers the action (runbook, deploy plan, checklist) is checked as a second target, and
   the checkpoint is complete only with both. Always-on cost: one sentence.
   *Envelope after Paket 5:* `rules/Meta.md` has 214 estimated tokens of reserve and nothing
   else is queued against it, so this one is affordable now. It is the only carried item this
   package clears for spending.
9. **A single run cannot show a transition-state bug.** Distinct from axis 7 (reachability):
   there the branch was never entered, here the run entered it but only end states were
   observed, while the defect sat in the state carried between runs. It reached production.
   Proposed: where state is carried forward across runs, check at least two consecutive
   cycles plus the transition between the end states. The note itself argues `/core:batch`
   §3.3 is a better home than `General.md` §5.2, which is dense and always-on.
10. **RESOLVED 2026-09-02 — the agnix ledger claim was wrong for memory files.**
    User decision: correct the sentence, no manual step. Applied in `CLAUDE.md` and in the
    `.githooks/pre-commit` header, which carried the same false claim — agnix covers
    SKILL.md and rule files; memory files are not covered, and widening the hook scope does
    not help.
    One premise corrected in passing: a manual step would NOT have meant tracking the memory
    files. `npx agnix@0.40.0 validate projects/-home-uwestrepp--claude/memory` runs fine on
    the untracked, gitignored path (verified 2026-09-02: 0 errors, 21 warnings, all of them
    portability complaints about hard-coded `~/.claude` paths). What a pre-commit hook cannot
    do is gate on it — an untracked file gives the hook nothing to block. Original below.

    `CLAUDE.md` states that
    "SKILL.md / rule / memory files are validated by `agnix` ... in the pre-commit hook".
    Verified 2026-08-31: the hook runs `agnix validate plugins/marketplaces/local/plugins
    rules`, and `projects/` (which holds every memory directory) is gitignored at
    `.gitignore:32`, so memory files are untracked and no pre-commit hook can validate them
    at all. Widening the hook scope therefore does not fix it. Fix: correct the ledger
    sentence, or add an explicit manual validation step for memory files and say so.

Two items were appended later by the packages that discovered them:

11. **Skill activation has no test, and the harness may already offer one.** Package 5 had to
    change twelve activation triggers with no executable validation path: `General.md` §5.2
    asks for a behavioural check, and for a skill description there is none — the "test" was
    re-reading the text. The mitigation used (one commit per description, revert as repair)
    limits the blast radius but proves nothing. Hypothesis to verify before proposing
    anything concrete: `claude plugin eval` (referenced by the `claude-code-guide` agent as
    covering plugin eval suites and `/skill-doctor`) can assert that a given prompt activates
    a given skill. If it can, a fixture of the phrases each description claims as triggers
    turns the whole surface testable and this is the single highest-value addition to the
    rule-set's own tooling. If it cannot, say so here and the risk stays accepted-and-named.
    **Hypothesis CONFIRMED in mechanism, BLOCKED in execution (2026-09-02).** User decision
    was "if it is a feasible test, do it". It is the right test and it cannot be run here yet.
    Two findings, with their reach kept separate:
    - *Verified by running it on this host.* `claude plugin eval` exists and its `--help`
      documents `--ablation <none|with-without>` plus, verbatim: "under with-without, graders
      marked with-only, incl. `tool_used: Skill`, are a plugin-fired indicator rather than
      part of the score". So skill activation is a first-class thing the harness scores. But
      EVERY real invocation answers `` `plugin eval` is currently in early access `` and
      exits 1 — `init --bare` included, so nothing can even be scaffolded. CLI is 2.1.258 and
      `claude update` reports up to date, so a stale binary is not the cause.
    - *Reported by a `claude-code-guide` sub-agent from an embedded offline reference, NOT
      verified by running anything and NOT found in public docs.* Case layout is
      `evals/<case>/prompt.md` + `graders/<name>.md` (+ optional `case.yaml`), and the
      skill-fired grader idiom is `type: tool_used` / `tool: Skill` /
      `input_match: '"skill"\s*:\s*"(?:[\w-]+:)?<skill>"'`. The `<skill>` placeholder and
      the optional namespace group are what would make a PER-SKILL assertion possible rather
      than a bare "some skill fired"; the sub-agent could not confirm the substitution, so
      treat the syntax as a dated hypothesis until an actual run type-checks it.
      Enablement per the same reference: automatic for first-party clients after
      `claude update` plus a fresh session, and an enablement env var — name not in the
      reference — for restricted clients (Bedrock/Vertex/Foundry, custom base URL, or
      telemetry disabled).
    **Next concrete step, and it is the user's, not the agent's:** retry a real
    `claude plugin eval` invocation in a FRESH session — that is the one untested variable
    left in the automatic-enablement path. If it is still gated, the enablement variable's
    name has to come from the early-access contact; there is no public doc page for it. Only
    then is the fixture worth authoring, and it should start with a handful of skills whose
    triggers are unambiguous rather than all 27 descriptions at once.
    Until then the risk stays accepted-and-named: Paket 5's twelve description changes and
    Paket 1's own reliance on §1.6 firing are both untested, and `git revert` of a single
    commit remains the only repair.

12. **The §5.6 completeness bullet did not land** (Paket 1, 2026-09-02). The verbatim cue
    quoted under "Proposed change" — a filter's hit list is not an event list; assert on a
    count against an independent source and confirm the counted lines are the command's only
    output — costs ~500 bytes on a surface that closed at reserve 16 tokens. Its
    **recognition** half is in `General.md` §1.6's recurring limits ("a filter's hit list is
    not an event list"); its **repair** half is what is missing, and that half is the useful
    one, drafted against two measured instances. Same queue as item 4: it needs a demotion
    to pay for it. Do not re-derive the text — it is quoted verbatim above.

## Dissolved: `unsorted.md`

Seven raw notes, each with its disposition. The file is removed; git history keeps the
original text.

| # | Note | Disposition |
|---|---|---|
| 1 | Run a `Meta.md` §3.3 demotion review before the next always-on addition trips the wire; plus: agnix hook scope versus the ledger claim about memory files | Split. First half **dropped**: §3.3 already mandates it at every `/core:rule-friction` cycle, so the note proposes an existing obligation. Second half **carried** as open item 10, with a sharper and verified diagnosis. |
| 2 | `Meta.md` §2.4 should require a memory-referenced artifact to be reboot-safe and outside `/tmp` | **Folded** into the Paket 3 clause, which already carries "any path it points at MUST survive a reboot (never a temp dir or session scratchpad)". |
| 3 | Test run 208705 passed without entering the changed branch; alternative formulation about stateful logic and transition states | Split. Reachability half **folded** as axis 7. The stateful-logic half is a different failure and is **carried** as open item 9. |
| 4 | Extend `General.md` §5.6 to completeness proofs (hit list versus event list; `wc -l` inflated by a deprecation banner) | **Folded** as axis 6; its drafted bullet is quoted verbatim under "Proposed change" because it is the sharpest repair cue in the set. |
| 5 | A bare path to `handoff-20260730-145859-communication-pm-detail-rule.md` | **Dropped.** No proposal content; the handoff it points at is already consumed and archived under `handoffs/done/`. |
| 6 | A finding with an action consequence needs the operational document as a second target | **Carried** as open item 8. |
| 7 | `git log main` taken as evidence for a branch state; a local ref is a cached value | **Dropped as a proposal**, kept as a repeat instance of axis 5. It is already persisted at its correct scope: auto-memory `git-stale-index-snapshot-trap` in the `mosaiq-n8n-server` project (verified present 2026-08-31). |

## Not superseded

`proposal-2026-08-20-guided-gui-configuration.md` stays active in this directory. It is a
feature proposal (a named loop for configuration behind a GUI the agent cannot reach), not a
verification-reach instance, and it carries a decision the record cannot make for it. Its
risk section was corrected in this change-set: it priced a new skill at "a ledger line
always-on" and omitted the skill description, which is itself always-on and costs ~150-270
tokens. Paket 6 item 4 generalises that omission into a `General.md` §9.2 obligation.

## Evidence

- Triage packet, revision 3, with the full atom ladder, the classification table and the
  drafted texts: `.aiassistant/state/workflow-triage/20260831-ruleset-consolidation-alwayson.md`.
- Pre-change functional baseline: `.aiassistant/state/functional-baseline-ruleset-consolidation.md`.
- The seven work packages: `.aiassistant/state/handoffs/handoff-20260831-122057-*.md`.
- The fifteen superseded proposals, in full, under `.aiassistant/state/proposals/done/`.
- Session of 2026-08-31, `/core:batch` cycle, three independent audits.
