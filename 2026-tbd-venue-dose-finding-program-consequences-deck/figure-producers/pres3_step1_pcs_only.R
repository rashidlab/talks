# PRESENTATION VARIANT of fig3_pcs_wrong_policy.R, LEFT COLUMN ONLY, for progressive reveal.
#
# id = "pres3_step1_pcs_only"
#
# Data loading, filtering, the identical-values assertion, and the collapse to six distinct
# design strategies are copied from the archival fig3 script (results/exp7_compose.rds$design),
# identically to pres3_pcs_wrong_policy.R. This script reads none of exp7_persistence.rds or
# exp7_q3_primary.rds, because step 1 shows only the chance of selecting the correct dose, no
# crossing annotation and no confirmation-stage value.
#
# Per the owner's inspection criterion: this is composed as its OWN standalone chart (a ranked
# dot plot spanning the full canvas), not as the slopegraph with the right column deleted, so a
# viewer sees a complete figure with no hint that a second axis is coming. No connecting lines,
# no right-column values, no "Chance of ultimately confirming" text anywhere on the page.

suppressPackageStartupMessages({
  library(ggplot2)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

FIG_ID <- "pres3_step1_pcs_only"

# ------------------------------------------------------------------------------------------
# 1. LOAD, FILTER, COLLAPSE, identical logic to pres3_pcs_wrong_policy.R.
# ------------------------------------------------------------------------------------------

compose <- readRDS(file.path(ROOT, "results", "exp7_compose.rds"))
design  <- compose$design

sub <- design[design$module == "primary" &
              design$inferential_role == "PRIMARY_INFERENTIAL_SET", ]

stopifnot(nrow(sub) == 9)
stopifnot(length(unique(sub$policy_id)) == 6)
stopifnot(all(grepl("application\\|OBD_monotone", sub$key, fixed = FALSE)))

sub <- sub[order(sub$policy_id, sub$w), ]
for (pid in unique(sub$policy_id)) {
  rows <- sub[sub$policy_id == pid, ]
  if (nrow(rows) > 1) {
    stopifnot(length(unique(rows$PCShat)) == 1L)
    stopifnot(length(unique(rows$POShat)) == 1L)
  }
}

weight_phrase <- function(w) {
  if (isTRUE(all.equal(w, 0)))   return("lower worst-case enrollment")
  if (isTRUE(all.equal(w, 1)))   return("lower average enrollment")
  if (isTRUE(all.equal(w, 0.5))) return("balanced")
  stop("unexpected weight value: ", w)
}

collapsed <- do.call(rbind, lapply(split(sub, sub$policy_id), function(rows) {
  ws <- sort(rows$w)
  fam_label <- switch(rows$family[1],
                       boin = "BOIN", boin12 = "BOIN12", uboin = "U-BOIN", rows$family[1])
  if (length(ws) == 3) {
    trade_label <- "same strategy across settings"
  } else if (length(ws) == 2) {
    phrases <- vapply(ws, weight_phrase, character(1))
    trade_label <- paste(phrases, collapse = " or ")
  } else {
    trade_label <- weight_phrase(ws)
  }
  data.frame(
    policy_id = rows$policy_id[1], family = rows$family[1],
    label = paste0(fam_label, ", ", trade_label),
    PCShat = rows$PCShat[1], POShat = rows$POShat[1],
    stringsAsFactors = FALSE
  )
}))
rownames(collapsed) <- NULL
stopifnot(nrow(collapsed) == 6)

expected_labels <- c(
  "BOIN12, lower average enrollment", "BOIN12, balanced", "BOIN12, lower worst-case enrollment",
  "BOIN, same strategy across settings",
  "U-BOIN, lower average enrollment", "U-BOIN, lower worst-case enrollment or balanced"
)
stopifnot(setequal(collapsed$label, expected_labels))
cat("[pres3_step1] ASSERTION PASSED: six collapsed labels match expected wording.\n")

verify_banner(
  figure_id = FIG_ID,
  source_artifact = "results/exp7_compose.rds$design",
  producer = "scripts/figures/arpa_stats_meeting/pres3_step1_pcs_only.R (cut from fig3_pcs_wrong_policy.R, left column only)",
  fields = c("policy_id", "family", "w", "PCShat"),
  expected = "9 rows / 6 distinct policy_id, collapsed labels matching owner wording",
  observed = sprintf("%d rows / %d distinct policy_id", nrow(sub), length(unique(sub$policy_id)))
)

POLICY_COLORS <- c("#E69F00", "#56B4E9", "#F0E442", "#CC79A7", "#000000", "#7F3C8D")
collapsed <- collapsed[order(-collapsed$PCShat), ]
collapsed$color <- POLICY_COLORS[seq_len(nrow(collapsed))]
collapsed$label <- factor(collapsed$label, levels = rev(collapsed$label))

# ------------------------------------------------------------------------------------------
# 2. STANDALONE RANKED DOT PLOT. Full-canvas, single axis, own title. No connecting lines,
#    no right-column content, no confirmation-stage vocabulary anywhere on the page.
# ------------------------------------------------------------------------------------------

p <- ggplot(collapsed, aes(x = PCShat, y = label)) +
  geom_segment(aes(x = 0, xend = PCShat, yend = label), color = "#C9C9C9", linewidth = 1.6) +
  geom_point(aes(color = label), size = 8.5, show.legend = FALSE) +
  geom_text(aes(label = sprintf("%.0f%%", 100 * PCShat)), hjust = -0.55, size = 7.2,
            color = PAL$ink, fontface = "bold") +
  scale_color_manual(values = setNames(collapsed$color, collapsed$label)) +
  scale_x_continuous(limits = c(0, max(collapsed$PCShat) * 1.22),
                      labels = scales::percent_format(accuracy = 1),
                      expand = expansion(mult = c(0, 0.02))) +
  labs(
    title = NULL,
    subtitle = "Which would you choose?",
    x = "Chance of selecting the correct dose",
    y = NULL
  ) +
  theme_arpa(base_size = 23) +
  theme(
    axis.text.y = element_text(size = rel(1.0), face = "bold", color = PAL$ink),
    panel.grid.major.y = element_blank(),
    plot.title = element_text(size = rel(1.25), lineheight = 1.05),
    plot.subtitle = element_text(size = rel(1.15), face = "italic", color = PAL$ink,
                                  margin = margin(t = 4, b = 12))
  )

out <- save_figure(p, FIG_ID, width_in = 13.333, height_in = 7.5)
print(out)

rendered_strings <- c(
  title = "Six design strategies",
  subtitle = "Which would you choose?",
  x_axis = "Chance of selecting the correct dose",
  labels = paste(as.character(collapsed$label), collapse = " | ")
)
forbidden <- c("PCS", "confirm", "truth", "cell", "frozen", "locked", "\\bpolic(y|ies)\\b")
hit <- FALSE
for (s in rendered_strings) {
  if (any(sapply(forbidden, function(pat) grepl(pat, s, ignore.case = TRUE)))) hit <- TRUE
}
stopifnot(!hit)
cat("[pres3_step1] jargon check PASSED, no confirmation-stage vocabulary present.\n")
