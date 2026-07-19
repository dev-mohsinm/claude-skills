# Runbook authoring patterns (read when filling a fresh non-trivial runbook)

Extends the core SKILL.md. Two parts: proven optional patterns marked `<!-- OPTIONAL -->` in the template, and guidance for shaping/adding bespoke sections.

## Optional patterns (proven in real docs — use when they help, delete when they don't)

Each is marked `<!-- OPTIONAL -->` in the template. Keep the ones that fit the doc; strip the rest.

- **Item-card anatomy** — the item body has a labeled skeleton (*What's involved* → *Why / how* → optional `<pre>` commands → *What carries over / result* → *Verify* small). Use it to keep each item self-contained; delete any label that doesn't apply. For a trivial one-line item, a single sentence is fine. Briefs are **collapsed by default** (`<details>`, not `<details open>`); the **Expand all / Collapse all** button on the Items heading toggles every `<details>` at once — the button + script are already in the template, so keep them (and keep new item cards as plain `<details>`).
- **Correction / changelog note** — when a claim in a runbook turns out **wrong**, do NOT silently overwrite it. Add a `<span class="status done">CORRECTED {date}</span>` chip by the item title and a `<p class="small"><strong>Correction {date}:</strong> originally said X; actually Y.</p>`. This keeps the "doc mirrors reality" honesty — the reader sees what changed and why.
- **Disposition chip** (`<span class="disp">…</span>`) — an optional 2nd chip tagging the *kind* of work, separate from risk: e.g. `REBUILD`, `PORTABLE`, `STALE`, `REPROVISION`, `REINSTALL`. For feasibility/migration docs it can also become a summary-table column; for plain execution runbooks, usually skip it.
- **Risk-legend prose** — the short `<p class="small">` block under the legend chips defines what HIGH/MED/LOW/PORTABLE mean *for this doc*. Keep it for risk/feasibility docs; delete it for simple execution runbooks where the chips are self-explanatory.
- **Cost + Risk item footer** — end each item card with `<p><strong>Cost:</strong> … · <strong>Risk:</strong> …</p>`. Forces a per-item statement of price and residual blast radius. Drop the Cost half when nothing costs money.
- **Effort column** — the summary table has an optional `Effort` column (rough per-item time, e.g. `~5 min`, `~1 hr`). Great for tracker/checklist runbooks; delete the `Effort` th+td for feasibility docs where time-per-item isn't meaningful.
- **"Out of scope (explicitly NOT doing)" section** — list what was *deliberately* excluded and why. Distinct from "What gets worse" (which is honest downsides of what you ARE doing). Keeps priority honest and pre-empts scope creep. Delete if nothing was consciously cut.
- **Priority axis instead of risk** — an item's severity chip/border can express **risk** (how dangerous — default: `risk-*` chips + `item-card high|med|low|ok`) OR **priority** (how urgent/important — `priority-1|2|3` chips + `item-card p1|p2|p3`). Use priority for hardening/backlog/follow-up docs that think in P1/P2/P3; rename the summary column "Risk"→"Pri" and add a matching priority-legend. Keep risk for feasibility/change docs. Pick one axis per doc — don't mix.

## Shape the doc to the task — add, rename, and cut sections freely

The template is a **starting point, not a contract**. It offers an always-useful spine (meta, verdict, decisions, summary, items, verification, rollback), but every runbook should be shaped to its task in both directions:

- **Add / rename:** actively ask *"What would make THIS doc genuinely useful that the template doesn't already cover?"* — then add bespoke `<h2>` sections, or rename stock headings to task-specific ones that say it better (e.g. "Cutover window" instead of "Recommended sequence", "What the auditor will ask" instead of "Verification").
- **Cut:** any stock section that doesn't earn its place goes — an empty or filler-filled section is worse than no section (only the ops Verification/Rollback omissions need the one-line why-note from the core rules).

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
| is dense with IDs/hosts/accounts | **Key entities** — a reference table of the specific instances (hosts, account IDs, buckets); the always-on Glossary already covers service names and acronyms |
| touches creds/permissions/data | **Security considerations** |
| spans people or days | **Timeline / owners** — phases with who + when |
| is an incident write-up | **RCA shape** — timeline → root cause → contributing factors → action items |
| ships user-facing UI | **Visual states / screenshots**, or a **test matrix** (cases × platforms) |

When in doubt, invent a section the menu doesn't list — the goal is a doc that fits the task, and thinking beyond this menu is encouraged.
