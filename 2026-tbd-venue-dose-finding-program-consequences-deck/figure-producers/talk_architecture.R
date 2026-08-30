# TALK-MODE VERSION OF THE FOUR ARCHITECTURE CONTRASTS, BOTH GEOMETRIES.
#
# WHY THIS EXISTS. The deck rendered these four contrasts as an HTML grid whose fourth row fell
# off the bottom of the slide. The source carried four rows and the room saw three, so the
# evidence-boundary contrast, the one comparison that isolates a single feature, was silently
# absent from the only slide that reported it. A figure with a hard `nrow == 4` assertion cannot
# fail that way, because a dropped row stops the build instead of shortening the slide.
#
# PURE RENDER FROM LOCKED ARTIFACTS. No simulation. Every estimate, interval and verdict is read
# from results/exp8_q5_primary.rds and results/exp9_q8.rds through the same reproduction guard
# scripts/fig_architecture.R uses, so the slide and the manuscript figure cannot disagree.
# docs/TALK_DESIGN-2026-08-30.md Section 9 names those two artifacts as the authority for this
# slide's content.
#
# WHAT IS DERIVED RATHER THAN TYPED. Support is recomputed here from whether the Bonferroni
# adjusted interval excludes zero, then asserted equal to the artifact's own `supported` column,
# so the figure cannot inherit a stale flag and cannot invent one. The per-row interpretation
# phrases are likewise computed from sign, support and cross-geometry magnitude. No phrase is
# attached to a contrast by hand.
#
# WHY THE ENGLISH LABELS ARE KEYED ON THE ARCHITECTURE PAIR AND NOT ON THE C INDEX. C1 through C4
# are positions in a frozen family, not meanings. Keying prose on the index would let a
# renumbering of that family relabel the wrong architecture with no error. Keying on the artifact's
# own A and B columns makes the label follow the architectures it describes.

RepoRoot <- function() {
  env <- Sys.getenv("BATOND_PAPER_REPO", "")
  if (nzchar(env)) return(normalizePath(env))
  rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
}
ROOT <- RepoRoot()
source(file.path(ROOT, "R", "metrics.R"))

# ---- REPRODUCTION GUARD, IDENTICAL TO THE MANUSCRIPT PRODUCER'S ------------------------------
M <- metrics()
raw_mono <- readRDS(file.path(ROOT, "results", "exp8_q5_primary.rds"))
raw_plat <- readRDS(file.path(ROOT, "results", "exp9_q8.rds"))
stopifnot(
  identical(raw_mono, artifact("exp8_q5_primary", M)),
  identical(raw_plat, artifact("exp9_q8", M)))

mono <- raw_mono$contrasts
plat <- raw_plat$contrasts

# ---- THE FOUR ROWS EXIST, IN ONE ORDER, ON BOTH GEOMETRIES -----------------------------------
# Order is read from the artifact rather than assumed, and the two geometries must present the
# same family in the same sequence or the panels would not be row-comparable.
stopifnot(identical(mono$contrast, plat$contrast))
stopifnot(nrow(mono) == 4L, nrow(plat) == 4L)
ORDER <- mono$contrast

# ---- ONE VOCABULARY FOR THE FOUR ARCHITECTURES -----------------------------------------------
# Verified against R/exp8_arch.R's EXP8_ARCH_TREE (the architecture definitions),
# scripts/exp8_inference.R (the frozen contrast family) and docs/DECISIONS-2026-08-27.md
# Section 5d. `select_exclude` is the hard boundary that discards evidence already generated,
# which is why it reads as restarting. `select_incorporate` is the permeable boundary that lets
# that evidence contribute downstream, which is why it reads as reuse.
#
# THESE FOUR STRINGS ARE THE DECK'S CANONICAL SET and appear verbatim in
# scripts/figures/arpa_stats_meeting/pres4a_architectures.R and pres6_no_free_optionality.R. The
# three figures previously named the same four architectures three different ways and the room
# carried away a takeaway the deck's own mechanism slide refuses. Agreement is enforced by the
# deck repo's check/vocabulary_check.R rather than remembered.
ARCH_NAME <- c(
  single             = "Commit early",
  parallel           = "Keep both through confirmation",
  select_exclude     = "Select one, then restart evidence",
  select_incorporate = "Select one, then reuse evidence")

