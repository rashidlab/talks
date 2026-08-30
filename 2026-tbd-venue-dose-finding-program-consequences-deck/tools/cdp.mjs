// Minimal Chrome DevTools Protocol driver over Node's built-in WebSocket.
//
// WHY no puppeteer or playwright. This gate has to run on any lab machine and on a
// conference laptop the night before a talk. An npm install that can fail, or a
// bundled Chromium that has to download, is a reason the gate gets skipped. Node 22
// ships a global WebSocket and Chrome ships a CDP endpoint, so the whole driver is
// this file and it has no install step.
import { spawn } from "node:child_process";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const CHROME_CANDIDATES = [
  process.env.CHROME_BIN,
  "google-chrome",
  "google-chrome-stable",
  "chromium",
  "chromium-browser",
].filter(Boolean);

export async function launch(port) {
  const profile = mkdtempSync(join(tmpdir(), "viewport-preflight-chrome-"));
  let lastErr = "";
  for (const bin of CHROME_CANDIDATES) {
    const proc = spawn(bin, [
      "--headless=new",
      "--disable-gpu",
      "--no-sandbox",
      "--no-first-run",
      "--no-default-browser-check",
      "--hide-scrollbars",
      // WHY force scale 1. Any device pixel ratio other than 1 makes CSS-pixel
      // geometry differ from what the room's projector will lay out, and the whole
      // point of this gate is a number that transfers to the room.
      "--force-device-scale-factor=1",
      "--window-size=1280,720",
      `--remote-debugging-port=${port}`,
      `--user-data-dir=${profile}`,
      "about:blank",
    ], { stdio: ["ignore", "pipe", "pipe"] });
    let err = "";
    proc.stderr.on("data", (d) => { err += d.toString(); });
    let failed = false;
    proc.on("error", () => { failed = true; });
    // Poll the devtools HTTP endpoint until the browser answers.
    for (let i = 0; i < 120 && !failed; i++) {
      try {
        const r = await fetch(`http://127.0.0.1:${port}/json/version`);
        if (r.ok) {
          return {
            proc,
            binary: bin,
            cleanup: () => {
              try { proc.kill(); } catch { /* already gone */ }
              try { rmSync(profile, { recursive: true, force: true }); } catch { /* best effort */ }
            },
          };
        }
      } catch { /* not up yet */ }
      await new Promise((r) => setTimeout(r, 100));
    }
    try { proc.kill(); } catch { /* already gone */ }
    lastErr = `${bin}: ${err.slice(-400)}`;
  }
  try { rmSync(profile, { recursive: true, force: true }); } catch { /* best effort */ }
  throw new Error(`no usable Chrome found. Tried ${CHROME_CANDIDATES.join(", ")}\n${lastErr}`);
}

export class Session {
  constructor(ws) {
    this.ws = ws;
    this.id = 0;
    this.pending = new Map();
    ws.addEventListener("message", (e) => {
      const m = JSON.parse(e.data);
      if (m.id && this.pending.has(m.id)) {
        const { res, rej } = this.pending.get(m.id);
        this.pending.delete(m.id);
        if (m.error) rej(new Error(JSON.stringify(m.error)));
        else res(m.result);
      }
    });
  }
  send(method, params = {}) {
    const id = ++this.id;
    this.ws.send(JSON.stringify({ id, method, params }));
    return new Promise((res, rej) => this.pending.set(id, { res, rej }));
  }
  close() { try { this.ws.close(); } catch { /* already closed */ } }
}

async function openSocket(url) {
  const ws = new WebSocket(url);
  await new Promise((res, rej) => {
    ws.addEventListener("open", res, { once: true });
    ws.addEventListener("error", rej, { once: true });
  });
  return new Session(ws);
}

export async function connect(port) {
  const v = await (await fetch(`http://127.0.0.1:${port}/json/version`)).json();
  return openSocket(v.webSocketDebuggerUrl);
}

export async function openPage(browser, port, url) {
  // WHY a second socket rather than a flattened session on the browser socket.
  // CDP sessions are scoped to the connection that created them, so a sessionId
  // minted on the browser socket is rejected with "Session with given id not found"
  // when replayed on another socket. Talking to the page target directly avoids
  // the whole question.
  const { targetId } = await browser.send("Target.createTarget", { url: "about:blank" });
  let wsUrl = null;
  for (let i = 0; i < 50 && !wsUrl; i++) {
    const list = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
    const t = list.find((x) => x.id === targetId);
    if (t && t.webSocketDebuggerUrl) wsUrl = t.webSocketDebuggerUrl;
    else await new Promise((r) => setTimeout(r, 100));
  }
  if (!wsUrl) throw new Error("chrome opened no websocket for the page target");
  const page = await openSocket(wsUrl);
  await page.send("Page.enable");
  await page.send("Runtime.enable");
  const loaded = new Promise((res) => {
    const h = (e) => {
      if (JSON.parse(e.data).method === "Page.loadEventFired") {
        page.ws.removeEventListener("message", h);
        res();
      }
    };
    page.ws.addEventListener("message", h);
  });
  await page.send("Page.navigate", { url });
  await loaded;
  return page;
}

export async function evalJs(page, expression) {
  const r = await page.send("Runtime.evaluate", { expression, returnByValue: true, awaitPromise: true });
  if (r.exceptionDetails) throw new Error(JSON.stringify(r.exceptionDetails, null, 2));
  return r.result.value;
}
