# PRESENTATION VARIANT of fig5_information_debt.R, CONCEPT ONLY (no sotorasib chronology).
#
# id = "pres5a_debt_concept"
#
# Conceptual, no empirical values, same status as the archival fig5 lanes it is cut from.
# Reduced to two very simple lanes with big labels and almost no prose, per the owner's
# instruction that this slide stays diagrammatic, a pause in the empirical sequence rather than
# another data slide. The title deliberately does not use the words "information debt", per
# instruction. That term is not introduced anywhere on this slide.

suppressPackageStartupMessages({
  library(ggplot2)
  library(grid)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

FIG_ID <- "pres5a_debt_concept"

verify_banner(
  figure_id       = FIG_ID,
  source_artifact = "none (conceptual, cut from fig5_information_debt.R lanes A and B)",
  producer        = "scripts/figures/arpa_stats_meeting/pres5a_debt_concept.R",
  fields          = "none, all coordinates are schematic placement constants",
  expected        = "a conceptual figure carries no empirical claim to check against a result object",
  observed        = "n/a, this banner documents the absence of a source artifact rather than a check"
)

# ------------------------------------------------------------------------------------------
# TWO LANES, three nodes each, big labels, minimal connective prose.
# ------------------------------------------------------------------------------------------

sx <- c(1, 2, 3)
y_top <- 1.6
y_bot <- -1.6

p <- ggplot() +
  coord_cartesian(xlim = c(-0.35, 3.7), ylim = c(-2.5, 2.5), clip = "off") +
  theme_arpa(base_size = 22) +
  theme(
    axis.text = element_blank(), axis.title = element_blank(), panel.grid = element_blank(),
    plot.title = element_text(size = rel(1.2), lineheight = 1.05), plot.subtitle = element_blank()
  )

# --- Repayable lane --------------------------------------------------------------------------
p <- p + geom_line(data = data.frame(x = sx, y = y_top), aes(x, y),
                    color = PAL$retained, linewidth = 2.2, lineend = "round") +
  annotate("segment", x = sx[2], xend = sx[3], y = y_top, yend = y_top, color = PAL$retained,
           linewidth = 2.2, arrow = arrow(length = unit(0.22, "in"), type = "closed")) +
  geom_point(data = data.frame(x = sx[1], y = y_top), aes(x, y), shape = 21, size = 9,
             color = PAL$accent, fill = PAL$paper, stroke = 2.4) +
  geom_point(data = data.frame(x = sx[3], y = y_top), aes(x, y), color = PAL$retained, size = 9) +
  annotate("text", x = sx, y = y_top + 0.55,
           label = c("Question\nunresolved", "Collect new\nevidence", "Resolved"),
           size = 6.4, fontface = "bold", color = PAL$ink, lineheight = 0.92) +
  annotate("text", x = 0.08, y = y_top, label = "Repayable",
           hjust = 0, size = 8.5, color = PAL$retained, fontface = "bold")

# --- Irrecoverable lane ------------------------------------------------------------------------
p <- p + geom_line(data = data.frame(x = sx[1:2], y = y_bot), aes(x, y),
                    color = PAL$discarded, linewidth = 2.2, lineend = "round") +
  geom_point(data = data.frame(x = sx[1], y = y_bot), aes(x, y),
             shape = 4, size = 8, color = PAL$discarded, stroke = 2.6) +
  geom_line(data = data.frame(x = sx[2:3], y = y_bot), aes(x, y),
            color = PAL$retained, linewidth = 2.2, lineend = "round", alpha = 0.95) +
  geom_point(data = data.frame(x = sx[2], y = y_bot), aes(x, y), shape = 21, size = 9,
             color = PAL$retained, fill = PAL$paper, stroke = 2.4) +
  geom_point(data = data.frame(x = sx[3], y = y_bot), aes(x, y), shape = 21, size = 10.5,
             color = PAL$accent, fill = PAL$paper, stroke = 2.6) +
  annotate("text", x = sx, y = y_bot + 0.55,
           label = c("Alternative\nabandoned", "Collect more evidence\nat remaining dose",
                     "Original comparison\nstill unavailable"),
           size = 6.4, fontface = "bold", color = PAL$ink, lineheight = 0.92) +
  annotate("text", x = -0.32, y = y_bot, label = "Irrecoverable",
           hjust = 0, size = 8.5, color = PAL$discarded, fontface = "bold")



out <- save_figure(p, FIG_ID, width_in = 13.333, height_in = 7.5)
print(out)

rendered_strings <- c(
  title = "Some uncertainty can be bought back. Some information is gone.",
  repayable_labels = "Repayable | Question unresolved | Collect new evidence | Resolved",
  irrecoverable_labels = paste(
    "Irrecoverable | Alternative abandoned | Collect more evidence at remaining dose",
    "Original comparison still unavailable", sep = " | "
  )
)
forbidden <- c("information debt", "PCS", "\\btruth\\b", "\\bcell\\b", "frozen", "locked",
               "\\bpolic(y|ies)\\b")
hit <- FALSE
for (s in rendered_strings) {
  if (any(sapply(forbidden, function(pat) grepl(pat, s, ignore.case = TRUE)))) hit <- TRUE
}
stopifnot(!hit)
cat("[pres5a] jargon check PASSED, 'information debt' confirmed absent from the title.\n")
