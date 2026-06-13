# Changelog — genesis-usage

## 0.2.0 — 2026-06-13

Tunability and reach.

Added:

- **Interactive `/genesis-usage:setup`.** Asks for the cap (5h/7d), mode, and
  notifications, then writes them into `settings.json` — no hand-editing JSON or
  memorizing env vars. `/genesis-usage:setup 80` sets the 5-hour cap directly.
- **Desktop notifications.** `GENESIS_USAGE_NOTIFY=on` posts a macOS notification
  when the sensor fires — an at-a-glance alert when you are working in another
  app, without a menu-bar app. Skipped silently where unsupported.
- Honors the global `GENESIS_OFF=1` kill switch.

Changed:

- README rewritten dual-audience (newcomer quickstart + full config reference +
  troubleshooting).

## 0.1.0 — 2026-06-13

Initial release. The trigger half of the GENESIS G7 emergency close.

Added:

- **Usage sensor (Stop hook).** Reads Claude Code's subscriber `rate_limits`
  (5-hour and 7-day windows) on stdin and acts when usage crosses a threshold
  with a reset still far enough out to risk a cutoff. `advise` mode (default)
  warns to stderr; `enforce` mode blocks the stop so Claude runs
  `/genesis:close`. Throttled to once per rising 5-point usage bucket per
  session. Fails open for API-key users (no `rate_limits` on stdin).
- **Optional statusline.** A lean one-line readout (model, context %, 5h/7d
  usage %, git branch) with color thresholds. Opt-in via `/genesis-usage:setup`
  — never overrides an existing statusline. Not a HUD by design.
- **`/genesis-usage:setup` skill.** Tunes the sensor (mode, thresholds, grace)
  and optionally wires the statusline.
- Covered by the repo hook test suite (7 sensor scenarios).
