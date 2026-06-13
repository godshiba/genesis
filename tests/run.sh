#!/bin/bash
# GENESIS hook test suite. Self-contained: builds throwaway git fixtures in
# mktemp dirs, feeds each hook script the JSON it would receive from the
# harness, and asserts exit codes and output. Run from anywhere:
#   bash tests/run.sh
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS="$ROOT/plugins/genesis/hooks/scripts"
USCRIPTS="$ROOT/plugins/genesis-usage/hooks/scripts"
PASS=0
FAIL=0

# Determinism: clear any GENESIS_* config the host shell may export, so default
# behavior is what we assert unless a test sets a variable explicitly.
unset GENESIS_OFF GENESIS_G1 GENESIS_G2 GENESIS_G3 GENESIS_G2_CONFIG GENESIS_G7 \
      GENESIS_PRECOMPACT GENESIS_RESUME GENESIS_USAGE_MODE GENESIS_USAGE_THRESHOLD \
      GENESIS_USAGE_WEEK_THRESHOLD GENESIS_USAGE_GRACE_SECS GENESIS_USAGE_NOTIFY 2>/dev/null || true

# Isolate hook state: the usage sensor writes per-session throttle files to
# TMPDIR. A throwaway TMPDIR keeps runs repeatable and never touches the host's
# real session state.
export TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

check() { # name expected_exit actual_exit haystack needle
  local name="$1" want="$2" got="$3" out="$4" needle="$5"
  if [ "$got" != "$want" ]; then
    echo "FAIL  $name (exit: want $want, got $got)"
    FAIL=$((FAIL+1)); return
  fi
  if [ -n "$needle" ] && ! printf '%s' "$out" | grep -qF "$needle"; then
    echo "FAIL  $name (output missing: $needle)"
    FAIL=$((FAIL+1)); return
  fi
  echo "ok    $name"
  PASS=$((PASS+1))
}

run() { # script json -> sets OUT and RC (stdout+stderr combined)
  OUT=$(printf '%s' "$2" | "$SCRIPTS/$1" 2>&1); RC=$?
}

urun() { # genesis-usage script json -> sets OUT and RC (stdout+stderr combined)
  OUT=$(printf '%s' "$2" | "$USCRIPTS/$1" 2>&1); RC=$?
}

genesis_fixture() { # creates a GENESIS git repo, echoes its path
  local t; t=$(mktemp -d)
  git -C "$t" init -q -b main
  mkdir -p "$t/docs/registry" "$t/src"
  printf '| Concept | File | Notes |\n| Reg | `src/registered.ts` | x |\n' > "$t/docs/registry/FILES.md"
  printf '# ISSUES\n\n## Open\n\n### ISS-001 - flaky test\nbody\n\n### ISS-002 - slow build\nbody\n\n## Resolved\n\n### ISS-000 - done\n' > "$t/docs/registry/ISSUES.md"
  touch "$t/docs/registry/DECISIONS.md" "$t/docs/registry/LANDMINES.md"
  printf '# SESSION_LOG\n\n## 2026-06-12 - Shipped phase 2\n\n- Built auth in src/auth.ts\n- Next: token refresh, phase 3 task 1.\n\n## 2026-06-10 - older\n- old\n' > "$t/docs/registry/SESSION_LOG.md"
  printf '# ROADMAP\n- [x] done\n- [ ] implement token refresh\n- [ ] later\n' > "$t/docs/registry/ROADMAP.md"
  git -C "$t" add -A
  git -C "$t" -c user.email=t@t -c user.name=t commit -qm init
  echo "$t"
}

echo "== g7-session-guard =="
T=$(genesis_fixture)
echo change > "$T/src/new.txt"
run g7-session-guard.sh "{\"cwd\":\"$T\",\"stop_hook_active\":false}"
check "G7 blocks dirty tree without log entry" 2 $RC "$OUT" "G7 session gate"
run g7-session-guard.sh "{\"cwd\":\"$T\",\"stop_hook_active\":true}"
check "G7 allows when stop_hook_active (loop guard)" 0 $RC "$OUT" ""
echo entry >> "$T/docs/registry/SESSION_LOG.md"
run g7-session-guard.sh "{\"cwd\":\"$T\",\"stop_hook_active\":false}"
check "G7 allows when log also dirty" 0 $RC "$OUT" ""
run g7-session-guard.sh '{"cwd":"/tmp","stop_hook_active":false}'
check "G7 silent outside GENESIS" 0 $RC "$OUT" ""
rm -rf "$T"
T=$(genesis_fixture)
run g7-session-guard.sh "{\"cwd\":\"$T\",\"stop_hook_active\":false}"
check "G7 allows clean tree" 0 $RC "$OUT" ""
rm -rf "$T"

