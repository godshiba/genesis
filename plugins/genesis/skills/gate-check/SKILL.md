---
name: gate-check
description: Audit current work against all seven GENESIS gates before a commit or at the end of a task. Runs the project check command, finds unregistered files, orphan TODOs, doc-sync drift, and missing registry entries. Use when the user asks to gate-check, audit gates, verify gates, or before committing in a GENESIS project (one with docs/registry/).
---

# /genesis:gate-check — Audit the Seven Gates

Audits the working tree against every gate and reports pass/fail per gate.
This skill never fixes silently — it reports, then offers to fix.

Requires a GENESIS project (`docs/registry/` exists). If absent, say so and
suggest `/genesis:init`.

For large diffs (10+ changed files), delegate the audit to this plugin's
`gate-auditor` agent (registered as `genesis:gate-auditor`) via the Agent tool
and relay its report. Otherwise run inline:

## The checks

**G1 Registration** — `git status --porcelain` for untracked/new files (and
new files in the diff against the default branch). Each must appear in
`docs/registry/FILES.md`. List missing ones.

**G2 Validation** — find the check command in CLAUDE.md (the command marked as
the validation gate) and run it. Red output means G2 FAIL and the overall
result is FAIL regardless of other gates. Never report overall pass on a red
check command. Quote the failing output.

**G3 Issue** — grep changed files for `TODO`, `FIXME`, `HACK`, `XXX` markers
that do not reference an `ISS-` ID. Each is a G3 violation: it belongs in
`docs/registry/ISSUES.md`.

**G4 Doc-sync** — read the Doc-Sync Map table in CLAUDE.md. For each changed
area, check whether the mapped doc was also modified (in the diff or working
tree). Flag stale pairs.

**G5 Landmine** — judgment check, not mechanical: did this session hit
surprising behavior, a debugging detour, or an environment quirk? If yes and
`docs/registry/LANDMINES.md` was not touched, flag it and draft the entry.

**G6 Decision** — judgment check: did this work choose between real
alternatives (library, pattern, schema)? If yes and DECISIONS.md was not
touched, flag it and draft the entry.

**G7 Session** — informational here (the Stop hook and `/genesis:close`
enforce it): note whether SESSION_LOG.md has an entry covering this work.

## Report format

One line per gate: `G1 Registration  PASS` or `FAIL — <specifics with paths>`.
Then an overall verdict. If anything failed, list the concrete fixes in order
and offer to apply them. Fixes to registries are additive edits; never delete
registry content to make a gate pass.
