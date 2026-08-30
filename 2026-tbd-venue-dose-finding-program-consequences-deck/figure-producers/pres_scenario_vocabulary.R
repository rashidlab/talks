# SCENARIO VOCABULARY FIGURE FOR THE CONFERENCE DECK.
#
# id = "pres_scenario_vocabulary"
#
# WHY THIS EXISTS RATHER THAN A REUSE OF figures/fig_scenario_truths.pdf. The deck's terminology
# slide carried six definitions and 154 words of projected prose. Two of those definitions,
# "clinical scenario" and "correct dose", are things a picture teaches in one second and a
# sentence teaches in fifteen. The manuscript already draws exactly that picture, but it draws it
# for a reader holding the paper, so it carries the constraint vocabulary ("target selection and
# overdose exposure", "safe stopping"), the efficacy floor and the MTD/OBD abbreviations. Every
# one of those is a term the deck has not introduced yet at the point this slide appears, and a
# figure that needs its own glossary costs more than the sentence it replaces.
#
# THE SCIENTIFIC CONTENT IS THEREFORE IDENTICAL AND ONLY THE ANNOTATION LAYER DIFFERS. The
# truths, the admissible sets, the maximum tolerated dose and the utility optimum all come from
# the same frozen definitions through the same production truth functions that
# scripts/fig_scenario_truths.R uses, read rather than retyped, and the labels this figure draws
# are ASSERTED against them below. Nothing here is a schematic and nothing here is a result.
#
# WHAT IS DELIBERATELY DROPPED, AND WHY IT IS NOT A MISREPRESENTATION.
#
#   The efficacy floor line. The admissible set is drawn as shading, and for all three scenarios
#   drawn here that set is determined by the toxicity ceiling alone. That is not assumed, it is
#   ASSERTED at ADMISSIBLE_IS_TOXICITY_DETERMINED below, so a scenario whose efficacy floor
#   actually bit would stop this script rather than be drawn without the line that explains it.
#
#   The constraint strip. It names the operating requirements, which belong to the movement of
#   the talk that introduces them and not to the terminology slide.
#
# WHAT IS RENAMED, AND IT IS A RENAME AND NOT A REDEFINITION. "OBD" is drawn as "correct dose"
# and "MTD" as "highest tolerable", because those are the deck's own words for the same two
# derived quantities. The quantities are `obd_utility_set` and `mtd_set` exactly as the
# manuscript figure marks them.

ROOT <- local({
  env <- Sys.getenv("BATOND_PAPER_REPO", "")
  root <- if (nzchar(trimws(env))) path.expand(trimws(env)) else {
    d <- normalizePath(getwd(), winslash = "/", mustWork = FALSE)
    repeat {
      if (file.exists(file.path(d, "globals.yml"))) break
      p <- dirname(d)
      if (identical(p, d)) stop("pres_scenario_vocabulary: no `globals.yml` at or above `",
                                getwd(), "`. Set BATOND_PAPER_REPO or run from the repository.",
                                call. = FALSE)
      d <- p
    }
    d
  }
  normalizePath(root, winslash = "/", mustWork = TRUE)
})
setwd(ROOT)
suppressMessages(pkgload::load_all(file.path("~", "research", "BATOND"), quiet = TRUE))

# THE SAME CONSTRUCTION PHASE D USES, extracted from it rather than copied, exactly as
# scripts/fig_scenario_truths.R does it. The prefix of the Phase D script up to its first
# heartbeat is the scenario and truth definition and nothing else.
SRC <- readLines("scripts/phase_d_families.R")
END <- grep('^beat\\("starting"\\)$', SRC)
stopifnot(length(END) == 1L)
defs <- tempfile(fileext = ".R"); writeLines(SRC[seq_len(END - 1L)], defs); source(defs)

truths <- mk_truths()
PHI <- truths[[1]]$phi

# THE LABELS ARE ASSERTED, NOT TRUSTED. Identical to the manuscript figure's guard. If a frozen
# scenario ever moves, this stops rather than drawing a slide that disagrees with the paper.
stopifnot(identical(truths$OBD_plateau$mtd_set, 3L),
          identical(truths$OBD_plateau$obd_utility_set, 2L),
          identical(truths$OBD_monotone$mtd_set, 3L),
          identical(truths$OBD_monotone$obd_utility_set, 3L),
          length(truths$S0_toxic$mtd_set) == 0L,
          length(truths$S0_toxic$admissible_set) == 0L)

ORDER <- c("OBD_plateau", "OBD_monotone", "S0_toxic")

# ADMISSIBLE_IS_TOXICITY_DETERMINED. This is what licenses dropping the efficacy floor line.
# Every dose inside the shaded region and every dose outside it is placed there by the toxicity
# ceiling alone, for each of the three scenarios this figure draws.
for (nm in ORDER) {
  t <- truths[[nm]]
  by_tox <- which(t$p_tox <= PHI)
  stopifnot("the shaded admissible set is not toxicity-determined for this scenario, so the
             efficacy floor cannot be dropped from the drawing" =
              identical(as.integer(t$admissible_set), as.integer(by_tox)))
}

