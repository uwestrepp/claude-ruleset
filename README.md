# mq.agent-ruleset

MOSAIQ Claude Code agent ruleset: global rules, custom agents, hooks, and configuration templates.

---

## Contents

```
CLAUDE.md                   Rule index (entry point for all projects)
rules/                      Rule files loaded by CLAUDE.md
  General.md                Global baseline behavior [CRITICAL]
  Meta.md                   Knowledge persistence and rule governance [CRITICAL]
  Batch.md                  Batch workflow foundation
  CleanCode.md              Clean code principles
  Commits.md                Commit message format and pre-commit checklist
  PER.md                    PHP PER-CS 3.0 coding style
  PER-Application.md        PER application policy
  TYPO3.md                  TYPO3 upgrade impact policy
  TYPO3-Changelog.md        TYPO3 deprecations/breaking changes index (v10–v14)
  TYPO3-ExtensionScanner.md ExtensionScanner workflow
  TYPO3-Static-Code-Tests.md Static code test workflow
  TYPO3-Upgrade-Workflow.md Upgrade execution workflow and DoD
agents/                     Custom subagents
  checkpoint.md             Knowledge persistence agent
  contract-researcher.md    Upstream contract verification agent
  test-runner.md            Test execution agent
hooks/
  validate-commit-message.sh  PreToolUse hook: enforces Commits.md subject format
settings.json.example       Template for ~/.claude/settings.json
claude.json.example         Template for MCP server entries in ~/.claude.json
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

---

## Updating

```bash
cd ~/.claude && git pull
```

No further steps needed unless `settings.json.example` or `claude.json.example` have changed — check the diff and apply manually if so.

---

## Project-level configuration

For project-specific agent state, extension ticket maps, triage artifacts, and `.aiassistant/` conventions, see the project's own `CLAUDE.md` and `.aiassistant/` directory.
