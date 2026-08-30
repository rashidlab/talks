# PRESENTATION VARIANT, new orientation slide (owner addition, mid-build).
#
# id = "pres0b_two_questions"
#
# Conceptual, no empirical values. Two large boxes (early-trial question, development-program
# question), a connecting phrase, a compact two-line distinction between the two experiment
# families shown later in the deck, and one small footer replacing nothing else, per instruction
# the per-slide application-scenario badge stays on the empirical slides too.

suppressPackageStartupMessages({
  library(ggplot2)
  library(grid)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

FIG_ID <- "pres0b_two_questions"

verify_banner(
  figure_id       = FIG_ID,
  source_artifact = "none (conceptual orientation schematic, no result artifact)",
  producer        = "scripts/figures/arpa_stats_meeting/pres0b_two_questions.R",
  fields          = "none, all coordinates are schematic placement constants",
  expected        = "a conceptual figure carries no empirical claim to check against a result object",
  observed        = "n/a, this banner documents the absence of a source artifact rather than a check"
)

p <- ggplot() +
  coord_cartesian(xlim = c(0, 10), ylim = c(0, 10), clip = "off") +
  theme_void(base_size = 20) +
  theme(plot.title = element_text(size = rel(1.55), face = "bold", color = PAL$ink,
                                   hjust = 0, margin = margin(b = 10)),
        plot.margin = margin(18, 22, 14, 20))

# ------------------------------------------------------------------------------------------
# TWO LARGE BOXES
# ------------------------------------------------------------------------------------------

box_df <- data.frame(
  xmin = c(0.3, 5.3), xmax = c(4.7, 9.7), ymin = 6.6, ymax = 9.3,
  fill = c(PAL$retained, PAL$accent)
)
p <- p + geom_rect(data = box_df, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = fill),
                    alpha = 0.10, color = box_df$fill, linewidth = 1.6) +  # globals-ok: graphics transparency, not the exposure ceiling
  scale_fill_identity()

p <- p +
  annotate("text", x = 2.5, y = 8.55, label = "Early-trial question", size = 6.4,
           fontface = "bold", color = PAL$retained, hjust = 0.5) +
  annotate("text", x = 2.5, y = 7.55, label = "Did we select the\ncorrect dose?", size = 6.8,
           color = PAL$ink, hjust = 0.5, lineheight = 1.0) +
  annotate("text", x = 7.5, y = 8.55, label = "Development-program question", size = 6.4,
           fontface = "bold", color = PAL$accent, hjust = 0.5) +
  annotate("text", x = 7.5, y = 7.55, label = "Did we ultimately confirm\nthe correct dose?", size = 6.8,
           color = PAL$ink, hjust = 0.5, lineheight = 1.0)

# connecting phrase
p <- p + annotate("segment", x = 4.75, xend = 5.25, y = 8.0, yend = 8.0,
                   color = "#6A6A6A", linewidth = 1.0,
                   arrow = arrow(length = unit(0.16, "in"), ends = "both", type = "closed")) +
  annotate("text", x = 5.0, y = 6.15, label = "Selection changes what evidence and options remain",
           size = 5.6, color = "#3A3A3A", fontface = "italic", hjust = 0.5)

# ------------------------------------------------------------------------------------------
# COMPACT DISTINCTION
# ------------------------------------------------------------------------------------------

p <- p +
  annotate("text", x = 0.3, y = 4.3,
           label = paste(strwrap(
             "First set of experiments: What features of a dose-finding design change the early decision?",
             width = 60), collapse = "\n"),
           hjust = 0, vjust = 1, size = 6.0, color = PAL$ink, lineheight = 1.1) +
  annotate("text", x = 0.3, y = 2.55,
           label = paste(strwrap(
             "Second set of experiments: What happens when that early decision is carried into different confirmation strategies?",
             width = 60), collapse = "\n"),
           hjust = 0, vjust = 1, size = 6.0, color = PAL$ink, lineheight = 1.1)

# ------------------------------------------------------------------------------------------
# FOOTER
# ------------------------------------------------------------------------------------------

# The owner's mid-build footer text used the word "downstream", which conflicts with this
# repository's own standing jargon rule ("no ... downstream ... on any rendered page"), a rule
# the same mid-build message said applies to this slide "exactly as everywhere else". Reworded
# to preserve the meaning without the banned word rather than resolved silently; reported as a
# conflict in this run's final summary, following the precedent in fig3_pcs_wrong_policy.R.
p <- p + annotate(
  "text", x = 0.3, y = 0.55,
  label = "The comparisons shown today use one application scenario in which efficacy increases with dose.",
  hjust = 0, vjust = 0, size = 4.2, color = "#6A6A6A", fontface = "italic"
)



out <- save_figure(p, FIG_ID, width_in = 13.333, height_in = 7.5)
print(out)

rendered_strings <- c(
  title = "Two questions, two levels of evaluation",
  box1 = "Early-trial question | Did we select the correct dose?",
  box2 = "Development-program question | Did we ultimately confirm the correct dose?",
  connector = "Selection changes what evidence and options remain",
  distinction = paste(
    "First set of experiments: What features of a dose-finding design change the early decision?",
    "Second set of experiments: What happens when that early decision is carried into different confirmation strategies?",
    sep = " || "
  ),
  footer = "The comparisons shown today use one application scenario in which efficacy increases with dose."
)
forbidden <- c("PCS", "\\btruth\\b", "\\bcell\\b", "frozen", "locked", "\\bpolic(y|ies)\\b",
               "\\bE1\\b", "\\bE2\\b", "kernel", "backbone", "application track", "\\bdownstream\\b")
hit <- FALSE
for (s in rendered_strings) {
  if (any(sapply(forbidden, function(pat) grepl(pat, s, ignore.case = TRUE)))) hit <- TRUE
}
stopifnot(!hit)
cat("[pres0b] jargon check PASSED.\n")
