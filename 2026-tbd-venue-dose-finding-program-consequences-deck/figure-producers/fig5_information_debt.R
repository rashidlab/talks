# FIGURE 5: information debt, repayable versus irrecoverable.
#
# Conceptual, no empirical values, two stacked lanes contrasting a dose question that gets
# resolved later at additional cost (Lane A, repayable) against a dose question that becomes
# permanently unanswerable once an alternative is abandoned (Lane B, irrecoverable).
#
# Lane A is illustrated beneath by a small sotorasib chronology strip. That strip carries
# externally documented regulatory facts, not a repo result artifact, so it is drawn with
# DESCRIPTIVE status (dashed, STATUS$descriptive), never conceptual and never supported.
#
# Sources verified 2026-08-27 (see this session's final report for URLs):
#   - FDA accelerated approval of sotorasib (Lumakras), 960 mg orally once daily, May 28 2021.
#   - PMR: randomized trial of 960 mg vs a lower dose (240 mg once daily), CodeBreaK 201
#     (NCT04933695), a 170-patient randomized phase 2 dose-comparison study in previously
#     treated KRAS G12C NSCLC.
#   - Result: 960 mg numerically superior on ORR, DCR, DOR and OS versus 240 mg, no notable
#     safety difference. FDA considered the PMR fulfilled December 2023 (Amgen statement,
#     2023-12-26), and 960 mg once daily remains the approved dose.
# The chronology strip's terminal label is "960 mg retained", literally, per the owner
# constraint that this is an example of a dose question resolved LATER, not evidence the
# original dose was wrong.

