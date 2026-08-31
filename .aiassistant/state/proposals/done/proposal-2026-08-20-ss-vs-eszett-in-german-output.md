# Name the ß-vs-ss choice explicitly in the German orthography rule

```
Date:         2026-08-20
Status:       superseded
Superseded by: .aiassistant/state/proposals/proposal-2026-08-31-verification-reach-consolidation.md
Origin:       user correction — an entire German documentation set was written in the
              Swiss ss spelling without any rule, gate or spellchecker objecting
Revisit when: the next German-language project starts, or the next
              /core:rule-friction cycle, whichever comes first
```

## Problem

`/core:communication` §2 and the `General.md` §8.2 kernel both require "full
orthographic correctness including umlauts and ß", and both illustrate it with the
same kind of example: `für`, not `fur`; `löschen`, not `loeschen`. Every example
targets **ASCII substitution**.

The Swiss `ss` spelling is a different failure. `heisst`, `grösser`,
`erfahrungsgemäss`, `Grössenordnung` are not ASCII substitutions and not typos: they
are orthographically valid German, they carry every diacritic the rule asks for, and
no spellchecker flags them. So the rule reads as satisfied while the register is
wrong, and nothing in the loop objects.

It got through an entire documentation set. In the MO Shopify project, `docs/`
carried roughly 67 `ss`-variant occurrences against 5 uses of `ß` before the user
noticed, including two colleague-facing attachments prepared for a customer-facing
answer. The user's correction, verbatim:

> "normalerweise sollten immer Umlaute und ß in der Kommunikation nach außen genutzt
> werden, das sieht sonst unnatürlich aus."

The mechanism is the one §8.5 fights in a different guise: once the surrounding
material uses a form, matching it beats recalling the rule. Here it is worse than
with the em-dash, because the wrong form is *correct German* and therefore produces
no signal at all.

## Proposed change

`/core:communication` §2, in the "Prose typography" or "Language mapping" paragraph
where "including umlauts and ß" already stands. Add one sentence with the actual
contrast, and one carve-out:

- German output uses `ß`, never the Swiss `ss` variant: `heißt`, `größer`, `außen`,
  `erfahrungsgemäß`. This is a register choice, not a spelling error, which is why
  it needs stating: the `ss` form is valid German and no checker objects.
- Carve-out: a recipient in Switzerland or Liechtenstein inverts this. Record the
  exception in that project's `CLAUDE.md` per §9 rather than deciding it per
  document.

`General.md` §8.2 needs no edit. It keeps only the kernel by design and already says
"including umlauts and ß"; the full rule belongs in the skill per the authority split
stated at the top of that skill. **The always-on surface therefore does not grow**
(`Meta.md` §3.3).

## Expected impact

Closes a gap that is invisible from the inside. The failure is not carelessness about
a known rule but a rule whose examples never test the case that actually occurs, so
re-reading the rule does not help — only naming the contrast does.

Cheap where it lands: one sentence in a skill that loads only when colleague-facing
output is being produced, which is exactly the moment it is needed.

## Risk / tradeoff

- **No always-on token cost.** The change is in the skill, not in a `[CRITICAL]` file.
- **Swiss recipients are a real exception**, not a hypothetical: MOSAIQ and Funntastic
  both have DACH reach. Without the carve-out the rule would be wrong for them, which
  is why the proposal names it rather than leaving it implicit.
- **Not mechanically enforceable as cheaply as the em-dash gate.** A U+2014 match is
  unambiguous; `ss` is not, because `dass`, `muss`, `Prozess` and `müssen` are always
  `ss`. A gate would need a stem list (`heisst`, `gross`, `ausser`, `weiss`, `gemäss`,
  `schliess`, `Fuss`, `draussen`, `Massnahme`, `grösse`), which catches the frequent
  cases but is not complete. If `proposal-2026-08-17-em-dash-gate.md` ships, that
  hook is the natural host for such a list; until then this stays an attention rule,
  and that limitation belongs in the proposal rather than in a promise.
- Existing `ss` text is not worth a mass conversion. Better guidance, applied in the
  MO project: convert a passage when touching it anyway, and say so in the project's
  `CLAUDE.md` so the mixed state is explained rather than looking accidental.

## Evidence

- 2026-08-20, `~/work/projects/shopify/MO`, ticket MO-101. Corrected in commit
  `05a715e`, which also records the convention in the project's `CLAUDE.md` under the
  overrides. The same commit carries a second, unrelated inference error found in the
  same proof-reading pass: the user's initials had been derived from their name (`US`
  instead of the official `USP`), 44 occurrences.
- Both facts persisted as auto-memory for that project:
  `write-ss-scharf-not-ss.md` (type `feedback`) and `usp-is-the-users-initials.md`
  (type `user`).
- The affected text was not a draft. It included
  `.aiassistant/state/ticket-anhaenge/MO-101_2026-08-20_Aufwandsschaetzung_intern.md`,
  the document answering the customer's question about whether the platform choice
  still holds, which is the least suitable place for prose that reads as machine-set.
