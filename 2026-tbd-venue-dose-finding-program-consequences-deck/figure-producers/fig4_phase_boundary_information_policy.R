# Figure 4, ARPA-H statistics meeting: "A phase boundary is an information policy"
#
# Left half: four matched conceptual schematics (STATUS$conceptual) contrasting how a
# phase I -> phase II architecture treats evidence at the selection/confirmation seam:
# Single, Parallel, Hard boundary, Permeable boundary.
#
# Right half: empirical forest plot (STATUS$supported) of contrasts C1-C4 from
# results/exp8_q5_primary.rds, plus a graphically separated descriptive resource callout
# (STATUS$descriptive) built from the same object's $costs table.
#
# Read-only w.r.t. results/. Writes only figures/arpa_stats_meeting/fig4_*.{pdf,svg,png}.

suppressPackageStartupMessages({
  library(ggplot2)
  library(grid)
  library(cowplot)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

FIG_ID <- "fig4_phase_boundary_information_policy"

# =================================================================================================
# 1. LOAD AND VERIFY THE EMPIRICAL OBJECT
# =================================================================================================

art_path <- file.path(ROOT, "results", "exp8_q5_primary.rds")
stopifnot(file.exists(art_path))
obj <- readRDS(art_path)

stopifnot(all(c("contrasts", "costs", "truth_key") %in% names(obj)))

contrasts <- obj$contrasts
stopifnot(all(c("contrast", "A", "B", "reads", "estimate", "se", "z", "ci_lo", "ci_hi", "supported") %in%
              names(contrasts)))
stopifnot(nrow(contrasts) == 4)
stopifnot(all(c("C1", "C2", "C3", "C4") %in% contrasts$contrast))

# Re-derive against the brief's expected values (tolerance 5e-4 on estimate/ci bounds).
expected <- data.frame(
  contrast = c("C1", "C2", "C3", "C4"),
  estimate = c(0.1073, 0.0112, 0.0208, 0.0096),
  ci_lo    = c(0.1012, 0.0061, 0.0156, 0.0093),
  ci_hi    = c(0.1134, 0.0164, 0.0261, 0.0100)
)
chk <- merge(contrasts[, c("contrast", "estimate", "ci_lo", "ci_hi")], expected, by = "contrast",
             suffixes = c("_obs", "_exp"))
mismatch <- with(chk,
  abs(estimate_obs - estimate_exp) > 5e-4 |
  abs(ci_lo_obs - ci_lo_exp) > 5e-4 |
  abs(ci_hi_obs - ci_hi_exp) > 5e-4
)
if (any(mismatch)) {
  print(chk[mismatch, ])
  stop("FIG4: contrasts C1-C4 do not match the brief's expected values within tolerance. Stopping per instructions.")
}

costs <- obj$costs
stopifnot(all(c("arch", "n_cells", "e_n_ii", "e_n_program", "t_months") %in% names(costs)))
costs_sub <- costs[costs$arch %in% c("select_exclude", "select_incorporate"), ]
stopifnot(nrow(costs_sub) == 2)

e_n_ii_excl <- costs_sub$e_n_ii[costs_sub$arch == "select_exclude"]
e_n_ii_inc  <- costs_sub$e_n_ii[costs_sub$arch == "select_incorporate"]
t_mo_excl   <- costs_sub$t_months[costs_sub$arch == "select_exclude"]
t_mo_inc    <- costs_sub$t_months[costs_sub$arch == "select_incorporate"]

delta_n  <- e_n_ii_excl - e_n_ii_inc
delta_t  <- t_mo_excl - t_mo_inc

stopifnot(abs(e_n_ii_inc - 54.03) < 0.1)
stopifnot(abs(e_n_ii_excl - 58.96) < 0.1)
stopifnot(abs(delta_n - 4.9) < 0.15)
stopifnot(abs(t_mo_inc - 36.65) < 0.1)
stopifnot(abs(t_mo_excl - 39.12) < 0.1)
stopifnot(abs(delta_t - 2.5) < 0.15)

truth_key <- obj$truth_key
stopifnot(identical(truth_key, "application|OBD_monotone"))

verify_banner(
  figure_id = FIG_ID,
  source_artifact = "results/exp8_q5_primary.rds",
  producer = "fig4_phase_boundary_information_policy.R",
  fields = c("contrasts$estimate/ci_lo/ci_hi", "costs$e_n_ii/t_months", "truth_key"),
  expected = "C1..C4 per brief; e_n_ii excl 58.96 / inc 54.03 (delta 4.9); t_months excl 39.12 / inc 36.65 (delta 2.5); truth_key application|OBD_monotone",
  observed = sprintf(
    "C1=%.4f[%.4f,%.4f] C2=%.4f[%.4f,%.4f] C3=%.4f[%.4f,%.4f] C4=%.4f[%.4f,%.4f]; e_n_ii excl=%.4f inc=%.4f (d=%.2f); t_months excl=%.4f inc=%.4f (d=%.2f); truth_key=%s",
    contrasts$estimate[contrasts$contrast == "C1"], contrasts$ci_lo[contrasts$contrast == "C1"], contrasts$ci_hi[contrasts$contrast == "C1"],
    contrasts$estimate[contrasts$contrast == "C2"], contrasts$ci_lo[contrasts$contrast == "C2"], contrasts$ci_hi[contrasts$contrast == "C2"],
    contrasts$estimate[contrasts$contrast == "C3"], contrasts$ci_lo[contrasts$contrast == "C3"], contrasts$ci_hi[contrasts$contrast == "C3"],
    contrasts$estimate[contrasts$contrast == "C4"], contrasts$ci_lo[contrasts$contrast == "C4"], contrasts$ci_hi[contrasts$contrast == "C4"],
    e_n_ii_excl, e_n_ii_inc, delta_n, t_mo_excl, t_mo_inc, delta_t, truth_key
  )
)

# =================================================================================================
# 2. LEFT HALF: FOUR MATCHED CONCEPTUAL SCHEMATICS (STATUS$conceptual)
# =================================================================================================
# Shared layout skeleton across all four panels:
#   x in [0, 1], selection stage occupies x in [0, 0.42], the seam/boundary sits at x = 0.5,
#   confirmation stage occupies x in [0.58, 1]. Every panel draws the same node shapes at the
#   same x-positions; only the line/boundary treatment differs. This is what makes the four
#   comparable "at a glance" rather than by close reading.

SEL_X0   <- 0.02
SEL_X1   <- 0.42
SEAM_X   <- 0.50
CONF_X0  <- 0.58
CONF_X1  <- 0.98

schematic_base <- function(title_txt) {
  ggplot() +
    coord_cartesian(xlim = c(0, 1), ylim = c(0, 1), expand = FALSE, clip = "off") +
    theme_void(base_size = 20) +
    theme(
      plot.title = element_text(size = rel(0.62), face = "bold", color = PAL$ink,
                                 hjust = 0.5, margin = margin(t = 4, b = 2)),
      plot.margin = margin(2, 4, 2, 4)
    ) +
    labs(title = title_txt)
}

# Node dot for a stage anchor (selection or confirmation cluster origin/target).
node_layer <- function(x, y, open = FALSE) {
  if (open) {
    list(
      geom_point(aes(x = x, y = y), shape = 21, size = 3.6, stroke = 1.3,
                 fill = PAL$paper, color = PAL$accent)
    )
  } else {
    list(
      geom_point(aes(x = x, y = y), shape = 21, size = 3.6, stroke = 1.1,
                 fill = PAL$ink, color = PAL$ink)
    )
  }
}

# Dead-end tick mark: a short perpendicular bar at (x, y), signalling "alternative abandoned".
deadend_layer <- function(x, y) {
  list(
    geom_segment(aes(x = x, xend = x, y = y - 0.055, yend = y + 0.055),
                 color = PAL$discarded, linewidth = 1.3, lineend = "butt")
  )
}

CONCEPT_ALPHA <- STATUS$conceptual$alpha  # 0.70, applied to all schematic strokes

# --- Panel 1: SINGLE ---------------------------------------------------------------------------
# Selection stage -> ONE line continues (retained, solid) into confirmation at y = 0.65.
# The other candidate dose (y = 0.35) dead-ends exactly at the selection boundary (x = SEL_X1).
p_single <- schematic_base("Commit to\none dose") +
  # selection-stage stems from a common origin
  geom_segment(aes(x = SEL_X0, xend = SEL_X1, y = 0.5, yend = 0.65),
               color = PAL$retained, linewidth = 1.1, alpha = CONCEPT_ALPHA) +
  geom_segment(aes(x = SEL_X0, xend = SEL_X1, y = 0.5, yend = 0.35),
               color = PAL$discarded, linewidth = 1.1, alpha = CONCEPT_ALPHA) +
  # surviving dose continues, solid retained, straight through the seam into confirmation
  geom_segment(aes(x = SEL_X1, xend = CONF_X1, y = 0.65, yend = 0.65),
               color = PAL$retained, linewidth = 1.5, alpha = CONCEPT_ALPHA) +
  # abandoned dose dead-ends at the selection boundary
  deadend_layer(SEL_X1, 0.35) +
  node_layer(SEL_X0, 0.5) +
  node_layer(CONF_X1, 0.65) +
  annotate("text", x = SEL_X0 + (SEL_X1 - SEL_X0) / 2, y = 0.92, label = "selection",
           size = 3.1, color = "#5A5A5A") +
  annotate("text", x = CONF_X0 + (CONF_X1 - CONF_X0) / 2, y = 0.92, label = "confirmation",
           size = 3.1, color = "#5A5A5A")

# --- Panel 2: PARALLEL --------------------------------------------------------------------------
# Selection stage -> TWO lines continue side by side into confirmation (both retained, solid).
# No dead-end mark at the boundary.
p_parallel <- schematic_base("Confirm\nboth doses") +
  geom_segment(aes(x = SEL_X0, xend = SEL_X1, y = 0.5, yend = 0.65),
               color = PAL$retained, linewidth = 1.1, alpha = CONCEPT_ALPHA) +
  geom_segment(aes(x = SEL_X0, xend = SEL_X1, y = 0.5, yend = 0.35),
               color = PAL$retained, linewidth = 1.1, alpha = CONCEPT_ALPHA) +
  geom_segment(aes(x = SEL_X1, xend = CONF_X1, y = 0.65, yend = 0.65),
               color = PAL$retained, linewidth = 1.5, alpha = CONCEPT_ALPHA) +
  geom_segment(aes(x = SEL_X1, xend = CONF_X1, y = 0.35, yend = 0.35),
               color = PAL$retained, linewidth = 1.5, alpha = CONCEPT_ALPHA) +
  node_layer(SEL_X0, 0.5) +
  node_layer(CONF_X1, 0.65) +
  node_layer(CONF_X1, 0.35) +
  annotate("text", x = SEL_X0 + (SEL_X1 - SEL_X0) / 2, y = 0.92, label = "selection",
           size = 3.1, color = "#5A5A5A") +
  annotate("text", x = CONF_X0 + (CONF_X1 - CONF_X0) / 2, y = 0.92, label = "confirmation",
           size = 3.1, color = "#5A5A5A")

# --- Panel 3: HARD BOUNDARY ---------------------------------------------------------------------
# A vertical seam line at SEAM_X. The surviving dose's evidence line terminates/fades exactly at
# the seam (discarded grammar), and a NEW disconnected line begins on the confirmation side
# (fresh-evidence-required grammar), even though it is nominally "the same dose" carried forward.
seam_df <- data.frame(x = SEAM_X, y1 = 0.08, y2 = 0.92)
fade_df <- data.frame(
  x = seq(SEL_X1, SEAM_X, length.out = 30),
  y = 0.65
)
fade_df$a <- seq(1, 0.05, length.out = 30) * CONCEPT_ALPHA

p_hard <- schematic_base("Select one, then\nfresh confirmation") +
  geom_segment(aes(x = SEL_X0, xend = SEL_X1, y = 0.5, yend = 0.65),
               color = PAL$retained, linewidth = 1.1, alpha = CONCEPT_ALPHA) +
  geom_segment(aes(x = SEL_X0, xend = SEL_X1, y = 0.5, yend = 0.35),
               color = PAL$discarded, linewidth = 1.1, alpha = CONCEPT_ALPHA) +
  deadend_layer(SEL_X1, 0.35) +
  # fading segment: evidence terminates at the seam, does not cross it
  geom_line(data = fade_df, aes(x = x, y = y, alpha = a, group = 1),
            color = PAL$discarded, linewidth = 1.5) +
  scale_alpha_identity() +
  # the vertical boundary itself
  geom_segment(data = seam_df, aes(x = x, xend = x, y = y1, yend = y2),
               color = PAL$ink, linewidth = 0.9, linetype = "22") +
  # fresh, disconnected line begins on the confirmation side
  geom_segment(aes(x = SEAM_X + 0.02, xend = CONF_X1, y = 0.65, yend = 0.65),
               color = PAL$retained, linewidth = 1.5, alpha = CONCEPT_ALPHA) +
  node_layer(SEL_X0, 0.5) +
  node_layer(SEAM_X + 0.02, 0.65, open = TRUE) +
  node_layer(CONF_X1, 0.65) +
  annotate("text", x = SEL_X0 + (SEL_X1 - SEL_X0) / 2, y = 0.92, label = "selection",
           size = 3.1, color = "#5A5A5A") +
  annotate("text", x = CONF_X0 + (CONF_X1 - CONF_X0) / 2, y = 0.98, label = "confirmation",
           size = 3.1, color = "#5A5A5A")

# --- Panel 4: PERMEABLE BOUNDARY ------------------------------------------------------------------
# Same vertical seam, but the surviving dose's evidence line passes THROUGH it continuously
# (retained, solid, uninterrupted).
p_permeable <- schematic_base("Select one, then\nreuse evidence") +
  geom_segment(aes(x = SEL_X0, xend = SEL_X1, y = 0.5, yend = 0.65),
               color = PAL$retained, linewidth = 1.1, alpha = CONCEPT_ALPHA) +
  geom_segment(aes(x = SEL_X0, xend = SEL_X1, y = 0.5, yend = 0.35),
               color = PAL$discarded, linewidth = 1.1, alpha = CONCEPT_ALPHA) +
  deadend_layer(SEL_X1, 0.35) +
  # uninterrupted line, crosses the seam without termination or restart
  geom_segment(aes(x = SEL_X1, xend = CONF_X1, y = 0.65, yend = 0.65),
               color = PAL$retained, linewidth = 1.5, alpha = CONCEPT_ALPHA) +
  geom_segment(data = seam_df, aes(x = x, xend = x, y = y1, yend = y2),
               color = PAL$ink, linewidth = 0.9, linetype = "22") +
  node_layer(SEL_X0, 0.5) +
  node_layer(CONF_X1, 0.65) +
  annotate("text", x = SEL_X0 + (SEL_X1 - SEL_X0) / 2, y = 0.92, label = "selection",
           size = 3.1, color = "#5A5A5A") +
  annotate("text", x = CONF_X0 + (CONF_X1 - CONF_X0) / 2, y = 0.98, label = "confirmation",
           size = 3.1, color = "#5A5A5A")

conceptual_tag <- ggplot() +
  theme_void() +
  annotate("text", x = 0, y = 0, label = paste0("* ", STATUS$conceptual$label),
           size = 3.6, color = "#5A5A5A", hjust = 0, fontface = "italic")

# =================================================================================================
# 3. RIGHT HALF: FOREST PLOT OF C1-C4 (STATUS$supported)
# =================================================================================================

row_labels <- c(
  C1 = "Confirm both doses\nvs commit to one",
  C2 = "Select one + fresh confirmation\nvs commit to one",
  C3 = "Select one + reuse evidence\nvs commit to one",
  C4 = "Reuse earlier evidence vs\nrequire fresh confirmation"
)

fp <- contrasts
fp$row_label <- row_labels[fp$contrast]
# Order top-to-bottom C1..C4 as rows going down; ggplot y increases upward, so reverse factor.
fp$contrast <- factor(fp$contrast, levels = c("C4", "C3", "C2", "C1"))
fp$is_c4 <- fp$contrast == "C4"
fp$label_val <- sprintf("%+0.3f [%+0.3f, %+0.3f]", fp$estimate, fp$ci_lo, fp$ci_hi)

# Highlight band for the C4 row (drawn first, underneath).
c4_band <- data.frame(ymin = as.numeric(factor("C4", levels = levels(fp$contrast))) - 0.5,
                       ymax = as.numeric(factor("C4", levels = levels(fp$contrast))) + 0.5)

forest <- ggplot(fp, aes(x = estimate, y = contrast)) +
  geom_rect(data = c4_band, aes(ymin = ymin, ymax = ymax), xmin = -Inf, xmax = Inf,
            inherit.aes = FALSE, fill = PAL$accent, alpha = 0.10) +  # globals-ok: graphics transparency, not the exposure ceiling
  geom_vline(xintercept = 0, color = "#B5B5B5", linewidth = 0.6, linetype = "solid") +
  geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi, color = is_c4),
                 height = 0.18, linewidth = ifelse(fp$is_c4, 1.7, 1.1)) +
  geom_point(aes(color = is_c4, size = is_c4, shape = is_c4)) +
  geom_text(aes(label = label_val, x = ci_hi), hjust = -0.08, vjust = 0.5,
            size = 3.55, color = PAL$ink, fontface = ifelse(fp$is_c4, "bold", "plain")) +
  scale_color_manual(values = c(`TRUE` = PAL$accent, `FALSE` = PAL$retained), guide = "none") +
  scale_size_manual(values = c(`TRUE` = 4.6, `FALSE` = 3.2), guide = "none") +
  scale_shape_manual(values = c(`TRUE` = 18, `FALSE` = 16), guide = "none") +
  scale_y_discrete(labels = function(x) row_labels[x]) +
  scale_x_continuous(labels = function(v) sprintf("%+.2f", v),
                      expand = expansion(mult = c(0.06, 0.68))) +
  labs(
    x = "Difference in chance of ultimately confirming\nthe correct dose (95% CI, adjusted for four planned comparisons)",
    y = NULL,
    subtitle = "Four comparisons, one clinical scenario. The diamond and highlighted\nrow show the evidence-reuse effect alone, holding the design and\nthe interim stopping rule fixed."
  ) +
  theme_arpa(base_size = 18) +
  theme(
    axis.text.y = element_text(hjust = 0, size = rel(0.72), lineheight = 0.95),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    plot.subtitle = element_text(size = rel(0.60), lineheight = 1.05, margin = margin(b = 10)),
    plot.margin = margin(10, 26, 10, 10)
  )
