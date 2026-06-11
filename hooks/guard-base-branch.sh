#!/usr/bin/env bash
# Claude Code PreToolUse hook for Bash: catches the reflexive use of a default
# branch (main/master/develop/trunk) as a comparison base when the project's
# real base differs (e.g. release/typo3_13). Targets a specific, recurring
# friction: diffing/reviewing against the wrong base branch.
#
# Activation is project-opt-in (stays silent where unconfigured, so it never
# nags repos that don't need it). The expected base is read from, in order:
#   1. env CLAUDE_EXPECTED_BASE
#   2. first non-comment, non-empty line of ./.aiassistant/state/base-branch
# If neither is set → no-op.
#
# Fires "ask" only when a git comparison command references a DEFAULT branch
# name that is NOT the configured base — i.e. the "Claude reached for main/
# master out of habit" case. Comparing against the configured base, a SHA, or a
# feature branch does not trigger it.
#
# Input:  JSON on stdin; command at .tool_input.command (.command fallback).
# Output: stdout ask-JSON, or exit 0 silent.

set -uo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // .command // empty' 2>/dev/null || true)
[[ -z "$COMMAND" ]] && exit 0

# Only inspect git comparison/history commands.
if ! echo "$COMMAND" | grep -qE 'git[[:space:]]+(diff|log|merge-base|rev-list|cherry|rebase)([[:space:]]|$)'; then
    exit 0
fi

# Resolve expected base (env wins; else project state file).
EXPECTED="${CLAUDE_EXPECTED_BASE:-}"
if [[ -z "$EXPECTED" && -f ./.aiassistant/state/base-branch ]]; then
    EXPECTED=$(grep -vE '^[[:space:]]*(#|$)' ./.aiassistant/state/base-branch 2>/dev/null | head -1 | tr -d '[:space:]')
fi
[[ -z "$EXPECTED" ]] && exit 0

# Compare on basename so release/typo3_13 vs origin/release/typo3_13 align.
EXPECTED_BASE="${EXPECTED##*/}"

for DEF in main master develop trunk; do
    [[ "$DEF" == "$EXPECTED_BASE" ]] && continue
    # word-boundary match, also catches origin/<def>
    if echo "$COMMAND" | grep -qE "(^|[[:space:]/])${DEF}([[:space:].]|\.\.|$)"; then
        REASON="Base-branch check: this git command references '${DEF}', but the configured base for this project is '${EXPECTED}'. Confirm the comparison base is correct before diffing/reviewing (recurring base-branch mistake — General.md §2.4):
  $COMMAND"
        jq -n --arg reason "$REASON" '{
            hookSpecificOutput: {
                hookEventName: "PreToolUse",
                permissionDecision: "ask",
                permissionDecisionReason: $reason
            }
        }'
        exit 0
    fi
done

exit 0
