---
name: runbook
description: Create an HTML runbook/plan-of-record BEFORE executing any task that has a pre-execution plan worth documenting — ops, infra, machine-setup, migration, deployment, config changes, features, refactors, pre-deployment code reviews. For ops/infra it is mandatory and comes before plan review (the user reviews the runbook, not a chat plan). For any other planned task, offer to save the approved plan as a runbook before executing. Also use when the user types /runbook, or when flipping status chips after steps complete.
license: MIT
---

# HTML Runbook (document-first workflow)

The rule: for ops/infra work, the plan of record is written into an HTML runbook FIRST, the user reviews **the runbook** (not a chat message), and execution starts only on their go-ahead. As steps complete, chips flip so the doc always mirrors reality.

For **any other planned task** (feature, refactor, config change, …): after a plan is approved, ask the user whether to save the plan as a runbook before executing — see "Saving an approved plan as a runbook" below.

## Creating a runbook — never write CSS

1. **Copy the template — do NOT Read it, do NOT write HTML boilerplate or CSS yourself:**
   ```bash
   cp ~/.claude/skills/runbook/template.html <dest>.html
   ```
   Destination: the project's `docs/runbooks/` folder if it exists, else the project's `docs/`, else `~/docs/`. Use a kebab-case descriptive filename (e.g. `main-account-handover.html`).
   - **Check for an existing runbook first** — search the destination for a doc already covering this work and update it (chips, `Updated:` line, correction notes) instead of creating a near-duplicate.
   - **Sensitive-content gate:** if the runbook will hold infra/access detail (IPs, hostnames, account IDs, creds paths) and the destination is inside a git repo, verify the path is gitignored first (`git check-ignore -q <dest> && echo ignored`). If it isn't, use a gitignored location or `~/docs/` — never let a sensitive runbook become committable.

