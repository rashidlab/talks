# PRESENTATION VARIANT built from the inset of fig3_pcs_wrong_policy.R (results/exp7_q3_primary.rds).
#
# id = "pres3b_mechanism"
#
# The archival fig3 script drew this as a small inset decision-tree bar chart tucked inside the
# slopegraph. Here it gets its own slide, drawn large, three horizontal outcome bars. Data
# loading and the numeric assertions are copied VERBATIM from fig3's inset section (same object,
# same qmap keys, same expected values, same tolerance).

suppressPackageStartupMessages({
  library(ggplot2)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

FIG_ID <- "pres3b_mechanism"

q3 <- readRDS(file.path(ROOT, "results", "exp7_q3_primary.rds"))

cat("[pres3b] q3_primary$dstar:", q3$dstar, "\n")
stopifnot(q3$dstar == 3)

qmap <- q3$qmap
cat("[pres3b] q3_primary$qmap:\n")
print(qmap)

q_target <- unname(qmap["3"])
q_neighbor <- unname(qmap["2"])
q_none <- unname(qmap["none"])

cat(sprintf("[pres3b] q_target   : %.9f (expected ~0.780944107)\n", q_target))
cat(sprintf("[pres3b] q_neighbor : %.9f (expected ~0.693228528)\n", q_neighbor))
cat(sprintf("[pres3b] q_none     : %.9f (expected 0)\n", q_none))

stopifnot(abs(q_target - 0.780944107) < 1e-6)
stopifnot(abs(q_neighbor - 0.693228528) < 1e-6)
stopifnot(q_none == 0)
cat("[pres3b] ASSERTION PASSED: values match expected magnitudes to within 1e-6.\n")

verify_banner(
  figure_id = FIG_ID,
  source_artifact = "results/exp7_q3_primary.rds",
  producer = "scripts/figures/arpa_stats_meeting/pres3b_mechanism.R (cut from fig3_pcs_wrong_policy.R's inset)",
  fields = c("qmap", "dstar"),
  expected = "qmap[3]~0.781, qmap[2]~0.693, qmap[none]=0, dstar=3",
  observed = sprintf("qmap[3]=%.6f, qmap[2]=%.6f, qmap[none]=%.6f, dstar=%d",
                      q_target, q_neighbor, q_none, q3$dstar)
)

bar_df <- data.frame(
  outcome = factor(
    c("Correct dose selected", "Adjacent dose selected", "No dose selected"),
    levels = c("No dose selected", "Adjacent dose selected", "Correct dose selected")
  ),
  value = c(q_target, q_neighbor, q_none),
  label = c(sprintf("%.1f%%", 100 * q_target),
            sprintf("%.1f%%", 100 * q_neighbor),
            sprintf("%.0f%%", 100 * q_none))
)
bar_df$fill <- c(PAL$comparator, "#56B4E9", PAL$retained)[match(bar_df$outcome,
  c("No dose selected", "Adjacent dose selected", "Correct dose selected"))]

# ------------------------------------------------------------------------------------------
# PLOT. Three large horizontal bars, own slide, one sentence beneath.
# ------------------------------------------------------------------------------------------

p <- ggplot(bar_df, aes(x = outcome, y = value)) +
  geom_col(aes(fill = outcome), width = 0.6, show.legend = FALSE) +
  geom_text(aes(label = label), hjust = -0.12, size = 9.5, color = PAL$ink, fontface = "bold") +
  scale_fill_manual(values = setNames(bar_df$fill, bar_df$outcome)) +
  coord_flip(clip = "off") +
  scale_y_continuous(limits = c(0, 0.92), expand = expansion(mult = c(0, 0.02))) +
  labs(
    title = NULL,
    x = NULL,
    y = NULL,
    caption = paste(strwrap(
      "Correct-dose selection treats only the first outcome as success, even though the other outcomes have very different consequences later.",
      width = 74), collapse = "\n")
  ) +
  theme_arpa(base_size = 24) +
  theme(
    axis.text.y = element_text(size = rel(1.05), face = "bold"),
    axis.text.x = element_blank(),
    axis.title.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_blank(),
    plot.title = element_text(size = rel(1.05), lineheight = 1.05),
    plot.caption = element_text(size = rel(0.85), color = "#3A3A3A", face = "italic",
                                 hjust = 0, lineheight = 1.1, margin = margin(t = 22)),
    plot.margin = margin(16, 90, 20, 16)
  )

out <- save_figure(p, FIG_ID, width_in = 13.333, height_in = 7.5)
print(out)

rendered_strings <- c(
  title = "none, the slide owns the title",
  y_axis = "none",
  bars = paste(as.character(bar_df$outcome), collapse = " | "),
  note = "Correct-dose selection treats only the first outcome as success, even though the other outcomes have very different consequences later."
)
forbidden <- c("PCS", "\\btruth\\b", "\\bcell\\b", "frozen", "locked", "\\bpolic(y|ies)\\b", "qmap", "dstar")
hit <- FALSE
for (s in rendered_strings) {
  if (any(sapply(forbidden, function(pat) grepl(pat, s, ignore.case = TRUE)))) hit <- TRUE
}
stopifnot(!hit)
cat("[pres3b] jargon check PASSED.\n")
