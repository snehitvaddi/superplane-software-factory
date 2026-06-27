#!/usr/bin/env bash
# Runner node: "Deploy Preview"
# Builds the frontend and ships it to a single Render static site (free tier, no spin-down),
# then returns the live preview URL for the PR comment.
#
# Free-tier note: true per-PR Preview Environments need Render Pro. We instead redeploy ONE
# persistent static site per run and read back its URL — same demo outcome, $0.
#
# Env: RENDER_API_KEY, RENDER_PREVIEW_SERVICE_ID
set -euo pipefail
: "${RENDER_API_KEY:?}"; : "${RENDER_PREVIEW_SERVICE_ID:?}"
WORK="$(pwd)/workspace/repo"

# build the static preview of the changed frontend
( cd "$WORK/web_src" && npm run build )

# trigger a Render deploy of the preview service and wait
DEPLOY=$(curl -fsS -X POST \
  "https://api.render.com/v1/services/${RENDER_PREVIEW_SERVICE_ID}/deploys" \
  -H "Authorization: Bearer ${RENDER_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"clearCache":"do_not_clear"}')

# fetch the service URL (serviceDetails.url)
URL=$(curl -fsS \
  "https://api.render.com/v1/services/${RENDER_PREVIEW_SERVICE_ID}" \
  -H "Authorization: Bearer ${RENDER_API_KEY}" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin).get("serviceDetails",{}).get("url",""))')

echo "{\"previewUrl\":\"${URL}\"}" > "$SUPERPLANE_RESULT_FILE"
echo "preview: ${URL}"
