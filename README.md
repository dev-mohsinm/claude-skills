# claude-skills-and-plugins

A collection of [Claude Code](https://claude.com/claude-code) **skills** and **plugins**.

- **Skills** (`skills/`) — reusable instructions + assets that Claude discovers automatically and applies to matching tasks. Installed by copying a folder.
- **Plugins** (`plugins/`) — versioned bundles of skills **plus** hooks/agents/config that install as one unit. This repo is also a [plugin marketplace](https://code.claude.com/docs/en/plugins), so plugins install with two commands and stay upgradable.

## Plugins

| Plugin | What it does |
|---|---|
| [`runbook`](plugins/runbook/) | Document-first HTML runbooks: before executing any planned task (ops, infra, migration, deployment, refactor, …), Claude writes the plan of record into a self-contained HTML runbook with live status chips. You review **the runbook**, not a chat message; work starts on your go-ahead, and chips flip `PENDING → IN PROGRESS → DONE` as steps complete, so the doc always mirrors reality. Bundles two hooks: a **plan-offer** hook (when Claude writes a plan-mode plan, it offers to save it as a runbook up front) and a **chip-reminder** hook (when a session that touched a runbook ends, Claude double-checks that chips, the `Updated:` line, and the footer date reflect what actually happened). |

### Install (as a plugin — recommended)

```
/plugin marketplace add dev-mohsinm/claude-skills-and-plugins
/plugin install runbook@claude-skills-and-plugins
```

Or from a shell: `claude plugin marketplace add dev-mohsinm/claude-skills-and-plugins && claude plugin install runbook@claude-skills-and-plugins`.

The skill is then available as `/runbook:runbook`, and both hooks are active with zero `settings.json` editing. Upgrade later with `/plugin update runbook`.

## Skills

| Skill | What it does |
|---|---|
| [`find-course`](skills/find-course/) | LinkedIn Learning course finder: give it a learning goal, skill level, time budget, learning style, and result count, and Claude drives a real browser (via [Playwright MCP](https://github.com/microsoft/playwright-mcp)) to search the catalog, visit course pages, filter out anything off-goal / too long / too basic, and return a ranked comparison table with picks and a suggested learning order. Every fact comes from a page it actually loaded. Requires the Playwright MCP server (setup inside the skill); sign-in is always manual and persists across sessions. |

### Install (plain skills)

Copy the skill folder(s) you want into your Claude Code skills directory:

```bash
git clone https://github.com/dev-mohsinm/claude-skills-and-plugins.git
cp -r claude-skills-and-plugins/skills/find-course ~/.claude/skills/find-course
```

Claude Code auto-discovers skills in `~/.claude/skills/` (each skill is a folder with a `SKILL.md`). Trigger a skill explicitly by typing its name (`/find-course`), or just describe a matching task and Claude applies it. Skills can also be installed per-project under `<repo>/.claude/skills/` to scope them to one codebase.

> The runbook skill can also be used this way (`cp -r plugins/runbook/skills/runbook ~/.claude/skills/runbook`), but you lose the bundled hooks — prefer the plugin install.

## How the runbook plugin works

1. **Plan → runbook.** Claude copies the skill's `template.html`, fills it with the task's verdict, locked decisions, item cards (with risk chips), verification checks, and rollback table — never inventing CSS, always shaping sections to the task.
2. **Review gate.** The runbook opens with an `AWAITING REVIEW` chip. Claude stops and hands you the file path; nothing executes until you say go.
3. **Living record.** During execution every completed step flips its chip and gets a dated *Completed:* note; wrong claims get dated *Correction:* notes instead of silent rewrites. The chip-reminder hook backstops this: end a session with a stale runbook and Claude gets one nudge to sync it before finishing.

The generated docs are single-file HTML — no build step, no dependencies, dark mode on `Ctrl/⌘+Shift+L`.

## Repo layout

```
.claude-plugin/marketplace.json   # marketplace manifest (lists plugins/)
plugins/
  runbook/
    .claude-plugin/plugin.json    # plugin manifest (name, version)
    skills/runbook/               # the skill + its HTML template
    hooks/                        # hooks.json + hook scripts
skills/
  find-course/                    # plain copy-in skills
```

## License

[MIT](LICENSE)
