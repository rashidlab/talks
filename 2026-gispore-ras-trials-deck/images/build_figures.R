# Build the four data-plot figures for the GI SPORE talk.
#
# These are pedagogical illustrations, not analyses of real data. The KM curve
# in particular uses simulated event times that reproduce the published
# RASolute 302 headline numbers (median OS 13.2 vs 6.7 mo, HR ~0.40) for
# visual purposes only. A "Schematic" annotation is included on the slide.
#
# Run from this directory:
#   Rscript build_figures.R
#
# Outputs written next to this script: rasolute302-km.svg,
# dose-response-trio.svg, uboin-utility-heatmap.svg, baton-acquisition-cartoon.svg

# Lab palette (kept inline so the script is self-contained; tokens elsewhere
# in the deck live in custom.css).
PAL <- list(
  navy          = "#13294B",
  carolina      = "#4B9CD3",
  carolina_deep = "#2E6A9F",
  graphite      = "#5B6670",
  fog           = "#F4F6F8",
  mist          = "#E6EAEF",
  ink           = "#1A202C",
  alert         = "#C75050",   # for the "MTD region" hatch
  warn          = "#D9B546",
  good          = "#5CA77C"
)

# ---------------------------------------------------------------------------
# Figure 1 — RASolute 302 schematic KM curve
# ---------------------------------------------------------------------------
# Construct two exponential-ish survival curves with the right medians.
# median = log(2) / lambda  =>  lambda = log(2) / median
draw_km <- function() {
  t <- seq(0, 24, by = 0.1)
  S_chemo <- exp(-log(2) / 6.7 * t)
  S_dara  <- exp(-log(2) / 13.2 * t)

  svg("rasolute302-km.svg", width = 6, height = 4.5)
  op <- par(mar = c(4.2, 4.3, 1.5, 0.8), family = "sans",
            col.axis = PAL$graphite, col.lab = PAL$navy,
            fg = PAL$graphite, cex.axis = 0.9, cex.lab = 1.0)

  plot(NA, xlim = c(0, 24), ylim = c(0, 1), axes = FALSE,
       xlab = "Months from randomization",
       ylab = "Overall survival probability")
  axis(1, at = seq(0, 24, by = 6), col = PAL$mist, col.ticks = PAL$graphite,
       lwd = 1)
  axis(2, at = seq(0, 1, by = 0.25), las = 1, col = PAL$mist,
       col.ticks = PAL$graphite, lwd = 1)
  abline(h = seq(0, 1, by = 0.25), col = PAL$mist, lwd = 0.5)

  # Median guides
  segments(0, 0.5, 13.2, 0.5, col = PAL$mist, lty = 3)
  segments(6.7, 0, 6.7, 0.5,  col = PAL$mist, lty = 3)
  segments(13.2, 0, 13.2, 0.5, col = PAL$mist, lty = 3)

  lines(t, S_chemo, col = PAL$graphite,      lwd = 3)
  lines(t, S_dara,  col = PAL$carolina_deep, lwd = 3)

  # Median annotations
  text(6.7,  0.04, "6.7 mo",  col = PAL$graphite,      cex = 0.75, adj = c(-0.05, 0))
  text(13.2, 0.04, "13.2 mo", col = PAL$carolina_deep, cex = 0.75, adj = c(-0.05, 0))

  # Legend
  legend("topright", bty = "n", cex = 0.85, text.col = PAL$ink,
         legend = c("Daraxonrasib (n ~ 160)", "Investigator's choice (n ~ 160)"),
         col = c(PAL$carolina_deep, PAL$graphite),
         lwd = 3, seg.len = 2)

  # HR annotation
  text(18, 0.62, expression(HR == 0.40), col = PAL$navy, cex = 1.0)
  text(18, 0.55, "p < 0.0001", col = PAL$navy, cex = 0.85)

  # Schematic disclaimer (top-left, out of the way of median annotations)
  text(0.2, 0.95, "Schematic — pre-publication illustration",
       col = PAL$graphite, cex = 0.65, font = 3, adj = c(0, 0))

  par(op)
  dev.off()
  invisible(NULL)
}

