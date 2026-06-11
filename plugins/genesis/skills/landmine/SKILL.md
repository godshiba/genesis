---
name: landmine
description: Five-second capture of a gotcha into docs/registry/LANDMINES.md while the pain is fresh. Use when the user types /genesis:landmine (optionally with the gotcha as argument), says "that's a landmine", "log this gotcha", or immediately after a debugging detour caused by surprising behavior in a GENESIS project.
---

# /genesis:landmine — Capture a Gotcha

Append one entry to `docs/registry/LANDMINES.md`. Speed matters more than
polish — capture now, the next session benefits forever.

## Steps

1. Identify the trap. If given as an argument, use it. Otherwise take it from
   the immediate conversation context: what just cost time or surprised us?
   Only ask the user if genuinely ambiguous.
2. Write the entry in the file's format:
   - Bold one-line trap statement.
   - Why it is this way, what breaks if you assume otherwise, and the rule
     (always/never do X). Cite the files involved.
3. Append it. Do not edit or delete existing entries.
4. Confirm in one line: the bold trap sentence as written.

If `docs/registry/LANDMINES.md` does not exist but the user clearly wants the
capture, create it from the plugin's `templates/registry/LANDMINES.md` (at
`../../templates/registry/` from this skill's base directory) and register it
in FILES.md (G1).

Quality bar: a landmine entry must let a future reader avoid the trap without
re-deriving it. "X is weird" fails the bar; "X inverts direction when
lineId === 'green'; always go through getNextStation, never index arithmetic"
passes it.
