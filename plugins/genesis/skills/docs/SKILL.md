---
name: docs
description: Reorganize a repository's documentation into a clean, comprehensible structure. Inventories every doc, absorbs registry-shaped knowledge (decisions, gotchas, TODOs) into GENESIS registries, moves and merges files, flags stale content, writes missing docs from code evidence - all behind an approval gate, all reversible. Use when the user asks to organize/clean up/restructure docs, when a repo's documentation is scattered or duplicated, or when /genesis:init retrofits a repo with more than a handful of docs.
---

# /genesis:docs — Curate the Documentation

Turns accumulated, scattered documentation into a clean structure where every
doc has a place, a purpose, and a G4 wire that keeps it true — without losing
knowledge and without surprising the user.

## Preconditions

- **Must be a git repository.** Every move and deletion has to be revertible
  with one command. If the directory is not a repo, offer `git init` first
  and stop if declined.
- Works with or without an existing GENESIS kit. Without one, suggest running
  `/genesis:init` first (the registries are where absorbed knowledge lands);
  proceed standalone only if the user prefers — then absorbed knowledge goes
  into the best existing doc instead of registries.

## Protocol

1. **Analyze.** For repos with more than ~5 doc files, dispatch this plugin's
   `doc-curator` agent (registered as `genesis:doc-curator`) via the Agent
   tool — it reads everything so the main context does not have to — and
   relay its migration plan. For small doc sets, run the curator's procedure
   inline (read its agent file for the classification taxonomy, verdicts, and
   plan format; follow it exactly).

2. **Present the plan and get approval.** Show the full migration table
   (doc, class, verdict, destination), the registry entries to be seeded, and
   the drafts for missing docs. Use AskUserQuestion: approve all / approve
   with exclusions / cancel. Never execute an unapproved plan. If the user
   excludes items, execute only the remainder.

3. **Execute, in this order:**
   1. Seed registries with absorbed knowledge (DECISIONS/ISSUES/LANDMINES
      entries citing their source doc).
   2. `git mv` for every move and archive — never delete-and-recreate, so
      history follows the file.
   3. Apply rewrites (stale claims corrected, with the code evidence the
      curator cited).
   4. Write the new docs from the approved drafts.
   5. Delete only `junk`-verdict files and absorbed sources the plan marked
      for deletion.
   6. Update `docs/registry/FILES.md` with a row for every doc in the final
      structure, and extend the CLAUDE.md doc-sync map (G4) so each living
      doc has an owner area — this is what prevents the cleaned structure
      from rotting again.

4. **Commit once.** A single commit (`docs: restructure documentation`) so
   the entire reorganization is one reviewable, one-revert unit. Summarize:
   before/after counts, knowledge absorbed, gaps filled, and the revert
   command (`git revert <hash>`).

## Hard rules

- No execution without explicit approval of the presented plan.
- Knowledge is never lost: deletion only for junk or fully-absorbed sources.
- One commit for the whole operation; never spread it across several.
- Respect coherent existing conventions — restructure the mess, not the
  working parts.
- Stale docs that contradict code: fix when the truth is clear from code,
  otherwise register an ISS-NNN and leave the doc marked, never guess.
