# PRESENTATION VARIANT of fig4_phase_boundary_information_policy.R, RIGHT HALF ONLY.
#
# id = "pres4b_forest"
#
# Data loading and the numeric assertions below are copied VERBATIM from the archival fig4
# script's verification section (same object, results/exp8_q5_primary.rds, same expected values,
# same tolerances). The four schematic panels are NOT drawn here, that content moved to pres4a
# entirely. The forest plot is drawn large, full slide. Per the coordinator's inspection
# criterion: the three versus-commit comparisons (C1-C3) are drawn in medium gray at full
# opacity, not faint, so they read as supported context rather than de-emphasized noise, while
# the evidence-reuse comparison (C4) is the single emphasized focus.

suppressPackageStartupMessages({
  library(ggplot2)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

FIG_ID <- "pres4b_forest"

# =================================================================================================
# LOAD AND VERIFY, identical to fig4_phase_boundary_information_policy.R.
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
  stop("PRES4B: contrasts C1-C4 do not match the brief's expected values within tolerance. Stopping per instructions.")
}
cat("[pres4b] contrasts C1-C4 matched expected values within tolerance.\n")

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
  producer = "scripts/figures/arpa_stats_meeting/pres4b_forest.R (cut from fig4_phase_boundary_information_policy.R right half)",
  fields = c("contrasts$estimate/ci_lo/ci_hi", "costs$e_n_ii/t_months", "truth_key"),
  expected = "C1..C4 per brief; e_n_ii excl 58.96 / inc 54.03 (delta 4.9); t_months excl 39.12 / inc 36.65 (delta 2.5)",
  observed = sprintf(
    "C1=%.4f C2=%.4f C3=%.4f C4=%.4f; e_n_ii excl=%.4f inc=%.4f (d=%.2f); t_months excl=%.4f inc=%.4f (d=%.2f)",
    contrasts$estimate[contrasts$contrast == "C1"], contrasts$estimate[contrasts$contrast == "C2"],
    contrasts$estimate[contrasts$contrast == "C3"], contrasts$estimate[contrasts$contrast == "C4"],
    e_n_ii_excl, e_n_ii_inc, delta_n, t_mo_excl, t_mo_inc, delta_t
  )
)

# =================================================================================================
# FOREST PLOT. C1-C3 medium gray, full opacity. C4 the strong emphasized focus.
# =================================================================================================

row_labels <- c(
  C1 = "Confirm both doses\nvs commit to one",
  C2 = "Select one + fresh confirmation\nvs commit to one",
  C3 = "Select one + reuse evidence\nvs commit to one",
  C4 = "Reuse earlier evidence vs\nrequire fresh confirmation"
)

fp <- contrasts
fp$row_label <- row_labels[fp$contrast]
fp$contrast <- factor(fp$contrast, levels = c("C4", "C3", "C2", "C1"))
fp$is_c4 <- fp$contrast == "C4"
fp$label_val <- sprintf("%+0.3f [%+0.3f, %+0.3f]", fp$estimate, fp$ci_lo, fp$ci_hi)

c4_band <- data.frame(ymin = as.numeric(factor("C4", levels = levels(fp$contrast))) - 0.5,
                       ymax = as.numeric(factor("C4", levels = levels(fp$contrast))) + 0.5)

