# Phase 0: build system report (2026-09-04)

- **Build system:** Quarto RevealJS (reveal.js via `format: revealjs`), single-file source.
- **Source:** `baton-compmed-v2.qmd` (baseline, 54 slides). Restructure is done in a new versioned copy,
  `baton-compmed-v3.qmd`, so v2 keeps rendering throughout.
- **Assets:** `images/` (all figures; PNG). Generated figures have R scripts in the deck root
  (`make_fig_*.R`): `make_fig_novice_visuals.R` (fixed-vs-adaptive timeline, tally strip, novice
  frontier), `make_fig_search_intuition.R` (grid / random / seed / guided panels),
  `make_fig_map_simple.R` (points + GP fit), `make_fig_acquisition.R`, `make_fig_loop_plain.R`,
  `make_fig_funnel_plain.R`, `make_fig_sample_efficiency.R` (Simon convergence). Manuscript-derived
  figures (`fig_R*.png`, `fig_A_*.png`, `fig_B_*.png`, `fig_F_*.png`) and harvested ARPA-H slides
  (`harvest_*.png`) are static rasters with no script here.
- **Theme:** three CSS files in the YAML `theme:` list: `custom.css` (lab template), `title-slide.css`
  (title + section dividers), `content-slides.css` (deck utility classes: `.landing` caption band,
  `.frame-box`, `.fig-tall/.fig-mid`, footer/slide-number, `.backup-slide`).
- **Build:** `quarto render baton-compmed-v3.qmd` (HTML, embed-resources). PDF export:
  `npx decktape reveal -s 1280x720 --load-pause 800 file://$PWD/baton-compmed-v3.html baton-compmed-v3.pdf`
  (Chrome print-to-PDF reflows to portrait; never use it).
- **Backups:** slides after the "Questions" divider, then a navy "Backup" divider, then slides carrying
  the `.backup-slide` class; not separated by the build, only by position and class.
- **Baseline build:** the committed-state v2 renders to 54 pages via decktape (verified 2026-09-04,
  `pdfinfo`: Pages 54) with slide order identical to `baton-compmed-v2.pdf`; the PDF on disk IS the
  build output of the current source, so the baseline is exact rather than approximately equal.

## v3 build result (2026-09-04)
- `python3 build_v3.py` regenerates `baton-compmed-v3.qmd` from v2 + `baton-compmed-reordered-outline.md`;
  `quarto render baton-compmed-v3.qmd`; decktape export → `baton-compmed-v3.pdf`, 48 pages
  (36 main + Questions + backup divider + B1..B10), title order verified against the outline.
- Regenerated figure scripts live in the deck root (`make_fig_*.R`); manuscript-figure relabels were
  run from edited copies of `scripts/defense_figures/*.R` (scratch) writing `images/*_v3.png`.
