# 3-Minute Demo Script

You get **3 minutes**. Judges score: usefulness, technical depth, AI/agents, creativity,
demo quality. The whole game is: **make them feel the magic, never watch a spinner.**

## The golden rule: pre-bake, then perform

Before presentations (during the 16:15–17:00 polish window), run the FULL pipeline once on
issue **#5368** so you have a **real, already-merged PR with a live preview link**. That is
your proof. During the live demo you *start* a fresh run for theater, but you *show* the
pre-baked result. Never bet the demo on a live 5–15 min code-gen.

## Beat sheet (target ~2:45, leaves buffer)

| Time | You say | You show |
|------|---------|----------|
| 0:00 | "We're holding a funeral for the manual dev loop. Watch an idea become a tested, deployed feature — with no human writing code." | Title slide / the Canvas |
| 0:20 | "I drop a rough request in — just a sentence." Type `/solve #5368` (or paste into the form). | The intake firing |
| 0:35 | "SuperPlane classifies it, an agent writes a spec, and a gate checks the spec is real before we spend a build." | Canvas nodes lighting green: Classify → Spec → gate |
| 1:00 | "Now the coding agent clones the repo and implements it — and here's the part nobody else does: if the build fails, the errors loop back and it **fixes itself**." | The `loop` node + runner logs |
| 1:25 | "While that runs live, here's the same pipeline that finished moments ago." Switch to the pre-baked PR. | The real PR on GitHub |
| 1:45 | "It opened a PR, deployed a preview, and — the kicker — an agent **tested its own work in a browser** and posted the proof." | PR comment: live link + screenshot |
| 2:05 | **Click the preview link. The feature works live.** | The rendered markdown/mermaid in the preview |
| 2:25 | "Idea in. Tested, deployed, *proven* PoC out. The entire factory IS this SuperPlane canvas — and it runs on all five of your validation issues." | Back to the Canvas |
| 2:40 | "We didn't replace a script. We replaced the loop." | Closing slide |

## Lines that score points
- **Usefulness:** "on your *own* real issues, today."
- **Technical:** "self-healing loop — it validates every stage and recovers."
- **AI/agents:** "three agents: spec, coder, and a QA agent that tests its own work."
- **Creativity:** "the agent attaches its own demo video to the PR."
- **On-platform:** "delete SuperPlane and there's no project left — the canvas *is* the product."

## If something breaks (it won't sink you)
- Live run hangs → "and while that finishes, here's the completed one" → pre-baked PR. Smooth.
- WiFi dies → screen-recording of the full run + screenshots saved locally (capture these
  during polish). Narrate over the recording.
- Preview 404s → you have a second pre-baked preview URL from a different issue. Keep two.

## Pre-demo checklist (do at 16:15)
- [ ] One full pipeline run completed on #5368; PR + preview URL saved
- [ ] Second preview URL saved (different issue or re-run) as backup
- [ ] Screen recording of a full green run saved locally
- [ ] Screenshots of: Canvas all-green, PR comment, live preview
- [ ] Browser tabs pre-opened in order; font size bumped for the room
- [ ] Rehearsed out loud twice, under 3:00
