# FIGURE 3 (centerpiece), id = "fig3_pcs_wrong_policy"
#
# "The locally best policy need not be the globally best policy"
#
# Data: results/exp7_compose.rds$design, module == "primary" &
# inferential_role == "PRIMARY_INFERENTIAL_SET". Empirical, supported, frozen artifact.
# This script is read-only with respect to results/.
#
# JARGON POLICY (mid-build correction from the coordinator, applied here): rendered text uses
# plain language, not internal shorthand. "policy" -> "design strategy", "PCS" and "truth" are
# not printed on the page, "w=0/0.5/1" tokens are replaced with plain descriptions of what the
# calibration weight trades off (per docs/BATOND_SPEC-2026-08-07.md Section 5: the objective is
# w * E_S1[N] + (1-w) * N_max, so w=0 minimizes worst-case enrollment alone, w=1 minimizes
# average enrollment alone, w=0.5 balances the two).
#
# CONFLICT, NOW RESOLVED EXTERNALLY: the original task brief separately required the title and
# subtitle VERBATIM ("The locally best policy need not be the globally best policy" / "PCS
# functions as a development-stage surrogate objective for program success."), and those two
# strings contained "policy" and "PCS". This script initially kept them verbatim and flagged the
# conflict rather than resolving it unilaterally. The title/subtitle below were subsequently
# edited outside this script's own logic (by the coordinator or a shared-file process, per the
# harness's own note that this file was modified since it was last read) to the jargon-compliant
# wording. That edit is kept rather than reverted. The conflict itself, and that it was resolved
# by an edit this script did not make, is reported in the run's final message.

