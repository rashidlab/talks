# FIGURE 6, id = "fig6_no_free_optionality"
#
# Two panels. Panel A: natural (unconstrained) expected phase-II enrollment by architecture,
# against the single-arch budget. Panel B: attainable E2 power under that common budget for the
# three two-dose architectures, shown as a fall from unconstrained power, with no ranking among
# the three and no inferential decoration between them.
#
# Data: results/exp8_stress.rds (search/certification results, budget) and
#       results/exp8_architectures.rds (design_stage, unconstrained natural values).

suppressPackageStartupMessages({
  library(ggplot2)
  library(grid)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

stress <- readRDS(file.path(ROOT, "results", "exp8_stress.rds"))
arch   <- readRDS(file.path(ROOT, "results", "exp8_architectures.rds"))

# ================================================================================================
# MANDATORY PRE-PLOT GATE. Must run and print output before any plotting code executes. Hard
# stop on any failed assertion, per the owner spec's "if any refusal state is present STOP
# rather than plot".
# ================================================================================================

cat("=====================================================================\n")
cat("FIGURE fig6_no_free_optionality PRE-PLOT GATE\n")
cat("=====================================================================\n")

# --- 1. status and traversal_complete -----------------------------------------------------

status_ok <- all(stress$summary$status == "feasible_design_found")
cat("1a. all(summary$status == 'feasible_design_found'):", status_ok, "\n")
cat("    summary$status values:", paste(stress$summary$status, collapse = ", "), "\n")
stopifnot(status_ok)

tc_select_exclude     <- stress$select_results$select_exclude$traversal_complete
tc_select_incorporate <- stress$select_results$select_incorporate$traversal_complete
tc_parallel           <- stress$parallel_result$traversal_complete

cat("1b. traversal_complete, select_exclude:    ", tc_select_exclude, "\n")
cat("    traversal_complete, select_incorporate:", tc_select_incorporate, "\n")
cat("    traversal_complete, parallel:          ", tc_parallel, "\n")
stopifnot(isTRUE(tc_select_exclude), isTRUE(tc_select_incorporate), isTRUE(tc_parallel))

# --- 2. guard_demonstrations ------------------------------------------------------------------

guard_ok <- isTRUE(stress$guard_demonstrations$all_as_declared)
cat("2. guard_demonstrations$all_as_declared:", guard_ok, "\n")
stopifnot(guard_ok)

# --- 3. cross-check unconstrained values against design_stage --------------------------------

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

# unconstrained_reproduces_design_stage, checked on summary and each of the three sub-lists
urds_summary <- stress$summary$unconstrained_reproduces_design_stage
urds_select_exclude     <- stress$select_results$select_exclude$unconstrained_reproduces_design_stage
urds_select_incorporate <- stress$select_results$select_incorporate$unconstrained_reproduces_design_stage
urds_parallel           <- stress$parallel_result$unconstrained_reproduces_design_stage

cat("3b. unconstrained_reproduces_design_stage present:\n")
cat("    summary$unconstrained_reproduces_design_stage:      ", paste(urds_summary, collapse = ", "), "\n")
cat("    select_results$select_exclude$...:                  ", urds_select_exclude, "\n")
cat("    select_results$select_incorporate$...:               ", urds_select_incorporate, "\n")
cat("    parallel_result$...:                                 ", urds_parallel, "\n")
stopifnot(
  all(urds_summary), isTRUE(urds_select_exclude), isTRUE(urds_select_incorporate), isTRUE(urds_parallel)
)

# --- 4. the budget scalar ----------------------------------------------------------------------

budget <- stress$budget
cat("4a. exp8_stress.rds$budget (read once):", sprintf("%.10f", budget), "\n")
stopifnot(is.numeric(budget), length(budget) == 1, !is.na(budget))
stopifnot(abs(budget - 36.07154) < 1e-3)

budget_prov_value <- stress$budget_provenance$value
cat("4b. exp8_stress.rds$budget_provenance$value:", sprintf("%.10f", budget_prov_value), "\n")
cat("    budget_provenance$source:      ", stress$budget_provenance$source, "\n")
cat("    budget_provenance$object_path: ", stress$budget_provenance$object_path, "\n")
cat("    budget_provenance$row_filter:  ", stress$budget_provenance$row_filter, "\n")
cat("    budget_provenance$column:      ", stress$budget_provenance$column, "\n")
stopifnot(identical(budget, budget_prov_value))
cat("    CONFIRMED: budget == budget_provenance$value, both sourced from design_stage's\n")
cat("    arch == 'single' row, column e_n_ii_alt.\n")

# Confirm this matches design_stage's own single row directly, as a final triangulation
ds_single_n <- ds[ds$arch == "single", "e_n_ii_alt"]
cat("    design_stage arch=='single' e_n_ii_alt (independent check):", sprintf("%.10f", ds_single_n), "\n")
stopifnot(abs(budget - ds_single_n) < 1e-6)

# --- refusal-state scan --------------------------------------------------------------------

refusal_hit <- any(grepl("search_domain_failure", stress$summary$status, fixed = TRUE))
cat("5. refusal-state ('search_domain_failure') present in summary$status:", refusal_hit, "\n")
stopifnot(!refusal_hit)

cat("=====================================================================\n")
cat("GATE PASSED. Proceeding to plot.\n")
cat("=====================================================================\n")

# ================================================================================================
# JARGON-FREE LABELS. Mid-build coordinator ruling: no acronym, experiment number, internal
# object name, or shorthand (E1/E2, arch tokens, "traversal_complete", etc.) may appear on the
# RENDERED page. Those tokens stay in code, comments, and console/report output only. One named
# vector below is the single source of the plain-language architecture names, used identically
# in both panels so the same architecture reads the same way everywhere on the figure.
# ================================================================================================

ARCH_LABELS <- c(
  single              = "Commit to\none dose",
  parallel             = "Confirm\nboth doses",
  select_exclude       = "Fresh-\nconfirmation",
  select_incorporate   = "Evidence-\nreuse"
)

# ================================================================================================
# PANEL A. Natural (unconstrained) expected phase-II enrollment by architecture, all four
# architectures, from exp8_architectures.rds$design_stage. Budget reference line uses the SAME
# `budget` variable read once above, for all three (in fact all four) architecture rows, no
# per-arch reconstruction.
# ================================================================================================

panel_a_arch_order <- c("single", "parallel", "select_exclude", "select_incorporate")
panel_a_data <- data.frame(
  arch = factor(
    ds$arch,
    levels = panel_a_arch_order,
    labels = ARCH_LABELS[panel_a_arch_order]
  ),
  e_n_ii_alt = ds$e_n_ii_alt
)

cat("\nPanel A bar heights (full precision):\n")
print(panel_a_data, digits = 10)
cat("Panel A budget reference line x-position (the single `budget` variable, identical for all rows):",
    sprintf("%.10f", budget), "\n")

panel_a <- ggplot(panel_a_data, aes(x = arch, y = e_n_ii_alt)) +
  geom_col(fill = PAL$comparator, width = 0.62) +
  geom_hline(yintercept = budget, color = PAL$discarded, linewidth = 1.0, linetype = "solid") +
  annotate(
    "segment",
    x = 2.5, xend = 2.5, y = budget + 3, yend = budget + 17,
    color = PAL$discarded, linewidth = 0.7
  ) +
  annotate(
    "text",
    x = 2.5, y = budget + 19,
    label = sprintf("Budget = %.1f patients\n(what committing to one dose naturally needs)", budget),
    hjust = 0.5, vjust = 0, size = 4.6, color = PAL$discarded, fontface = "bold"
  ) +
  geom_text(
    aes(label = sprintf("%.1f", e_n_ii_alt)),
    vjust = -0.6, size = 5.2, color = PAL$ink
  ) +
  scale_y_continuous(
    limits = c(0, max(panel_a_data$e_n_ii_alt) * 1.18),
    expand = expansion(mult = c(0, 0.02))
  ) +
  labs(
    title = "Natural enrollment, no budget",
    x = NULL,
    y = "Expected phase II enrollment\n(patients, unconstrained)"
  ) +
  theme_arpa(base_size = 19) +
  theme(
    plot.title = element_text(size = rel(1.0), face = "bold", color = PAL$ink,
                               margin = margin(b = 6), hjust = 0),
    panel.grid.major.x = element_blank(),
    axis.text.x = element_text(lineheight = 0.9, size = rel(0.72))
  )

# ================================================================================================
# PANEL B. Attained E2 power under the common budget, three two-dose architectures only. Pale
# reference markers show unconstrained power for the same three. Fixed, non-performance-derived
# order: the order the three architectures appear in exp8_stress.rds$summary, which is
# select_exclude, select_incorporate, parallel. No sort by attained value. No emphasis color,
# no size difference, no bold label singling out any one architecture.
# ================================================================================================

arch_order <- c("select_exclude", "select_incorporate", "parallel")

attained_power <- c(
  select_exclude     = stress$select_results$select_exclude$reported$e2_attained_power,
  select_incorporate = stress$select_results$select_incorporate$reported$e2_attained_power,
  parallel            = stress$parallel_result$reported$e2_attained_power
)
unconstrained_power <- stress_unc_power[arch_order]

cat("\nPanel B attained e2_attained_power (full precision, object values, order =",
    paste(arch_order, collapse = " -> "), "):\n")
print(attained_power, digits = 10)
cat("Panel B unconstrained e2_attained_power reference (full precision):\n")
print(unconstrained_power, digits = 10)

panel_b_data <- data.frame(
  arch = factor(arch_order, levels = arch_order, labels = ARCH_LABELS[arch_order]),
  attained = unname(attained_power[arch_order]),
  unconstrained = unname(unconstrained_power)
)

# Panel B title states the shared budget in plain language, rounded for display, sourced from
# the same `budget` scalar read once in the gate above (not re-derived). Both title and subtitle
# are hard-wrapped to the panel's narrower width so they never overrun into Panel A's space.
panel_b_title_raw <- sprintf(
  "What confirmatory power is achievable with the same %d-patient budget?",
  round(budget)
)
panel_b_subtitle_raw <- "Preserving dose options remains possible, but it costs power when the patient budget is fixed."
panel_b_title    <- paste(strwrap(panel_b_title_raw, width = 34), collapse = "\n")
panel_b_subtitle <- paste(strwrap(panel_b_subtitle_raw, width = 44), collapse = "\n")

panel_b <- ggplot(panel_b_data, aes(x = arch)) +
  # the fall: one shared, strong visual treatment common to all three, drawn first so it
  # sits beneath everything else
  geom_segment(
    aes(xend = arch, y = unconstrained, yend = attained),
    color = PAL$comparator, linewidth = 3.2, lineend = "round", alpha = 0.55
  ) +
  # pale unconstrained reference markers, visually secondary, identical treatment across arch
  geom_point(
    aes(y = unconstrained),
    shape = 21, size = 6, stroke = 1.1,
    fill = PAL$paper, color = PAL$comparator, alpha = 0.55
  ) +
  # attained power, the primary bars, identical fill/weight across all three architectures
  geom_col(aes(y = attained), fill = PAL$retained, width = 0.42) +
  geom_text(
    aes(y = attained, label = sprintf("%.3f", attained)),
    vjust = -0.7, size = 5.4, color = PAL$ink, fontface = "bold"
  ) +
  geom_text(
    aes(y = unconstrained, label = sprintf("%.2f", unconstrained)),
    vjust = -1.1, size = 4.0, color = PAL$comparator
  ) +
  scale_y_continuous(
    limits = c(0, 1.0), breaks = seq(0, 1, 0.2),
    expand = expansion(mult = c(0, 0.05))
  ) +
  labs(
    title = panel_b_title,
    subtitle = panel_b_subtitle,
    x = NULL,
    y = "Confirmatory power"
  ) +
  theme_arpa(base_size = 19) +
  theme(
    plot.title = element_text(size = rel(0.68), face = "bold", color = PAL$ink,
                               margin = margin(b = 4), hjust = 0),
    plot.subtitle = element_text(size = rel(0.62), color = "#3A3A3A",
                                  margin = margin(b = 10), hjust = 0),
    panel.grid.major.x = element_blank(),
    axis.text.x = element_text(lineheight = 0.9, size = rel(0.72))
  )

# ================================================================================================
# JARGON CHECK. Every piece of literal text placed on the rendered page, collected and scanned
# for banned internal tokens (E1/E2, raw arch names, object/field names, experiment numbers).
# This runs against the STRINGS THEMSELVES, not against the rendered pixels, but it is exhaustive
# over every text-producing call in the script above.
# ================================================================================================

overall_title   <- "Preserving dose options has a cost"
overall_caption <- "The question is where to pay for it."

rendered_text <- c(
  overall_title,
  overall_caption,
  "Natural enrollment, no budget",                 # panel A title
  as.character(panel_a_data$arch),                 # panel A tick labels
  sprintf("Budget = %.1f patients\n(what committing to one dose naturally needs)", budget),
  "Expected phase II enrollment\n(patients, unconstrained)",  # panel A y axis
  sprintf("%.1f", panel_a_data$e_n_ii_alt),         # panel A bar labels
  panel_b_title,
  panel_b_subtitle,
  as.character(panel_b_data$arch),                 # panel B tick labels
  "Confirmatory power",                             # panel B y axis
  sprintf("%.3f", panel_b_data$attained),           # panel B attained labels
  sprintf("%.2f", panel_b_data$unconstrained)       # panel B pale reference labels
)

banned_tokens <- c(
  "E1", "E2", "arch", "select_exclude", "select_incorporate",
  "traversal_complete", "exp8", "stress.rds", "architectures.rds",
  "BATOND", "guard_demonstrations", "unconstrained_reproduces_design_stage"
)

jargon_hits <- lapply(banned_tokens, function(tok) {
  hit_strings <- rendered_text[grepl(tok, rendered_text, fixed = TRUE)]
  if (length(hit_strings) > 0) list(token = tok, strings = hit_strings) else NULL
})
jargon_hits <- Filter(Negate(is.null), jargon_hits)

cat("\n=====================================================================\n")
cat("JARGON CHECK over every rendered text string\n")
cat("=====================================================================\n")
cat("Rendered strings checked (", length(rendered_text), " total):\n", sep = "")
for (s in rendered_text) cat("  - ", gsub("\n", " / ", s), "\n", sep = "")
if (length(jargon_hits) == 0) {
  cat("RESULT: PASS. No banned internal token found in any rendered string.\n")
} else {
  cat("RESULT: FAIL. Banned tokens found:\n")
  for (h in jargon_hits) cat("  token '", h$token, "' in: ", paste(h$strings, collapse = "; "), "\n", sep = "")
}
stopifnot(length(jargon_hits) == 0)

# ================================================================================================
# ASSEMBLE. Two panels side by side, shared title, required annotation text present verbatim.
# ================================================================================================

library(patchwork)

combined <- (panel_a + panel_b) +
  plot_layout(ncol = 2) +
  plot_annotation(
    title = "Preserving dose options has a cost",
    caption = "The question is where to pay for it.",
    theme = theme_arpa(base_size = 19) + theme(
      plot.title = element_text(size = rel(1.55), face = "bold", color = PAL$ink,
                                 margin = margin(b = 4), hjust = 0),
      plot.caption = element_text(size = rel(1.05), color = PAL$ink, hjust = 0,
                                   face = "italic", margin = margin(t = 14))
    )
  )

result <- save_figure(combined, "fig6_no_free_optionality", width_in = 13.333, height_in = 7.5)

cat("\nFinal file paths:\n")
print(result)
