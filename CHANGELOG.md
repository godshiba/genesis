# Changelog

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

## 1.0.0 — 2026-06-11

Initial release: doctrine (MASTER.md), six-project analysis (ANALYSIS.md),
CLAUDE.md template with seven gates, six registry skeletons, seven skills
(init, gate-check, close, landmine, decision, issue, learn), two agents
(gate-auditor, genesis-architect), four enforcement hooks (G7 session guard,
G1 registration nudge, G3 issue nudge, G2 commit reminder).
