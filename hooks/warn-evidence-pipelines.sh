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
# Payload gate (narrows the shape match to what §5.6 actually binds): the rule
# governs echoes that ASSERT A BINARY FACT. A section separator or progress
# label ("=== post-commit ===", "--- files ---", bare `echo`, "Diff gegen X:")
# claims nothing, so it cannot be false evidence — those are allowed. Only a
# payload that reads as an assertion keeps the ASK verdict.
#
# Verdict: PermissionDecision "ask" (soft-block; false positives cost one
# user click, never a hard stop).
#
# Known false-positive classes (accepted, probe-confirmed 2026-07-16):
#   - the pattern inside quoted text: the hook sees only the raw command
#     string, so e.g. a heredoc commit body *citing* a §5.6 example triggers.
# Accepted false NEGATIVE of the payload gate: an assertion dressed as a
# separator (`echo "=== TRACKED ==="`) passes. Judged the cheaper error.
#
# Fail-open by design: if jq is missing or the input JSON is unparseable,
# COMMAND resolves empty and the hook exits 0 (allow). This is a deliberate
# §5.6 authoring-clause decision — the hook is an advisory layer, not a
# security gate; a broken hook must not block all Bash usage.
#
# Input:  JSON on stdin with tool_input containing a "command" field.
# Output: JSON on stdout to request confirmation; exit 0.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // .command // empty' 2>/dev/null || true)

[[ -z "$COMMAND" ]] && exit 0

# Pipe into an empty-input-tolerant filter, then `&&` with echo/printf, with
# no closing paren between filter and `&&` (paren = command substitution =
# the conformant test-gated form). Trailing `[^&|;]*` captures the echo
# payload so the label gate below can inspect it.
PATTERN='\|[[:space:]]*(head|tail|cat|sort|wc)([[:space:]][^|&;)]*)?&&[[:space:]]*(echo|printf)[^&|;]*'

mapfile -t MATCHES < <(printf '%s' "$COMMAND" | grep -oE "$PATTERN" || true)
[[ ${#MATCHES[@]} -eq 0 ]] && exit 0

# A payload is a separator/label — and thus outside §5.6 — when it is empty,
# opens with a run of decoration characters, or ends in a colon.
is_label() {
    local p="$1"
    [[ -z "$p" ]] && return 0
    [[ "$p" =~ ^[-=#*\>+~_]{2,} ]] && return 0
    [[ "$p" == *: ]] && return 0
    return 1
}

asserts_fact=0
for match in "${MATCHES[@]}"; do
    payload=${match#*&&}
    payload=$(printf '%s' "$payload" \
        | sed -E 's/^[[:space:]]*(echo|printf)([[:space:]]+-[a-zA-Z]+)*[[:space:]]*//; s/[[:space:]]*$//; s/^"(.*)"$/\1/; s/^'\''(.*)'\''$/\1/; s/^[[:space:]]*//; s/[[:space:]]*$//')
    if ! is_label "$payload"; then
        asserts_fact=1
        break
    fi
done

[[ $asserts_fact -eq 0 ]] && exit 0

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
