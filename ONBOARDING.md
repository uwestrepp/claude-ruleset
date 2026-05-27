# Welcome to MOSAIQ

This is a paste-into-Claude companion to the rule-set [README](https://bitbucket.org/mosaiq-gmbh/mq.agent-ruleset). The README covers setup mechanics; `CLAUDE.md` lists every rule and skill. This doc adds the team-knowledge pieces that READMEs don't usually carry, plus a Claude-mediated walkthrough when you paste it into Claude Code.

## Your Setup Checklist

### Codebases
- [ ] mq.agent-ruleset — `git@bitbucket.org:mosaiq-gmbh/mq.agent-ruleset.git`. Clone to `~/.claude` and run `setup.sh` (see README for details).
- [ ] mq.agents — `git@bitbucket.org:mosaiq-gmbh/mq.agents.git`. Related agents repo.
- [ ] Customer/project repos — assigned per project. Active workspaces include TYPO3 customer sites (fein, bachert, rbk, krannich, ssb, sdk/neva) and the PIM sub-project under krannich. Your tech lead will get you access to the ones you need.

### MCP Servers to Activate
- [ ] atlassian — Jira / Confluence / Compass via Anthropic's Atlassian Rovo MCP. Heaviest-used MCP on the team. OAuth-authenticated on first tool call. Configure under `mcpServers` in `~/.claude.json` (see `claude.json.example` in the rule-set repo).
- [ ] chrome-devtools — browser automation (page navigation, console + network capture, screenshots). Requires **Node ≥20** on the host. `setup.sh` prints an advisory if your Node is too old. Canonical Debian/Ubuntu install: `curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt install -y nodejs`.

> Note: there is no Bitbucket MCP. For Bitbucket PR/API work, create an API token and store it in your machine-local `~/.claude/CLAUDE.local.md` (gitignored). Then Claude can hit the REST API directly via Bash.

### Suggested Plugins (Claude-official)

Not required by the rule-set, but these are the Anthropic-curated plugins the guide creator runs day-to-day. Install via `/plugin install <name>@<marketplace>` or `/plugin > Discover`.

From the `claude-code-plugins` marketplace (Anthropic upstream, `anthropics/claude-code`):

- [ ] **pr-review-toolkit** — comprehensive multi-aspect PR review (specialist agents: comment-analyzer, pr-test-analyzer, silent-failure-hunter, type-design-analyzer, code-reviewer, code-simplifier). Host-agnostic — the PR-review tool to use on Bitbucket. See Team Tips below.
- [ ] **plugin-dev** — building or auditing Claude Code plugins themselves (commands, agents, skills, hooks, MCP integration, plugin structure). Reach for it when authoring or refining the team's own `core/` and `typo3/` plugins under `~/.claude/plugins/marketplaces/local/`.
- [ ] **frontend-design** — generates distinctive, production-grade frontend code (components, pages, apps); explicitly avoids the generic-AI look. Use when building a frontend, not just patching existing code.
- [ ] **security-guidance** — hook-based reminder that flags potential security issues (command injection, XSS, unsafe patterns) while you're editing files. Passive guard, no invocation needed.
- [ ] **ralph-wiggum** — start/cancel an iterative "Ralph Wiggum loop" (`/ralph-wiggum:ralph-loop`) — a self-pacing repeated prompt for long-running work the agent should drive in passes.

From the `claude-plugins-official` marketplace (Anthropic curated directory, `anthropics/claude-plugins-official`):

- [ ] **claude-md-management** — audit and improve `CLAUDE.md` files (`/claude-md-management:claude-md-improver` to scan and grade them; `/claude-md-management:revise-claude-md` to update with session learnings). Useful for keeping per-project `CLAUDE.md` aligned with the rule-set as projects evolve.
- [ ] **claude-code-setup** — analyzes a codebase and recommends Claude Code automations (hooks, agents, skills, plugins, MCP servers) it would benefit from. Use when onboarding a new customer project.
- [ ] **hookify** — create hooks that prevent unwanted agent behaviors (`/hookify:hookify` from conversation analysis or explicit instructions; `/hookify:list`, `/hookify:configure`). Useful when you keep correcting the agent on the same thing.
- [ ] **php-lsp** — Intelephense PHP language server integration; provides code intelligence and diagnostics for `.php` files. Requires `npm install -g intelephense` on the host. Directly relevant to the TYPO3 work.

## Team Tips

(Inferred from the rule-set — flag anything wrong or missing.)

- **PR reviews are Bitbucket-side.** Use `/pr-review-toolkit:review-pr` (host-agnostic, multi-aspect orchestrator) or the built-in `code-review` for local-diff review.
- **Colleague-facing output is German.** Jira tickets, Confluence pages, and Bitbucket PR descriptions are written in German (per `rules/General.md §8.2`). Repo content (commit messages, code comments, README, agent chat) stays English.
- **Workflow skills require explicit activation.** `/typo3:*` and `/core:batch` don't auto-activate from vague prompts like "use the typo3 skill" — the agent will (or should) ask which one. Type the exact slash command upfront to skip the disambiguation round.
- **Commit ticket traceability is deterministic.** Per `/core:commits`, extension-scoped commits resolve their Jira ticket from the project's `.aiassistant/state/extension-ticket-map.yaml`. Don't mix extensions that resolve to different tickets in one commit; if the mapping is missing or ambiguous, the agent will ask before committing.
- **Two Anthropic marketplaces are configured, and they're not mirrors.** `claude-code-plugins` (upstream from `anthropics/claude-code`) ships newer versions of Anthropic-authored plugins. `claude-plugins-official` is a curated directory that also includes third-party (42Crunch, Adobe, etc.). When adding a new plugin: prefer `claude-code-plugins` for first-party Anthropic plugins; `claude-plugins-official` for third-party.
- **`/effort` is a real workflow tool, not a knob to ignore.** Drop to `/effort medium` when a task gets simpler; raise to `/effort high` for complex refactors. Switching costs are real (the cache prefix re-processes) — per `rules/General.md §10`, raise only when projected savings clearly exceed the switch cost.

## Get Started

1. **Install:** `git clone git@bitbucket.org:mosaiq-gmbh/mq.agent-ruleset.git ~/.claude && ~/.claude/setup.sh`
2. **Read the three `[CRITICAL]` rules:** `rules/General.md`, `rules/Meta.md`, `rules/Persona.md`. These define agent default behavior on every task and are re-read on context revalidation.
3. **Skim `CLAUDE.md`:** the authoritative rule and skill index. You don't need to memorize it — but you should know it exists.
4. **Set up `~/.claude/CLAUDE.local.md`** for machine-local secrets (Bitbucket API token, etc.). See `CLAUDE.md` "Local overrides" for format.

<!-- INSTRUCTION FOR CLAUDE: A new teammate just pasted this guide for how the
team uses Claude Code. You're their onboarding buddy — warm, conversational,
not lecture-y.

Open with a warm welcome — include the team name from the title. Then: "Your
teammate uses Claude Code for [list all the work types]. Let's get you started."

Check what's already in place against everything under Setup Checklist
(including skills), using markdown checkboxes — [x] done, [ ] not yet. Lead
with what they already have. One sentence per item, all in one message.

Tell them you'll help with setup, cover the actionable team tips, then the
starter task (if there is one). Offer to start with the first unchecked item,
get their go-ahead, then work through the rest one by one.

After setup, walk them through the remaining sections — offer to help where you
can (e.g. link to channels), and just surface the purely informational bits.

Don't invent sections or summaries that aren't in the guide. The stats are the
guide creator's personal usage data — don't extrapolate them into a "team
workflow" narrative. -->