# ---- ROW LABELS, KEYED ON THE ARCHITECTURE PAIR ----------------------------------------------
# A row of this figure is a CONTRAST, architecture A minus architecture B, so it takes two names.
# The bold label names A and the line beneath it names B. Folding the comparator into the label
# would hide that three of the four rows share one comparator, and a reader who cannot see the
# comparator reads the rows as absolute levels.
#
# ROWS THREE AND FOUR CARRY THE SAME BOLD LABEL ON PURPOSE. Both measure
# `select_incorporate`, once against committing early and once against restarting the evidence,
# and the repeat is exactly what makes the fourth row legible as the one contrast that isolates
# the boundary function alone. Inventing a distinct name for the fourth row is what produced a
# fifth vocabulary item that denoted no architecture.
pair_key <- paste(mono$A, mono$B, sep = "|")
FAMILY_KEYS <- c("parallel|single", "select_exclude|single",
                 "select_incorporate|single", "select_incorporate|select_exclude")
stopifnot(setequal(pair_key, FAMILY_KEYS), !anyDuplicated(pair_key))
stopifnot(all(mono$A %in% names(ARCH_NAME)), all(mono$B %in% names(ARCH_NAME)))
stopifnot(identical(mono$A, plat$A), identical(mono$B, plat$B))

LABEL <- unname(ARCH_NAME[mono$A])
# Lower-cased so "versus commit early" reads as one sentence fragment rather than as a title.
SUBLAB <- paste("versus", sub("^(.)", "\\L\\1", unname(ARCH_NAME[mono$B]), perl = TRUE))

# ---- SUPPORT IS RECOMPUTED, THEN CHECKED AGAINST THE ARTIFACT --------------------------------
excludes_zero <- function(lo, hi) (lo > 0) | (hi < 0)
mono_supp <- excludes_zero(mono$ci_lo, mono$ci_hi)
plat_supp <- excludes_zero(plat$ci_lo, plat$ci_hi)
stopifnot(identical(mono_supp, mono$supported), identical(plat_supp, plat$supported))

# ---- THE LONG PLOTTING FRAME, ASSERTED COMPLETE BEFORE ANYTHING IS DRAWN ---------------------
GEOM <- c(mono = "Monotone efficacy", plat = "Plateau efficacy")
PLOT <- rbind(
  data.frame(geometry = GEOM[["mono"]], label = LABEL, sublabel = SUBLAB, row = seq_len(4L),
             estimate = mono$estimate, ci_lo = mono$ci_lo, ci_hi = mono$ci_hi,
             supported = mono_supp, ref_est = mono$estimate, is_ref = TRUE,
             stringsAsFactors = FALSE),
  data.frame(geometry = GEOM[["plat"]], label = LABEL, sublabel = SUBLAB, row = seq_len(4L),
             estimate = plat$estimate, ci_lo = plat$ci_lo, ci_hi = plat$ci_hi,
             supported = plat_supp, ref_est = mono$estimate, is_ref = FALSE,
             stringsAsFactors = FALSE))

# Count the objects rather than trusting the construction above. Four rows per geometry, both
# geometries present, every contrast appearing exactly once in each panel.
#
# THE IDENTITY OF A ROW IS THE LABEL AND THE COMPARATOR TOGETHER, not the label alone. Rows
# three and four share a bold label by design, so a check on labels alone would pass on a frame
# that had lost one of them and duplicated the other.
ROW_ID <- paste(ARCH_NAME[c("parallel", "select_exclude", "select_incorporate",
                            "select_incorporate")],
                paste("versus", sub("^(.)", "\\L\\1",
                                    ARCH_NAME[c("single", "single", "single", "select_exclude")],
                                    perl = TRUE)))
stopifnot(nrow(PLOT) == 8L)
stopifnot(setequal(unique(PLOT$geometry), unname(GEOM)))
for (g in unname(GEOM)) {
  panel_rows <- PLOT[PLOT$geometry == g, ]
  stopifnot("each panel must carry all four architecture contrasts" = nrow(panel_rows) == 4L)
  ids <- paste(panel_rows$label, panel_rows$sublabel)
  stopifnot(setequal(ids, ROW_ID), !anyDuplicated(ids))
}

# ---- INTERPRETATION PHRASES, COMPUTED FROM THE NUMBERS ---------------------------------------
# "Small" is relative to the largest effect the figure displays, so the word means the same thing
# in both panels and carries no absolute threshold smuggled in from outside the data.
SMALL_FRAC <- 0.2
BIGGEST <- max(abs(PLOT$estimate))
is_small <- abs(PLOT$estimate) < SMALL_FRAC * BIGGEST

