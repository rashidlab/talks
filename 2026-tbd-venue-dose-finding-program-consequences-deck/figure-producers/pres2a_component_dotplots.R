# PRESENTATION VARIANT of fig2_selected_dose_information_state.R, Panel A only.
#
# id = "pres2a_component_dotplots"
#
# Data loading, provenance checks, and numeric assertions below are copied VERBATIM from the
# archival fig2 script's Panel A section (same objects, same expected values, same tolerance).
# Simplification is visual only: Panel B is dropped entirely, the two-panel composition and its
# manuscript-style caption/subtitle apparatus are removed, and the plot itself is reduced to the
# single claim the owner specified, one callout on the largest positive effect and one on the
# largest negative effect. No number below is retyped from a rendered figure or from memory,
# every one is read from the same $contrasts data frames fig2 reads.
#
# JARGON RULE unchanged from fig2: no acronym, experiment number, object name, internal analysis
# label, or repo shorthand on anything rendered. BOIN, BOIN12, U-BOIN are standard design names
# and are kept.

suppressPackageStartupMessages({
  library(ggplot2)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

WORKTREE <- file.path(ROOT, ".worktrees", "experiment-1-efficacy-timing")
MXF_PATH   <- file.path(WORKTREE, "results", "mxf_kernel_study.rds")
UBOIN_PATH <- file.path(WORKTREE, "results", "uboin_kernel_study.rds")

stopifnot(file.exists(MXF_PATH), file.exists(UBOIN_PATH))

near <- function(a, b, tol = 1e-8) abs(a - b) < tol

# ================================================================================================
# LOAD AND VERIFY, identical to fig2_selected_dose_information_state.R Panel A section.
# ================================================================================================

mxf <- readRDS(MXF_PATH)
ub  <- readRDS(UBOIN_PATH)

stopifnot(identical(mxf$provenance$script, "scripts/mxf_kernel_study.R"))
stopifnot(identical(mxf$provenance$commit, "6d0f88281bf23155c8c340be0173c95bbec23a27"))
stopifnot(identical(mxf$provenance$batond_commit, "d5beb4e88de48ea78dbed264b1c291ebbeee832a"))

stopifnot(startsWith(ub$provenance$batond_commit, "0a743ed"))
stopifnot(identical(ub$provenance$batond_commit, "0a743edee283801151e9bee8e122319fc5622537"))

cat("[pres2a] provenance verified, same objects and commits as fig2 Panel A.\n")

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

cat("[pres2a] BOIN12 (K2-K1, K3-K2) matched expected values on all 5 truths, tol 1e-6.\n")

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

cat("[pres2a] U-BOIN (K2-K1, K3-K2) matched expected values on all 7 truths, tol 1e-6.\n")

verify_banner(
  figure_id = "pres2a_component_dotplots",
  source_artifact = paste(MXF_PATH, UBOIN_PATH, sep = " ; "),
  producer = "scripts/figures/arpa_stats_meeting/pres2a_component_dotplots.R (cut from fig2_selected_dose_information_state.R Panel A)",
  fields = c("contrasts$truth", "contrasts$contrast", "contrasts$diff", "contrasts$mcse",
             "contrasts$metric == select_obd_utility"),
  expected = "12 diffs matched exactly, see build brief",
  observed = "all stopifnot() assertions passed, tol 1e-6"
)

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
panelA_df$scenario_num <- as.integer(sub("^Scenario ", "", panelA_df$scenario))
panelA_df$scenario_num <- factor(panelA_df$scenario_num, levels = 1:7)
panelA_df$component <- factor(panelA_df$component,
                               levels = c("Dose-ranking rule", "Evidence-summary method"))

# ================================================================================================
# ONE callout on the largest positive effect, ONE on the largest (most negative) effect, found
# programmatically from the same data frame that draws the points, never typed.
# ================================================================================================

max_row <- panelA_df[which.max(panelA_df$diff_pp), ]
min_row <- panelA_df[which.min(panelA_df$diff_pp), ]

cat(sprintf("[pres2a] Largest positive effect: %s, %s, %s = %+.1f points\n",
            max_row$design, max_row$scenario, max_row$component, max_row$diff_pp))
cat(sprintf("[pres2a] Largest negative effect: %s, %s, %s = %+.1f points\n",
            min_row$design, min_row$scenario, min_row$component, min_row$diff_pp))

# ================================================================================================
# PLOT. Component dotplots only, faceted by design. Blue = dose-ranking rule, gray =
# evidence-summary method. Minimal color key, no CI-grammar legend, no manuscript caption.
# ================================================================================================

shape_map <- c("Dose-ranking rule" = 16, "Evidence-summary method" = 17)
color_map <- c("Dose-ranking rule" = PAL$retained, "Evidence-summary method" = PAL$comparator)

# Facets have separately-scaled x axes (scenario numbers restart at 1 per design), so a callout
# built with annotate() would be facet-blind and repeat identically in the wrong facet. The
# callout data below carries its own `design` column and is drawn with geom_label/geom_segment
# so each one lands in only its correct facet panel.

p <- ggplot(panelA_df, aes(x = scenario_num, y = diff_pp, color = component, shape = component,
                            group = component)) +
  geom_hline(yintercept = 0, color = PAL$ink, linewidth = 0.5) +
  geom_errorbar(aes(ymin = lo_pp, ymax = hi_pp), width = 0.16,
                position = position_dodge(width = 0.5), linewidth = 0.8, alpha = 0.9) +
  geom_point(position = position_dodge(width = 0.5), size = 4.0, alpha = 0.95) +
  facet_wrap(~design, scales = "free_x", nrow = 1) +
  scale_color_manual(values = color_map, name = NULL) +
  scale_shape_manual(values = shape_map, name = NULL)

y_top <- max(panelA_df$hi_pp) + 6.0
y_bot <- min(panelA_df$lo_pp) - 5.0

p <- p +
  scale_y_continuous(limits = c(y_bot - 0.5, y_top + 0.5)) +
  labs(
    title = NULL,
    x = "Clinical scenario",
    y = "Change in probability of\ncorrect-dose selection (points)"
  ) +
  theme_arpa(base_size = 21) +
  theme(
    legend.position = "top",
    legend.text = element_text(size = rel(0.95)),
    strip.text = element_text(size = rel(1.05), face = "bold", color = PAL$ink),
    panel.spacing = unit(2.0, "lines"),
    plot.title = element_text(size = rel(1.35))
  )

# Callouts are placed DIRECTLY ABOVE (gain) or BELOW (loss) their own point, at the point's own
# x position, with a vertical leader line, never nudged sideways. This keeps them inside the
# panel's plotted x-range regardless of where the point falls within the discrete scenario axis,
# which is what caused the earlier version's text to run past the panel edge and clip.
callout_df <- rbind(
  data.frame(design = max_row$design, x = as.numeric(as.character(max_row$scenario_num)),
             y_point = max_row$diff_pp, y_label = y_top,
             label = sprintf("Largest gain\nabout %+.0f points", round(max_row$diff_pp)),
             color = PAL$retained),
  data.frame(design = min_row$design, x = as.numeric(as.character(min_row$scenario_num)),
             y_point = min_row$diff_pp, y_label = y_bot,
             label = sprintf("Largest loss\nabout %+.0f points", round(min_row$diff_pp)),
             color = PAL$discarded)
)

p <- p + geom_segment(
  data = callout_df,
  aes(x = x, xend = x, y = y_point, yend = y_label),
  inherit.aes = FALSE, color = callout_df$color, linewidth = 0.6
) + geom_label(
  data = callout_df,
  aes(x = x, y = y_label, label = label),
  inherit.aes = FALSE, hjust = 0.5, vjust = 0.5, size = 5.2, fontface = "bold",
  lineheight = 0.95, color = callout_df$color, fill = scales::alpha(PAL$paper, 0.92),
  label.size = 0
)

out <- save_figure(p, "pres2a_component_dotplots", width_in = 13.333, height_in = 7.5)
print(out)
