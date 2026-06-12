# MASTER.md — The GENESIS Doctrine

A project operating system for Claude Code, distilled from six real projects.
This file is the concept. It is never copied into a project — projects get a
tailored `CLAUDE.md` generated from `templates/` via the `/genesis:init` skill.

Lineage and trade-off analysis of the six source files: [ANALYSIS.md](./ANALYSIS.md).

---

## 1. The Doctrine

**What isn't registered doesn't exist.**

Every project that went well had one thing in common: structured registry files
that made work visible, resumable, and honest. Every project that drifted lacked
them. Style rules are taste; registries are infrastructure. A session that ends
without updating the registries has silently destroyed context that the next
session will pay to rebuild.

Three corollaries:

1. **Registries over memory.** Claude's conversation memory dies at session end.
   Files in the repo do not. Anything worth remembering goes in a registry.
2. **The map is the index.** Not finding something in the file map is a signal
   to add it after you find it — never a signal to grep blindly forever.
3. **Docs are not aspirational.** If reality differs from a spec, fix one or the
   other in the same commit. A wrong doc is worse than no doc.

---

## 2. The Three Layers

```
LAYER 1 — DOCTRINE      this file (ships with the plugin), plus the user's
                        global ~/.claude/CLAUDE.md.
                        Universal rules. Never copied, only referenced.

LAYER 2 — TEMPLATES     templates/ in the plugin:
                        CLAUDE.template.md + registry/ skeletons.
                        Copied and tailored once per project by /genesis:init.

LAYER 3 — AUTOMATION    the plugin's skills, agents, and hooks.
                        /genesis:init — prep protocol (greenfield or retrofit)
                        /genesis:docs — doc curation: inventory, absorb,
                          reorganize existing documentation (approval-gated)
                        /genesis:gate-check, :close, :landmine, :decision,
                          :issue, :learn — the daily habit loop
                        gate-auditor, genesis-architect, doc-curator —
                          delegable agents
                        hooks — G7 guard (blocks) + session-resume loader,
                          G1/G3 nudges, G2 commit reminder + config guard
```

The split matters: doctrine changes rarely, templates evolve as you learn,
and each project's generated kit diverges freely without polluting the source.
Improvements discovered inside a project flow back up via `/genesis:learn`:
project-level lessons land in that project's CLAUDE.md; system-level lessons
become changes to the plugin's templates (a PR to the plugin repo, or direct
edits if you maintain a fork), and every later project inherits them.

---

## 3. The Seven Hard Gates

Non-negotiable. They appear in every generated `CLAUDE.md`. "Done" means all
gates passed, not "the code seems to work."

| # | Gate | Rule |
|---|------|------|
| G1 | Registration | Every new file gets a row in `docs/registry/FILES.md` before the task is done. Unregistered files are invisible. |
| G2 | Validation | Run the project's check command after every change. Never proceed on red. Never disable a test to ship. |
| G3 | Issue | Every bug, deferral, or known limitation becomes `ISS-NNN` in `docs/registry/ISSUES.md`. No silent TODO comments. |
| G4 | Doc-sync | The doc-sync map in the project CLAUDE.md says change X means update doc Y. Same commit. They must not drift. |
| G5 | Landmine | Every gotcha discovered the hard way goes in `docs/registry/LANDMINES.md` immediately, while the pain is fresh. |
| G6 | Decision | Every non-obvious choice (and the rejected alternatives) is appended to `docs/registry/DECISIONS.md`. Append-only. |
| G7 | Session | Before ending work: append to `docs/registry/SESSION_LOG.md` — what changed, repo state, next concrete step. |

Why hard gates and not guidelines: a guideline competes with momentum and loses.
A gate is checked mechanically at the end of every task. The cost is thirty
seconds per gate; the payoff is that any session — or any other agent — can pick
up the project cold.

Each gate gets the strongest enforcement its nature allows — three classes:

- **Mechanical and generic** — enforced by hooks, project-agnostic shell
  checks. G7 blocks (a turn that changed code cannot end without a session-log
  touch), G1 and G3 nudge the model the moment a violation appears, G2 injects
  its obligation right before any git commit.
- **Mechanical but project-specific** — enforced by skills, which can read the
  project's CLAUDE.md. G2's actual run (the check command differs per project)
  and G4's doc-sync map audit live in `/genesis:gate-check` and
  `/genesis:close`, which refuse to report clean over a red check command.
