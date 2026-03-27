#!/usr/bin/env bash
# setup.sh — Install or update the MOSAIQ Claude Code agent ruleset.
# See README.md for manual steps; this script automates them.
set -euo pipefail

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
REPO_URL="git@bitbucket.org:mosaiq-gmbh/mq.agent-ruleset.git"
DEFAULT_TARGET="$HOME/.claude"
CLAUDE_JSON="$HOME/.claude.json"

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
TARGET_DIR="$DEFAULT_TARGET"
MODE="auto"
SKIP_PLUGINS=false
SKIP_MCP=false
FORCE=false
DRY_RUN=false
VERBOSE=false

# Tracking for summary
STEPS_DONE=()
STEPS_SKIPPED=()
STEPS_FAILED=()

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
log_info()    { printf '\033[0;34m[INFO]\033[0m  %s\n' "$*"; }
log_success() { printf '\033[0;32m[OK]\033[0m    %s\n' "$*"; }
log_warn()    { printf '\033[0;33m[WARN]\033[0m  %s\n' "$*"; }
log_error()   { printf '\033[0;31m[ERROR]\033[0m %s\n' "$*" >&2; }
log_verbose() { [[ "$VERBOSE" == "true" ]] && printf '\033[0;90m        %s\033[0m\n' "$*" || true; }
log_dry()     { printf '\033[0;35m[DRY]\033[0m   %s\n' "$*"; }

step_done()    { STEPS_DONE+=("$1");    log_success "$1"; }
step_skipped() { STEPS_SKIPPED+=("$1"); log_warn "Skipped: $1"; }
step_failed()  { STEPS_FAILED+=("$1");  log_error "Failed: $1"; }

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
    cat <<'USAGE'
Usage: setup.sh [OPTIONS]

Install or update the MOSAIQ Claude Code agent ruleset.

Options:
  -d, --dir DIR        Target directory (default: ~/.claude)
  -m, --mode MODE      install | update | auto (default: auto)
      --no-plugins     Skip plugin marketplace registration and install/update
      --no-mcp         Skip MCP server merge into ~/.claude.json
      --force          Overwrite settings.json from template (backs up first)
      --dry-run        Show what would be done, change nothing
  -v, --verbose        Show detailed output
  -h, --help           Show this help

Modes:
  auto      Detect: install if target does not exist, update if it does (default)
  install   Fresh install (clone repo, copy settings, register plugins)
  update    Non-destructive update (pull, merge new keys, update plugins)

Examples:
  setup.sh                          # Auto-detect, default directory
  setup.sh --mode install           # Force fresh install
  setup.sh --mode update --no-mcp   # Update rules only, skip MCP merge
  setup.sh --dry-run                # Preview what would happen
  setup.sh -d ~/my-claude           # Install to custom directory
USAGE
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--dir)       TARGET_DIR="$2"; shift 2 ;;
            -m|--mode)      MODE="$2"; shift 2 ;;
            --no-plugins)   SKIP_PLUGINS=true; shift ;;
            --no-mcp)       SKIP_MCP=true; shift ;;
            --force)        FORCE=true; shift ;;
            --dry-run)      DRY_RUN=true; shift ;;
            -v|--verbose)   VERBOSE=true; shift ;;
            -h|--help)      usage; exit 0 ;;
            *)              log_error "Unknown option: $1"; usage; exit 1 ;;
        esac
    done

    # Expand ~ in TARGET_DIR
    TARGET_DIR="${TARGET_DIR/#\~/$HOME}"

    # Validate mode
    case "$MODE" in
        auto|install|update) ;;
        *) log_error "Invalid mode: $MODE (expected: auto, install, update)"; exit 1 ;;
    esac
}

# ---------------------------------------------------------------------------
# Dependency checks
# ---------------------------------------------------------------------------
require_cmd() {
    local cmd="$1" hint="${2:-}"
    if ! command -v "$cmd" &>/dev/null; then
        if [[ -n "$hint" ]]; then
            log_error "$cmd is required but not found. $hint"
        else
            log_error "$cmd is required but not found."
        fi
        return 1
    fi
    log_verbose "Found $cmd: $(command -v "$cmd")"
}

HAS_CLAUDE=false

check_dependencies() {
    log_info "Checking dependencies..."
    require_cmd git "Install git: https://git-scm.com"
    require_cmd jq  "Install jq: https://jqlang.github.io/jq/download/"

    if command -v claude &>/dev/null; then
        HAS_CLAUDE=true
        log_verbose "Found claude: $(command -v claude)"
    else
        HAS_CLAUDE=false
        if [[ "$SKIP_PLUGINS" != "true" ]]; then
            log_warn "claude CLI not found. Plugin steps will be skipped."
            log_warn "Install Claude Code first: https://docs.anthropic.com/en/docs/claude-code"
        fi
    fi
}

