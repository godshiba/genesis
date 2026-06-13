#!/bin/bash
# GENESIS usage sensor (Stop hook).
#
# The missing trigger for the G7 emergency close. Claude Code passes a
# subscriber `rate_limits` object on stdin (5-hour + 7-day windows, Pro/Max
# only, v1.0.80+). At the end of each turn this reads it and, when usage crosses
# a threshold while a reset is still far enough out to risk a cutoff, it acts:
#
#   advise  (default) - prints a recommendation to stderr (shown inline), exits 0.
#   enforce           - blocks the stop (exit 2) so Claude runs /genesis:close
#                       before the turn ends. Only in a GENESIS project.
#
# A sensor, not a HUD: it says nothing until you are near a cap, and fires at
# most once per rising 5-point usage bucket per session. Fails open - silent
# without python3, without rate_limits (API users), or on any parse error.
set -u

command -v python3 >/dev/null 2>&1 || exit 0

input=$(cat 2>/dev/null) || exit 0

tok=$(printf '%s' "$input" | python3 -c '
import json, os, sys, time, tempfile, hashlib

def num(x):
    try:
        return float(x)
    except (TypeError, ValueError):
        return None

try:
    d = json.load(sys.stdin)
except Exception:
    print("NONE"); sys.exit(0)

mode = os.environ.get("GENESIS_USAGE_MODE", "advise").strip().lower()
if mode == "off":
    print("NONE"); sys.exit(0)

def env_float(name, default):
    try:
        return float(os.environ.get(name, default))
    except (TypeError, ValueError):
        return default

th5 = env_float("GENESIS_USAGE_THRESHOLD", 90.0)
th7 = env_float("GENESIS_USAGE_WEEK_THRESHOLD", 85.0)
grace = env_float("GENESIS_USAGE_GRACE_SECS", 120.0)

rl = d.get("rate_limits") or {}
cwd = d.get("cwd") or ""
sid = d.get("session_id") or ""
stop_active = bool(d.get("stop_hook_active", False))
now = time.time()

def window(name, thresh):
    w = rl.get(name) or {}
    used = num(w.get("used_percentage"))
    if used is None or used < thresh:
        return None
    resets = num(w.get("resets_at"))
    if resets is not None and (resets - now) <= grace:
        return None
    eta = int(resets - now) if (resets is not None and resets > now) else None
    return {"used": used, "eta": eta}

w5 = window("five_hour", th5)
w7 = window("seven_day", th7)
if not w5 and not w7:
    print("NONE"); sys.exit(0)

worst = max([w["used"] for w in (w5, w7) if w])
bucket = int(worst // 5 * 5)
key = sid or hashlib.sha1(cwd.encode("utf-8", "replace")).hexdigest()[:16]
safe = "".join(c for c in key if c.isalnum() or c in "-_") or "anon"
state = os.path.join(tempfile.gettempdir(), "genesis-usage." + safe + ".state")
last = -1
try:
    with open(state) as f:
        last = int((f.read().strip() or "-1"))
except Exception:
    last = -1
if bucket <= last:
    print("NONE"); sys.exit(0)
try:
    with open(state, "w") as f:
        f.write(str(bucket))
except Exception:
    pass

def fmt_eta(eta):
    if eta is None:
        return "reset time unknown"
    return "resets in %dh%02dm" % (eta // 3600, (eta % 3600) // 60)

is_genesis = bool(cwd) and os.path.isdir(os.path.join(cwd, "docs", "registry"))

bits = []
if w5:
    bits.append("5h usage %d%% (%s)" % (round(w5["used"]), fmt_eta(w5["eta"])))
if w7:
    bits.append("7d usage %d%% (%s)" % (round(w7["used"]), fmt_eta(w7["eta"])))
head = "GENESIS usage sensor: " + "; ".join(bits) + "."

if is_genesis:
    action = "Run /genesis:close now - capture mid-task state in SESSION_LOG before the cutoff."
else:
    action = "Good moment to commit and wrap up before the limit resets."

enforce = (mode == "enforce") and is_genesis
if enforce and stop_active:
    print("NONE"); sys.exit(0)

sys.stderr.write(head + " " + action + "\n")
print("BLOCK" if enforce else "ADVISE")
') || exit 0

case "$tok" in
  BLOCK) exit 2 ;;
  *) exit 0 ;;
esac
