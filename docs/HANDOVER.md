# 🤝 HANDOVER — SuperPlane Software Factory (resume in a new chat)

Paste this file's path to a new session and say "continue from HANDOVER.md".
Last updated: 2026-06-27, mid-build (hackathon day).

## What this is
A SuperPlane app that turns a GitHub issue → spec → code (Claude Code) → build/test →
Render preview → PR → human approve → merge. The **deliverable is the SuperPlane Canvas**
(`canvas/canvas.yaml`). Built for the "Bash Script Funeral" hackathon. Solo dev: snehitvaddi.

## 🔑 Live IDs (all real, on the user's accounts)
- SuperPlane org: **SnentleyBentley** `63bdf188-0019-4006-86f0-4a4b26b2ab0c`
- App: **Software Factory** `07c03f78-499d-4324-a1b3-26936e61a831`
  - URL: https://app.superplane.com/63bdf188-0019-4006-86f0-4a4b26b2ab0c/apps/07c03f78-499d-4324-a1b3-26936e61a831
- Secret: **factory** `db709a38-f57f-478f-9bfa-9b0f5d36614c` — keys: ANTHROPIC_API_KEY,
  GH_PAT, RENDER_API_KEY, SLACK_WEBHOOK_URL, RENDER_PREVIEW_SERVICE_ID, PREVIEW_URL, VERIFIER_URL
