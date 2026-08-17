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

# Variant used for the segment analysis: fold fd-duplication redirects (`2>&1`)
# away first, because their `&` would otherwise split a segment in two and hide
# its operands. Other redirects stay intact — tmp_scratch_only vets their
# targets.
SEGSCAN=$(printf '%s' "$SCAN" | sed -E 's/[0-9]*[<>]+&[0-9]*-?//g')

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

# --- command segmentation ---------------------------------------------------
# Flag detection for every verb guarded below is scoped twice over:
#   1. to a command SEGMENT — the run of tokens from a verb at a segment
#      boundary up to the next shell operator — so a flag on an unrelated
#      chained command cannot leak in (`cp -r … && rm -f …` is not a recursive
#      rm; `git clean --dry-run; tar -xzf a.tgz` is not a forced clean);
#   2. to the segment's OPTION TOKENS only, so an ARGUMENT can never be read
#      as flags.
# (2) is not hypothetical: the scratchpad root carries the project slug, e.g.
# /tmp/claude-1000/-home-uwestrepp-work-projects-gmp/…, and a substring match
# for `-[a-z]*r` happily found the `r` in `-uwestrepp`. Every plain `rm -f` of a
# scratch file under such a path was therefore classified recursive-force.

# A token is an OPTION only if it is a pure short cluster (-rf, -Rfv) or a long
# option (--force, --force-with-lease=origin/main). Anything with an internal
# dash after a single leading dash, and anything starting with `/` or `.`, is an
# operand — which is what keeps a path from being mistaken for flags.
is_option_token() {
    [[ "$1" =~ ^-[A-Za-z]+$ || "$1" =~ ^--[A-Za-z][A-Za-z0-9-]*(=.*)?$ ]]
}

# Split a segment into its whitespace tokens WITHOUT glob expansion or further
# word-splitting surprises. Sets the caller-visible array TOKENS.
tokenize() {
    TOKENS=()
    read -ra TOKENS <<< "$1"
}

# Emit each command segment whose verb matches the ERE $1 (anchored at the
# segment start, e.g. 'rm' or 'git[[:space:]]+clean'), one per line. Segments
# are delimited by the shell operators ; | & ( ) ` or newlines; a leading
# sudo/doas is stripped. Callers inspect flags and targets against these
# segments only — never the whole (possibly chained) command line.
command_segments() {
    local verb="$1" ops=';|&()`'
    printf '%s' "$SEGSCAN" | tr "$ops" '\n\n\n\n\n\n' | while IFS= read -r seg || [[ -n "$seg" ]]; do
        seg="${seg#"${seg%%[![:space:]]*}"}"                 # ltrim
        seg=$(printf '%s' "$seg" | sed -E 's/^(sudo|doas)[[:space:]]+//')
        [[ "$seg" =~ ^${verb}([[:space:]]|$) ]] || continue
        printf '%s\n' "$seg"
    done
}

