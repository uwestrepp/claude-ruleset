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

# True iff every dangerous-looking target is a concrete subpath under /tmp/ —
# scoped cleanup of test scratch that cannot leak outside /tmp. Deliberately
# EXCLUDES: bare /tmp, /tmp/* (would wipe other processes' tmp files), any
# ".." traversal, and any $HOME/~ reference. Used only to suppress the ask tier.
safe_tmp_only() {
    echo "$SCAN" | grep -qE '(~|\$HOME|\$\{HOME\}|\.\.)' && return 1
    local tokens tok
    # Danger tokens: absolute paths (start with /) or anything containing a glob.
    tokens=$(echo "$SCAN" | tr ' \t' '\n' | grep -E '(^/|\*)' || true)
    [[ -z "$tokens" ]] && return 1
    while IFS= read -r tok; do
        [[ -z "$tok" ]] && continue
        case "$tok" in
            /tmp/[!*]*) ;;     # /tmp/<name>... (first char after /tmp/ not a glob)
            *) return 1 ;;
        esac
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
        # else: scoped /tmp/... cleanup → allow silently.
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

exit 0