phrase_for <- function(i) {
  est <- PLOT$estimate[i]; supp <- PLOT$supported[i]
  core <- if (PLOT$is_ref[i]) {
    # The monotone panel is the reference, so it can only report direction and support.
    if (!supp) "not supported" else if (est > 0) "positive, supported" else "negative, supported"
  } else {
    # The plateau panel is read against its own monotone counterpart, which is the whole point of
    # showing two geometries.
    same_sign <- sign(est) == sign(PLOT$ref_est[i])
    if (!supp) {
      if (!same_sign) "reverses, unsupported" else "not supported"
    } else if (!same_sign) {
      "reverses, supported"
    } else if (abs(est) > abs(PLOT$ref_est[i])) {
      "recurs and strengthens"
    } else {
      "recurs"
    }
  }
  if (is_small[i]) paste0("small, ", core) else core
}
PLOT$phrase <- vapply(seq_len(nrow(PLOT)), phrase_for, character(1))
PLOT$numeric <- sprintf("%+.3f  [%+.3f, %+.3f]", PLOT$estimate, PLOT$ci_lo, PLOT$ci_hi)

# ---- COLOUR CARRIES VERDICT, AND NEVER CARRIES IT ALONE --------------------------------------
NAVY <- "#13294B"      # row labels and panel titles
RETAIN <- "#2E6A9F"    # established and retained, a supported gain
CAUTION <- "#B07D00"   # unresolved, an interval that does not exclude zero
LOST <- "#C1521F"      # a supported loss, an architecture that actively costs support
NEUTRAL <- "#5B6670"   # the zero reference and the comparator text

verdict_col <- function(supp, est) {
  if (!supp) CAUTION else if (est > 0) RETAIN else LOST
}
PLOT$col <- vapply(seq_len(nrow(PLOT)),
                   function(i) verdict_col(PLOT$supported[i], PLOT$estimate[i]), character(1))
# Shape repeats the verdict so the figure survives a greyscale print and a colour-blind reader.
PLOT$pch <- ifelse(PLOT$supported, 15L, 1L)
PLOT$lty <- ifelse(PLOT$supported, 1L, 2L)

# ---- NO C INDEX REACHES THE CANVAS -----------------------------------------------------------
# The deck owner's requirement, enforced rather than remembered. Every string this script draws is
# collected and checked, so a future edit that reintroduces a bare contrast index fails the build.
KEY_LINE <- sprintf(
  "Filled marker, adjusted interval excludes zero.   Open marker, it does not.   \"Small\" means under %s of the largest effect shown.",
  paste0("one ", c("half", "third", "quarter", "fifth")[round(1 / SMALL_FRAC) - 1L]))
AXIS_LAB <- "Difference in correct-final-dose support"
DRAWN <- c(PLOT$label, PLOT$sublabel, PLOT$phrase, PLOT$numeric, unname(GEOM), KEY_LINE, AXIS_LAB)
stopifnot("no contrast index may appear in drawn text" = !any(grepl("C[1-4]", DRAWN)))

# ---- GEOMETRY OF THE CANVAS ------------------------------------------------------------------
# Both panels share one x range, computed from the union of every interval plus zero, so a reader
# comparing across panels is comparing lengths rather than scales.
all_bounds <- c(PLOT$ci_lo, PLOT$ci_hi, 0)
pad <- 0.10 * diff(range(all_bounds))
DATA_LO <- min(all_bounds) - pad
DATA_HI <- max(all_bounds) + pad
SPAN <- DATA_HI - DATA_LO
YLIM <- c(0.55, 4.60)
stopifnot(DATA_LO <= min(all_bounds), DATA_HI >= max(all_bounds), DATA_LO <= 0, DATA_HI >= 0)

W <- 11; H <- 6
WIDTHS <- c(1.12, 1, 1)
OMA <- c(2.4, 0.4, 0.4, 0.4)
MAR_LABEL <- c(3.8, 0.4, 4.8, 0.8)
MAR_DATA <- c(3.8, 0.8, 4.8, 0.6)
CEX_NUM <- 0.98
CEX_PHRASE <- 1.10
GAP_FRAC <- 0.05
# Breathing room past the longest string. Without it the text zone is sized to end exactly at the
# panel edge, which puts the fit assertion on a floating-point knife edge and lets the longest
# phrase touch the border.
RIGHT_PAD_FRAC <- 0.04

