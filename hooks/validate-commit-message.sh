#!/usr/bin/env bash
# Claude Code PreToolUse hook: validates commit message format against Commits.md schema.
# Called with tool_input JSON on stdin. Exits 0 (allow) or 2 (block with reason).
#
# Expected input: JSON with "command" field containing the git commit command.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.command // empty' 2>/dev/null)

# Only check git commit commands
if [[ -z "$COMMAND" ]] || ! echo "$COMMAND" | grep -qE 'git\s+commit'; then
    exit 0
fi

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