echo "== g1-registration-nudge =="
T=$(genesis_fixture)
run g1-registration-nudge.sh "{\"cwd\":\"$T\",\"tool_input\":{\"file_path\":\"$T/src/new-thing.ts\"}}"
check "G1 nudges unregistered new file" 2 $RC "$OUT" "G1 registration gate"
run g1-registration-nudge.sh "{\"cwd\":\"$T\",\"tool_input\":{\"file_path\":\"$T/src/registered.ts\"}}"
check "G1 silent for registered file" 0 $RC "$OUT" ""
echo x > "$T/src/tracked.ts" && git -C "$T" add . && git -C "$T" -c user.email=t@t -c user.name=t commit -qm add
run g1-registration-nudge.sh "{\"cwd\":\"$T\",\"tool_input\":{\"file_path\":\"$T/src/tracked.ts\"}}"
check "G1 silent for tracked-file overwrite" 0 $RC "$OUT" ""
run g1-registration-nudge.sh "{\"cwd\":\"$T\",\"tool_input\":{\"file_path\":\"$T/docs/registry/ISSUES.md\"}}"
check "G1 silent inside docs/registry" 0 $RC "$OUT" ""
run g1-registration-nudge.sh '{"cwd":"/tmp","tool_input":{"file_path":"/tmp/foo.ts"}}'
check "G1 silent outside GENESIS" 0 $RC "$OUT" ""
rm -rf "$T"

echo "== g3-todo-nudge =="
T=$(genesis_fixture)
run g3-todo-nudge.sh "{\"cwd\":\"$T\",\"tool_input\":{\"file_path\":\"$T/src/a.ts\",\"content\":\"// TODO: handle timeout\"}}"
check "G3 nudges orphan TODO in Write" 2 $RC "$OUT" "G3 issue gate"
run g3-todo-nudge.sh "{\"cwd\":\"$T\",\"tool_input\":{\"file_path\":\"$T/src/a.ts\",\"content\":\"// TODO(ISS-004): handle timeout\"}}"
check "G3 silent when TODO cites ISS id" 0 $RC "$OUT" ""
run g3-todo-nudge.sh "{\"cwd\":\"$T\",\"tool_input\":{\"file_path\":\"$T/src/a.ts\",\"new_string\":\"// FIXME later\"}}"
check "G3 nudges FIXME in Edit new_string" 2 $RC "$OUT" "G3 issue gate"
run g3-todo-nudge.sh '{"cwd":"/tmp","tool_input":{"file_path":"/tmp/a.ts","content":"// TODO: x"}}'
check "G3 silent outside GENESIS" 0 $RC "$OUT" ""
rm -rf "$T"

echo "== g2-commit-reminder =="
T=$(genesis_fixture)
run g2-commit-reminder.sh "{\"cwd\":\"$T\",\"tool_input\":{\"command\":\"git add -A && git commit -m x\"}}"
check "G2 injects context before git commit" 0 $RC "$OUT" "additionalContext"
run g2-commit-reminder.sh "{\"cwd\":\"$T\",\"tool_input\":{\"command\":\"ls -la\"}}"
check "G2 silent for ordinary bash" 0 $RC "$OUT" ""
[ -z "$OUT" ] || { echo "FAIL  G2 ordinary bash should print nothing"; FAIL=$((FAIL+1)); PASS=$((PASS-1)); }
run g2-commit-reminder.sh '{"cwd":"/tmp","tool_input":{"command":"git commit -m x"}}'
check "G2 silent outside GENESIS" 0 $RC "$OUT" ""
rm -rf "$T"

echo "== g7-session-resume =="
T=$(genesis_fixture)
run g7-session-resume.sh "{\"cwd\":\"$T\",\"hook_event_name\":\"SessionStart\"}"
check "resume injects last handoff" 0 $RC "$OUT" "Shipped phase 2"
check "resume injects next roadmap task" 0 $RC "$OUT" "implement token refresh"
check "resume counts open issues only" 0 $RC "$OUT" "Open issues: 2"
run g7-session-resume.sh '{"cwd":"/tmp"}'
check "resume silent outside GENESIS" 0 $RC "$OUT" ""
rm -rf "$T"

