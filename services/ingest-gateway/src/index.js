// ingest-gateway — normalizes any idea source (X mention, GitHub issue, web form)
// into one canonical payload, then forwards it to the SuperPlane Webhook trigger.
// Source-agnostic on purpose: the demo uses /idea (form) + /webhook/github.
import http from "node:http";

const PORT = process.env.PORT || 4200;
const SP_URL = process.env.SUPERPLANE_WEBHOOK_URL;       // SuperPlane webhook trigger URL
const SP_TOKEN = process.env.SUPERPLANE_WEBHOOK_TOKEN;   // X-Webhook-Token

const read = (req) =>
  new Promise((res) => {
    let b = "";
    req.on("data", (c) => (b += c));
    req.on("end", () => res(b));
  });

function canonical(source, raw) {
  // map each source shape into one idea
  if (source === "github") {
    return {
      runId: `gh-${raw.issue?.number || Date.now()}`,
      source,
      issueNumber: raw.issue?.number,
      title: raw.issue?.title,
      body: raw.comment?.body || raw.issue?.body || "",
    };
  }
  // form / x / generic
  return {
    runId: `idea-${Date.now()}`,
    source,
    issueNumber: raw.issueNumber,
    title: raw.title || "(untitled idea)",
    body: raw.body || raw.text || "",
  };
}

async function forward(idea) {
  if (!SP_URL) return { skipped: "no SUPERPLANE_WEBHOOK_URL" };
  const r = await fetch(SP_URL, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      ...(SP_TOKEN ? { "X-Webhook-Token": SP_TOKEN } : {}),
    },
    body: JSON.stringify(idea),
  });
  return { status: r.status };
}

const server = http.createServer(async (req, res) => {
  if (req.url === "/health") return res.end("ok");
  if (req.method !== "POST") {
    res.statusCode = 405;
    return res.end("POST only");
  }
  const source = req.url.includes("github") ? "github" : "form";
  let raw = {};
  try {
    raw = JSON.parse((await read(req)) || "{}");
  } catch {}
  const idea = canonical(source, raw);
  const fwd = await forward(idea);
  res.setHeader("content-type", "application/json");
  res.end(JSON.stringify({ idea, forwarded: fwd }));
});

server.listen(PORT, () => console.log(`ingest-gateway on :${PORT}`));
