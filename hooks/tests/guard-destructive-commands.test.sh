#!/usr/bin/env bash
# Regression tests for guard-destructive-commands.sh.
# Asserts the PreToolUse verdict (ALLOW / ASK / HARD-BLOCK) for representative
# commands. Run: bash hooks/tests/guard-destructive-commands.test.sh
#
# Covers the segment-scoping fix: recursive/force flags must belong to the rm
# invocation itself, not leak from an unrelated chained command.

set -uo pipefail
GUARD="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/guard-destructive-commands.sh"
fail=0

probe() {
  local expect="$1" desc="$2" cmd="$3" resp rc verdict mark
  resp=$(jq -Rn --arg c "$cmd" '{tool_input:{command:$c}}' | bash "$GUARD" 2>/dev/null); rc=$?
  verdict="ALLOW"
  [[ $rc -eq 2 ]] && verdict="HARD-BLOCK"
  printf '%s' "$resp" | grep -q '"ask"' && verdict="ASK"
  mark="ok  "
  [[ "$verdict" != "$expect" ]] && { mark="FAIL"; fail=1; }
  printf '[%s] expect=%-10s got=%-10s  %s\n' "$mark" "$expect" "$verdict" "$desc"
}

# Flags on a chained non-rm command must NOT make a plain rm look recursive.
probe ALLOW      "rm -f force only"                       'rm -f /tmp/x'
probe ALLOW      "cp -r … && rm -f … (-r on cp)"          'cp -r a b && rm -f /tmp/x'
probe ALLOW      "grep -rl … && rm -f … (-r on grep)"     'grep -rl pat . && rm -f /tmp/x'
probe ALLOW      "ls -R …; rm -f …; rm -f …"              'ls -R d; rm -f /tmp/a; rm -f /tmp/b'
probe ALLOW      "literal rm -rf inside a grep arg"       'grep -rln "rm -rf" .claude/'
probe ALLOW      "literal rm -rf inside an echo string"   'echo "use rm -rf to wipe"'

# Real recursive-force catastrophes — must hard-block on the rm's own target.
probe HARD-BLOCK "rm -rf /"                               'rm -rf /'
probe HARD-BLOCK "sudo rm -rf /"                          'sudo rm -rf /'
probe HARD-BLOCK "rm -rf \$HOME"                          'rm -rf $HOME'
probe HARD-BLOCK "rm -rf ~/"                              'rm -rf ~/'
probe HARD-BLOCK "real rm -rf / later in a chain"         'cp -r a b && rm -rf /'
probe HARD-BLOCK "rm --no-preserve-root -rf /etc"         'rm --no-preserve-root -rf /etc'

# Dangerous-but-sometimes-valid — must ask.
probe ASK        "rm -rf absolute subpath"               'rm -rf /etc/foo'
probe ASK        "rm -rf glob"                           'rm -rf /var/www/*'

# Scoped relative / system-temp scratch — must allow.
probe ALLOW      "rm -rf relative dir"                   'rm -rf node_modules'
probe ALLOW      "rm -rf /tmp scratch"                   'rm -rf /tmp/scratch123'

echo
if [[ $fail -eq 0 ]]; then echo "ALL PASS"; else echo "SOME FAILED"; fi
exit $fail