echo "== g2-config-guard =="
T=$(genesis_fixture)
run g2-config-guard.sh "{\"cwd\":\"$T\",\"tool_input\":{\"file_path\":\"$T/vitest.config.ts\"}}"
check "config guard nudges test config edit" 2 $RC "$OUT" "G2 validation gate"
run g2-config-guard.sh "{\"cwd\":\"$T\",\"tool_input\":{\"file_path\":\"$T/.eslintrc.json\"}}"
check "config guard nudges lint config edit" 2 $RC "$OUT" "G2 validation gate"
run g2-config-guard.sh "{\"cwd\":\"$T\",\"tool_input\":{\"file_path\":\"$T/tsconfig.json\"}}"
check "config guard excludes compiler config" 0 $RC "$OUT" ""
run g2-config-guard.sh "{\"cwd\":\"$T\",\"tool_input\":{\"file_path\":\"$T/src/app.ts\"}}"
check "config guard silent for source files" 0 $RC "$OUT" ""
run g2-config-guard.sh '{"cwd":"/tmp","tool_input":{"file_path":"/tmp/.eslintrc.json"}}'
check "config guard silent outside GENESIS" 0 $RC "$OUT" ""
rm -rf "$T"

echo "== g7-precompact-snapshot =="
T=$(genesis_fixture)
echo wip > "$T/src/wip.txt"
run g7-precompact-snapshot.sh "{\"cwd\":\"$T\",\"trigger\":\"auto\"}"
check "precompact exits silently" 0 $RC "$OUT" ""
SNAP="$T/docs/registry/.session-snapshot.md"
if [ -f "$SNAP" ] && grep -q "Pre-compaction snapshot" "$SNAP" && grep -q "src/wip.txt" "$SNAP"; then
  echo "ok    precompact writes snapshot with dirty files"; PASS=$((PASS+1))
else
  echo "FAIL  precompact snapshot missing or incomplete"; FAIL=$((FAIL+1))
fi
run g7-precompact-snapshot.sh '{"cwd":"/tmp","trigger":"auto"}'
check "precompact silent outside GENESIS" 0 $RC "$OUT" ""
rm -rf "$T"
# resume loader surfaces the snapshot when present (mid-task safety net)
T=$(genesis_fixture)
printf '# Pre-compaction snapshot\n\n- Branch: main\n- HEAD: abc123 wip\n' > "$T/docs/registry/.session-snapshot.md"
run g7-session-resume.sh "{\"cwd\":\"$T\",\"hook_event_name\":\"SessionStart\"}"
check "resume surfaces pre-compaction snapshot" 0 $RC "$OUT" "Pre-compaction snapshot present"
rm -rf "$T"

echo "== usage-sensor (genesis-usage) =="
FAR=$(( $(date +%s) + 3600 ))   # realistic reset ~1h out, beyond the grace window
T=$(genesis_fixture)
urun usage-sensor.sh "{\"cwd\":\"$T\",\"session_id\":\"s-below\",\"rate_limits\":{\"five_hour\":{\"used_percentage\":40,\"resets_at\":$FAR}}}"
check "usage sensor silent below threshold" 0 $RC "$OUT" ""
[ -z "$OUT" ] || { echo "FAIL  usage sensor should be silent below threshold"; FAIL=$((FAIL+1)); PASS=$((PASS-1)); }
urun usage-sensor.sh "{\"cwd\":\"$T\",\"session_id\":\"s-adv\",\"rate_limits\":{\"five_hour\":{\"used_percentage\":95,\"resets_at\":$FAR}}}"
check "usage sensor advises near 5h cap (recommends /genesis:close)" 0 $RC "$OUT" "/genesis:close"
urun usage-sensor.sh "{\"cwd\":\"$T\",\"session_id\":\"s-adv\",\"rate_limits\":{\"five_hour\":{\"used_percentage\":95,\"resets_at\":$FAR}}}"
check "usage sensor throttles repeat in same bucket" 0 $RC "$OUT" ""
[ -z "$OUT" ] || { echo "FAIL  usage sensor should throttle repeat in same bucket"; FAIL=$((FAIL+1)); PASS=$((PASS-1)); }
OUT=$(printf '%s' "{\"cwd\":\"$T\",\"session_id\":\"s-enf\",\"rate_limits\":{\"five_hour\":{\"used_percentage\":96,\"resets_at\":$FAR}}}" | GENESIS_USAGE_MODE=enforce "$USCRIPTS/usage-sensor.sh" 2>&1); RC=$?
check "usage sensor enforce blocks the stop" 2 $RC "$OUT" "/genesis:close"
OUT=$(printf '%s' "{\"cwd\":\"$T\",\"session_id\":\"s-enf2\",\"stop_hook_active\":true,\"rate_limits\":{\"five_hour\":{\"used_percentage\":96,\"resets_at\":$FAR}}}" | GENESIS_USAGE_MODE=enforce "$USCRIPTS/usage-sensor.sh" 2>&1); RC=$?
check "usage sensor enforce respects stop loop guard" 0 $RC "$OUT" ""
urun usage-sensor.sh "{\"cwd\":\"$T\",\"session_id\":\"s-nodata\"}"
check "usage sensor silent without rate_limits (API users)" 0 $RC "$OUT" ""
rm -rf "$T"
P=$(mktemp -d)
urun usage-sensor.sh "{\"cwd\":\"$P\",\"session_id\":\"s-plain\",\"rate_limits\":{\"five_hour\":{\"used_percentage\":97,\"resets_at\":$FAR}}}"
check "usage sensor advises generically outside GENESIS" 0 $RC "$OUT" "wrap up"
rm -rf "$P"

