# PRESENTATION VARIANT, new orientation slide (owner addition, mid-build).
#
# id = "pres0a_what_we_simulated"
#
# Conceptual, no empirical values. Uses the same visual grammar as the other schematic slides in
# this set (theme.R palette and typography), in the style of pres1's simplified pipeline. One
# simple development path plus three short numbered statements, verbatim from the owner's spec.

suppressPackageStartupMessages({
  library(ggplot2)
  library(grid)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

FIG_ID <- "pres0a_what_we_simulated"

verify_banner(
  figure_id       = FIG_ID,
  source_artifact = "none (conceptual orientation schematic, no result artifact)",
  producer        = "scripts/figures/arpa_stats_meeting/pres0a_what_we_simulated.R",
  fields          = "none, all coordinates are schematic placement constants",
  expected        = "a conceptual figure carries no empirical claim to check against a result object",
  observed        = "n/a, this banner documents the absence of a source artifact rather than a check"
)

# ------------------------------------------------------------------------------------------
# STAGE GEOMETRY. Five stages: Patients arrive -> learn toxicity + efficacy -> choose dose(s)
# -> phase II / confirmation -> final development outcome.
# ------------------------------------------------------------------------------------------

stage_x <- c(1, 2, 3, 4, 5)
stage_names <- c(
  "Patients\narrive",
  "Learn about\ntoxicity + efficacy",
  "Choose\ndose(s)",
  "Phase II /\nconfirmation",
  "Final development\noutcome"
)

y_path      <- 1.55
y_stage_lab <- 1.05

xr <- range(stage_x) + c(-0.55, 0.55)

p <- ggplot() +
  coord_cartesian(xlim = xr, ylim = c(-3.3, 2.2), clip = "off") +
  theme_arpa(base_size = 20) +
  theme(
    axis.text = element_blank(), axis.title = element_blank(), panel.grid = element_blank(),
    plot.title = element_text(size = rel(1.45)), plot.subtitle = element_blank()
  )

path_df <- data.frame(x = stage_x, y = y_path)
p <- p +
  geom_line(data = path_df, aes(x, y), color = PAL$ink, linewidth = 1.3) +
  geom_point(data = path_df, aes(x, y), color = PAL$ink, fill = PAL$paper,
             shape = 21, size = 7, stroke = 1.5) +
  annotate("segment", x = stage_x[5], y = y_path, xend = stage_x[5] + 0.32, yend = y_path,
           color = PAL$ink, linewidth = 1.3,
           arrow = arrow(length = unit(0.18, "in"), type = "closed")) +
  annotate("text", x = stage_x, y = y_stage_lab, label = stage_names,
           size = 5.2, fontface = "bold", color = PAL$ink, lineheight = 0.92, vjust = 1)

# ------------------------------------------------------------------------------------------
# THREE NUMBERED STATEMENTS, verbatim.
# ------------------------------------------------------------------------------------------

statements <- c(
  "1. Start with established designs. BOIN, BOIN12, U-BOIN, each calibrated within its own family.",
  "2. Simulate complete development programs. Not just which dose is selected, but what happens after selection.",
  "3. Change one development decision at a time. When efficacy enters, how doses are ranked, which options remain, and what evidence can be reused."
)
statements_wrapped <- vapply(statements, function(s) paste(strwrap(s, width = 108), collapse = "\n"),
                              character(1))

y_stmt <- c(-0.95, -1.85, -2.85)
for (i in seq_along(statements_wrapped)) {
  p <- p + annotate("text", x = xr[1] + 0.05, y = y_stmt[i], label = statements_wrapped[i],
                     hjust = 0, vjust = 1, size = 5.6, color = PAL$ink, lineheight = 1.08)
}



out <- save_figure(p, FIG_ID, width_in = 13.333, height_in = 7.5)
print(out)

rendered_strings <- c(
  title = "What did we actually simulate?",
  stages = paste(stage_names, collapse = " | "),
  statements = paste(statements, collapse = " || ")
)
forbidden <- c("PCS", "\\btruth\\b", "\\bcell\\b", "frozen", "locked", "\\bpolic(y|ies)\\b",
               "\\bE1\\b", "\\bE2\\b", "kernel", "backbone")
hit <- FALSE
for (s in rendered_strings) {
  if (any(sapply(forbidden, function(pat) grepl(pat, s, ignore.case = TRUE)))) hit <- TRUE
}
stopifnot(!hit)
cat("[pres0a] jargon check PASSED.\n")
