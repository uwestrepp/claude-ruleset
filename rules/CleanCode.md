---
paths:
   - "**/*.php"
   - "**/*.js"
   - "**/*.ts"
   - "**/*.{jsx,tsx,vue}"
   - "**/*.{css,scss}"
   - "**/*.sql"
   - "**/*.py"
   - "**/*.go"
   - "**/*.{rb,java,sh}"
---

# Clean Code – Project-Specific Overrides

Normative keywords per `General.md`. This file keeps only project-opinion rules that
are NOT already covered by model defaults (which already enforce: intent-revealing
names, small focused functions, SRP, DRY/KISS/YAGNI, limit parameters, law of
demeter, tests must be readable, etc.).

# Operating Modes (extends `General.md` §4.6)

Per `General.md` §4.6 (generation / legacy-review / uncertainty). Clean-code specifics:

- **Generation:** prefer clarity over cleverness and explicitness over implicit behavior. Non-compliance with a MUST rule below is an error.
- **Generation into an existing codebase:** where a MUST rule below conflicts with a dominant, deliberate convention of the surrounding code (for example an established fluent/chaining API vs command–query separation), the codebase convention wins (`General.md` §3.1/§3.3); state the deviation briefly instead of breaking consistency. Greenfield code follows the rules below without exception.
- **Legacy review:** identify deviations from this spec and suggest minimal, safe refactorings (do not auto-modify — `General.md` §4.6).
- **Uncertainty:** avoid assumptions about business intent; do not introduce new architectural patterns without confirmation (`General.md` §3.3).

# Architectural Cut Gate (MUST)

Before applying a change that

- introduces more than one new unit (class/module/service), OR
- relocates a responsibility boundary between existing units, OR
- touches the data schema (migration, entity, TCA, config schema),

the agent MUST name the intended cut and offer `/core:blueprint`. Auto-suggest gate per the
`General.md` §3.5 pattern: propose, never silently activate. When the cut is fully determined
by an existing codebase convention, state that instead and proceed without the offer.

The trigger is established structural scope, not task phrasing. It fires after grounding
(`General.md` §3.1), not on the wording of the request.

Before offering, check for an existing blueprint record covering the affected area
(`docs/adr/`, `.aiassistant/state/blueprint-*.md`). If one exists, read it and follow it
rather than re-deriving the cut; offer the skill only for what it does not cover.

# Project-Opinion Rules

## Use Searchable Names — replace magic numbers with constants (MUST)

Bad:
```php
if ($timeout > 300) {}
```

Good:
```php
private const SESSION_TIMEOUT_SECONDS = 300;
```

## Avoid Flag Arguments (MUST NOT)

Bad:
```php
save($user, true);
```

Better:
```php
saveActiveUser($user);
```

## Command–Query Separation (MUST)

Functions MUST either:
- Perform action, OR
- Return data.

Not both.

## No Public Mutable State (MUST)

This is an architectural rule. `PER.md` governs formatting of whatever visibility is
chosen; it does not endorse public mutable properties.

Bad:
```php
public string $name;
```

## Error Handling

### Do Not Swallow Exceptions (MUST NOT)

Bad:
```php
try { ... } catch (Exception $e) {}
```

### Provide Context in Exceptions (MUST)

Exception messages MUST describe failure clearly.

## Comments

### Prefer Self-Documenting Code (MUST)

Code clarity MUST reduce comment need.

### Acceptable Comments (MAY)

- Legal notes
- Non-obvious intent
- External constraints

### Prohibited Comments (MUST NOT)

- Commented-out code
- Redundant comments

Bad:
```php
// increment i
$i++;
```

# Meta Rule

Clean Code means:
- Easy to read.
- Easy to understand.
- Easy to change safely.

If code is difficult to understand, the agent MUST prioritize clarity: apply the improvement in code it is generating, and propose it (no silent rewrites) for existing code — per `General.md` §4.6.