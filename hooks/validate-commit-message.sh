#!/usr/bin/env bash
# Claude Code PreToolUse hook: validates commit message format against the
# /core:commits schema. Exits 0 (allow) or 2 (block with reason).
#
# SCOPE: enforces only for repositories under ~/work, where real project work
# lives. Other repos — notably ~/.claude itself, which uses a bare "AGENT"
# pseudo-ticket convention that does not match the JIRA-123 schema — are
# intentionally exempt and pass through untouched.
#
# Input: PreToolUse JSON on stdin; command at .tool_input.command (.command
# fallback), working dir at .cwd.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // .command // empty' 2>/dev/null)

# Only check git commit commands.
if [[ -z "$COMMAND" ]] || ! echo "$COMMAND" | grep -qE 'git\s+commit'; then
    exit 0
fi

# Enforce only within ~/work — resolve the repo root from the tool's cwd.
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
[[ -z "$CWD" ]] && CWD="$PWD"
REPO_ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null || echo "$CWD")
case "$REPO_ROOT/" in
    "$HOME"/work/*) ;;   # under ~/work → enforce
    *) exit 0 ;;         # elsewhere → exempt
esac

# Extract the commit message from -m flag or heredoc pattern
# Pattern 1: git commit -m "message" or git commit -m 'message'
# Pattern 2: git commit -m "$(cat <<'EOF' ... EOF )"
MSG=""

# Try to extract from heredoc pattern first (most common in this workflow)
if echo "$COMMAND" | grep -q 'EOF'; then
    MSG=$(echo "$COMMAND" | sed -n '/<<.*EOF/,/EOF/p' | grep -v 'EOF' | grep -v '<<' | head -1 | sed 's/^[[:space:]]*//')
fi

# Fall back to -m "..." extraction
if [[ -z "$MSG" ]]; then
    MSG=$(echo "$COMMAND" | grep -oP '(?<=-m\s)["\x27]([^"\x27]*)["\x27]' | head -1 | tr -d "\"'" 2>/dev/null || true)
fi

# If we couldn't extract a message, allow (might be interactive or --amend)
if [[ -z "$MSG" ]]; then
    exit 0
fi

# Extract first line (subject) only
SUBJECT=$(echo "$MSG" | head -1 | sed 's/^[[:space:]]*//')

# Validate against Commits.md regex
REGEX='^\[(FEAT|FIX|BUILD|CHORE|CI|DOCS|STYLE|REFACTOR|PERF|TEST)\] [A-Z]+-[0-9]+ \([a-z0-9._/-]+\) .+'

if echo "$SUBJECT" | grep -qP "$REGEX"; then
    exit 0
else
    echo '{"error": "Commit message subject does not match required format: [{TYPE}] JIRA-123 (scope) summary. See Commits.md for the full schema."}' >&2
    exit 2
fi
