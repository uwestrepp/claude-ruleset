#!/usr/bin/env bash
# Validates a commit subject against the /core:commits schema and (optionally)
# enforces ticket traceability via branch name and/or an extension-ticket map.
#
# Usage:
#   validate-commit-subject.sh <subject> [<commit_sha> [<branch_ref>]]
#
# Configuration is loaded from `config.sh` next to this script if present.
# Defaults below match the /core:commits schema out of the box.

set -euo pipefail

# -------- defaults (overridable via config.sh) --------
HOOK_COMMIT_TYPES="FEAT|FIX|BUILD|CHORE|CI|DOCS|STYLE|REFACTOR|PERF|TEST"
HOOK_TICKET_REGEX="[A-Z][A-Z0-9]+-[0-9]+"
HOOK_SCOPE_REGEX="[a-z0-9._/-]+"
HOOK_REQUIRE_TICKET=1
HOOK_EXTENSION_TICKET_MAP=0
HOOK_EXTENSION_PATH_REGEX='^packages/([a-z0-9_]+)/.+'
HOOK_BYPASS_ENV="SKIP_COMMIT_MSG_CHECK"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$script_dir/config.sh" ]]; then
    # shellcheck disable=SC1091
    source "$script_dir/config.sh"
fi

# Emergency bypass.
bypass_value="${!HOOK_BYPASS_ENV:-0}"
if [[ "$bypass_value" == "1" ]]; then
    exit 0
fi

subject="${1:-}"
commit_sha="${2:-}"
branch_ref="${3:-}"

if [[ -z "$subject" ]]; then
    echo "ERROR: Empty commit subject." >&2
    exit 1
fi

# Allow default git revert commit subjects.
if [[ "$subject" =~ ^Revert\ \".+\"$ ]]; then
    exit 0
fi

# Subject format: [TYPE] TICKET (scope) summary
format_regex="^\[($HOOK_COMMIT_TYPES)\] ${HOOK_TICKET_REGEX} \(${HOOK_SCOPE_REGEX}\) .+"
if ! [[ "$subject" =~ $format_regex ]]; then
    echo "ERROR: Commit subject does not match required format." >&2
    echo "Required: [TYPE] TICKET (scope) summary" >&2
    echo "Got: $subject" >&2
    exit 1
fi

# Ticket traceability disabled → we're done.
if [[ "$HOOK_REQUIRE_TICKET" != "1" ]]; then
    exit 0
fi

subject_ticket="$(printf '%s' "$subject" | grep -oE "$HOOK_TICKET_REGEX" | head -n1 || true)"
if [[ -z "$subject_ticket" ]]; then
    echo "ERROR: Commit subject does not contain a ticket matching $HOOK_TICKET_REGEX." >&2
    exit 1
fi

# -------- optional: extension-ticket-map resolver --------
resolver="$script_dir/commit-ticket-resolver"
use_resolver=0
if [[ "$HOOK_EXTENSION_TICKET_MAP" == "1" && -f "$resolver" ]]; then
    use_resolver=1
fi

if [[ "$use_resolver" == "1" ]]; then
    resolver_stderr="$(mktemp)"
    resolver_exit=0
    if [[ -n "$commit_sha" ]]; then
        if [[ -n "$branch_ref" ]]; then
            expected_ticket="$(bash "$resolver" --mode commit --commit "$commit_sha" --branch "$branch_ref" --quiet 2>"$resolver_stderr")" || resolver_exit=$?
        else
            expected_ticket="$(bash "$resolver" --mode commit --commit "$commit_sha" --quiet 2>"$resolver_stderr")" || resolver_exit=$?
        fi
    else
        expected_ticket="$(bash "$resolver" --mode staged --quiet 2>"$resolver_stderr")" || resolver_exit=$?
    fi

    case "$resolver_exit" in
        0)
            if [[ "$subject_ticket" != "$expected_ticket" ]]; then
                echo "ERROR: Commit subject ticket does not match resolved extension ticket." >&2
                echo "Expected: $expected_ticket" >&2
                echo "Subject:  $subject_ticket" >&2
                rm -f "$resolver_stderr"
                exit 1
            fi
            rm -f "$resolver_stderr"
            exit 0
            ;;
        3)
            # No extension-scoped changes; fall through to branch-ticket check.
            rm -f "$resolver_stderr"
            ;;
        *)
            cat "$resolver_stderr" >&2
            rm -f "$resolver_stderr"
            exit 1
            ;;
    esac
fi

# -------- branch-ticket fallback (primary check when ext-map is off or inapplicable) --------
# Only enforce in commit-msg context (no commit_sha). In pre-push context the branch
# ref was validated at commit time, so we don't second-guess historical commits.
if [[ -z "$commit_sha" ]]; then
    branch="$(git symbolic-ref --quiet --short HEAD || true)"
    if [[ -n "$branch" ]]; then
        branch_ticket="$(printf '%s' "$branch" | grep -oE "$HOOK_TICKET_REGEX" | head -n1 || true)"

        if [[ -z "$branch_ticket" ]]; then
            echo "ERROR: No ticket found in branch name: $branch" >&2
            echo "Expected a ticket matching $HOOK_TICKET_REGEX somewhere in the branch name." >&2
            exit 1
        fi

        if [[ "$subject_ticket" != "$branch_ticket" ]]; then
            echo "ERROR: Commit subject ticket does not match branch ticket." >&2
            echo "Branch ticket:  $branch_ticket" >&2
            echo "Subject ticket: $subject_ticket" >&2
            exit 1
        fi
    fi
fi

exit 0
