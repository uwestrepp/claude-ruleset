#!/usr/bin/env bash
# Claude Code PreToolUse hook for Bash: guards destructive shell commands.
#
# Tiered, tuned for PRECISION over recall to avoid alarm fatigue (a guard that
# cries wolf gets reflex-approved or disabled, then catches nothing):
#   - HARD BLOCK (exit 2): never-legitimate catastrophes — recursive-force rm
#     whose target is the root / or home (~, $HOME) itself, or --no-preserve-root.
#   - ASK (exit 0 + permissionDecision "ask"): genuinely dangerous but sometimes
#     valid — recursive-force rm of an absolute path, a home SUBdir, or a glob;
#     bare `git push --force`/`-f`; `git reset --hard`; `git clean -f[dx]`.
#   - ALLOW (exit 0, silent): scoped relative rm (e.g. node_modules, build,
#     .aiassistant/scratch/ — Meta.md §2.4 mandates rm-ing scratch); and the
#     safer `git push --force-with-lease`/`--force-if-includes`.
#
# Input:  JSON on stdin; command at .tool_input.command (verified harness shape;
#         .command fallback for older shapes).
# Output: exit 2 + stderr {"error":...} to hard-block; or stdout ask-JSON; else
#         exit 0 silent.
# Limitation: regex over the command string after stripping heredoc bodies and
# -m/-F message args (so commit messages don't false-positive). Inline quoted
# strings elsewhere (e.g. `echo "rm -rf /"`) may still match; runtime variable
# expansion is not evaluated.
# Under permission_mode=bypassPermissions an "ask" may be auto-approved; the
# hard-block tier (exit 2) still enforces.

set -uo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // .command // empty' 2>/dev/null || true)
[[ -z "$COMMAND" ]] && exit 0

# Normalize away NON-EXECUTED text so destructive tokens inside commit messages
# or other message args can't false-positive: drop heredoc bodies (e.g.
# `git commit -F - <<'EOF' ... EOF`) and -m/--message/-F/--file arguments. We do
# NOT strip quotes globally — that would let `rm -rf "/"` evade detection.
SCAN=$(printf '%s\n' "$COMMAND" | awk '
    BEGIN { inhd = 0 }
    inhd { if ($0 ~ ("^[[:space:]]*" delim "[[:space:]]*$")) inhd = 0; next }
    {
        if (match($0, /<<[^A-Za-z0-9_]*[A-Za-z_][A-Za-z0-9_]*/)) {
            delim = substr($0, RSTART, RLENGTH)
            gsub(/[^A-Za-z0-9_]/, "", delim)
            inhd = 1
            sub(/<<.*/, "", $0)
        }
        print
    }')
SCAN=$(printf '%s' "$SCAN" | sed -E "s/(--?(m|message|F|file))[[:space:]]*('[^']*'|\"[^\"]*\"|[^[:space:]]+)/ /g")
# Drop remaining quote chars so a quoted target (rm -rf "/") can't evade the
# path patterns below. Done AFTER message-arg stripping, which needs the quotes.
SCAN=$(printf '%s' "$SCAN" | tr -d "\"'")

# grep wrapper: matches against the normalized command; -- guards patterns
# beginning with '-'.
matches() { echo "$SCAN" | grep -qE -- "$1"; }
# Case-insensitive variant — only for SQL keywords (shell subcommands are
# case-sensitive, so the rest use the case-sensitive matcher).
imatches() { echo "$SCAN" | grep -qiE -- "$1"; }

ask() {
    jq -n --arg reason "$1" '{
        hookSpecificOutput: {
            hookEventName: "PreToolUse",
            permissionDecision: "ask",
            permissionDecisionReason: $reason
        }
    }'
    exit 0
}

hard_block() {
    printf '{"error": %s}\n' "$(jq -Rn --arg m "$1" '$m')" >&2
    exit 2
}

# --- rm -rf detection -------------------------------------------------------
# Recursive AND force rm: a combined flag cluster containing both r/R and f
# (e.g. -rf, -fr, -Rfv, and the spaceless typo -rfnode_modules), OR separate
# recursive + force flags. Only when `rm` sits at a command boundary.
RM_AT_BOUNDARY='(^|[|&;(`[:space:]])rm([[:space:]]|$)'
RF_COMBINED='-[a-zA-Z]*[rR][a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*[rR]'
HAS_RECURSIVE='(-[a-zA-Z]*[rR]|--recursive)'
HAS_FORCE='(-[a-zA-Z]*f|--force)'

is_rm_recursive_force() {
    matches "$RM_AT_BOUNDARY" || return 1
    matches "$RF_COMBINED" && return 0
    { matches "$HAS_RECURSIVE" && matches "$HAS_FORCE"; } && return 0
    return 1
}

