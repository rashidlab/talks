# FIGURE 2. "A selected dose is also an information state"
#
# id = "fig2_selected_dose_information_state"
#
# Two panels.
#   A. Effect of the dose-ranking rule vs the effect of how toxicity/efficacy evidence is
#      summarized, on the probability of selecting the correct dose. BOIN12 design (5 clinical
#      scenarios) and U-BOIN design (7 clinical scenarios).
#   B. A scenario in which the best dose can be eliminated before selection ever happens,
#      nearly unchanged across five alternative design variants.
#
# Every number plotted is read live from the frozen result objects below and asserted against
# the values given in the build brief before any geometry is drawn. If an assertion fails the
# script stops rather than plotting a silently wrong number.
#
# JARGON RULE (mid-build correction, binding on all audience-facing figures). No acronym,
# experiment number, object name, internal analysis label, or repo shorthand may appear on
# anything rendered (titles, subtitles, axis labels, direct point/bar labels, annotations,
# legends, caption). Named designs BOIN, BOIN12, U-BOIN are standard terms for this audience
# and are kept. Internal identifiers (truth IDs, kernel arm codes, file/commit provenance)
# stay in code comments, cat() console output, and this script's own verification banners,
# never on the rendered page. Full provenance is reported back to the coordinator in prose,
# not drawn on the figure.
#
# Governing rule for this build: BLOCKED is preferred to any weakening of provenance. If a
# panel's numbers cannot be traced to object fields exactly, that panel is not drawn.

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

WORKTREE <- file.path(ROOT, ".worktrees", "experiment-1-efficacy-timing")
MXF_PATH   <- file.path(WORKTREE, "results", "mxf_kernel_study.rds")
UBOIN_PATH <- file.path(WORKTREE, "results", "uboin_kernel_study.rds")

stopifnot(file.exists(MXF_PATH), file.exists(UBOIN_PATH))

near <- function(a, b, tol = 1e-8) abs(a - b) < tol

# ================================================================================================
# PANEL A. Effect of the dose-ranking rule vs effect of evidence summarization on correct
# selection. (Internal names for these two contrasts: K2-K1 = ranking functional, K3-K2 =
# posterior representation. Neither name is rendered.)
# ================================================================================================

mxf <- readRDS(MXF_PATH)
ub  <- readRDS(UBOIN_PATH)

# --- provenance checks, both sources (console only, never rendered) ---------------------------

stopifnot(identical(mxf$provenance$script, "scripts/mxf_kernel_study.R"))
stopifnot(identical(mxf$provenance$commit, "6d0f88281bf23155c8c340be0173c95bbec23a27"))
stopifnot(identical(mxf$provenance$batond_commit, "d5beb4e88de48ea78dbed264b1c291ebbeee832a"))

stopifnot(startsWith(ub$provenance$batond_commit, "0a743ed"))
stopifnot(identical(ub$provenance$batond_commit, "0a743edee283801151e9bee8e122319fc5622537"))

cat("[fig2] Panel A provenance verified.\n")
cat("  mxf_kernel_study.rds  script =", mxf$provenance$script,
    " commit =", mxf$provenance$commit,
    " batond_commit =", mxf$provenance$batond_commit, "\n")
cat("  uboin_kernel_study.rds script =", ub$provenance$script,
    " batond_commit =", ub$provenance$batond_commit, "\n")

# --- BOIN12 design, contrasts, metric select_obd_utility --------------------------------------

stopifnot(is.data.frame(mxf$contrasts))
stopifnot(all(c("truth", "contrast", "diff", "mcse", "metric", "replicates") %in% names(mxf$contrasts)))

b12_truths <- c("b12_bk1", "b12_bk2", "b12_bk3", "b12_bk4", "b12_bk5")

b12_func <- mxf$contrasts[mxf$contrasts$metric == "select_obd_utility" &
                             mxf$contrasts$contrast == "K2-K1" &
                             mxf$contrasts$truth %in% b12_truths, ]
b12_repr <- mxf$contrasts[mxf$contrasts$metric == "select_obd_utility" &
                             mxf$contrasts$contrast == "K3-K2" &
                             mxf$contrasts$truth %in% b12_truths, ]

