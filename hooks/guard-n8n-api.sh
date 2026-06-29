#!/usr/bin/env bash
# Claude Code PreToolUse hook for Bash: guards n8n public-API calls (any tool /
# session in this account), independent of the n8n API token's own scopes — the
# token is editable and could be widened, so this is a second, agent-side fence.
#
# Scope: only commands that hit the n8n public API (host n8n.mosaiq.com + /api/).
# Everything else (incl. n8n /webhook/ trigger calls and non-n8n commands) passes
# through untouched.
#
# Tiers:
#   - HARD BLOCK (exit 2): irreversible / never-needed-by-agent —
#       * any DELETE (workflows, credentials, executions, data-tables, …)
#       * any write (POST/PUT/PATCH) to credentials / users / projects /
#         variables / tags / source-control endpoints
#   - ASK (exit 0 + permissionDecision "ask"): write (POST/PUT/PATCH) to a
#       /workflows resource whose ID is NOT in the allowlist file, incl. create
#       (POST /workflows, no ID) and activate/deactivate; plus any other
#       uncategorised n8n write (fail-safe).
#   - ALLOW (exit 0, silent): GET/HEAD; writes to an allowlisted workflow ID;
#       data-tables writes (create table / insert rows — non-destructive).
#
# Allowlist: ~/.claude/n8n-workflow-allowlist.txt (one workflow ID per line).
# Input:  JSON on stdin; command at .tool_input.command (.command fallback).
# Limitation: regex over the command string; runtime variable expansion is not
# evaluated. Under bypassPermissions an "ask" may auto-approve, but the hard-block
# tier (exit 2) still enforces.

set -uo pipefail

N8N_HOST="n8n.mosaiq.com"
ALLOWLIST="$HOME/.claude/n8n-workflow-allowlist.txt"

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // .command // empty' 2>/dev/null || true)
[[ -z "$CMD" ]] && exit 0

# Only act on n8n public-API calls. Webhook triggers and non-n8n commands pass.
echo "$CMD" | grep -qF "$N8N_HOST" || exit 0
echo "$CMD" | grep -qE '/api/v[0-9]' || exit 0

hard_block() {
    printf '{"error": %s}\n' "$(jq -Rn --arg m "$1" '$m')" >&2
    exit 2
}
ask() {
    jq -n --arg reason "$1" '{
        hookSpecificOutput: {
            hookEventName: "PreToolUse",
            permissionDecision: "ask",
            permissionDecisionReason: $reason
        }
    }'
    exit 0
}

# --- determine HTTP method --------------------------------------------------
METHOD=""
if echo "$CMD" | grep -qiE -- '(--request|-X)[[:space:]]*[A-Za-z]+'; then
    METHOD=$(echo "$CMD" | grep -ioE -- '(--request|-X)[[:space:]]*[A-Za-z]+' | head -1 \
             | sed -E 's/^(--request|-X)[[:space:]]*//I')
    METHOD=$(echo "$METHOD" | tr '[:lower:]' '[:upper:]')
fi
if [[ -z "$METHOD" ]]; then
    # No explicit method: a body/form flag implies POST, otherwise GET.
    if echo "$CMD" | grep -qE -- '(--data|--form|(^|[[:space:]])-d([[:space:]=@]|$)|(^|[[:space:]])-F([[:space:]=@]|$))'; then
        METHOD="POST"
    else
        METHOD="GET"
    fi
fi

# --- read-only → allow ------------------------------------------------------
[[ "$METHOD" == "GET" || "$METHOD" == "HEAD" ]] && exit 0

# --- HARD BLOCK: any DELETE to the n8n API ----------------------------------
if [[ "$METHOD" == "DELETE" ]]; then
    hard_block "Blocked: DELETE against the n8n API ($N8N_HOST) is irreversible (workflows/credentials/executions/data-tables have no undo). Perform deletions manually in the n8n UI if truly intended."
fi

# --- HARD BLOCK: writes to high-blast resource types ------------------------
if echo "$CMD" | grep -qiE "/api/v[0-9]+/(credentials|users|projects|variables|tags|source-control)([/?\"'[:space:]]|$)"; then
    hard_block "Blocked: write ($METHOD) to a protected n8n resource (credentials/users/projects/variables/tags/source-control). The agent never needs these; deleting/altering shared credentials would break other workflows. Do it in the n8n UI if intended."
fi

# --- /workflows writes: allowlist or ask ------------------------------------
if echo "$CMD" | grep -qiE '/api/v[0-9]+/workflows'; then
    WFID=$(echo "$CMD" | grep -oiE '/workflows/[A-Za-z0-9_-]+' | head -1 | sed -E 's#.*/workflows/##')
    if [[ -n "$WFID" && -f "$ALLOWLIST" ]] \
       && grep -vE '^[[:space:]]*(#|$)' "$ALLOWLIST" | grep -qxF -- "$WFID"; then
        exit 0   # allowlisted workflow → allow silently
    fi
    if [[ -n "$WFID" ]]; then
        ask "n8n write ($METHOD) to workflow '$WFID', which is NOT in the allowlist (~/.claude/n8n-workflow-allowlist.txt). Confirm you intend to modify THIS workflow (wrong ID would clobber someone else's):
  $CMD"
    else
        ask "n8n workflow create/write ($METHOD /workflows) detected. Confirm — then add the new workflow ID to ~/.claude/n8n-workflow-allowlist.txt to skip future prompts:
  $CMD"
    fi
fi

# --- data-tables writes → allow (non-destructive: create table / insert rows)
if echo "$CMD" | grep -qiE '/api/v[0-9]+/data-tables'; then
    exit 0
fi

# --- any other uncategorised n8n write → ask (fail-safe) --------------------
ask "Uncategorised n8n API write ($METHOD). Review before proceeding:
  $CMD"
