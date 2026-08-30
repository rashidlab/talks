#!/usr/bin/env node
//
// VIEWPORT PREFLIGHT
//
// Measures the real rendered geometry of every slide in a Quarto RevealJS deck and
// fails if any slide's content crosses the safe content boundary.
//
// WHY this exists. RevealJS scales a fixed 1280x720 slide canvas to fit whatever
// window it is given. Content laid out below y=720 in slide coordinates is not
// clipped with a scrollbar and not marked in any way. It is simply not on the screen
// in the room, and the presenter cannot see that from the speaker view. This deck has
// lost scientific content that way twice, once a whole contrast row of a figure and
// once the epistemic qualifiers that are the point of the slides carrying them.
// Reading the qmd cannot detect it, because the overflow is a property of the
// rendered layout and not of the source.
//
// WHY a headless browser rather than an estimate from the source. Figure heights,
// title wrapping, fragment stacking and CSS margins compose into the final bottom
// edge. Only the layout engine knows the answer, so the gate asks the layout engine.
//
// USAGE
//   node tools/viewport-preflight.mjs [options]
//     --html <path>     deck HTML to measure. Default dose-finding-program-consequences.html
//     --source <path>   qmd whose mtime the HTML must postdate. Default matches --html
//     --allow-stale     measure the HTML even if it is older than its sources
//     --verbose         list the five deepest elements on each offending slide
//     --json            emit machine-readable results on stdout
//     --expect-fail <n[,n...]>  self-test mode. Exit 0 only if exactly these slide
//                       numbers are flagged. Used to prove the gate can fail.
//
// EXIT CODES
//   0  every slide clears the boundary (or, with --expect-fail, the flagged set matched)
//   1  at least one slide crosses the boundary
//   2  the gate could not run (no browser, stale render, missing file)

import { existsSync, statSync, readFileSync } from "node:fs";
import { resolve, dirname, basename, join } from "node:path";
import { pathToFileURL } from "node:url";
import { launch, connect, openPage, evalJs } from "./cdp.mjs";

// ---------------------------------------------------------------------------
// Arguments
// ---------------------------------------------------------------------------
const argv = process.argv.slice(2);
const arg = (name, fallback = null) => {
  const i = argv.indexOf(name);
  return i >= 0 && argv[i + 1] ? argv[i + 1] : fallback;
};
const flag = (name) => argv.includes(name);

const HERE = dirname(new URL(import.meta.url).pathname);
const DECK_DIR = resolve(HERE, "..");
const htmlPath = resolve(arg("--html", join(DECK_DIR, "dose-finding-program-consequences.html")));
const sourcePath = resolve(arg("--source", htmlPath.replace(/\.html$/, ".qmd")));
const verbose = flag("--verbose");
const asJson = flag("--json");
const expectFail = arg("--expect-fail", null);
const PORT = Number(arg("--port", "9339"));

const die = (msg) => { console.error(`viewport-preflight: ${msg}`); process.exit(2); };

if (!existsSync(htmlPath)) die(`no rendered HTML at ${htmlPath}. Run quarto render first.`);

// ---------------------------------------------------------------------------
// Staleness guard
//
// WHY. A gate that certifies a stale render certifies nothing. The failure mode is
// silent and attractive: edit the qmd to fix an overflow, run the gate against
// yesterday's HTML, see green, present the broken deck. So the gate refuses to
// measure HTML older than the sources that produce it.
// ---------------------------------------------------------------------------
if (!flag("--allow-stale")) {
  const htmlAge = statSync(htmlPath).mtimeMs;
  const sources = [sourcePath];
  if (existsSync(sourcePath)) {
    // The theme list in the qmd front matter names the stylesheets that set the
    // geometry, so a CSS edit is a source edit for this purpose.
    const qmd = readFileSync(sourcePath, "utf8");
    for (const m of qmd.matchAll(/([\w.-]+\.(?:css|scss))/g)) {
      const p = join(dirname(sourcePath), m[1]);
      if (existsSync(p)) sources.push(p);
    }
  }
  const stale = sources.filter((p) => existsSync(p) && statSync(p).mtimeMs > htmlAge);
  if (stale.length) {
    die(`the rendered HTML predates ${stale.map((p) => basename(p)).join(", ")}. `
      + `Run quarto render, or pass --allow-stale to measure it anyway.`);
  }
}

