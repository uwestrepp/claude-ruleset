---
apply: by model decision
instructions: Apply only when generating or reviewing code.
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

---

# Operating Modes (extends `General.md` §4.6)

Per `General.md` §4.6 (generation / legacy-review / uncertainty). Clean-code specifics:

- **Generation:** prefer clarity over cleverness and explicitness over implicit behavior. Non-compliance with a MUST rule below is an error.
- **Legacy review:** identify deviations from this spec and suggest minimal, safe refactorings (do not auto-modify — `General.md` §4.6).
- **Uncertainty:** avoid assumptions about business intent; do not introduce new architectural patterns without confirmation (`General.md` §3.3).

---

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

---

# Meta Rule

Clean Code means:
- Easy to read.
- Easy to understand.
- Easy to change safely.

If code is difficult to understand, the agent MUST prioritize clarity: apply the improvement in code it is generating, and propose it (no silent rewrites) for existing code — per `General.md` §4.6.