echo "== gate config (modes + kill switch) =="
T=$(genesis_fixture); echo change > "$T/src/new.txt"
OUT=$(printf '%s' "{\"cwd\":\"$T\",\"stop_hook_active\":false}" | GENESIS_G7=warn "$SCRIPTS/g7-session-guard.sh" 2>&1); RC=$?
check "G7 warn advises without blocking (exit 0)" 0 $RC "$OUT" "G7 session gate"
OUT=$(printf '%s' "{\"cwd\":\"$T\",\"stop_hook_active\":false}" | GENESIS_G7=off "$SCRIPTS/g7-session-guard.sh" 2>&1); RC=$?
check "G7 off is silent" 0 $RC "$OUT" ""
[ -z "$OUT" ] || { echo "FAIL  G7 off should print nothing"; FAIL=$((FAIL+1)); PASS=$((PASS-1)); }
OUT=$(printf '%s' "{\"cwd\":\"$T\",\"stop_hook_active\":false}" | GENESIS_OFF=1 "$SCRIPTS/g7-session-guard.sh" 2>&1); RC=$?
check "GENESIS_OFF kill switch silences G7" 0 $RC "$OUT" ""
[ -z "$OUT" ] || { echo "FAIL  GENESIS_OFF should silence G7"; FAIL=$((FAIL+1)); PASS=$((PASS-1)); }
rm -rf "$T"
T=$(genesis_fixture)
OUT=$(printf '%s' "{\"cwd\":\"$T\",\"tool_input\":{\"file_path\":\"$T/src/new-thing.ts\"}}" | GENESIS_G1=warn "$SCRIPTS/g1-registration-nudge.sh" 2>&1); RC=$?
check "G1 warn advises without exit 2" 0 $RC "$OUT" "G1 registration gate"
rm -rf "$T"
# Stub osascript on PATH so the notify path is exercised WITHOUT firing a real
# desktop notification on the host running the tests.
mkdir -p "$TMPDIR/fakebin"; printf '#!/bin/sh\nexit 0\n' > "$TMPDIR/fakebin/osascript"; chmod +x "$TMPDIR/fakebin/osascript"
T=$(genesis_fixture)
OUT=$(printf '%s' "{\"cwd\":\"$T\",\"session_id\":\"s-notify\",\"rate_limits\":{\"five_hour\":{\"used_percentage\":97,\"resets_at\":$FAR}}}" | PATH="$TMPDIR/fakebin:$PATH" GENESIS_USAGE_NOTIFY=on "$USCRIPTS/usage-sensor.sh" 2>&1); RC=$?
check "usage sensor advises cleanly with NOTIFY=on (stubbed, no real notification)" 0 $RC "$OUT" "/genesis:close"
rm -rf "$T"

echo "== statusline (genesis-usage) =="
SL="$ROOT/plugins/genesis-usage/statusline/statusline.sh"
NOWT=$(date +%s)
OUT=$(printf '%s' "{\"model\":{\"display_name\":\"Opus\"},\"context_window\":{\"used_percentage\":3},\"rate_limits\":{\"five_hour\":{\"used_percentage\":69,\"resets_at\":$(( NOWT + 8040 ))}}}" | bash "$SL" 2>&1); RC=$?
check "statusline shows 5h usage" 0 $RC "$OUT" "5h 69%"
check "statusline shows reset countdown" 0 $RC "$OUT" "(2h"
OUT=$(printf '%s' "{\"model\":{\"display_name\":\"Opus\"},\"rate_limits\":{\"five_hour\":{\"used_percentage\":69,\"resets_at\":9999999999}}}" | bash "$SL" 2>&1); RC=$?
check "statusline omits absurd reset countdown" 0 $RC "$OUT" "5h 69%"
printf '%s' "$OUT" | grep -q '(' && { echo "FAIL  statusline should omit absurd countdown"; FAIL=$((FAIL+1)); } || true

echo
echo "passed: $PASS  failed: $FAIL"
[ "$FAIL" -eq 0 ]
