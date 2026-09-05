#!/usr/bin/env python3
"""Pre-room QA for a Quarto RevealJS deck (generalist-scientist profile).

Usage: python3 deck_qa.py <deck>.html [--main N] [--cap 60] [--out DIR]

Steps: decktape export -> rasterize 1920x1080 -> contact sheets -> per-slide word counts
(title + caption included; numbers count) -> prohibited-string grep on extracted text ->
[TODO: confirm] scan -> speaker-notes presence for slides whose notes contain "Say" cues.
Requires: npx decktape, pdftoppm/pdftotext (poppler), Pillow.
"""
import argparse, glob, os, re, subprocess, sys
from PIL import Image, ImageDraw

PROHIBITED = ["—", "black box", "cheaply", "guarantee", "always feasible",
              "changed decisions", "no tool that searches", "Both correct", "E_0[N]", "E0[N]",
              "TODO"]
TITLE_ONLY_OK = {"AI-guided": 1}   # allowed only on this page

ap = argparse.ArgumentParser()
ap.add_argument("html"); ap.add_argument("--main", type=int, default=0, help="number of main-deck pages (0 = all)")
ap.add_argument("--cap", type=int, default=60); ap.add_argument("--out", default="qa")
a = ap.parse_args()
deck = os.path.abspath(a.html); base = os.path.splitext(deck)[0]; pdf = base + ".pdf"
os.makedirs(a.out, exist_ok=True)

subprocess.run(["npx", "decktape", "reveal", "-s", "1280x720", "--load-pause", "800", "file://" + deck, pdf], check=True)
for f in glob.glob(f"{a.out}/p-*.png"): os.remove(f)
subprocess.run(["pdftoppm", "-r", "144", "-png", pdf, f"{a.out}/p"], check=True)
pages = sorted(glob.glob(f"{a.out}/p-*.png")); n = len(pages)
print(f"pages: {n}")

for si in range(0, n, 12):
    sheet = Image.new("RGB", (3 * 640 + 40, 4 * 360 + 50), "white"); d = ImageDraw.Draw(sheet)
    for k, f in enumerate(pages[si:si + 12]):
        im = Image.open(f).resize((640, 360)); r, c = divmod(k, 3); x, y = 10 + c * 640, 10 + r * 360
        sheet.paste(im, (x, y)); d.rectangle([x, y, x + 639, y + 359], outline="#888"); d.text((x + 6, y + 4), str(si + k + 1), fill="red")
    sheet.save(f"{a.out}/contact-{si + 1:02d}-{min(si + 12, n):02d}.png")

txt = subprocess.run(["pdftotext", "-layout", pdf, "-"], capture_output=True, text=True, check=True).stdout
pg = txt.split("\f"); main_n = a.main or n

# THE RUNNING FOOTER IS DERIVED FROM THE DECK, NOT GUESSED AT BY KEYWORD. The previous filter
# required both "SEMINAR" and "LINEBERGER" on one line, which matched the reference deck's footer
# and matched nothing here, so every content slide was counted with its footer and inflated by the
# footer's own length. A word cap enforced against an inflated count is not the cap that was
# specified.
_qmd_for_footer = base + ".qmd"
_footer_words = set()
if os.path.exists(_qmd_for_footer):
    _m = re.search(r"^\s*footer:\s*(.+)$", open(_qmd_for_footer).read(), re.M)
    if _m:
        _f = re.sub(r"<[^>]+>", " ", _m.group(1)).strip().strip("'\"")
        _footer_words = {w.upper() for w in re.findall(r"[A-Za-z0-9][A-Za-z0-9'\u2019.,%/-]*", _f)}

def _is_footer(line):
    # THE SLIDE NUMBER SHARES THE FOOTER'S LINE, so it is stripped BEFORE the test. Testing the
    # raw line was the second version of this defect: the subset check failed on the page number
    # and the footer survived on every page exactly as it did under the keyword filter.
    bare = re.sub(rf"\b\d+\s*/\s*{n}\b", " ", line)
    ws = {w.upper() for w in re.findall(r"[A-Za-z0-9][A-Za-z0-9'\u2019.,%/-]*", bare)}
    return bool(ws) and bool(_footer_words) and ws <= _footer_words

_footer_hits = 0
over = []
for i, p in enumerate(pg[:n], 1):
    lines = [l for l in p.splitlines() if not _is_footer(l)]
    _footer_hits += len(p.splitlines()) - len(lines)
    t = re.sub(rf"\b\d+ / {n}\b", "", " ".join(lines))
    w = len(re.findall(r"[A-Za-z0-9][A-Za-z0-9'’.,%/-]*", t))
    if w > a.cap and i <= main_n: over.append((i, w))
if not _footer_words:
    print("WARNING: no footer declared in the qmd, so no footer text was excluded from the counts.")
elif _footer_hits < n / 2:
    # NOT "ZERO", BUT "IMPLAUSIBLY FEW". A first version warned only at zero, and a probe that
    # disabled the slide-number strip matched exactly one page in fifty. That printed a reassuring
    # count and no warning while every other page was still counted with its footer. A filter that
    # matches almost nothing looks like a filter that works, which is the failure this guard exists
    # to catch, so the threshold is a share of the deck rather than the absence of any match.
    print(f"WARNING: a footer IS declared but matched only {_footer_hits} of {n} pages. Nearly "
          f"every count below still includes it. Fix the footer filter before trusting the cap.")
else:
    print(f"footer lines excluded from the counts: {_footer_hits} across {n} pages")
print("main-deck slides over the word cap:", over or "none")
# EVERY RENDERED PAGE IS SWEPT, not only the ones inside the word cap's bound. `--main` marks
# where the backups begin so acknowledgments and backups are exempt from the CAP, which is the
# talk skill's rule. It was also silently bounding the banned-vocabulary sweep, which has no such
# exemption, so two rendered main-deck slides and every backup went unchecked.
for s in PROHIBITED:
    hits = [i + 1 for i, p in enumerate(pg[:n]) if s in p]
    if hits: print(f"PROHIBITED {s!r} on pages {hits}")
for s, ok in TITLE_ONLY_OK.items():
    hits = [i + 1 for i, p in enumerate(pg[:n]) if s in p and (i + 1) != ok]
    if hits: print(f"PROHIBITED (outside page {ok}) {s!r} on pages {hits}")
print(f"banned-vocabulary sweep covered all {n} pages, cap applied to the first {main_n}")

qmd = base + ".qmd"
if os.path.exists(qmd):
    src = open(qmd).read(); chunks = re.split(r"\n(?=## )", src[src.index("\n## ") + 1:])
    missing = [i + 1 for i, c in enumerate(chunks) if re.search(r"\bSay\b|Say aloud|Spoken|Define aloud|Gloss", c) and "::: {.notes}" not in c]
    print("slides with spoken cues but no notes block:", missing or "none")
    print("em-dashes in source:", src.count("—"))
print("contact sheets:", sorted(glob.glob(f"{a.out}/contact-*.png")))
