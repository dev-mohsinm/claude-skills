#!/usr/bin/env bash
# Runbook plugin — PostToolUse hook (Write|Edit).
#
# 1) Plan-offer: when Claude writes a plan file in plan mode, remind it — ONCE per
#    session, at plan-write time (before approval) — to offer saving the plan as an
#    HTML runbook. Path-gated to Claude's plans directories so it only fires for
#    plan files; session-keyed sentinel in /tmp makes it fire once per session.
# 2) Chip-reminder tracking: when a runbook HTML is written or edited, record a
#    session-keyed sentinel so the Stop hook (runbook-chip-reminder.sh) can nudge
#    Claude to keep status chips in sync with reality.

input=$(cat)
fp=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
sid=$(printf '%s' "$input" | jq -r '.session_id // "nosid"' 2>/dev/null)

case "$fp" in
  */.claude/plans/*|*/.claude-b/plans/*)
    sentinel="/tmp/claude-runbook-offer-${sid}"
    if [ ! -e "$sentinel" ]; then
      touch "$sentinel" 2>/dev/null
      cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"A plan file was just written in plan mode. As part of presenting this plan, FIRST use AskUserQuestion to ask the user whether to also save it as an HTML runbook (per the runbook skill: copy the skill's template.html to the destination and fill placeholders from the plan). Make this offer up front at plan-write time, NOT after approval or at execution. If yes, create the runbook so it becomes the plan of record; if no, proceed with the plan."}}
JSON
    fi
    ;;
  */docs/runbooks/*.html|*runbook*.html)
    printf '%s\n' "$fp" > "/tmp/claude-runbook-active-${sid}" 2>/dev/null
    ;;
esac
