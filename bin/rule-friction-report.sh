#!/usr/bin/env bash
# rule-friction-report.sh — aggregate Claude Code usage-data facets into a
# rule-set friction summary. Input for the /core:rule-friction skill.
#
# Read-only. Data sources (machine-local, rolling — absence means "no
# signal", not "no friction"):
#   usage-data/facets/<session>.json      per-session classification
#     (friction_counts, friction_detail, outcome, user_satisfaction_counts)
#   usage-data/session-meta/<session>.json  project path, tool counts
#
# Facets whose friction_detail indicates the CLASSIFIER failed (truncated
# transcript, output-token-max) are bucketed under "Data quality" and
# excluded from the main statistics — they are pipeline noise, not session
# friction.

set -uo pipefail
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
FACETS="$CLAUDE_DIR/usage-data/facets"
META="$CLAUDE_DIR/usage-data/session-meta"
NOISE_RE='token maximum|truncated|preventing analysis|unavailable due to'

[[ -d "$FACETS" ]] || { echo "No facets dir at $FACETS" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq required" >&2; exit 1; }

GOOD=()
NOISE=()
for f in "$FACETS"/*.json; do
    [[ -f "$f" ]] || continue
    detail=$(jq -r '.friction_detail // empty' "$f")
    if [[ -n "$detail" ]] && printf '%s' "$detail" | grep -qiE "$NOISE_RE"; then
        NOISE+=("$f")
    else
        GOOD+=("$f")
    fi
done

echo "# Rule-friction report — ${#GOOD[@]} sessions (+ ${#NOISE[@]} excluded as classifier noise)"

if [[ ${#GOOD[@]} -gt 0 ]]; then
    echo
    echo "## Outcome distribution"
    jq -s 'map(.outcome // "unknown") | group_by(.) | map({key: .[0], value: length}) | sort_by(-.value) | from_entries' "${GOOD[@]}"

    echo
    echo "## Aggregated friction counts"
    jq -s 'map(.friction_counts // {})
           | reduce .[] as $f ({}; reduce ($f|to_entries[]) as $e (.; .[$e.key] = (.[$e.key] // 0) + $e.value))
           | to_entries | sort_by(-.value) | from_entries' "${GOOD[@]}"

    echo
    echo "## Sessions with friction detail"
    for f in "${GOOD[@]}"; do
        detail=$(jq -r '.friction_detail // empty' "$f")
        [[ -z "$detail" ]] && continue
        id=$(jq -r '.session_id // "unknown"' "$f")
        proj=$(jq -r '.project_path // empty' "$META/$id.json" 2>/dev/null)
        echo "- ${id:0:8} (${proj:-project unknown}): $detail"
    done

    echo
    echo "## Sessions with negative satisfaction signals"
    for f in "${GOOD[@]}"; do
        bad=$(jq -r '[(.user_satisfaction_counts // {}) | to_entries[]
                      | select(.key | test("dissatisf|frustrat|unhappy|annoyed"; "i"))
                      | .value] | add // 0' "$f")
        [[ "$bad" =~ ^[0-9]+$ && "$bad" -gt 0 ]] || continue
        id=$(jq -r '.session_id // "unknown"' "$f")
        summ=$(jq -r '.brief_summary // ""' "$f" | cut -c1-160)
        echo "- ${id:0:8}: $bad negative signal(s) — $summ"
    done
fi

if [[ ${#NOISE[@]} -gt 0 ]]; then
    echo
    echo "## Data quality — classifier failures (excluded from stats above)"
    for f in "${NOISE[@]}"; do
        id=$(jq -r '.session_id // "unknown"' "$f")
        detail=$(jq -r '.friction_detail // empty' "$f" | cut -c1-120)
        echo "- ${id:0:8}: $detail"
    done
fi

echo
echo "(End of report. Map recurring patterns to rules via /core:rule-friction.)"
