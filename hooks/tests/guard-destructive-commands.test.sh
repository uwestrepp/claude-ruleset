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

# Single recursive-OR-force rm (NOT both) is not a recursive-force rm → allow.
probe ALLOW      "rm -r only (no force)"                 'rm -r /tmp/claude-1/scratch/dir'
probe ALLOW      "rm -f only (no recursive)"             'rm -f /etc/foo'

# Scoped relative / system-temp scratch — must allow.
probe ALLOW      "rm -rf relative dir"                   'rm -rf node_modules'
probe ALLOW      "rm -rf /tmp scratch"                   'rm -rf /tmp/scratch123'

# Scoped /tmp cleanup WITH a glob confined to a literal subtree — must allow.
probe ALLOW      "rm -rf /tmp scratch glob"              'rm -rf /tmp/claude-1234/scratch/*'
probe ALLOW      "rm -f /tmp scratch suffix glob"        'rm -f /tmp/claude-1234/scratch/*.tmp'
probe ALLOW      "rm -rf multiple /tmp globs"            'rm -rf /tmp/claude-1234/a/* /tmp/claude-1234/b/*'
# But a bare-root or first-segment /tmp glob is too broad — must ask.
probe ASK        "rm -rf bare /tmp glob"                 'rm -rf /tmp/*'
probe ASK        "rm -rf glob on first /tmp segment"     'rm -rf /tmp/foo*'

# --- Reported false positives: scratchpad cleanup ---------------------------
# The session scratchpad root carries the project slug, so its path holds
# dash-prefixed segments (…/-home-uwestrepp-work-projects-gmp/…). Flag detection
# must read OPTION TOKENS only — a substring scan finds an `r` in `-uwestrepp`
# and turns every plain `rm -f` there into a "recursive-force" verdict.
SP=/tmp/claude-1000/-home-uwestrepp-work-projects-gmp/70f2bc5d-6130-49c2/scratchpad
probe ALLOW      "rm -f scratchpad file (dash-slug path)"  "rm -f $SP/commit-msg.txt"
probe ALLOW      "rm -f scratchpad glob + chained echo"    "rm -f $SP/bs-full.* 2>/dev/null; echo cleaned"
probe ALLOW      "rm -rf scratchpad + chained git"         "rm -rf $SP/verify-*.php $SP/twiglint; git status --porcelain"
probe ALLOW      "rm -f scratchpad on its own line"        "git status -sb
rm -f $SP/commit-msg.txt"
probe ALLOW      "ssh-wrapped /tmp cleanup, chained"       "ssh rom 'rm -rf /tmp/gmp342-body /tmp/gmp342-proxy; ls /tmp' | tail -3"
# The same path with the dash segment removed must behave identically —
# the verdict must not depend on the username in the path.
probe ALLOW      "control: same shape, no dash segment"    'rm -f /tmp/claude-1000/abc/scratchpad/bs-full.*; echo cleaned'

# --- Chaining and redirects no longer suppress the /tmp allowance -----------
probe ALLOW      "rm -rf /tmp scratch, 2>/dev/null"      'rm -rf /tmp/claude-1/scratch/x 2>/dev/null'
probe ALLOW      "rm -rf /tmp scratch, >/dev/null 2>&1"  'rm -rf /tmp/claude-1/scratch/x >/dev/null 2>&1'
probe ALLOW      "rm -rf /tmp scratch, -- end of opts"   'rm -rf -- /tmp/claude-1/scratch/x'

# --- …but the operands themselves are still fully vetted --------------------
probe ASK        "brace expansion escaping /tmp"         'rm -rf /tmp/{x,/etc}'
probe ASK        "variable in the /tmp target"           'rm -rf /tmp/claude-1/$FOO'
probe ASK        "parent traversal out of /tmp"          'rm -rf /tmp/x/../../etc'
probe ASK        "redirect to a non-/dev/null target"    'rm -rf /tmp/claude-1/x > /etc/passwd'
probe ASK        "second rm segment leaves /tmp"         'rm -rf /tmp/claude-1/x; rm -rf /srv/data'
probe HARD-BLOCK "second rm segment targets /"           'rm -rf /tmp/claude-1/x; rm -rf /'
probe ASK        "long-form --recursive --force"         'rm --recursive --force /etc/foo'
probe ASK        "operands after -- still checked"       'rm -rf -- /etc/foo'
# A chained command that is dangerous in its OWN right still raises its own
# prompt — the rm allowance never suppresses another rule.
probe ASK        "chained reboot after /tmp cleanup"     'rm -rf /tmp/claude-1/scratch/x; reboot'
probe ASK        "chained git reset --hard"              'rm -rf /tmp/claude-1/scratch/x; git reset --hard'

# --- Same defect class in the non-rm rules ----------------------------------
# Flags must come from the guarded verb's OWN segment, never harvested from
# anywhere on the line.
probe ALLOW      "git clean dry-run"                     'git clean -n'
probe ALLOW      "git clean dry-run, -d"                 'git clean -nd'
probe ALLOW      "git clean -nfd is still a dry run"     'git clean -nfd'
probe ALLOW      "git clean -nd; grep -rf … (-f on grep)"    'git clean -nd; grep -rf pattern .'
probe ALLOW      "git clean --dry-run; tar -xzf (-f on tar)" 'git clean --dry-run; tar -xzf a.tgz'
probe ASK        "real git clean -fd"                    'git clean -fd'
probe ASK        "real git clean --force --directory"    'git clean --force --directory'

probe ALLOW      "git push plain"                        'git push origin main'
probe ALLOW      "git push; tar -xzf (-f on tar)"        'git push origin main; tar -xzf a.tgz'
probe ALLOW      "git push --force-with-lease"           'git push --force-with-lease origin main'
probe ALLOW      "git push --force-with-lease=origin/x"  'git push --force-with-lease=origin/main main'
probe ASK        "real git push -f"                      'git push -f origin main'
probe ASK        "real git push --force"                 'git push --force origin main'

probe ALLOW      "chown non-recursive"                   'chown www-data:www-data /var/www/html/f.txt'
probe ALLOW      "chown …; ls -R … (-R on ls)"           'chown www-data /var/www/f.txt; ls -R /var/www'
probe ALLOW      "chmod a-rwx (mode is not a flag)"      'chmod a-rwx /var/www/f.txt'
probe ASK        "real chown -R"                         'chown -R www-data /var/www'
probe ASK        "real chmod -R"                         'chmod -R 755 /var/www'
probe ASK        "real chmod 755 -R (flag after mode)"   'chmod 755 -R /var/www'

echo
if [[ $fail -eq 0 ]]; then echo "ALL PASS"; else echo "SOME FAILED"; fi
exit $fail