# Emphasis for C4 is carried by the diamond marker, the heavier CI line, the bold numeric
# label, and the highlighted row band, so it reads without relying on bold axis text alone.

badge_layer <- annotate("label", x = -Inf, y = Inf, label = APPLICATION_BADGE_TEXT,
                         hjust = -0.02, vjust = 1.4, size = 3.1, color = PAL$ink,
                         fill = PAL$panel_bg, fontface = "italic")

supported_tag <- ggplot() +
  theme_void() +
  annotate("text", x = 0, y = 0, label = paste0("* ", STATUS$supported$label),
           size = 3.6, color = PAL$retained, hjust = 0, fontface = "italic")

forest_final <- forest + badge_layer

# =================================================================================================
# 4. DESCRIPTIVE RESOURCE CALLOUT, GRAPHICALLY SEPARATED FROM THE FOREST PLOT
# =================================================================================================
# Its own bordered/shaded panel, offset below the forest with a visible gap, no shared row axis
# or y-scale with the C1-C4 rows so it cannot read as a fifth contrast.

callout_text <- sprintf(
  paste0(
    "Reusing evidence across the boundary saves about %.1f expected phase II patients\n",
    "and about %.1f months versus a fresh-confirmation strategy, for this clinical\n",
    "scenario and this budget."
  ),
  delta_n, delta_t
)

