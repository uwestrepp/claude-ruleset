# mq.agent-ruleset

MOSAIQ Claude Code ruleset: global behavioral rules, path-gated framework
guidance, reusable workflow skills, guard hooks, onboarding material, and
external rule exports.

`CLAUDE.md` is the authoritative index for the rules and skills that Claude
Code loads. For the design rationale and skill-routing guide, see
[`docs/RULESET-OVERVIEW.md`](docs/RULESET-OVERVIEW.md). For a teammate-facing
setup checklist and practical first steps, see [`ONBOARDING.md`](ONBOARDING.md).

## Contents

```
CLAUDE.md                       Authoritative rule and skill index
rules/
  Meta.md, General.md, Persona.md  Always-on governance and baseline behavior
  Organisation.md                  MOSAIQ and Funntastic organisation context
  CleanCode.md, PER.md, Twig.md    Path-gated language and authoring rules
  TYPO3.md, Drupal.md, Shopware.md Path-gated platform rules
agents/                         Reusable specialist agents
  checkpoint.md                 Durable-knowledge persistence
  contract-researcher.md        Upstream contract verification
  migration-pattern-researcher.md  Migration research
  payload-replay-verifier.md    Payload verification
  rule-index-auditor.md         Rule-index consistency audit
  test-runner.md                Test execution
hooks/                          Claude Code PreToolUse and SessionStart guards
bin/                            Rule-reference linting and friction reporting
.githooks/pre-commit           Runs the rule-reference and skill-ledger linter
plugins/marketplaces/local/    Local marketplace: core, composer, typo3, pocock
exports/                        Condensed variants for external agent harnesses
settings.json.example          Claude Code settings and hook template
claude.json.example            MCP server template for ~/.claude.json
ONBOARDING.md                  Team onboarding guide
setup.sh                       Non-destructive install and update helper
```

## Installation

The setup script is the supported route. It preserves existing runtime files,
merges new settings and MCP server entries without overwriting custom values,
and updates the `typo3` plugin when the Claude CLI is available.

```bash
git clone git@bitbucket.org:mosaiq-gmbh/mq.agent-ruleset.git ~/.claude
~/.claude/setup.sh
```

If `~/.claude` already exists as a Claude Code runtime directory but is not a
Git repository, the script overlays the ruleset while backing up affected
runtime files. It requires `git` and `jq`; the Claude CLI is optional, but
needed for the plugin steps. `chrome-devtools-mcp` in the MCP template needs
Node.js 20 or newer.

```
setup.sh [OPTIONS]

  -d, --dir DIR        Target directory (default: ~/.claude)
  -m, --mode MODE      install | update | auto (default: auto)
      --no-plugins     Skip marketplace registration and plugin work
      --no-mcp         Skip merging MCP servers into ~/.claude.json
      --force          Overwrite settings.json from the template (backs up first)
      --dry-run        Show intended changes without modifying files
  -v, --verbose        Show detailed output
  -h, --help           Show help
```

`setup.sh` currently registers the local marketplace and installs or updates
`typo3@local`. Install the other bundled plugins when their workflows are
useful to you:

```bash
claude plugins marketplace add ~/.claude/plugins/marketplaces/local
claude plugins install core@local
claude plugins install composer@local
claude plugins install pocock@local
```

## Updating

```bash
~/.claude/setup.sh
```

Update mode pulls the configured `origin`, deep-merges newly introduced keys
from `settings.json.example`, merges only the `mcpServers` key into
`~/.claude.json`, refreshes executable hook permissions, updates `typo3@local`,
and prints rule-relevant commits since the previous revision.

## Manual Setup

Use this only when diagnosing a setup step or intentionally managing the files
yourself.

### 1. Clone into `~/.claude`

```bash
git clone git@bitbucket.org:mosaiq-gmbh/mq.agent-ruleset.git ~/.claude
```

### 2. Apply `settings.json`

```bash
cp ~/.claude/settings.json.example ~/.claude/settings.json
```

### 3. Merge MCP servers into `~/.claude.json`

Merge the `mcpServers` object from `claude.json.example` into the existing
`~/.claude.json`; do not replace that live Claude Code file.

### 4. Make the hook executable

```bash
chmod +x ~/.claude/hooks/*.sh
git -C ~/.claude config core.hooksPath .githooks
```

### 5. Register and install the local plugin marketplace

Register the local marketplace and install the plugins required by your work
as shown above.

Keep machine-local account facts in `~/.claude/CLAUDE.local.md`, which is
imported by the rule index and ignored by Git. Store secrets only in separate,
mode-600 pointer files such as `~/.claude/.service-api-token`, never inline in
`CLAUDE.local.md`.

## Included Workflows

| Plugin | Scope |
|---|---|
| `core` | Commit discipline, git knowledge and hooks, batch governance, communication, estimates, brainstorming, adversarial review, and ruleset feedback |
| `composer` | Composer resolution and lock-file knowledge, gated updates, and generic major-version upgrades |
| `typo3` | TYPO3 upgrades, ExtensionScanner, static tests, and the complete upgrade chain |
| `pocock` | Vendored and adapted engineering aids for prototyping, interface design, architecture improvement, diagnosis, handoff, and concise output |

Skill activation varies deliberately. `CLAUDE.md` is the source of truth for
each skill's trigger and whether it is automatic, auto-suggested, or requires
an explicit slash command.

## Exports

[`exports/`](exports/README.md) contains condensed or adapted rule variants
for external agents and harnesses. These files are not loaded by Claude Code.
When changing a source under `rules/`, update any corresponding export in the
same change set.