suppressPackageStartupMessages({
  library(ggplot2)
  library(grid)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

verify_banner(
  figure_id       = "fig5_information_debt",
  source_artifact = "sotorasib chronology strip only: externally documented regulatory record, not a repo result artifact",
  producer        = "scripts/figures/arpa_stats_meeting/fig5_information_debt.R",
  fields          = "approval date/dose, PMR terms, dose-comparison trial identifier, PMR fulfillment date, retained dose",
  expected        = "May 2021 accelerated approval at 960 mg, PMR for a randomized 960 vs 240 mg trial, PMR fulfilled Dec 2023, 960 mg retained",
  observed        = "confirmed via WebSearch/WebFetch against FDA-approval-history summaries, Amgen's Dec 26 2023 regulatory-update statement, and a JCO/Cancer Letter account of CodeBreaK 201 (NCT04933695). No conflict found."
)

# ------------------------------------------------------------------------------------------
# SHARED GEOMETRY: five conceptual stages per lane, same x-rhythm both lanes
# ------------------------------------------------------------------------------------------

sx <- c(1, 2, 3, 4, 5)
xr <- range(sx) + c(-2.05, 2.35)   # extra right room for the end-of-lane captions

y_laneA <- 3.0
y_laneB <- -0.9

# ------------------------------------------------------------------------------------------
# LANE A: repayable
# unresolved dose -> pivotal development proceeds -> uncertainty survives -> randomized dose
# comparison -> resolved
# ------------------------------------------------------------------------------------------

laneA_labels <- c(
  "Unresolved\ndose question",
  "Pivotal\ndevelopment\nproceeds",
  "Uncertainty\nsurvives",
  "Randomized\ndose\ncomparison",
  "Resolved"
)

p <- ggplot() +
  coord_cartesian(xlim = xr, ylim = c(-2.35, 3.85), clip = "off") +
  theme_arpa(base_size = 20) +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.title = element_text(size = rel(1.45)),
    plot.subtitle = element_text(size = rel(1.0))
  )

# main retained-color line through nodes 1-2 (solid, evidence accumulating normally)
p <- p + geom_line(data = data.frame(x = sx[1:2], y = y_laneA), aes(x, y),
                    color = PAL$retained, linewidth = 1.7, lineend = "round")
p <- p + geom_point(data = data.frame(x = sx[1], y = y_laneA), aes(x, y),
                     color = PAL$retained, size = 3.2)

# node 3, "uncertainty survives", is an open node (unresolved at that point in the story)
p <- p + geom_point(data = data.frame(x = sx[3], y = y_laneA), aes(x, y),
                     shape = 21, size = 7.5, color = PAL$accent, fill = PAL$paper, stroke = 2.1)
# connector from node 2 to node 3 stays retained-blue (the line of evidence is still moving,
# it is the DOSE QUESTION that is unresolved, not the surrounding development stream)
p <- p + geom_line(data = data.frame(x = sx[2:3], y = y_laneA), aes(x, y),
                    color = PAL$retained, linewidth = 1.7, lineend = "round")

# the segment from node 3 to node 4 (randomized dose comparison) closes the open question,
# drawn as retained-blue continuing, ending in a solid terminal node at "Resolved"
p <- p + geom_line(data = data.frame(x = sx[3:5], y = y_laneA), aes(x, y),
                    color = PAL$retained, linewidth = 1.7, lineend = "round")
p <- p + geom_point(data = data.frame(x = sx[4], y = y_laneA), aes(x, y),
                     color = PAL$retained, size = 3.2)
p <- p + geom_point(data = data.frame(x = sx[5], y = y_laneA), aes(x, y),
                     color = PAL$retained, size = 7.0)
p <- p + geom_point(data = data.frame(x = sx[5], y = y_laneA), aes(x, y),
                     shape = 21, color = PAL$paper, fill = NA, size = 3.4, stroke = 1.2)

p <- p + annotate("text", x = sx, y = y_laneA + 0.42, label = laneA_labels,
                   size = 3.85, color = PAL$ink, lineheight = 0.9, fontface = "bold", vjust = 0)

p <- p + annotate("text", x = xr[1] + 0.05, y = y_laneA, label = "Repayable",
                   hjust = 0, size = 6.0, color = PAL$retained, fontface = "bold")

laneA_caption <- paste(strwrap("Debt repaid with additional patients and time.", width = 20), collapse = "\n")
p <- p + annotate("text", x = sx[5] + 0.55, y = y_laneA - 0.02,
                   label = laneA_caption,
                   hjust = 0, size = 4.0, color = "#3A3A3A", lineheight = 0.95)

# --- sotorasib chronology strip beneath Lane A, DESCRIPTIVE status (dashed), externally
# documented facts, not a repo result artifact -----------------------------------------------

y_strip <- y_laneA - 1.05
strip_x <- c(1, 2, 3, 4)
strip_labels <- c(
  "960 mg pivotal\ndose, May 2021\naccelerated approval",
  "Post-marketing\nrequirement issued",
  "Randomized trial,\n960 mg vs 240 mg\nonce daily",
  "960 mg retained"
)

p <- p + geom_line(data = data.frame(x = strip_x, y = y_strip), aes(x, y),
                    color = PAL$comparator, linewidth = 1.1,
                    linetype = STATUS$descriptive$linetype, alpha = STATUS$descriptive$alpha)
p <- p + geom_point(data = data.frame(x = strip_x[1:3], y = y_strip), aes(x, y),
                     color = PAL$comparator, size = 3.4)
p <- p + geom_point(data = data.frame(x = strip_x[4], y = y_strip), aes(x, y),
                     color = PAL$retained, size = 5.4)
p <- p + geom_point(data = data.frame(x = strip_x[4], y = y_strip), aes(x, y),
                     shape = 21, color = PAL$paper, fill = NA, size = 2.6, stroke = 1.0)

p <- p + annotate("text", x = strip_x[1:3], y = y_strip - 0.34,
                   label = strip_labels[1:3], size = 3.15, color = "#3A3A3A",
                   lineheight = 0.9, vjust = 1)
p <- p + annotate("text", x = strip_x[4], y = y_strip - 0.20,
                   label = strip_labels[4], size = 3.7, color = PAL$retained,
                   fontface = "bold", vjust = 1)

p <- p + annotate("text", x = xr[1] + 0.05, y = y_strip, label = "Sotorasib\nchronology",
                   hjust = 0, size = 3.3, color = "#3A3A3A", lineheight = 0.9, fontface = "italic")
descriptive_note <- paste(strwrap(
  "Descriptive: externally documented regulatory record, not a study result from this project.",
  width = 24), collapse = "\n")
p <- p + annotate("text", x = xr[1] + 0.05, y = y_strip - 0.62,
                   label = descriptive_note,
                   hjust = 0, size = 2.85, color = "#6A6A6A", fontface = "italic", lineheight = 1.0)

# ------------------------------------------------------------------------------------------
# LANE B: irrecoverable
# true OBD available -> eliminated -> alternative abandoned -> more evidence at remaining
# option -> original comparison no longer observable
# ------------------------------------------------------------------------------------------

laneB_labels <- c(
  "True optimal\ndose available",
  "Eliminated",
  "Alternative\nabandoned",
  "More evidence\nat remaining\noption",
  "Original\ncomparison no\nlonger observable"
)

# segment 1: line begins at node 1 (retained color, this dose is on the table)
p <- p + geom_line(data = data.frame(x = sx[1:2], y = y_laneB), aes(x, y),
                    color = PAL$retained, linewidth = 1.7, lineend = "round")
p <- p + geom_point(data = data.frame(x = sx[1], y = y_laneB), aes(x, y),
                     color = PAL$retained, size = 3.2)

# the line fades out approaching node 2 ("eliminated"), then terminates: draw a short fading
# gradient by layering shrinking-alpha segments, then a dead-end tick at the elimination point
fade_df <- data.frame(
  x = seq(sx[2] - 0.28, sx[2], length.out = 6)
)
fade_df$y <- y_laneB
fade_df$a <- seq(0.85, 0.08, length.out = 6)
for (i in seq_len(nrow(fade_df) - 1)) {
  seg <- data.frame(x = c(fade_df$x[i], fade_df$x[i + 1]), y = y_laneB)
  p <- p + geom_line(data = seg, aes(x, y), color = PAL$discarded,
                      linewidth = 1.7, alpha = fade_df$a[i], lineend = "round")
}
p <- p + geom_point(data = data.frame(x = sx[2], y = y_laneB), aes(x, y),
                     shape = 4, size = 5.6, color = PAL$discarded, stroke = 2.0)

# "alternative abandoned" gets its own dead-end mark, a short perpendicular tick just after
# node 2, reinforcing that the branch is closed (not merely paused)
p <- p + annotate("segment", x = sx[3] - 0.02, xend = sx[3] - 0.02,
                   y = y_laneB - 0.16, yend = y_laneB + 0.16,
                   color = PAL$discarded, linewidth = 2.0)
p <- p + geom_point(data = data.frame(x = sx[3] - 0.02, y = y_laneB), aes(x, y),
                     shape = 21, size = 5.2, color = PAL$discarded, fill = PAL$paper, stroke = 1.8)

# segment 2: a NEW, disconnected line begins at node 4 ("more evidence at remaining option"),
# offset start, drawn in retained color to show real evidence is still being generated, but
# visually separated (a gap, plus an open-circle fresh-start marker) from the lost original
p <- p + geom_line(data = data.frame(x = sx[4:5], y = y_laneB), aes(x, y),
                    color = PAL$retained, linewidth = 1.7, lineend = "round", alpha = 0.95)
p <- p + geom_point(data = data.frame(x = sx[4], y = y_laneB), aes(x, y),
                     shape = 21, size = 5.2, color = PAL$retained, fill = PAL$paper, stroke = 1.8)
# BELOW the lane, larger, upright. Owner edit 2026-08-27, this is an important concept and not a
# footnote, so it does not crowd the line it annotates.
p <- p + annotate("text", x = mean(sx[4:5]), y = y_laneB - 0.62,
                   label = "New evidence cannot recreate\nthe abandoned comparison",
                   hjust = 0.5, size = 4.4, color = PAL$retained, lineheight = 1.05)

# terminal node 5, "original comparison no longer observable", permanently open (never closes)
p <- p + geom_point(data = data.frame(x = sx[5], y = y_laneB), aes(x, y),
                     shape = 21, size = 8.5, color = PAL$accent, fill = PAL$paper, stroke = 2.3)

p <- p + annotate("text", x = sx, y = y_laneB + 0.42, label = laneB_labels,
                   size = 3.85, color = PAL$ink, lineheight = 0.9, fontface = "bold", vjust = 0)

p <- p + annotate("text", x = xr[1] + 0.05, y = y_laneB, label = "Irrecoverable",
                   hjust = 0, size = 6.0, color = PAL$discarded, fontface = "bold")

laneB_caption <- paste(strwrap(
  paste("More patients can repay some information debt.",
        "Abandoned alternatives can create debt that additional enrollment",
        "at the surviving option cannot repay."),
  width = 20), collapse = "\n")

p <- p + annotate("text", x = sx[5] + 0.55, y = y_laneB - 0.02,
                   label = laneB_caption,
                   hjust = 0, size = 4.0, color = "#3A3A3A", lineheight = 0.95)

# ------------------------------------------------------------------------------------------
# titles
# ------------------------------------------------------------------------------------------

subtitle_wrapped <- paste(strwrap(
  paste("A dose question left open at selection is not automatically debt of the same kind.",
        "Some of it can still be repaid. Some of it cannot."),
  width = 98), collapse = "\n")

caption_wrapped <- paste(strwrap(
  paste("Conceptual illustration. Lane A and the sotorasib chronology strip beneath it are",
        "drawn on the same horizontal rhythm for visual comparison only, they are not the",
        "same timeline. Information debt: evidence the program has to generate later",
        "because of an earlier decision. Grammar: solid blue = evidence retained.",
        "Vermillion fading to a cross mark = evidence discarded. Hollow tick mark =",
        "alternative abandoned. Offset blue start = fresh evidence required, disconnected",
        "from what was lost. Open green circle = unresolved, filled/ringed blue = resolved.",
        "Dashed gray = descriptive external record (sotorasib chronology only)."),
  width = 150), collapse = "\n")

p <- p + labs(
  title = "Information debt, repayable versus irrecoverable",
  subtitle = subtitle_wrapped,
  caption = caption_wrapped
)

print(save_figure(p, "fig5_information_debt", width_in = 13.333, height_in = 7.5))
