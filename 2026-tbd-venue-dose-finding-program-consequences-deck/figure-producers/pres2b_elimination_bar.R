# PRESENTATION VARIANT of fig2_selected_dose_information_state.R, Panel B only.
#
# id = "pres2b_elimination_bar"
#
# Data loading and numeric assertions below are copied VERBATIM from the archival fig2 script's
# Panel B section (same object, same column, same expected values, same tolerance). Simplification
# is visual only: the bar is drawn full-slide, the "range across five variants" text and the
# italic subtitle are removed, and the only rendered prose is the two sentences the owner
# specified. Approximation signs on the percentages are kept, per instruction.

suppressPackageStartupMessages({
  library(ggplot2)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

WORKTREE <- file.path(ROOT, ".worktrees", "experiment-1-efficacy-timing")
UBOIN_PATH <- file.path(WORKTREE, "results", "uboin_kernel_study.rds")

stopifnot(file.exists(UBOIN_PATH))

near <- function(a, b, tol = 1e-8) abs(a - b) < tol

ub <- readRDS(UBOIN_PATH)

stopifnot(startsWith(ub$provenance$batond_commit, "0a743ed"))
stopifnot(identical(ub$provenance$batond_commit, "0a743edee283801151e9bee8e122319fc5622537"))

cat("[pres2b] provenance verified, same object and commit as fig2 Panel B.\n")

# ================================================================================================
# PANEL B DATA, identical column and truth filter to fig2_selected_dose_information_state.R.
# ================================================================================================

stopifnot(is.data.frame(ub$estimates))
stopifnot(!("elim_dstar" %in% names(ub$estimates)))
stopifnot("false_elim_dstar" %in% names(ub$estimates))

cat("[pres2b] Column check. 'elim_dstar' is NOT a column (as expected). ",
    "'false_elim_dstar' IS a column.\n")

s4_est <- ub$estimates[ub$estimates$truth == "s4", c("arm", "arm_label", "false_elim_dstar", "replicates")]
s4_est <- s4_est[order(s4_est$arm), ]

expected_s4 <- c(K1 = 0.0955, K2 = 0.1005, K3 = 0.10025, K4 = 0.10025, REC = 0.0955)
stopifnot(nrow(s4_est) == 5)
stopifnot(identical(s4_est$arm_label, c("K1", "K2", "K3", "K4", "REC")))
stopifnot(all(near(s4_est$false_elim_dstar, expected_s4[s4_est$arm_label], 1e-6)))
stopifnot(all(s4_est$replicates == 4000))

cat("[pres2b] s4 false_elim_dstar matched expected values on all 5 kernel arms, tol 1e-6.\n")
print(s4_est)

verify_banner(
  figure_id = "pres2b_elimination_bar",
  source_artifact = UBOIN_PATH,
  producer = "scripts/figures/arpa_stats_meeting/pres2b_elimination_bar.R (cut from fig2_selected_dose_information_state.R Panel B)",
  fields = c("estimates$truth == s4", "estimates$arm_label", "estimates$false_elim_dstar"),
  expected = paste(names(expected_s4), expected_s4, sep = "=", collapse = ", "),
  observed = paste(s4_est$arm_label, s4_est$false_elim_dstar, sep = "=", collapse = ", ")
)

k1_val <- s4_est$false_elim_dstar[s4_est$arm_label == "K1"]

panelB_df <- data.frame(
  segment = factor(c("OBD available", "OBD eliminated before selection"),
                    levels = c("OBD eliminated before selection", "OBD available")),
  xmin = c(0, 1 - k1_val),
  xmax = c(1 - k1_val, 1)
)

# ================================================================================================
# PLOT. One bar, full slide. Two sentences only.
# ================================================================================================

p_b <- ggplot(panelB_df, aes(y = 1, xmin = xmin, xmax = xmax, fill = segment)) +
  geom_rect(aes(ymin = 0.45, ymax = 0.85), color = PAL$paper, linewidth = 1.6) +
  annotate("text", x = (1 - k1_val) / 2, y = 0.65,
           label = sprintf("≈%.0f%% best dose still available", (1 - k1_val) * 100),
           color = PAL$paper, fontface = "bold", size = 9.5) +
  annotate("segment", x = 1 - k1_val / 2, xend = 1.04, y = 0.65, yend = 0.65,
           color = PAL$discarded, linewidth = 1.0) +
  annotate("text", x = 1.07, y = 0.65,
           label = sprintf("≈%.0f%%\neliminated", k1_val * 100),
           color = PAL$discarded, fontface = "bold", size = 7.2, hjust = 0, lineheight = 0.9) +
  scale_fill_manual(values = c("OBD available" = PAL$retained,
                                "OBD eliminated before selection" = PAL$discarded)) +
  scale_x_continuous(limits = c(0, 1.42), expand = c(0, 0)) +
  scale_y_continuous(limits = c(0, 1.0), expand = c(0, 0)) +
  labs(title = NULL) +
  theme_arpa(base_size = 22) +
  theme(
    legend.position = "none",
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),
    plot.title = element_text(size = rel(1.55)),
    plot.margin = margin(16, 24, 16, 20)
  ) +
  annotate("text", x = 0, y = 0.20,
           label = "In this difficult scenario, the best dose is eliminated in about 1 in 10 trials.",
           hjust = 0, vjust = 1, size = 7.2, color = PAL$ink) +
  annotate("text", x = 0, y = 0.06,
           label = "Once it is gone, no later calibration can select it.",
           hjust = 0, vjust = 1, size = 7.2, color = PAL$discarded, fontface = "bold")

out <- save_figure(p_b, "pres2b_elimination_bar", width_in = 13.333, height_in = 7.5)
print(out)
