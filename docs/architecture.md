# Architecture

The factory is a **SuperPlane Canvas**. Everything below maps to a verified SuperPlane
primitive (confirmed against docs.superplane.com).

## Layer split (the base44 guardrail)

| Layer | Where | Why |
|-------|-------|-----|
| Orchestration, gates, retry loop, LLM calls | **SuperPlane Canvas** | the deliverable; on-platform |
| Code generation (`claude -p`), build/test | **SuperPlane runner** | on-platform compute |
| Always-on intake listener | **Render** `ingest-gateway` | needs public always-on endpoint |
| Visual proof (Playwright) | **Render** `factory-verifier` | persistent browser service |
| Telemetry | **Render** `factory-postgres` | durable cross-run storage |
| Per-run preview target | **Render** `factory-preview` (static) | instant, no spin-down |

## Verified primitive mapping

| Stage | Component | Key |
|-------|-----------|-----|
| Intake | Webhook trigger | `webhook` (header-token auth, ≤64KB) |
| Classify / Spec | Claude Text Prompt | `claude` → `data.text` |
| Gates | If / Filter | `if` (True/False), `filter` |
| Human gate | Slack Wait for Button Click | `slack` (Received/Timeout) — NOT the UI-only Approval node |
| Code-gen / build | Run Shell Commands | `runner` → `$SUPERPLANE_RESULT_FILE` |
| Self-heal | Loop | `loop` (untilExpression, maxIterations) — cycles only via this node |
| Deploy / PR | Render + GitHub | `render.deploy` / `github.createPullRequest`, `createIssueComment` |
| Dashboard | Console + Memory | Table/Number widgets over a memory namespace |

## Key constraints learned in research

- Render PR **Preview Environments require Pro** → we redeploy one free static site per run.
- GitHub connects as the **`superplane-app` GitHub App**, but the runner needs a separate
  **PAT** to `git push`.
- `claude -p` on the runner needs **`ANTHROPIC_API_KEY`** (Cloud's built-in agent doesn't
  cover the runner CLI).
- CLI **cannot** trigger runs or connect integrations — those are webhook/UI. CLI IS the
  way to ship the canvas (`apps canvas update -f`).
- Cloud beta limits: 14-day run retention, 500k events/org/month.

## Source-of-truth prep docs

Detailed issue analysis and demo script live in `../superplane-hackathon-prep/`:
- `issue-validation-matrix.md` — file lists + acceptance criteria for all 5 issues
- `factory-canvas-design.md` — node-by-node design
- `software-factory-demo-script.md` — the 3-minute demo
