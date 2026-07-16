#!/usr/bin/env bash
# Claude Code PreToolUse hook for Bash: soft-blocks General.md §5.6
# anti-pattern shapes — a pipeline ending in a filter that exits 0 on empty
# input (head/tail/cat/sort/wc) directly followed by `&& echo`/`&& printf`.
# The success branch emits the positive signal regardless of the actual
# result, so such commands cannot serve as evidence for a binary fact.
#
# Conformant shapes are NOT flagged: a closing paren between the filter and
# `&&` indicates command substitution, i.e. the §5.6-recommended form
# `test "$(... | wc -l)" -gt 0 && echo ...` where a real test gates the echo.
#
# Verdict: PermissionDecision "ask" (soft-block; false positives cost one
# user click, never a hard stop).
#
# Input:  JSON on stdin with tool_input containing a "command" field.
# Output: JSON on stdout to request confirmation; exit 0.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // .command // empty' 2>/dev/null || true)

[[ -z "$COMMAND" ]] && exit 0

# Pipe into an empty-input-tolerant filter, then `&&` with echo/printf, with
# no closing paren between filter and `&&` (paren = command substitution =
# the conformant test-gated form).
PATTERN='\|[[:space:]]*(head|tail|cat|sort|wc)([[:space:]][^|&;)]*)?&&[[:space:]]*(echo|printf)'

if ! printf '%s' "$COMMAND" | grep -qE "$PATTERN"; then
    exit 0
fi

cat <<'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "General.md §5.6: this pipeline ends in a filter that exits 0 even on empty input (head/tail/cat/sort/wc), so the `&& echo` fires regardless of the actual result — it cannot serve as evidence. Assert on an explicit count/value instead, e.g. test \"$(... | wc -l)\" -gt 0 && echo ..."
  }
}
JSON
exit 0
