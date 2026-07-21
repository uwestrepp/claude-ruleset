#!/usr/bin/env python3
"""lint-skill-files — validate local SKILL.md and rule files.

Approximates the SKILL.md frontmatter/body validator ("agnix") so the same
issues are caught at commit time instead of only when a file is opened in the
IDE. Scope mirrors the real validator: the frontmatter and body-tag checks run
on SKILL.md only. Rule files (rules/*.md) get a frontmatter-validity check only,
because they legitimately contain angle-bracket HTML in prose (<head>, <img>,
<picture>) that a body-tag check would falsely flag.

Checks (SKILL.md):
  ERROR  frontmatter missing / not closed
  ERROR  name: missing
  ERROR  argument-hint: is a bare YAML sequence ([x]) instead of a quoted string
  ERROR  description: longer than 1024 code points
  ERROR  unclosed angle-bracket tag in the body (properly closed <x>..</x> ok)
  WARN   argument-hint set but the body never references $ARGUMENTS

Checks (rules/*.md):
  ERROR  frontmatter present but does not parse as simple key: value lines

Exit 0 when no ERROR (WARN is non-blocking); exit 1 when any ERROR is found.
Stdlib only — no PyYAML dependency, so it runs in a bare git hook.
"""
import glob
import os
import re
import sys

DESC_MAX = 1024
FM_RE = re.compile(r"\A---\n(.*?)\n---\n?(.*)\Z", re.S)
KV_RE = re.compile(r"(?m)^([A-Za-z0-9_-]+):\s*(.*\S)?\s*$")
# open/close/self-closing angle-bracket token starting with a letter
TAG_RE = re.compile(r"<(/?)([A-Za-z][^\s/>]*)([^>]*?)(/?)>")

errors = []
warnings = []


def err(f, msg, line=None):
    errors.append(f"  ERROR {f}{':' + str(line) if line else ''}: {msg}")


def warn(f, msg, line=None):
    warnings.append(f"  WARN  {f}{':' + str(line) if line else ''}: {msg}")


def yaml_scalar(raw):
    """Decode a single-line YAML scalar value (quoted or plain) to its string."""
    raw = raw.strip()
    if len(raw) >= 2 and raw[0] == raw[-1] == '"':
        return raw[1:-1].replace('\\"', '"').replace("\\\\", "\\")
    if len(raw) >= 2 and raw[0] == raw[-1] == "'":
        return raw[1:-1].replace("''", "'")
    return raw


def get_field(fm, key):
    """Return the raw value string of a top-level frontmatter key, or None."""
    m = re.search(r"(?m)^" + re.escape(key) + r":\s*(.*\S)\s*$", fm)
    return m.group(1) if m else None


def check_unclosed_tags(f, body, base_line):
    """Stack-pair angle-bracket tags; report any that never close."""
    stack = []  # (name, line)
    for m in TAG_RE.finditer(body):
        closing, name, attrs, selfclose = m.groups()
        token = m.group(0)
        # skip autolinks / urls / emails — not tags
        if "://" in token or "@" in token:
            continue
        if selfclose == "/":
            continue
        line = base_line + body.count("\n", 0, m.start())
        if closing == "/":
            # pop nearest matching open
            for i in range(len(stack) - 1, -1, -1):
                if stack[i][0] == name:
                    del stack[i]
                    break
            # unmatched close tags are ignored (lenient, matches placeholder focus)
        else:
            stack.append((name, line))
    for name, line in stack:
        err(f, f'unclosed tag "<{name}>" (close it or drop the angle brackets)', line)


def rel(f):
    return f


def lint_skill(f):
    text = open(f, encoding="utf-8").read()
    m = FM_RE.match(text)
    if not m:
        err(f, "frontmatter block missing or not closed with ---")
        return
    fm, body = m.group(1), m.group(2)
    body_start_line = 2 + fm.count("\n") + 2  # after "---\n<fm>\n---\n"

    if get_field(fm, "name") is None:
        err(f, "frontmatter has no name:")

    ah_raw = get_field(fm, "argument-hint")
    if ah_raw is not None:
        if ah_raw.lstrip().startswith("["):
            err(f, f'argument-hint is a bare YAML sequence {ah_raw} — quote it: "{ah_raw}"')
        ah_val = yaml_scalar(ah_raw)
        if ah_val and "$ARGUMENTS" not in body:
            warn(f, "argument-hint set but body never references $ARGUMENTS")

    desc_raw = get_field(fm, "description")
    if desc_raw is not None and desc_raw[:1] not in (">", "|"):
        n = len(yaml_scalar(desc_raw))
        if n > DESC_MAX:
            err(f, f"description is {n} code points (max {DESC_MAX})")

    check_unclosed_tags(f, body, body_start_line)


def lint_rule(f):
    text = open(f, encoding="utf-8").read()
    m = FM_RE.match(text)
    if not m:
        return  # rule files need not have frontmatter
    fm = m.group(1)
    for ln in fm.split("\n"):
        if ln.strip() == "" or ln.startswith((" ", "\t", "-")):
            continue  # blank, nested, or list continuation
        if not KV_RE.match(ln):
            err(f, f"frontmatter line does not parse as key: value -> {ln!r}")


def main():
    root = os.getcwd()
    skills = sorted(glob.glob("plugins/marketplaces/local/plugins/*/skills/*/SKILL.md"))
    rules = sorted(glob.glob("rules/*.md"))
    for f in skills:
        lint_skill(f)
    for f in rules:
        lint_rule(f)

    for w in warnings:
        print(w)
    for e in errors:
        print(e)
    n_s, n_r = len(skills), len(rules)
    if errors:
        print(f"SKILL-LINT: {len(errors)} error(s), {len(warnings)} warning(s) "
              f"across {n_s} skills + {n_r} rule files")
        return 1
    print(f"SKILL-LINT: ok ({n_s} skills, {n_r} rule files"
          + (f", {len(warnings)} warning(s)" if warnings else "") + ")")
    return 0


if __name__ == "__main__":
    sys.exit(main())
