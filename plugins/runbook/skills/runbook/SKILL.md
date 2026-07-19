---
name: runbook
description: Create an HTML runbook/plan-of-record BEFORE executing any task that has a pre-execution plan worth documenting — ops, infra, machine-setup, migration, deployment, config changes, features, refactors, pre-deployment code reviews. For ops/infra it is mandatory and comes before plan review (the user reviews the runbook, not a chat plan). For any other planned task, offer to save the approved plan as a runbook before executing. Also use when the user types /runbook, or when flipping status chips after steps complete.
license: MIT
---

# HTML Runbook (document-first workflow)

The rule: for ops/infra work, the plan of record is written into an HTML runbook FIRST, the user reviews **the runbook** (not a chat message), and execution starts only on their go-ahead. As steps complete, chips flip so the doc always mirrors reality.

For **any other planned task** (feature, refactor, config change, …): after a plan is approved, ask the user whether to save it as a runbook before executing — if yes, read `<skill-dir>/references/plan-to-runbook.md` for the mapping (also covers pre-deployment code reviews).

`<skill-dir>` below means this skill's own directory (where this SKILL.md lives — the path is shown when the skill loads). If it isn't evident: `find ~/.claude/plugins ~/.claude/skills -path '*runbook/template.html' -print -quit 2>/dev/null`.

## Creating a runbook — never write CSS

1. **Copy the template — do NOT Read it, do NOT write HTML boilerplate or CSS yourself:**
   ```bash
   cp "<skill-dir>/template.html" <dest>.html
   ```
   Destination: the project's `docs/runbooks/` folder if it exists, else the project's `docs/`, else `~/docs/`. Kebab-case descriptive filename (e.g. `main-account-handover.html`).
   - **Check for an existing runbook first** — a doc already covering this work gets updated (chips, `Updated:` line, correction notes), not near-duplicated.
   - **Sensitive-content gate:** if the runbook will hold infra/access detail (IPs, hostnames, account IDs, creds paths) and the destination is inside a git repo, verify the path is gitignored (`git check-ignore -q <dest> && echo ignored`); if not, use a gitignored location or `~/docs/` — never let a sensitive runbook become committable.

2. **Read the fresh copy once, then fill content with targeted Edit calls only** (never Read the template itself). It contains `{{PLACEHOLDER}}` markers for: title, meta block, headline verdict, locked-decisions rows, glossary rows, summary-table rows, item-cards, sequence, verification rows, rollback rows, footer date. Duplicate the single example row/card per real item. Non-negotiable filling rules:
   - Every item/step-tracking table carries a **Status column with a chip** (`<span class="status …">…</span>`); the summary table's **One-line verdict** column is always filled; the **item title** (not the number) hyperlinks to its `#item-N` card; item-card risk classes `item-card high|med|low|ok` + matching `status risk-*` chip.
   - **Never touch the `<style>` block** or invent new CSS — if a doc seems to need new styling, ask the user.

3. **Shape the doc to the task.** Any stock section is skippable, headings are renameable/inventable, bespoke sections are encouraged — one honesty rule: if an ops/infra runbook drops Verification or Rollback, leave a one-line note saying why. Before filling any non-trivial runbook, read `<skill-dir>/references/authoring-patterns.md` (proven optional patterns + a menu of high-value bespoke sections); a short simple runbook can skip it.

4. **Always-on conventions (not optional):**
   - **Glossary section** — every runbook: one table of services/tools named in the doc (plain-language what-it-is + role here) and one expanding every acronym. Self-contained for a reader who doesn't know the stack; when a later edit introduces a new name, add it to the Glossary in the same edit.
   - **`Updated:` line** in the meta block — a running dated changelog (starts `—` for a new doc; append an entry on every material change).
   - **"Verified via" evidence** — back factual claims with the command that proved them, inline. Don't assert state you didn't observe.
   - **Custom chip text is fine** — chip *styles* are fixed but *text* isn't: `AWAITING USER`, `SOAK UNTIL 2026-06-27`, `BLOCKED — waiting on DNS` (reuse the closest style: `awaiting`/`done`/`in-progress`/`blocked`).

5. **Initial state:** every item/verification chip is `<span class="status pending">PENDING</span>`; the H1 chip is `<span class="status awaiting">AWAITING REVIEW</span>`.

6. **Pre-handoff check, then stop:** `grep -n '{{' <dest>.html` — any hit is an unfilled placeholder or leftover template comment; fix every one. Then STOP, give the user the absolute `file:///…` path, and ask them to review the runbook. Do not begin execution.

## During and after execution

- On go-ahead: flip the H1 chip to `in-progress`/`IN PROGRESS`.
- As each step completes: flip its chip to `done`/`DONE` and append a dated note inside the item, e.g. `<p class="small"><em>Completed: 2026-07-07 — what actually happened.</em></p>`. Blocked steps get `blocked`/`BLOCKED` with the reason.
- When a claim turns out **wrong**: never silently overwrite — add a `CORRECTED {date}` chip and a `<p class="small"><strong>Correction {date}:</strong> originally said X; actually Y.</p>` note.
- When everything is done: H1 chip → `DONE`, update the footer "Last updated" date.
- Every material update (chip flip, correction, new item) also appends a dated entry to the `Updated:` line in the meta block — don't let the changelog go stale while chips move.
