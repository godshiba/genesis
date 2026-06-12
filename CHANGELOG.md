# Changelog

## 1.2.0 — 2026-06-12

The doc curation release.

Added:

- **`/genesis:docs` skill + `doc-curator` agent.** Reorganizes existing
  documentation: inventories and classifies every doc, absorbs
  registry-shaped knowledge (decision records, gotcha notes, TODO lists)
  into the GENESIS registries, moves/merges files into a clean structure,
  flags claims that contradict the code, and writes missing docs from code
  evidence. Everything is presented as a migration plan behind an approval
  gate and executed as a single revertible commit via `git mv`. Knowledge is
  never lost: deletion only for junk or fully-absorbed sources.
- `/genesis:init` now offers the curation protocol when retrofitting a repo
  that carries more than a handful of doc files.

## 1.1.0 — 2026-06-12

The resume-loop and conduct release. Researched against
multica-ai/andrej-karpathy-skills and affaan-m/ECC; adopted what completed
existing GENESIS loops, rejected what duplicated other tools or added
dependencies.

Added:

- **Session-resume hook (SessionStart).** The read side of G7: the last
  SESSION_LOG handoff, next unchecked ROADMAP task, and open issue count are
  injected automatically when a session starts in a GENESIS project. Zero
  cold starts, mechanically.
- **G2 config guard (PostToolUse).** Editing a test/lint config (vitest,
  eslint, coverage, and similar) now reminds that fixing code beats weakening
  gates, and that intentional changes are G6 decisions. Compiler configs are
  deliberately excluded.
- **Conduct section** in generated CLAUDE.md files and the doctrine — four
  rules derived from Karpathy's LLM-pitfall guidelines (surface assumptions,
  simplicity first, surgical diffs, goal-driven steps), wired into gates
  G2/G4/G6 rather than pasted as slogans.
- **EXAMPLES.md** — a worked end-to-end example of generated output.
- **CHANGELOG.md** — this file.

Changed:

- README restructured: install-first, summary up top, example linked.
- README translations added: Chinese (README.zh-CN.md) and Russian
  (README.ru.md), with a language switcher on all three.

## 1.0.0 — 2026-06-11

Initial release: doctrine (MASTER.md), six-project analysis (ANALYSIS.md),
CLAUDE.md template with seven gates, six registry skeletons, seven skills
(init, gate-check, close, landmine, decision, issue, learn), two agents
(gate-auditor, genesis-architect), four enforcement hooks (G7 session guard,
G1 registration nudge, G3 issue nudge, G2 commit reminder).
