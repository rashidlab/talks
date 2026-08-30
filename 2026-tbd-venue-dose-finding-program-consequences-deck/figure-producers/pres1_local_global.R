# PRESENTATION VARIANT of fig1_local_optimization_global_propagation.R
#
# id = "pres1_local_global"
#
# Cut down from the archival fig1 script per the owner's presentation-variant ruling. One
# claim, one visual, one sentence to remember.
#
#   - Pipeline simplified from five stages to four: Dose finding -> Phase II decision ->
#     Confirmation -> Approval.
#   - The archival version's five lanes (available alternatives, evidence retained, evidence
#     conditioned on selection, unresolved questions) collapse to ONE contrasting lane headed
#     "What happens to the information?" showing only three things: alternatives disappear,
#     some earlier evidence can or cannot be reused, unresolved questions may survive.
#   - No icon grammar legend, no line-style legend, no locally-valid markers, no bottom
#     manuscript-style caption.
#
# Conceptual, no empirical values, same as the archival figure it is cut from. Reads only
# theme.R for palette and export.

suppressPackageStartupMessages({
  library(ggplot2)
  library(grid)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

verify_banner(
  figure_id       = "pres1_local_global",
  source_artifact = "none (conceptual schematic, no result artifact, cut from fig1_local_optimization_global_propagation.R)",
  producer        = "scripts/figures/arpa_stats_meeting/pres1_local_global.R",
  fields          = "none, all coordinates are schematic placement constants",
  expected        = "a conceptual figure carries no empirical claim to check against a result object",
  observed        = "n/a, this banner documents the absence of a source artifact rather than a check"
)

# ------------------------------------------------------------------------------------------
# STAGE GEOMETRY. Four stages, not five (Phase-II go/no-go and Confirmation from the
# archival figure become one combined "Phase II decision" stage, ahead of "Confirmation").
# ------------------------------------------------------------------------------------------

stage_x <- c(1, 2, 3, 4)
stage_names <- c("Dose\nfinding", "Phase II\ndecision", "Confirmation", "Approval")

y_path      <- 0.0
y_stage_lab <- -0.42

y_lane_hd   <- -1.55   # lane heading
y_lane_1    <- -2.35   # alternatives disappear
y_lane_2    <- -3.05   # some earlier evidence can or cannot be reused
y_lane_3    <- -3.75   # unresolved questions may survive

xr <- range(stage_x) + c(-0.55, 0.55)

# ------------------------------------------------------------------------------------------
# BUILD
# ------------------------------------------------------------------------------------------

p <- ggplot() +
  coord_cartesian(xlim = xr, ylim = c(-4.15, 1.15), clip = "off") +
  theme_arpa(base_size = 22) +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.title = element_text(size = rel(1.25), lineheight = 1.05),
    plot.subtitle = element_blank()
  )

# --- main path, stage nodes and connector --------------------------------------------------
path_df <- data.frame(x = stage_x, y = y_path)

p <- p +
  geom_line(data = path_df, aes(x, y), color = PAL$ink, linewidth = 1.4) +
  geom_point(data = path_df, aes(x, y), color = PAL$ink, fill = PAL$paper,
             shape = 21, size = 8, stroke = 1.7) +
  annotate("segment", x = stage_x[4], y = y_path, xend = stage_x[4] + 0.35, yend = y_path,
           color = PAL$ink, linewidth = 1.4,
           arrow = arrow(length = unit(0.20, "in"), type = "closed"))

p <- p + annotate("text", x = stage_x, y = y_stage_lab, label = stage_names,
                   size = 6.6, fontface = "bold", color = PAL$ink, lineheight = 0.95, vjust = 1)

# ------------------------------------------------------------------------------------------
# ONE CONTRASTING LANE: "What happens to the information?"
# Three plain statements, each with a single color accent (no legend explaining the colors).
# ------------------------------------------------------------------------------------------

p <- p + annotate("text", x = mean(stage_x), y = y_lane_hd,
                   label = "What happens to the information?",
                   size = 6.4, fontface = "bold", color = PAL$ink, hjust = 0.5)

lane_items <- data.frame(
  y = c(y_lane_1, y_lane_2, y_lane_3),
  label = c(
    "Alternatives disappear.",
    "Some earlier evidence can be reused. Some cannot.",
    "Unresolved questions may survive."
  ),
  color = c(PAL$discarded, PAL$retained, PAL$accent)
)

for (i in seq_len(nrow(lane_items))) {
  p <- p + annotate("point", x = mean(stage_x) - 2.55, y = lane_items$y[i],
                     color = lane_items$color[i], size = 5.5) +
    annotate("text", x = mean(stage_x) - 2.30, y = lane_items$y[i],
             label = lane_items$label[i], hjust = 0, size = 6.0,
             color = PAL$ink, fontface = "plain")
}

title_text <- "Each trial can succeed locally while the program fails globally"
title_wrapped <- paste(strwrap(title_text, width = 36), collapse = "\n")


print(save_figure(p, "pres1_local_global", width_in = 13.333, height_in = 7.5))
