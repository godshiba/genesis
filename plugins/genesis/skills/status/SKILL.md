---
name: status
description: One-screen health dashboard for a GENESIS project - current roadmap phase, open issues by severity, registry sizes, last handoff age, and repo state. Read-only and fast. Use when the user asks for project status, "where are we", what's open, or wants a quick orientation in a project with docs/registry/.
---

# /genesis:status — The Project Dashboard

Read-only, fast orientation. Requires `docs/registry/` — if absent, say so
and suggest `/genesis:init`. Never run the check command or modify anything
here; this skill answers "where are we" in seconds, not "are we green"
(that is `/genesis:gate-check`).

## Gather (reads and cheap git commands only)

- `ROADMAP.md` — current phase from the status table; first unchecked task.
- `ISSUES.md` — open entries grouped by severity (high / medium / deferred).
- `SESSION_LOG.md` — date and title of the top entry; its stated next step.
- `LANDMINES.md`, `DECISIONS.md`, `FILES.md` — entry counts.
- `git status --porcelain` (dirty file count), current branch, last commit
  hash and age, `git log --oneline -1`.
- CLAUDE.md — the check command name (report it, do not run it).

## Report format

Compact, one screen, no prose around it:

```text
GENESIS STATUS — <project> @ <branch> <short-hash> (<commit age>)

Phase      <N — title>            next: <first unchecked task>
Issues     <H> high  <M> medium  <D> deferred
Last close <date — title>         (<age>; "next" was: <stated next step>)
Registry   <L> landmines  <D> decisions  <F> files mapped
Tree       <clean | N uncommitted files>
Gate cmd   <check command>        (run /genesis:gate-check to verify)
```

After the block, at most three lines of judgment — only if something needs
attention: a stale handoff (older than the last commits — G7 drift), a high
severity issue open, or a phase whose tasks are all checked but whose status
row was never updated. If everything is coherent, say one line: status clean.
