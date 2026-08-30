# PRESENTATION VARIANT of fig5_information_debt.R, SOTORASIB CHRONOLOGY ONLY.
#
# id = "pres5b_sotorasib"
#
# The chronology facts and dates below are copied VERBATIM from the archival fig5 script's
# sotorasib strip (externally documented regulatory record, not a repo result artifact, same
# sources: FDA accelerated approval history; Amgen's Dec 26 2023 regulatory-update statement;
# CodeBreaK 201 / NCT04933695). Per the owner's instruction, "information debt" vocabulary is
# NOT reintroduced on this slide, the prior slide (pres5a) already taught the concept. One
# chronology, one takeaway sentence.

suppressPackageStartupMessages({
  library(ggplot2)
  library(grid)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

FIG_ID <- "pres5b_sotorasib"

verify_banner(
  figure_id       = FIG_ID,
  source_artifact = "sotorasib chronology: externally documented regulatory record, not a repo result artifact (cut from fig5_information_debt.R)",
  producer        = "scripts/figures/arpa_stats_meeting/pres5b_sotorasib.R",
  fields          = "approval date/dose, PMR terms, dose-comparison trial identifier, PMR fulfillment date, retained dose",
  expected        = "May 2021 accelerated approval at 960 mg, PMR for a randomized 960 vs 240 mg trial, PMR fulfilled Dec 2023, 960 mg retained",
  observed        = "same sources fig5 verified: FDA-approval-history summaries, Amgen's Dec 26 2023 regulatory-update statement, and a JCO/Cancer Letter account of CodeBreaK 201 (NCT04933695). No conflict found."
)

# ------------------------------------------------------------------------------------------
# CHRONOLOGY, five stages, one horizontal strip, full slide.
# ------------------------------------------------------------------------------------------

sx <- c(1, 2, 3, 4, 5)
strip_labels <- c(
  "960 mg\npivotal program",
  "Accelerated\napproval",
  "Postmarketing\nrequirement",
  "960 mg vs 240 mg\nrandomized comparison",
  "960 mg\nretained"
)

p <- ggplot() +
  coord_cartesian(xlim = c(0.4, 5.6), ylim = c(-1.6, 1.9), clip = "off") +
  theme_arpa(base_size = 22) +
  theme(
    axis.text = element_blank(), axis.title = element_blank(), panel.grid = element_blank(),
    plot.title = element_text(size = rel(1.3)), plot.subtitle = element_blank()
  )

p <- p + geom_line(data = data.frame(x = sx[1:4], y = 0), aes(x, y),
                    color = PAL$comparator, linewidth = 1.6,
                    linetype = STATUS$descriptive$linetype, alpha = STATUS$descriptive$alpha) +
  geom_point(data = data.frame(x = sx[1:4], y = 0), aes(x, y), color = PAL$comparator, size = 6.5) +
  geom_line(data = data.frame(x = sx[4:5], y = 0), aes(x, y),
            color = PAL$retained, linewidth = 1.8, lineend = "round") +
  geom_point(data = data.frame(x = sx[5], y = 0), aes(x, y), color = PAL$retained, size = 10.5) +
  geom_point(data = data.frame(x = sx[5], y = 0), aes(x, y), shape = 21, color = PAL$paper,
             fill = NA, size = 5.2, stroke = 1.4)

p <- p + annotate("text", x = sx, y = 0.55, label = strip_labels,
                   size = 6.1, fontface = "bold", color = PAL$ink, lineheight = 0.92, vjust = 0)
p <- p + annotate("text", x = sx[5], y = -0.55, label = "2021 → 2023",
                   size = 4.2, color = "#6A6A6A", fontface = "italic")

p <- p + annotate(
  "text", x = mean(sx), y = -1.35,
  label = "The dose was not shown to be wrong, the dose question simply remained open until after approval.",
  size = 6.6, color = PAL$ink, hjust = 0.5, fontface = "italic"
)



out <- save_figure(p, FIG_ID, width_in = 13.333, height_in = 7.5)
print(out)

rendered_strings <- c(
  title = "Sotorasib shows what buying the answer later can look like",
  strip_labels = paste(strip_labels, collapse = " | "),
  takeaway = "The dose was not shown to be wrong, the dose question simply remained open until after approval.",
  year_note = "2021 → 2023"
)
forbidden <- c("information debt", "\\bdebt\\b", "PCS", "\\btruth\\b", "\\bcell\\b", "frozen",
               "locked", "\\bpolic(y|ies)\\b")
hit <- FALSE
for (s in rendered_strings) {
  if (any(sapply(forbidden, function(pat) grepl(pat, s, ignore.case = TRUE)))) hit <- TRUE
}
stopifnot(!hit)
cat("[pres5b] jargon check PASSED, 'debt' vocabulary confirmed absent.\n")
