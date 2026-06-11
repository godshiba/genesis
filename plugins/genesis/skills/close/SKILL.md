---
name: close
description: The G7 session-close ritual for GENESIS projects. Runs a gate audit, appends the SESSION_LOG entry (what changed, repo state, next concrete step), and leaves the tree in a resumable state. Use when the user says close the session, wrap up, stopping here, done for today, or when ending substantial work in a project with docs/registry/.
---

# /genesis:close — End the Session Cleanly

The exit ritual. A session that ends without this destroys context the next
session will pay to rebuild. Requires `docs/registry/` — if absent, just
summarize the work normally and suggest `/genesis:init` for next time.

## Steps

1. **Gate audit first.** Run the /genesis:gate-check checks. If G2 (validation)
   is red: do not close over it. Either fix it now or register the failure as
   an ISS-NNN and say explicitly that the tree is red and why. Never leave a
   broken tree silently.

2. **Settle the tree.** Half-finished work is either completed, committed as a
   coherent WIP on a branch, or reverted — never left ambiguous. Ask the user
   which, if it is not obvious.

3. **Append the SESSION_LOG.md entry** (newest on top):
   - What was completed, with file paths.
   - Repo state: branch, last commit hash, check command green or red.
   - The next concrete step — specific enough that a cold session can start
     from it without re-reading the whole repo ("implement X in file Y per
     ROADMAP phase N task M", not "continue").
   - Anything in progress that should be reviewed first.
   - Reference issues by ID only; bodies live in ISSUES.md.

4. **Sync the roadmap.** Check off completed ROADMAP.md tasks and update the
   status table if a phase boundary was crossed.

5. **Close with the handoff summary** to the user: completed / repo state /
   next step, in three short lines.

The Stop hook (G7 guard) will stop blocking once SESSION_LOG.md is touched —
this skill is the proper way to satisfy it.
