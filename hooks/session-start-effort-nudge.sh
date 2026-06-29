#!/usr/bin/env bash
# Claude Code SessionStart hook: deterministically surfaces the current effort
# level + model at session start and reminds the agent to run the General.md
# §10.2 effort/model recommendation gate before substantive work.
#
# Why: §10.2 is an always-on MUST, yet it was skipped entirely at task start
# (friction session ce981975). A buried rule line is easy to miss; a SessionStart
# injection puts the trigger AND the current values in front of the agent at the
# one moment with near-zero switch cost. SessionStart cannot block (informational
# only) — this is a salience nudge, not a hard gate.
#
# Fires once per session start. `source` (startup|resume|clear|compact) tailors
# the message: a new task (startup/clear) demands the full §10.2 block; a
# continuity event (resume/compact) asks for a lighter re-confirm and, on
# compact, a §3.4 continuity revalidation.
#
# Input:  JSON on stdin; effort at .effort.level, model at .model, trigger at .source.
# Output: stdout additionalContext JSON, exit 0. Never blocks.
#
# Effort resolution: the SessionStart stdin JSON does NOT reliably carry
# .effort.level at startup (model comes through, effort is empty → "unknown").
# Resolve via a fallback chain instead, matching General.md §10.2 which names
# $CLAUDE_EFFORT as the source of truth: stdin .effort.level → $CLAUDE_EFFORT env
# (set for hooks per the Claude Code changelog) → settings.json effortLevel
# (persisted default) → "unknown".

set -uo pipefail

SETTINGS="${HOME}/.claude/settings.json"

INPUT=$(cat)
EFFORT=$(echo "$INPUT" | jq -r '.effort.level // empty' 2>/dev/null || true)
MODEL=$(echo "$INPUT" | jq -r '.model // empty' 2>/dev/null || true)
SOURCE=$(echo "$INPUT" | jq -r '.source // empty' 2>/dev/null || true)

# Fallback chain for effort when stdin omits it.
if [ -z "$EFFORT" ]; then
    EFFORT="${CLAUDE_EFFORT:-}"
fi
if [ -z "$EFFORT" ] && [ -f "$SETTINGS" ]; then
    EFFORT=$(jq -r '.effortLevel // empty' "$SETTINGS" 2>/dev/null || true)
fi

EFFORT=${EFFORT:-unknown}
MODEL=${MODEL:-unknown}

case "$SOURCE" in
    resume)
        MSG="Session resumed. Current: /effort ${EFFORT} | ${MODEL}. Re-confirm this setting still fits the work; emit the General.md §10.2 recommendation if it does not, or if no recommendation was made yet this task."
        ;;
    compact)
        MSG="Context compaction occurred. Current: /effort ${EFFORT} | ${MODEL}. Per General.md §3.4, revalidate continuity (re-read [CRITICAL] files + in-scope state) before continuing, and re-check whether the effort/model setting still fits per §10.2."
        ;;
    *)
        # startup, clear, or unknown trigger → new task baseline.
        MSG="Session start. Current: /effort ${EFFORT} | ${MODEL}. Before substantive work, run the General.md §10.2 gate: emit the Effort/model recommendation block (Current / Recommended / Reason) and apply the escalation test. Do not skip this step."
        ;;
esac

jq -n --arg ctx "$MSG" '{
    hookSpecificOutput: {
        hookEventName: "SessionStart",
        additionalContext: $ctx
    }
}'
exit 0