expected_b12_func <- c(b12_bk1 = -0.0335, b12_bk2 = 0.0255, b12_bk3 = 0.10075,
                        b12_bk4 = -0.0495, b12_bk5 = -0.00075)
expected_b12_repr <- c(b12_bk1 = 0.0125, b12_bk2 = -0.01575, b12_bk3 = -0.01275,
                        b12_bk4 = 0.01475, b12_bk5 = -0.0005)
expected_b12_func_mcse <- c(b12_bk1 = 0.007122648, b12_bk2 = 0.005323958, b12_bk3 = 0.006337184,
                             b12_bk4 = 0.006811684, b12_bk5 = 0.006428273)
expected_b12_repr_mcse <- c(b12_bk1 = 0.004818375, b12_bk2 = 0.004183881, b12_bk3 = 0.003694627,
                             b12_bk4 = 0.004584033, b12_bk5 = 0.004213594)

stopifnot(nrow(b12_func) == 5, nrow(b12_repr) == 5)
stopifnot(all(near(b12_func$diff[match(b12_truths, b12_func$truth)], expected_b12_func[b12_truths], 1e-6)))
stopifnot(all(near(b12_repr$diff[match(b12_truths, b12_repr$truth)], expected_b12_repr[b12_truths], 1e-6)))
stopifnot(all(near(b12_func$mcse[match(b12_truths, b12_func$truth)], expected_b12_func_mcse[b12_truths], 1e-6)))
stopifnot(all(near(b12_repr$mcse[match(b12_truths, b12_repr$truth)], expected_b12_repr_mcse[b12_truths], 1e-6)))
stopifnot(all(b12_func$replicates == 4000), all(b12_repr$replicates == 4000))

cat("[fig2] Panel A BOIN12 (K2-K1, K3-K2) matched expected values on all 5 truths, tol 1e-6.\n")

# --- U-BOIN design, contrasts, metric select_obd_utility, s2..s8 ------------------------------

ub_truths <- c("s2", "s3", "s4", "s5", "s6", "s7", "s8")

ub_func <- ub$contrasts[ub$contrasts$metric == "select_obd_utility" &
                           ub$contrasts$contrast == "K2-K1" &
                           ub$contrasts$truth %in% ub_truths, ]
ub_repr <- ub$contrasts[ub$contrasts$metric == "select_obd_utility" &
                           ub$contrasts$contrast == "K3-K2" &
                           ub$contrasts$truth %in% ub_truths, ]

expected_ub_func <- c(s2 = -0.0135, s3 = 0.0155, s4 = 0.0335, s5 = 0.01725,
                       s6 = -0.0175, s7 = -0.0005, s8 = 0)
expected_ub_repr <- c(s2 = 0.002, s3 = -0.00225, s4 = 0.00125, s5 = 0.01075,
                       s6 = 0.011, s7 = -0.0035, s8 = 0)
expected_ub_func_mcse <- c(s2 = 0.006370996, s3 = 0.003717310, s4 = 0.004660994, s5 = 0.005733352,
                            s6 = 0.004450100, s7 = 0.005172681, s8 = 0)
expected_ub_repr_mcse <- c(s2 = 0.003984717, s3 = 0.002046285, s4 = 0.002634169, s5 = 0.003378086,
                            s6 = 0.002733426, s7 = 0.003316578, s8 = 0)

stopifnot(nrow(ub_func) == 7, nrow(ub_repr) == 7)
stopifnot(all(near(ub_func$diff[match(ub_truths, ub_func$truth)], expected_ub_func[ub_truths], 1e-6)))
stopifnot(all(near(ub_repr$diff[match(ub_truths, ub_repr$truth)], expected_ub_repr[ub_truths], 1e-6)))
stopifnot(all(near(ub_func$mcse[match(ub_truths, ub_func$truth)], expected_ub_func_mcse[ub_truths], 1e-6)))
stopifnot(all(near(ub_repr$mcse[match(ub_truths, ub_repr$truth)], expected_ub_repr_mcse[ub_truths], 1e-6)))
stopifnot(all(ub_func$replicates == 4000), all(ub_repr$replicates == 4000))

cat("[fig2] Panel A U-BOIN (K2-K1, K3-K2) matched expected values on all 7 truths, tol 1e-6.\n")

