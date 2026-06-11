#!/usr/bin/env bash
# rule-friction-report.sh — aggregate Claude Code usage-data facets into a
# rule-set friction summary. Input for the /core:rule-friction skill.
#
# Read-only. Data sources (machine-local, rolling — absence means "no
# signal", not "no friction"):
#   usage-data/facets/<session>.json      per-session classification
#     (friction_counts, friction_detail, outcome, user_satisfaction_counts)
#   usage-data/session-meta/<session>.json  project path, tool counts

set -uo pipefail
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
FACETS="$CLAUDE_DIR/usage-data/facets"
META="$CLAUDE_DIR/usage-data/session-meta"

[[ -d "$FACETS" ]] || { echo "No facets dir at $FACETS" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq required" >&2; exit 1; }

count=$(find "$FACETS" -name '*.json' | wc -l)
echo "# Rule-friction report — $count classified sessions"

echo
echo "## Outcome distribution"
jq -s 'map(.outcome // "unknown") | group_by(.) | map({key: .[0], value: length}) | sort_by(-.value) | from_entries' "$FACETS"/*.json

echo
echo "## Aggregated friction counts (all sessions)"
jq -s 'map(.friction_counts // {})
       | reduce .[] as $f ({}; reduce ($f|to_entries[]) as $e (.; .[$e.key] = (.[$e.key] // 0) + $e.value))
       | to_entries | sort_by(-.value) | from_entries' "$FACETS"/*.json

echo
echo "## Sessions with friction detail"
for f in "$FACETS"/*.json; do
    detail=$(jq -r '.friction_detail // empty' "$f")
    [[ -z "$detail" ]] && continue
    id=$(jq -r '.session_id // "unknown"' "$f")
    proj=$(jq -r '.project_path // empty' "$META/$id.json" 2>/dev/null)
    echo "- ${id:0:8} (${proj:-project unknown}): $detail"
done

echo
echo "## Sessions with negative satisfaction signals"
for f in "$FACETS"/*.json; do
    bad=$(jq -r '[(.user_satisfaction_counts // {}) | to_entries[]
                  | select(.key | test("dissatisf|frustrat|unhappy|annoyed"; "i"))
                  | .value] | add // 0' "$f")
    [[ "$bad" =~ ^[0-9]+$ && "$bad" -gt 0 ]] || continue
    id=$(jq -r '.session_id // "unknown"' "$f")
    summ=$(jq -r '.brief_summary // ""' "$f" | cut -c1-160)
    echo "- ${id:0:8}: $bad negative signal(s) — $summ"
done

echo
echo "(End of report. Map recurring patterns to rules via /core:rule-friction.)"
