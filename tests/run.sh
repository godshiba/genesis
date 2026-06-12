#!/bin/bash
# GENESIS hook test suite. Self-contained: builds throwaway git fixtures in
# mktemp dirs, feeds each hook script the JSON it would receive from the
# harness, and asserts exit codes and output. Run from anywhere:
#   bash tests/run.sh
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS="$ROOT/plugins/genesis/hooks/scripts"
PASS=0
FAIL=0

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

echo
echo "passed: $PASS  failed: $FAIL"
[ "$FAIL" -eq 0 ]
