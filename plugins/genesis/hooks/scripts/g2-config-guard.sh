#!/bin/bash
# GENESIS G2 quality-config guard (PostToolUse on Write|Edit, non-blocking).
#
# G2 says "never proceed on red, never disable a test to ship" - but the gate
# itself can be silently weakened by editing test or lint configuration. When
# such a file is modified in a GENESIS project, remind the model that fixing
# code beats weakening gates, and that an intentional change is a G6 decision.
# Deliberately excludes compiler configs (tsconfig etc.) - those change
# legitimately too often to nag about. Fails open.
set -u

# Global kill switch: GENESIS_OFF=1 silences every GENESIS hook.
[ "${GENESIS_OFF:-}" = "1" ] && exit 0

command -v python3 >/dev/null 2>&1 || exit 0

input=$(cat 2>/dev/null) || exit 0
result=$(printf '%s' "$input" | python3 -c '
import json, os, re, sys
try:
    d = json.load(sys.stdin)
    cwd = d.get("cwd", "")
    fp = (d.get("tool_input") or {}).get("file_path", "")
    if not cwd or not fp:
        sys.exit(0)
    if not os.path.isfile(os.path.join(cwd, "docs", "registry", "DECISIONS.md")):
        sys.exit(0)
    name = os.path.basename(fp).lower()
    patterns = (
        r"^\.?eslint", r"^biome\.json", r"^\.?prettier",
        r"^jest\.config", r"^vitest\.config", r"^playwright\.config",
        r"^karma\.conf", r"^pytest\.ini", r"^ruff\.toml", r"^\.golangci",
        r"^\.rubocop", r"^\.swiftlint", r"^codecov", r"^\.?coveragerc",
    )
    if any(re.match(p, name) for p in patterns):
        print(name)
except Exception:
    pass
') || exit 0

[ -n "$result" ] || exit 0
mode="${GENESIS_G2_CONFIG:-on}"
[ "$mode" = "off" ] && exit 0
echo "G2 validation gate (GENESIS): '$result' is a quality-gate config. Fixing the code beats weakening the gate - do not relax rules, skip tests, or lower coverage to get green. If this change is intentional, record it in docs/registry/DECISIONS.md (G6) with the reason." >&2
[ "$mode" = "warn" ] && exit 0
exit 2
