#!/bin/bash
# GENESIS G7 pre-compaction snapshot (PreCompact hook, non-blocking).
#
# The context-window safety net for the G7 loop. Just before Claude Code
# compacts a full conversation into a lossy summary, this writes a mechanical
# breadcrumb of repo state to docs/registry/.session-snapshot.md. If the
# session then ends (rate limit, crash, walking away) before /genesis:close
# runs, the resume loader surfaces this snapshot next session so nothing about
# the working tree is silently lost across the compaction boundary.
#
# It is a breadcrumb, not a handoff: a shell script can capture git state, not
# intent. /genesis:close writes the real handoff and deletes this file - a
# proper close supersedes the breadcrumb. Fails open: outside a GENESIS project
# or without git/python3 it is silent.
set -u

# Global kill switch + snapshot toggle (GENESIS_OFF=1, or GENESIS_PRECOMPACT=off).
[ "${GENESIS_OFF:-}" = "1" ] && exit 0
[ "${GENESIS_PRECOMPACT:-on}" = "off" ] && exit 0

command -v python3 >/dev/null 2>&1 || exit 0
command -v git >/dev/null 2>&1 || exit 0

input=$(cat 2>/dev/null) || exit 0
parsed=$(printf '%s' "$input" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get("cwd", ""))
    print(d.get("trigger", ""))
except Exception:
    print("")
    print("")
') || exit 0

cwd=$(printf '%s\n' "$parsed" | sed -n 1p)
trigger=$(printf '%s\n' "$parsed" | sed -n 2p)

# Only act inside a GENESIS project that is a git work tree.
[ -n "$cwd" ] && [ -d "$cwd/docs/registry" ] || exit 0
git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

snap="$cwd/docs/registry/.session-snapshot.md"
ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "?")
branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
head=$(git -C "$cwd" log -1 --pretty='%h %s' 2>/dev/null || echo "?")
dirty=$(git -C "$cwd" status --porcelain --untracked-files=all 2>/dev/null)

{
  echo "# Pre-compaction snapshot (mechanical, auto-written by GENESIS)"
  echo
  echo "Written ${ts} just before a ${trigger:-auto} context compaction."
  echo "This is a breadcrumb, not a handoff. If you see it on resume, the last"
  echo "session may have ended mid-task before /genesis:close ran - reconcile"
  echo "it against SESSION_LOG.md, then continue."
  echo
  echo "- Branch: ${branch}"
  echo "- HEAD: ${head}"
  if [ -n "$dirty" ]; then
    echo "- Uncommitted changes:"
    printf '%s\n' "$dirty" | sed 's/^/    /'
  else
    echo "- Working tree clean."
  fi
} > "$snap" 2>/dev/null || exit 0

exit 0
