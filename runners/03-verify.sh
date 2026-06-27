#!/usr/bin/env bash
# Runner node: "Verify Build" (last step inside the self-heal loop)
# Builds, tests, and lints the change. Exit 0 => loop's untilExpression passes => Done.
# Non-zero => loop runs another Implement iteration with FAILLOG fed back in.
set -uo pipefail
WORK="$(pwd)/workspace/repo"
cd "$WORK/web_src"

LOG="$(pwd)/../verify.log"; : > "$LOG"
status=0

echo "== build ==" | tee -a "$LOG"
npm run build           >>"$LOG" 2>&1 || status=1
echo "== test ==" | tee -a "$LOG"
npm run test:run        >>"$LOG" 2>&1 || status=1
echo "== lint ==" | tee -a "$LOG"
npm run lint:budget     >>"$LOG" 2>&1 || true   # lint is advisory, not a hard gate

# Surface the tail of the log so the next loop iteration can self-heal.
TAIL="$(tail -c 4000 "$LOG" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
echo "{\"exit_code\":$status,\"faillog\":$TAIL}" > "$SUPERPLANE_RESULT_FILE"
exit $status
