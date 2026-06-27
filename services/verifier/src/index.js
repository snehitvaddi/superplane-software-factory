// factory-verifier — loads a deployed preview in real Chromium, runs smoke checks,
// captures a screenshot, and returns structured pass/fail evidence.
// This is the "Prove" stage: visual proof the PoC actually works, posted on the PR.
import http from "node:http";
import { chromium } from "playwright";

const PORT = process.env.PORT || 4201;
const TIMEOUT = Number(process.env.CHECK_TIMEOUT_MS || 15000);

async function verify(url, contains) {
  const browser = await chromium.launch({
    args: ["--no-sandbox", "--disable-dev-shm-usage"],
  });
  try {
    const page = await browser.newPage();
    const resp = await page.goto(url, { timeout: TIMEOUT, waitUntil: "networkidle" });
    const ok = !!resp && resp.ok();
    const text = await page.content();
    const matched = contains ? text.includes(contains) : true;
    const shot = await page.screenshot({ fullPage: true });
    return {
      ok: ok && matched,
      httpOk: ok,
      contains: contains || null,
      matched,
      screenshotBase64: shot.toString("base64"),
    };
  } finally {
    await browser.close();
  }
}

const server = http.createServer(async (req, res) => {
  const u = new URL(req.url, `http://localhost:${PORT}`);
  if (u.pathname === "/health") return res.end("ok");
  if (u.pathname !== "/verify") {
    res.statusCode = 404;
    return res.end("not found");
  }
  const target = u.searchParams.get("url");
  const contains = u.searchParams.get("contains");
  res.setHeader("content-type", "application/json");
  if (!target) {
    res.statusCode = 400;
    return res.end(JSON.stringify({ error: "url required" }));
  }
  try {
    const result = await verify(target, contains);
    res.statusCode = result.ok ? 200 : 422;
    res.end(JSON.stringify(result));
  } catch (e) {
    res.statusCode = 500;
    res.end(JSON.stringify({ ok: false, error: String(e) }));
  }
});

server.listen(PORT, () => console.log(`factory-verifier on :${PORT}`));
