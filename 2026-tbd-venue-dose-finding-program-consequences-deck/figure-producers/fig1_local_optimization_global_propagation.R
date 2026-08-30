# FIGURE 1: local optimization, global propagation.
#
# Conceptual, no empirical values. Slide-ready schematic showing that a five-stage development
# pathway can be locally valid at every stage (top labels, earned checkmarks) while the
# information state carried forward (bottom lanes) has a structure that a stage-by-stage
# validity argument never examines.
#
# Reads only scripts/figures/arpa_stats_meeting/theme.R for palette, status grammar and export.

suppressPackageStartupMessages({
  library(ggplot2)
  library(grid)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

verify_banner(
  figure_id       = "fig1_local_optimization_global_propagation",
  source_artifact = "none (conceptual schematic, no result artifact)",
  producer        = "scripts/figures/arpa_stats_meeting/fig1_local_optimization_global_propagation.R",
  fields          = "none, all coordinates are schematic placement constants",
  expected        = "a conceptual figure carries no empirical claim to check against a result object",
  observed         = "n/a, this banner documents the absence of a source artifact rather than a check"
)

# ------------------------------------------------------------------------------------------
# STAGE GEOMETRY
# ------------------------------------------------------------------------------------------

stage_x <- c(1, 2, 3, 4, 5)
stage_names <- c("Dose\nexploration", "Selection", "Phase-II\ngo / no-go", "Confirmation", "Approval")
local_objective <- c(
  "correct dose\nidentification",
  "select one dose\nto carry forward",
  "detect signal,\nstop for futility",
  "control type I error,\nachieve power",
  "risk-benefit\njudgment"
)

y_path      <- 0.0     # the horizontal stage path
y_obj_label <- 1.55     # local-objective labels above
y_check     <- 1.05     # earned-checkmark row
y_stage_lab <- -0.35    # stage names just under the path

# lane y-positions, below the path, top to bottom
y_alt      <- -1.35   # available alternatives (branching, terminating)
y_retained <- -2.25   # evidence retained (continuous)
y_cond     <- -3.15   # evidence conditioned on selection (fresh line from Selection onward)
y_unres    <- -4.05   # unresolved questions (open nodes)

xr <- range(stage_x) + c(-1.75, 0.55)   # extra left room for direct lane labels, left-aligned

# ------------------------------------------------------------------------------------------
# BUILD ELEMENTS
# ------------------------------------------------------------------------------------------

p <- ggplot() +
  coord_cartesian(xlim = xr, ylim = c(-4.9, 2.15), clip = "off") +
  theme_arpa(base_size = 20) +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.title = element_text(size = rel(1.45)),
    plot.subtitle = element_text(size = rel(1.0))
  )

# --- main path, stage nodes and connectors -------------------------------------------------
path_df <- data.frame(x = stage_x, y = y_path)

p <- p +
  geom_line(data = path_df, aes(x, y), color = PAL$ink, linewidth = 1.1) +
  geom_point(data = path_df, aes(x, y), color = PAL$ink, fill = PAL$paper,
             shape = 21, size = 6, stroke = 1.4) +
  # arrowhead at the end of the path
  annotate("segment", x = stage_x[5], y = y_path, xend = stage_x[5] + 0.42, yend = y_path,
           color = PAL$ink, linewidth = 1.1,
           arrow = arrow(length = unit(0.16, "in"), type = "closed"))

# --- stage names under the path -------------------------------------------------------------
p <- p + annotate("text", x = stage_x, y = y_stage_lab, label = stage_names,
                   size = 5.6, fontface = "bold", color = PAL$ink, lineheight = 0.92, vjust = 1)

# --- local objective labels + earned checkmarks above --------------------------------------
p <- p +
  annotate("text", x = stage_x, y = y_obj_label, label = local_objective,
           size = 4.6, color = "#3A3A3A", lineheight = 0.95, vjust = 0) +
  annotate("segment", x = stage_x, xend = stage_x, y = y_path + 0.12, yend = y_check - 0.18,
           color = PAL$gridline, linewidth = 0.5, linetype = "dotted")

# earned checkmark glyph, drawn as a small check path per stage, colored retained-blue,
# inside a thin circle, to read as "locally valid" without implying sarcasm
check_df <- data.frame(x = stage_x[1:4], y = y_check)
p <- p + geom_point(data = check_df, aes(x, y), shape = 21, size = 11.5,
                     color = PAL$retained, fill = scales::alpha(PAL$retained, 0.10), stroke = 1.3)
# checkmark as two short segments per stage (drawn via annotate with vectorized x/y works for
# points/text but not naturally for per-point two-segment glyphs, so build a small df and loop)
# THE APPROVAL STAGE CARRIES NO MARKER, owner edit 2026-08-27. Approval is a risk-benefit
# judgment and "locally valid" is statistical language, so the first four stages keep their
# markers and the fifth does not.
check_glyph <- do.call(rbind, lapply(stage_x[1:4], function(cx) {
  data.frame(
    x    = c(cx - 0.085, cx - 0.015, cx - 0.015, cx + 0.095),
    y    = c(y_check - 0.02, y_check - 0.095, y_check - 0.095, y_check + 0.10),
    grp  = c(cx, cx, cx, cx),
    seg  = c(1, 1, 2, 2)
  )
}))
p <- p + geom_line(data = check_glyph, aes(x, y, group = interaction(grp, seg)),
                    color = PAL$retained, linewidth = 1.5, lineend = "round")
p <- p + annotate("text", x = stage_x[1:4], y = y_check - 0.42, label = rep("locally valid", 4),
                   size = 3.5, color = PAL$retained, fontface = "italic")

# ------------------------------------------------------------------------------------------
# LANE 1: available alternatives, branch and terminate down to one survivor by Selection
# ------------------------------------------------------------------------------------------

# three branches converging: at Dose exploration, three parallel candidate lines; two of them
# terminate (dead-end tick) before Selection, one survives and continues flat to the end as a
# thin gray "carried forward" thread (kept faint, distinct from the "evidence retained" lane).
branch_y0 <- y_alt + c(0.28, 0, -0.28)
alt_branches <- list(
  data.frame(x = c(stage_x[1], stage_x[1] + 0.35), y = c(branch_y0[1], y_alt + 0.10)),  # terminates early
  data.frame(x = c(stage_x[1], stage_x[2]),        y = c(branch_y0[2], y_alt)),          # survives to Selection
  data.frame(x = c(stage_x[1], stage_x[1] + 0.62), y = c(branch_y0[3], y_alt - 0.12))    # terminates early
)
for (b in alt_branches) {
  p <- p + geom_line(data = b, aes(x, y), color = PAL$discarded, linewidth = 1.0, alpha = 0.85)
}
# dead-end ticks (perpendicular short mark) at the termination point of the two abandoned branches
deadend_pts <- data.frame(
  x = c(alt_branches[[1]]$x[2], alt_branches[[3]]$x[2]),
  y = c(alt_branches[[1]]$y[2], alt_branches[[3]]$y[2])
)
p <- p + geom_point(data = deadend_pts, aes(x, y), shape = 4, size = 4.2,
                     color = PAL$discarded, stroke = 1.6)

# surviving branch continues from Selection onward as a single thin carried-forward thread
survive_df <- data.frame(x = c(stage_x[2], stage_x[5]), y = c(y_alt, y_alt))
p <- p + geom_line(data = survive_df, aes(x, y), color = PAL$comparator, linewidth = 1.0,
                    linetype = STATUS$conceptual$linetype)
p <- p + geom_point(data = data.frame(x = stage_x[2], y = y_alt), aes(x, y),
                     shape = 21, size = 4, color = PAL$comparator, fill = PAL$paper, stroke = 1.2)

p <- p + annotate("text", x = xr[1] + 0.05, y = y_alt, label = "Available\nalternatives",
                   hjust = 0, size = 4.0, color = PAL$ink, lineheight = 0.9, fontface = "bold")

# ------------------------------------------------------------------------------------------
# LANE 2: evidence retained, continuous across the whole path
# ------------------------------------------------------------------------------------------

retained_df <- data.frame(x = c(stage_x[1], stage_x[5]), y = y_retained)
p <- p + geom_line(data = retained_df, aes(x, y), color = PAL$retained, linewidth = 1.7,
                    lineend = "round")
p <- p + geom_point(data = data.frame(x = stage_x, y = y_retained), aes(x, y),
                     color = PAL$retained, size = 2.6)
p <- p + annotate("text", x = xr[1] + 0.05, y = y_retained, label = "Evidence\nretained",
                   hjust = 0, size = 4.0, color = PAL$ink, lineheight = 0.9, fontface = "bold")

# ------------------------------------------------------------------------------------------
# LANE 3: evidence conditioned on selection, a NEW line beginning at Selection (offset start,
# does not connect to anything upstream)
# ------------------------------------------------------------------------------------------

cond_df <- data.frame(x = c(stage_x[2], stage_x[5]), y = y_cond)
p <- p + geom_line(data = cond_df, aes(x, y), color = PAL$retained, linewidth = 1.7,
                    lineend = "round", alpha = 0.95)
# fresh-start marker: open circle at the offset start distinct from a continuation
p <- p + geom_point(data = data.frame(x = stage_x[2], y = y_cond), aes(x, y),
                     shape = 21, size = 5.2, color = PAL$retained, fill = PAL$paper, stroke = 1.8)
p <- p + geom_point(data = data.frame(x = stage_x[3:5], y = y_cond), aes(x, y),
                     color = PAL$retained, size = 2.6)
p <- p + annotate("text", x = xr[1] + 0.05, y = y_cond,
                   label = "Evidence conditioned\non selection",
                   hjust = 0, size = 4.0, color = PAL$ink, lineheight = 0.9, fontface = "bold")
p <- p + annotate("text", x = stage_x[2] + 0.06, y = y_cond + 0.30, label = "fresh evidence begins",
                   hjust = 0, size = 3.3, color = PAL$retained, fontface = "italic")

# ------------------------------------------------------------------------------------------
# LANE 4: unresolved questions, open nodes at intervals, some close, some persist to Approval
# ------------------------------------------------------------------------------------------

# baseline thread (very light) so the open nodes read as one lane
unres_thread <- data.frame(x = c(stage_x[1], stage_x[5]), y = y_unres)
p <- p + geom_line(data = unres_thread, aes(x, y), color = PAL$gridline, linewidth = 0.8)

# five conceptual questions raised at different stages, some resolved (filled) later, some
# persisting open all the way to Approval. Drawn as short horizontal spans from an open node
# (raised) to either a filled node (closed) or nothing (persists open).
unres_spans <- list(
  # raised at Dose exploration, closes at Selection
  list(x0 = stage_x[1], x1 = stage_x[2], closes = TRUE),
  # raised at Selection, closes at Confirmation
  list(x0 = stage_x[2], x1 = stage_x[4], closes = TRUE),
  # raised at Phase-II go/no-go, persists open to Approval
  list(x0 = stage_x[3], x1 = stage_x[5], closes = FALSE),
  # raised at Dose exploration, persists open all the way
  list(x0 = stage_x[1], x1 = stage_x[5], closes = FALSE)
)
jit <- c(0.12, -0.12, 0.0, 0.22)
for (i in seq_along(unres_spans)) {
  s <- unres_spans[[i]]
  yy <- y_unres + jit[i]
  seg <- data.frame(x = c(s$x0, s$x1), y = yy)
  p <- p + geom_line(data = seg, aes(x, y), color = PAL$accent, linewidth = 1.0,
                      linetype = STATUS$conceptual$linetype, alpha = 0.9)
  # open node at raise point
  p <- p + geom_point(data = data.frame(x = s$x0, y = yy), aes(x, y),
                       shape = 21, size = 4.6, color = PAL$accent, fill = PAL$paper, stroke = 1.6)
  if (s$closes) {
    p <- p + geom_point(data = data.frame(x = s$x1, y = yy), aes(x, y),
                         shape = 21, size = 4.6, color = PAL$accent, fill = PAL$accent, stroke = 1.6)
  } else {
    p <- p + geom_point(data = data.frame(x = s$x1, y = yy), aes(x, y),
                         shape = 21, size = 5.6, color = PAL$accent, fill = PAL$paper, stroke = 2.0)
  }
}
p <- p + annotate("text", x = xr[1] + 0.05, y = y_unres,
                   label = "Unresolved\nquestions",
                   hjust = 0, size = 4.0, color = PAL$ink, lineheight = 0.9, fontface = "bold")

# ------------------------------------------------------------------------------------------
# titles and caption. Subtitle and caption are wrapped explicitly (ggplot does not auto-wrap
# plot.title/subtitle/caption text against the device width).
# ------------------------------------------------------------------------------------------

subtitle_wrapped <- paste(strwrap(
  paste("Every stage below can be statistically valid on its own terms.",
        "The information carried between stages is a separate question",
        "the stage-by-stage validity argument never asks."),
  width = 98), collapse = "\n")

caption_wrapped <- paste(strwrap(
  paste("Conceptual illustration, no empirical values plotted.",
        "Line grammar: solid blue line = evidence retained.",
        "Vermillion line ending in a cross mark = alternative abandoned.",
        "Faded gray dotted line = carried forward without re-evaluation.",
        "Open green circle = unresolved question. Filled green circle = question resolved.",
        "Offset blue start = fresh evidence required from that stage on."),
  width = 150), collapse = "\n")

p <- p + labs(
  title = "Local optimization, global propagation",
  subtitle = subtitle_wrapped,
  caption = caption_wrapped
)

# ------------------------------------------------------------------------------------------
# bottom banner, the required verbatim closing statement
# ------------------------------------------------------------------------------------------

banner_wrapped <- paste(strwrap(
  "A statistically valid confirmatory analysis does not guarantee a globally well-designed development program.",
  width = 62), collapse = "\n")

p <- p + annotate("text", x = mean(stage_x), y = -4.75,
                   label = banner_wrapped,
                   size = 6.4, fontface = "bold", color = PAL$ink, hjust = 0.5, lineheight = 1.05)

print(save_figure(p, "fig1_local_optimization_global_propagation", width_in = 13.333, height_in = 7.5))
