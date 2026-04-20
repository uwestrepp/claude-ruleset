---
apply: by model decision
instructions: Apply only when creating/editing/reviewing PHP code.
paths:
   - "**/*.php"
---

# PER Coding Style 3.0 Context for PHP Coding Agent (PHP >= 7.4)

## Operating mode for this agent (how to apply these rules)
1) **When generating or editing new code:**
    - Always follow the rules in this document.
    - If a rule depends on a PHP language feature, only apply it when that feature exists in the target PHP version(s). (This org baseline is **PHP >= 7.4**.)

2) **When reviewing existing/legacy code:**
    - If you see deviations, **recommend a refactoring** aligned with these rules.
    - **Do not change legacy code automatically**. Propose the change and wait for explicit confirmation before modifying.

3) **Uncertainty handling:**
    - If the project's PHP version range is unknown, assume **PHP 7.4+** as the minimum and **flag rules that require 8.x or 8.4**.

---

# PER Coding Style 3.0 — Focused Rule Reference

This list is focused on deviation-prone areas and is non-exhaustive. The canonical and complete PER Coding Style specification is published at https://www.php-fig.org/per/coding-style/. When in doubt, consult the canonical source.

PER-CS 3.0 requires PSR-1. Version annotations appear only when a rule depends on a language feature introduced **after PHP 7.4**.

---

## PSR-1 Baseline (binding via PER-CS 3.0)

Use `<?php ?>` or `<?= ?>` only. UTF-8 without BOM. Files SHOULD either declare symbols or have side effects, not both. Namespaces and classes MUST follow PSR-4 autoloading. Class names: PascalCase. Constants: `UPPER_CASE`. Methods: `camelCase()`. Properties: consistent casing within a package (prefer `$camelCase`).

---

## Well-Known PER-CS Baseline

The following rules are well-established and summarized for reference. Full detail is in the canonical spec.

- **Files:** LF line endings; single LF at EOF; omit closing `?>` for PHP-only files.
- **Lines:** Soft limit 120 chars; no trailing whitespace; one statement per line.
- **Indenting:** 4 spaces, no tabs.
- **Keywords/types:** Lowercase; use short forms (`int`, `bool`, `string`).
- **Header blocks:** `<?php`, `declare`, `namespace`, `use` — in that order, separated by one blank line each.
- **Imports:** No leading `\` in `use` statements.
- **Classes:** Opening brace on its own line. `extends`/`implements` on same line as class name. Visibility MUST be declared on all properties, constants, and methods. MUST NOT use `var`. One property per statement.
- **Methods/functions:** No space before `(`; braces on their own lines; no spaces inside declaration parentheses. Default params last. `&` and `...` adjacent to parameter name.
- **Control structures:** One space after keyword; braces required; no spaces inside parentheses. `elseif` (not `else if`). Boolean operators at start of line when multiline.
- **Operators:** Binary operators surrounded by at least one space. Unary `++`/`--` no space. Casts: `(int) $x`.
- **Closures:** Space after `function`; brace on same line. `use` keyword spacing per spec.
- **Anonymous classes:** Follow closure-like formatting; omit `()` after `class` when no args.
- **Arrays:** MUST use `[]` syntax; multiline: one element per line, closing `]` on own line.

---

## Deviation-Prone Rules (full detail)

### Trailing commas in multi-line lists
Single-line: no trailing comma. Multi-line: MUST have trailing comma.
```php
foo($a, $b);
foo(
    $a,
    $b,
);
```

### Acronym treatment (SHOULD)
Treat acronyms like words: `Http`, `Url`, `Json` — not `HTTP`, `URL`, `JSON`.

### Compound types formatting (8.0+/8.1+)
No surrounding spaces around `|` and `&`. When multiline, operator at start of line.
```php
function f(int|string $x): User|Product {}
function g(
    \ReflectionObject
    |\ReflectionClass $r
): object|null {}
```

### Grouped imports depth limit
In `use Vendor\X\{...}`, MUST NOT nest more than two sub-namespaces inside the group.

### `declare(strict_types=1)` formatting
MUST be exactly `declare(strict_types=1)` (no spaces). In mixed markup: `<?php declare(strict_types=1) ?>` on first line.

### Instantiation parentheses
`new Foo()` MUST include parentheses even with no args. SHOULD NOT wrap in parentheses when immediately accessing members: `new Foo()->bar()`.

### Empty bodies (SHOULD)
Empty class bodies and empty/no-op method bodies SHOULD use `{}` on the same line.
```php
class MyException extends \RuntimeException {}
public function __construct(private int $x) {}
```

### Traits
`use Trait;` immediately after `{`; one trait per `use` statement; blank line after trait block before other members.

### Modifier keyword order
Modifiers MUST appear in this order, same line, single spaces, lowercase: `final`/`abstract`, visibility, `static`, `readonly` (8.1+), set-visibility (8.4+).
```php
final public static function run(): void {}
private readonly int $id;
```

### Named arguments spacing (8.0+)
No space around `name:`; exactly one space after colon: `f(a: 1, b: $b)`.

### Method chaining line breaks
First method call on next line; subsequent lines indented once.
```php
$builder
    ->create()
    ->prepare()
    ->run();
```

### `exit()` / `die()` parentheses (SHOULD)
SHOULD be called with parentheses even with no args.

### Callable references (8.1+)
`foo(...)` MUST NOT contain whitespace within the `...` token.

### Operator placement when splitting lines
Operator MUST be at beginning of new line. Ternary MUST be 3 lines.
```php
$result = $a
    ?? $b;
$v = $c
    ? 'fizz'
    : 'buzz';
```

### `switch` fall-through + `match` (8.0+)
Fall-through in non-empty `case` MUST have comment like `// no break`. `match` formatting:
```php
$result = match ($x) {
    1 => 'one',
    default => 'other',
};
```

### Enumerations (8.1+)
Follow class rules. Non-public methods MUST use `private`. Backed enum: `enum E: type`. Cases: PascalCase. Constants: PascalCase preferred (UPPER_CASE also allowed).
```php
enum Suit: string
{
    case Hearts = 'H';

    private function helper(): void {}
}
```

### Heredoc and nowdoc
Prefer nowdoc. Declaration on same line as context. Subsequent lines indented one level past declaring scope.
```php
$n = <<<'TXT'
    Hello
    TXT;
```

### Attributes (8.0+)
No space after `#[`; omit `()` if no args. Attributes on their own line before target. Parameter attributes inline for single-line params; on own line for multiline params. Docblocks come before attributes with no blank line. Multiple attributes: `#[A, B]` or separate blocks. Multiline args force attribute alone in its block.
```php
/** Doc */
#[MyAttr]
function f(#[A] int $x) {}
```
```php
#[Complex(
    a: 1,
    b: 2,
)]
#[Other]
function f(): void {}
```

### Property hooks (8.4+)
```php
public string $name {
    get {
        return $this->values[__PROPERTY__];
    }

    set {
        $this->values[__PROPERTY__] = $value;
    }
}
```
Abstract/interface properties: specify get/set/both; semicolon after hook keyword; get before set.
```php
interface I
{
    public string $readable { get; }
    public string $both { get; set; }
}
```
