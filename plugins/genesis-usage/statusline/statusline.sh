#!/bin/bash
# GENESIS usage statusline (optional, opt-in via /genesis-usage:setup).
#
# A lean one-line readout - model, context %, 5h/7d usage %, git branch - so the
# human sensor sees the numbers without a separate window. Deliberately NOT a
# HUD: no tool/agent/todo parsing, no boxes. Usage segments color green/yellow/
# red. Fails open: missing fields are simply omitted.
set -u

command -v python3 >/dev/null 2>&1 || { printf 'genesis-usage'; exit 0; }

input=$(cat 2>/dev/null) || exit 0

printf '%s' "$input" | python3 -c '
import json, sys, subprocess

def num(x):
    try:
        return float(x)
    except (TypeError, ValueError):
        return None

def color(pct, s):
    if pct is None:
        return s
    c = "31" if pct >= 90 else ("33" if pct >= 75 else "32")
    return "\033[%sm%s\033[0m" % (c, s)

try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)

model = (d.get("model") or {}).get("display_name") or "?"
ctx = num((d.get("context_window") or {}).get("used_percentage"))
rl = d.get("rate_limits") or {}
five = num((rl.get("five_hour") or {}).get("used_percentage"))
seven = num((rl.get("seven_day") or {}).get("used_percentage"))
cwd = (d.get("workspace") or {}).get("current_dir") or d.get("cwd") or ""

parts = [model]
if ctx is not None:
    parts.append("ctx %d%%" % round(ctx))
if five is not None:
    parts.append(color(five, "5h %d%%" % round(five)))
if seven is not None:
    parts.append(color(seven, "7d %d%%" % round(seven)))

branch = ""
if cwd:
    try:
        branch = subprocess.run(
            ["git", "-C", cwd, "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True, text=True, timeout=2).stdout.strip()
    except Exception:
        branch = ""
if branch:
    parts.append(branch)

sys.stdout.write("  ".join(parts))
'