// ---------------------------------------------------------------------------
// In-page measurement
//
// All geometry below is reported in SLIDE-LOCAL pixels: the coordinate system of
// RevealJS's fixed authoring canvas, origin at the slide's top-left, independent of
// the window the deck is shown in. Viewport rects are converted by subtracting the
// .slides origin and dividing by Reveal.getScale(). That is the frame the deck is
// authored in, so a number here means the same thing on any projector.
// ---------------------------------------------------------------------------

// Chrome is furniture Quarto and Reveal add around the slide: the footer band, the
// logo, the slide number, the progress bar. It is not content and must not be
// measured as content, but the bottom-anchored pieces of it ARE obstructions that
// content must stay clear of.
const CHROME_SELECTOR = ".footer, .slide-logo, .slide-number, .progress, .controls, "
  + ".backgrounds, .speaker-controls, .pause-overlay, .overlay, aside.notes, .notes";

const SETUP = `
window.__vp = (() => {
  const R = window.Reveal;
  const slidesEl = document.querySelector('.reveal .slides');
  const frame = () => {
    const r = slidesEl.getBoundingClientRect();
    return { top: r.top, left: r.left, scale: R.getScale() };
  };
  const localise = (el) => {
    const f = frame();
    const r = el.getBoundingClientRect();
    return {
      top:    (r.top    - f.top)  / f.scale,
      bottom: (r.bottom - f.top)  / f.scale,
      left:   (r.left   - f.left) / f.scale,
      right:  (r.right  - f.left) / f.scale,
    };
  };
  const visible = (el) => {
    const cs = getComputedStyle(el);
    if (cs.display === 'none') return false;
    const r = el.getBoundingClientRect();
    return r.width > 0 || r.height > 0;
  };
  return { R, slidesEl, localise, visible, canvas: { w: R.getConfig().width, h: R.getConfig().height } };
})();
true`;

const READY = `(async () => {
  // Layout is only final once fonts and images have resolved. Measuring earlier
  // reports the pre-swap layout, which is a different and wrong answer.
  await document.fonts.ready;
  await Promise.all([...document.images].map((i) => i.complete
    ? null
    : new Promise((res) => { i.addEventListener('load', res, { once: true }); i.addEventListener('error', res, { once: true }); })));
  await new Promise((res) => requestAnimationFrame(() => requestAnimationFrame(res)));
  return document.images.length;
})()`;

// Derive the safe content boundary from the deck's own rendered furniture.
const DERIVE_BOUNDARY = `(() => {
  const { R, localise, visible, canvas } = window.__vp;
  // Measure chrome on a slide that actually shows it. The title slide carries
  // data-state="hide-footer", so deriving the boundary there would miss the footer
  // entirely and hand back a boundary that is too generous.
  const slides = R.getSlides();
  let probe = null;
  for (const s of slides) {
    const ix = R.getIndices(s);
    R.slide(ix.h, ix.v);
    const f = document.querySelector('.reveal .footer');
    if (f && visible(f)) { probe = ${JSON.stringify("")} + (slides.indexOf(s) + 1); break; }
  }
  const obstructions = [];
  for (const el of document.querySelectorAll(${JSON.stringify(CHROME_SELECTOR.split(", ").map((s) => ".reveal " + s).join(", "))})) {
    if (!visible(el)) continue;
    const b = localise(el);
    // Only bottom-anchored furniture constrains the bottom of the content. The
    // slide number renders in the top margin band on this deck, and taking a
    // minimum over every chrome element without this test would return its
    // negative top and make the boundary nonsense.
    if (b.top <= canvas.h / 2) continue;
    // Furniture that does not overlap the slide horizontally cannot be collided with.
    if (b.right <= 0 || b.left >= canvas.w) continue;
    obstructions.push({
      selector: el.className ? '.' + el.className.toString().trim().split(/\\s+/).join('.') : el.tagName,
      top: +b.top.toFixed(1), bottom: +b.bottom.toFixed(1),
      left: +b.left.toFixed(1), right: +b.right.toFixed(1),
    });
  }
  obstructions.sort((a, b) => a.top - b.top);
  return { probeSlide: probe, canvas, obstructions };
})()`;

