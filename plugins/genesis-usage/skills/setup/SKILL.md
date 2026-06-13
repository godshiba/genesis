---
name: setup
description: Configure the GENESIS usage sensor and optionally wire its one-line statusline readout. Use after installing the genesis-usage plugin, or when the user asks to set up usage tracking, the usage sensor, rate-limit warnings, or the usage statusline.
---

# /genesis-usage:setup — Wire the usage sensor

The **sensor itself needs no setup** — installing the plugin auto-registers its
Stop hook, which warns you (or auto-closes) when you near a rate-limit cap.
This skill tunes it and, if wanted, adds the optional statusline readout.

## 1. Confirm prerequisites

The sensor only does anything on **Claude.ai Pro/Max** accounts (Claude Code
**v1.0.80+**), and only **after the first model response** in a session — that
is when Claude Code starts sending `rate_limits` on stdin. For API-key-only
users it stays silent by design. Say so plainly if the user is on API keys.

## 2. Tune the sensor (optional)

It reads these environment variables (sensible defaults shown). Set them in
`~/.claude/settings.json` under `"env"`, or in the shell:

| Variable | Default | Meaning |
|----------|---------|---------|
| `GENESIS_USAGE_MODE` | `advise` | `advise` (warn to stderr), `enforce` (block the stop so Claude runs `/genesis:close`), or `off`. |
| `GENESIS_USAGE_THRESHOLD` | `90` | 5-hour usage %% that triggers a warning. |
| `GENESIS_USAGE_WEEK_THRESHOLD` | `85` | 7-day usage %% that triggers a warning. |
| `GENESIS_USAGE_GRACE_SECS` | `120` | Stay silent if the window resets within this many seconds (it is about to refresh anyway). |

`enforce` only blocks inside a GENESIS project (one with `docs/registry/`) —
elsewhere there is no `/genesis:close` to run, so it falls back to `advise`.

## 3. Add the statusline readout (optional)

Only if the user wants the numbers always visible. The statusline is a single
Claude Code setting and only one can be active, so this is opt-in, never forced.

1. Find this plugin's installed directory (where `statusline/statusline.sh`
   lives — typically under `~/.claude/plugins/`). Resolve it to an absolute path
   (the `statusLine` setting does not expand `${CLAUDE_PLUGIN_ROOT}`).
2. In `~/.claude/settings.json`, set:

   ```json
   "statusLine": {
     "type": "command",
     "command": "/absolute/path/to/genesis-usage/statusline/statusline.sh"
   }
   ```

3. Make sure the script is executable (`chmod +x`). Restart Claude Code.

If the user already has a statusline they like, do not overwrite it — tell them
the sensor works without one, and the statusline is purely a convenience.

## 4. Explain the relationship to GENESIS

The sensor is the trigger half of the G7 emergency close: when it fires in a
GENESIS project it points at `/genesis:close`, which captures mid-task state
before the cutoff. The two are designed to work together but the sensor is
useful on its own — outside GENESIS it just advises you to commit and wrap up.