verify_banner(
  figure_id = "fig2_selected_dose_information_state (Panel A)",
  source_artifact = paste(MXF_PATH, UBOIN_PATH, sep = " ; "),
  producer = paste(mxf$provenance$script, ub$provenance$script, sep = " ; "),
  fields = c("contrasts$truth", "contrasts$contrast", "contrasts$diff", "contrasts$mcse",
             "contrasts$metric == select_obd_utility"),
  expected = "12 diffs matched exactly, see build brief",
  observed = "all stopifnot() assertions passed, tol 1e-6"
)

# Internal truth IDs are kept ONLY as an internal join key (b12_bkN, sN). The rendered x-axis
# uses neutral "Scenario N" labels, independently numbered within each design, per the
# mid-build jargon ruling ("neutral labels like Scenario 1, Scenario 2 with a compact key").
# No qualitative description is invented for scenarios whose qualitative character was not
# independently verified from the RESULT documents (derive-or-withhold).

b12_scenario_map <- setNames(paste("Scenario", seq_along(b12_truths)), b12_truths)
ub_scenario_map  <- setNames(paste("Scenario", seq_along(ub_truths)), ub_truths)

panelA_df <- rbind(
  data.frame(design = "BOIN12 design", truth = b12_func$truth,
             scenario = b12_scenario_map[b12_func$truth],
             component = "Dose-ranking rule", diff = b12_func$diff, mcse = b12_func$mcse),
  data.frame(design = "BOIN12 design", truth = b12_repr$truth,
             scenario = b12_scenario_map[b12_repr$truth],
             component = "Evidence-summary method", diff = b12_repr$diff, mcse = b12_repr$mcse),
  data.frame(design = "U-BOIN design", truth = ub_func$truth,
             scenario = ub_scenario_map[ub_func$truth],
             component = "Dose-ranking rule", diff = ub_func$diff, mcse = ub_func$mcse),
  data.frame(design = "U-BOIN design", truth = ub_repr$truth,
             scenario = ub_scenario_map[ub_repr$truth],
             component = "Evidence-summary method", diff = ub_repr$diff, mcse = ub_repr$mcse)
)
panelA_df$diff_pp <- panelA_df$diff * 100
panelA_df$lo_pp <- (panelA_df$diff - 1.96 * panelA_df$mcse) * 100
panelA_df$hi_pp <- (panelA_df$diff + 1.96 * panelA_df$mcse) * 100

panelA_df$design <- factor(panelA_df$design, levels = c("BOIN12 design", "U-BOIN design"))
# x-axis tick labels are bare numbers (the word "scenario" lives once, in the axis title) to
# keep 5+7 dodged category slots from colliding when the panel is not full canvas width.
panelA_df$scenario_num <- as.integer(sub("^Scenario ", "", panelA_df$scenario))
panelA_df$scenario_num <- factor(panelA_df$scenario_num, levels = 1:7)
panelA_df$component <- factor(panelA_df$component,
                               levels = c("Dose-ranking rule", "Evidence-summary method"))

# ================================================================================================
# PANEL B. A scenario where the best dose can be eliminated before selection.
# (Internal name for this truth: s4, the single-admissible-dose boundary / "cliff" truth. Not
# rendered. The column used is false_elim_dstar, arm-level, verified against the coordinator's
# correction that the field is NOT literally named elim_dstar.)
# ================================================================================================

stopifnot(is.data.frame(ub$estimates))
stopifnot(!("elim_dstar" %in% names(ub$estimates)))
stopifnot("false_elim_dstar" %in% names(ub$estimates))

cat("[fig2] Panel B column check. 'elim_dstar' is NOT a column (as expected). ",
    "'false_elim_dstar' IS a column (as the coordinator corrected).\n")

s4_est <- ub$estimates[ub$estimates$truth == "s4", c("arm", "arm_label", "false_elim_dstar", "replicates")]
s4_est <- s4_est[order(s4_est$arm), ]

expected_s4 <- c(K1 = 0.0955, K2 = 0.1005, K3 = 0.10025, K4 = 0.10025, REC = 0.0955)
stopifnot(nrow(s4_est) == 5)
stopifnot(identical(s4_est$arm_label, c("K1", "K2", "K3", "K4", "REC")))
stopifnot(all(near(s4_est$false_elim_dstar, expected_s4[s4_est$arm_label], 1e-6)))
stopifnot(all(s4_est$replicates == 4000))

