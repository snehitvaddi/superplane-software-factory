# SuperPlane Software Factory

> Give SuperPlane a rough GitHub issue and it specs, implements, validates, self-heals,
> opens a PR, deploys a Render preview, and comments back with a live, testable link —
> with **minimal human involvement**.

Built for the **SuperPlane Hackathon: Bash Script Funeral /w Render** (NYC, June 27, 2026).
Theme: **Build Your Own Software Factory.**

## The one rule (the base44 lesson)

**The deliverable IS the SuperPlane Canvas.** The orchestration, gates, retry loop, and LLM
calls all live on-platform as canvas nodes. Render hosts only *supporting* services. If you
deleted SuperPlane, almost nothing here would survive — that's the point.

> Test to apply all day: *"If I deleted SuperPlane, how much of my project survives?"*
> Answer must stay: *"Almost nothing — the pipeline IS the canvas."*

## What's in this repo

| Path | What it is | Runs where |
|------|------------|------------|
| [`canvas/canvas.yaml`](canvas/canvas.yaml) | **The deliverable** — the factory as canvas-as-code | SuperPlane Cloud |
| [`runners/`](runners/) | Shell scripts the SuperPlane runner nodes execute | SuperPlane runner |
| [`prompts/`](prompts/) | The Claude prompts for classify / spec / implement | SuperPlane LLM nodes + runner |
| [`services/`](services/) | The ≥2 Render services (ingest gateway, Playwright verifier) | Render |
| [`docs/architecture.md`](docs/architecture.md) | The full pipeline + decisions | — |

## Pipeline (each stage validates the previous one)

```
idea (/solve #5368 or web form)
  → Webhook trigger
  → Classify  (BUG | FEATURE | DISCARD) + (EASY | COMPLEX)
  → [if] DISCARD? drop   [if] COMPLEX? Slack approve gate
  → Spec agent  → [if] spec valid?
  → loop { Implement (claude -p) → Build/Test/Lint } until green   ← self-heal
  → Deploy preview to Render
  → Playwright verify (screenshot + smoke)  → [if] verified?
  → Open PR + comment (live link + screenshot)
  → Slack approve → merge
  → write telemetry → Console dashboard
```

## Build order (submission-safe at every checkpoint)

1. **Spine** — Webhook → Spec → gate → runner code-gen → build/test gate → PR w/ preview link on **#5368**. Satisfies all 5 requirements.
2. **Differentiators** — `loop` self-heal + Playwright proof screenshot.
3. **Polish** — Console dashboard.
4. **Upside** — Slack card, classification, 2nd issue.

## Quickstart

```sh
cp .env.example .env        # fill in real values (see day-of checklist)
# Push canvas to SuperPlane Cloud:
superplane apps canvas update -f canvas/canvas.yaml
# Deploy the Render services:
#   create a Render Blueprint from services/render.yaml
```

See [`docs/architecture.md`](docs/architecture.md) for the full design and the verified
SuperPlane primitive mapping.
