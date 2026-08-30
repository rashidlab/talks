# PRESENTATION VARIANT of fig3_pcs_wrong_policy.R, WITHOUT the inset.
#
# id = "pres3_pcs_wrong_policy"
#
# Data loading, filtering, the identical-values assertion, the collapse to six distinct design
# strategies, the slope-direction verification table, and the persistence check below are copied
# from the archival fig3 script (same objects: results/exp7_compose.rds$design,
# results/exp7_persistence.rds). The inset decision-tree diagram and its source object
# (results/exp7_q3_primary.rds) are NOT read here, that content moved to pres3b entirely, per the
# owner's ten-variant specification. Simplification from the archival figure is otherwise visual
# only: left-column labels drop their parenthetical percentages (the plotted point already shows
# the value), and the freed vertical space left by the removed inset is not repurposed with new
# content.

suppressPackageStartupMessages({
  library(ggplot2)
  library(ggrepel)
  library(grid)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

FIG_ID <- "pres3_pcs_wrong_policy"

# ------------------------------------------------------------------------------------------
# 1. LOAD AND FILTER, identical to fig3_pcs_wrong_policy.R.
# ------------------------------------------------------------------------------------------

compose <- readRDS(file.path(ROOT, "results", "exp7_compose.rds"))
design  <- compose$design

sub <- design[design$module == "primary" &
              design$inferential_role == "PRIMARY_INFERENTIAL_SET", ]

cat("[pres3] rows after filter:", nrow(sub), " distinct policy_id:", length(unique(sub$policy_id)), "\n")

stopifnot(nrow(sub) == 9)
stopifnot(length(unique(sub$policy_id)) == 6)
stopifnot(all(grepl("application\\|OBD_monotone", sub$key, fixed = FALSE)))
cat("[pres3] Confirmed: all 9 rows carry key containing 'application|OBD_monotone'.\n")

# ------------------------------------------------------------------------------------------
# 2. IDENTICAL-VALUES ASSERTION FOR REPEATED policy_id, BEFORE ANY COLLAPSING
# ------------------------------------------------------------------------------------------

sub <- sub[order(sub$policy_id, sub$w), ]

for (pid in unique(sub$policy_id)) {
  rows <- sub[sub$policy_id == pid, ]
  if (nrow(rows) > 1) {
    stopifnot(length(unique(rows$PCShat)) == 1L)
    stopifnot(length(unique(rows$POShat)) == 1L)
  }
}
cat("[pres3] ASSERTION PASSED: every repeated policy_id has bit-identical PCShat and POShat\n")

# ------------------------------------------------------------------------------------------
# 3. COLLAPSE TO ONE ROW PER DISTINCT policy_id
#
# weight_phrase() text updated per the owner's presentation-variant wording ("lower average /
# lower worst-case enrollment" instead of "smaller average / smaller worst-case enrollment",
# "same strategy across settings" instead of "unaffected by the enrollment trade-off setting").
# The label-construction LOGIC (fam_label + trade_label, combo phrasing via paste(collapse=" or"))
# is unchanged from fig3, only the phrase strings differ, and produces exactly the six labels the
# owner specified in the brief.
# ------------------------------------------------------------------------------------------

weight_phrase <- function(w) {
  if (isTRUE(all.equal(w, 0)))   return("lower worst-case enrollment")
  if (isTRUE(all.equal(w, 1)))   return("lower average enrollment")
  if (isTRUE(all.equal(w, 0.5))) return("balanced")
  stop("unexpected weight value: ", w)
}

collapsed <- do.call(rbind, lapply(split(sub, sub$policy_id), function(rows) {
  ws <- sort(rows$w)
  fam_label <- switch(rows$family[1],
                       boin = "BOIN",
                       boin12 = "BOIN12",
                       uboin = "U-BOIN",
                       rows$family[1])
  if (length(ws) == 3) {
    trade_label <- "same strategy across settings"
  } else if (length(ws) == 2) {
    phrases <- vapply(ws, weight_phrase, character(1))
    trade_label <- paste(phrases, collapse = " or ")
  } else {
    trade_label <- weight_phrase(ws)
  }
  data.frame(
    policy_id = rows$policy_id[1],
    family = rows$family[1],
    fam_label = fam_label,
    trade_label = trade_label,
    label = paste0(fam_label, ", ", trade_label),
    PCShat = rows$PCShat[1],
    POShat = rows$POShat[1],
    n_weights = nrow(rows),
    stringsAsFactors = FALSE
  )
}))
rownames(collapsed) <- NULL

stopifnot(nrow(collapsed) == 6)
cat("[pres3] Collapsed to", nrow(collapsed), "distinct-design-strategy lines:\n")
print(collapsed[, c("policy_id", "family", "label", "PCShat", "POShat")], row.names = FALSE)

expected_labels <- c(
  "BOIN12, lower average enrollment", "BOIN12, balanced", "BOIN12, lower worst-case enrollment",
  "BOIN, same strategy across settings",
  "U-BOIN, lower average enrollment", "U-BOIN, lower worst-case enrollment or balanced"
)
stopifnot(setequal(collapsed$label, expected_labels))
cat("[pres3] ASSERTION PASSED: the six collapsed labels match the owner's exact wording.\n")

# ------------------------------------------------------------------------------------------
# 4. SLOPE-DIRECTION VERIFICATION
# ------------------------------------------------------------------------------------------

collapsed$PCS_rank <- rank(-collapsed$PCShat, ties.method = "first")
collapsed$POS_rank <- rank(-collapsed$POShat, ties.method = "first")
collapsed$rank_crosses <- collapsed$PCS_rank != collapsed$POS_rank

cat("[pres3] Number of design strategies whose column-1 rank != column-2 rank (rank-crossing):",
    sum(collapsed$rank_crosses), "out of", nrow(collapsed), "\n")

stopifnot(nrow(collapsed) == length(unique(collapsed$policy_id)))
stopifnot(all(collapsed$PCS_rank %in% seq_len(nrow(collapsed))))
stopifnot(all(collapsed$POS_rank %in% seq_len(nrow(collapsed))))

# ------------------------------------------------------------------------------------------
# 5. PERSISTENCE ANNOTATION (the one robustness sentence), scoped to the boin12 w=0.5 vs
#    boin12 w=0 pair only, identical to fig3.
# ------------------------------------------------------------------------------------------

persist <- readRDS(file.path(ROOT, "results", "exp7_persistence.rds"))

pair_sub <- persist[grepl("boin12", persist$A, fixed = TRUE) &
                     grepl("0.5", persist$A, fixed = TRUE) &
                     grepl("boin12", persist$B, fixed = TRUE) &
                     grepl("0", persist$B, fixed = TRUE) &
                     !grepl("0.5", persist$B, fixed = TRUE), ]

stopifnot(nrow(pair_sub) == 6)
stopifnot(all(pair_sub$holds == TRUE))
cat("[pres3] ASSERTION PASSED: holds == TRUE on all 6 modules for the boin12 w=0.5 vs w=0 pair.\n")

persistence_annotation <- paste0(
  "The key ranking reversal persists under all 6 alternative assumptions\n",
  "about later-stage performance."
)

verify_banner(
  figure_id = FIG_ID,
  source_artifact = "results/exp7_compose.rds$design, results/exp7_persistence.rds",
  producer = "scripts/figures/arpa_stats_meeting/pres3_pcs_wrong_policy.R (cut from fig3_pcs_wrong_policy.R, inset removed)",
  fields = c("policy_id", "family", "w", "PCShat", "POShat", "A/B/module/dPCS/dPOS/holds"),
  expected = "9 rows / 6 distinct policy_id; 6/6 persistence holds for boin12 w=0.5 vs w=0",
  observed = sprintf("%d rows / %d distinct policy_id; %d/6 persistence holds",
                      nrow(sub), length(unique(sub$policy_id)), sum(pair_sub$holds))
)

# ------------------------------------------------------------------------------------------
# 6. COLORS, identical palette to fig3.
# ------------------------------------------------------------------------------------------

POLICY_COLORS <- c("#E69F00", "#56B4E9", "#F0E442", "#CC79A7", "#000000", "#7F3C8D")

collapsed <- collapsed[order(collapsed$PCS_rank), ]
collapsed$color <- POLICY_COLORS[seq_len(nrow(collapsed))]
stopifnot(!any(collapsed$color %in% unlist(PAL[c("retained", "discarded", "comparator", "accent")])))

# ------------------------------------------------------------------------------------------
# 7. LAYOUT GEOMETRY. No inset band required (dropped), only the badge band above the data.
# ------------------------------------------------------------------------------------------

data_y_range <- range(c(collapsed$PCShat, collapsed$POShat))
Y_LO <- data_y_range[1] - 0.14
Y_HI <- 0.97
X_LO <- 0.05
X_HI <- 3.15

BADGE_YMIN <- 0.895
BADGE_YMAX <- Y_HI - 0.01
stopifnot(BADGE_YMIN > data_y_range[2])

# ------------------------------------------------------------------------------------------
# 8. BUILD SLOPEGRAPH. Left labels have NO parenthetical percentage (point value already shown
#    on the axis and by direct proximity); right labels keep one decimal place as in fig3, since
#    several POShat values round to the same whole percent.
# ------------------------------------------------------------------------------------------

left_pts <- data.frame(
  policy_id = collapsed$policy_id,
  label = collapsed$label,
  color = collapsed$color,
  x = 1, y = collapsed$PCShat,
  text = collapsed$label,
  stringsAsFactors = FALSE
)
right_pts <- data.frame(
  policy_id = collapsed$policy_id,
  label = collapsed$label,
  color = collapsed$color,
  x = 2, y = collapsed$POShat,
  text = sprintf("%.1f%%", 100 * collapsed$POShat),
  stringsAsFactors = FALSE
)
long <- rbind(left_pts[, c("policy_id", "label", "color", "x", "y")],
              right_pts[, c("policy_id", "label", "color", "x", "y")])

color_map <- setNames(collapsed$color, collapsed$label)

p_main <- ggplot(long, aes(x = x, y = y, group = label)) +
  geom_line(aes(color = label), linewidth = 1.5, alpha = 0.92) +
  geom_point(aes(color = label), size = 5.0) +
  scale_color_manual(values = color_map, guide = "none") +
  scale_x_continuous(
    limits = c(X_LO, X_HI),
    breaks = c(1, 2),
    labels = c("Chance of selecting\nthe correct dose",
               "Chance of ultimately confirming\nthe correct dose")
  ) +
  scale_y_continuous(
    limits = c(Y_LO, Y_HI),
    breaks = seq(0.5, 0.9, 0.1),
    labels = scales::percent_format(accuracy = 1)
  ) +
  geom_text_repel(
    data = left_pts,
    aes(x = x, y = y, label = text, group = label),
    hjust = 1, direction = "y", nudge_x = -0.62, segment.size = 0.3,
    size = 5.3, color = PAL$ink, fontface = "plain", show.legend = FALSE,
    min.segment.length = 0, seed = 1, box.padding = 0.3
  ) +
  geom_text_repel(
    data = right_pts,
    aes(x = x, y = y, label = text, group = label),
    hjust = 0, direction = "y", nudge_x = 0.30, segment.size = 0.3,
    size = 5.3, color = PAL$ink, show.legend = FALSE,
    min.segment.length = 0, seed = 1, box.padding = 0.3
  ) +
  labs(
    title = NULL,
    subtitle = "Correct-dose selection is an early objective used as a stand-in for ultimate program success.",
    x = NULL,
    y = "Estimated probability"
  ) +
  theme_arpa(base_size = 21) +
  theme(
    axis.text.x = element_text(size = rel(1.0), face = "bold"),
    axis.title.x = element_blank(),
    panel.grid.major.x = element_blank()
  )

# ------------------------------------------------------------------------------------------
# 9. THE ONE ANNOTATION IDENTIFYING THE KEY CROSSING, pointed at the crossing of the
#    persistence-supported pair's own two lines, computed from their verified values.
# ------------------------------------------------------------------------------------------

pos_boin12_low_pcs  <- collapsed$POShat[collapsed$policy_id == "6f01edec4d0fd86b"]
pos_boin12_bal      <- collapsed$POShat[collapsed$policy_id == "fb581c66401e9631"]
pcs_bal <- collapsed$PCShat[collapsed$policy_id == "fb581c66401e9631"]
pcs_low <- collapsed$PCShat[collapsed$policy_id == "6f01edec4d0fd86b"]
t_cross <- (pcs_bal - pcs_low) / ((pcs_bal - pos_boin12_bal) + (pos_boin12_low_pcs - pcs_low))
cross_y <- pcs_bal + t_cross * (pos_boin12_bal - pcs_bal)
callout_df <- data.frame(x = 1.55, y = 0.83, xend = 1 + t_cross, yend = cross_y)

p_main <- p_main +
  geom_curve(
    data = callout_df, aes(x = x, y = y, xend = xend, yend = yend),
    inherit.aes = FALSE, curvature = -0.25, color = "#6A6A6A", linewidth = 0.5,
    arrow = arrow(length = unit(0.11, "in"), type = "closed")
  ) +
  geom_label(
    data = data.frame(x = 1.55, y = 0.83, lab = persistence_annotation),
    aes(x = x, y = y, label = lab),
    inherit.aes = FALSE, hjust = 0.5, vjust = 0, size = 4.5, color = PAL$ink,
    fill = PAL$panel_bg, linewidth = 0.35, lineheight = 1.05
  )

# ------------------------------------------------------------------------------------------
# 10. THE ONE-SCENARIO BADGE (kept, same required text as fig3), no inset below it now.
# ------------------------------------------------------------------------------------------

badge_grob <- grid::grobTree(
  grid::roundrectGrob(
    x = 0.5, y = 0.5, width = 0.98, height = 0.72,
    r = unit(0.15, "snpc"),
    gp = grid::gpar(fill = "#F0F0F0", col = "#B0B0B0", lwd = 1)
  ),
  grid::textGrob(
    APPLICATION_BADGE_TEXT, x = 0.5, y = 0.5,
    gp = grid::gpar(fontsize = 13, col = PAL$ink, fontface = "italic")
  )
)

p_main <- p_main +
  annotation_custom(badge_grob, xmin = 2.25, xmax = X_HI - 0.05, ymin = BADGE_YMIN, ymax = BADGE_YMAX)

out <- save_figure(p_main, FIG_ID, width_in = 15.0, height_in = 8.6)
cat("\nFigure written to:\n")
cat(" ", out$pdf, "\n")
cat(" ", out$svg, "\n")
cat(" ", out$png, "(width", out$png_width_px, "px)\n")

# ------------------------------------------------------------------------------------------
# 11. JARGON CHECK
# ------------------------------------------------------------------------------------------

rendered_strings <- c(
  title = "The locally best design strategy need not be the globally best one",
  subtitle = "Correct-dose selection is an early objective used as a stand-in for ultimate program success.",
  x_axis_left = "Chance of selecting\nthe correct dose",
  x_axis_right = "Chance of ultimately confirming\nthe correct dose",
  y_axis = "Estimated probability",
  persistence_annotation = persistence_annotation,
  badge = APPLICATION_BADGE_TEXT,
  setNames(left_pts$text, paste0("left_label_", seq_len(nrow(left_pts))))
)

forbidden_patterns <- c("PCS", "\\btruth\\b", "\\bcell\\b", "application track",
                         "\\bw *= *0(\\.5)?\\b", "\\bw *= *1\\b", "frozen", "locked")
any_fail <- FALSE
cat("\n===================== JARGON CHECK (rendered-page text only) =====================\n")
for (nm in names(rendered_strings)) {
  s <- rendered_strings[[nm]]
  hits <- sapply(forbidden_patterns, function(pat) grepl(pat, s, ignore.case = TRUE))
  pol_hit <- grepl("\\bpolic(y|ies)\\b", s, ignore.case = TRUE)
  fails <- c(hits, policy = pol_hit)
  if (any(fails)) {
    any_fail <- TRUE
    cat(sprintf("  FAIL  [%s]: %-60s  triggers: %s\n", nm, gsub("\n", " / ", s),
                paste(names(fails)[fails], collapse = ", ")))
  } else {
    cat(sprintf("  ok    [%s]: %s\n", nm, gsub("\n", " / ", s)))
  }
}
cat("=====================================================================================\n")
stopifnot(!any_fail)
cat("[pres3] jargon check PASSED.\n")
