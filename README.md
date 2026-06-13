English | [中文](./README.zh-CN.md) | [Русский](./README.ru.md)

[![CI](https://github.com/godshiba/genesis/actions/workflows/ci.yml/badge.svg)](https://github.com/godshiba/genesis/actions/workflows/ci.yml)

# GENESIS

A project operating system for Claude Code. One doctrine: **what isn't
registered doesn't exist.**

- **Permanent project memory** — six registries survive what conversation
  memory loses: decisions, landmines, issues, sessions, files, roadmap
- **Seven gates with real teeth** — hooks block unlogged session handoffs and
  nudge violations the moment they happen
- **Zero cold starts** — the next session auto-loads the last handoff and
  continues exactly where you stopped

Distilled from six real shipped projects — the full evidence record is in
[ANALYSIS.md](./plugins/genesis/ANALYSIS.md). See real generated output in
[EXAMPLES.md](./EXAMPLES.md).

## Install

Run these one at a time (each is a separate command — pasting both on one
line breaks the URL):

```text
/plugin marketplace add godshiba/genesis
```

```text
/plugin install genesis@godshiba
```

Then, in any project (new or existing):

```text
/genesis:init
```

## The problem

Every Claude Code session starts with amnesia. The model that knew why you
chose SQLite, which API lies in its documentation, and what the next step was
— gone the moment the session ends. Multi-session projects pay a recurring
tax: re-reading the tree, re-deriving decisions, re-stepping on the same
landmines. And projects started without preparation pay a second tax:
unexamined assumptions about scope, architecture, and what "done" means.

GENESIS eliminates both. Project knowledge lives in files that outlive every
session, gates define "done" mechanically, and hooks enforce the critical
rules so discipline does not depend on anyone's memory — including Claude's.

## How it works

### 1. Prep before code — `/genesis:init`

On a new project it interviews you: purpose in one sentence, hard constraints,
success criteria, and — mandatory — at least three named non-goals, because an
explicit out-of-scope list is the cheapest drift prevention that exists. It
then investigates the riskiest unknown, designs the architecture as a
dependency contract, and phases the build with acceptance gates.

On an existing repo it reads instead of asking — stack from manifests,
commands from scripts, history from git — and retrofits around what is there.
If the repo already carries scattered documentation, `/genesis:docs` curates
it: every doc inventoried and classified, decision records and gotcha notes
absorbed into the registries, files moved or merged into a clean structure,
stale claims flagged against the code, missing docs written from code
evidence — all presented as a migration plan you approve first, executed as
one revertible commit.

The output: a tailored `CLAUDE.md` (under 150 lines) with project invariants,
a conduct section, the gates, and the project's permanent memory:

### 2. The registries — `docs/registry/`

| File | Question it answers |
|------|--------------------|
| `FILES.md` | Where does everything live? |
| `ISSUES.md` | What is broken, deferred, or limited? (`ISS-NNN`) |
| `DECISIONS.md` | Why is it built this way? (append-only, with rejected alternatives) |
| `LANDMINES.md` | What will trip the next session up? |
| `SESSION_LOG.md` | What happened, and what is the next concrete step? |
| `ROADMAP.md` | What phase are we in, and what is its gate? |

### 3. The daily loop

Capture costs five seconds, so it actually happens:

| Command | When |
|---------|------|
| `/genesis:landmine` | Something just cost you ten confused minutes |
| `/genesis:decision` | You chose between real alternatives |
| `/genesis:issue` | A bug or deferral should not live in a TODO comment |
| `/genesis:status` | Any moment — one-screen dashboard: phase, issues, last handoff |
| `/genesis:gate-check` | Before a commit — audits all seven gates |
| `/genesis:close` | Ending a session — writes the handoff |
| `/genesis:learn` | After shipping — fold lessons back into the system |

### 4. The seven gates

A task is done only when all pass:

1. **Registration** — every new file has a row in `FILES.md`
2. **Validation** — the project check command is green; never proceed on red
3. **Issue** — problems become `ISS-NNN` entries, not TODO comments
4. **Doc-sync** — change X means update doc Y, same commit
5. **Landmine** — gotchas are recorded the moment they cost time
6. **Decision** — non-obvious choices are recorded with rejected alternatives
7. **Session** — work ends with a handoff: what changed, repo state, next step

Each gate gets the strongest enforcement its nature allows. Hooks handle the
mechanical ones: G7 **blocks** ending a turn that changed code without
touching the session log; G1 and G3 nudge on unregistered files and orphan
TODOs; G2's obligation is injected before every git commit, and a config
guard fires when a test or lint config is edited (fixing code beats weakening
gates). A pre-compaction hook snapshots the working tree before Claude Code
compacts a long conversation, so nothing is lost across that boundary. The
project-specific checks (running your check command, auditing the doc-sync
map) live in `gate-check` and `close`. The judgment calls (G5, G6) are probed
by the `gate-auditor` agent, which flags probable misses rather than
pretending grep can detect a decision.

Generated projects also carry a four-rule **Conduct** section (derived from
Karpathy's LLM-pitfall guidelines): surface assumptions, simplicity first,
surgical diffs, goal-driven steps — wired into the gates, not pasted as
slogans.

### 5. Resume — the closed loop

`/genesis:close` writes the handoff; the **session-resume hook reads it back
automatically** when the next session starts — last handoff, next roadmap
task, open issues, injected before you type a word. See it in
[EXAMPLES.md](./EXAMPLES.md#what-the-next-session-sees).

### 6. Surviving the two cutoffs

A session ends two ways, and the loop covers both:

- **The context window fills** and Claude Code compacts the conversation into a
  lossy summary. The pre-compaction hook fires first, writing the working-tree
  state to `docs/registry/.session-snapshot.md`; the resume hook surfaces it
  next session, and `/genesis:close` clears it once a real handoff replaces it.
  Fully automatic — you run nothing.
- **The usage cap (5-hour or weekly) is hit** and Claude Code stops abruptly.
  That gauge is not exposed to hooks, so there is no automatic trigger — *you*
  are the sensor. When `/usage` shows the cap nearing, run **`/genesis:close`**:
  its emergency mode records exactly where mid-task work sits and stops, so the
  next session (after the reset) resumes from the handoff instead of stranded,
  unrecorded work.

## Who this is for

**New to Claude Code:** install, run `/genesis:init`, answer the questions.
You get a project that explains itself, and you can close your laptop
mid-feature and lose nothing. [MASTER.md](./plugins/genesis/MASTER.md) doubles
as a short course in why each practice exists.

**Professional:** mechanical enforcement and zero drift — gates as hooks
instead of vibes, dependency-graph-as-contract architecture output, explicit
delegation criteria for multi-agent work, and a feedback loop that turns
project experience into template improvements. Plain markdown and shell —
fork it and make it yours.

## Compatibility

A shell over Claude Code's existing architecture, not a replacement for any
of it. Every hook fails open: in a project without `docs/registry/`, GENESIS
is completely silent. It composes with your other plugins, agents, and
skills (including learning systems like ECC — GENESIS persists to repo files,
they persist to their own state; no overlap). Hooks use `git` and `python3`
when present and stay silent when they are not. Stack-agnostic by design.

## What's in the box

```text
plugins/genesis/
├── MASTER.md            the doctrine — why each piece exists
├── ANALYSIS.md          the six-project autopsy GENESIS was distilled from
├── templates/           CLAUDE.template.md + the six registry skeletons
├── skills/              init, docs, status, gate-check, close, landmine,
│                        decision, issue, learn
├── agents/              gate-auditor, genesis-architect, doc-curator
└── hooks/               G7 session guard (blocking) + session-resume loader +
                         pre-compaction snapshot, G1/G3 nudges,
                         G2 commit reminder + config guard
tests/run.sh             hook test suite (30 scenarios, runs in CI)
EXAMPLES.md              real generated output, end to end
CHANGELOG.md             release history
```

## License

MIT
