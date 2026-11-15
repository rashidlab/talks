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
              "TODO", "SURPASS", "hetGP", "FACT-PENDING"]
TITLE_ONLY_OK = {"AI-guided": 1}   # allowed only on this page

ap = argparse.ArgumentParser()
ap.add_argument("html"); ap.add_argument("--main", type=int, default=0, help="number of main-deck pages (0 = all)")
ap.add_argument("--cap", type=int, default=60); ap.add_argument("--out", default="qa")
a = ap.parse_args()
deck = os.path.abspath(a.html); base = os.path.splitext(deck)[0]; pdf = base + ".pdf"
os.makedirs(a.out, exist_ok=True)

subprocess.run(["npx", "decktape", "reveal", "--chrome-arg=--no-sandbox", "-s", "1280x720", "--load-pause", "800", "file://" + deck, pdf], check=True)
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
over = []
for i, p in enumerate(pg[:n], 1):
    lines = [l for l in p.splitlines() if not ("TRIBIX" in l.upper() and "LINEBERGER" in l.upper())]
    t = re.sub(rf"\b\d+ / {n}\b", "", " ".join(lines))
    w = len(re.findall(r"[A-Za-z0-9][A-Za-z0-9'’.,%/-]*", t))
    if w > a.cap and i <= main_n: over.append((i, w))
print("main-deck slides over the word cap:", over or "none")
for s in PROHIBITED:
    hits = [i + 1 for i, p in enumerate(pg) if s in p and (i + 1) <= main_n]
    if hits: print(f"PROHIBITED {s!r} on pages {hits}")
for s, ok in TITLE_ONLY_OK.items():
    hits = [i + 1 for i, p in enumerate(pg) if s in p and (i + 1) <= main_n and (i + 1) != ok]
    if hits: print(f"PROHIBITED (outside page {ok}) {s!r} on pages {hits}")

qmd = base + ".qmd"
if os.path.exists(qmd):
    src = open(qmd).read(); chunks = re.split(r"\n(?=## )", src[src.index("\n## ") + 1:])
    missing = [i + 1 for i, c in enumerate(chunks) if re.search(r"\bSay\b|Say aloud|Spoken|Define aloud|Gloss", c) and "::: {.notes}" not in c]
    print("slides with spoken cues but no notes block:", missing or "none")
    print("em-dashes in source:", src.count("—"))
print("contact sheets:", sorted(glob.glob(f"{a.out}/contact-*.png")))
