#!/usr/bin/env bash
# Regression tests for warn-evidence-pipelines.sh.
# Asserts the PreToolUse verdict (ALLOW / ASK) for representative commands.
# Run: bash hooks/tests/warn-evidence-pipelines.test.sh

set -uo pipefail
GUARD="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/warn-evidence-pipelines.sh"
fail=0

probe() {
  local expect="$1" desc="$2" cmd="$3" resp verdict mark
  resp=$(jq -Rn --arg c "$cmd" '{tool_input:{command:$c}}' | bash "$GUARD" 2>/dev/null)
  verdict="ALLOW"
  printf '%s' "$resp" | grep -q '"ask"' && verdict="ASK"
  mark="ok  "
  [[ "$verdict" != "$expect" ]] && { mark="FAIL"; fail=1; }
  printf '[%s] expect=%-6s got=%-6s  %s\n' "$mark" "$expect" "$verdict" "$desc"
}

# §5.6 anti-pattern shapes → ASK.
probe ASK   "head masks empty input"          'git ls-files docs/x.md | head -1 && echo "TRACKED"'
probe ASK   "tail variant"                    'grep foo log.txt | tail -1 && echo FOUND'
probe ASK   "wc -l variant"                   'git diff --name-only | wc -l && echo CHANGED'
probe ASK   "sort variant"                    'ls patches/ | sort && echo PRESENT'
probe ASK   "printf as positive signal"       'git ls-files p | head -1 && printf "yes\n"'

# Conformant / unrelated shapes → ALLOW.
probe ALLOW "test-gated count (conformant)"   'test "$(git ls-files p | wc -l)" -gt 0 && echo TRACKED'
probe ALLOW "grep -q gate (safe: exit signals)" 'grep -q pattern file && echo MATCH'
probe ALLOW "plain pipeline, no && echo"      'git log --oneline | head -5'
probe ALLOW "echo before pipe, not after"     'echo start && git ls-files | head -3'
probe ALLOW "filter then different command"   'ls | sort && git status'
probe ALLOW "no pipeline at all"              'echo hello && echo world'

# Separator / label payloads are not evidence claims → ALLOW.
# Sourced from real false positives reported 2026-07-31.
probe ALLOW "dashed separator"                'docker compose up -d 2>&1 | tail -20 && echo "---PS---" && docker compose ps'
probe ALLOW "equals-sign section header"      'npx renovate-config-validator 2>&1 | tail -5 && echo "=== Diff gegen origin/main ===" && git diff origin/main'
probe ALLOW "header ending in colon"          'git status -sb | head -1 && echo "--- letzter gepushter Commit:" && git log --oneline -1'
probe ALLOW "bare echo as blank line"         'grep -rn massageMarkdown lib/ | head && echo && echo "=== markdown-Util ===" && cat lib/util/markdown.ts'
probe ALLOW "sort into section header"        'find . -maxdepth 3 -name .git | sort && echo "--- CLAUDE.md ---" && find . -name CLAUDE.md'
probe ALLOW "cat into separator"              'git log --oneline a..b | cat && echo "--- files ---" && git diff --stat a b'
probe ALLOW "colon label, no decoration"      'git push -u origin feature/X 2>&1 | tail -8 && echo "Working Tree:" && git status --short'

# Assertion payloads keep firing even amid separators → ASK.
probe ASK   "assertion after a separator"     'echo "=== check ===" && git ls-files p | head -1 && echo "vorhanden"'
probe ASK   "echo -n with assertion"          'git ls-files p | head -1 && echo -n TRACKED'

exit $fail
