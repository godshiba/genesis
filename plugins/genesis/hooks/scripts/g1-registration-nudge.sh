#!/bin/bash
# GENESIS G1 registration nudge (PostToolUse on Write, non-blocking).
#
# When a new file is created in a GENESIS project and has no row in
# docs/registry/FILES.md, remind Claude via exit 2 (stderr is shown to the
# model; the tool already ran, so nothing is blocked). Fails open.
set -u

command -v python3 >/dev/null 2>&1 || exit 0

input=$(cat 2>/dev/null) || exit 0
parsed=$(printf '%s' "$input" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get("cwd", ""))
    print((d.get("tool_input") or {}).get("file_path", ""))
except Exception:
    print("")
    print("")
') || exit 0

cwd=$(printf '%s\n' "$parsed" | sed -n 1p)
fp=$(printf '%s\n' "$parsed" | sed -n 2p)

[ -n "$cwd" ] && [ -n "$fp" ] || exit 0
reg="$cwd/docs/registry/FILES.md"
[ -f "$reg" ] || exit 0

case "$fp" in
  "$cwd"/*) rel="${fp#"$cwd"/}" ;;
  *) exit 0 ;;
esac

# Registry files register themselves; skip them.
case "$rel" in
  docs/registry/*) exit 0 ;;
esac

# Only nudge for genuinely new files: tracked files are overwrites, not creations.
if command -v git >/dev/null 2>&1 \
   && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
   && git -C "$cwd" ls-files --error-unmatch "$rel" >/dev/null 2>&1; then
  exit 0
fi

grep -qF "$rel" "$reg" 2>/dev/null && exit 0

echo "G1 registration gate (GENESIS): '$rel' has no row in docs/registry/FILES.md. Add one - unregistered files are invisible." >&2
exit 2
