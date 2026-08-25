# Require a consumer inventory before introducing or changing a global default

```
Date:         2026-08-25
Status:       open
Origin:       session observation — SSBSITE-1261, two of three rework commits traced to
              the same missing step
Revisit when: a second project shows rework caused by a global default whose consumers
              were discovered one at a time, or the next /core:rule-friction cycle
```

## Problem

`General.md` §3.2 tells the agent to evaluate other usages of a **modified API**. A global
default is not an API change, so the rule does not fire, yet its blast radius is every
consumer that inherits it. §4.4 covers the behavioural-impact description but not the
enumeration that would make the description complete.

Concretely, in SSBSITE-1261 the agent set `TYPO3_CONF_VARS['HTTP']['timeout'] = 15`
globally in one commit and then discovered the affected call sites one at a time across two
days:

1. `a4ef2b0ee` sets the global default and verifies the VVS path and the EMS feed.
2. `a472fb120`, same day, repairs the KDT queue path, which had been unbounded and would
   now abort mid-run. The commit body calls it "a regression this PR caused itself".
3. `b5d8e45db`, next day, settles the AboLive monitoring, and the measurement there showed
   the assumption behind the whole exercise was half wrong: the ESB path carries its own
   `timeout = 12` since SSBSITE-1082 and never hung on the global value at all.
4. The closing review produced the full inventory and found **four further frontend call
   sites** that were unbounded before and now run on 15 s, none of them exercised. One
   streams a PDF from the ESB to the visitor, which is the most plausible remaining
   regression in the branch.

The inventory that would have prevented steps 2 to 4 was a single grep over
`packages/*/Classes/` for `RequestFactory`/`GuzzleHttp\Client`, plus one for call sites
setting their own value. It took under a minute, and it was produced last instead of first.

## Proposed change

Add to `General.md` §3.2 (Cross-File Dependency Awareness), after the existing sentence:

> When a change introduces or alters a **default that consumers inherit** (framework or
> platform configuration, a base-class value, a shared client option), the agent MUST
> enumerate the inheriting call sites before applying it, and decide per call site whether
> the new value fits. The enumeration is part of the change, not its follow-up: a default
> discovered to be wrong for one consumer at a time produces one rework commit per
> consumer.

## Expected impact

In the observed case: two of three rework commits avoided, and the four still-unverified
frontend paths would have been decided in the same pass rather than left open in a handoff.
Generalises to any shared-default change, which is a recurring shape in TYPO3, Symfony and
Shopware work (`TYPO3_CONF_VARS`, `framework.yaml`, `shopware.yaml`, DI parameter
defaults).

## Risk / tradeoff

- Always-on token cost: `General.md` is `[CRITICAL]`, so roughly 70 always-on tokens per
  session against the `Meta.md` §3.3 budget. This is the main argument against, and §3.3
  requires the incident to justify it; one project with a named commit chain is thin, hence
  `open` rather than applied.
- The enumeration can be expensive where the default is very broad (logging, encoding,
  serialization), so the wording needs the materiality escape that §3.2 already carries
  ("to the extent relevant") or the rule becomes a licence to stall.
- Cheaper alternative worth weighing first: this may be better placed in the
  `/composer:knowledge` or platform-rule layer, which loads on demand, rather than in the
  always-on baseline. The counter-argument is that the failure is framework-independent.

## Evidence

- Commits `a4ef2b0ee`, `a472fb120`, `b5d8e45db` on
  `feature/SSBSITE-1261-performanceoptimierung` in `ssb.website`.
- The full call-site inventory, nine sites with their timeout state, in
  `.aiassistant/state/handoffs/handoff-20260825-122441-timeout-restnachweise-und-vvs-requestzahl.md`
  of that project.
- Retrospective with the 3-of-13 rework figure in `.aiassistant/state/notes/effort-calibration.md`,
  section "Rückblick auf die Auswahl des Change-Sets", commit `75177b716`.