const MEASURE_ONE = (i) => `(() => {
  const { R, localise, canvas } = window.__vp;
  const section = R.getSlides()[${i}];
  const chromeSel = ${JSON.stringify(CHROME_SELECTOR)};
  const ranked = [];
  const walk = (el) => {
    for (const c of el.children) {
      if (c.matches(chromeSel) || c.closest(chromeSel)) continue;
      const cs = getComputedStyle(c);
      // display:none contributes no layout. visibility:hidden DOES, which is what
      // unrevealed Reveal fragments use, so those are measured. A fragment that is
      // off-screen when revealed is off-screen, and the gate has to say so.
      if (cs.display === 'none') { continue; }
      const r = c.getBoundingClientRect();
      if (r.width === 0 && r.height === 0) { walk(c); continue; }
      const b = localise(c);
      ranked.push({
        bottom: +b.bottom.toFixed(1), top: +b.top.toFixed(1),
        tag: c.tagName.toLowerCase(),
        cls: (c.className || '').toString().trim().split(/\\s+/).slice(0, 3).join('.'),
        text: (c.textContent || '').trim().replace(/\\s+/g, ' ').slice(0, 70),
      });
      walk(c);
    }
  };
  walk(section);
  ranked.sort((a, b) => b.bottom - a.bottom);
  const h = section.querySelector('h1, h2, h3');
  const lineH = h ? parseFloat(getComputedStyle(h).lineHeight) : 0;
  return {
    number: ${i} + 1,
    title: h ? h.textContent.trim().replace(/\\s+/g, ' ') : '(no heading)',
    titleLines: h && lineH ? Math.round(h.getBoundingClientRect().height / (lineH * R.getScale())) : null,
    bottom: ranked.length ? ranked[0].bottom : 0,
    deepest: ranked.slice(0, 5),
  };
})()`;

// ---------------------------------------------------------------------------
// Run
// ---------------------------------------------------------------------------
let browserHandle = null;
try {
  browserHandle = await launch(PORT);
} catch (e) {
  die(e.message);
}