# ---------------------------------------------------------------------------
# Mode detection
# ---------------------------------------------------------------------------
detect_mode() {
    if [[ "$MODE" != "auto" ]]; then
        log_info "Mode: $MODE (explicit)"
        return
    fi

    if [[ ! -d "$TARGET_DIR" ]]; then
        MODE="install"
        log_info "Mode: install (target directory does not exist)"
        return
    fi

    if [[ ! -d "$TARGET_DIR/.git" ]]; then
        MODE="install"
        log_info "Mode: install (target exists but is not a git repo — will overlay)"
        return
    fi

    local actual_remote
    actual_remote=$(git -C "$TARGET_DIR" remote get-url origin 2>/dev/null || true)
    if [[ "$actual_remote" == "$REPO_URL" ]]; then
        MODE="update"
        log_info "Mode: update (existing repo matches expected remote)"
    else
        log_error "Target directory $TARGET_DIR is a git repo with a different remote:"
        log_error "  expected: $REPO_URL"
        log_error "  actual:   $actual_remote"
        log_error "Use --dir to specify a different target, or resolve manually."
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# Backup helper
# ---------------------------------------------------------------------------
backup_file() {
    local file="$1"
    [[ -f "$file" ]] || return 0

    local backup_dir="$TARGET_DIR/backups"
    local timestamp basename_f
    timestamp=$(date +%Y%m%d_%H%M%S)
    basename_f=$(basename "$file")

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would back up $file → backups/${basename_f}.${timestamp}.bak"
        return 0
    fi

    mkdir -p "$backup_dir"
    cp "$file" "$backup_dir/${basename_f}.${timestamp}.bak"
    log_verbose "Backed up $file → backups/${basename_f}.${timestamp}.bak"
}

# ---------------------------------------------------------------------------
# Install steps
# ---------------------------------------------------------------------------
clone_or_overlay() {
    if [[ "$DRY_RUN" == "true" ]]; then
        if [[ -d "$TARGET_DIR" ]]; then
            log_dry "Would overlay repo into existing $TARGET_DIR via git init + fetch + checkout"
        else
            log_dry "Would clone $REPO_URL → $TARGET_DIR"
        fi
        return 0
    fi

    if [[ -d "$TARGET_DIR" ]]; then
        # Existing directory without .git — overlay the repo
        log_info "Overlaying repo into existing $TARGET_DIR..."
        backup_file "$TARGET_DIR/settings.json"
        backup_file "$TARGET_DIR/settings.local.json"

        git init "$TARGET_DIR" >/dev/null
        git -C "$TARGET_DIR" remote add origin "$REPO_URL"
        git -C "$TARGET_DIR" fetch origin
        git -C "$TARGET_DIR" checkout -b main origin/main
        step_done "Overlaid repo into $TARGET_DIR"
    else
        log_info "Cloning into $TARGET_DIR..."
        git clone "$REPO_URL" "$TARGET_DIR"
        step_done "Cloned repo into $TARGET_DIR"
    fi
}

copy_settings() {
    local target="$TARGET_DIR/settings.json"
    local source="$TARGET_DIR/settings.json.example"

    if [[ "$DRY_RUN" == "true" ]]; then
        if [[ -f "$target" && "$FORCE" != "true" ]]; then
            log_dry "Would skip settings.json (already exists, no --force)"
        elif [[ -f "$target" ]]; then
            log_dry "Would back up and overwrite settings.json from template (--force)"
        else
            log_dry "Would copy settings.json.example → settings.json"
        fi
        return 0
    fi

    if [[ ! -f "$source" ]]; then
        step_failed "settings.json.example not found"
        return 1
    fi

    if [[ -f "$target" && "$FORCE" != "true" ]]; then
        step_skipped "settings.json already exists (use --force to overwrite)"
        return 0
    fi

    if [[ -f "$target" ]]; then
        backup_file "$target"
    fi
    cp "$source" "$target"
    step_done "Created settings.json from template"
}

# ---------------------------------------------------------------------------
# Update steps
# ---------------------------------------------------------------------------
git_pull() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would run git pull --ff-only in $TARGET_DIR"
        return 0
    fi

    log_info "Pulling latest changes..."
    if git -C "$TARGET_DIR" pull --ff-only; then
        step_done "Pulled latest changes"
    else
        log_error "git pull --ff-only failed. Resolve conflicts manually, then re-run."
        step_failed "git pull"
        return 1
    fi
}

