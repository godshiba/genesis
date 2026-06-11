#!/bin/bash
# GENESIS G7 session gate (Stop hook, blocking).
#
# Blocks ending a turn when the working tree has uncommitted changes but
# docs/registry/SESSION_LOG.md was not updated. Satisfied by /genesis:close
# or any append to the session log. Fails open: any unexpected condition
# allows the stop rather than trapping the user.
set -u

command -v python3 >/dev/null 2>&1 || exit 0
command -v git >/dev/null 2>&1 || exit 0

input=$(cat 2>/dev/null) || exit 0
parsed=$(printf '%s' "$input" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    print(str(d.get("stop_hook_active", False)).lower())
    print(d.get("cwd", ""))
except Exception:
    print("true")
    print("")
') || exit 0

active=$(printf '%s\n' "$parsed" | sed -n 1p)
cwd=$(printf '%s\n' "$parsed" | sed -n 2p)

# Loop prevention: we already blocked once this stop cycle.
[ "$active" = "true" ] && exit 0
[ -n "$cwd" ] && [ -d "$cwd" ] || exit 0

# Only guard GENESIS projects inside a git work tree.
log_rel="docs/registry/SESSION_LOG.md"
[ -f "$cwd/$log_rel" ] || exit 0
git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

dirty=$(git -C "$cwd" status --porcelain 2>/dev/null) || exit 0
[ -n "$dirty" ] || exit 0

# Work = uncommitted changes outside docs/registry/. Registry-only edits do
# not demand a session entry by themselves.
work=$(printf '%s\n' "$dirty" | grep -v ' docs/registry/' | grep -c .) || work=0
[ "$work" -gt 0 ] || exit 0

# Allow if the session log itself is among the uncommitted changes.
printf '%s\n' "$dirty" | grep -qF "$log_rel" && exit 0

echo "G7 session gate (GENESIS): the working tree has uncommitted changes but $log_rel has no new entry. Append one (what changed, repo state, next concrete step) - /genesis:close does this properly - then finish." >&2
exit 2
