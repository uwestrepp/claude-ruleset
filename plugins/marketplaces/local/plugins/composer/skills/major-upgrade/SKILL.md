---
name: major-upgrade
description: "Use before any major-version upgrade of a framework or platform managed through Composer — a jump crossing a deprecation/breaking-change line (e.g. cms-core ^12→^13, symfony 6→7, shopware 6.5→6.6), not a patch/minor bump. /typo3:upgrade is the TYPO3 specialization. explicit activation required — auto-suggest (do not auto-run) on requests like 'upgrade <framework> from major X to Y', 'major version migration', 'bump cms-core to the next major'. NOT patch/minor/security updates (/composer:update); NOT resolution/lock questions (/composer:knowledge)."
argument-hint: "[ecosystem|target-version]"
allowed-tools: [Read, Edit, Write, Glob, Grep, Bash, Agent]
---

# Composer Major-Upgrade Workflow (generic spine)

*Input (`$ARGUMENTS`): optional ecosystem or target-version hint (e.g. `typo3 13`).*

The system-agnostic backbone for a **major-version** upgrade of a Composer-managed framework or
platform. The premise: a major jump is not one `composer update` — it is a staged, gated cycle that
separates *which versions move* from *what must be migrated* from *which runtime to bump*, captures a
before/after baseline around the whole thing, and keeps every destructive step behind an explicit
snapshot gate.

This is a **workflow** skill. It is a **faithful specialization of `Batch.md` §1** — it adds no phase
numbering of its own; its phases ARE Batch phases 0–9, so any skill that chains on it (e.g.
`/typo3:upgrade` under `/typo3:upgrade-full`) sees the same phase model. It reuses the update skill's
delta and collision mechanics rather than restating them, and defers framework knowledge to a
pluggable slot contract. Resolve every referenced section into context before relying on it
(`General.md` §9.3):

- **`Batch.md` §1 (phase template — the authoritative phase model), §9 (Pass 1/2/3 + non-skippable
  triage/compliance gates), §2 (toolset gate), §3 (inventory/baseline), §5 (autonomous mode), §6
  (chaining), §7 (delegation), §8 (reporting).** Activate `/core:batch` or read those sections; they
  are binding here and MUST NOT be weakened (`Batch.md` §9.1 non-circumvention).
- **`/composer:update`** — **read (do not activate)** its §4–§7 (dry-run delta, ecosystem-catalog
  resolve, change-map build, collision/impact scan). You reuse its *mechanics* in Phase 3; activating
  the skill would trip its own scope gate, which refuses major jumps and redirects back here. The
  collision-vector catalogs (`../update/references/catalogs/{eco}.md`) are shared.
- **`/composer:knowledge`** — version resolution order, lock discipline, `-W` semantics, dev-overrides.
- **`/core:commits`** — commit schema + ticket traceability for the upgrade commits.
- **`General.md` §2.1/§2.2** (version/compat verification), **§2.3** (exec-context routing), **§2.4**
  (target disambiguation), **§4.5** (upstream-contract verification), **§5.2** (test-path selection),
  **§12** (git workflow: protected set, PR-only branches), **`Meta.md` §1.1** (checkpoints).

## Scope boundary (read first)

- **This skill** = major-version jumps that cross a breaking/deprecation line. The question is *"what
  must I migrate, in what order, and how do I roll it out without a destructive surprise."*
- **`/composer:update`** = patch/minor/security updates. The question there is *"will pulling this
  delta silently break a customization."* If the target does not cross a major line, defer to it.
- **Framework specializations** (e.g. `/typo3:upgrade`) fill this spine's slots with framework
  values. When a specialization exists for the detected ecosystem, **use it** — it activates this
  spine and supplies the framework-specific scan/remediation/schema/doc steps. This generic skill is
  the fallback when no specialization exists, and the shared contract they all conform to.

When the target sits at a boundary (a minor bump that also crosses a framework's own deprecation
line), name the ambiguity and ask (`General.md` §1.1).

---

## 1. Framework slot contract (MUST)