callout <- ggplot() +
  theme_void(base_size = 20) +
  xlim(0, 1) + ylim(0, 1) +
  geom_rect(aes(xmin = 0.005, xmax = 0.995, ymin = 0.03, ymax = 0.97),
            fill = PAL$panel_bg, color = PAL$ink, linewidth = 0.7) +
  annotate("label", x = 0.03, y = 0.86, label = "DESCRIPTIVE", hjust = 0, vjust = 0.5,
           size = 3.3, fontface = "bold", color = PAL$paper, fill = "#3A3A3A",
           label.padding = unit(0.22, "lines")) +
  annotate("text", x = 0.03, y = 0.42, label = callout_text, hjust = 0, vjust = 0.5,
           size = 3.4, color = PAL$ink, lineheight = 1.15) +
  labs(title = "Descriptive resource difference, not a statistical comparison") +
  theme(
    plot.title = element_text(size = rel(0.68), face = "bold", color = PAL$ink,
                               hjust = 0, margin = margin(b = 2)),
    plot.margin = margin(6, 6, 6, 6)
  )

# =================================================================================================
# 5. COMPOSE FULL FIGURE
# =================================================================================================
# Single flat ggdraw() canvas, every element placed by exact fraction via draw_plot(). This
# avoids ambiguous dimension resolution from deeply nested plot_grid()/patchwork objects, and
# gives deterministic control over the callout's visual separation from the forest plot's rows.

