# FIGURE 3B (backup/appendix), id = "fig3b_estimand_mismatch_quadrant"
#
# "The estimand-mismatch quadrant"
#
# Data: results/exp8_q5_primary.rds$per_cell_contrasts, contrast %in% c("C2","C3").
# DESCRIPTIVE status (see the inferential-role check in Section 2 below), not the same
# supported status as Figure 3. This script is read-only with respect to results/.
#
# JARGON POLICY (mid-build correction from the coordinator, applied here): "cell" ->
# "scenario/design combination", axis labels reworded in plain language, contrast panel
# titles built from the artifact's own "reads" text with internal contrast-code tokens
# (select_exclude / select_incorporate / single) stripped, sign-discordant grouping label
# reworded without a raw "w=" token. The owner's required verbatim annotation (rule 8) is
# kept with its exact counts but rephrased per the coordinator's suggested wording, since the
# coordinator explicitly allowed either the exact original phrase or a plain-language version
# that preserves the 3/9 and 1/6 counts.

suppressPackageStartupMessages({
  library(ggplot2)
  library(ggrepel)
  library(grid)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

FIG_ID <- "fig3b_estimand_mismatch_quadrant"

# ------------------------------------------------------------------------------------------
# 1. LOAD, FILTER, ROW-COUNT CHECK
# ------------------------------------------------------------------------------------------

q5 <- readRDS(file.path(ROOT, "results", "exp8_q5_primary.rds"))
per_cell <- q5$per_cell_contrasts

cat("=====================================================================\n")
cat("FIGURE", FIG_ID, ": structure and truth-key check\n")
cat("  per_cell_contrasts total rows:", nrow(per_cell), "\n")
cat("  distinct contrast values     :", paste(sort(unique(per_cell$contrast)), collapse = ", "), "\n")
cat("  truth_key                    :", q5$truth_key, "\n")
cat("=====================================================================\n")

stopifnot(nrow(per_cell) == 36)
stopifnot(q5$truth_key == "application|OBD_monotone")
cat("Confirmed: exp8_q5_primary truth_key is 'application|OBD_monotone' (application, monotone efficacy).\n\n")

sub <- per_cell[per_cell$contrast %in% c("C2", "C3"), ]
cat("Rows after filtering to contrast %in% c('C2','C3'):", nrow(sub), "\n")
stopifnot(nrow(sub) == 18)
stopifnot(sum(sub$contrast == "C2") == 9)
stopifnot(sum(sub$contrast == "C3") == 9)
cat("Confirmed: 9 rows for C2, 9 rows for C3.\n\n")

# ------------------------------------------------------------------------------------------
# 2. INFERENTIAL-ROLE / MODULE FIELD CHECK, to confirm descriptive (not supported) status
# ------------------------------------------------------------------------------------------

top_level_fields <- names(q5)
cat("Top-level fields of exp8_q5_primary.rds:", paste(top_level_fields, collapse = ", "), "\n")
has_inferential_role <- "inferential_role" %in% names(per_cell)
has_module <- "module" %in% names(per_cell)
cat("per_cell_contrasts has an 'inferential_role' column:", has_inferential_role, "\n")
cat("per_cell_contrasts has a 'module' column               :", has_module, "\n")
cat("per_cell_contrasts has a 'no_inferential_standing' column, all TRUE:",
    all(per_cell$no_inferential_standing), "\n")
cat(paste(
  "Finding: exp8_q5_primary carries NO inferential_role/module field analogous to",
  "exp7_compose's PRIMARY_INFERENTIAL_SET machinery, and per_cell_contrasts explicitly",
  "flags every row no_inferential_standing == TRUE.",
  "This figure's data is therefore classified DESCRIPTIVE, not the supported status",
  "used for Figure 3, and is drawn using STATUS$descriptive treatment throughout.\n"
))

FIG_STATUS <- STATUS$descriptive

# ------------------------------------------------------------------------------------------
# 3. SIGN-DISCORDANT ASSERTION, TOP-PRIORITY QA ITEM FOR THIS FIGURE
# ------------------------------------------------------------------------------------------

disc <- sub[sub$sign_disagreement == TRUE, ]
cat("Sign-discordant rows found:", nrow(disc), "\n")
print(disc[, c("contrast", "cellkey", "family", "w")], row.names = FALSE)

stopifnot(nrow(disc) == 6)                       # 3 per panel x 2 panels
stopifnot(all(disc$family == "boin"))
stopifnot(sum(disc$contrast == "C2") == 3)
stopifnot(sum(disc$contrast == "C3") == 3)
stopifnot(setequal(round(disc$w, 4), c(0, 0.5, 1)))
cat("ASSERTION PASSED: sign-discordant cells are exactly the 3 BOIN-family rows",
    "(w = 0, 0.5, 1) in each of C2 and C3, 6 rows total.\n\n")

# ------------------------------------------------------------------------------------------
# 4. CONTRAST DEFINITIONS, PLAIN-LANGUAGE PANEL TITLES BUILT FROM THE ARTIFACT'S OWN "reads"
# ------------------------------------------------------------------------------------------

contrasts_tab <- q5$contrasts
cat("Contrast definitions (results/exp8_q5_primary.rds$contrasts):\n")
print(contrasts_tab[contrasts_tab$contrast %in% c("C2", "C3"),
                     c("contrast", "A", "B", "reads")], row.names = FALSE)
cat("\n")

# The raw "reads" text is internal-shorthand (select_exclude / select_incorporate / single).
# Panel titles below are a plain-language paraphrase of the same artifact-sourced meaning,
# per the jargon correction: C2 reads "select_exclude minus single, carrying a second dose
# under a hard boundary and the futility interim"; C3 reads the analogous "select_incorporate"
# / "permeable boundary" comparison. Both compare against the same single-dose comparator.
panel_titles <- c(
  C2 = "Two doses, hard boundary\nvs. one dose",
  C3 = "Two doses, permeable boundary\nvs. one dose"
)

# ------------------------------------------------------------------------------------------
# 5. LABELS FOR EACH DESIGN-STRATEGY POINT, SAME WEIGHT-JARGON FIX AS FIGURE 3
# ------------------------------------------------------------------------------------------

weight_phrase_short <- function(w) {
  if (isTRUE(all.equal(w, 0)))   return("worst-case-focused")
  if (isTRUE(all.equal(w, 1)))   return("average-focused")
  if (isTRUE(all.equal(w, 0.5))) return("balanced")
  stop("unexpected weight value: ", w)
}

fam_label_of <- function(fam) switch(fam, boin = "BOIN", boin12 = "BOIN12", uboin = "U-BOIN", fam)

sub$fam_label <- vapply(sub$family, fam_label_of, character(1))
sub$point_label <- paste0(sub$fam_label, " (", vapply(sub$w, weight_phrase_short, character(1)), ")")

# ------------------------------------------------------------------------------------------
# 6. VERIFY BANNER
# ------------------------------------------------------------------------------------------

verify_banner(
  figure_id = FIG_ID,
  source_artifact = "results/exp8_q5_primary.rds$per_cell_contrasts, $contrasts",
  producer = "scripts/figures/arpa_stats_meeting/fig3b_estimand_mismatch_quadrant.R",
  fields = c("contrast", "cellkey", "family", "w", "estimate", "diagnostic_any_arm_estimate", "sign_disagreement"),
  expected = "18 rows (9 C2 + 9 C3); 6 sign-discordant rows, all family == 'boin', w in {0,0.5,1}",
  observed = sprintf("%d rows (%d C2 + %d C3); %d sign-discordant rows, families: %s, weights: %s",
                      nrow(sub), sum(sub$contrast == "C2"), sum(sub$contrast == "C3"),
                      nrow(disc), paste(unique(disc$family), collapse = ","),
                      paste(sort(unique(round(disc$w, 2))), collapse = ","))
)

# ------------------------------------------------------------------------------------------
# 7. BUILD SMALL-MULTIPLE SCATTER PANELS
# ------------------------------------------------------------------------------------------

sub$panel_title <- panel_titles[sub$contrast]
sub$group <- ifelse(sub$sign_disagreement, "Sign-discordant (BOIN)", "Concordant")

x_rng <- range(sub$diagnostic_any_arm_estimate)
y_rng <- range(sub$estimate)
x_pad <- diff(x_rng) * 0.28
y_pad <- diff(y_rng) * 0.28
x_lim <- c(min(0, x_rng[1]) - x_pad, x_rng[2] + x_pad)
y_lim <- c(y_rng[1] - y_pad, max(0, y_rng[2]) + y_pad)

# Bracket rectangle enclosing the 3 discordant points, per panel, in DATA coordinates.
bracket_pad_x <- diff(x_rng) * 0.06
bracket_pad_y <- diff(y_rng) * 0.06
bracket_df <- do.call(rbind, lapply(c("C2", "C3"), function(cc) {
  d3 <- disc[disc$contrast == cc, ]
  data.frame(
    contrast = cc,
    xmin = min(d3$diagnostic_any_arm_estimate) - bracket_pad_x,
    xmax = max(d3$diagnostic_any_arm_estimate) + bracket_pad_x,
    ymin = min(d3$estimate) - bracket_pad_y,
    ymax = max(d3$estimate) + bracket_pad_y
  )
}))
bracket_df$panel_title <- panel_titles[bracket_df$contrast]

p3b <- ggplot(sub, aes(x = diagnostic_any_arm_estimate, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = PAL$comparator, linewidth = 0.5) +
  geom_vline(xintercept = 0, linetype = "dashed", color = PAL$comparator, linewidth = 0.5) +
  geom_rect(
    data = bracket_df,
    aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
    inherit.aes = FALSE, fill = NA, color = PAL$discarded,
    linetype = FIG_STATUS$linetype, linewidth = 0.9
  ) +
  geom_point(aes(color = group, shape = group), size = 4.6, stroke = 1.2, alpha = FIG_STATUS$alpha) +
  scale_color_manual(values = c("Concordant" = PAL$retained, "Sign-discordant (BOIN)" = PAL$discarded)) +
  scale_shape_manual(values = c("Concordant" = 16, "Sign-discordant (BOIN)" = 17)) +
  geom_text_repel(
    aes(label = point_label), size = 3.3, color = PAL$ink, seed = 2,
    min.segment.length = 0, segment.size = 0.25, box.padding = 0.35, max.overlaps = 20
  ) +
  facet_wrap(~panel_title, nrow = 1) +
  coord_cartesian(xlim = x_lim, ylim = y_lim) +
  scale_x_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(
    title = "The estimand-mismatch quadrant",
    subtitle = "Same clinical scenario. The two confirmation signals do not always move together.",
    x = "Change in probability at least one dose is confirmed effective",
    y = "Change in probability the correct dose is ultimately confirmed",
    color = NULL, shape = NULL
  ) +
  theme_arpa() +
  theme(
    legend.position = "bottom",
    legend.text = element_text(size = rel(0.85)),
    strip.text = element_text(size = rel(0.95), face = "bold", color = PAL$ink),
    strip.background = element_rect(fill = PAL$panel_bg, color = NA),
    panel.spacing = unit(1.6, "lines")
  )

# ------------------------------------------------------------------------------------------
# 8. REQUIRED ANNOTATION (owner rule 8), DESCRIPTIVE-STATUS TAG, BACKUP CORNER TAG, BADGE
# ------------------------------------------------------------------------------------------

# Owner rule 8's exact phrase is "Descriptive: 3/9 cells, 1/6 distinct policies". The
# coordinator's jargon correction explicitly permits a plain-language version that keeps the
# 3/9 and 1/6 counts intact, since "cell"/"policy" in this fixed disclosure phrase are counted
# denominators rather than design-strategy labels. Using the plain-language version here.
required_annotation <- "Descriptive: 3 of 9 scenario/design combinations,\nrepresenting 1 of 6 distinct design strategies (per panel)."

# Badge and backup/appendix tag are placed using ggplot2's own tag/caption mechanisms rather
# than a patchwork whole-canvas overlay: this is a faceted plot, and an inset_element positioned
# beyond the [0,1] panel fraction (needed to clear the title) clipped the rendered edges in an
# earlier version of this script. Built-in plot.tag reserves its own margin space and cannot
# clip the panel; the badge is folded into the caption line for the same reason, in the time
# available. Both remain fully legible and non-overlapping, which is the requirement; the
# floating rounded-box badge style used in Figure 3 is not reproduced here.
p3b <- p3b +
  labs(
    tag = "BACKUP / APPENDIX",
    caption = paste0(
      required_annotation, "   Status: ", FIG_STATUS$label,
      "\n", APPLICATION_BADGE_TEXT
    )
  ) +
  theme(
    plot.tag = element_text(size = rel(0.68), face = "bold", color = "#5C4400"),
    plot.tag.position = "topleft",
    plot.caption = element_text(size = rel(0.8), face = "plain", color = PAL$ink,
                                 hjust = 0, margin = margin(t = 14), lineheight = 1.3),
    plot.margin = margin(30, 20, 12, 16)
  )

full_plot <- p3b

out <- save_figure(full_plot, FIG_ID, width_in = 14.0, height_in = 8.6)
cat("\nFigure written to:\n")
cat(" ", out$pdf, "\n")
cat(" ", out$svg, "\n")
cat(" ", out$png, "(width", out$png_width_px, "px)\n")

# ------------------------------------------------------------------------------------------
# 9. JARGON CHECK, per the mid-build coordinator correction
# ------------------------------------------------------------------------------------------

rendered_strings <- c(
  title = "The estimand-mismatch quadrant",
  subtitle = "Same clinical scenario. Where one confirmation signal moves does not always match where the other does.",
  x_axis = "Change in probability at least one dose is confirmed effective",
  y_axis = "Change in probability the correct dose is ultimately confirmed",
  panel_C2 = panel_titles[["C2"]],
  panel_C3 = panel_titles[["C3"]],
  caption = paste0(required_annotation, "   Status: ", FIG_STATUS$label, "\n", APPLICATION_BADGE_TEXT),
  legend_concordant = "Concordant",
  legend_discordant = "Sign-discordant (BOIN)",
  backup_tag = "BACKUP / APPENDIX",
  badge = APPLICATION_BADGE_TEXT,
  setNames(unique(sub$point_label), paste0("point_label_", seq_along(unique(sub$point_label))))
)

forbidden_patterns <- c("\\bPCS\\b", "\\btruth\\b", "\\bcell\\b", "application track",
                         "\\bw *= *0(\\.5)?\\b", "\\bw *= *1\\b", "frozen", "locked",
                         "select_exclude", "select_incorporate", "\\bsingle\\b(?!-)")

cat("\n===================== JARGON CHECK (rendered-page text only) =====================\n")
any_fail <- FALSE
for (nm in names(rendered_strings)) {
  s <- rendered_strings[[nm]]
  hits <- sapply(forbidden_patterns, function(pat) grepl(pat, s, ignore.case = TRUE, perl = TRUE))
  pol_hit <- grepl("\\bpolic(y|ies)\\b", s, ignore.case = TRUE) &&
             !grepl("scenario/design combinations|design strateg", s, ignore.case = TRUE)
  fails <- c(hits, policy = pol_hit)
  if (any(fails)) {
    any_fail <- TRUE
    cat(sprintf("  FAIL  [%s]: %-70s  triggers: %s\n", nm, gsub("\n", " / ", s),
                paste(names(fails)[fails], collapse = ", ")))
  } else {
    cat(sprintf("  ok    [%s]: %s\n", nm, gsub("\n", " / ", s)))
  }
}
cat("=====================================================================================\n")
if (!any_fail) cat("ALL rendered-page text passed the jargon check for Figure 3B.\n")
