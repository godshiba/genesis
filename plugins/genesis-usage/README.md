English | [中文](./README.zh-CN.md) | [Русский](./README.ru.md)

# GENESIS Usage Sensor

A **sensor, not a HUD.** It stays quiet until you are about to hit a Claude Code
rate-limit cap, then tells you to checkpoint — or, if you ask it to, makes it
happen. It is the trigger half of the GENESIS G7 emergency close.

There are already good usage HUDs (claude-hud, cc-usage-monitor). This is not
another one. It answers a different question: not *"how much have I used?"* but
*"...so close the session cleanly, now, before the cutoff strands your work."*

---

## New here? The 30-second version

1. Install (three lines, run one at a time):

   ```text
   /plugin marketplace add godshiba/genesis
   /plugin install genesis-usage@godshiba
   /genesis-usage:setup
   ```

2. That's it. From now on, when you get near your 5-hour or weekly limit while
   actually working, Claude will warn you to run `/genesis:close` so you don't
   lose your place. The rest of this page is for when you want to tune it.

**One caveat, told honestly:** the usage numbers only exist on **Claude.ai
Pro/Max** accounts (Claude Code v1.0.80+), and only **after Claude's first reply
in a session**. On API-key billing there is no rate-limit data, so the sensor
stays silent — that is expected, not a bug.

---

## What it actually does

Claude Code passes a subscriber `rate_limits` object on hook stdin — `five_hour`
and `seven_day` windows, each with `used_percentage` and `resets_at`. A **Stop
hook** (runs when each turn ends) reads it and decides whether to speak:

- **advise** (default) — prints a one-line recommendation to your terminal,
  then lets the turn end normally.
- **enforce** — blocks the turn so Claude runs `/genesis:close` before ending.
  Only inside a GENESIS project; elsewhere it falls back to advise.

It fires **at most once per rising 5-point usage bucket per session**, and only
when the window's reset is still far enough out to actually risk a cutoff — a
nudge at the right moment, not a nag every turn.

```
5h usage 91% (resets in 0h23m). Run /genesis:close now - capture mid-task
state in SESSION_LOG before the cutoff.
```

---

## Configuration

`/genesis-usage:setup` is the easy path — it asks what you want and writes it
for you. `/genesis-usage:setup 80` sets the 5-hour cap to 80 in one shot.

Prefer to do it by hand, or want the full list? Every option is an environment
variable. Set them **globally** in `~/.claude/settings.json` under `"env"`, or
**per-project** in that repo's `.claude/settings.json` (which overrides the
global value just for that repo — the right move when only some projects need a
tighter cap):

| Variable | Default | What it does |
|----------|---------|--------------|
| `GENESIS_USAGE_MODE` | `advise` | `advise` (warn), `enforce` (block so Claude closes), or `off`. |
| `GENESIS_USAGE_THRESHOLD` | `90` | 5-hour usage % that triggers. Set `80` to fire earlier. |
| `GENESIS_USAGE_WEEK_THRESHOLD` | `85` | 7-day usage % that triggers. |
| `GENESIS_USAGE_GRACE_SECS` | `120` | Stay silent if the window resets within this many seconds (it is about to refresh anyway). |
| `GENESIS_USAGE_NOTIFY` | `off` | `on` also posts a macOS desktop notification when the sensor fires. |
| `GENESIS_OFF` | unset | `1` silences this and every GENESIS hook entirely. |

Example — fire at 80%, and ping me even when I'm in another app:

```json
{
  "env": {
    "GENESIS_USAGE_THRESHOLD": "80",
    "GENESIS_USAGE_NOTIFY": "on"
  }
}
```

The sensor re-reads the environment every turn, so changes take effect on the
next turn — no restart needed (the statusline below is the one exception).

---

## Desktop notifications

Set `GENESIS_USAGE_NOTIFY=on` and, when the sensor fires, you also get a native
macOS notification — so you find out you are near a cap even when Claude Code is
behind your browser or editor. It uses `osascript`; on systems without it, the
notification is skipped silently and the in-terminal warning still appears.

This is the lightweight answer to "what if I walk away" — no menu-bar app
required.

---

## Optional statusline

A lean one-line readout — `Opus  ctx 38%  5h 91%  7d 62%  main` — with usage
colored green/yellow/red. It is **opt-in** (only one statusline can be active at
a time, so the plugin never overrides yours). `/genesis-usage:setup` wires it.
Deliberately minimal: no tool/agent/todo parsing, no boxes. If you want a full
HUD, run a dedicated HUD plugin alongside this sensor.

---

## Troubleshooting

- **I never see anything.** Most likely working as intended. Check, in order:
  are you on Pro/Max (not API keys)? Has Claude replied at least once this
  session? Are you actually above the threshold? Is `GENESIS_USAGE_MODE` set to
  `off`, or `GENESIS_OFF=1` set?
- **It warned once and went quiet.** By design — it fires once per rising
  5-point bucket per session, so it will speak again at the next bucket (e.g.
  90 → 95), not every turn.
- **It warned right before the limit reset.** Raise `GENESIS_USAGE_GRACE_SECS`
  so it stays quiet when a reset is imminent.
- **Enforce mode did not block.** Enforce only blocks inside a GENESIS project
  (one with `docs/registry/`); elsewhere it advises instead.

---

## Fail-open and privacy

Silent without `python3`, without `rate_limits` (API-key users), or on any parse
error — it never blocks a turn in `advise` mode, and never blocks outside a
GENESIS project. It reads only what Claude Code already hands it on stdin, makes
no network calls, and writes only a tiny throttle file under your temp dir.

---

## Relationship to GENESIS

The [`genesis`](../genesis) plugin's `/genesis:close` has an emergency mode that
captures mid-task state before a cutoff. This sensor is what tells you (or
Claude) to run it at the right moment. Useful on its own; better together.

## License

MIT
