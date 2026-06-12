---
name: init
description: Run the GENESIS prep protocol before building any project, or retrofit it onto an existing repo. Interviews for purpose/constraints/out-of-scope, investigates risks, produces an architecture contract and phase roadmap, then generates a tailored CLAUDE.md plus docs/registry/ (FILES, ISSUES, DECISIONS, LANDMINES, SESSION_LOG, ROADMAP). Use when starting a new project, when a repo has no CLAUDE.md, or when the user asks to genesis, prep, init, or bootstrap a project.
---

# /genesis:init — The GENESIS Prep Protocol

Source of truth: the plugin's `MASTER.md` (doctrine) and `templates/`
(CLAUDE.template.md + registry skeletons). Both live at the plugin root —
two directories above this skill's base directory, i.e. `../../MASTER.md`
and `../../templates/` from here. Read both before generating anything. Do
not improvise structure that the templates already define.

The doctrine in one line: **what isn't registered doesn't exist.** The output
of this skill is a project where that is mechanically true from day zero.

## Mode Detection

Inspect the working directory first:

- **Greenfield** (empty, or no source code): run all five steps below.
- **Existing repo**: skip interview questions the repo already answers. Detect
  stack and commands from manifests (package.json, Package.swift, Cargo.toml,
  pyproject.toml, go.mod, Makefile), derive the dependency graph from imports,
  and mine git history plus existing docs for landmines and decisions already
  paid for. Then run only the steps with gaps (usually Interrogate's
  out-of-scope question and Phase). If the repo carries more than a handful
  of doc files, offer the `/genesis:docs` curation protocol as part of the
  retrofit — it inventories every doc, absorbs registry-shaped knowledge
  (decisions, gotchas, TODO lists) into the new registries, and reorganizes
  the rest behind an approval gate.
- **Already has a CLAUDE.md**: do not overwrite. Read it, map its content onto
  the template slots, propose a migration diff, and get approval first.

## Calibrating to the user

If the user seems new to Claude Code (asks what a step is for, or says so),
briefly explain each step's purpose as you go and include the "Why these gates
exist" pointer in the generated CLAUDE.md. If the user is clearly experienced,
be terse: ask, decide, generate. Never skip steps in either mode — calibration
changes narration, not rigor.

## Step 1 — Interrogate

Ask via AskUserQuestion, batched sensibly (not one giant wall). Required
answers — do not proceed with blanks:

1. Purpose in one sentence, and the single primary user.
2. Hard constraints: platform, offline/online, privacy, budget, deadline.
3. Success criteria: how do we know v1 is done?
4. **Out of scope** — mandatory, minimum three named non-goals. If the user
   cannot name any, propose three plausible scope-creep candidates from the
   project description and ask them to confirm or replace. Never skip this.
5. Quality tier: does this project get tests (and which kinds), or are
   typecheck/lint the gates? Record the answer; it sets the check command.

## Step 2 — Investigate

Before any stack or architecture commitment:

- Identify prior art: existing libraries, similar tools, and the user's own
  past projects.
- Name the riskiest unknown — the thing most likely to kill or reshape the
  project — and define the smallest spike that would resolve it.
- Output: a short risk list. These become the first ISS-NNN entries
  (severity `deferred`, investigation paths filled in).

Use web search only when the question genuinely needs current external facts
(library status, API availability); otherwise reason from the repo and brief.

## Step 3 — Architect

Produce the dependency graph as a contract — a tree or arrow diagram where an
edge is a permitted import and everything else is forbidden. For non-trivial
projects, delegate this step to this plugin's `genesis-architect` agent
(registered as `genesis:genesis-architect`) via the Agent tool, passing the
purpose, constraints, stack, and quality tier in the brief. Apply the doctrine
biases and record each as a numbered invariant for the CLAUDE.md:

- Pure core, impure shell: parsers/reducers/codecs as pure functions, I/O at
  the edges.
- Layers import downward only.
- One named trust boundary if the project crosses processes or networks.
- Specific knowledge (vendor, machine, locale constants) quarantined in named
  files.
- One source of truth per piece of state, one mutation pathway.

Each significant choice here (framework, persistence, process model) becomes a
DECISIONS.md entry with rejected alternatives. Write them now, not later.

## Step 4 — Phase

Break the build into phases with acceptance criteria and the standard gate
(check command green + launches + criteria met). Phase 0 is always scaffold +
check command working — the validation gate must exist before there is code to
validate. Fill the ROADMAP.md template.

## Step 5 — Generate

1. Copy the plugin's `templates/registry/` (at `../../templates/registry/`
   from this skill's base directory) to `docs/registry/` and seed it with real
   content: Step 3 decisions into DECISIONS.md, Step 2 risks into ISSUES.md,
   every file the scaffold will create into FILES.md, phases into ROADMAP.md,
   and a genesis entry into SESSION_LOG.md (what was decided, next step =
   Phase 0 first task).
2. Fill every `{{SLOT}}` in the plugin's `templates/CLAUDE.template.md` and
   write it as `./CLAUDE.md`. No slot may survive as a literal placeholder.
   Keep it under ~150 lines; anything deeper links out.
3. Verify the seven gates are coherent: G2's command exists (or Phase 0 task 1
   creates it), the doc-sync map names real files, out-of-scope has at least
   three entries.
4. Report to the user: the generated tree, the invariants chosen, the riskiest
   unknown and its spike, and the first roadmap task. Then stop — building
   Phase 0 is a separate, explicit request.

## Hard Rules

- Never overwrite an existing CLAUDE.md or registry file without approval.
- Never leave a placeholder slot in generated output.
- Out of scope is never empty.
- The generated CLAUDE.md must contain all seven gates verbatim in spirit —
  tailored commands and paths, untouched obligations.