Framework specifics are **not** hardcoded here. A framework specialization (or, absent one, this
skill's own best-effort discovery) fills the slots defined in `references/framework-slot-contract.md`:

| Slot | What it supplies |
|------|------------------|
| `framework-detect` | composer signature + how to read the installed major version |
| `runtime-matrix` | supported PHP / DB / platform range for the target major |
| `changelog-source` | where the framework publishes its deprecation/breaking index |
| `deprecation-hotspots` | the API/config patterns that break across majors + the scanner/tooling |
| `remediation-toolchain` | the framework's remediation skills/tools (codemods, scanners) |
| `schema-wizard-commands` | schema-migration + upgrade-wizard CLI + destructive-cleanup handling |
| `config-sources` | configuration layers to cover in option-level validation |
| `doc-location` | the framework's migration-doc / version-doc convention |

State which slots were filled from a specialization, which from discovery, and which stayed unknown —
unknown slots reduce confidence and MUST be surfaced, not silently skipped.

---

## 2. Execution Phase Template (MUST)

A faithful specialization of `Batch.md` §1 — same phase numbers, same names, same boundaries. The
major-upgrade specifics live *inside* the phases; Phase 5 is staged (5a–5d) and is the only phase
that mutates code/data. The **runtime bump is not a phase** — it is either folded into Phase 5b
(coupled) or run as a post-rollout follow-up after Phase 9 (decoupled, §14).

| Phase | Batch name | Major-upgrade content |
|-------|-----------|------------------------|
| 0 | Toolset Gate | `Batch.md` §2 + composer root + exec context + `framework-detect`/`runtime-matrix` version verification (§3) |
| 1 | Preflight | `release/{target}` integration branch; restorable DB/state snapshot at the *old* version (§4) |
| 2 | Scope, Inventory & Baseline | inventory of entry points + touchpoints; functional **and** visual baseline at the *old* version (`Batch.md` §3.2) (§5) |
| 3 | Scan / Analysis | (a) changeset & collision map — reuse `/composer:update` §4–§7 mechanics; (b) deprecation/breaking scan via `changelog-source`/`deprecation-hotspots`. Then the **escalation gate (§10)** (§6) |
| 4 | Triage & Plan | triage packet (`Batch.md` §9.1); cleanup-on-old plan; **runtime coupled/decoupled decision** (§7) |
| 5 | Implementation | 5a cleanup-on-old · 5b version bump + boot fixes (incl. *coupled* runtime) · 5c framework remediation (`remediation-toolchain`) · 5d gated destructive schema/data. Pass 1/2/3 per `Batch.md` §9 (§8) |
| 6 | Validation | re-run the Phase 2 baseline; functional + visual diff; option coverage via `config-sources` (§9) |
| 7 | Documentation Sync | running upgrade log + a **separate** migration/rollout runbook at `doc-location` (§11) |
| 8 | Commits | per `/core:commits`; `release/{target}` → mainline via PR (§12) |
| 9 | Handover & Reporting | `Batch.md` §8.2 final report + `Meta.md` §1.1 (§13) |

Meta checkpoints (`Meta.md` §1.1) are mandatory at the end of Phase 3 (changeset/scan known), Phase 5
(implementation complete), and Phase 9, per the batch phase-boundary triggers.

---

## 3. Phase 0 — Toolset Gate (MUST)

Run the `Batch.md` §2 gate, plus:

1. **Locate the composer root** and **resolve exec context** exactly as `/composer:update` §2 (repo
   root vs nested app; host vs container — ddev → `ddev composer …`). Never operate against
   `vendor/`'s own composer files as the root. State the chosen mode once.
2. **Fill `framework-detect` + `runtime-matrix`** — read the installed major from `composer.lock`,
   confirm the target major, and verify the target major's supported PHP/DB/platform range against
   the project's current runtime (`General.md` §2.1/§2.2). A target major that does not support the
   current runtime forces a **coupled** runtime bump — flag it now, it changes Phase 4's decision.
3. **Confirm the target** — exact target major/version and the ecosystem. If a specialization exists
   for the ecosystem, name it and prefer it (§Scope boundary).

Do not proceed past Phase 0 if the root, exec context, or target major is ambiguous.

---

## 4. Phase 1 — Preflight (MUST)

1. **Integration branch** — cut/confirm a temporary `release/{target}` integration branch
   (e.g. `release/typo3_13`) from mainline: individual upgrade work branches are cut from and
   merged back to `release/{target}` via PR; it merges to mainline at completion, then is
   retired. It is part of the `General.md` §12 protected set (PR-only, no direct commits).
   Confirm the real deploy mapping before assuming any push deploys (`General.md` §12,
   `/composer:update` §9 deploy-target step); a deployment-trigger branch (e.g. `production`)
   derives from mainline, holds no unique work, and batches merged features into one release.
2. **State snapshot** — capture a restorable DB/state snapshot at the *old* version **before any
   change**. This is the rollback point for every later destructive step. Record its exact name and
   the restore command.

---

## 5. Phase 2 — Scope, Inventory & Baseline (MUST)

1. **Inventory** the upgrade surface (`Batch.md` §3): entry points (FE routes, BE, API, CLI,
   scheduler/worker), storage/schema touchpoints, and integration/dependency touchpoints (other
   in-house packages consuming the target).
2. **Baseline at the old version** — capture a functional baseline (the inventoried entry points:
   HTTP status, key queries, counts) **and** a visual baseline (screenshots of curated surfaces) per
   `Batch.md` §3.2. This is the regression oracle for Phase 6; without it, "before/after" is
   unprovable. Persist both as durable artifacts.

---

## 6. Phase 3 — Scan / Analysis (MUST)

Two analyses; neither mutates anything.

**(a) Changeset & collision map.** Apply `/composer:update`'s mechanics — **read** its §4–§7, do not
activate the skill (§reference list):

- **Dry-run delta** (`composer update {selectors} --dry-run -W`) → the authoritative per-package
  `current→target` set. Split direct vs transitive; flag security and floating-`@dev` transitions.
- **Collision scan** of project-owned customizations against the breaking-change set, via the
  ecosystem catalog (`../update/references/catalogs/{eco}.md`); classify each per `Batch.md` §9.
- **Change-map scope (do not over-build).** The per-package upstream change-map (`/composer:update`
  §6) is best-effort and scales poorly across a major delta — the rbk v12→v13 run resolved 75 package
  transitions via dry-run and drove migration from the deprecation scan + framework scanner, **not**
  from 75 per-package change-maps. Prioritize: (1) the collision scan against *your* customizations,
  (2) per-package change-maps only for packages your customizations touch or that the escalation gate
  (§10) flags. Do not block Phase 3 building exhaustive change-maps.
- **External-blocker check** — every required package has a stable release for the target major; a
  blocked dependency stops the upgrade. Report it.

**(b) Deprecation/breaking scan.** Fill `changelog-source` and scan the `deprecation-hotspots` the
slot contract supplies (a specialization names the concrete APIs; generic discovery falls back to the
framework's published upgrade guide + a grep of removed/renamed symbols). Map each finding to:

- **blocking** — must fix to boot/function on the target (fix in Phase 5),
- **safe path available** — should fix now; deterministic migration,
- **needs decision** — no safe path in context; backlog with rationale, or raise to the user.

For a multi-step jump, gather the per-delta patterns first via parallel `migration-pattern-researcher`
instances (one per version step/package; their output is a hypothesis set to verify against the installed
code, `General.md §1.4`). Delegate large finding sets per `Batch.md` §7 (`contract-researcher` for >10 §4.5 lookups). Then run
the **escalation gate (§10)** on the now-known scope before planning implementation.

---

## 7. Phase 4 — Triage & Plan (MUST)

1. **Triage packet** per `Batch.md` §9.1 — classify every finding `safe` / `provable` / `manual`;
   publish and persist the packet before any Phase 5 change (non-skippable gate).
2. **Cleanup-on-old plan** — what can be removed/neutralized *while still on the old version* to
   shrink the migration surface (unused packages, dead code, orphaned config). Verify "unused" with
   evidence (e.g. data/usage scan) before deleting (`General.md` §1.2).
3. **Runtime coupled/decoupled decision** (the highest-leverage planning call). Decide whether the
   runtime bump is **coupled** (the target major requires it → it runs in Phase 5b to even boot) or
   **decoupled** (the target major supports the current runtime → roll out code on existing infra
   first, bump runtime later as an isolated follow-up, §14). Decoupling reduces cutover risk by
   separating code variables from runtime variables; prefer it when `runtime-matrix` allows. Record
   the decision and rationale.

---

## 8. Phase 5 — Implementation (MUST)

The only phase that mutates code/data. Apply the `Batch.md` §9 Pass 1/2/3 model **within each
stage**; Pass 3 (high-risk/irreversible) always suspends for individual approval (`Batch.md` §9.3),
autonomous mode notwithstanding. Stages run in order:

- **5a — Cleanup on old version.** Execute the Phase 4 cleanup plan while still on the old major.
  Removing a package is not just `composer remove` — also strip its config, schema references,
  route/plugin registration, and scheduled tasks, or the new major may fail to boot on stale config.
  Validate against the Phase 2 baseline after cleanup.
- **5b — Version bump + boot-blocking fixes only.** Bump `composer.json` to the target constraints,
  run the real update (`-W` when a transitive bump must come along), then fix **only** what blocks
  boot/render. If the runtime bump is **coupled** (Phase 4), apply it here — the target cannot boot
  without it. Defer non-blocking deprecations to 5c. DoD for 5b: the Phase 2 entry points all respond
  (e.g. HTTP 200/expected) on the target major.
- **5c — Framework remediation.** Run the `remediation-toolchain` (a specialization's scanner +
  codemod skills — for TYPO3 this is `/typo3:upgrade-full` = scanner + static-tests). Chain per
  `Batch.md` §6. This clears the non-blocking deprecations/breaking-API findings from Phase 3.
- **5d — Destructive schema/data (gated).** Any irreversible schema or data operation
  (`schema-wizard-commands`) runs **last, behind its own gate**: (1) confirm the Phase 1 snapshot
  exists, (2) show a dry-run/preview of exactly what will change, (3) obtain explicit per-step
  approval, (4) apply, (5) verify boot + data integrity + functional parity. Prefer reversible
  intermediate steps (e.g. rename/prefix before drop) and leave the final irreversible drop as a
  documented manual step when feasible.

Verify upstream contracts for any changed public signature the project calls/subclasses
(`General.md` §4.5) before finalizing each stage.

---

## 9. Phase 6 — Validation (MUST)

Re-run the Phase 2 baseline on the target major and compare (`General.md` §5.2, `Batch.md` §9.4):

- **Functional** — every Phase 2 entry point, same checks; diff status/counts/key outputs.
- **Visual** — re-screenshot the curated surfaces; diff against the Phase 2 images; triage every
  visual delta as regression vs intended (a framework/theme major may legitimately restyle).
- **Option coverage** — for behavior-affecting configuration (`config-sources`), verify a minimal
  matrix of high-impact options still behaves (`/typo3:upgrade` §4.1 is the TYPO3 instance of this).

Static analyzers/linters are compliance-only and cannot be the sole regression proof (`Batch.md`
§9.4). Surface any open visual/UX decisions to the user rather than auto-accepting them.

---

## 10. Escalation gate — sequential, delegated, or orchestrated (MUST)

A major upgrade is **not** automatically large. Run this gate at the end of Phase 3 on the now-known
scope, and pick the lowest tier that fits. **Invariant across all tiers:** the **stateful spine**
(composer update, schema migration, boot cycles, snapshots, reindex, cutover) is inherently
sequential and stays in the main loop — parallelization only ever applies to the *fan-out-able*
sub-work (scan, triage, per-package remediation in isolation, per-surface validation/re-baselining).
`/core:batch`'s Pass-model and gates are the always-on **baseline**, not an escalation tier.

**Tier 0 — sequential (default).** One agent, human-paced, Batch Pass-model. (Verified on the rbk
v12→v13 run: ~2 packages removed, ~750 LOC custom across 2 extensions, ~7 scanner findings —
neither higher tier tripped; pure sequential sufficed.)

**Tier 1 — sub-agent delegation** (`General.md` §11 / `Batch.md` §7). The orchestrator stays in the
main loop and offloads bounded read/analysis/classification so it does not flood context. **No
opt-in** — apply as needed when ANY holds:

- inventory/scan spans ≥5 packages/extensions (→ `Explore`),
- >10 upstream-contract (§4.5) lookups (→ `contract-researcher`),
- a scan produces >~30 findings to triage,
- ≥3 independent validation surfaces (→ `test-runner`).

**Tier 2 — `Workflow`-tool orchestration.** Deterministic multi-agent fan-out/pipeline for the
genuinely parallelizable sub-phase (remediation per package, triage/verify per finding, re-baselining
per surface). **Requires explicit user opt-in** (the `Workflow` tool's own contract) — so the agent
**proposes** it per `General.md` §3.5 (`never silently activate`), it is never auto-run. Propose when
ANY holds:

- ≥10 packages each need non-trivial **independent** migration/removal,
- ≥100 findings need per-finding triage/verification,
- framework remediation spans ≥5 interacting modules transformable in isolation (use worktree
  isolation when agents mutate files in parallel),
- distributed/multi-environment infrastructure (sharded search, multi-node DB) needs parallel
  environment setup or an orchestrated cutover window,
- ≥20 visual components need parallel re-baselining.

When escalating to Tier 1 or proposing Tier 2, state which threshold tripped and what gets
delegated/parallelized — never silently absorb scope growth into a running cycle. Even under Tier 2,
the stateful spine stays sequential; only the fan-out-able sub-phase is orchestrated.

---

## 11. Phase 7 — Documentation Sync (MUST)

Two durable, **separate** artifacts (`Meta.md` §2.2):

- **Running upgrade log** — the cumulative phase-by-phase record (scope, commits, blockers,
  workarounds, gate decisions, open UX calls). Maintainer/operator-facing.
- **Migration / rollout runbook** at `doc-location` — kept separate from the log: target runtime spec,
  cutover steps, **one-time migration steps** (non-versioned DB/config changes that must be replayed
  on every environment), continuity dependencies, and — when the runtime bump is decoupled — the
  deferred runtime follow-up (§14) as an explicit later step. This is what deploys the upgrade; it
  must stand alone from the change history.

---

## 12. Phase 8 — Commits (MUST)

Commit per `/core:commits` on the working branch under the resolved ticket, grouped by concern
(version bump / boot fix / remediation / schema / docs). The `release/{target}` branch reaches
mainline via PR (`General.md` §12). Confirm the deploy target before assuming the merge deploys
(`/composer:update` §9 deploy-target step).

---

## 13. Phase 9 — Handover & Reporting (MUST)

Produce the `Batch.md` §8.2 final cycle report (branch + commit ids, per-stage validation evidence,
residual risk, open decisions, **whether a decoupled runtime follow-up (§14) is still pending**,
compliance checklist from `Batch.md` §9.1) and the `Meta.md` §1.1 combined meta checkpoint. If a
framework slot was filled from discovery (no specialization existed), note it as a knowledge-
persistence candidate — it may be worth authoring a specialization or a catalog entry (self-
extension, analogous to `/composer:update` §5).

---

## 14. Post-rollout follow-up — decoupled runtime bump (conditional)

Runs **only** when Phase 4 chose the **decoupled** path. It is not part of the 0–9 cycle: the code
rollout completes and deploys first (through Phase 8/PR), then — as a separate, isolated window — the
runtime is bumped per `runtime-matrix`:

1. snapshot the DB; bump PHP/DB/platform across all runtime targets (ddev / CI / server — three
   targets, `General.md` §2.4; do not assume parity),
2. re-import/re-snapshot the DB on the new engine when its SQL-mode/charset/collation behavior can
   shift,
3. re-boot and re-run the Phase 6 validation and the framework's static/remediation suite,
4. record the outcome in the rollout runbook (§11).

Treat this follow-up as its own small gated cycle. Until it is done, the Phase 9 report MUST mark it
pending so it is not forgotten.
