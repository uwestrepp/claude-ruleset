#!/usr/bin/env bash
# Regression tests for guard-pipefail-gates.sh.
# Asserts the PreToolUse verdict (ALLOW / ASK) for representative Write/Edit
# payloads. Run: bash hooks/tests/guard-pipefail-gates.test.sh

set -uo pipefail
GUARD="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/guard-pipefail-gates.sh"
fail=0

# probe <expect> <desc> <file_path> <content>
probe() {
  local expect="$1" desc="$2" path="$3" body="$4" resp verdict mark
  resp=$(jq -Rn --arg p "$path" --arg c "$body" \
      '{tool_input:{file_path:$p,content:$c}}' | bash "$GUARD" 2>/dev/null)
  verdict="ALLOW"
  printf '%s' "$resp" | grep -q '"ask"' && verdict="ASK"
  mark="ok  "
  [[ "$verdict" != "$expect" ]] && { mark="FAIL"; fail=1; }
  printf '[%s] expect=%-6s got=%-6s  %s\n' "$mark" "$expect" "$verdict" "$desc"
}

UNGUARDED_AND='#!/usr/bin/env bash
git ls-files docs/ | head -1 && run_migration'
GUARDED_AND='#!/usr/bin/env bash
set -euo pipefail
git ls-files docs/ | head -1 && run_migration'
UNGUARDED_IF='#!/bin/bash
if git diff --name-only | wc -l; then
  deploy
fi'
CONFORMANT='#!/usr/bin/env bash
test "$(git ls-files p | wc -l)" -gt 0 && run_migration'

# Missing pipefail on a status-gating pipeline → ASK.
probe ASK   "shell script, && gate, no pipefail"  "/repo/bin/deploy.sh"          "$UNGUARDED_AND"
probe ASK   "if-condition gate, no pipefail"      "/repo/bin/check.sh"           "$UNGUARDED_IF"
probe ASK   "git hook without extension"          "/repo/.githooks/pre-commit"   "$UNGUARDED_AND"
probe ASK   "bitbucket pipeline"                  "/repo/bitbucket-pipelines.yml" "$UNGUARDED_AND"
probe ASK   "gitlab CI"                           "/repo/.gitlab-ci.yml"         "$UNGUARDED_AND"
probe ASK   "|| gate counts too"                  "/repo/bin/x.sh"               'git ls-files p | head -1 || exit 1'

# Protected, conformant, or out of scope → ALLOW.
probe ALLOW "pipefail set in same write"          "/repo/bin/deploy.sh"          "$GUARDED_AND"
probe ALLOW "test-gated substitution"             "/repo/bin/deploy.sh"          "$CONFORMANT"
probe ALLOW "pipeline, but nothing gated on it"   "/repo/bin/deploy.sh"          'git log --oneline | head -5'
probe ALLOW "actions: shell bash implies pipefail" "/repo/.github/workflows/ci.yml" 'shell: bash
run: git ls-files p | head -1 && deploy'
probe ALLOW "non-shell file, same body"           "/repo/src/README.md"          "$UNGUARDED_AND"
probe ALLOW "python file, same body"              "/repo/tools/run.py"           "$UNGUARDED_AND"
probe ALLOW "no file_path in payload"             ""                             "$UNGUARDED_AND"

# Edit payload: pipefail lives in the file on disk, not in new_string.
tmp=$(mktemp -d)
printf '%s\n' '#!/usr/bin/env bash' 'set -euo pipefail' > "$tmp/existing.sh"
resp=$(jq -Rn --arg p "$tmp/existing.sh" --arg s 'ls | sort && deploy' \
    '{tool_input:{file_path:$p,old_string:"x",new_string:$s}}' | bash "$GUARD" 2>/dev/null)
verdict="ALLOW"; printf '%s' "$resp" | grep -q '"ask"' && verdict="ASK"
mark="ok  "; [[ "$verdict" != "ALLOW" ]] && { mark="FAIL"; fail=1; }
printf '[%s] expect=%-6s got=%-6s  %s\n' "$mark" "ALLOW" "$verdict" "edit: pipefail already on disk"

printf '%s\n' '#!/usr/bin/env bash' 'echo start' > "$tmp/bare.sh"
resp=$(jq -Rn --arg p "$tmp/bare.sh" --arg s 'ls | sort && deploy' \
    '{tool_input:{file_path:$p,old_string:"x",new_string:$s}}' | bash "$GUARD" 2>/dev/null)
verdict="ALLOW"; printf '%s' "$resp" | grep -q '"ask"' && verdict="ASK"
mark="ok  "; [[ "$verdict" != "ASK" ]] && { mark="FAIL"; fail=1; }
printf '[%s] expect=%-6s got=%-6s  %s\n' "$mark" "ASK" "$verdict" "edit: no pipefail anywhere"
rm -rf "$tmp"

exit $fail
