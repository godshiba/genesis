---
name: close
description: The G7 session-close ritual for GENESIS projects. Runs a gate audit, appends the SESSION_LOG entry (what changed, repo state, next concrete step), and leaves the tree in a resumable state. Use when the user says close the session, wrap up, stopping here, done for today, when about to hit a usage limit, or when ending substantial work in a project with docs/registry/.
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

5. **Clear the breadcrumb.** If `docs/registry/.session-snapshot.md` exists
   (written automatically before a context compaction), delete it — a proper
   handoff supersedes the mechanical snapshot, and leaving it would mislead the
   next session into thinking work ended mid-task.

6. **Close with the handoff summary** to the user: completed / repo state /
   next step, in three short lines.

The Stop hook (G7 guard) will stop blocking once SESSION_LOG.md is touched —
this skill is the proper way to satisfy it.

## Emergency close — about to hit a usage limit

Claude Code does not expose the 5-hour or weekly rate-limit gauge to scripts,
so there is no automatic trigger: **you are the sensor.** When `/usage` shows
the cap approaching, interrupt the current work and run this skill immediately.
A mid-task handoff beats a hard cutoff that strands the work with no record.

In this mode, prioritize capture over polish — do not spend the remaining
budget finishing or reverting:

1. **Do not settle the tree.** Leave half-done work exactly where it is.
   Instead, record precisely where it sits: which files are touched, what is
   incomplete in each, and the single next action to resume — specific enough
   that a cold session continues without re-deriving anything.
2. **Append the SESSION_LOG entry** (what changed so far, repo state, the exact
   next step, what is mid-flight and unreviewed). This is the only required
   step. Skip the roadmap sync and gate audit if budget is tight — note any
   red check command as an ISS-NNN rather than running it.
3. **Stop.** Do not start anything new. The resume loader will replay this
   handoff next session, after the limit resets, at near-zero context cost.
