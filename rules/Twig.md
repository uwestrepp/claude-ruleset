---
paths:
   - "**/*.twig"
---

# Twig Template Rules

Normative keywords per `General.md`.

## 1. Suppress rendering with `{# #}`, not target-format comments (MUST)

Twig evaluates `{{ }}`, `{% %}`, and `{# #}` before the consumer sees the
output. A line "commented" in the target format (`#` in shell/env/INI/YAML,
`//` in JS, `<!-- -->` in HTML, `;` in INI, `--` in SQL) is still rendered —
so a missing variable, exception, expensive lookup, or mutation inside `{{ }}`
still fires.

```twig
#SOLR_USERNAME={{ environment.get('SOLR_USERNAME')|raw }}   {# WRONG: still evaluated, can throw #}
{# SOLR_USERNAME={{ environment.get('SOLR_USERNAME')|raw }} #}   {# RIGHT: skipped before render #}
```

Most common when rendering into `.env`, `.conf`, `.ini`, YAML, or SQL. When
unsure whether a `{{ }}` is render-safe on a target-commented line, wrap the
whole line in `{# #}`.

## 2. Prefer deletion over `{# #}` shelving (SHOULD)

`{# #}` is for suppressing the §1 trap, not for parking dead code. Delete dead
Twig outright (`CleanCode.md` prohibits commented-out code); shelve in `{# #}`
only when reactivation is concretely tracked (ticket, design note).
