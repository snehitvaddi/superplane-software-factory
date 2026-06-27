#!/usr/bin/env bash
# Runner node: "Implement"
# Clones the fork, creates a branch, runs Claude Code headless to implement the issue,
# commits and pushes. Branch must exist before the github.createPullRequest node runs.
#
# Env vars (set on the runner node; back them with SuperPlane secrets):
#   ANTHROPIC_API_KEY, GH_PAT, GITHUB_REPO (owner/superplane), CLAUDE_MODEL,
#   ISSUE_NUMBER, ISSUE_BODY, SPEC_JSON  (passed from upstream nodes via expressions)
set -euo pipefail

: "${ANTHROPIC_API_KEY:?}"; : "${GH_PAT:?}"; : "${GITHUB_REPO:?}"; : "${ISSUE_NUMBER:?}"
MODEL="${CLAUDE_MODEL:-claude-opus-4-8}"
BRANCH="factory/issue-${ISSUE_NUMBER}"
WORK="$(pwd)/workspace"

# --- setup: install Claude Code CLI if not present (runner is Node 22 / Ubuntu) ---
command -v claude >/dev/null 2>&1 || npm install -g @anthropic-ai/claude-code

# --- clone (idempotent across loop iterations) ---
if [ ! -d "$WORK/repo/.git" ]; then
  rm -rf "$WORK"; mkdir -p "$WORK"
  git clone --depth 1 "https://x-access-token:${GH_PAT}@github.com/${GITHUB_REPO}.git" "$WORK/repo"
fi
cd "$WORK/repo"
git config user.name  "superplane-factory"
git config user.email "factory@superplane.local"
git checkout -B "$BRANCH"

# --- install frontend deps (the 5 validation issues are all web_src) ---
( cd web_src && npm ci --no-audit --no-fund )

# --- implement headlessly. On retry, FAILLOG carries prior errors back in. ---
PROMPT="Implement GitHub issue #${ISSUE_NUMBER} in this repo.
Spec:
${SPEC_JSON:-see issue body}

Issue:
${ISSUE_BODY:-}

Follow web_src/AGENTS.md. Edit code AND tests. Keep edit mode raw.
${FAILLOG:+Previous validation FAILED with:\n$FAILLOG\nFix these specifically.}"

claude -p "$PROMPT" \
  --model "$MODEL" \
  --permission-mode acceptEdits \
  --allowedTools "Read,Edit,Write,Bash" \
  --output-format json > "$WORK/claude-result.json" || true

# --- commit + push so the PR node has a branch ---
git add -A
git commit -m "factory: implement #${ISSUE_NUMBER}" || echo "no changes to commit"
git push -f "https://x-access-token:${GH_PAT}@github.com/${GITHUB_REPO}.git" "$BRANCH"

echo "{\"branch\":\"$BRANCH\",\"issue\":${ISSUE_NUMBER}}" > "$SUPERPLANE_RESULT_FILE"
