---
name: learn
description: The GENESIS feedback loop. Review the session or shipped project for lessons worth promoting - recurring landmines, gate friction, missing template slots - and fold them into the project CLAUDE.md or propose upstream changes to the GENESIS plugin templates. Use when the user types /genesis:learn, asks for a project autopsy/retro, or after shipping a phase or release.
---

# /genesis:learn — Fold Lessons Back Into the System

GENESIS is designed to evolve. A rule a project repeatedly violates is wrong
for that project; a pattern three projects repeat belongs in the template.
This skill is the mechanism.

## Steps

1. **Gather evidence.** Read the project's registries — SESSION_LOG (what
   actually happened), LANDMINES (what surprised us), ISSUES (what recurred),
   DECISIONS (what we chose) — plus recent git history. Look for:
   - A landmine category that appeared 2+ times: candidate for a CLAUDE.md
     invariant or key pattern.
   - A gate that produced friction without payoff in this project: candidate
     for a recorded, deliberate deviation.
   - A convention followed in code but written nowhere: candidate for the
     CLAUDE.md Key Patterns section.
   - A workflow improvement any project would want: candidate for upstream.

2. **Classify each finding** by destination:
   - **Project-level:** edit this project's CLAUDE.md (invariants, patterns,
     doc-sync map). Apply directly after listing the proposed edits.
   - **Deviation:** record in DECISIONS.md why this project bends a GENESIS
     rule. The rule stands elsewhere.
   - **Upstream:** belongs in the GENESIS plugin itself (templates, doctrine,
     a skill). The installed plugin is a read-only cache — do not edit it.
     Instead, produce the exact proposed diff against the plugin repo
     (https://github.com/godshiba/genesis) and offer to apply it if the user
     has a local clone, or format it as a PR-ready change.

3. **Report:** findings, destination for each, and what was applied vs
   proposed. Keep it short — three strong findings beat ten weak ones. Zero
   findings is a valid result; say so rather than inventing lessons.
