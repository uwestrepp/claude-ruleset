#!/usr/bin/env bash
# Claude Code PreToolUse hook for Bash: soft-blocks `git commit` when it
# would commit denylisted paths (local overrides, scratch artifacts, secrets,
# SSH/cert material). Emits a PermissionDecision "ask" so the user is
# prompted before the commit runs.
#
# Scope: only `git commit` invocations. `git add` is not inspected; any
# accidentally staged denylisted path is caught at commit time.
# Limitation: assumes the hook CWD is the target repo. `cd other-repo && git
# commit ...` composites are not handled.
#
# Input:  JSON on stdin with tool_input containing a "command" field.
# Output: JSON on stdout to request confirmation; exit 0.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // .command // empty' 2>/dev/null || true)

[[ -z "$COMMAND" ]] && exit 0

# Only act on git commit commands.
if ! echo "$COMMAND" | grep -qE '(^|[|&;[:space:]])git[[:space:]]+commit([[:space:]]|$)'; then
    exit 0
fi

# Collect candidate paths from the index.
STAGED=$(git diff --cached --name-only 2>/dev/null || true)

# If `-a`/`-am`/`--all` is present, also include modified tracked files that
# `commit -a` would auto-stage.
if echo "$COMMAND" | grep -qE '(^|[[:space:]])(-[a-zA-Z]*a[a-zA-Z]*|--all)([[:space:]=]|$)'; then
    UNSTAGED=$(git diff --name-only 2>/dev/null || true)
    CANDIDATES=$(printf '%s\n%s\n' "$STAGED" "$UNSTAGED" | sort -u)
else
    CANDIDATES="$STAGED"
fi

[[ -z "$CANDIDATES" ]] && exit 0

# Denylist patterns (POSIX ERE, matched against full path).
# See rules/Meta.md §1.4 for .aiassistant/scratch/ convention.
PATTERNS=(
    '\.local(\.|$)'
    '(^|[/.])(override|overwrite)s?(\.|$)'
    '(^|/)id_(rsa|dsa|ecdsa|ed25519)(\.pub)?$'
    '\.(pem|p12|pfx)$'
    '(^|/)\.aws/credentials$'
    '(^|/)\.aiassistant/scratch/'
)

MATCHED=()
while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    for pat in "${PATTERNS[@]}"; do
        if echo "$path" | grep -qE "$pat"; then
            MATCHED+=("$path")
            break
        fi
    done
done <<< "$CANDIDATES"

if [[ ${#MATCHED[@]} -eq 0 ]]; then
    exit 0
fi

REASON="Commit would include denylisted paths (forbidden-stages hook; see rules/Meta.md §1.4):"
for p in "${MATCHED[@]}"; do
    REASON="$REASON"$'\n'"  - $p"
done
REASON="$REASON"$'\n\n'"Confirm you really intend to commit these before proceeding."

jq -n --arg reason "$REASON" '{
    hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "ask",
        permissionDecisionReason: $reason
    }
}'

exit 0
