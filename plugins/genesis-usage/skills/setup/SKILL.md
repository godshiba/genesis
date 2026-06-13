---
name: setup
description: Configure the GENESIS usage sensor interactively - set the trigger cap (5h/7d), choose advise/enforce/off, toggle desktop notifications, and optionally wire the statusline readout. Persists to settings.json. Use after installing genesis-usage, or when the user asks to set up / change the usage cap, threshold, sensor mode, notifications, or the usage statusline.
---

# /genesis-usage:setup - Configure the usage sensor

The sensor works out of the box; this makes it yours. It writes choices into
`~/.claude/settings.json` so you never hand-edit JSON or memorize an env var.

If the user passed a number as an argument (e.g. `/genesis-usage:setup 80`),
treat it as the desired 5-hour cap and skip straight to writing it.

## 1. Check eligibility first (be honest)

The sensor only fires on **Claude.ai Pro/Max** (Claude Code **v1.0.80+**), and
only **after the first model response** in a session - that is when Claude Code
starts sending `rate_limits`. On API-key-only accounts it stays silent by
design. If the user is on API keys, say so plainly and stop - configuring it
will not make data appear.

## 2. Ask what they want (one short round)

Confirm or collect, with current values shown if already set:

- **Cap** - the 5-hour usage %% that triggers (default 90). Offer the 7-day cap
  too (default 85); most people only set the 5-hour one.
- **Mode** - `advise` (warn in the terminal, default), `enforce` (block the
  turn so Claude runs `/genesis:close`), or `off`.
- **Desktop notification** - `on`/`off` (default off). When on, the sensor also
  posts a macOS notification, useful when you are working in another app.
- **Statusline** - whether to add the one-line readout (see step 4).

Do not over-ask: if they said "trigger at 80", set the 5-hour cap to 80, leave
everything else default, and move on.

## 3. Write the config

Merge into `~/.claude/settings.json` under `"env"` (create the block if absent;
preserve anything already there). Only write keys that differ from the default:

```json
{
  "env": {
    "GENESIS_USAGE_THRESHOLD": "80",
    "GENESIS_USAGE_WEEK_THRESHOLD": "80",
    "GENESIS_USAGE_MODE": "advise",
    "GENESIS_USAGE_NOTIFY": "on"
  }
}
```

For a **per-project** cap instead of global, write the same `"env"` block into
that project's `.claude/settings.json` - it overrides the global default there.
This is the right answer when only some repos need a tighter cap.

Full variable reference:

| Variable | Default | Meaning |
|----------|---------|---------|
| `GENESIS_USAGE_MODE` | `advise` | `advise`, `enforce`, or `off`. |
| `GENESIS_USAGE_THRESHOLD` | `90` | 5-hour usage %% that triggers. |
| `GENESIS_USAGE_WEEK_THRESHOLD` | `85` | 7-day usage %% that triggers. |
| `GENESIS_USAGE_GRACE_SECS` | `120` | Stay silent if the window resets within this many seconds. |
| `GENESIS_USAGE_NOTIFY` | `off` | `on` posts a macOS desktop notification when the sensor fires. |

`enforce` only blocks inside a GENESIS project (one with `docs/registry/`);
elsewhere it falls back to `advise`. `GENESIS_OFF=1` silences this and every
GENESIS hook entirely.

## 4. Optional: the statusline readout

Only if the user wants the numbers always visible. One statusline can be active
at a time, so this is opt-in and must never clobber an existing one.

1. Resolve this plugin's installed directory and the absolute path to
   `statusline/statusline.sh` (the `statusLine` setting does not expand
   `${CLAUDE_PLUGIN_ROOT}`). Confirm it is executable.
2. If `~/.claude/settings.json` already has a `statusLine`, show it and ask
   before replacing. Otherwise set:

   ```json
   "statusLine": { "type": "command", "command": "/abs/path/to/statusline.sh" }
   ```

3. Restart Claude Code for the statusline to take effect.

## 5. Confirm back

Tell the user, in two lines: the effective cap/mode/notify, and that the sensor
is live now (it re-reads the env on every turn). If you wired the statusline,
remind them to restart.