# True iff any OPTION TOKEN of segment $1 matches the bash ERE $2 (short-cluster
# form; pass '' to skip) or equals one of the whitespace-separated long options
# in $3 (compared without any `=value` suffix). Scanning stops at `--`.
segment_has_option() {
    local seg="$1" short_re="$2" longs="${3:-}" tok name l i
    tokenize "$seg"
    for ((i = 1; i < ${#TOKENS[@]}; i++)); do
        tok="${TOKENS[i]}"
        [[ "$tok" == "--" ]] && break        # end of options; rest are operands
        is_option_token "$tok" || continue
        [[ -n "$short_re" && "$tok" =~ $short_re ]] && return 0
        name="${tok%%=*}"
        for l in $longs; do [[ "$name" == "$l" ]] && return 0; done
    done
    return 1
}

# Skip the blank lines a segment list can carry.
is_blank() { [[ -z "${1//[[:space:]]/}" ]]; }

# --- rm -rf detection -------------------------------------------------------
# Emit each recursive-force rm segment (one per line).
rm_rf_segments() {
    local seg
    while IFS= read -r seg; do
        is_blank "$seg" && continue
        segment_has_option "$seg" '^-[A-Za-z]*[rR]' '--recursive' || continue
        segment_has_option "$seg" '^-[A-Za-z]*f'    '--force'     || continue
        printf '%s\n' "$seg"
    done < <(command_segments 'rm')
}

# True iff every OPERAND of one recursive-force rm segment is a scoped subpath
# under a SYSTEM temp root (/tmp or /var/tmp) — scratch cleanup that cannot leak
# outside those roots. Used only to suppress the ask tier.
#
# A trailing glob IS permitted, but ONLY after a LITERAL first path segment
# (e.g. /tmp/claude-1234/scratch/* , /tmp/x/*.tmp): shell globbing cannot escape
# the named subtree (no `..`, no absolute pattern), so the blast radius stays
# inside it. A bare-root glob (/tmp/* , /var/tmp/*) and a glob on the first
# segment (/tmp/foo*) are still rejected and prompt — those could match far
# more than intended.
#
# SCOPE: the judgement covers the rm's own operands, not the whole command line.
# An earlier revision refused to suppress the prompt whenever the COMMAND held
# any shell operator, to also catch a chained non-temp action
# (`rm -rf /tmp/x;reboot`). That over-reached: `rm … ; echo done`,
# `rm … 2>/dev/null` and `rm …; git status` are the normal shape of scratch
# cleanup, so the guard prompted on nearly every one of them — the alarm fatigue
# this file's tier design exists to avoid. Chained commands are not dropped from
# scrutiny: every other rule below re-scans the full command line, so `reboot`,
# `git reset --hard`, `docker volume rm`, `dd of=` etc. still raise their OWN
# (correctly worded) prompt. What is given up is incidental coverage of a chained
# action no rule here models at all (`… && curl e|sh`) — equally unguarded when
# no rm is present, so it was never this guard's protection to offer.
#
# Still refused, because the guard cannot statically reason about them: variable
# or brace expansion ($X, ${X}, {a,b}), backslashes, ~ / $HOME / .. references, a
# redirect to anything but /dev/null, or a segment with no operand at all.
#
# The temp roots are ANCHORED at the start of the token (^/tmp/ , ^/var/tmp/),
# so a project-relative path like a Symfony app's `var/tmp` (absolute form
# /srv/app/var/tmp, or relative `var/tmp`) does NOT match and still prompts.
# Bare roots and dot-only leaves (/tmp/. , /var/tmp/..) are rejected.
tmp_scratch_only() {
    local seg="$1"
    # NOTE: '*' and '?' are deliberately NOT rejected here — a confined glob is
    # allowed by the token regex below; bracket globs ([...]) fall out via the
    # charset.
    [[ "$seg" == *'$'* || "$seg" == *'{'* || "$seg" == *'}'* ]] && return 1
    [[ "$seg" == *'\'* ]] && return 1
    [[ "$seg" == *'~'* || "$seg" == *'..'* ]] && return 1
    # Drop the one whitelisted redirect; any surviving < or > writes somewhere
    # this guard has not vetted → prompt.
    seg=$(printf '%s' "$seg" | sed -E 's|[0-9]*[<>]+[[:space:]]*/dev/null||g')
    [[ "$seg" == *'<'* || "$seg" == *'>'* ]] && return 1

    tokenize "$seg"
    local endopts=0 operands=0 i tok
    for ((i = 1; i < ${#TOKENS[@]}; i++)); do
        tok="${TOKENS[i]}"
        if [[ $endopts -eq 0 ]]; then
            [[ "$tok" == "--" ]] && { endopts=1; continue; }
            is_option_token "$tok" && continue
        fi
        operands=$((operands + 1))
        # A system temp root, a LITERAL first segment (no glob — blocks /tmp/*),
        # then any number of further segments that MAY carry a * or ? glob
        # (confined to the named subtree). Optional single trailing slash.
        [[ "$tok" =~ ^(/tmp|/var/tmp)/[A-Za-z0-9._-]+(/[A-Za-z0-9._*?-]+)*/?$ ]] || return 1
        # Reject dot-only leaf (…/. , …/.. , …/./) — resolves to the root itself.
        [[ "$tok" =~ ^(/tmp|/var/tmp)/[.]+/?$ ]] && return 1
    done
    [[ $operands -gt 0 ]]
}

# True iff EVERY recursive-force rm segment is scratch-only.
all_segments_tmp_scratch() {
    local seg
    while IFS= read -r seg; do
        is_blank "$seg" && continue
        tmp_scratch_only "$seg" || return 1
    done <<< "$RF_SEGMENTS"
    return 0
}

RF_SEGMENTS=$(rm_rf_segments)
if [[ -n "$RF_SEGMENTS" ]]; then
    # Match only within the recursive-force rm segment(s), so an unrelated
    # chained command's flags or targets can never trip these checks.
    seg_matches() { printf '%s' "$RF_SEGMENTS" | grep -qE -- "$1"; }

    if seg_matches '(--no-preserve-root)'; then
        hard_block "Refused: 'rm --no-preserve-root' (recursive force) is almost never intentional. Remove the flag and target a specific path."
    fi
    # Target IS root or home itself (optionally one trailing slash, or /* ) → catastrophic.
    if seg_matches '[[:space:]](/|/\*|~|~/|~/\*|\$HOME/?|\$\{HOME\}/?)([[:space:]]|$)'; then
        hard_block "Refused: recursive-force rm whose target is / or the home tree (~ / \$HOME). This would wipe the system or your entire home directory. Target a specific scoped path instead."
    fi
    # Absolute path, home SUBdir, or glob → dangerous but sometimes valid → ask,
    # UNLESS every such target is a scoped /tmp subpath (test-scratch cleanup).
    if seg_matches '[[:space:]](/[A-Za-z0-9._]|~/[A-Za-z0-9._]|\$HOME/[A-Za-z0-9._]|\$\{HOME\}/)' \
       || seg_matches '[[:space:]]\*([[:space:]]|$)'; then
        if ! all_segments_tmp_scratch; then
            ask "Destructive: recursive-force rm of an absolute path, home subdirectory, or glob. Confirm the exact target before proceeding:
  $COMMAND"
        fi
        # else: scoped /tmp or /var/tmp cleanup → allow silently.
    fi
    # Otherwise a scoped relative path (node_modules, build, scratch) → allow.
fi

# --- git push --force (bare) ------------------------------------------------
# NOTE: the loops below read from a process substitution, NOT a pipe, so `ask`
# (which exits) fires in this shell instead of a subshell that would be
# discarded.
while IFS= read -r seg; do
    is_blank "$seg" && continue
    # Safer forms reject if the remote moved → allow silently.
    segment_has_option "$seg" '' '--force-with-lease --force-if-includes' && continue
    if segment_has_option "$seg" '^-[A-Za-z]*f' '--force'; then
        ask "Force-push detected. Confirm the branch is correct and prefer --force-with-lease (rejects if the remote moved):
  $COMMAND"
    fi
done < <(command_segments 'git[[:space:]]+push')

# --- git reset --hard -------------------------------------------------------
while IFS= read -r seg; do
    is_blank "$seg" && continue
    if segment_has_option "$seg" '' '--hard'; then
        ask "git reset --hard discards uncommitted working-tree and index changes irreversibly. Confirm:
  $COMMAND"
    fi
done < <(command_segments 'git[[:space:]]+reset')

# --- git clean -f[dx] -------------------------------------------------------
while IFS= read -r seg; do
    is_blank "$seg" && continue
    # -n/--dry-run deletes nothing, whatever else is set.
    segment_has_option "$seg" '^-[A-Za-z]*n' '--dry-run' && continue
    segment_has_option "$seg" '^-[A-Za-z]*f' '--force'     || continue
    segment_has_option "$seg" '^-[A-Za-z]*[dx]' '--directory' || continue
    ask "git clean -f deletes untracked files (and -d/-x untracked dirs/ignored files) irreversibly. Confirm:
  $COMMAND"
done < <(command_segments 'git[[:space:]]+clean')

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
while IFS= read -r seg; do
    is_blank "$seg" && continue
    if segment_has_option "$seg" '^-[A-Za-z]*R' '--recursive'; then
        ask "Recursive chmod/chown/chgrp. Original per-file modes/owners are not stored anywhere — this is effectively irreversible. Confirm the starting path:
  $COMMAND"
    fi
done < <(command_segments '(chmod|chown|chgrp)')

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
