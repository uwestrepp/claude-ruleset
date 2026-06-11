# mq.agent-ruleset

MOSAIQ Claude Code agent ruleset: global rules, custom agents, hooks, plugins, and configuration templates.

---

## Contents

```
CLAUDE.md                     Rule index (entry point for all projects)
rules/
  General.md                  Global baseline behavior [CRITICAL]
  Meta.md                     Knowledge persistence and rule governance [CRITICAL]
  Persona.md                  Verification-first behavioral framing [CRITICAL]
  CleanCode.md                Clean code principles
  PER.md                      PHP PER-CS 3.0 coding style + application policy (path-gated: **/*.php)
  TYPO3.md                    TYPO3 operating policy + extension version layering (path-gated)
  Twig.md                     Twig authoring rules (path-gated: **/*.twig)
agents/
  checkpoint.md               Knowledge persistence agent
  contract-researcher.md      Upstream contract verification agent
  test-runner.md              Test execution agent
hooks/                        Claude-side PreToolUse guards
  validate-commit-message.sh  Enforces /core:commits subject format (~/work repos)
  block-forbidden-stages.sh   Soft-blocks commits touching denylisted paths
  guard-destructive-commands.sh  Tiered guard for destructive shell/git commands
  guard-base-branch.sh        Catches comparisons against the wrong base branch
bin/
  lint-section-refs.sh        Cross-reference + skill-ledger linter (this repo)
  rule-friction-report.sh     Usage-data facet aggregation for /core:rule-friction
.githooks/
  pre-commit                  Runs the section-ref linter (activate: git config core.hooksPath .githooks)
plugins/
  known_marketplaces.json     Marketplace registry (managed by CLI)
  marketplaces/
    local/                    Local MOSAIQ marketplace
      plugins/
        core/                 Generic workflow skills (batch, commits, composer, composer-update,
                              githooks-install, brainstorm, grill-me, rule-friction)
        typo3/                TYPO3 workflow skills (upgrade, scanner, static-tests, upgrade-full)
exports/                      Condensed rule-set variants for external agents/harnesses
settings.json.example         Template for ~/.claude/settings.json
claude.json.example           Template for MCP server entries in ~/.claude.json
setup.sh                      Automated install/update script (shows rule-set changelog on update)
```

---

## Installation

### Quick setup

```bash
git clone git@bitbucket.org:mosaiq-gmbh/mq.agent-ruleset.git ~/.claude
~/.claude/setup.sh
```

The setup script auto-detects install vs update mode. It handles settings, MCP servers, hooks, and plugin registration in one step.

> If `~/.claude` already exists as a Claude Code runtime directory (no git repo), the script overlays the repo without touching existing runtime files (credentials, sessions, etc.).

### Setup options

```
setup.sh [OPTIONS]

  -d, --dir DIR        Target directory (default: ~/.claude)
  -m, --mode MODE      install | update | auto (default: auto)
      --no-plugins     Skip plugin marketplace registration and install/update
      --no-mcp         Skip MCP server merge into ~/.claude.json
      --force          Overwrite settings.json from template (backs up first)
      --dry-run        Show what would be done, change nothing
  -v, --verbose        Show detailed output
  -h, --help           Show this help
```

Prerequisites: `git`, `jq`, and optionally the `claude` CLI (plugin steps are skipped gracefully if it is not installed yet).

---

## Updating

```bash
~/.claude/setup.sh
```

The script auto-detects update mode when the target directory already contains the repo. It pulls the latest changes, merges new settings keys (without overwriting your customizations), and updates plugins.

---

## Manual alternative

If you prefer not to use the setup script, or need to debug a specific step:

<details>
<summary>Show manual installation steps</summary>

### 1. Clone into `~/.claude`

```bash
git clone git@bitbucket.org:mosaiq-gmbh/mq.agent-ruleset.git ~/.claude
```

### 2. Apply `settings.json`

```bash
cp ~/.claude/settings.json.example ~/.claude/settings.json
```

### 3. Merge MCP servers into `~/.claude.json`

> **Important:** `~/.claude.json` is a live file owned and continuously updated by Claude Code.
> **Never replace it.** Only merge the `mcpServers` key into your existing file.

`claude.json.example` contains only the `mcpServers` block. Merge it manually:

1. Open `~/.claude.json` in an editor.
2. Locate (or add) the top-level `"mcpServers"` key.
3. Copy the server entries from `claude.json.example` into that key.

The Atlassian MCP server requires an active Atlassian OAuth session. See [Atlassian MCP documentation](https://mcp.atlassian.com) for authentication setup.

### 4. Make the hook executable

```bash
chmod +x ~/.claude/hooks/validate-commit-message.sh
```

### 5. Register and install the local plugin marketplace

```bash
claude plugins marketplace add ~/.claude/plugins/marketplaces/local
claude plugins install typo3@local
claude plugins list  # verify: typo3@local should be enabled
```

### Manual update

```bash
cd ~/.claude && git pull
claude plugins update typo3@local
```

</details>

---

## TYPO3 Workflow Skills

The `typo3` plugin provides four skills for structured TYPO3 upgrade work. Skills require **explicit activation** — the agent will not start a workflow until you invoke the skill. See each skill's description for full trigger patterns.

| Skill | Invoke with | Use when |
|---|---|---|
| TYPO3 Upgrade Workflow | `/typo3:upgrade` | Running an upgrade, fixing deprecations or breaking changes |
| TYPO3 ExtensionScanner | `/typo3:scanner` | Running ExtensionScanner, triaging scanner findings |
| TYPO3 Static Code Tests | `/typo3:static-tests` | Running phpstan, rector, fractor, php-cs-fixer, TypoScript lint |
| TYPO3 Full Upgrade Chain | `/typo3:upgrade-full` | Running all three workflows in one chained session |

For the full chain, a single invocation drives all three component workflows in sequence:

```
/typo3:upgrade-full
```

The orchestrator invokes `/typo3:upgrade`, `/typo3:scanner`, and `/typo3:static-tests` in order via the Skill tool — do NOT pre-activate them manually.

---

## Project-level configuration

For project-specific agent state, extension ticket maps, triage artifacts, and `.aiassistant/` conventions, see the project's own `CLAUDE.md` and `.aiassistant/` directory.
