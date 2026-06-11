---
name: issue
description: Register a bug, deferral, or known limitation as the next ISS-NNN in docs/registry/ISSUES.md with severity and an investigation path. Use when the user types /genesis:issue, says "log this bug/issue", "defer this", or when work uncovers a problem that will not be fixed in the current task in a GENESIS project.
---

# /genesis:issue — Register an Issue

Append one entry to the Open section of `docs/registry/ISSUES.md`. A problem
in a TODO comment is invisible; a problem with an ISS number is work.

## Steps

1. Determine the next sequential ID by scanning existing `ISS-` entries
   (including Resolved).
2. Pick severity: `high` (blocks or corrupts), `medium` (wrong but
   survivable), `deferred` (intentional, revisit later). If unclear from
   context, default to `medium` and say so.
3. Write the entry in the file's format: title, severity, registered date
   (today's real date), context with file paths, and a concrete investigation
   path — the first commands or files whoever picks this up should look at.
4. If the repo has a GitHub remote and `gh` is available and the project's
   CLAUDE.md or the user has opted into mirroring: `gh issue create --title
   "ISS-NNN: <title>"` with a body pointing at the canonical ISSUES.md entry,
   then back-fill the `**GitHub:** [#N](url)` line. If mirroring is not set
   up, skip silently — never make it a blocker.
5. If the code contains a related TODO/FIXME, rewrite it to cite the ID:
   `// TODO(ISS-NNN): ...`.
6. Confirm in one line: `ISS-NNN registered (severity) — <title>`.

Resolving (when asked): move the entry under Resolved with a dated note —
never delete — and close the GitHub mirror in the same commit if one exists.
