#!/usr/bin/env bash
# Runbook plugin — Stop hook.
#
# If a runbook HTML was written/edited this session (sentinel dropped by
# runbook-plan-offer.sh), nudge Claude ONCE to verify the doc still mirrors
# reality — status chips, the `Updated:` line, and the footer date — before
# finishing. The sentinel is consumed and stop_hook_active is honored, so this
# can never loop: at most one continuation per runbook-touching burst of work.

input=$(cat)
sid=$(printf '%s' "$input" | jq -r '.session_id // "nosid"' 2>/dev/null)
active=$(printf '%s' "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)

sentinel="/tmp/claude-runbook-active-${sid}"
[ -e "$sentinel" ] || exit 0

rb=$(head -1 "$sentinel" 2>/dev/null)
rm -f "$sentinel" 2>/dev/null

# Already continuing from a stop hook — don't re-trigger, just clean up.
[ "$active" = "true" ] && exit 0

reason="A runbook was modified this session (${rb}). Before finishing, verify the doc mirrors reality: every completed/blocked step's status chip is flipped, dated notes are appended inside touched items, the Updated: line in the meta block has an entry for today's changes, and the footer 'Last updated' date is current. If everything is already in sync, no edits are needed — just finish."

jq -n --arg reason "$reason" '{"decision":"block","reason":$reason}'