# A dedicated text zone to the right of the data zone. Anchoring the numbers and the phrase at one
# fixed x rather than beside each marker keeps them in a readable column and makes collision with
# the intervals structurally impossible rather than a thing to check by eye.
#
# THE ZONE IS MEASURED, NOT GUESSED. The longest phrase is rendered at its real cex on a device of
# this figure's exact type, size and layout, and the zone is sized from that measurement. An
# eyeballed fraction is how the first draft clipped "reverses, unsupported" off the right edge of
# the plateau panel, which is the same class of silent content loss this figure replaces.
#
# THE MEASUREMENT DEVICE IS A PNG AND NOT A NULL PDF. Font metrics are a device property, and a pdf
# resolves text against its own font metrics rather than the system font the png rasterises. A
# measurement taken on the wrong device type underestimated the widest phrase and the real-device
# assertion below caught it, which is why the check is kept on both sides.
measure_text_fraction <- function() {
  tmp <- tempfile(fileext = ".png")
  grDevices::png(tmp, width = W, height = H, units = "in", res = 200, bg = "white")
  on.exit({ grDevices::dev.off(); unlink(tmp) })
  par(oma = OMA)
  layout(matrix(1:3, nrow = 1), widths = WIDTHS)
  par(mar = MAR_LABEL); plot.new()
  par(mar = MAR_DATA); plot.new()
  widest <- max(strwidth(PLOT$numeric, units = "inches", cex = CEX_NUM),
                strwidth(PLOT$phrase, units = "inches", cex = CEX_PHRASE))
  widest / par("pin")[1]
}
FRAC_TEXT <- measure_text_fraction()
# The data zone must survive the text zone. If prose ever grows long enough to squeeze the
# intervals below a quarter of the panel, that is a content problem to solve in the prose.
stopifnot("text zone must leave the data zone at least a quarter of the panel" =
            FRAC_TEXT + GAP_FRAC + RIGHT_PAD_FRAC < 0.75)
TOTAL <- SPAN / (1 - FRAC_TEXT - GAP_FRAC - RIGHT_PAD_FRAC)
TEXT_X <- DATA_HI + GAP_FRAC * TOTAL
XLIM <- c(DATA_LO, DATA_LO + TOTAL)
stopifnot(TEXT_X > DATA_HI, XLIM[2] > TEXT_X)

# Row 1 of the family sits at the top of the panel, which is how the audience reads a list.
yof <- function(row) 5 - row

CEX_LABEL <- 1.40
CEX_SUBLAB <- 0.95

label_panel <- function() {
  par(mar = MAR_LABEL)
  plot(NA, xlim = c(0, 1), ylim = YLIM, axes = FALSE, xlab = "", ylab = "")
  first <- PLOT[PLOT$geometry == GEOM[["mono"]], ]
  for (i in seq_len(nrow(first))) {
    y <- yof(first$row[i])
    wrapped <- paste(strwrap(first$label[i], width = 22), collapse = "\n")
    # The comparator is wrapped too. It grew from a short phrase to a full architecture name when
    # the vocabulary was canonicalised, and the longest one no longer fits on one line.
    sub_wrapped <- paste(strwrap(first$sublabel[i], width = 26), collapse = "\n")
    text(1, y + 0.13, wrapped, adj = c(1, 0.5), col = NAVY, font = 2, cex = CEX_LABEL, xpd = NA)
    # Pulled up toward its own label. Sitting equidistant between two rows, the comparator reads
    # as if it belonged to the row beneath it.
    text(1, y - 0.28, sub_wrapped, adj = c(1, 0.5), col = NEUTRAL, cex = CEX_SUBLAB, xpd = NA)
    # THE FIT CHECK RUNS ON THE REAL DEVICE. This text is right-anchored under xpd = NA, so an
    # overlong line silently slides left into the data panel instead of being clipped, which is
    # the same class of invisible content loss the whole figure was built to stop. The panel is
    # one user unit wide, so a width in user units is directly a fraction of the panel.
    widest <- max(strwidth(strsplit(wrapped, "\n")[[1]], cex = CEX_LABEL, font = 2),
                  strwidth(strsplit(sub_wrapped, "\n")[[1]], cex = CEX_SUBLAB))
    stopifnot("row label text must fit inside the label panel" = widest <= 1)
  }
}

