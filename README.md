# GENESIS

A project operating system for Claude Code.

## The problem

Every Claude Code session starts with amnesia. The model that knew exactly why
you chose SQLite over IndexedDB, which API lies in its documentation, and what
the next step was — that model is gone when the session ends. What survives is
the code and, if you are lucky, a stale CLAUDE.md.

So multi-session projects pay a recurring tax: re-reading the tree,
re-deriving decisions, re-stepping on the same landmines, re-asking "where was
I?" And projects started without preparation pay a second tax: unexamined
assumptions about scope, architecture, and what "done" means — discovered
expensively, mid-build.

GENESIS exists to eliminate both taxes. Its doctrine fits in one line:

**What isn't registered doesn't exist.**

It was distilled from six real projects (Electron apps, Swift menu-bar apps,
vanilla-JS PWAs). Every practice in it earned its place in a shipped project;
the full lineage — what each source project did well and where it failed — is
in [ANALYSIS.md](./plugins/genesis/ANALYSIS.md).

## How it works

### 1. Prep before code

```text
/genesis:init
```

On a new project it interviews you: purpose in one sentence, hard constraints,
success criteria, and — mandatory — at least three named non-goals, because an
explicit out-of-scope list is the cheapest drift prevention that exists. It
then investigates the riskiest unknown, designs the architecture as a
dependency contract (which imports are permitted; everything else is
forbidden), and phases the build with acceptance gates.

On an existing repo it reads instead of asking: stack from manifests, commands
from scripts, history from git — and retrofits around what is already there.
It never overwrites an existing CLAUDE.md without approval.

Either way, the output is a tailored `CLAUDE.md` (under 150 lines — context is
a scarce resource) plus the project's permanent memory:

### 2. The registries

Six files in `docs/registry/`, each answering one question any future session
will ask:

| File | Question it answers |
|------|--------------------|
| `FILES.md` | Where does everything live? |
| `ISSUES.md` | What is broken, deferred, or limited? (`ISS-NNN`, severity-tagged) |
| `DECISIONS.md` | Why is it built this way? (append-only, with rejected alternatives) |
| `LANDMINES.md` | What will trip the next session up? |
| `SESSION_LOG.md` | What happened, and what is the next concrete step? |
| `ROADMAP.md` | What phase are we in, and what is its gate? |

Conversation memory dies at session end. Registries do not.

### 3. The daily loop

Capture costs five seconds, so it actually happens:

| Command | When |
|---------|------|
| `/genesis:landmine` | Something just cost you ten confused minutes |
| `/genesis:decision` | You chose between real alternatives |
| `/genesis:issue` | A bug or deferral should not live in a TODO comment |
| `/genesis:gate-check` | Before a commit — audits all seven gates |
| `/genesis:close` | Ending a session — the handoff ritual |
| `/genesis:learn` | After shipping — fold lessons back into the system |

### 4. The seven gates

A task is done only when all pass:

1. **Registration** — every new file has a row in `FILES.md`
2. **Validation** — the project check command is green; never proceed on red
3. **Issue** — problems become `ISS-NNN` entries, not TODO comments
4. **Doc-sync** — change X means update doc Y, same commit
5. **Landmine** — gotchas are recorded the moment they cost time
6. **Decision** — non-obvious choices are recorded with rejected alternatives
7. **Session** — work ends with a log entry: what changed, repo state, next step

Gates are not guidelines, because guidelines compete with momentum and lose.
Each gate gets the strongest enforcement its nature allows. Hooks handle the
mechanical ones: G7 **blocks** ending a turn that changed code without
touching the session log; G1 and G3 nudge the model the instant it writes an
unregistered file or an orphan TODO; G2's obligation is injected right before
every git commit. The project-specific ones (running your check command,
auditing the doc-sync map) live in `gate-check` and `close`, which refuse to
report clean over a red check. The judgment calls (G5, G6) are probed by the
`gate-auditor` agent, which flags probable misses rather than pretending grep
can detect a decision.

### 5. Resume

The next session — tomorrow, next month, or a different agent entirely — reads
the top `SESSION_LOG.md` entry and the first unchecked `ROADMAP.md` task, and
continues. That pair is the whole handoff. No tree-spelunking, no "what was I
doing?".

## Install

```text
/plugin marketplace add godshiba/genesis
/plugin install genesis@godshiba
```

Then run `/genesis:init` in any project.

## Who this is for

**New to Claude Code or AI-assisted work:** install it, run `/genesis:init`,
answer the questions. You get a project that explains itself, and you can
close your laptop mid-feature and lose nothing. The doctrine file
([MASTER.md](./plugins/genesis/MASTER.md)) doubles as a short course in why
each practice exists.

**Professional:** the value is mechanical enforcement and zero drift — gates
as hooks instead of vibes, dependency-graph-as-contract architecture output,
explicit delegation criteria for multi-agent work, and a feedback loop
(`/genesis:learn`) that turns project experience into template improvements.
Everything is plain markdown and shell — fork it and make it yours.

## Compatibility

GENESIS is a shell over Claude Code's existing architecture, not a
replacement for any of it. Every hook fails open: in a project without
`docs/registry/`, the plugin is completely silent and changes nothing. It
composes with your other plugins, agents, and skills. The hooks use `git` and
`python3` when present and stay silent when they are not. Stack-agnostic by
design — the templates carry no assumptions about language or framework.

## What's in the box

```text
plugins/genesis/
├── MASTER.md            the doctrine — why each piece exists
├── ANALYSIS.md          the six-project autopsy GENESIS was distilled from
├── templates/           CLAUDE.template.md + the six registry skeletons
├── skills/              init, gate-check, close, landmine, decision, issue, learn
├── agents/              gate-auditor, genesis-architect
└── hooks/               G7 session guard (blocking), G1/G3 nudges, G2 commit reminder
```

## License

MIT