let exitCode = 0;
try {
  const browser = await connect(PORT);
  const page = await openPage(browser, PORT, pathToFileURL(htmlPath).href);
  // WHY an explicit device metrics override rather than trusting --window-size.
  // --window-size sizes the OS window including its frame, so the viewport came back
  // 1280x633 and Reveal scaled to 0.79. The override sets the viewport itself.
  await page.send("Emulation.setDeviceMetricsOverride", {
    width: 1280, height: 720, deviceScaleFactor: 1, mobile: false,
  });
  await evalJs(page, READY);
  const hasReveal = await evalJs(page, `!!window.Reveal && typeof window.Reveal.getSlides === 'function'`);
  if (!hasReveal) die(`${basename(htmlPath)} does not look like a RevealJS deck.`);
  await evalJs(page, SETUP);

  const { canvas, obstructions, probeSlide } = await evalJs(page, DERIVE_BOUNDARY);

  // ---- The safe content boundary -----------------------------------------
  //
  // Three terms, all measured from the deck rather than chosen:
  //
  //   1. The canvas floor. Reveal's configured slide height. Anything below it is
  //      off the rendered slide and therefore off the screen.
  //   2. The lowest bottom-anchored chrome top. Content above this line is clear of
  //      the footer band, the logo and the progress bar. Content below it collides
  //      with opaque furniture, which is a legibility failure even when the pixels
  //      are technically on the canvas.
  //   3. A projection margin. Reveal maps slide-local y to floor(y * scale) at a
  //      scale set by the room's aspect ratio, so a value one pixel inside the line
  //      at one scale can land one pixel outside at another, and projectors fed a
  //      signal they letterbox or overscan eat the outermost rows. One percent of
  //      the canvas height, rounded up to a whole pixel, covers both.
  const canvasFloor = canvas.h;
  const lowestChromeTop = obstructions.length ? obstructions[0].top : canvasFloor;
  const projectionMargin = Math.ceil(0.01 * canvas.h);
  const boundary = +(Math.min(canvasFloor, lowestChromeTop) - projectionMargin).toFixed(1);

  const n = await evalJs(page, `window.Reveal.getSlides().length`);
  const rows = [];
  for (let i = 0; i < n; i++) {
    await evalJs(page, `(() => { const R = window.Reveal; const ix = R.getIndices(R.getSlides()[${i}]); R.slide(ix.h, ix.v); })()`);
    // Reveal animates the slide change. Measuring mid-transition reports a
    // transformed rect, so let the transition settle before reading geometry.
    await new Promise((r) => setTimeout(r, 160));
    rows.push(await evalJs(page, MEASURE_ONE(i)));
  }

  const offenders = rows.filter((r) => r.bottom > boundary);

  if (asJson) {
    console.log(JSON.stringify({ boundary, canvas, projectionMargin, obstructions, slides: rows, offenders: offenders.map((o) => o.number) }, null, 2));
  } else {
    console.log(`VIEWPORT PREFLIGHT  ${basename(htmlPath)}`);
    console.log(`  canvas                 ${canvas.w} x ${canvas.h} slide-local px`);
    console.log(`  chrome probed on slide ${probeSlide}`);
    for (const o of obstructions) {
      console.log(`  obstruction            ${o.selector.padEnd(24)} top ${String(o.top).padStart(7)}  x [${o.left}, ${o.right}]`);
    }
    console.log(`  lowest chrome top      ${lowestChromeTop}`);
    console.log(`  projection margin      ${projectionMargin}  (1 percent of ${canvas.h}, rounded up)`);
    console.log(`  SAFE CONTENT BOUNDARY  ${boundary}   = min(${canvasFloor}, ${lowestChromeTop}) - ${projectionMargin}`);
    console.log(`  slides measured        ${rows.length}`);
    console.log("");
    if (offenders.length === 0) {
      console.log(`PASS. All ${rows.length} slides clear the boundary.`);
      const worst = [...rows].sort((a, b) => b.bottom - a.bottom).slice(0, 3);
      console.log(`  tightest: ${worst.map((w) => `slide ${w.number} at ${w.bottom}`).join(", ")}`);
    } else {
      console.log(`FAIL. ${offenders.length} of ${rows.length} slides cross the safe content boundary of ${boundary}.`);
      console.log("");
      for (const o of offenders) {
        console.log(`  slide ${String(o.number).padStart(2)}  bottom ${String(o.bottom).padStart(7)}  over by ${String(+(o.bottom - boundary).toFixed(1)).padStart(6)}  ${o.title}`);
        if (verbose) {
          for (const d of o.deepest) {
            console.log(`            ${String(d.bottom).padStart(7)}  ${(d.tag + (d.cls ? "." + d.cls : "")).padEnd(34)} ${d.text}`);
          }
          console.log("");
        }
      }
    }
  }

  // --expect-fail turns the gate into its own negative control. It passes only when
  // the flagged set is exactly the set the caller says should be flagged, so it
  // catches both a gate that stopped failing and a gate that started over-failing.
  if (expectFail !== null) {
    const want = expectFail.split(",").map((s) => Number(s.trim())).sort((a, b) => a - b);
    const got = offenders.map((o) => o.number).sort((a, b) => a - b);
    const same = want.length === got.length && want.every((v, i) => v === got[i]);
    console.log("");
    console.log(`SELF-TEST  expected flagged [${want.join(", ")}]  got [${got.join(", ")}]  ${same ? "MATCH" : "MISMATCH"}`);
    exitCode = same ? 0 : 1;
  } else {
    exitCode = offenders.length ? 1 : 0;
  }
} catch (e) {
  console.error(`viewport-preflight: ${e.stack || e.message}`);
  exitCode = 2;
} finally {
  browserHandle.cleanup();
}
process.exit(exitCode);
