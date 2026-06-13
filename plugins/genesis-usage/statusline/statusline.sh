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
import json, sys, time, subprocess

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

now = time.time()

def dim(s):
    return "\033[90m%s\033[0m" % s

def fmt_countdown(resets):
    # How long until the window refreshes. Empty for missing or implausible
    # (>8d) values - a 5h window resets within 5h, a 7d within 7d.
    if resets is None:
        return ""
    secs = resets - now
    if secs <= 0 or secs > 8 * 24 * 3600:
        return ""
    d, rem = divmod(int(secs), 86400)
    h, rem = divmod(rem, 3600)
    m = rem // 60
    if d:
        return "%dd%dh" % (d, h)
    if h:
        return "%dh%02dm" % (h, m)
    return "%dm" % m

def usage_seg(label, w):
    used = num((w or {}).get("used_percentage"))
    if used is None:
        return None
    seg = color(used, "%s %d%%" % (label, round(used)))
    cd = fmt_countdown(num((w or {}).get("resets_at")))
    if cd:
        seg += " " + dim("(" + cd + ")")
    return seg

try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)

model = (d.get("model") or {}).get("display_name") or "?"
ctx = num((d.get("context_window") or {}).get("used_percentage"))
rl = d.get("rate_limits") or {}
cwd = (d.get("workspace") or {}).get("current_dir") or d.get("cwd") or ""

parts = [model]
if ctx is not None:
    parts.append("ctx %d%%" % round(ctx))
for seg in (usage_seg("5h", rl.get("five_hour")), usage_seg("7d", rl.get("seven_day"))):
    if seg:
        parts.append(seg)

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