2. **Read the fresh copy once, then fill content with targeted Edit calls only.** (The Edit tool requires one Read of the destination file — it's ~9KB, cheap. Never Read the template itself or any old reference doc; Reading an existing runbook you're *updating* is fine and required.) The template contains `{{PLACEHOLDER}}` markers for: title, meta block (Related/Context/Purpose/Scope/Created), headline verdict, locked-decisions rows, summary-table rows, item-cards, sequence, verification rows, rollback rows, footer date.
   - Duplicate the single example row/card for each real item. In the summary table, the **item title** is the hyperlink to its `#item-N` card (not the number — the number stays plain text); keep row count and anchors in sync with the cards.
   - Every item/step-tracking table (summary, verification) must carry a **Status column with a chip** (`<span class="status …">…</span>`) — never leave status as plain text or omit the column.
   - The summary table also has a **One-line verdict** column (`{{ONE_LINE_VERDICT}}`) — always fill it with the crisp per-row takeaway (what's the upshot of this item). Not optional.
   - Item-card risk classes: `item-card high|med|low|ok` (left border) + matching `status risk-*` chip.
   - **Any section is skippable, not just the marked ones.** The `<!-- OPTIONAL -->` markers are hints, not the full list — if a stock heading (Locked decisions, Recommended sequence, even Verification/Rollback) adds nothing for this task, delete it. One honesty rule: if an ops/infra runbook drops Verification or Rollback, leave a one-line note saying why (e.g. "No rollback section — read-only audit, nothing to undo") so the omission is visibly deliberate, not forgotten.
   - **Headings are renameable and inventable.** If a task-specific heading says it better than the stock one ("Cutover window" instead of "Recommended sequence", "What the auditor will ask" instead of "Verification"), use it. The doc should read like it was written for this task, not poured into a mold.
   - Never touch the `<style>` block. If a doc seems to need new styling, ask the user instead of improvising.

### Optional patterns (proven in real docs — use when they help, delete when they don't)

Each is marked `<!-- OPTIONAL -->` in the template. Keep the ones that fit the doc; strip the rest.

- **Item-card anatomy** — the item body has a labeled skeleton (*What's involved* → *Why / how* → optional `<pre>` commands → *What carries over / result* → *Verify* small). Use it to keep each item self-contained; delete any label that doesn't apply. For a trivial one-line item, a single sentence is fine. Briefs are **collapsed by default** (`<details>`, not `<details open>`); the **Expand all / Collapse all** button on the Items heading toggles every `<details>` at once — the button + script are already in the template, so keep them (and keep new item cards as plain `<details>`).
- **Correction / changelog note** — when a claim in a runbook turns out **wrong**, do NOT silently overwrite it. Add a `<span class="status done">CORRECTED {date}</span>` chip by the item title and a `<p class="small"><strong>Correction {date}:</strong> originally said X; actually Y.</p>`. This keeps the "doc mirrors reality" honesty — the reader sees what changed and why.
- **Disposition chip** (`<span class="disp">…</span>`) — an optional 2nd chip tagging the *kind* of work, separate from risk: e.g. `REBUILD`, `PORTABLE`, `STALE`, `REPROVISION`, `REINSTALL`. For feasibility/migration docs it can also become a summary-table column; for plain execution runbooks, usually skip it.
- **Risk-legend prose** — the short `<p class="small">` block under the legend chips defines what HIGH/MED/LOW/PORTABLE mean *for this doc*. Keep it for risk/feasibility docs; delete it for simple execution runbooks where the chips are self-explanatory.
- **Cost + Risk item footer** — end each item card with `<p><strong>Cost:</strong> … · <strong>Risk:</strong> …</p>`. Forces a per-item statement of price and residual blast radius. Drop the Cost half when nothing costs money.
- **Effort column** — the summary table has an optional `Effort` column (rough per-item time, e.g. `~5 min`, `~1 hr`). Great for tracker/checklist runbooks; delete the `Effort` th+td for feasibility docs where time-per-item isn't meaningful.
- **"Out of scope (explicitly NOT doing)" section** — list what was *deliberately* excluded and why. Distinct from "What gets worse" (which is honest downsides of what you ARE doing). Keeps priority honest and pre-empts scope creep. Delete if nothing was consciously cut.
- **Priority axis instead of risk** — an item's severity chip/border can express **risk** (how dangerous — default: `risk-*` chips + `item-card high|med|low|ok`) OR **priority** (how urgent/important — `priority-1|2|3` chips + `item-card p1|p2|p3`). Use priority for hardening/backlog/follow-up docs that think in P1/P2/P3; rename the summary column "Risk"→"Pri" and add a matching priority-legend. Keep risk for feasibility/change docs. Pick one axis per doc — don't mix.

### Always-on conventions (not optional)

- **`Updated:` line** in the meta block — a running dated changelog of what changed since creation (e.g. `2026-07-07 — item 3 done; 2026-07-06 — added item 5`). Start it as `—` for a brand-new doc; append an entry every time you materially change the doc. This is how a runbook stays a *living* record.
- **"Verified via" evidence** — back factual claims with the command that proved them, inline: *"Verified via `aws cloudwatch describe-alarms` — zero alarms."* Applies the same honesty as correction notes: a reader can re-run the check. Don't assert state you didn't observe.
- **Custom chip text is fine** — the chip *styles* are fixed but their *text* isn't. Use nuanced states when they're truer: `AWAITING USER`, `PARTIALLY DONE`, `SOAK UNTIL 2026-06-27`, `BLOCKED — waiting on DNS` (reuse the closest style: `awaiting`/`done`/`in-progress`/`blocked`).

3. **Initial state:** every item/verification chip is `<span class="status pending">PENDING</span>` and the H1 chip is `<span class="status awaiting">AWAITING REVIEW</span>`.

4. **Pre-handoff check, then stop:** run `grep -n '{{' <dest>.html` — any hit is an unfilled placeholder or a leftover template comment (e.g. the correction-note stub); fix every one. Then STOP, give the user the absolute `file:///…` path, and ask them to review the runbook. Do not begin execution.

## Shape the doc to the task — add, rename, and cut sections freely

The template is a **starting point, not a contract**. It offers an always-useful spine (meta, verdict, decisions, summary, items, verification, rollback), but every runbook should be shaped to its task in both directions:

- **Add / rename:** actively ask *"What would make THIS doc genuinely useful that the template doesn't already cover?"* — then add bespoke `<h2>` sections, or rename stock headings to task-specific ones that say it better.
- **Cut:** any stock section that doesn't earn its place goes — an empty or filler-filled section is worse than no section (only the ops Verification/Rollback omissions need the one-line why-note from step 2).

What's *not* flexible: the meta block, status chips on anything trackable, the review gate, and the no-new-CSS rule.

**Rules for added sections:**
- Reuse the existing CSS primitives only — `<table>` (with a Status chip column if anything is trackable), `.item-card`, `.status`/`.risk-*`/`.disp` chips, `.meta`, `.small`, `<code>`/`<pre>`, `<details>`. **Never invent new CSS** — if a section seems to need it, ask the user.
- Place them where they read best (usually after the summary or after the items). Match the house style: `<h2>` header, concise prose, tables over walls of text.
- Add only what earns its place. Two sharp bespoke sections beat ten generic ones.

**Menu of high-value candidates (pick per task — this list is a prompt, not a checklist):**

| Add when the task… | Section to add |
|---|---|
| moves/reshapes a system | **Before → After** two-column table (current state vs target) |
| has data flow or topology | **Architecture / flow** — an ASCII diagram in `<pre>`, or a labeled step list |
| chose among real alternatives | **Alternatives considered** — options + why-rejected (distinct from the locked *decisions*) |
| rests on unverified beliefs | **Assumptions & open questions** — what's taken as true, what's still unknown |
| touches money/disk/quota/tokens | **Cost / resource impact** — estimates before vs after |
| needs things in place first | **Prerequisites / dependencies** — what must be true before step 1 |
| could break other things | **Blast radius** — who/what is affected if it goes wrong |
| has a fuzzy "done" | **Success criteria / metrics** — measurable done, separate from mechanical verification |
| is dense with IDs/hosts/accounts | **Key entities / glossary** — a reference table of the nouns |
| touches creds/permissions/data | **Security considerations** |
| spans people or days | **Timeline / owners** — phases with who + when |
| is an incident write-up | **RCA shape** — timeline → root cause → contributing factors → action items |
| ships user-facing UI | **Visual states / screenshots**, or a **test matrix** (cases × platforms) |

When in doubt, invent a section the menu doesn't list — the goal is a doc that fits the task, and thinking beyond this menu is encouraged.

## Saving an approved plan as a runbook

When a plan was already approved (e.g. via plan mode / ExitPlanMode) and the user says yes to saving it:

1. `cp` the template as above (same destination rules; never Read it, never write CSS).
2. Map the plan onto the template: plan Context → meta block Purpose/Context; the decision(s) made → locked-decisions table; each implementation step → a summary row + item-card (risk class by judgment); the plan's verification section → verification table; undo strategy → rollback table.
3. Because the plan is already approved, skip the `AWAITING REVIEW` gate: after creating the runbook, ask the user for go-ahead to execute; on go-ahead flip the H1 chip to `in-progress`/`IN PROGRESS`. (The `AWAITING REVIEW` gate remains for the ops document-first flow, where the runbook itself is the review artifact.)
4. If the user says no to saving, proceed with the plan directly — do not create the file.

**Pre-deployment code reviews** map the same way: each finding → a summary row + item-card with the risk chip set by severity, the review's overall verdict → headline Verdict, fix-confirmation checks → verification table, and "ship / hold" → the H1 chip (`AWAITING REVIEW` until the user signs off).

## During and after execution

- On go-ahead: flip the H1 chip to `in-progress`/`IN PROGRESS`.
- As each step completes: flip its chip to `done`/`DONE` and append a dated note inside the item, e.g. `<p class="small"><em>Completed: 2026-07-07 — what actually happened.</em></p>`. Blocked steps get `blocked`/`BLOCKED` with the reason.
- When everything is done: H1 chip → `DONE`, update the footer "Last updated" date.
- Every material update (chip flip, correction, new item) also appends a dated entry to the `Updated:` line in the meta block — that line is the doc's changelog; don't let it go stale while chips move.