TITLE <- c(OBD_plateau  = "efficacy levels off",
           OBD_monotone = "efficacy keeps rising",
           S0_toxic     = "no acceptable dose")
SUB   <- c(OBD_plateau  = "the correct dose is not the highest tolerable one",
           OBD_monotone = "the correct dose is the highest tolerable one",
           S0_toxic     = "stopping with no dose is the correct action")

INK <- "#13294B"; ACCENT <- "#4B9CD3"; SHADE <- "#EDF2F7"

panel <- function(nm) {
  t <- truths[[nm]]
  D <- length(t$p_tox); x <- seq_len(D)
  plot(NA, xlim = c(0.6, D + 0.4), ylim = c(0, 1.0), xaxt = "n", yaxt = "n",
       xlab = "", ylab = "", bty = "n")
  axis(1, at = x, cex.axis = 1.25, lwd = 0, lwd.ticks = 1, col.axis = INK, padj = -0.3)
  axis(2, at = c(0, 0.5, 1), cex.axis = 1.25, las = 1, lwd = 0, lwd.ticks = 1, col.axis = INK)
  mtext("dose level", side = 1, line = 2.5, cex = 0.92, col = INK)

  adm <- t$admissible_set
  if (length(adm)) rect(adm - 0.4, 0, adm + 0.4, 1.0, col = SHADE, border = NA)

  abline(h = PHI, lty = 2, lwd = 1.6, col = "grey45")
  # LABELLED ONCE, ON THE LEFT PANEL ONLY. The line is the same quantity in all three panels, and
  # the only region guaranteed clear of both curves in every panel does not exist, so the label
  # goes where it is provably clear rather than in three places where it collides. Under the line
  # at the right of panel A is empty, since that panel's toxicity curve sits above the ceiling
  # from dose 3 on and its efficacy curve never comes near it.
  if (identical(nm, ORDER[1])) {
    stopifnot("the toxicity-ceiling label would collide with a drawn curve" =
                all(t$p_tox[4:5] > PHI), all(t$p_eff[4:5] > PHI))
    text(D + 0.4, PHI - 0.055, labels = "toxicity ceiling", adj = c(1, 1), cex = 1.05,
         col = "grey35")
  }

  lines(x, t$p_tox, lwd = 2.6, type = "b", pch = 19, cex = 1.5, col = INK)
  if (!is.null(t$p_eff)) {
    lines(x, t$p_eff, lwd = 2.6, lty = 2, type = "b", pch = 1, cex = 1.5, col = INK)
  }

  if (length(t$mtd_set)) {
    points(t$mtd_set, t$p_tox[t$mtd_set], pch = 0, cex = 3.0, lwd = 2.2, col = INK)
    text(t$mtd_set, t$p_tox[t$mtd_set], labels = "highest\ntolerable", pos = 1, cex = 1.0,
         offset = 1.1, col = INK)
  }
  if (length(t$obd_utility_set)) {
    points(t$obd_utility_set, t$p_eff[t$obd_utility_set], pch = 5, cex = 3.2, lwd = 2.6,
           col = ACCENT)
    text(t$obd_utility_set, t$p_eff[t$obd_utility_set], labels = "correct dose", pos = 3,
         cex = 1.15, offset = 1.1, col = ACCENT, font = 2)
  }
  if (!length(t$admissible_set)) {
    # The upper-left corner, which the rising toxicity curve has not reached yet.
    stopifnot("the no-acceptable-dose annotation would collide with the toxicity curve" =
                t$p_tox[2] < 0.70)
    text(0.65, 0.99, labels = "no dose is\nacceptable", cex = 1.15, col = ACCENT, font = 2,
         adj = c(0, 1))
  }
  mtext(TITLE[[nm]], side = 3, line = 1.75, adj = 0, font = 2, cex = 1.2, col = INK)
  mtext(SUB[[nm]],   side = 3, line = 0.5,  adj = 0, cex = 0.98, col = "grey35")
}

draw <- function() {
  op <- par(mfrow = c(1, 3), mar = c(4.2, 3.0, 4.0, 1.4), mgp = c(2.5, 0.6, 0),
            oma = c(0.2, 1.6, 0.2, 0.2), family = "sans")
  on.exit(par(op))
  for (nm in ORDER) panel(nm)
  mtext("true probability", side = 2, outer = TRUE, line = 0.1, cex = 0.92, col = INK)
}

OUT <- file.path("figures", "conference_deck")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)
grDevices::png(file.path(OUT, "pres_scenario_vocabulary.png"),
               width = 12.0, height = 4.0, units = "in", res = 220, type = "cairo",
               bg = "white")
draw(); grDevices::dev.off()

cat("Scenario vocabulary figure written to ", OUT, "/pres_scenario_vocabulary.png\n", sep = "")
cat("Drawn from the frozen definitions through the production truth functions. No simulation.\n")
for (nm in ORDER) {
  t <- truths[[nm]]
  cat(sprintf("  %-13s admissible {%s}  highest tolerable {%s}  correct dose {%s}\n", nm,
              paste(t$admissible_set, collapse = ","),
              paste(t$mtd_set, collapse = ","),
              paste(t$obd_utility_set, collapse = ",")))
}
