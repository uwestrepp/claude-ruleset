---
apply: always
---

# Clean Code – Project-Specific Overrides

Normative keywords per `General.md`. This file keeps only project-opinion rules that
are NOT already covered by model defaults (which already enforce: intent-revealing
names, small focused functions, SRP, DRY/KISS/YAGNI, limit parameters, law of
demeter, tests must be readable, etc.).

---

# Operating Modes

## 1. Code Generation Mode

When creating new code:

- Comply with the rules below.
- Prefer clarity over cleverness.
- Prefer explicitness over implicit behavior.

Non-compliance with a MUST rule is considered an error.

## 2. Legacy Code Review Mode

When analyzing existing code:

- Identify deviations from this spec.
- Suggest minimal, safe refactorings.
- DO NOT automatically modify legacy code.
- Ask for confirmation before structural or behavioral changes.

## 3. When in Doubt

- Ask clarifying questions.
- Avoid assumptions about business intent.
- Avoid introducing new architectural patterns without confirmation.

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

If code is difficult to understand, the agent MUST prioritize clarity improvements.