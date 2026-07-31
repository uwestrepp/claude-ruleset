#!/usr/bin/env bash
# Claude Code PreToolUse hook for Write/Edit: soft-blocks the General.md §5.6
# AUTHORING clause — authored shell/hook/CI code in which a downstream filter
# (head/tail/cat/sort/wc) masks the producer's exit status *where that status
# gates behavior*, while the file sets no `pipefail`.
#
# Sibling of warn-evidence-pipelines.sh, deliberately split by clause:
#   - warn-evidence-pipelines.sh guards the EVIDENCE clause on ad-hoc Bash
#     (an `&& echo` asserting a binary fact),
#   - this hook guards the AUTHORING clause on files the agent writes.
# Ad-hoc commands are intentionally out of scope here: `cmd 2>&1 | tail -20`
# keeps the error text visible in the output the agent reads, so a swallowed
# status is not silently load-bearing there. In a committed gate it is.
#
# Fires only when ALL hold:
#   1. target is shell or CI code (see FILE case below),
#   2. the written text contains a pipeline ending in an empty-tolerant filter
#      whose exit status gates control flow (`&&`, `||`, or `if`/`while`/`until`
#      condition) — a closing paren before the gate means command substitution
#      and is NOT a status gate,
#   3. neither the written text nor the file on disk sets `pipefail`
#      (GitHub Actions `shell: bash` counts — it implies `-eo pipefail`).
#
# Known gaps (deliberate, to keep the false-positive rate at zero):
#   - a pipeline as the last command of a function/script, where its status
#     becomes the return value, is not detected,
#   - Makefile recipes (every recipe line is its own gate) are out of scope.
#
# Verdict: PermissionDecision "ask" (soft-block). Fail-open by design: missing
# jq or unparseable input resolves FILE empty and exits 0 — an advisory layer
# must not block all edits when broken.
#
# Input:  JSON on stdin with tool_input.file_path plus content/new_string.
# Output: JSON on stdout to request confirmation; exit 0.

set -euo pipefail

INPUT=$(cat)
FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)

[[ -z "$FILE" ]] && exit 0

case "$FILE" in
    *.sh|*.bash|*/.githooks/*|*/.husky/*) ;;
    */bitbucket-pipelines.yml|bitbucket-pipelines.yml) ;;
    */.gitlab-ci.yml|.gitlab-ci.yml) ;;
    */.github/workflows/*.yml|*/.github/workflows/*.yaml) ;;
    *) exit 0 ;;
esac

# Write carries the whole file in .content; Edit carries only the replacement.
NEW=$(printf '%s' "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null || true)
[[ -z "$NEW" ]] && exit 0

FILTER='(head|tail|cat|sort|wc)'
# Pipeline into the filter, then `&&`/`||`. Excluding `)` from the argument run
# keeps `test "$(... | wc -l)" -gt 0 && ...` (conformant) out.
GATE_LIST="\|[[:space:]]*${FILTER}([[:space:]][^&;)|]*)?(&&|\|\|)"
# Same pipeline as an if/while/until condition.
GATE_COND="(^|;|&&|\|\||then|do)[[:space:]]*(if|while|until)[[:space:]][^;)]*\|[[:space:]]*${FILTER}([[:space:]][^;)]*)?;"

gated=0
printf '%s' "$NEW" | grep -qE "$GATE_LIST" && gated=1
printf '%s' "$NEW" | grep -qE "$GATE_COND" && gated=1
[[ $gated -eq 0 ]] && exit 0

# `set -euo pipefail`, `set -o pipefail`, or an Actions step declaring bash.
PROTECT='set[[:space:]]+-[a-zA-Z]*o[[:space:]]+pipefail|shell:[[:space:]]*bash'

protected=0
printf '%s' "$NEW" | grep -qE "$PROTECT" && protected=1
[[ $protected -eq 0 && -f "$FILE" ]] && grep -qE "$PROTECT" "$FILE" && protected=1
[[ $protected -eq 1 ]] && exit 0

cat <<'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "General.md §5.6 (authoring clause): this file gates control flow on a pipeline ending in head/tail/cat/sort/wc, but sets no `pipefail` — the filter exits 0 and masks the producer's failure, so the gate silently fails open. Add `set -o pipefail`, capture the producer's status explicitly, or restructure the pipeline. If fail-open is intended here, say so and re-run."
  }
}
JSON
exit 0
