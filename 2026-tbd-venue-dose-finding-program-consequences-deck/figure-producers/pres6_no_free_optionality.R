# PRESENTATION VARIANT of fig6_no_free_optionality.R.
#
# id = "pres6_no_free_optionality"
#
# The entire pre-plot gate (traversal_complete booleans, guard_demonstrations, design_stage
# cross-check, budget scalar identity, refusal-state scan) below is copied VERBATIM from the
# archival fig6 script. No assertion is loosened. Simplification from the archival figure is
# visual only: the orange sentence overlaid on the left panel is replaced by a plain labeled
# reference line ("Common budget = 36.1"), panel titles are shortened to the owner's exact
# wording, and a single bottom takeaway line replaces the prior title/caption pairing. Panel B's
# architecture order and undecorated treatment (no sort by attained power, no emphasis color on
# the largest value) are unchanged from fig6.

suppressPackageStartupMessages({
  library(ggplot2)
  library(grid)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

FIG_ID <- "pres6_no_free_optionality"

stress <- readRDS(file.path(ROOT, "results", "exp8_stress.rds"))
arch   <- readRDS(file.path(ROOT, "results", "exp8_architectures.rds"))

# ================================================================================================
# MANDATORY PRE-PLOT GATE, identical to fig6_no_free_optionality.R.
# ================================================================================================

cat("=====================================================================\n")
cat("FIGURE pres6_no_free_optionality PRE-PLOT GATE\n")
cat("=====================================================================\n")

status_ok <- all(stress$summary$status == "feasible_design_found")
cat("1a. all(summary$status == 'feasible_design_found'):", status_ok, "\n")
stopifnot(status_ok)

tc_select_exclude     <- stress$select_results$select_exclude$traversal_complete
tc_select_incorporate <- stress$select_results$select_incorporate$traversal_complete
tc_parallel           <- stress$parallel_result$traversal_complete
cat("1b. traversal_complete (select_exclude, select_incorporate, parallel):",
    tc_select_exclude, tc_select_incorporate, tc_parallel, "\n")
stopifnot(isTRUE(tc_select_exclude), isTRUE(tc_select_incorporate), isTRUE(tc_parallel))

guard_ok <- isTRUE(stress$guard_demonstrations$all_as_declared)
cat("2. guard_demonstrations$all_as_declared:", guard_ok, "\n")
stopifnot(guard_ok)

ds <- arch$design_stage
get_ds_row <- function(a) ds[ds$arch == a, ]
ds_select_exclude     <- get_ds_row("select_exclude")
ds_select_incorporate <- get_ds_row("select_incorporate")
ds_parallel           <- get_ds_row("parallel")

stress_unc_power <- c(
  select_exclude     = stress$select_results$select_exclude$unconstrained$e2_attained_power,
  select_incorporate = stress$select_results$select_incorporate$unconstrained$e2_attained_power,
  parallel            = stress$parallel_result$unconstrained$e2_attained_power
)
ds_unc_power <- c(
  select_exclude     = ds_select_exclude$e2_attained_power,
  select_incorporate = ds_select_incorporate$e2_attained_power,
  parallel            = ds_parallel$e2_attained_power
)
stress_unc_n <- c(
  select_exclude     = stress$select_results$select_exclude$unconstrained$e_n_ii_alt,
  select_incorporate = stress$select_results$select_incorporate$unconstrained$e_n_ii_alt,
  parallel            = stress$parallel_result$unconstrained$e_n_ii_alt
)
ds_unc_n <- c(
  select_exclude     = ds_select_exclude$e_n_ii_alt,
  select_incorporate = ds_select_incorporate$e_n_ii_alt,
  parallel            = ds_parallel$e_n_ii_alt
)
cmp_table <- data.frame(
  arch = names(stress_unc_power),
  stress_e2_attained_power = unname(stress_unc_power),
  design_stage_e2_attained_power = unname(ds_unc_power),
  power_match = abs(stress_unc_power - ds_unc_power) < 1e-6,
  stress_e_n_ii_alt = unname(stress_unc_n),
  design_stage_e_n_ii_alt = unname(ds_unc_n),
  n_match = abs(stress_unc_n - ds_unc_n) < 1e-6
)
cat("3. design_stage cross-check table:\n")
print(cmp_table, digits = 8)
stopifnot(all(cmp_table$power_match), all(cmp_table$n_match))

urds_summary <- stress$summary$unconstrained_reproduces_design_stage
urds_select_exclude     <- stress$select_results$select_exclude$unconstrained_reproduces_design_stage
urds_select_incorporate <- stress$select_results$select_incorporate$unconstrained_reproduces_design_stage
urds_parallel           <- stress$parallel_result$unconstrained_reproduces_design_stage
stopifnot(
  all(urds_summary), isTRUE(urds_select_exclude), isTRUE(urds_select_incorporate), isTRUE(urds_parallel)
)

budget <- stress$budget
cat("4a. exp8_stress.rds$budget (read once):", sprintf("%.10f", budget), "\n")
stopifnot(is.numeric(budget), length(budget) == 1, !is.na(budget))
stopifnot(abs(budget - 36.07154) < 1e-3)

budget_prov_value <- stress$budget_provenance$value
stopifnot(identical(budget, budget_prov_value))
ds_single_n <- ds[ds$arch == "single", "e_n_ii_alt"]
stopifnot(abs(budget - ds_single_n) < 1e-6)
cat("4b. budget == budget_provenance$value == design_stage arch=='single' e_n_ii_alt, confirmed.\n")

refusal_hit <- any(grepl("search_domain_failure", stress$summary$status, fixed = TRUE))
stopifnot(!refusal_hit)

cat("=====================================================================\n")
cat("GATE PASSED. Proceeding to plot.\n")
cat("=====================================================================\n")

verify_banner(
  figure_id = FIG_ID,
  source_artifact = "results/exp8_stress.rds, results/exp8_architectures.rds$design_stage",
  producer = "scripts/figures/arpa_stats_meeting/pres6_no_free_optionality.R (cut from fig6_no_free_optionality.R)",
  fields = c("summary$status", "traversal_complete", "guard_demonstrations$all_as_declared",
             "budget", "design_stage$e_n_ii_alt", "select_results$*$reported$e2_attained_power"),
  expected = "all gate checks pass, budget ~36.07",
  observed = sprintf("gate passed, budget=%.6f", budget)
)

# ONE VOCABULARY FOR THE FOUR ARCHITECTURES, matching pres4a_architectures.R and
# scripts/figures/conference_deck/talk_architecture.R verbatim.
#
# WHY THIS CHANGED. These four architectures previously carried a different name in each of the
# three figures that show them, and the room left with a takeaway the deck's own mechanism slide
# refuses. The names below are the deck's canonical set and are guarded by the deck repo's
# check/vocabulary_check.R, which reads the string literals of every producer the deck embeds.
#
# The line breaks are placement, not content. Axis category labels have roughly a quarter of a
# half-canvas each, so every name wraps to three lines and no line runs past twelve characters.
# The check normalises whitespace before comparing.
ARCH_LABELS <- c(
  single              = "Commit\nearly",
  parallel             = "Keep both\nthrough\nconfirmation",
  select_exclude       = "Select one,\nthen restart\nevidence",
  select_incorporate   = "Select one,\nthen reuse\nevidence"
)

# THE PANEL ORDER IS READ FROM THE ARTIFACT, NOT TYPED TWICE. `design_stage` carries the
# architectures in EXP8_ARCH_TREE's structural order, dose count then presence of a selection
# stage then permeability of the boundary, and that order encodes no ranking. Deriving both
# panels from it is what makes them agree, rather than two hand-typed vectors that agreed until
# one of them was edited.
ARCH_ORDER <- ds$arch
stopifnot("the artifact must carry exactly the four named architectures, once each" =
            setequal(ARCH_ORDER, names(ARCH_LABELS)) && !anyDuplicated(ARCH_ORDER))

# ================================================================================================
# PANEL A. "Without a common budget." Orange reference line, plainly labeled, no sentence
# overlay.
# ================================================================================================

panel_a_arch_order <- ARCH_ORDER
panel_a_data <- data.frame(
  arch = factor(ds$arch, levels = panel_a_arch_order, labels = ARCH_LABELS[panel_a_arch_order]),
  e_n_ii_alt = ds$e_n_ii_alt
)

panel_a <- ggplot(panel_a_data, aes(x = arch, y = e_n_ii_alt)) +
  geom_col(fill = PAL$comparator, width = 0.62) +
  geom_hline(yintercept = budget, color = PAL$discarded, linewidth = 1.1, linetype = "solid") +
  annotate("text", x = 4.0, y = budget, label = sprintf("Common budget = %.1f", budget),
           hjust = 1, vjust = -0.6, size = 5.2, color = PAL$discarded, fontface = "bold") +
  geom_text(aes(label = sprintf("%.1f", e_n_ii_alt)), vjust = -0.6, size = 6.2, color = PAL$ink) +
  scale_y_continuous(limits = c(0, max(panel_a_data$e_n_ii_alt) * 1.18),
                      expand = expansion(mult = c(0, 0.02))) +
  labs(title = "Without a common budget", x = NULL,
       y = "Expected phase II enrollment\n(patients, unconstrained)") +
  theme_arpa(base_size = 20) +
  theme(
    plot.title = element_text(size = rel(1.1), face = "bold", color = PAL$ink,
                               margin = margin(b = 6), hjust = 0),
    panel.grid.major.x = element_blank(),
    axis.text.x = element_text(lineheight = 0.9, size = rel(0.78))
  )

# ================================================================================================
# PANEL B. "With the same 36-patient budget."
#
# ORDER NOW MATCHES PANEL A, which is a change from fig6. The two panels ranked the same
# strategies differently, so a viewer could not follow one strategy from the left panel to the
# right one and had to re-read the category labels twice. Panel B carries the three strategies
# that spend the budget, which is panel A's order with the budget donor removed, and it is
# derived from ARCH_ORDER rather than typed so the two panels cannot drift apart.
#
# WHAT IS UNCHANGED FROM fig6, and must stay unchanged. No sort by attained value and no
# emphasis color on the largest value. The declared order encodes no ranking, and sorting the
# bars by outcome would assert one.
# ================================================================================================

arch_order <- ARCH_ORDER[ARCH_ORDER != "single"]
stopifnot("panel B must be panel A's order with the budget donor removed" =
            length(arch_order) == 3L && !("single" %in% arch_order))
attained_power <- c(
  select_exclude     = stress$select_results$select_exclude$reported$e2_attained_power,
  select_incorporate = stress$select_results$select_incorporate$reported$e2_attained_power,
  parallel            = stress$parallel_result$reported$e2_attained_power
)
unconstrained_power <- stress_unc_power[arch_order]

panel_b_data <- data.frame(
  arch = factor(arch_order, levels = arch_order, labels = ARCH_LABELS[arch_order]),
  attained = unname(attained_power[arch_order]),
  unconstrained = unname(unconstrained_power)
)

panel_b_title <- sprintf("With the same %d-patient budget", round(budget))

# THE KEY IS DRAWN INSIDE THE ARTWORK, and it is drawn because the open markers were unexplained.
# Every one of them sits near 0.90, close enough that a viewer reads them as a nominal power
# target the panel is asserting rather than as three separate designed operating points. They are
# each strategy's own power at its own unconstrained spend, which is what makes the drop below
# them a cost rather than a shortfall against an external standard.
#
# The key rows carry the marks themselves and not just words, so the panel stays readable
# detached from any caption and survives a greyscale print.
#
# SIZED FOR ROOM DISTANCE, not for a laptop. The key was the SMALLEST text on the panel at size
# 4.6, smaller than the axis categories and well under the bold value labels, while being the only
# thing on the panel that explains what the pale circles are. On this figure's slide placement, a
# 13.3 by 7.5 inch canvas shown at 520 of 720 canvas pixels high, size 4.6 lands near 1.7 percent
# of slide height, and roughly 2 percent is the floor for comfortable reading at the back of a
# room. Size 6.0 puts the key at parity with the bold attained-power labels, which are legible.
#
# The label keeps every word it had. Enlarging it on one line would have run it off the panel, so
# it wraps to two lines and the rows move apart to make room, rather than the wording being cut
# down to fit. The mark sizes grow with the text and the open circle now matches the plotted
# marker's size exactly, so the key mark and the thing it explains are the same object.
KEY_TEXT_SIZE <- 5.8
KEY_Y_UNC <- 1.23
# The lower key row sits clear of the gridline at 1.0 rather than astride it. The swatch is a key
# mark and a gridline running through it reads as a plotted value.
KEY_Y_ATT <- 1.06
KEY_RECT_HALF_H <- 0.033
KEY_TOP <- 1.36
KEY_X_MARK <- 0.50
KEY_X_TEXT <- 0.62
KEY_UNC_TEXT <- "Power at each strategy's own\nunconstrained spend"
KEY_ATT_TEXT <- "Power on the shared budget"
# Headroom is asserted rather than eyeballed. The key must clear the tallest mark the data draws,
# which is the open marker and the number printed above it.
#
# The upper row is now two lines, so the panel ceiling has to clear the TOP of that text block and
# not merely its centre, which is what a bare KEY_TOP > KEY_Y_UNC would have checked. The half
# height is estimated from the point size and the line count, converted through the panel's own
# y-range, so enlarging the text again cannot silently push the first line off the canvas.
KEY_PANEL_H_IN <- 5.6          # panel B's drawing height, net of title, caption, axis and margins
key_lines <- lengths(regmatches(KEY_UNC_TEXT, gregexpr("\n", KEY_UNC_TEXT))) + 1L
key_half_h <- (key_lines * KEY_TEXT_SIZE * .pt * 1.2 / 72) / KEY_PANEL_H_IN * KEY_TOP / 2
stopifnot("the key must sit above every plotted marker" =
            KEY_Y_ATT > max(panel_b_data$unconstrained) + 0.06,
          "the panel ceiling must clear the top line of the two-line key label" =
            KEY_TOP > KEY_Y_UNC + key_half_h,
          "the two key rows must not overlap" =
            KEY_Y_UNC - key_half_h > KEY_Y_ATT + key_half_h / key_lines,
          "the lower key swatch must clear the topmost gridline, not straddle it" =
            KEY_Y_ATT - KEY_RECT_HALF_H > 1.0)

panel_b <- ggplot(panel_b_data, aes(x = arch)) +
  geom_segment(aes(xend = arch, y = unconstrained, yend = attained),
               color = PAL$comparator, linewidth = 3.4, lineend = "round", alpha = 0.55) +
  geom_point(aes(y = unconstrained), shape = 21, size = 6.4, stroke = 1.2,
             fill = PAL$paper, color = PAL$comparator, alpha = 0.55) +
  geom_col(aes(y = attained), fill = PAL$retained, width = 0.42) +
  geom_text(aes(y = attained, label = sprintf("%.3f", attained)),
            vjust = -0.7, size = 6.0, color = PAL$ink, fontface = "bold") +
  geom_text(aes(y = unconstrained, label = sprintf("%.2f", unconstrained)),
            vjust = -1.1, size = 4.4, color = PAL$comparator) +
  # The key MARK keeps the plotted marker's exact appearance, same shape, fill, color and alpha,
  # and now its exact size too, because the mark is what identifies the thing being explained. The
  # key TEXT is darkened off PAL$comparator, which is a pale gray that survives a laptop and not a
  # projector. Contrast is a legibility property of the label and carries no encoding, so raising
  # it costs nothing, and the open circle beside it still carries the identity on its own.
  annotate("point", x = KEY_X_MARK, y = KEY_Y_UNC, shape = 21, size = 6.4, stroke = 1.2,
           fill = PAL$paper, color = PAL$comparator, alpha = 0.55) +
  annotate("text", x = KEY_X_TEXT, y = KEY_Y_UNC, label = KEY_UNC_TEXT, hjust = 0, vjust = 0.5,
           size = KEY_TEXT_SIZE, color = "#5A5A5A", lineheight = 0.95) +
  annotate("rect", xmin = KEY_X_MARK - 0.062, xmax = KEY_X_MARK + 0.062,
           ymin = KEY_Y_ATT - KEY_RECT_HALF_H, ymax = KEY_Y_ATT + KEY_RECT_HALF_H,
           fill = PAL$retained) +
  annotate("text", x = KEY_X_TEXT, y = KEY_Y_ATT, label = KEY_ATT_TEXT, hjust = 0,
           size = KEY_TEXT_SIZE, color = PAL$ink) +
  scale_y_continuous(limits = c(0, KEY_TOP), breaks = seq(0, 1, 0.2),
                      expand = expansion(mult = c(0, 0.02))) +
  labs(title = panel_b_title, x = NULL, y = "Confirmatory power") +
  theme_arpa(base_size = 20) +
  theme(
    plot.title = element_text(size = rel(1.1), face = "bold", color = PAL$ink,
                               margin = margin(b = 6), hjust = 0),
    panel.grid.major.x = element_blank(),
    axis.text.x = element_text(lineheight = 0.9, size = rel(0.78))
  )

# ================================================================================================
# JARGON CHECK
# ================================================================================================

rendered_text <- c(
  "Preserving options has a cost. The question is where to pay it.",
  "Without a common budget",
  as.character(panel_a_data$arch),
  sprintf("Common budget = %.1f", budget),
  "Expected phase II enrollment\n(patients, unconstrained)",
  sprintf("%.1f", panel_a_data$e_n_ii_alt),
  panel_b_title,
  as.character(panel_b_data$arch),
  KEY_UNC_TEXT,
  KEY_ATT_TEXT,
  "Confirmatory power",
  sprintf("%.3f", panel_b_data$attained),
  sprintf("%.2f", panel_b_data$unconstrained)
)
banned_tokens <- c("E1", "E2", "arch", "select_exclude", "select_incorporate",
                    "traversal_complete", "exp8", "stress.rds", "architectures.rds",
                    "BATOND", "guard_demonstrations", "unconstrained_reproduces_design_stage")
jargon_hits <- lapply(banned_tokens, function(tok) {
  hit_strings <- rendered_text[grepl(tok, rendered_text, fixed = TRUE)]
  if (length(hit_strings) > 0) list(token = tok, strings = hit_strings) else NULL
})
jargon_hits <- Filter(Negate(is.null), jargon_hits)
if (length(jargon_hits) > 0) {
  for (h in jargon_hits) cat("  token '", h$token, "' in: ", paste(h$strings, collapse = "; "), "\n", sep = "")
}
stopifnot(length(jargon_hits) == 0)
cat("[pres6] jargon check PASSED.\n")

# ================================================================================================
# ASSEMBLE
# ================================================================================================

library(patchwork)

combined <- (panel_a + panel_b) +
  plot_layout(ncol = 2) +
  plot_annotation(
    caption = "Preserving options has a cost. The question is where to pay it.",
    theme = theme_arpa(base_size = 19) + theme(
      plot.caption = element_text(size = rel(1.15), color = PAL$ink, hjust = 0.5,
                                   face = "italic", margin = margin(t = 14))
    )
  )

result <- save_figure(combined, FIG_ID, width_in = 13.333, height_in = 7.5)
print(result)
