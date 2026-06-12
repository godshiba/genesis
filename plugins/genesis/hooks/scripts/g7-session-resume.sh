#!/bin/bash
# GENESIS G7 resume loader (SessionStart hook, non-blocking).
#
# The read side of the G7 loop: /genesis:close writes the handoff, this hook
# loads it back. On session start in a GENESIS project, injects the most
# recent SESSION_LOG entry, the next unchecked ROADMAP task, and the open
# issue count as additional context. Bounded output, fails open, silent
# outside GENESIS projects.
set -u

command -v python3 >/dev/null 2>&1 || exit 0

input=$(cat 2>/dev/null) || exit 0
printf '%s' "$input" | python3 -c '
import json, os, re, sys

try:
    d = json.load(sys.stdin)
    cwd = d.get("cwd", "")
    reg = os.path.join(cwd, "docs", "registry")
    if not cwd or not os.path.isdir(reg):
        sys.exit(0)

    def read(name):
        try:
            with open(os.path.join(reg, name), encoding="utf-8", errors="replace") as f:
                return f.read()
        except OSError:
            return ""

    parts = []

    log = read("SESSION_LOG.md")
    m = re.search(r"^## (.+)$", log, re.M)
    if m:
        start = m.start()
        nxt = log.find("\n## ", start + 1)
        entry = log[start:nxt if nxt != -1 else len(log)].strip()
        if len(entry) > 900:
            entry = entry[:900] + " [...]"
        parts.append("Last session handoff:\n" + entry)

    roadmap = read("ROADMAP.md")
    t = re.search(r"^\s*- \[ \] (.+)$", roadmap, re.M)
    if t:
        parts.append("Next roadmap task: " + t.group(1).strip())

    issues = read("ISSUES.md")
    open_section = issues.split("## Resolved")[0]
    ids = re.findall(r"^### (ISS-\d+)", open_section, re.M)
    if ids:
        parts.append("Open issues: %d (%s)" % (len(ids), ", ".join(ids[:5])))

    if not parts:
        sys.exit(0)

    ctx = ("GENESIS resume context (auto-loaded from docs/registry/ by the "
           "G7 session-resume hook):\n\n" + "\n\n".join(parts) +
           "\n\nContinue from the next concrete step unless the user asks "
           "for something else. Full registries are in docs/registry/.")
    print(json.dumps({"additionalContext": ctx}))
except Exception:
    pass
'
exit 0
