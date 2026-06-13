# Changelog

## 1.4.0 — 2026-06-13

The cutoff-survival release. Completes the G7 loop for both ways a session
ends: the context window filling, and the usage cap being hit.

Added:

- **Pre-compaction snapshot hook (PreCompact).** Just before Claude Code
  compacts a long conversation into a lossy summary, a mechanical breadcrumb of
  repo state (branch, HEAD, uncommitted files) is written to
  `docs/registry/.session-snapshot.md`. If the session then ends mid-task
  before a proper close, the resume hook surfaces it next session so nothing
  about the working tree is lost across the compaction boundary. Fails open.
- **Emergency mode for `/genesis:close`.** The 5-hour and weekly rate-limit
  gauges are not exposed to hooks, so there is no automatic trigger — you are
  the sensor. When `/usage` shows the cap nearing, `/genesis:close` now has a
  fast path: capture exactly where mid-task work sits, append the SESSION_LOG
  handoff, and stop — without spending the remaining budget settling the tree.

Changed:

- **Resume loader** surfaces `.session-snapshot.md` when present (and
  `/genesis:close` deletes it once a real handoff supersedes it) — a symmetric
  write/read/supersede loop alongside the existing SESSION_LOG handoff.
- **Doctrine and template** now carry the two-cutoff model and a sharper
  delegation discipline: delegate read-heavy work to subagents to preserve the
  main context window, work in small batches, and checkpoint between them so a
  cutoff loses at most one batch. Propagated into every generated CLAUDE.md.
- Hook test suite expanded to 30 scenarios (snapshot write, fail-open, and
  resume surfacing).

## 1.3.0 — 2026-06-12

The trust release: mechanical beats instructional, applied to the plugin
itself.

Added:

- **Hook test suite** (`tests/run.sh`) — 26 scenarios covering all six hook
  scripts: blocking, nudging, loop prevention, and the fail-open guarantees
  (silent outside GENESIS projects).
- **CI** (GitHub Actions) — runs the hook tests, strict plugin/marketplace
  validation via the Claude Code CLI, and frontmatter/JSON structure checks
  on every push and pull request. Badge in the README.
- **`/genesis:status`** — read-only one-screen dashboard: current phase and
  next task, open issues by severity, last handoff age, registry sizes, tree
  state. Orientation in seconds; verification stays in gate-check.
- Tagged releases: v1.0.0 through v1.3.0 now exist as git tags with GitHub
  Releases.

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