data_panel <- function(geom, n_cells) {
  par(mar = MAR_DATA)
  plot(NA, xlim = XLIM, ylim = YLIM, axes = FALSE, xlab = "", ylab = "")
  ticks <- pretty(c(DATA_LO, DATA_HI), n = 4)
  ticks <- ticks[ticks >= DATA_LO & ticks <= DATA_HI]
  axis(1, at = ticks, col = NEUTRAL, col.axis = NEUTRAL, cex.axis = 1.05, lwd = 1.4)
  mtext(AXIS_LAB, side = 1, line = 2.5, adj = 0, at = DATA_LO, cex = 0.82, col = NEUTRAL)
  # The zero line is drawn only across the data zone, so it cannot read as a divider of the text.
  segments(0, YLIM[1] + 0.05, 0, YLIM[2] - 0.30, lty = 3, lwd = 1.6, col = NEUTRAL)

  rows <- PLOT[PLOT$geometry == geom, ]
  stopifnot(nrow(rows) == 4L)
  for (i in seq_len(nrow(rows))) {
    y <- yof(rows$row[i])
    segments(rows$ci_lo[i], y, rows$ci_hi[i], y, col = rows$col[i], lty = rows$lty[i], lwd = 2.6)
    # End caps are drawn explicitly because an interval narrower than the cap width would otherwise
    # be indistinguishable from a bare point, and one of these four is exactly that narrow.
    for (xe in c(rows$ci_lo[i], rows$ci_hi[i])) {
      segments(xe, y - 0.075, xe, y + 0.075, col = rows$col[i], lwd = 2.6)
    }
    points(rows$estimate[i], y, pch = rows$pch[i], col = rows$col[i], bg = "white", cex = 2.0,
           lwd = 2.8)
    text(TEXT_X, y + 0.19, rows$numeric[i], adj = c(0, 0.5), col = NAVY, cex = CEX_NUM, xpd = NA)
    text(TEXT_X, y - 0.24, rows$phrase[i], adj = c(0, 0.5), col = rows$col[i], font = 2,
         cex = CEX_PHRASE, xpd = NA)
    # THE OVERFLOW CHECK RUNS ON THE REAL DEVICE, where the measurement pass cannot be wrong about
    # font metrics. Text running past the panel is exactly the failure that lost the fourth row on
    # the slide this figure replaces, so it stops the build.
    ends <- TEXT_X + c(strwidth(rows$numeric[i], cex = CEX_NUM),
                       strwidth(rows$phrase[i], cex = CEX_PHRASE))
    stopifnot("annotation text must fit inside its panel" = all(ends <= XLIM[2]))
  }
  mtext(geom, side = 3, line = 2.1, adj = 0, at = DATA_LO, font = 2, cex = 1.25, col = NAVY)
  # NOT "CERTIFIED". Both papers retired that word for cells, and it is specifically false here,
  # because Movement III of this same deck discloses that two of the nine monotone cells are
  # unresolved under the corrected verification family. A panel asserting certified cells would
  # contradict a slide four positions later in the same talk.
  mtext(sprintf("%d qualified analysis cases", n_cells), side = 3, line = 0.7, adj = 0, at = DATA_LO,
        cex = 0.95, col = NEUTRAL)
}

draw <- function() {
  op <- par(oma = OMA)
  on.exit(par(op))
  layout(matrix(1:3, nrow = 1), widths = WIDTHS)
  label_panel()
  data_panel(GEOM[["mono"]], raw_mono$n_cells)
  data_panel(GEOM[["plat"]], raw_plat$n_cells)
  mtext(KEY_LINE, side = 1, outer = TRUE, line = 0.9, cex = 0.90, col = NEUTRAL)
}

OUT <- file.path(ROOT, "figures", "conference_deck")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)
grDevices::png(file.path(OUT, "talk_architecture.png"), width = W, height = H, units = "in",
               res = 200, bg = "white")
draw()
grDevices::dev.off()

cat("Talk-mode architecture figure rendered from locked artifacts. No simulation performed.\n")
cat(sprintf("  %d rows drawn, %d per geometry, across %d geometries.\n",
            nrow(PLOT), 4L, length(unique(PLOT$geometry))))
for (g in unname(GEOM)) {
  cat(sprintf("%s\n", g))
  rows <- PLOT[PLOT$geometry == g, ]
  for (i in seq_len(nrow(rows))) {
    # The comparator is printed too. Two rows share a label, so a log line carrying the label
    # alone cannot tell the reader which contrast it reports.
    cat(sprintf("  %-34s %-42s %s  %s\n", rows$label[i], rows$sublabel[i], rows$numeric[i],
                rows$phrase[i]))
  }
}