# ---------------------------------------------------------------------------
# Figure 2 — Dose-response trio
# ---------------------------------------------------------------------------
draw_dose_response_trio <- function() {
  x <- seq(0, 10, length.out = 200)

  # Chemo: monotone in both
  chemo_eff <- 0.05 + 0.085 * x
  chemo_tox <- 0.02 + 0.092 * x

  # Targeted: efficacy plateaus, toxicity climbs
  targ_eff  <- 0.85 / (1 + exp(-1.6 * (x - 2.0)))
  targ_tox  <- 0.05 + 0.085 * x

  # IO / CAR-T: efficacy umbrella, toxicity climbs
  io_eff    <- 0.92 * exp(-((x - 4.5) / 2.4)^2)
  io_tox    <- 0.05 + 0.085 * x

  svg("dose-response-trio.svg", width = 9, height = 3.3)
  op <- par(mfrow = c(1, 3), mar = c(3.5, 3.5, 2.2, 0.8), family = "sans",
            col.axis = PAL$graphite, col.lab = PAL$navy,
            fg = PAL$graphite, cex.axis = 0.85, cex.lab = 0.95,
            cex.main = 1.05, col.main = PAL$navy)

  panel <- function(eff, tox, title) {
    plot(NA, xlim = c(0, 10), ylim = c(0, 1), axes = FALSE,
         xlab = "Dose", ylab = "Probability", main = title)
    axis(1, at = c(0, 5, 10), labels = c("low", "mid", "high"),
         col = PAL$mist, col.ticks = PAL$graphite, lwd = 1)
    axis(2, at = c(0, 0.5, 1), las = 1, col = PAL$mist,
         col.ticks = PAL$graphite, lwd = 1)
    lines(x, eff, col = PAL$carolina_deep, lwd = 3)
    lines(x, tox, col = PAL$alert,          lwd = 3, lty = 2)
  }

  panel(chemo_eff, chemo_tox, "Cytotoxic chemo")
  legend("topleft", bty = "n", cex = 0.85, text.col = PAL$ink,
         legend = c("Efficacy", "Toxicity"),
         col = c(PAL$carolina_deep, PAL$alert), lwd = 3, lty = c(1, 2),
         seg.len = 2.5)

  panel(targ_eff, targ_tox, "Targeted agent")
  panel(io_eff,   io_tox,   "IO / CAR-T / bispecific")

  par(op)
  dev.off()
  invisible(NULL)
}

# ---------------------------------------------------------------------------
# Figure 3 — U-BOIN utility heatmap
# ---------------------------------------------------------------------------
# Plot the dose × (tox, eff) plane with a utility heatmap. Toxicity probability
# on x-axis, efficacy probability on y-axis. Mark admissibility lines and OBD
# region. Show six candidate dose levels as labeled points.
draw_uboin_heatmap <- function() {
  tox <- seq(0, 0.5, length.out = 80)
  eff <- seq(0, 0.7, length.out = 80)
  grid <- expand.grid(tox = tox, eff = eff)
  # Linear utility: u = w_eff * eff - w_tox * tox  (canonical U-BOIN form)
  grid$u <- 1.0 * grid$eff - 1.2 * grid$tox

  # 2D matrix for image()
  U <- matrix(grid$u, nrow = length(tox), ncol = length(eff))

  svg("uboin-utility-heatmap.svg", width = 6.5, height = 4.3)
  op <- par(mar = c(4.2, 4.3, 0.8, 0.8), family = "sans",
            col.axis = PAL$graphite, col.lab = PAL$navy,
            fg = PAL$graphite, cex.axis = 0.85, cex.lab = 0.95)

  # Build the colorRampPalette ranging from fog (low utility) to carolina_deep
  # (high utility) — keeps the figure on-palette for the deck.
  pal_n <- 100
  ramp <- colorRampPalette(c("#F4F6F8", "#D6E5F2", "#9DC4E3", "#4B9CD3", "#2E6A9F"))
  image(tox, eff, U, col = ramp(pal_n), axes = FALSE,
        xlab = "Probability of Grade ≥3 toxicity",
        ylab = "Probability of response")
  axis(1, at = seq(0, 0.5, by = 0.1), col = PAL$mist,
       col.ticks = PAL$graphite, lwd = 1)
  axis(2, at = seq(0, 0.7, by = 0.1), las = 1, col = PAL$mist,
       col.ticks = PAL$graphite, lwd = 1)

  # Admissibility lines: toxicity ≤ 0.25 and efficacy ≥ 0.20
  abline(v = 0.25, col = PAL$alert, lwd = 2, lty = 2)
  abline(h = 0.20, col = PAL$good,  lwd = 2, lty = 2)
  text(0.255, 0.68, "Tox limit (≤25%)", col = PAL$alert, cex = 0.75, adj = c(0, 1))
  text(0.49, 0.205, "Eff min (≥20%)",   col = PAL$good,  cex = 0.75, adj = c(1, 0))

  # Six candidate dose levels (illustrative). Toxicity rises with dose,
  # efficacy peaks around dose 3-4 then falls under combo toxicity.
  doses <- data.frame(
    label = c("d1", "d2", "d3", "d4", "d5", "d6"),
    tox   = c(0.05, 0.10, 0.18, 0.24, 0.32, 0.42),
    eff   = c(0.08, 0.22, 0.36, 0.48, 0.40, 0.30)
  )
  points(doses$tox, doses$eff, pch = 21, bg = "white",
         col = PAL$navy, cex = 1.6, lwd = 2)
  text(doses$tox, doses$eff, doses$label, col = PAL$navy,
       cex = 0.7, font = 2)

  # OBD region: d3-d4 (admissible AND high utility)
  rect(0.13, 0.30, 0.27, 0.53, border = PAL$navy, lwd = 2, lty = 3)
  text(0.20, 0.55, "OBD region", col = PAL$navy, cex = 0.78, font = 2)

  par(op)
  dev.off()
  invisible(NULL)
}