cat("[fig2] Panel B s4 false_elim_dstar matched expected values on all 5 kernel arms, tol 1e-6.\n")
print(s4_est)

verify_banner(
  figure_id = "fig2_selected_dose_information_state (Panel B)",
  source_artifact = UBOIN_PATH,
  producer = ub$provenance$script,
  fields = c("estimates$truth == s4", "estimates$arm_label", "estimates$false_elim_dstar"),
  expected = paste(names(expected_s4), expected_s4, sep = "=", collapse = ", "),
  observed = paste(s4_est$arm_label, s4_est$false_elim_dstar, sep = "=", collapse = ", ")
)

k1_val <- s4_est$false_elim_dstar[s4_est$arm_label == "K1"]
range_lo <- min(s4_est$false_elim_dstar)
range_hi <- max(s4_est$false_elim_dstar)

panelB_df <- data.frame(
  segment = factor(c("OBD available", "OBD eliminated before selection"),
                    levels = c("OBD eliminated before selection", "OBD available")),
  xmin = c(0, 1 - k1_val),
  xmax = c(1 - k1_val, 1)
)

# ================================================================================================
# BADGE APPLICABILITY. Read the RESULT documents to confirm the truth family behind Figure 2.
# ================================================================================================
#
# Checked against:
#   .worktrees/experiment-1-efficacy-timing/docs/plans/2026-08-24-experiment-2-mxf-kernels-RESULT.md
#   .worktrees/experiment-1-efficacy-timing/docs/plans/2026-08-25-experiment-3-uboin-kernels-RESULT.md
#
# Both documents describe the truths behind these numbers as the fixed nominal benchmark grid
# (b12_bk1..b12_bk5 on the BOIN12 design, the frozen nine-truth U-BOIN list including s2..s8).
# Neither document names any of these truths "the application truth" or singles out "efficacy
# increases with dose" as a distinguished condition, except s6 which is mentioned in passing as
# "monotone efficacy to the top dose, every dose admissible" among nine truths in that grid, not
# a singled-out application scenario. Figure 2 therefore does NOT draw from the one clinical
# scenario that Figures 3/3B/4/6 use later in development, and the badge is NOT applied here.
# This determination is unchanged by the mid-build jargon correction, which only updated the
# badge's wording for figures where it does apply.

APPLY_APPLICATION_BADGE <- FALSE

# ================================================================================================
# PLOTS
# ================================================================================================

# Panels are stacked (full canvas width each) rather than placed side by side. Patchwork does
# not wrap or clip a subplot's own title/subtitle text to its allotted column width, so the
# first side-by-side layout let panel A's title overrun panel B's column. Stacking removes the
# narrow-column constraint that caused it, since both panels now span the full 13.333in canvas.

shape_map <- c("Dose-ranking rule" = 16, "Evidence-summary method" = 17)
color_map <- c("Dose-ranking rule" = PAL$retained, "Evidence-summary method" = PAL$comparator)

p_a <- ggplot(panelA_df, aes(x = scenario_num, y = diff_pp, color = component, shape = component,
                              group = component)) +
  geom_hline(yintercept = 0, color = PAL$ink, linewidth = 0.4) +
  geom_errorbar(aes(ymin = lo_pp, ymax = hi_pp), width = 0.16,
                position = position_dodge(width = 0.5), linewidth = 0.7,
                linetype = STATUS$supported$linetype, alpha = STATUS$supported$alpha) +
  geom_point(position = position_dodge(width = 0.5), size = 3.2,
             alpha = STATUS$supported$alpha) +
  facet_wrap(~design, scales = "free_x", nrow = 1) +
  scale_color_manual(values = color_map, name = NULL) +
  scale_shape_manual(values = shape_map, name = NULL) +
  labs(
    title = "What changes the probability of correct-dose selection",
    subtitle = "Dose-ranking rule vs evidence-summary method, by clinical scenario (95% CI)",
    x = "Clinical scenario, numbered independently within each design",
    y = "Change in probability of\ncorrect-dose selection (points)"
  ) +
  theme_arpa(base_size = 17) +
  theme(
    legend.position = "top",
    legend.text = element_text(size = rel(0.8)),
    strip.text = element_text(size = rel(1.0), face = "bold", color = PAL$ink),
    plot.subtitle = element_text(size = rel(0.85)),
    panel.spacing = unit(1.6, "lines")
  )

