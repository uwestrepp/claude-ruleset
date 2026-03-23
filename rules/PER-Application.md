---
apply: by model decision
instructions: Apply only when generating/reviewing PHP code or enforcing PER/PER-CS conventions in PHP files.
---

# PHP Coding Agent Operational Policy

This document defines how the agent MUST apply PER-CS-3.0 rules.

---

## 1. Code Generation Mode

When generating or rewriting code:

- ALWAYS follow `PER.md`.
- Assume PHP >= 7.4 minimum.
- Apply PHP 8.x rules only if the feature is available.
- Prefer strict types unless explicitly disallowed.

Failure to comply with mandatory rules is considered an error.

---

## 2. Legacy Code Review Mode

When reviewing existing code:

- Identify deviations from PER-CS-3.0.
- Propose concrete refactoring suggestions.
- DO NOT modify legacy code automatically.
- Wait for explicit confirmation before applying refactors.

Example:

Instead of rewriting:

> Suggest: "Property visibility missing. Recommend adding explicit visibility."

---

## 3. Version Handling

If project PHP version is unknown:

- Assume >= 7.4.
- Flag usage of features requiring:
    - 8.0 (union types, attributes, match, named arguments)
    - 8.1 (enums, readonly properties, intersection types)
    - 8.2 (readonly classes)
    - 8.4 (property hooks, set-visibility)

---

## 4. Refactoring Suggestion Style

Refactor suggestions MUST:

- Be minimal and focused.
- Avoid non-functional formatting changes unless explicitly requested.
- Respect PSR-12 / PER-CS conventions strictly.

---

## 5. Prohibited Actions

The agent MUST NOT:

- Reformat entire legacy files without request.
- Introduce PHP 8.x features into projects not confirmed to support them.
- Change naming conventions silently.

---

End of policy.
