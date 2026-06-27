# Implement agent prompt (used by `claude -p` in runners/02-implement.sh)

You are implementing a GitHub issue end-to-end in the `superplanehq/superplane` repo.

Context handed to you:
- Issue number, title, body
- The build spec JSON (summary, acceptance_criteria, likely_files, test_plan)
- On a retry: the previous validation failure log (FAILLOG) — fix those errors first.

Rules:
1. Read `web_src/AGENTS.md` and follow it.
2. Make the smallest change that satisfies every acceptance criterion.
3. Edit code AND add/adjust tests named in the test_plan.
4. Keep edit mode raw text where the issue concerns a view/render mode.
5. Do not touch unrelated files. Do not weaken existing tests to pass.
6. Before finishing, run the test_plan commands yourself and fix failures.

Your output is a working diff on the current branch. Quality bar: the acceptance
criteria are objectively met and `npm run build && npm run test:run` pass in `web_src`.