# ---------------------------------------------------------------------------
# Figure 4 — BATON acquisition surface
# ---------------------------------------------------------------------------
# 2D constrained optimization landscape. Objective function = expected sample
# size (to minimize). Two constraints carve out a feasible region. BATON's
# sequential evaluations (numbered) converge to the constrained optimum.
draw_baton_surface <- function() {
  # Design parameters: p1 (efficacy threshold), p2 (futility margin)
  p1 <- seq(0, 1, length.out = 80)
  p2 <- seq(0, 1, length.out = 80)
  grid <- expand.grid(p1 = p1, p2 = p2)
  # Objective: bowl-shaped, optimum near (0.7, 0.4)
  grid$obj <- 60 + 40 * ((grid$p1 - 0.7)^2 + (grid$p2 - 0.4)^2)
  Obj <- matrix(grid$obj, nrow = length(p1), ncol = length(p2))

  svg("baton-acquisition-cartoon.svg", width = 6, height = 4.5)
  op <- par(mar = c(4.2, 4.3, 0.8, 0.8), family = "sans",
            col.axis = PAL$graphite, col.lab = PAL$navy,
            fg = PAL$graphite, cex.axis = 0.85, cex.lab = 0.95)

  ramp <- colorRampPalette(c("#2E6A9F", "#9DC4E3", "#F4F6F8", "#FCEAE7", "#C75050"))
  image(p1, p2, Obj, col = ramp(100), axes = FALSE,
        xlab = "Design parameter 1",
        ylab = "Design parameter 2")
  axis(1, at = seq(0, 1, by = 0.2), col = PAL$mist,
       col.ticks = PAL$graphite, lwd = 1)
  axis(2, at = seq(0, 1, by = 0.2), las = 1, col = PAL$mist,
       col.ticks = PAL$graphite, lwd = 1)

  # Constraint 1: Type I error <= alpha (left of curve)
  c1_x <- seq(0, 1, length.out = 100)
  c1_y <- 0.18 + 0.55 * c1_x
  lines(c1_x, c1_y, col = PAL$alert, lwd = 2, lty = 2)
  text(0.05, 0.21, "Type I ≤ α", col = PAL$alert, cex = 0.72, adj = c(0, 0))

  # Constraint 2: Power >= 1 - beta (right of curve)
  c2_x <- seq(0, 1, length.out = 100)
  c2_y <- 0.9 - 0.55 * c2_x
  lines(c2_x, c2_y, col = PAL$good, lwd = 2, lty = 2)
  text(0.95, 0.40, "Power ≥ 0.80", col = PAL$good, cex = 0.72, adj = c(1, 0))

  # Feasible region polygon (between the two constraints)
  feas_x <- c(seq(0.0, 1.0, length.out = 50),
              seq(1.0, 0.0, length.out = 50))
  feas_y <- c(0.18 + 0.55 * seq(0.0, 1.0, length.out = 50),
              0.9  - 0.55 * seq(1.0, 0.0, length.out = 50))
  feas_y <- pmax(0, pmin(1, feas_y))
  polygon(feas_x, feas_y, col = adjustcolor(PAL$carolina, alpha.f = 0.18),
          border = NA)
  text(0.55, 0.55, "feasible", col = PAL$navy, cex = 0.78, font = 3)

  # BATON sequential evaluations — converging trajectory
  pts <- data.frame(
    x = c(0.15, 0.85, 0.30, 0.65, 0.55, 0.72, 0.68, 0.70),
    y = c(0.85, 0.20, 0.55, 0.75, 0.32, 0.45, 0.38, 0.40),
    n = 1:8
  )
  for (i in seq_len(nrow(pts) - 1)) {
    segments(pts$x[i], pts$y[i], pts$x[i+1], pts$y[i+1],
             col = PAL$navy, lwd = 1, lty = 3)
  }
  points(pts$x, pts$y, pch = 21, bg = "white", col = PAL$navy,
         cex = 1.5, lwd = 1.6)
  text(pts$x, pts$y, pts$n, col = PAL$navy, cex = 0.65, font = 2)

  # Final optimum (star at point 8)
  points(0.70, 0.40, pch = 8, col = PAL$navy, cex = 2.2, lwd = 2.5)

  par(op)
  dev.off()
  invisible(NULL)
}

# ---------------------------------------------------------------------------
# Build all four
# ---------------------------------------------------------------------------
draw_km()
draw_dose_response_trio()
draw_uboin_heatmap()
draw_baton_surface()

cat("Built:\n")
cat(" - rasolute302-km.svg\n")
cat(" - dose-response-trio.svg\n")
cat(" - uboin-utility-heatmap.svg\n")
cat(" - baton-acquisition-cartoon.svg\n")