# True iff the command is a SIMPLE, single rm whose every dangerous-looking
# target is a concrete literal subpath under a SYSTEM temp root (/tmp or
# /var/tmp) — scoped scratch cleanup that cannot leak outside those roots. Used
# only to suppress the ask tier.
#
# Hardened against confirmation-prompt bypass — a token that looks like a temp
# path to us but chains/expands to a non-temp action at shell runtime, e.g.
# `rm -rf /tmp/x;reboot`, `rm -rf /tmp/x && curl e|sh`, or brace expansion
# `rm -rf /tmp/{x,/etc}`. It refuses to suppress the prompt whenever the command
# contains ANY shell control operator, expansion, brace, backslash, newline,
# $HOME/~ reference, or `..`; and each target must match a strict,
# metacharacter-free charset (no globs).
#
# The temp roots are ANCHORED at the start of the token (^/tmp/ , ^/var/tmp/),
# so a project-relative path like a Symfony app's `var/tmp` (absolute form
# /srv/app/var/tmp, or relative `var/tmp`) does NOT match and still prompts.
# Bare roots and dot-only leaves (/tmp/. , /var/tmp/..) are rejected.
safe_tmp_only() {
    # Shell metacharacters / chaining / expansion / braces → can't reason → ask.
    local META='[{}$;&|()<>`]'
    [[ "$COMMAND" =~ $META ]] && return 1
    [[ "$COMMAND" == *'\'* ]] && return 1     # backslash
    [[ "$COMMAND" == *$'\n'* ]] && return 1   # newline / multiple lines
    echo "$SCAN" | grep -qE '(~|\$HOME|\$\{HOME\}|\.\.)' && return 1

    local tokens tok
    # Danger tokens: absolute paths (start with /) or anything containing a glob.
    tokens=$(echo "$SCAN" | tr ' \t' '\n' | grep -E '(^/|\*)' || true)
    [[ -z "$tokens" ]] && return 1
    while IFS= read -r tok; do
        [[ -z "$tok" ]] && continue
        # Strict: a system temp root + one or more safe path chars, no glob.
        [[ "$tok" =~ ^(/tmp|/var/tmp)/[A-Za-z0-9._/-]+$ ]] || return 1
        # Reject dot-only leaf (…/. , …/.. , …/./) — resolves to the root itself.
        [[ "$tok" =~ ^(/tmp|/var/tmp)/[.]+/?$ ]] && return 1
    done <<< "$tokens"
    return 0
}

if is_rm_recursive_force; then
    if matches '(--no-preserve-root)'; then
        hard_block "Refused: 'rm --no-preserve-root' (recursive force) is almost never intentional. Remove the flag and target a specific path."
    fi
    # Target IS root or home itself (optionally one trailing slash, or /* ) → catastrophic.
    if matches '[[:space:]](/|/\*|~|~/|~/\*|\$HOME/?|\$\{HOME\}/?)([[:space:]]|$)'; then
        hard_block "Refused: recursive-force rm whose target is / or the home tree (~ / \$HOME). This would wipe the system or your entire home directory. Target a specific scoped path instead."
    fi
    # Absolute path, home SUBdir, or glob → dangerous but sometimes valid → ask,
    # UNLESS every such target is a scoped /tmp subpath (test-scratch cleanup).
    if matches '[[:space:]](/[A-Za-z0-9._]|~/[A-Za-z0-9._]|\$HOME/[A-Za-z0-9._]|\$\{HOME\}/)' \
       || matches '[[:space:]]\*([[:space:]]|$)'; then
        if ! safe_tmp_only; then
            ask "Destructive: recursive-force rm of an absolute path, home subdirectory, or glob. Confirm the exact target before proceeding:
  $COMMAND"
        fi
        # else: scoped /tmp or /var/tmp cleanup → allow silently.
    fi
    # Otherwise a scoped relative path (node_modules, build, scratch) → allow.
fi

# --- git push --force (bare) ------------------------------------------------
if matches 'git[[:space:]]+push'; then
    if matches '(--force-with-lease|--force-if-includes)'; then
        :   # safer form — allow silently
    elif matches '(--force([[:space:]=]|$)|[[:space:]]-[a-zA-Z]*f([[:space:]]|$))'; then
        ask "Force-push detected. Confirm the branch is correct and prefer --force-with-lease (rejects if the remote moved):
  $COMMAND"
    fi
fi

# --- git reset --hard -------------------------------------------------------
if matches 'git[[:space:]]+reset[[:space:]].*--hard'; then
    ask "git reset --hard discards uncommitted working-tree and index changes irreversibly. Confirm:
  $COMMAND"
fi

# --- git clean -f[dx] -------------------------------------------------------
if matches 'git[[:space:]]+clean[[:space:]]' \
   && matches '(-[a-zA-Z]*f|--force)' \
   && matches '(-[a-zA-Z]*[dx]|--directory)'; then
    ask "git clean -f deletes untracked files (and -d/-x untracked dirs/ignored files) irreversibly. Confirm:
  $COMMAND"
fi

# Command-position prefix: start, or after a pipe/and/or/semicolon/paren, with an
# optional sudo/doas. Prevents matching a verb that is merely a plain argument
# (e.g. `echo reboot`) while still catching `sudo reboot`, `x && reboot`, etc.
CP='(^|[|&;`(])[[:space:]]*((sudo|doas)[[:space:]]+)?'

# --- bulk deletion via find / xargs -----------------------------------------
# These indirect the delete verb, so the rm-path guard above never sees them.
if matches "${CP}find[[:space:]].*-delete([[:space:]]|$)" \
   || matches "${CP}find[[:space:]].*-exec[[:space:]]+rm([[:space:]]|$)" \
   || matches "${CP}xargs([[:space:]]+-[A-Za-z0-9]+)*[[:space:]]+rm([[:space:]]|$)"; then
    ask "Bulk deletion via find/xargs. A too-broad predicate deletes far more than intended. Confirm scope:
  $COMMAND"
fi

# --- recursive permission / ownership changes -------------------------------
if matches "${CP}(chmod|chown|chgrp)[[:space:]].*(-[A-Za-z]*R|--recursive)"; then
    ask "Recursive chmod/chown/chgrp. Original per-file modes/owners are not stored anywhere — this is effectively irreversible. Confirm the starting path:
  $COMMAND"
fi

# --- block-device / in-place destructive writes + system halt ---------------
if matches "${CP}dd[[:space:]].*of=" \
   || matches "${CP}mkfs(\.[a-z0-9]+)?([[:space:]]|$)" \
   || matches "${CP}shred([[:space:]]|$)" \
   || matches "${CP}truncate[[:space:]].*-s[[:space:]]*0([[:space:]]|$)" \
   || matches "${CP}(reboot|shutdown|poweroff|halt)([[:space:]]|$)"; then
    ask "Destructive low-level / system operation (dd of=, mkfs, shred, truncate -s 0, or reboot/shutdown). Confirm the target:
  $COMMAND"
fi

# --- container / orchestration teardown that destroys persistent state ------
# Only the data-destroying variants — safe `down`/`stop`/`ps` are untouched.
if matches "${CP}docker([[:space:]]+|-)compose[[:space:]].*down[[:space:]].*(-v([[:space:]]|$)|--volumes([[:space:]]|$))" \
   || matches "${CP}docker[[:space:]]+volume[[:space:]]+(rm|prune)" \
   || matches "${CP}docker[[:space:]]+system[[:space:]]+prune" \
   || matches "${CP}kubectl[[:space:]]+delete([[:space:]]|$)" \
   || matches "${CP}ddev[[:space:]]+delete([[:space:]]|$)"; then
    ask "Container/orchestration teardown that destroys persistent state (volumes/resources). Confirm — this can wipe DB data:
  $COMMAND"
fi

# --- git ref / stash / history destruction (beyond force/reset/clean) -------
if matches 'git[[:space:]]+branch[[:space:]].*-D([[:space:]]|$)' \
   || matches 'git[[:space:]]+push[[:space:]].*(--delete|[[:space:]]:[A-Za-z0-9_./-]+)' \
   || matches 'git[[:space:]]+stash[[:space:]]+(clear|drop)' \
   || matches 'git[[:space:]]+reflog[[:space:]]+expire' \
   || matches 'git[[:space:]]+gc[[:space:]].*--prune=(now|all)' \
   || matches 'git[[:space:]]+update-ref[[:space:]].*-d([[:space:]]|$)'; then
    ask "Irrecoverable git ref/stash/history operation (force branch delete, remote branch delete, stash clear/drop, reflog expire, or gc --prune=now). Confirm:
  $COMMAND"
fi

# --- destructive SQL via a DB client (scoped to clean keywords) -------------
# Matched on the normalized command, so DROP/TRUNCATE inside a commit message
# (heredoc/-m, already stripped) won't false-positive. Misses heredoc-fed SQL.
if imatches '(drop[[:space:]]+(database|table|schema)\b|truncate[[:space:]]+table\b)'; then
    ask "Destructive SQL (DROP DATABASE/TABLE/SCHEMA or TRUNCATE TABLE). This is immediate and usually irreversible against live data. Confirm:
  $COMMAND"
fi

exit 0
