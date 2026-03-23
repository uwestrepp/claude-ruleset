---
apply: always
---

# Clean Code – AI Coding Agent Operational Specification

This document defines how the agent MUST apply Clean Code principles.

The rules in this document:

- MUST be followed for all newly generated code.
- MUST NOT be auto-applied to legacy code without confirmation.
- MUST trigger refactoring suggestions if violated in existing code.
- MUST trigger clarification questions if intent is unclear.

---

# Normative Keyword Meaning

Normative keywords are defined in `General.md` and apply here unchanged.

---

# Operating Modes

## 1. Code Generation Mode

When creating new code:

- Always comply with all rules in this document.
- Prefer clarity over cleverness.
- Prefer explicitness over implicit behavior.

Non-compliance with a MUST rule is considered an error.

---

## 2. Legacy Code Review Mode

When analyzing existing code:

- Identify deviations from this spec.
- Suggest minimal, safe refactorings.
- DO NOT automatically modify legacy code.
- Ask for confirmation before structural or behavioral changes.

---

## 3. When in Doubt

The agent MUST:

- Ask clarifying questions.
- Avoid assumptions about business intent.
- Avoid introducing new architectural patterns without confirmation.

---

# 1. Naming Rules

## 1.1 Intention-Revealing Names (MUST)

Names MUST describe purpose clearly.

Bad:
```php
$d = get();
```

Good:
```php
$activeUsers = getActiveUsers();
```

---

## 1.2 Avoid Generic Names (MUST NOT)

Do not use vague identifiers like `data`, `tmp`, `value`.

Bad:
```php
$data = process($input);
```

---

## 1.3 Avoid Type Encoding (MUST NOT)

Do not prefix names with type indicators.

Bad:
```php
$strName = "John";
$arrUsers = [];
```

Good:
```php
$name = "John";
$users = [];
```

---

## 1.4 Use Searchable Names (MUST)

Replace magic numbers with constants.

Bad:
```php
if ($timeout > 300) {}
```

Good:
```php
private const SESSION_TIMEOUT_SECONDS = 300;
```

---

## 1.5 Avoid Misleading Names (MUST)

Plural names MUST represent collections.

Bad:
```php
$user = [];
```

---

# 2. Function Rules

## 2.1 Functions Must Be Small (SHOULD)

Prefer ≤ 20 lines.

---

## 2.2 Do One Thing (MUST)

A function MUST have a single responsibility.

Bad:
```php
function registerUser($data) {
    validate($data);
    saveToDatabase($data);
    sendEmail($data);
}
```

---

## 2.3 Avoid Flag Arguments (MUST NOT)

Bad:
```php
save($user, true);
```

Better:
```php
saveActiveUser($user);
```

---

## 2.4 Limit Parameters (SHOULD)

0–2 preferred.  
3 acceptable.
>3 → introduce value object or DTO.

---

## 2.5 No Hidden Side Effects (MUST)

Functions MUST NOT modify unrelated external state.

---

## 2.6 Command–Query Separation (MUST)

Functions MUST either:
- Perform action, OR
- Return data.

Not both.

---

## 2.7 Prefer Exceptions Over Error Codes (SHOULD)

Bad:
```php
return false;
```

Good:
```php
throw new InvalidArgumentException("Invalid input");
```

---

# 3. Class Design

## 3.1 Single Responsibility Principle (MUST)

A class MUST have only one reason to change.

---

## 3.2 Small Classes (SHOULD)

Classes SHOULD be focused and cohesive.

---

## 3.3 High Cohesion (MUST)

All methods MUST relate to the class purpose.

---

## 3.4 Prefer Composition Over Inheritance (SHOULD)

Favor dependency injection over subclassing.

---

## 3.5 No Public Mutable State (MUST)

This is an architectural rule. `PER.md` governs formatting of whatever visibility is chosen; it does not endorse public mutable properties.

Bad:
```php
public string $name;
```

---

# 4. Object Principles

## 4.1 Tell, Don’t Ask (SHOULD)

Bad:
```php
if ($user->isActive()) { ... }
```

Better:
```php
$user->activate();
```

---

## 4.2 Law of Demeter (SHOULD)

Avoid deep chaining.

Bad:
```php
$order->getCustomer()->getAddress()->getZip();
```

---

## 4.3 Hide Internal Structure (MUST)

Internal data structures MUST NOT be exposed directly.

---

# 5. Error Handling

## 5.1 Do Not Swallow Exceptions (MUST NOT)

Bad:
```php
try { ... } catch (Exception $e) {}
```

---

## 5.2 Provide Context in Exceptions (MUST)

Exception messages MUST describe failure clearly.

---

## 5.3 Avoid Returning Null (SHOULD)

Prefer explicit handling or Null Object pattern.

---

# 6. Comments

## 6.1 Prefer Self-Documenting Code (MUST)

Code clarity MUST reduce comment need.

---

## 6.2 Acceptable Comments (MAY)

- Legal notes
- Non-obvious intent
- External constraints

---

## 6.3 Prohibited Comments (MUST NOT)

- Commented-out code
- Redundant comments

Bad:
```php
// increment i
$i++;
```

---

# 7. Formatting

## 7.1 Logical Vertical Separation (SHOULD)

Group related code together.

---

## 7.2 Avoid Alignment Noise (SHOULD NOT)

Avoid unnecessary column alignment.

---

## 7.3 Consistent Formatting (MUST)

Follow project formatting standards strictly.

---

# 8. Testing

## 8.1 Tests Must Be Readable (MUST)

Tests MUST express behavior clearly.

---

## 8.2 F.I.R.S.T. (SHOULD)

Tests SHOULD be:
- Fast
- Independent
- Repeatable
- Self-validating
- Timely

---

# 9. General Principles

## 9.1 DRY (MUST)

Avoid duplication.

---

## 9.2 KISS (MUST)

Prefer simple solutions.

---

## 9.3 YAGNI (MUST NOT)

Do not implement unused features.

---

## 9.4 Fail Fast (MUST)

Detect invalid states early.

---

## 9.5 Avoid Global State (MUST)

Dependencies MUST be explicit.

---

## 9.6 Immutability Preferred (SHOULD)

Prefer immutable value objects.

---

# 10. Refactoring Guidelines (Legacy Mode)

When suggesting refactors:

- Extract method for clarity.
- Extract class if multiple responsibilities exist.
- Rename unclear identifiers.
- Replace magic numbers with constants.
- Remove dead code.
- Remove duplication.
- Simplify conditionals.
- Replace conditionals with polymorphism if appropriate.

Refactor suggestions MUST:
- Be minimal.
- Preserve behavior.
- Avoid formatting-only changes unless requested.

---

# Meta Rule

Clean Code means:
- Easy to read.
- Easy to understand.
- Easy to change safely.

If code is difficult to understand, the agent MUST prioritize clarity improvements.
