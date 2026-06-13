# Changelog — genesis-usage

## 0.3.1 — 2026-06-13

Fixed:

- `/genesis-usage:setup` now treats the **weekly (7-day) cap as a first-class
  prompt** and writes both caps explicitly. Previously it framed the weekly cap
  as optional and left it at the default 85 without showing it, so it looked
  "silently set". A second argument sets it directly too:
  `/genesis-usage:setup 80 75`.

## 0.3.0 — 2026-06-13

Added:

- **Reset countdown in the statusline.** Each usage figure now shows when that
  window refreshes — `5h 69% (2h14m)  7d 10% (3d4h)` — dimmed, so you can see at
  a glance how long until the limit clears, not just how much is used. Omitted
  for implausible reset times (same >8d clamp as the sensor).

## 0.2.1 — 2026-06-13

Fixed:

- Reset countdown now shows "reset time unknown" for implausible `resets_at`
  values (beyond ~8 days) instead of an absurd multi-million-hour countdown.
- Test suite stubs `osascript` so the notification path is exercised without
  firing a real desktop notification on the machine running the tests.

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