merge_settings() {
    local target="$TARGET_DIR/settings.json"
    local source="$TARGET_DIR/settings.json.example"

    if [[ ! -f "$source" ]]; then
        step_failed "settings.json.example not found"
        return 1
    fi

    if [[ ! -f "$target" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "Would copy settings.json.example → settings.json (missing)"
            return 0
        fi
        cp "$source" "$target"
        step_done "Created settings.json from template (was missing)"
        return 0
    fi

    if [[ "$FORCE" == "true" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "Would back up and overwrite settings.json from template (--force)"
            return 0
        fi
        backup_file "$target"
        cp "$source" "$target"
        step_done "Overwrote settings.json from template (--force)"
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would merge new keys from settings.json.example into settings.json"
        return 0
    fi

    backup_file "$target"

    # Deep merge: example (defaults, left) * user (overrides, right)
    # User values win on conflicts; new keys from example are added.
    local merged
    merged=$(jq -s '.[0] * .[1]' "$source" "$target")
    printf '%s\n' "$merged" > "$target"
    step_done "Merged new keys into settings.json"
}

# ---------------------------------------------------------------------------
# MCP server merge
# ---------------------------------------------------------------------------
merge_mcp_servers() {
    if [[ "$SKIP_MCP" == "true" ]]; then
        step_skipped "MCP server merge (--no-mcp)"
        return 0
    fi

    local example="$TARGET_DIR/claude.json.example"

    if [[ "$DRY_RUN" == "true" ]]; then
        if [[ -f "$CLAUDE_JSON" ]]; then
            log_dry "Would merge MCP servers from template into $CLAUDE_JSON"
        else
            log_dry "Would create $CLAUDE_JSON from template"
        fi
        return 0
    fi

    if [[ ! -f "$example" ]]; then
        step_failed "claude.json.example not found"
        return 1
    fi

    if [[ ! -f "$CLAUDE_JSON" ]]; then
        cp "$example" "$CLAUDE_JSON"
        step_done "Created $CLAUDE_JSON from template"
        return 0
    fi

    backup_file "$CLAUDE_JSON"

    # Merge mcpServers key only. Example servers as defaults (left),
    # existing servers win on conflicts (right). User-added servers preserved.
    local merged
    merged=$(jq -s '
        .[0] as $existing |
        .[1].mcpServers as $new |
        ($new * ($existing.mcpServers // {})) as $merged_servers |
        $existing | .mcpServers = $merged_servers
    ' "$CLAUDE_JSON" "$example")
    printf '%s\n' "$merged" > "$CLAUDE_JSON"
    step_done "Merged MCP servers into $CLAUDE_JSON"
}

# ---------------------------------------------------------------------------
# Hook permissions
# ---------------------------------------------------------------------------
fix_hook_permissions() {
    if [[ ! -d "$TARGET_DIR/hooks" ]]; then
        log_verbose "No hooks directory, skipping"
        return 0
    fi

    local hooks=("$TARGET_DIR/hooks/"*.sh)
    if [[ ! -e "${hooks[0]}" ]]; then
        log_verbose "No .sh files in hooks/, skipping"
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would chmod +x ${hooks[*]}"
        return 0
    fi

    chmod +x "${hooks[@]}"
    step_done "Hook scripts marked executable"
}

# ---------------------------------------------------------------------------
# Plugin management
# ---------------------------------------------------------------------------
run_plugin_steps_install() {
    if [[ "$SKIP_PLUGINS" == "true" ]]; then
        step_skipped "Plugin registration (--no-plugins)"
        return 0
    fi

    if [[ "$HAS_CLAUDE" != "true" ]]; then
        step_skipped "Plugin registration (claude CLI not found)"
        log_warn "Run these commands manually after installing Claude Code:"
        log_warn "  claude plugins marketplace add $TARGET_DIR/plugins/marketplaces/local"
        log_warn "  claude plugins install typo3-workflows@local"
        return 0
    fi

    local marketplace_path="$TARGET_DIR/plugins/marketplaces/local"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would run: claude plugins marketplace add $marketplace_path"
        log_dry "Would run: claude plugins install typo3-workflows@local"
        return 0
    fi

    if [[ ! -d "$marketplace_path" ]]; then
        step_failed "Local marketplace directory not found at $marketplace_path"
        return 1
    fi

    log_info "Registering local marketplace..."
    if claude plugins marketplace add "$marketplace_path" 2>&1; then
        step_done "Registered local marketplace"
    else
        step_failed "Marketplace registration"
    fi

    log_info "Installing typo3-workflows plugin..."
    if claude plugins install typo3-workflows@local 2>&1; then
        step_done "Installed typo3-workflows plugin"
    else
        step_failed "Plugin installation"
    fi
}

run_plugin_steps_update() {
    if [[ "$SKIP_PLUGINS" == "true" ]]; then
        step_skipped "Plugin update (--no-plugins)"
        return 0
    fi

    if [[ "$HAS_CLAUDE" != "true" ]]; then
        step_skipped "Plugin update (claude CLI not found)"
        log_warn "Run manually: claude plugins update typo3-workflows@local"
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would run: claude plugins update typo3-workflows@local"
        return 0
    fi

    log_info "Updating typo3-workflows plugin..."
    if claude plugins update typo3-workflows@local 2>&1; then
        step_done "Updated typo3-workflows plugin"
    else
        # Update may fail if nothing changed — not critical
        log_verbose "Plugin update returned non-zero (may already be up to date)"
        step_done "Plugin update checked"
    fi
}

# ---------------------------------------------------------------------------
# Verification
# ---------------------------------------------------------------------------
verify() {
    log_info "Verifying installation..."
    local issues=0

    # settings.json exists and is valid JSON
    if [[ -f "$TARGET_DIR/settings.json" ]]; then
        if jq empty "$TARGET_DIR/settings.json" 2>/dev/null; then
            log_verbose "settings.json: valid JSON"
        else
            log_warn "settings.json exists but is not valid JSON"
            issues=$((issues + 1))
        fi
    else
        log_warn "settings.json missing"
        issues=$((issues + 1))
    fi

    # Hooks are executable
    for hook in "$TARGET_DIR/hooks/"*.sh; do
        [[ -e "$hook" ]] || continue
        if [[ -x "$hook" ]]; then
            log_verbose "$hook: executable"
        else
            log_warn "$hook is not executable"
            issues=$((issues + 1))
        fi
    done

    # MCP servers
    if [[ "$SKIP_MCP" != "true" && -f "$CLAUDE_JSON" ]]; then
        local server_count
        server_count=$(jq '.mcpServers | length // 0' "$CLAUDE_JSON" 2>/dev/null || echo 0)
        if [[ "$server_count" -gt 0 ]]; then
            log_verbose "MCP servers: $server_count configured"
        else
            log_warn "No MCP servers found in $CLAUDE_JSON"
            issues=$((issues + 1))
        fi
    fi

    # Plugin
    if [[ "$SKIP_PLUGINS" != "true" && "$HAS_CLAUDE" == "true" ]]; then
        if claude plugins list 2>/dev/null | grep -q "typo3-workflows"; then
            log_verbose "typo3-workflows plugin: installed"
        else
            log_warn "typo3-workflows plugin not found"
            issues=$((issues + 1))
        fi
    fi

    if [[ $issues -eq 0 ]]; then
        log_success "Verification passed"
    else
        log_warn "Verification found $issues issue(s) — review warnings above"
    fi
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
print_summary() {
    echo
    log_info "--- Summary ---"

    if [[ ${#STEPS_DONE[@]} -gt 0 ]]; then
        for s in "${STEPS_DONE[@]}"; do
            printf '  \033[0;32m✔\033[0m %s\n' "$s"
        done
    fi

    if [[ ${#STEPS_SKIPPED[@]} -gt 0 ]]; then
        for s in "${STEPS_SKIPPED[@]}"; do
            printf '  \033[0;33m–\033[0m %s\n' "$s"
        done
    fi

    if [[ ${#STEPS_FAILED[@]} -gt 0 ]]; then
        for s in "${STEPS_FAILED[@]}"; do
            printf '  \033[0;31m✘\033[0m %s\n' "$s"
        done
    fi

    echo
    if [[ ${#STEPS_FAILED[@]} -gt 0 ]]; then
        log_error "Completed with ${#STEPS_FAILED[@]} failure(s)."
        return 1
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_info "Dry run complete. No changes were made."
    else
        log_success "Done."
    fi
}

# ---------------------------------------------------------------------------
# Main flows
# ---------------------------------------------------------------------------
run_install() {
    log_info "Running install..."
    clone_or_overlay
    copy_settings
    merge_mcp_servers
    fix_hook_permissions
    run_plugin_steps_install
}

run_update() {
    log_info "Running update..."
    git_pull
    merge_settings
    merge_mcp_servers
    fix_hook_permissions
    run_plugin_steps_update
}

main() {
    parse_args "$@"
    check_dependencies
    detect_mode

    case "$MODE" in
        install) run_install ;;
        update)  run_update ;;
    esac

    if [[ "$DRY_RUN" != "true" ]]; then
        verify
    fi

    print_summary
}

main "$@"
