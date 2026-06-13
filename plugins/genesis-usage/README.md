# GENESIS Usage Sensor

A **sensor, not a HUD.** It stays quiet until you are about to hit a Claude Code
rate-limit cap, then tells you to checkpoint — or, in enforce mode, makes it
happen. It is the trigger half of the GENESIS G7 emergency close.

There are already good usage HUDs (claude-hud, cc-usage-monitor). This is not
another one. It answers a different question: not *"how much have I used?"* but
*"...so close the session cleanly, now, before the cutoff strands your work."*

## How it works

Claude Code passes a subscriber `rate_limits` object on hook stdin — `five_hour`
and `seven_day` windows, each with `used_percentage` and `resets_at` (Pro/Max
only, v1.0.80+, after the first response in a session). A **Stop hook** reads it
at the end of each turn and decides whether to act:

- **advise** (default) — prints a one-line recommendation to stderr (shown
  inline in the CLI), then lets the turn end normally.
- **enforce** — blocks the stop so Claude runs `/genesis:close` before ending.
  Only in a GENESIS project; elsewhere it falls back to advise.

It fires **at most once per rising 5-point usage bucket per session**, and only
when the window's reset is still far enough out to actually risk a cutoff — so
it is a nudge at the right moment, not a nag every turn.

```
5h usage 91% (resets in 0h23m). Run /genesis:close now - capture mid-task
state in SESSION_LOG before the cutoff.
```

## Install

```text
/plugin marketplace add godshiba/genesis
/plugin install genesis-usage@godshiba
/genesis-usage:setup
```

The sensor is active immediately after install — `setup` only tunes it and
optionally wires the statusline.

## Configuration

Environment variables (set in `~/.claude/settings.json` `"env"` or your shell):

| Variable | Default | Meaning |
|----------|---------|---------|
| `GENESIS_USAGE_MODE` | `advise` | `advise`, `enforce`, or `off`. |
| `GENESIS_USAGE_THRESHOLD` | `90` | 5-hour usage % that triggers. |
| `GENESIS_USAGE_WEEK_THRESHOLD` | `85` | 7-day usage % that triggers. |
| `GENESIS_USAGE_GRACE_SECS` | `120` | Stay silent if the window resets within this many seconds. |

## Optional statusline

A lean one-line readout — `model  ctx 38%  5h 91%  7d 62%  main` — with usage
colored green/yellow/red. It is **opt-in** (one statusline can be active at a
time, so the plugin never overrides yours). `/genesis-usage:setup` wires it.
Deliberately minimal: no tool/agent/todo parsing, no boxes. If you want a full
HUD, use one of the dedicated HUD plugins alongside this sensor.

## Fail-open

Silent without `python3`, without `rate_limits` (API-key users see nothing), or
on any parse error. It never blocks a turn in `advise` mode, and never blocks
outside a GENESIS project. A shell over Claude Code, never in its way.

## Relationship to GENESIS

The [`genesis`](../genesis) plugin's `/genesis:close` has an emergency mode that
captures mid-task state before a cutoff. This sensor is what tells you (or
Claude) to run it at the right moment. Useful on its own; better together.

## License

MIT
