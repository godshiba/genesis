#!/bin/bash
# GENESIS G3 issue gate nudge (PostToolUse on Write|Edit, non-blocking).
#
# When newly written content contains TODO/FIXME/HACK/XXX markers that do not
# reference an ISS- id, remind Claude that problems belong in
# docs/registry/ISSUES.md. Scans only the new content (Write content or Edit
# new_string), never the whole file, so pre-existing markers do not nag.
# Fails open.
set -u

# Global kill switch: GENESIS_OFF=1 silences every GENESIS hook.
[ "${GENESIS_OFF:-}" = "1" ] && exit 0

command -v python3 >/dev/null 2>&1 || exit 0

input=$(cat 2>/dev/null) || exit 0
result=$(printf '%s' "$input" | python3 -c '
import json, re, sys
try:
    d = json.load(sys.stdin)
    cwd = d.get("cwd", "")
    ti = d.get("tool_input") or {}
    text = ti.get("content") or ti.get("new_string") or ""
    fp = ti.get("file_path", "")
    if not cwd or not text or not fp:
        sys.exit(0)
    if "/docs/registry/" in fp:
        sys.exit(0)
    hits = []
    for i, line in enumerate(text.splitlines(), 1):
        if re.search(r"\b(TODO|FIXME|HACK|XXX)\b", line) and "ISS-" not in line:
            hits.append(line.strip()[:100])
        if len(hits) >= 3:
            break
    if hits:
        print(cwd)
        for h in hits:
            print(h)
except Exception:
    pass
') || exit 0

[ -n "$result" ] || exit 0
cwd=$(printf '%s\n' "$result" | sed -n 1p)
[ -f "$cwd/docs/registry/ISSUES.md" ] || exit 0

markers=$(printf '%s\n' "$result" | sed 1d)
mode="${GENESIS_G3:-on}"
[ "$mode" = "off" ] && exit 0
echo "G3 issue gate (GENESIS): new TODO/FIXME marker(s) without an ISS- reference: $markers -- register the problem in docs/registry/ISSUES.md (/genesis:issue) and cite the id, e.g. TODO(ISS-NNN)." >&2
[ "$mode" = "warn" ] && exit 0
exit 2