forest <- ggplot(fp, aes(x = estimate, y = contrast)) +
  geom_rect(data = c4_band, aes(ymin = ymin, ymax = ymax), xmin = -Inf, xmax = Inf,
            inherit.aes = FALSE, fill = PAL$accent, alpha = 0.10) +  # globals-ok: graphics transparency, not the exposure ceiling
  geom_vline(xintercept = 0, color = "#B5B5B5", linewidth = 0.7) +
  geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi, color = is_c4),
                 height = 0.20, linewidth = ifelse(fp$is_c4, 2.6, 1.7)) +
  geom_point(aes(color = is_c4, size = is_c4, shape = is_c4)) +
  geom_text(aes(label = label_val, x = ci_hi), hjust = -0.08, vjust = 0.5,
            size = 6.6, color = PAL$ink, fontface = ifelse(fp$is_c4, "bold", "plain")) +
  scale_color_manual(values = c(`TRUE` = PAL$accent, `FALSE` = PAL$comparator), guide = "none") +
  scale_size_manual(values = c(`TRUE` = 7.5, `FALSE` = 5.0), guide = "none") +
  scale_shape_manual(values = c(`TRUE` = 18, `FALSE` = 16), guide = "none") +
  scale_y_discrete(labels = function(x) row_labels[x]) +
  scale_x_continuous(labels = function(v) sprintf("%+.2f", v),
                      expand = expansion(mult = c(0.06, 0.62))) +
  labs(
    title = NULL,
    x = "Difference in chance of ultimately confirming\nthe correct dose (95% CI, adjusted for four planned comparisons)",
    y = NULL
  ) +
  theme_arpa(base_size = 23) +
  theme(
    axis.text.y = element_text(hjust = 0, size = rel(0.82), lineheight = 0.95, color = PAL$ink),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    plot.title = element_text(size = rel(1.05), lineheight = 1.05),
    plot.margin = margin(14, 34, 14, 14)
  )

badge_layer <- annotate("label", x = -Inf, y = Inf, label = APPLICATION_BADGE_TEXT,
                         hjust = -0.02, vjust = 1.5, size = 4.6, color = PAL$ink,
                         fill = PAL$panel_bg, fontface = "italic")

forest_final <- forest + badge_layer

# ------------------------------------------------------------------------------------------
# Secondary small callout, clearly descriptive, values read from the same costs object.
# ------------------------------------------------------------------------------------------

callout_text <- sprintf(
  "Also, descriptively: about %.0f fewer patients and about %.1f months shorter.",
  delta_n, delta_t
)

callout <- ggplot() +
  theme_void(base_size = 20) +
  xlim(0, 1) + ylim(0, 1) +
  geom_rect(aes(xmin = 0.01, xmax = 0.99, ymin = 0.05, ymax = 0.95),
            fill = PAL$panel_bg, color = "#B0B0B0", linewidth = 0.6) +
  annotate("text", x = 0.5, y = 0.5, label = callout_text, hjust = 0.5, vjust = 0.5,
           size = 5.6, color = "#3A3A3A", fontface = "italic")

full <- cowplot::ggdraw() +
  cowplot::draw_grob(grid::rectGrob(gp = grid::gpar(fill = PAL$paper, col = NA)),
                      x = 0, y = 0, width = 1, height = 1) +
  cowplot::draw_plot(forest_final, x = 0.0, y = 0.14, width = 1.0, height = 0.86) +
  cowplot::draw_plot(callout, x = 0.08, y = 0.0, width = 0.84, height = 0.13)

out <- save_figure(full, FIG_ID, width_in = 12.8, height_in = 7.3)
print(out)

rendered_strings <- c(
  title = "none, the slide owns the title",
  x_axis = "Difference in chance of ultimately confirming\nthe correct dose (95% CI, adjusted for four planned comparisons)",
  row_labels = paste(row_labels, collapse = " | "),
  badge = APPLICATION_BADGE_TEXT,
  callout = callout_text
)
forbidden <- c("PCS", "\\btruth\\b", "\\bcell\\b", "frozen", "locked", "\\bpolic(y|ies)\\b",
               "select_exclude", "select_incorporate", "exp8", "\\bC1\\b", "\\bC2\\b", "\\bC3\\b", "\\bC4\\b")
hit <- FALSE
for (s in rendered_strings) {
  if (any(sapply(forbidden, function(pat) grepl(pat, s, ignore.case = TRUE)))) hit <- TRUE
}
stopifnot(!hit)
cat("[pres4b] jargon check PASSED.\n")