- GitHub fork (code/PR target): **snehitvaddi/superplane** (issues fetched from upstream **superplanehq/superplane**)
- Render services: **factory-verifier** `srv-d900ng0k1i2s73f8dneg` (https://factory-verifier.onrender.com),
  **factory-preview** `srv-d900nnf7f7vs739m5ui0` (https://factory-preview.onrender.com)
- Render owner: `tea-d5pa0dp4tr6s73aneoi0`
- Webhook trigger: read fresh each push: `superplane apps canvas get <APP> -o yaml | grep url`
- ⚠️ User said they will **rotate all keys** — re-auth-check before relying on them.

## CLI setup (do first in new session)
```sh
export PATH="$HOME/.local/bin:$PATH"           # superplane CLI v0.26.0 installed here
superplane whoami                               # should print SnentleyBentley
# if not connected: superplane connect https://app.superplane.com <SUPERPLANE_TOKEN>
APP=07c03f78-499d-4324-a1b3-26936e61a831
```

## How to push the canvas / trigger / monitor
```sh
# push canvas (NOTE: live canvas currently has gate-complex bypassed for testing — see below)
superplane apps canvas update -f canvas/canvas.yaml --auto-layout horizontal
# trigger a run
WURL=$(superplane apps canvas get $APP -o yaml | grep -i 'url:.*webhooks' | head -1 | awk '{print $2}')
curl -s -X POST "$WURL" -H "Content-Type: application/json" -d '{"issueNumber":5368}'
# monitor a node (latest execution + diagnostics)
superplane executions list --app-id $APP --node-id build -o json | python3 -c 'import json,sys;es=json.load(sys.stdin)["executions"];es.sort(key=lambda x:x["createdAt"],reverse=True);print(json.dumps(es[0].get("outputs",{}))[:600])'
```

## ✅ Proven working (live runs)
- Webhook intake, Classify (real issue→type/complexity), gates, Spec Agent (10 acceptance
  criteria), Spec gate. The full left side of the pipeline works.
- Credentials all auth-verified (Anthropic, GitHub PAT, Render, Slack webhook).
- 2 Render services created and building.

## 🔴 CURRENT BLOCKER (start here)
**The `Build` node finishes in ~35s with PASSED but writes NO output and pushes NO branch.**
Claude Code / clone is failing early. **The API does NOT expose runner stdout logs — they
only render in the SuperPlane UI.** So:
→ **Open the app in the UI, click the `Build` node → latest execution → Logs tab**, read what
  actually fails (likely: git clone of a big repo, `npm install -g @anthropic-ai/claude-code`,
  or `claude -p` auth/runtime). Then fix `canvas/canvas.yaml` Build node accordingly.
- Hypotheses to check: clone timeout/size; claude CLI install on the runner; whether `claude -p`
  needs extra flags (`--dangerously-skip-permissions` in sandbox); result-file write path.
- Build node is `aws-standard-1`, timeout 2400s. It clones snehitvaddi/superplane, installs
  claude-code, runs `claude -p`, builds+tests web_src, pushes branch `factory/issue-5368`.

## ⬜ Still to build (priority order)
1. **Fix the Build node** (above) → real branch + PR. Everything downstream is wired & waiting.
2. **Restore approval gate**: live canvas has gate-complex expression replaced with `false`
   (bypass) for testing. Repo `canvas/canvas.yaml` has the REAL expression. Push repo version
   to restore. (Or keep bypass until Build works.)
3. **Two-way Slack** (user wants interactive approve/reject IN Slack): replace the two core
   `approval` nodes (Authorize Build, Merge to Prod) with **`slack.waitForButtonClick`**
   (channels: Received/Timeout). REQUIRES connecting the native Slack integration in the UI
   (Bot Token + Signing Secret) — CLI can't connect integrations. Then set node `integration.id`
   from `superplane integrations list`.
4. **Failure handling**: the 8 false/failure branches currently dead-end. Add a shared
   "Notify Failure" runner (curl Slack webhook + upsertMemory status) + a build-loop
   "exhausted?" check. (Self-heal loop already exists via the `loop` node, max 3.)
5. **Console dashboard**: build `console.yaml` (via `superplane apps console set/get`) with a
   Table widget over Memory namespace `factoryRuns` + KPI numbers (auto-built count,
   EASY/COMPLEX ratio). Telemetry node already writes there.
6. **Demo prep**: pre-bake one clean run, screen-record, rehearse 3-min script.

## ⚠️ Hard-won gotchas (don't re-learn these)
- Runners are **ephemeral** — each node = fresh machine, NO shared filesystem. That's why
  Implement+Verify are merged into one `Build` node.
- Runner result path downstream: **`$['Node'].data.result.<key>`** (NOT `.data.<key>`).
- Webhook body path: **`root().data.body.<field>`** (NOT `root().data.<field>`).
- **`gh` is NOT installed on runners** → use GitHub REST API via `curl`.
- Secret ref in runner env: `secret: { secret: <name>, key: <key> }` (the inner `secret` = name).
- Node YAML rejects `paused:`; use `isCollapsed` only. Secret YAML provider = `PROVIDER_LOCAL`,
  data under `spec.local.data`, needs `metadata.id` to update.
- `if` channels: `true`/`false`; runner: `passed`/`failed`; loop: `next`/`done`; approval: `approved`/`rejected`.
- CLI canNOT: connect integrations, trigger runs (use webhook), or read runner logs (UI only).
- Cancel stuck loop executions or they block new runs:
  `superplane executions cancel --app-id $APP --execution-id <eid>`

## DB question (answered)
**No external DB needed.** SuperPlane **Memory** (built-in, app-scoped JSON) handles run
telemetry/state via the `upsertMemory` node (namespace `factoryRuns`). The Console reads it.
No Postgres. The Render track is satisfied by the 2 services above (no DB required).

## Files
- `canvas/canvas.yaml` — THE deliverable (the factory). 16 nodes.
- `docs/cli-build-log.md` — validated CLI/YAML formats.
- `docs/architecture.md`, `docs/demo-script.md`, `docs/day-of-runbook.md`.
- `prompts/` — classify/spec/implement prompts.
- `services/` — Render service source (verifier = Playwright, ingest-gateway).
- File memory: `~/.claude/projects/-Users-vsneh-Downloads-Drive-D-Hackathins/memory/`
  (superplane-hackathon.md, superplane-platform-facts.md). Mem0 user_id "snehit".