- **Judgment calls** — G5 and G6 cannot be detected by grep; the gate-check
  skill and gate-auditor agent probe for them ("did this work choose between
  alternatives?") and flag probable misses rather than pretending certainty.

All hooks fail open: outside a GENESIS project (no `docs/registry/`), or on a
machine missing git or python3, they are silent. The plugin is a shell over
Claude Code's existing architecture, never a replacement for it.

### The conduct layer

Gates govern artifacts; they say nothing about how to behave while producing
them. Every generated CLAUDE.md therefore carries a four-rule Conduct section
(derived from Karpathy's LLM-pitfall guidelines, adapted to the gates):
surface assumptions before coding (an assumption that shaped the approach is a
G6 decision), simplicity first, surgical diffs (every changed line traces to
the request — which is what keeps G4 honest), and goal-driven steps (each task
names its verify check up front — G2 as behavior). Gates catch what conduct
misses; conduct prevents what gates would catch.

---

## 4. The Registry System

Lives at `docs/registry/` in every project. Six files, one concern each:

| File | Question it answers | Discipline |
|------|--------------------|------------|
| `FILES.md` | Where does everything live? | One row per concept/file. Add the row when you add the file. |
| `ISSUES.md` | What is broken, deferred, or limited? | Sequential `ISS-NNN`, severity-tagged, with investigation paths. Resolved entries move to a Resolved section, never deleted. |
| `DECISIONS.md` | Why is it built this way? | Append-only. Decision, context, alternatives rejected, date. |
| `LANDMINES.md` | What will trip the next session up? | Inverted behavior, false assumptions, magic constants, ordering traps. The most valuable file in the system. |
| `SESSION_LOG.md` | What happened, when, and what is next? | Newest on top. Concrete: file paths, what, why. Reference issues by ID, never inline their bodies. |
| `ROADMAP.md` | What phase are we in and what is the gate? | Phases with acceptance criteria. Resume protocol: read this first, find the first unchecked task. |

Source-of-truth precedence when registries and code disagree:
design/spec files say *what to build*, runbooks say *how to operate*,
`CLAUDE.md` says *how to work*, and the code says *what currently is*.
Conflicts are G4 violations — fix in the same commit.

---

## 5. The Prep Protocol

What `/genesis:init` executes before any code exists. Five steps, in order.
Skipping a step is how projects inherit unexamined assumptions.

### Step 1 — Interrogate
Force the questions most projects never ask out loud: purpose in one sentence,
the single user it serves, hard constraints (platform, offline, budget, privacy),
success criteria, and — mandatory — **out of scope**. Naming non-goals is the
cheapest drift prevention that exists. Every generated CLAUDE.md ends with an
"Out of Scope" section.

### Step 2 — Investigate
Before choosing anything: what already exists (prior art, libraries, the user's
own past projects), what the riskiest unknown is, and what the smallest
experiment to kill that risk would be. Output: a short list of risks with a
spike plan for the top one. Brainstorm wide here, commit narrow.

### Step 3 — Architect
Produce the dependency graph as a contract, not a diagram. Rules of thumb that
held across all six projects:

- **Pure core, impure shell.** Parsers, reducers, codecs as pure functions with
  zero I/O — testable by passing values. I/O lives at the edges.
- **Layers import downward only.** Crossing layers is a smell; extract or relocate.
- **One trust boundary, named explicitly.** (IPC bridge, XPC, API edge.) Nothing
  else crosses processes.
- **Specific knowledge quarantined.** Machine/vendor/locale-specific constants
  live in named files, never scattered.
- **State has one source of truth** and one mutation pathway.

### Step 4 — Phase
Break the build into phases with explicit gates: "tsc + build pass, dev launches,
acceptance criteria met." One phase per branch, squash-merged, tagged. The
roadmap is the resume protocol.

### Step 5 — Generate
Emit the tailored kit: `CLAUDE.md` from the template with every slot filled,
`docs/registry/` seeded with real initial content (the architecture decisions
from Step 3 become the first DECISIONS.md entries; the risks from Step 2 become
the first ISSUES.md entries).

---

## 6. Context Economy

Claude's context window is the scarcest resource in the system.

- On session start: read the project `CLAUDE.md`, the registry index, and only
  the files you will edit. Do not read the entire source tree.
- Read one pattern example, apply to all — sibling modules are intentionally
  identical, that is what the conventions buy.
- The project CLAUDE.md stays under ~150 lines. Deep content links out.
  A 20KB CLAUDE.md is a tax on every single session.
- Avoid the last 20% of the context window for multi-file work.

---

## 7. Delegation and Parallelism

Default to delegation when work splits cleanly; direct work when it does not.

Delegate when: a phase has 3+ independent files in different domains; a pure
component can be built against a locked interface; tests can be written in
parallel with implementation against the same locked interface.

Do not delegate when: the component is small and tightly coupled to surrounding
code; every file depends on every other; you cannot write a self-contained
brief without rereading half the repo (then the agent cannot work from it either).

The pattern that worked: lock interface contracts first in a sync step, then
spawn N agents with disjoint file scopes, explicit doc citations, a named test
framework, a required build/test run, and a required structured report. Then
integrate and reconcile drift.

---

## 8. Session Continuity and Limits

- Near the end of a long session, stop starting multi-step work. Land the
  current commit cleanly, update SESSION_LOG and ISSUES, and state: what was
  completed, repo state, the next concrete step, and anything needing review.
- Never leave a broken tree or half-finished commit hoping to come back.
  Complete it or revert it.
- Resume protocol: SESSION_LOG.md (most recent entry) then ROADMAP.md (first
  unchecked task). That pair is the whole handoff — and the session-resume
  hook injects it automatically at session start, so the loop closes without
  relying on anyone remembering to read.

---

## 9. Unattended Operation

When running with reduced permission prompts, trust comes with bright lines.
Will: push after every successful commit (no force), keep registries current.
Will not: force-push or rewrite remote history, run sudo, hard-reset or
`git clean -f`, touch files outside the project, make unapproved outbound
network calls, delete files it did not create without checking, or bypass
failing tests. When in doubt: stop, log the blocker in SESSION_LOG, wait.

---

## 10. Evolving This System

This system is designed to be modified — that is the point of Layer 2.

- A rule that a project repeatedly violates is wrong for that project: record
  the deviation in DECISIONS.md, and if it recurs across projects, change the
  template here.
- After each project ships, do a five-minute autopsy: which registry earned its
  keep, which gate was friction without payoff, what new landmine category
  appeared. Fold the answer into `templates/`.
- ANALYSIS.md is the precedent record. When unsure whether an idea belongs in
  the doctrine, check whether one of the six sources already tried it.