# x-scale extends to 1.22 (bar itself still spans exactly 0 to 1, i.e. 0% to 100%) so the
# "eliminated" segment's callout label has room to sit to the right of the bar without being
# clipped at the canvas edge, since that segment (about 9.5% of the bar) is too narrow to carry
# its own label inside it.
p_b <- ggplot(panelB_df, aes(y = 1, xmin = xmin, xmax = xmax, fill = segment)) +
  geom_rect(aes(ymin = 0.66, ymax = 0.96), color = PAL$paper, linewidth = 1.2) +
  annotate("text", x = (1 - k1_val) / 2, y = 0.81,
           label = sprintf("\u2248%.1f%% best dose still available", (1 - k1_val) * 100),
           color = PAL$paper, fontface = "bold", size = 5.6) +
  annotate("segment", x = 1 - k1_val / 2, xend = 1.06, y = 0.81, yend = 0.81,
           color = PAL$discarded, linewidth = 0.8) +
  annotate("text", x = 1.09, y = 0.81,
           label = sprintf("\u2248%.1f%%\neliminated", k1_val * 100),
           color = PAL$discarded, fontface = "bold", size = 5.2, hjust = 0, lineheight = 0.9) +
  annotate("text", x = 0, y = 0.42,
           label = sprintf(
             "Range across five alternative design variants, %.2f%% to %.2f%%, nearly the same regardless of choice",
             range_lo * 100, range_hi * 100),
           hjust = 0, vjust = 1, size = 4.4, color = "#4A4A4A") +
  annotate("text", x = 0, y = 0.20,
           label = "Once eliminated, the best dose cannot be recovered later in development.",
           hjust = 0, vjust = 1, size = 5.2, color = PAL$discarded, fontface = "bold") +
  scale_fill_manual(values = c("OBD available" = PAL$retained,
                                "OBD eliminated before selection" = PAL$discarded)) +
  scale_x_continuous(limits = c(0, 1.22), expand = c(0, 0)) +
  scale_y_continuous(limits = c(0, 1.0), expand = c(0, 0)) +
  labs(
    title = "The best dose can be eliminated before selection",
    subtitle = "Scenario in which the best dose is adjacent to a sharply worse dose"
  ) +
  theme_arpa(base_size = 17) +
  theme(
    legend.position = "none",
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),
    plot.subtitle = element_text(size = rel(0.85), face = "italic"),
    plot.margin = margin(10, 20, 14, 16)
  )

combined <- p_a / p_b +
  plot_layout(heights = c(1.15, 1)) +
  plot_annotation(
    title = "A selected dose is also an information state",
    subtitle = "Empirical result, 95% confidence intervals shown",
    caption = paste0(
      "Source, simulation study comparing design variants within each underlying design, ",
      "4,000 simulated trials per scenario per variant."
    ),
    theme = theme(
      plot.title = element_text(size = rel(1.7), face = "bold", color = PAL$ink,
                                 family = BASE_FAMILY, margin = margin(b = 4)),
      plot.subtitle = element_text(size = rel(1.05), color = PAL$retained, face = "bold",
                                    family = BASE_FAMILY, margin = margin(b = 10)),
      plot.caption = element_text(size = rel(0.62), color = "#6A6A6A", hjust = 0,
                                   family = BASE_FAMILY, margin = margin(t = 8))
    )
  )

if (!APPLY_APPLICATION_BADGE) {
  cat("[fig2] Application-scenario badge NOT applied. Figure 2 draws from the nominal benchmark\n")
  cat("       scenario grid (b12_bk1..b12_bk5, s2..s8), not the one clinical scenario reserved\n")
  cat("       for Experiments 5-8 results shown later in development.\n")
}

out <- save_figure(combined, "fig2_selected_dose_information_state", width_in = 13.333, height_in = 7.5)
print(out)