suppressPackageStartupMessages({
  library(ggplot2)
  library(ggrepel)
  library(grid)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

FIG_ID <- "fig3_pcs_wrong_policy"

# ------------------------------------------------------------------------------------------
# 1. LOAD AND FILTER
# ------------------------------------------------------------------------------------------

compose <- readRDS(file.path(ROOT, "results", "exp7_compose.rds"))
design  <- compose$design

sub <- design[design$module == "primary" &
              design$inferential_role == "PRIMARY_INFERENTIAL_SET", ]

cat("=====================================================================\n")
cat("FIGURE", FIG_ID, ": row-count and truth-key check\n")
cat("  rows after filter (module==primary & inferential_role==PRIMARY_INFERENTIAL_SET):",
    nrow(sub), "\n")
cat("  distinct policy_id                                                :",
    length(unique(sub$policy_id)), "\n")
cat("  distinct key (truth) values                                       :",
    paste(unique(sub$key), collapse = ", "), "\n")
cat("=====================================================================\n")

stopifnot(nrow(sub) == 9)
stopifnot(length(unique(sub$policy_id)) == 6)

# Application-truth badge check: key must carry the literal substring "application|OBD_monotone"
stopifnot(all(grepl("application\\|OBD_monotone", sub$key, fixed = FALSE)))
cat("Confirmed: all 9 rows carry key containing 'application|OBD_monotone'.\n")

# ------------------------------------------------------------------------------------------
# 2. IDENTICAL-VALUES ASSERTION FOR REPEATED policy_id, BEFORE ANY COLLAPSING
# ------------------------------------------------------------------------------------------

sub <- sub[order(sub$policy_id, sub$w), ]

verify_rows <- list()
repeated_ids <- names(table(sub$policy_id))[table(sub$policy_id) > 1]

for (pid in unique(sub$policy_id)) {
  rows <- sub[sub$policy_id == pid, ]
  ws   <- paste(sprintf("%.1f", rows$w), collapse = ", ")
  pcs_vals <- rows$PCShat
  pos_vals <- rows$POShat
  identical_flag <- if (nrow(rows) > 1) {
    (length(unique(pcs_vals)) == 1L) && (length(unique(pos_vals)) == 1L)
  } else {
    NA
  }
  verify_rows[[pid]] <- data.frame(
    policy_id = pid,
    family = rows$family[1],
    n_weights = nrow(rows),
    weights = ws,
    PCShat_values = paste(sprintf("%.8f", pcs_vals), collapse = " | "),
    POShat_values = paste(sprintf("%.8f", pos_vals), collapse = " | "),
    identical_across_weights = identical_flag,
    stringsAsFactors = FALSE
  )
}
verify_tab <- do.call(rbind, verify_rows)
rownames(verify_tab) <- NULL

cat("\n----- IDENTICAL-VALUES VERIFICATION TABLE (printed for audit, NOT on the rendered page) -----\n")
print(verify_tab, row.names = FALSE)
cat("-----------------------------------------------------------------------------------------------\n\n")

for (pid in repeated_ids) {
  rows <- sub[sub$policy_id == pid, ]
  stopifnot(length(unique(rows$PCShat)) == 1L)
  stopifnot(length(unique(rows$POShat)) == 1L)
}
cat("ASSERTION PASSED: every repeated policy_id has bit-identical PCShat and POShat",
    "across the weights that share it. Safe to collapse to one line per distinct policy_id.\n\n")

# ------------------------------------------------------------------------------------------
# 3. COLLAPSE TO ONE ROW PER DISTINCT policy_id, USING FULL-PRECISION STORED VALUES
#
# Direct-label text is plain language (no "w=" tokens, no "policy_id"), grounded in the spec's
# own objective definition: w * E_S1[N] + (1-w) * N_max. w=0 -> minimizes worst-case enrollment
# alone. w=1 -> minimizes average enrollment alone. w=0.5 -> balances the two.
# ------------------------------------------------------------------------------------------

weight_phrase <- function(w) {
  if (isTRUE(all.equal(w, 0)))   return("smaller worst-case enrollment")
  if (isTRUE(all.equal(w, 1)))   return("smaller average enrollment")
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
    trade_label <- "unaffected by the enrollment trade-off setting"
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
cat("Collapsed to", nrow(collapsed), "distinct-design-strategy lines:\n")
print(collapsed[, c("policy_id", "family", "label", "PCShat", "POShat")], row.names = FALSE)
cat("\n")

# ------------------------------------------------------------------------------------------
# 4. SLOPE-DIRECTION VERIFICATION, TOP-PRIORITY QA ITEM FOR THIS WHOLE FIGURE SET
# ------------------------------------------------------------------------------------------

collapsed$PCS_rank <- rank(-collapsed$PCShat, ties.method = "first")  # 1 = highest PCS
collapsed$POS_rank <- rank(-collapsed$POShat, ties.method = "first")  # 1 = highest POS
collapsed$rank_crosses <- collapsed$PCS_rank != collapsed$POS_rank

slope_check <- collapsed[order(collapsed$PCS_rank),
                          c("label", "PCShat", "PCS_rank", "POShat", "POS_rank", "rank_crosses")]

cat("===================== SLOPE-DIRECTION VERIFICATION TABLE =====================\n")
cat("(left column PCS ranking vs right column POS ranking, read off the SAME 6 rows\n")
cat(" used to draw the slopegraph lines; rank_crosses == TRUE means that design strategy's\n")
cat(" line changes vertical order between the two columns. Internal PCS/POS names are used\n")
cat(" here in console output only, never on the rendered page.)\n\n")
print(slope_check, row.names = FALSE)
cat("================================================================================\n\n")

n_crossings <- sum(collapsed$rank_crosses)
cat("Number of design strategies whose PCS rank != POS rank (rank-crossing lines):",
    n_crossings, "out of", nrow(collapsed), "\n\n")

stopifnot(nrow(collapsed) == length(unique(collapsed$policy_id)))
stopifnot(all(collapsed$PCS_rank %in% seq_len(nrow(collapsed))))
stopifnot(all(collapsed$POS_rank %in% seq_len(nrow(collapsed))))

# ------------------------------------------------------------------------------------------
# 5. PERSISTENCE ANNOTATION, SCOPED TO THE boin12 w=0.5 vs boin12 w=0 PAIR ONLY
# ------------------------------------------------------------------------------------------

persist <- readRDS(file.path(ROOT, "results", "exp7_persistence.rds"))

pair_sub <- persist[grepl("boin12", persist$A, fixed = TRUE) &
                     grepl("0.5", persist$A, fixed = TRUE) &
                     grepl("boin12", persist$B, fixed = TRUE) &
                     grepl("0", persist$B, fixed = TRUE) &
                     !grepl("0.5", persist$B, fixed = TRUE), ]

cat("Persistence pair (boin12 w=0.5 vs boin12 w=0) rows found:", nrow(pair_sub), "\n")
print(pair_sub, row.names = FALSE)
stopifnot(nrow(pair_sub) == 6)
stopifnot(all(pair_sub$holds == TRUE))
cat("ASSERTION PASSED: holds == TRUE on all 6 modules for the boin12 w=0.5 vs w=0 pair.\n")
cat("(The other pair in this artifact, boin12 w=1 vs w=0, which holds on only 4/6 modules,\n")
cat(" is DELIBERATELY OMITTED from this figure and its annotation per the coordinator's\n")
cat(" instruction. It is not referenced anywhere below, including no footnote or hedge.)\n\n")

# Exact required wording from the mid-build jargon correction.
persistence_annotation <- paste0(
  "The key ranking reversal persists under all 6 alternative assumptions\n",
  "about later-stage performance."
)

# ------------------------------------------------------------------------------------------
# 6. INSET DATA: DECISION-TREE / THREE-BRANCH DIAGRAM
# ------------------------------------------------------------------------------------------

q3 <- readRDS(file.path(ROOT, "results", "exp7_q3_primary.rds"))

cat("q3_primary$dstar:", q3$dstar, "\n")
stopifnot(q3$dstar == 3)

qmap <- q3$qmap
cat("q3_primary$qmap:\n")
print(qmap)

q_target <- unname(qmap["3"])
q_neighbor <- unname(qmap["2"])
q_none <- unname(qmap["none"])

cat(sprintf("\nq_target (select the correct dose)         : %.9f (expected ~0.780944107)\n", q_target))
cat(sprintf("q_neighbor (select adjacent, lower-regret)  : %.9f (expected ~0.693228528)\n", q_neighbor))
cat(sprintf("q_none (select nothing)                     : %.9f (expected 0)\n", q_none))

stopifnot(abs(q_target - 0.780944107) < 1e-6)
stopifnot(abs(q_neighbor - 0.693228528) < 1e-6)
stopifnot(q_none == 0)
cat("ASSERTION PASSED: inset values match expected magnitudes to within 1e-6.\n\n")

inset_df <- data.frame(
  branch = factor(
    c("Select the correct dose\n(the target)", "Select an adjacent dose", "Select nothing"),
    levels = c("Select nothing", "Select an adjacent dose", "Select the correct dose\n(the target)")
  ),
  value = c(q_target, q_neighbor, q_none),
  label = c(sprintf("%.1f%%", 100 * q_target),
            sprintf("%.1f%%", 100 * q_neighbor),
            sprintf("%.0f%%", 100 * q_none))
)

# ------------------------------------------------------------------------------------------
# 7. VERIFY BANNER (per house convention)
# ------------------------------------------------------------------------------------------

verify_banner(
  figure_id = FIG_ID,
  source_artifact = "results/exp7_compose.rds$design, results/exp7_persistence.rds, results/exp7_q3_primary.rds",
  producer = "scripts/figures/arpa_stats_meeting/fig3_pcs_wrong_policy.R",
  fields = c("policy_id", "family", "w", "PCShat", "POShat", "A/B/module/dPCS/dPOS/holds", "qmap", "dstar"),
  expected = "9 rows / 6 distinct policy_id; 6/6 persistence holds for boin12 w=0.5 vs w=0; qmap[3]~0.781, qmap[2]~0.693, qmap[none]=0",
  observed = sprintf("%d rows / %d distinct policy_id; %d/6 persistence holds; qmap[3]=%.6f, qmap[2]=%.6f, qmap[none]=%.6f",
                      nrow(sub), length(unique(sub$policy_id)), sum(pair_sub$holds),
                      q_target, q_neighbor, q_none)
)

# ------------------------------------------------------------------------------------------
# 8. COLORS FOR THE 6 DESIGN-STRATEGY LINES
#
# PAL only names 4 roles (retained/discarded/comparator/accent), all reserved for their defined
# meanings elsewhere in this figure set. Extend with fresh Okabe-Ito-family hues, not reused
# from PAL, for the 6 line identities specifically.
# ------------------------------------------------------------------------------------------

POLICY_COLORS <- c(
  "#E69F00",  # orange
  "#56B4E9",  # sky blue
  "#F0E442",  # yellow
  "#CC79A7",  # reddish purple
  "#000000",  # black
  "#7F3C8D"   # deep purple, distinct from PAL$accent (#009E73) and from the other 5 hues
)

collapsed <- collapsed[order(collapsed$PCS_rank), ]
collapsed$color <- POLICY_COLORS[seq_len(nrow(collapsed))]

stopifnot(!any(collapsed$color %in% unlist(PAL[c("retained", "discarded", "comparator", "accent")])))
cat("Confirmed: none of the 6 design-strategy line colors reuse a PAL role color.\n\n")

# ------------------------------------------------------------------------------------------
# 9. LAYOUT GEOMETRY
#
# Data spans PCShat/POShat in [0.516, 0.856]. The y-axis is deliberately widened beyond that
# range so the badge (top band) and the inset decision diagram (bottom band) sit in space that
# provably contains no line, point, or direct label, verified programmatically below rather
# than eyeballed.
# ------------------------------------------------------------------------------------------

Y_LO <- 0.22
Y_HI <- 0.97
X_LO <- 0.05
X_HI <- 3.15

data_y_range <- range(c(collapsed$PCShat, collapsed$POShat))
cat("Data y-range (PCShat/POShat):", paste(round(data_y_range, 4), collapse = " to "), "\n")

INSET_YMIN <- Y_LO + 0.01
# Left of the two lowest lines, the direct labels (repelled around y ~= 0.50-0.53) need a clear
# gap above the inset's top border, not just non-overlap with the data points themselves.
INSET_YMAX <- 0.435
BADGE_YMIN <- 0.895
BADGE_YMAX <- Y_HI - 0.01
stopifnot(INSET_YMAX < data_y_range[1])   # inset sits strictly below the lowest data point
stopifnot(BADGE_YMIN > data_y_range[2])   # badge sits strictly above the highest data point
cat("Confirmed: inset band [", INSET_YMIN, ",", INSET_YMAX, "] sits below all data (min",
    data_y_range[1], "); badge band [", BADGE_YMIN, ",", BADGE_YMAX, "] sits above all data (max",
    data_y_range[2], ").\n\n")

# ------------------------------------------------------------------------------------------
# 10. BUILD MAIN SLOPEGRAPH
# ------------------------------------------------------------------------------------------

left_pts <- data.frame(
  policy_id = collapsed$policy_id,
  label = collapsed$label,
  color = collapsed$color,
  x = 1, y = collapsed$PCShat,
  text = sprintf("%s  (%.0f%%)", collapsed$label, 100 * collapsed$PCShat),
  stringsAsFactors = FALSE
)
right_pts <- data.frame(
  policy_id = collapsed$policy_id,
  label = collapsed$label,
  color = collapsed$color,
  x = 2, y = collapsed$POShat,
  # One decimal place: several POShat values round to the same whole percent (e.g. 62.2%,
  # 62.4%, 62.6%, 63.0% all round to "62%"/"63%"), and the right column shows the bare number
  # with no accompanying design-strategy text, so the extra digit is needed for the reader to
  # tell clustered points apart without relying on the leader line alone.
  text = sprintf("%.1f%%", 100 * collapsed$POShat),
  stringsAsFactors = FALSE
)
long <- rbind(left_pts[, c("policy_id", "label", "color", "x", "y")],
              right_pts[, c("policy_id", "label", "color", "x", "y")])

color_map <- setNames(collapsed$color, collapsed$label)

p_main <- ggplot(long, aes(x = x, y = y, group = label)) +
  geom_line(aes(color = label), linewidth = 1.3, alpha = 0.92) +
  geom_point(aes(color = label), size = 4.2) +
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
    size = 4.5, color = PAL$ink, fontface = "plain", show.legend = FALSE,
    min.segment.length = 0, seed = 1, box.padding = 0.3
  ) +
  geom_text_repel(
    data = right_pts,
    aes(x = x, y = y, label = text, group = label),
    hjust = 0, direction = "y", nudge_x = 0.30, segment.size = 0.3,
    size = 4.5, color = PAL$ink, show.legend = FALSE,
    min.segment.length = 0, seed = 1, box.padding = 0.3
  ) +
  labs(
    title = "The locally best design strategy need not be the globally best one",
    subtitle = "Correct-dose selection is an early objective used as a stand-in for ultimate program success.",
    x = NULL,
    y = "Estimated probability"
  ) +
  theme_arpa() +
  theme(
    axis.text.x = element_text(size = rel(1.0), face = "bold"),
    axis.title.x = element_blank(),
    panel.grid.major.x = element_blank()
  )

# ------------------------------------------------------------------------------------------
# 11. PERSISTENCE CALLOUT, PLACED IN THE VERIFIED-EMPTY TOP BAND, EXACT REQUIRED WORDING
# ------------------------------------------------------------------------------------------

pos_boin12_low_pcs  <- collapsed$POShat[collapsed$policy_id == "6f01edec4d0fd86b"]  # BOIN12, smaller worst-case
pos_boin12_bal      <- collapsed$POShat[collapsed$policy_id == "fb581c66401e9631"]  # BOIN12, balanced
callout_target_y <- mean(c(pos_boin12_low_pcs, pos_boin12_bal))

# ARROW TARGET, revised by the coordinator. The midpoint of the two right endpoints lands visually
# on a THIRD line's endpoint, the 86-to-67 pair that persists on only 4 of 6 modules, which would
# attach the 6-of-6 claim to the wrong pair. The arrow now points at the CROSSING of the supported
# pair's own two lines, computed from their verified values rather than typed.
pcs_bal <- collapsed$PCShat[collapsed$policy_id == "fb581c66401e9631"]
pcs_low <- collapsed$PCShat[collapsed$policy_id == "6f01edec4d0fd86b"]
t_cross <- (pcs_bal - pcs_low) / ((pcs_bal - pos_boin12_bal) + (pos_boin12_low_pcs - pcs_low))
cross_y <- pcs_bal + t_cross * (pos_boin12_bal - pcs_bal)
callout_df <- data.frame(x = 1.55, y = 0.83, xend = 1 + t_cross, yend = cross_y)

p_main <- p_main +
  geom_curve(
    data = callout_df, aes(x = x, y = y, xend = xend, yend = yend),
    inherit.aes = FALSE, curvature = -0.25, color = "#6A6A6A", linewidth = 0.4,
    arrow = arrow(length = unit(0.10, "in"), type = "closed")
  ) +
  geom_label(
    data = data.frame(x = 1.55, y = 0.83, lab = persistence_annotation),
    aes(x = x, y = y, label = lab),
    inherit.aes = FALSE, hjust = 0.5, vjust = 0, size = 3.9, color = PAL$ink,
    fill = PAL$panel_bg, linewidth = 0.35, lineheight = 1.05
  )

# ------------------------------------------------------------------------------------------
# 12. INSET: THREE-BRANCH DECISION DIAGRAM (exp7_q3_primary), placed in the verified-empty
#     bottom band via annotation_custom in DATA coordinates (no panel-fraction guesswork).
# ------------------------------------------------------------------------------------------

p_inset <- ggplot(inset_df, aes(x = branch, y = value, fill = branch)) +
  geom_col(width = 0.62) +
  geom_text(aes(label = label), hjust = -0.12, size = 3.9, color = PAL$ink) +
  coord_flip(clip = "off") +
  scale_y_continuous(limits = c(0, 0.92), expand = expansion(mult = c(0, 0.02))) +
  scale_fill_manual(values = c(
    "Select nothing" = PAL$comparator,
    "Select an adjacent,\nlower-regret dose" = "#56B4E9",
    "Select the correct dose\n(the target)" = PAL$retained
  ), guide = "none") +
  labs(
    title = "Ultimate success by dose-selection decision",
    x = NULL, y = "Chance of ultimately confirming the correct dose"
  ) +
  theme_arpa(base_size = 13) +
  theme(
    plot.title = element_text(size = rel(1.0), face = "bold", margin = margin(b = 4)),
    axis.text.y = element_text(size = rel(0.92)),
    axis.text.x = element_blank(),
    axis.title.x = element_text(size = rel(0.82)),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_blank(),
    plot.margin = margin(6, 22, 6, 4),
    plot.background = element_rect(fill = PAL$panel_bg, color = "#D0D0D0", linewidth = 0.4)
  )

inset_grob <- ggplotGrob(p_inset)

p_main <- p_main +
  annotation_custom(inset_grob, xmin = X_LO + 0.05, xmax = 1.62, ymin = INSET_YMIN, ymax = INSET_YMAX)

# ------------------------------------------------------------------------------------------
# 13. APPLICATION-TRUTH BADGE (required on both figures, exact text from theme.R),
#     placed in the verified-empty top band via annotation_custom in DATA coordinates.
# ------------------------------------------------------------------------------------------

badge_grob <- grid::grobTree(
  grid::roundrectGrob(
    x = 0.5, y = 0.5, width = 0.98, height = 0.72,
    r = unit(0.15, "snpc"),
    gp = grid::gpar(fill = "#F0F0F0", col = "#B0B0B0", lwd = 1)
  ),
  grid::textGrob(
    APPLICATION_BADGE_TEXT, x = 0.5, y = 0.5,
    gp = grid::gpar(fontsize = 12, col = PAL$ink, fontface = "italic")
  )
)

p_main <- p_main +
  annotation_custom(badge_grob, xmin = 2.25, xmax = X_HI - 0.05, ymin = BADGE_YMIN, ymax = BADGE_YMAX)

full_plot <- p_main

out <- save_figure(full_plot, FIG_ID, width_in = 15.0, height_in = 8.6)
cat("\nFigure written to:\n")
cat(" ", out$pdf, "\n")
cat(" ", out$svg, "\n")
cat(" ", out$png, "(width", out$png_width_px, "px)\n")

# ------------------------------------------------------------------------------------------
# 14. JARGON CHECK, per the mid-build coordinator correction
#
# Scans every string that lands on the rendered page (title, subtitle, axis labels, direct
# line/point labels, annotation, inset text, badge) for forbidden internal tokens. Verification
# tables above are console-only and are correctly exempt from this check.
# ------------------------------------------------------------------------------------------

rendered_strings <- c(
  title = "The locally best design strategy need not be the globally best one",
  subtitle = "Correct-dose selection is an early objective used as a stand-in for ultimate program success.",
  x_axis_left = "Chance of selecting\nthe correct dose",
  x_axis_right = "Chance of ultimately confirming\nthe correct dose",
  y_axis = "Estimated probability",
  persistence_annotation = persistence_annotation,
  inset_title = "Ultimate success by dose-selection decision",
  inset_yaxis = "Chance of ultimately confirming the correct dose",
  badge = APPLICATION_BADGE_TEXT,
  setNames(left_pts$text, paste0("left_label_", seq_len(nrow(left_pts)))),
  setNames(as.character(inset_df$branch), paste0("inset_branch_", seq_len(nrow(inset_df))))
)

forbidden_patterns <- c("PCS", "\\btruth\\b", "\\bcell\\b", "application track",
                         "\\bw *= *0(\\.5)?\\b", "\\bw *= *1\\b", "frozen", "locked")
# "policy" is checked separately because "policy" alone (not "design strateg*") is forbidden,
# but the words BOIN / BOIN12 / U-BOIN are explicitly allowed as standard design names.
policy_hits <- grepl("\\bpolic(y|ies)\\b", rendered_strings, ignore.case = TRUE)

cat("\n===================== JARGON CHECK (rendered-page text only) =====================\n")
any_fail <- FALSE
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
if (any_fail) {
  cat("NOTE: title/subtitle failures are the KNOWN, EXPLICITLY FLAGGED conflict between the\n")
  cat("original task brief (verbatim title/subtitle required) and the mid-build jargon\n")
  cat("correction (no 'PCS' or 'policy' on the rendered page). Not resolved unilaterally;\n")
  cat("kept verbatim per the primary brief and reported as a conflict.\n")
}
