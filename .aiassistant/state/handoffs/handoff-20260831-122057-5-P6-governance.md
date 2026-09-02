# Paket 6: governance fixes for the rule-set process itself

Status: designed, NOT applied. Each item traces to an incident inside the 2026-08-31
session, not to a hypothetical.

## 1. Meta.md §3.1 — proposals must name their axis

Incident: seven proposals described ONE error on seven axes and sat as seven files for
weeks. Each argued its own ~60-token budget case; the sum was ~675 against 228 available.
The pattern was visible only because one proposal voluntarily drew an adjacency table.

Change: a proposal names the axis / cluster it belongs to, and the /core:rule-friction
cycle gets an explicit consolidation pass over open proposals sharing an axis.
Impact: turns "one incident, one clause" into "n incidents, one clause", which is both
cheaper in always-on tokens and better evidence under §3.3.

## 2. General.md §11.2 — a delegation briefing must name the claim

**STATUS: DONE by Paket 1, 2026-09-02 — no work left in this item.** It ends below by
suggesting "Consider folding it into §1.6 (Paket 1) instead of §11.2, to keep it at one
site", and that is what happened. `General.md` §1.6's final paragraph carries it:
"Delegated checks inherit the reach of their briefing, and a sub-agent's clean negative
reads exactly like a wide one. The delegating agent MUST state the claim the check is meant
to support, and MUST treat the result as bounded by what was actually asked." §11.2 itself
was NOT touched. Everything below is kept as evidence, not as a pending change.

Incident, in this session: a sub-agent was briefed to look for `advisor` under `agents/`
and in plugin directories. It searched exactly there, correctly found nothing, and reported
"does not exist". The reach narrowing was produced BY THE BRIEFING, and the delegating
agent saw only a clean negative. `/advisor <model>` exists as a harness command.

Change: the briefing states the CLAIM the check is meant to support, and the sub-agent
reports the reach of what it actually checked. Applied in-session for two later audits and
it worked immediately: both auditors disclosed what they could and could not falsify, and
one of them thereby exposed that it had no Bash and had reconstructed file sizes from line
lengths, which is why a third audit with measurement capability was commissioned and found
a blocking unit error.

Cost: ~40 always-on tokens. Consider folding it into §1.6 (Paket 1) instead of §11.2, to
keep it at one site.

## 3. /core:batch §9 — no proportionality floor

Incident: §9 applies when "more than one finding/topic/file is handled in one cycle", which
covers nearly every task. A two-file prose edit therefore ran the full code-batch gate:
three triage revisions, three independent audits, a proof-ledger schema and an atom ladder
designed for call-site refactors. The gate DID find three real defects (systematic optimism
bias, a live cross-reference that would have broken, a blocking unit error in the budget
arithmetic), so it is not worthless. It is mis-sized.

Change: give §9 a proportionality clause, or a lighter track for change-sets that touch no
executable code. Do not simply raise the trigger threshold: the defects it caught were real
and would have shipped.

## 4. General.md §9.2 — cost a new skill at creation time

Incident: proposal-2026-08-20-guided-gui-configuration prices a new skill at "a ledger line
always-on" and omits its description (~150-270 tokens). §9.2 governs the ledger entry but
not the cost. Every future skill proposal will make the same omission.

Change: when a skill is created, its description's token cost is checked against the budget
in the same change-set. Only meaningful once Paket 5 gives descriptions a budget.

## 5. The counter-check is weak evidence when self-administered

Observation, not yet a proposal: /core:batch §9.1.1 mandates a written counter-check
("why is this atom NOT one level riskier?") explicitly as a guard against the model's
optimism bias. It was written for every atom in revision 1 and caught none of the
misclassifications; the independent audit caught them all. Consider whether the
counter-check earns its salience protection, or whether its real value is only as input to
the audit rather than as a gate in itself.
