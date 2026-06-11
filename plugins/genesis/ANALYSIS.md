# ANALYSIS.md — The Six-Project Autopsy

GENESIS was distilled from the CLAUDE.md files of six real projects. This
file records what each did well, where it failed, and what the doctrine in
[MASTER.md](./MASTER.md) adopted or rejected — the precedent record for every
design decision in the system. Sources are anonymized; their lessons are not.

The six sources:

| Source | What it was |
|--------|-------------|
| S1 | A global (cross-project) CLAUDE.md — the philosophy layer |
| S2 | A macOS menu-bar hardware monitor (Swift, privileged helper) — 20KB, the most evolved |
| S3 | An Electron desktop app for community management — 5KB |
| S4 | An Electron desktop app with a heavy linked-docs system — 7.5KB |
| S5 | A Swift menu-bar app with a real-time log-parsing overlay — 5.5KB |
| S6 | A vanilla-JS transit PWA, no framework, no build step — 6.5KB |

---

## S1 — the philosophy layer

**Strong**
- Clear principle hierarchy: agent-first, parallel execution, plan-before-execute.
- Modular rules pattern (linked rule files) keeps the main file short.
- Knowledge-capture routing (personal notes vs project docs) is genuinely good
  and rarely seen.

**Weak**
- Entirely generic — nothing enforces anything. "Security-first" with no gate is
  a poster, not a rule.
- Tables of agents and rule files duplicate what the harness already discovers.
- No project memory concept at all: no issues, no sessions, no decisions.

**Adopted:** agent-first philosophy, modular layout, knowledge routing.
**Rejected:** duplicated discovery tables, unenforced slogans.

---

## S2 — the most evolved, and the heaviest

**Strong**
- The file map ("the map is the index; not finding something is a signal to add
  it, not to grep blindly") — became doctrine corollary 2.
- An issue register with sequential IDs, severity tags, remote mirroring, and a
  same-commit resolve policy. The best issue discipline in any of the six.
- A session log + session-limit safety + resume protocol — the only file that
  treated session death as a design constraint.
- Delegation/parallelism protocol with explicit when/when-not criteria and an
  agent dispatch checklist — proven across real build phases.
- Unattended-operation bright lines (will / will not lists).
- An explicit "Out of scope" section — the cheapest drift prevention found.
- Architecture invariants numbered and phrased as violations ("do not violate").

**Weak**
- 20KB auto-loaded every session — a context tax on every task, violating its
  own context-economy interests. Much of it belonged in linked docs.
- Everything hardcoded to one machine and one repo; zero reusability.
- The remote-mirror policy was excellent but verbose enough to compete with
  the rules that mattered more.

**Adopted:** issue register, session log, resume protocol, delegation protocol,
unattended rules, out-of-scope section, numbered invariants, file map principle.
**Rejected:** monolithic size (GENESIS caps project CLAUDE.md at ~150 lines and
links out), single-machine hardcoding.

---

## S3 — the registration pioneer

**Strong**
- "Every new file must be registered where it belongs. Unregistered files are
  invisible." — the single most important sentence in the six files. Became G1
  and the doctrine itself.
- Context loading rules ("read one pattern example, apply to all") — became
  MASTER §6.
- Phase execution with a validation command after every change and explicit
  phase gates — became G2 and prep Step 4.
- Change Maps (which files to touch per operation) — high leverage, low cost.
- Resume instruction tied to the roadmap.

**Weak**
- The registration checklist lived in a linked doc that nothing forced the
  model to read — a gate that depends on voluntary compliance is a guideline.
- No issue register; deferred work had nowhere to live.
- No landmines section despite the codebase having plenty.

**Adopted:** registration rule (promoted to a hard gate with a dedicated
registry file and an enforcement hook), context economy, phase gates, change
maps (folded into the doc-sync map slot).
**Rejected:** registration-by-linked-checklist; the registry row is the
checklist now.

---

## S4 — the doc-sync map

**Strong**
- The "Keep Docs in Sync" tables — changed X means update Y — are the most
  mechanical, checkable doc discipline in the six. Became G4.
- A need-to-file Doc Map table makes sixteen docs navigable in ten lines.
- Key Patterns section shows real code snippets for the five operations that
  recur constantly — cheaper than a thousand words of convention prose.
- A decisions file with "append, never delete" — became G6.
- Proof that a hard per-change rule (its localization policy) can be stated in
  seven lines.

**Weak**
- No tests, and the file just says so — quality gates exist (lint, typecheck)
  but nothing defines done beyond them.
- No session continuity, no issue register, no roadmap; great at space (where
  things are), absent at time (what happened, what is next).

**Adopted:** doc-sync map as a gate, need-to-file doc map, patterns-as-snippets,
append-only decisions.
**Rejected:** nothing — this file's content was nearly all signal; it was just
incomplete.

---

## S5 — architecture as contract

**Strong**
- The dependency graph rendered as a tree with a strict import rule — the
  architecture is falsifiable, not decorative. Became prep Step 3's core
  output.
- "Pure core, impure shell": the reducer as a free function with zero I/O,
  testable by passing values — became an architecture rule of thumb.
- Key design rules state *why* (a circular-import trap, a compiler diagnostic
  bug) — landmines and invariants fused.
- Documents non-obvious domain heuristics precisely where a future session
  would otherwise re-derive them.

**Weak**
- Pure description, zero workflow: no gates, no registries, no session story.
  A perfect snapshot that goes stale the moment code moves, with no G4
  mechanism to keep it honest.
- A key-files table duplicating what FILES.md should own.

**Adopted:** dependency-graph-as-contract, pure-core/impure-shell, invariants
that explain why.
**Rejected:** description-without-workflow; every descriptive section in GENESIS
has a gate that keeps it true.

---

## S6 — the landmine register

**Strong**
- A "things that will trip you up" section — inverted direction semantics on
  one data path, estimated values that look authoritative, a UI element that
  breaks if "cleaned up". The highest value-per-line section in any of the six
  files. Became G5 and LANDMINES.md.
- "Check the roadmap docs first — they may already describe the work" — work
  intake routed through existing plans before improvising.
- Locale consistency stated as a constraint, not a preference.

**Weak**
- Landmines buried in prose with no structure and no instruction to add new
  ones — a snapshot of past pain, not a growing register.
- No validation gate at all (no tests, no lint — fine — but not even a smoke
  check defined).
- No issue or decision tracking.

**Adopted:** the landmine concept, promoted to a dedicated append-on-discovery
registry; roadmap-first work intake.
**Rejected:** landmines-as-prose.

---

## Cross-cutting verdicts

1. **The best ideas were all registries** (issues, sessions, landmines, files,
   decisions) and the best rules were all gates tied to them. Style preferences
   contributed almost nothing to project outcomes.
2. **Description without enforcement rots.** S5 and S6 are excellent snapshots
   that nothing keeps true. Every descriptive artifact in GENESIS is paired
   with the gate that maintains it.
3. **Size is a tax.** The best content (S2) was also the most expensive to
   load. GENESIS separates doctrine (loaded never), template (copied once),
   and project file (loaded always, capped ~150 lines).
4. **Each project independently reinvented part of the system.** Six files,
   five partial implementations of the same missing operating system. GENESIS
   is that operating system made explicit.
