---
name: find-course
description: Search LinkedIn Learning through Playwright MCP browser automation and return ranked course recommendations for a learning goal. Use when the user wants course recommendations, asks to find/compare online courses for a topic or skill, or types /find-course. Collects real course details (instructor, duration, level, release date, exercise files) from pages actually visited, filters by the user's skill level and time budget, and reports a ranked comparison table with picks and a learning order.
license: MIT
---

# LinkedIn Learning Course Finder

Find, evaluate, and rank LinkedIn Learning courses for the user's learning goal using the Playwright MCP browser tools (`mcp__playwright__*`).

## Setup (once)

1. Register the Playwright MCP server at user scope:

   ```bash
   claude mcp add --scope user playwright npx @playwright/mcp@latest
   ```

   Restart Claude Code so the server loads, and confirm with `claude mcp list` (expect `playwright … ✔ Connected`).

2. No credentials are ever configured or typed by Claude. Playwright MCP uses a **persistent browser profile**, so once you sign in to LinkedIn Learning manually in the opened browser window, the session survives across Claude Code sessions and reboots.

3. **Customizing for library / SSO access (optional):** if you access LinkedIn Learning through a public library or your company's SSO rather than a personal subscription, paste your organization's LinkedIn Learning login URL into Step 1 below (replace the generic sign-in flow). Libraries typically provide a `linkedin.com/learning-login/go/…` link on their e-resources page.

## Step 0 — Gather parameters

Extract these five parameters from the user's input. If any are missing, ask for them (one AskUserQuestion call) before touching the browser:

1. **Goal** — topic or skill to learn (free text)
2. **Level** — beginner / intermediate / advanced
3. **Max duration** — longest acceptable course length
4. **Style** — e.g. practical/hands-on, conceptual, project-based
5. **Count** — number of recommendations (default 5)

## Step 1 — Open LinkedIn Learning (handle auth gracefully)

1. Use `browser_navigate` to open `https://www.linkedin.com/learning/`.
2. Take a `browser_snapshot` and check the state:
   - **Signed in** (personalized homepage, search bar visible): continue.
   - **Login wall / sign-in page**: do NOT ask for or enter credentials. If the user has configured an organization/library login URL (see Setup), navigate there; otherwise stay on LinkedIn's sign-in page. Tell the user: "A browser window is open — please sign in to LinkedIn Learning manually, then tell me when you're done." Wait for their confirmation, re-snapshot, and verify sign-in succeeded before continuing. The Playwright MCP profile is persistent, so they should only need to do this once.
   - **Page failed to load / timeout**: retry once. If it fails again, report the error and stop — do not loop.
3. Note: search and most course metadata are publicly visible, so the workflow also works signed-out — but the signed-in view additionally shows exercise-file details, so prefer signing in when accuracy about hands-on content matters.

## Step 2 — Search the catalog

1. Derive 2–4 search queries from the goal: the goal itself plus close variants and related keywords (e.g. for "production RAG systems": "retrieval augmented generation", "RAG LLM applications", "building LLM applications").
2. For each query, navigate to `https://www.linkedin.com/learning/search?keywords=<url-encoded query>`. If the page offers filters, prefer filtering to content type "Courses" (skip videos/learning paths unless nothing else matches).
3. Snapshot each results page and collect candidate courses: title, URL, and any duration/level shown inline. Gather roughly 3× the requested count of candidates across all queries, deduplicated by URL. Scroll or paginate only if the first page yields too few relevant hits. The "Similar courses" rail on course pages is a good extra source of candidates.
4. If a search returns zero results, say so and try a broader query before giving up. If all queries return nothing relevant, report that honestly rather than padding with off-topic courses.

## Step 3 — Collect details for each candidate

Visit each promising course page (up to ~2× the requested count — prioritize the most relevant-looking) and extract:

- Course title
- Instructor name(s)
- Full course URL (the canonical `linkedin.com/learning/<slug>` link)
- Duration
- Skill level (as stated by LinkedIn)
- Release date / last-updated date
- Main topics covered (from the description and table of contents)
- Whether exercise files, hands-on demos, projects, or quizzes are included

If a field isn't visible on the page, record it as "not verified" — never invent values. If a course page fails to load, skip it and note the skip.

## Step 4 — Filter

Exclude courses that:

- Don't actually address the user's goal (title keyword matches with unrelated content don't count)
- Exceed the max duration
- Are clearly introductory/basics-level when the user asked for intermediate or advanced

If filtering leaves fewer courses than requested, return what survived and say why the list is short — do not backfill with excluded courses.

## Step 5 — Rank

Score the survivors on, in order of weight:

1. **Relevance** — how directly the course covers the stated goal
2. **Practical value** — exercises, demos, real projects (weight this higher when style = hands-on)
3. **Recency** — newer release/update dates rank higher, especially for fast-moving topics
4. **Level fit** — matches the requested skill level

## Step 6 — Report

Produce, in this order:

1. **Ranked comparison table** — columns: Rank, Course, Instructor, Duration, Level, Released/Updated, Hands-on?, Link. Put the direct LinkedIn Learning URL in the Link column.
2. **Ranking rationale** — 1–2 sentences per course explaining its position.
3. **Picks** — Best course to start with, best practical course, and best advanced course (only if a genuinely advanced course made the list; otherwise say none qualified).
4. **Recommended learning order** — a sensible sequence through the recommended courses.
5. **Caveats** — anything that could not be verified (missing dates, unstated levels, pages that failed to load), and any constraint that had to be relaxed.

## Rules

- Never ask for, read, or type LinkedIn credentials; manual sign-in only.
- Every recommended course must have a course URL you actually visited or saw in search results.
- All course facts must come from pages you loaded this session — no training-data course knowledge.
- If the browser tools are unavailable (Playwright MCP not connected), tell the user to restart Claude Code so the `playwright` MCP server loads, and stop.
