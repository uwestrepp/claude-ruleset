# mq.agent-ruleset

MOSAIQ Claude Code agent ruleset: global rules, custom agents, hooks, plugins, and configuration templates.

---

## Contents

```
CLAUDE.md                     Rule index (entry point for all projects)
rules/
  General.md                  Global baseline behavior [CRITICAL]
  Meta.md                     Knowledge persistence and rule governance [CRITICAL]
  Batch.md                    Batch workflow foundation
  CleanCode.md                Clean code principles
  Commits.md                  Commit message format and pre-commit checklist
  PER.md                      PHP PER-CS 3.0 coding style
  PER-Application.md          PER application policy
  TYPO3.md                    TYPO3 upgrade impact policy and skill invocation gate (§9)
agents/
  checkpoint.md               Knowledge persistence agent
  contract-researcher.md      Upstream contract verification agent
  test-runner.md              Test execution agent
hooks/
  validate-commit-message.sh  PreToolUse hook: enforces Commits.md subject format
plugins/
  known_marketplaces.json     Marketplace registry (managed by CLI)
  marketplaces/
    local/                    Local MOSAIQ marketplace
      plugins/
        typo3-workflows/      TYPO3 workflow skills (upgrade, scanner, static-tests, full chain)
settings.json.example         Template for ~/.claude/settings.json
claude.json.example           Template for MCP server entries in ~/.claude.json
```

---

## Installation

### 1. Clone into `~/.claude`

```bash
git clone git@bitbucket.org:mosaiq-gmbh/mq.agent-ruleset.git ~/.claude
```

> If `~/.claude` already exists, clone elsewhere and copy/merge the contents manually.

### 2. Apply `settings.json`

Copy the example and adjust to taste:

```bash
cp ~/.claude/settings.json.example ~/.claude/settings.json
```

The example enables `acceptEdits` mode by default and wires up the commit message validation hook.

### 3. Merge MCP servers into `~/.claude.json`

> **Important:** `~/.claude.json` is a live file owned and continuously updated by Claude Code.
> **Never replace it.** Only merge the `mcpServers` key into your existing file.

`claude.json.example` contains only the `mcpServers` block. Merge it manually:

1. Open `~/.claude.json` in an editor.
2. Locate (or add) the top-level `"mcpServers"` key.
3. Copy the server entries from `claude.json.example` into that key.

Example result:

```json
{
  "mcpServers": {
    "atlassian": {
      "type": "http",
      "url": "https://mcp.atlassian.com/v1/mcp"
    },
    "chrome-devtools": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@0.18.1", "--headless=true", "--isolated=true", "--no-performance-crux", "--no-usage-statistics"]
    }
  },
  ... (rest of your existing ~/.claude.json)
}
```

The Atlassian MCP server requires an active Atlassian OAuth session. See [Atlassian MCP documentation](https://mcp.atlassian.com) for authentication setup.

### 4. Make the hook executable

```bash
chmod +x ~/.claude/hooks/validate-commit-message.sh
```

### 5. Register and install the local plugin marketplace

The TYPO3 workflow skills ship as a local Claude Code plugin and must be installed once after cloning.

```bash
# Register the local marketplace
claude plugins marketplace add ~/.claude/plugins/marketplaces/local

# Install the TYPO3 workflow plugin
claude plugins install typo3-workflows@local

# Verify
claude plugins list
```

Expected output of `claude plugins list`:
```
Installed plugins:

  ❯ typo3-workflows@local
    Version: 1.0.0
    Scope: user
    Status: ✔ enabled
```

---

## Updating

```bash
cd ~/.claude && git pull
```

After pulling, re-run the plugin installation step if the plugin was added or updated:

```bash
claude plugins update typo3-workflows
```

No further steps needed unless `settings.json.example` or `claude.json.example` have changed — check the diff and apply manually if so.

---

## TYPO3 Workflow Skills

The `typo3-workflows` plugin provides four skills for structured TYPO3 upgrade work. Skills require **explicit activation** — the agent will not start a workflow until you invoke the skill. See `rules/TYPO3.md` §9 for full trigger patterns.

| Skill | Invoke with | Use when |
|---|---|---|
| TYPO3 Upgrade Workflow | `/typo3-workflows:typo3-upgrade` | Running an upgrade, fixing deprecations or breaking changes |
| TYPO3 ExtensionScanner | `/typo3-workflows:typo3-scanner` | Running ExtensionScanner, triaging scanner findings |
| TYPO3 Static Code Tests | `/typo3-workflows:typo3-static-tests` | Running phpstan, rector, fractor, php-cs-fixer, TypoScript lint |
| TYPO3 Full Upgrade Chain | `/typo3-workflows:typo3-upgrade-full` | Running all three workflows in one chained session |

For the full chain, activate all four skills in the same session:

```
/typo3-workflows:typo3-upgrade-full
/typo3-workflows:typo3-upgrade
/typo3-workflows:typo3-scanner
/typo3-workflows:typo3-static-tests
```

---

## Project-level configuration

For project-specific agent state, extension ticket maps, triage artifacts, and `.aiassistant/` conventions, see the project's own `CLAUDE.md` and `.aiassistant/` directory.
