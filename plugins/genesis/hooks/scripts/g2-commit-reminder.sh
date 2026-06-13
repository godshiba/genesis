#!/bin/bash
# GENESIS G2 validation reminder (PreToolUse on Bash, non-blocking).
#
# When a git commit is about to run in a GENESIS project, inject a reminder
# that G2 requires the project check command to be green and that
# /genesis:gate-check audits all gates. Never blocks: the commit proceeds;
# this only puts the obligation in front of the model at the moment it
# matters. Fails open (silent).
set -u

# Global kill switch + G2 toggle (GENESIS_OFF=1, or GENESIS_G2=off).
[ "${GENESIS_OFF:-}" = "1" ] && exit 0
[ "${GENESIS_G2:-on}" = "off" ] && exit 0

command -v python3 >/dev/null 2>&1 || exit 0

input=$(cat 2>/dev/null) || exit 0
printf '%s' "$input" | python3 -c '
import json, os, re, sys
try:
    d = json.load(sys.stdin)
    cwd = d.get("cwd", "")
    cmd = (d.get("tool_input") or {}).get("command", "")
    if not cwd or not re.search(r"\bgit\b[^|;&]*\bcommit\b", cmd):
        sys.exit(0)
    if not os.path.isfile(os.path.join(cwd, "docs", "registry", "FILES.md")):
        sys.exit(0)
    print(json.dumps({
        "additionalContext": (
            "G2 validation gate (GENESIS): a commit is about to run. The "
            "project check command named in CLAUDE.md must be green for this "
            "commit - run it now if it has not run since the last change. "
            "/genesis:gate-check audits all seven gates."
        )
    }))
except Exception:
    pass
'
exit 0
