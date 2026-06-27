# CLI Build Log — validated against the live org

Org **SnentleyBentley** (`63bdf188-0019-4006-86f0-4a4b26b2ab0c`).
App **Software Factory** (`07c03f78-499d-4324-a1b3-26936e61a831`).
Secret **factory** (`db709a38-...`) keys: `ANTHROPIC_API_KEY`, `GH_PAT`, `RENDER_API_KEY`.

## ✅ Proven end-to-end (2026-06-27, on the floor)
1. CLI v0.26.0 installed, `superplane connect` to Cloud — works.
2. App created via `superplane apps create`.
3. Secret created via `superplane secrets create -f`.
4. Canvas pushed via `superplane apps canvas update -f`.
5. **Webhook trigger → runner with secret-injected env → RESULT_PASSED.**
   The whole credential + execution path works without connecting any integration.

## Validated YAML quirks (the things that errored first)
- Node-level `paused:` is **rejected** by the CLI — omit it (use `isCollapsed` only).
- Secret YAML: `spec.provider: PROVIDER_LOCAL` + `spec.local.data: {KEY: val}`.
- Runner env secret ref shape (the one that bit us):
  ```yaml
  environment:
    - name: ANTHROPIC_API_KEY
      valueSource: secret
      secret: { secret: factory, key: ANTHROPIC_API_KEY }   # secret = the secret NAME
  ```
- Runner `machine_type` uses VALUES not labels: `aws-standard-1` (e1-large-amd64),
  `aws-arm64-1` (e1-large-arm64), `e1-tiny-amd64`, `e1-tiny-arm64`.
- `if` / `filter` / `loop` use `configuration.expression` / `untilExpression` (Expr lang).
- Channels: runner `passed`/`failed`, if `true`/`false`, loop `done`/`next`,
  http `success`/`failure`, filter `default`.
- Update needs `metadata.id` in the file (the app id).

## How we trigger runs (CLI has no run command)
The canvas uses a **Webhook** trigger (auth `none` for now). Trigger a run with:
```sh
curl -X POST "https://app.superplane.com/api/v1/webhooks/<webhook-id>" \
  -H "Content-Type: application/json" -d '{"issueNumber":5368}'
```
Webhook id for the current Intake node: `36fc4625-963c-41d0-8fe2-97e352c9fab2`
(re-read after each push: `superplane apps canvas get <app> -o yaml | grep url`).

## Monitor
```sh
superplane runs list --app-id 07c03f78-499d-4324-a1b3-26936e61a831
superplane executions list --app-id 07c03f78-... --node-id <nodeId>
```

## Integration strategy (decided)
CLI cannot connect GitHub/Render/Slack integrations (UI only). So the pipeline does ALL
external work from **runners** using the `factory` secret — `git`/`gh` with `GH_PAT`,
`claude -p` with `ANTHROPIC_API_KEY`, Render via API with `RENDER_API_KEY`. Zero UI
integration setup required. Native integration nodes can be added later for polish.

See `canvas/probe.validated.yaml` for the working reference canvas.
