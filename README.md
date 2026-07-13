# claude-skills

A collection of [Claude Code](https://claude.com/claude-code) skills — reusable instructions + assets that Claude discovers automatically and applies to matching tasks.

## Skills

| Skill | What it does |
|---|---|
| [`runbook`](runbook/) | Document-first HTML runbooks: before executing any planned task (ops, infra, migration, deployment, refactor, …), Claude writes the plan of record into a self-contained HTML runbook with live status chips. You review **the runbook**, not a chat message; work starts on your go-ahead, and chips flip `PENDING → IN PROGRESS → DONE` as steps complete, so the doc always mirrors reality. |
| [`find-course`](find-course/) | LinkedIn Learning course finder: give it a learning goal, skill level, time budget, learning style, and result count, and Claude drives a real browser (via [Playwright MCP](https://github.com/microsoft/playwright-mcp)) to search the catalog, visit course pages, filter out anything off-goal / too long / too basic, and return a ranked comparison table with picks and a suggested learning order. Every fact comes from a page it actually loaded. Requires the Playwright MCP server (setup inside the skill); sign-in is always manual and persists across sessions. |

## Install

Copy the skill folder(s) you want into your Claude Code skills directory:

```bash
git clone https://github.com/dev-mohsinm/claude-skills.git
cp -r claude-skills/runbook ~/.claude/skills/runbook
cp -r claude-skills/find-course ~/.claude/skills/find-course
```

That's it — Claude Code auto-discovers skills in `~/.claude/skills/` (each skill is a folder with a `SKILL.md`). Trigger a skill explicitly by typing its name (`/runbook`, `/find-course`), or just describe a matching task and Claude applies it — e.g. ask Claude to plan an ops/infra task and it will offer the document-first runbook flow.

> Skills can also be installed per-project under `<repo>/.claude/skills/` if you want them scoped to one codebase.

## How the runbook skill works

1. **Plan → runbook.** Claude copies `runbook/template.html`, fills it with the task's verdict, locked decisions, item cards (with risk chips), verification checks, and rollback table — never inventing CSS, always shaping sections to the task.
2. **Review gate.** The runbook opens with an `AWAITING REVIEW` chip. Claude stops and hands you the file path; nothing executes until you say go.
3. **Living record.** During execution every completed step flips its chip and gets a dated *Completed:* note; wrong claims get dated *Correction:* notes instead of silent rewrites.

The generated docs are single-file HTML — no build step, no dependencies, dark mode on `Ctrl/⌘+Shift+L`.

## License

[MIT](LICENSE)