LEFT_X0  <- 0.02;  LEFT_X1  <- 0.485
RIGHT_X0 <- 0.515; RIGHT_X1 <- 0.98
LEFT_W   <- LEFT_X1 - LEFT_X0
RIGHT_W  <- RIGHT_X1 - RIGHT_X0

# Four schematic panels, equal width, small gaps, spanning the left column exactly.
n_sch <- 4
gap_sch <- 0.008
panel_w <- (LEFT_W - (n_sch - 1) * gap_sch) / n_sch
sch_x0 <- LEFT_X0 + (0:(n_sch - 1)) * (panel_w + gap_sch)
sch_plots <- list(p_single, p_parallel, p_hard, p_permeable)

full <- cowplot::ggdraw() +
  cowplot::draw_grob(grid::rectGrob(gp = grid::gpar(fill = PAL$paper, col = NA)),
                      x = 0, y = 0, width = 1, height = 1) +
  cowplot::draw_label("A phase boundary is an information policy",
                       fontface = "bold", size = 25, x = 0.02, hjust = 0, y = 0.965,
                       color = PAL$ink) +
  cowplot::draw_label(
    "It determines what evidence is kept, what options are dropped, and what later trials must collect again.",
    size = 14, x = 0.02, hjust = 0, y = 0.915, color = "#3A3A3A"
  ) +
  cowplot::draw_label("How each design treats evidence at the boundary",
                       fontface = "bold", size = 15, x = LEFT_X0, hjust = 0, y = 0.84,
                       color = PAL$ink) +
  cowplot::draw_plot(conceptual_tag, x = LEFT_X0, y = 0.04, width = LEFT_W, height = 0.06) +
  cowplot::draw_plot(forest_final, x = RIGHT_X0, y = 0.28, width = RIGHT_W, height = 0.575) +
  cowplot::draw_plot(supported_tag, x = RIGHT_X0, y = 0.225, width = RIGHT_W, height = 0.045) +
  cowplot::draw_plot(callout, x = RIGHT_X0, y = 0.03, width = RIGHT_W, height = 0.155)

for (i in seq_len(n_sch)) {
  full <- full + cowplot::draw_plot(sch_plots[[i]], x = sch_x0[i], y = 0.14,
                                     width = panel_w, height = 0.65)
}

print(full)

res <- save_figure(full, FIG_ID, width_in = 16, height_in = 9, dpi = 300)
cat("[fig4] outputs:\n")
str(res)
