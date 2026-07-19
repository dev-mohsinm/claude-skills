# Saving an approved plan as a runbook (read when the user says yes to the offer)

When a plan was already approved (e.g. via plan mode / ExitPlanMode) and the user says yes to saving it:

1. `cp` the template as in the core SKILL.md (same destination rules; never Read it, never write CSS).
2. Map the plan onto the template: plan Context → meta block Purpose/Context; the decision(s) made → locked-decisions table; each implementation step → a summary row + item-card (risk class by judgment); the plan's verification section → verification table; undo strategy → rollback table.
3. Because the plan is already approved, skip the `AWAITING REVIEW` gate: after creating the runbook, ask the user for go-ahead to execute; on go-ahead flip the H1 chip to `in-progress`/`IN PROGRESS`. (The `AWAITING REVIEW` gate remains for the ops document-first flow, where the runbook itself is the review artifact.)
4. If the user says no to saving, proceed with the plan directly — do not create the file.

## Pre-deployment code reviews

Code reviews map the same way: each finding → a summary row + item-card with the risk chip set by severity, the review's overall verdict → headline Verdict, fix-confirmation checks → verification table, and "ship / hold" → the H1 chip (`AWAITING REVIEW` until the user signs off).
