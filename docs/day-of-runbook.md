# Day-of Runbook — June 27 (solo, ~6 build hours)

Agenda: build window **11:15–17:00** (lunch 13:00–13:30), **submit 17:00**, demo 17:15.
Goal: be **submission-safe at every checkpoint** — build the spine first, layer upside after.

## T-0 (before 11:15): setup, while intro talks happen

Fill `.env` from `.env.example`. Order matters:

- [ ] SuperPlane Cloud account → create org → **record org name** (the form needs it)
- [ ] SuperPlane service-account token → `SUPERPLANE_TOKEN`
- [ ] `superplane connect $SUPERPLANE_URL $SUPERPLANE_TOKEN` → `superplane whoami` works
- [ ] Fork `superplanehq/superplane` → `GITHUB_FORK_URL`, `GITHUB_REPO`
- [ ] Install `superplane-app` GitHub App on the fork
- [ ] Fine-grained GitHub PAT (Contents+PR on fork) → `GH_PAT`
- [ ] Anthropic API key → `ANTHROPIC_API_KEY`
- [ ] Render account (login w/ GitHub) + API key → `RENDER_API_KEY`
- [ ] Connect GitHub integration, Anthropic, Render inside SuperPlane (UI — CLI can't)

## Build phases (each ends in a working, demoable state)

### Phase 1 — THE SPINE (11:15–13:00) — *must finish; this alone is compliant*
1. Create the app in SuperPlane Cloud; note the app id into `canvas/canvas.yaml` metadata.id
2. Build in the UI (more reliable than hand-YAML): **Manual Run → Spec (Claude) → If →
   Run Shell (implement) → Run Shell (build/test) → GitHub Create PR**
3. Get the **implement runner** green on #5368: clone fork, `claude -p`, push branch
   (use `runners/02-implement.sh` as the node's commands)
4. Get the **verify runner** green: `cd web_src && npm run build && npm run test:run`
5. GitHub Create PR node opens a PR on the pushed branch
- ✅ **GO/NO-GO:** a `/manual run` on #5368 produces a real PR. If yes, you are submittable.

### Phase 2 — PROOF + SELF-HEAL (13:30–15:00) — *the differentiators*
6. Deploy the Render Blueprint (`services/render.yaml`) → get `factory-verifier` +
   `factory-preview` URLs into `.env` / SuperPlane secrets
7. Add **Deploy Preview** runner (`04-deploy-preview.sh`) → live URL
8. Add **Prove** HTTP node → `factory-verifier/verify?url=...` → screenshot evidence
9. Add **Comment** node: post preview link + screenshot on the PR
10. Wrap Implement→Verify in a **`loop`** node (maxIterations 3, until exit_code==0)
- ✅ **GO/NO-GO:** PR now has a clickable preview + a proof screenshot.

### Phase 3 — POLISH (15:15–16:15)
11. Console dashboard: Table widget over a `runs` memory namespace (auto-built count,
    EASY/COMPLEX ratio, build funnel)
12. Add intake via `ingest-gateway` (form/`/solve` comment) replacing Manual Run
13. Classification node + Slack approve gate (optional)

### Phase 4 — DEMO PREP (16:15–17:00)
14. Run the full pipeline once on #5368 → **save PR + preview URL** (pre-bake)
15. Screen-record a full green run; screenshot Canvas/PR/preview
16. Rehearse the [demo script](demo-script.md) twice, < 3:00
17. **Submit at 17:00.**

## If you fall behind — cut in this order
1. Drop Slack approval (demo the approval in SuperPlane's UI)
2. Drop classification (go straight issue → spec)
3. Drop the Console dashboard (show the Canvas instead)
4. Drop the `loop` self-heal (single-shot build; still compliant)
Never drop: the PR with a working preview link. That's requirement #4 — non-negotiable.

## Known traps (from research)
- Render previews need Pro → we redeploy ONE free static site (`04-deploy-preview.sh`)
- Runner needs its OWN `GH_PAT` to push (the GitHub App only opens the PR)
- Runner needs `ANTHROPIC_API_KEY` for `claude -p`
- `claude`/`gh` aren't preinstalled on runners → install in setup commands
- SuperPlane CLI can't trigger runs → use Manual Run / Webhook nodes
- Cloud beta: 14-day retention, 500k events/month (plenty)
