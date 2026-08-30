# PRESENTATION VARIANT of fig4_phase_boundary_information_policy.R, LEFT HALF ONLY.
#
# id = "pres4a_architectures"
#
# The four schematic-drawing helpers and the four panel constructions below are copied from the
# archival fig4 script's left-half section (schematic_base, node_layer, deadend_layer, and the
# four panels: single, parallel, hard boundary, permeable boundary). Conceptual, no empirical
# values, same as that section of fig4. The right-half forest plot and its
# results/exp8_q5_primary.rds data are NOT read here, that content moved to pres4b entirely.

suppressPackageStartupMessages({
  library(ggplot2)
  library(grid)
  library(cowplot)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
source(file.path(ROOT, "scripts", "figures", "arpa_stats_meeting", "theme.R"))

FIG_ID <- "pres4a_architectures"

verify_banner(
  figure_id       = FIG_ID,
  source_artifact = "none (conceptual schematics, cut from fig4_phase_boundary_information_policy.R left half)",
  producer        = "scripts/figures/arpa_stats_meeting/pres4a_architectures.R",
  fields          = "none, all coordinates are schematic placement constants",
  expected        = "a conceptual figure carries no empirical claim to check against a result object",
  observed        = "n/a, this banner documents the absence of a source artifact rather than a check"
)

# =================================================================================================
# SCHEMATIC HELPERS, identical geometry constants and grammar to fig4.
# =================================================================================================

SEL_X0   <- 0.02
SEL_X1   <- 0.42
SEAM_X   <- 0.50
CONF_X0  <- 0.58
CONF_X1  <- 0.98

# sub_txt is accepted for documentation/traceability at the call site but is NOT drawn inside
# this ggplot. Each schematic's caption is drawn later, once, by the composed cowplot layer at
# an absolute canvas position confined to that panel's own column, because drawing it inside the
# ggplot with clip="off" let adjacent panels' captions bleed into and overlap each other.
schematic_base <- function(title_txt, sub_txt) {
  ggplot() +
    coord_cartesian(xlim = c(0, 1), ylim = c(0, 1), expand = FALSE, clip = "on") +
    theme_void(base_size = 20) +
    theme(
      plot.title = element_text(size = rel(1.05), face = "bold", color = PAL$ink,
                                 hjust = 0.5, margin = margin(t = 4, b = 4)),
      plot.margin = margin(4, 8, 4, 8)
    ) +
    labs(title = title_txt)
}

node_layer <- function(x, y, open = FALSE) {
  if (open) {
    list(geom_point(aes(x = x, y = y), shape = 21, size = 5.2, stroke = 1.6,
                     fill = PAL$paper, color = PAL$accent))
  } else {
    list(geom_point(aes(x = x, y = y), shape = 21, size = 5.2, stroke = 1.4,
                     fill = PAL$ink, color = PAL$ink))
  }
}

deadend_layer <- function(x, y) {
  list(geom_segment(aes(x = x, xend = x, y = y - 0.07, yend = y + 0.07),
                     color = PAL$discarded, linewidth = 1.8, lineend = "butt"))
}

CONCEPT_ALPHA <- STATUS$conceptual$alpha

stage_labels <- function() {
  list(
    annotate("text", x = SEL_X0 + (SEL_X1 - SEL_X0) / 2, y = 0.97, label = "selection",
             size = 4.0, color = "#5A5A5A"),
    annotate("text", x = CONF_X0 + (CONF_X1 - CONF_X0) / 2, y = 0.97, label = "confirmation",
             size = 4.0, color = "#5A5A5A")
  )
}

# ONE VOCABULARY FOR THE FOUR ARCHITECTURES, DRAWN FROM R/exp8_arch.R's EXP8_ARCH_TREE.
#
# WHY THESE EXACT STRINGS AND WHY THEY ARE REPEATED VERBATIM IN THE OTHER TWO PRODUCERS. This
# schematic, scripts/figures/conference_deck/talk_architecture.R and pres6_no_free_optionality.R
# each named the same four architectures differently, and the room carried away a takeaway the
# deck's own mechanism slide refuses. The names below are the deck's canonical set. They are
# guarded by the deck repo's check/vocabulary_check.R, which reads the string literals of every
# producer the deck embeds and fails on a divergence, so agreement is enforced rather than
# remembered.
#
# THE ARCHITECTURE EACH NAME DENOTES, keyed on EXP8_ARCH_TREE's own rows.
#   single             one dose forwarded                                   Commit early
#   parallel           two doses forwarded, both confirmed                  Keep both through confirmation
#   select_exclude     selection stage, HARD boundary, fresh data only      Select one, then restart evidence
#   select_incorporate selection stage, PERMEABLE boundary, stage one reused  Select one, then reuse evidence
#
# The line breaks are placement, not content. Every title wraps to two lines so the four panel
# bodies start at the same height, and the check normalises whitespace before comparing.
ARCH_TITLE <- c(
  single             = "Commit\nearly",
  parallel           = "Keep both through\nconfirmation",
  select_exclude     = "Select one, then\nrestart evidence",
  select_incorporate = "Select one, then\nreuse evidence"
)

# --- Panel 1: single, COMMIT EARLY -------------------------------------------------------------
p_single <- schematic_base(ARCH_TITLE[["single"]], "One dose moves forward, the other is dropped.") +
  geom_segment(aes(x = SEL_X0, xend = SEL_X1, y = 0.5, yend = 0.65),
               color = PAL$retained, linewidth = 1.4, alpha = CONCEPT_ALPHA) +
  geom_segment(aes(x = SEL_X0, xend = SEL_X1, y = 0.5, yend = 0.35),
               color = PAL$discarded, linewidth = 1.4, alpha = CONCEPT_ALPHA) +
  geom_segment(aes(x = SEL_X1, xend = CONF_X1, y = 0.65, yend = 0.65),
               color = PAL$retained, linewidth = 1.9, alpha = CONCEPT_ALPHA) +
  deadend_layer(SEL_X1, 0.35) +
  node_layer(SEL_X0, 0.5) + node_layer(CONF_X1, 0.65) +
  stage_labels()

# --- Panel 2: parallel, KEEP BOTH THROUGH CONFIRMATION -----------------------------------------
p_parallel <- schematic_base(ARCH_TITLE[["parallel"]], "Both doses continue into confirmation.") +
  geom_segment(aes(x = SEL_X0, xend = SEL_X1, y = 0.5, yend = 0.65),
               color = PAL$retained, linewidth = 1.4, alpha = CONCEPT_ALPHA) +
  geom_segment(aes(x = SEL_X0, xend = SEL_X1, y = 0.5, yend = 0.35),
               color = PAL$retained, linewidth = 1.4, alpha = CONCEPT_ALPHA) +
  geom_segment(aes(x = SEL_X1, xend = CONF_X1, y = 0.65, yend = 0.65),
               color = PAL$retained, linewidth = 1.9, alpha = CONCEPT_ALPHA) +
  geom_segment(aes(x = SEL_X1, xend = CONF_X1, y = 0.35, yend = 0.35),
               color = PAL$retained, linewidth = 1.9, alpha = CONCEPT_ALPHA) +
  node_layer(SEL_X0, 0.5) + node_layer(CONF_X1, 0.65) + node_layer(CONF_X1, 0.35) +
  stage_labels()

# --- Panel 3: select_exclude, SELECT ONE THEN RESTART EVIDENCE ----------------------------------
seam_df <- data.frame(x = SEAM_X, y1 = 0.02, y2 = 0.90)
fade_df <- data.frame(x = seq(SEL_X1, SEAM_X, length.out = 30), y = 0.65)
fade_df$a <- seq(1, 0.05, length.out = 30) * CONCEPT_ALPHA

p_hard <- schematic_base(ARCH_TITLE[["select_exclude"]], "The chosen dose's earlier evidence does not carry forward.") +
  geom_segment(aes(x = SEL_X0, xend = SEL_X1, y = 0.5, yend = 0.65),
               color = PAL$retained, linewidth = 1.4, alpha = CONCEPT_ALPHA) +
  geom_segment(aes(x = SEL_X0, xend = SEL_X1, y = 0.5, yend = 0.35),
               color = PAL$discarded, linewidth = 1.4, alpha = CONCEPT_ALPHA) +
  deadend_layer(SEL_X1, 0.35) +
  geom_line(data = fade_df, aes(x = x, y = y, alpha = a, group = 1),
            color = PAL$discarded, linewidth = 1.9) +
  scale_alpha_identity() +
  geom_segment(data = seam_df, aes(x = x, xend = x, y = y1, yend = y2),
               color = PAL$ink, linewidth = 1.0, linetype = "22") +
  geom_segment(aes(x = SEAM_X + 0.02, xend = CONF_X1, y = 0.65, yend = 0.65),
               color = PAL$retained, linewidth = 1.9, alpha = CONCEPT_ALPHA) +
  node_layer(SEL_X0, 0.5) + node_layer(SEAM_X + 0.02, 0.65, open = TRUE) + node_layer(CONF_X1, 0.65) +
  stage_labels()

# --- Panel 4: select_incorporate, SELECT ONE THEN REUSE EVIDENCE -------------------------------
p_permeable <- schematic_base(ARCH_TITLE[["select_incorporate"]], "The chosen dose's earlier evidence carries forward.") +
  geom_segment(aes(x = SEL_X0, xend = SEL_X1, y = 0.5, yend = 0.65),
               color = PAL$retained, linewidth = 1.4, alpha = CONCEPT_ALPHA) +
  geom_segment(aes(x = SEL_X0, xend = SEL_X1, y = 0.5, yend = 0.35),
               color = PAL$discarded, linewidth = 1.4, alpha = CONCEPT_ALPHA) +
  deadend_layer(SEL_X1, 0.35) +
  geom_segment(aes(x = SEL_X1, xend = CONF_X1, y = 0.65, yend = 0.65),
               color = PAL$retained, linewidth = 1.9, alpha = CONCEPT_ALPHA) +
  geom_segment(data = seam_df, aes(x = x, xend = x, y = y1, yend = y2),
               color = PAL$ink, linewidth = 1.0, linetype = "22") +
  node_layer(SEL_X0, 0.5) + node_layer(CONF_X1, 0.65) +
  stage_labels()

# =================================================================================================
# COMPOSE. Four panels, equal width, full canvas, own title.
# =================================================================================================

full <- cowplot::ggdraw() +
  cowplot::draw_grob(grid::rectGrob(gp = grid::gpar(fill = PAL$paper, col = NA)),
                      x = 0, y = 0, width = 1, height = 1) +
  cowplot::draw_grob(grid::nullGrob())

n_sch <- 4
gap_sch <- 0.025
x0 <- 0.03; x1 <- 0.97
panel_w <- (x1 - x0 - (n_sch - 1) * gap_sch) / n_sch
sch_x0 <- x0 + (0:(n_sch - 1)) * (panel_w + gap_sch)
# Left to right in EXP8_ARCH_TREE's structural order, dose count then selection stage then
# boundary permeability. That order carries no ranking and is the same order pres6 uses, so a
# viewer who has seen one figure reads the other in the same sequence.
sch_plots <- list(single = p_single, parallel = p_parallel,
                  select_exclude = p_hard, select_incorporate = p_permeable)
stopifnot("panel order must follow the canonical architecture vocabulary" =
            identical(names(sch_plots), names(ARCH_TITLE)))

PANEL_Y <- 0.17
PANEL_H <- 0.77
for (i in seq_len(n_sch)) {
  full <- full + cowplot::draw_plot(sch_plots[[i]], x = sch_x0[i], y = PANEL_Y,
                                     width = panel_w, height = PANEL_H)
}

# =================================================================================================
# THE KEY, DRAWN INSIDE THE ARTWORK.
#
# WHY IT EXISTS. The schematics carried four encodings and no key at all, so a viewer had to infer
# from context that blue and orange mean opposite things and had no way at all to read the green
# circle, which is drawn in exactly one of the four panels.
#
# EACH ENTRY IS READ OFF THE DRAWING CODE ABOVE, not off an assumption about what the colors
# usually mean in this deck.
#   blue   PAL$retained,  every geom_segment that continues to a filled endpoint. theme.R's own
#          role for this color is "information retained / evidence that carries forward", and both
#          uses here match it, the branch that is not dropped and the confirmation segment.
#   orange PAL$discarded, two uses that share one meaning. The branch that ends in deadend_layer's
#          cross bar, and, in panel 3 only, the fading stub on the RETAINED path, which is that
#          dose's earlier evidence not surviving the boundary. So the entry is worded as "does not
#          carry forward" rather than "dose dropped", because the second use is not a dropped dose.
#   green  PAL$accent, node_layer(open = TRUE). Drawn ONCE, at SEAM_X + 0.02 in panel 3, which is
#          the first point AFTER the boundary on the path whose earlier evidence just faded out.
#          It therefore marks confirmation beginning with nothing carried in. It does NOT mark
#          selection. Panels 1 and 4 also select a single dose and carry no green circle, and
#          panel 4 differs from panel 3 only in that its evidence does carry forward.
#   dotted PAL$ink at linetype "22", seam_df, drawn in panels 3 and 4, the phase boundary.
# The black filled nodes are deliberately not keyed. They are the start and end points of a path
# and read as such without help, and a fifth entry costs the four real ones their legible size.
# =================================================================================================

KEY_TEXT_SIZE <- 5.8
KEY_MARK_W    <- 0.040
KEY_GAP       <- 0.013
KEY_COL1_X    <- 0.02
KEY_COL2_X    <- 0.53
KEY_ROW_HI    <- 0.70
KEY_ROW_LO    <- 0.26

key_entries <- data.frame(
  x     = c(KEY_COL1_X, KEY_COL2_X, KEY_COL1_X, KEY_COL2_X),
  y     = c(KEY_ROW_HI, KEY_ROW_HI, KEY_ROW_LO, KEY_ROW_LO),
  mark  = c("retained", "discarded", "restart", "boundary"),
  label = c("kept, carries forward",
            "dropped, does not carry forward",
            "confirmation starts with no earlier evidence",
            "phase boundary"),
  stringsAsFactors = FALSE
)

# OVERFLOW IS ASSERTED, NOT EYEBALLED. ggplot text `size` is in mm and converts to points by the
# .pt constant, and a mean lowercase advance runs near half the point size. That gives a per
# character width in inches, which divided by the key's own drawn width is a width in the key's
# 0..1 x units. The bound is deliberately crude and deliberately conservative.
KEY_PLOT_W_IN <- (0.98 - 0.02) * 13.333
key_char_w <- (KEY_TEXT_SIZE * .pt * 0.5 / 72) / KEY_PLOT_W_IN
key_entries$right <- key_entries$x + KEY_MARK_W + KEY_GAP +
  nchar(key_entries$label) * key_char_w
col1 <- key_entries$x == KEY_COL1_X
stopifnot("column one of the key must not run into column two" =
            all(key_entries$right[col1] < KEY_COL2_X),
          "column two of the key must not run off the canvas" =
            all(key_entries$right[!col1] < 1))

key_text_x <- key_entries$x + KEY_MARK_W + KEY_GAP
seg <- function(i) key_entries[i, ]

p_key <- ggplot() +
  coord_cartesian(xlim = c(0, 1), ylim = c(0, 1), expand = FALSE, clip = "off") +
  theme_void() +
  # Blue, retained. Same color, linewidth and alpha as the confirmation segments above.
  geom_segment(aes(x = seg(1)$x, xend = seg(1)$x + KEY_MARK_W, y = seg(1)$y, yend = seg(1)$y),
               color = PAL$retained, linewidth = 1.9, alpha = CONCEPT_ALPHA) +
  # Orange, discarded, drawn with deadend_layer's own cross bar so the entry shows the whole mark.
  geom_segment(aes(x = seg(2)$x, xend = seg(2)$x + KEY_MARK_W, y = seg(2)$y, yend = seg(2)$y),
               color = PAL$discarded, linewidth = 1.9, alpha = CONCEPT_ALPHA) +
  geom_segment(aes(x = seg(2)$x + KEY_MARK_W, xend = seg(2)$x + KEY_MARK_W,
                   y = seg(2)$y - 0.13, yend = seg(2)$y + 0.13),
               color = PAL$discarded, linewidth = 1.8, lineend = "butt") +
  # Green open circle, identical parameters to node_layer(open = TRUE).
  geom_point(aes(x = seg(3)$x + KEY_MARK_W / 2, y = seg(3)$y), shape = 21, size = 5.2,
             stroke = 1.6, fill = PAL$paper, color = PAL$accent) +
  # Dotted phase boundary, identical parameters to seam_df's segment.
  geom_segment(aes(x = seg(4)$x + KEY_MARK_W / 2, xend = seg(4)$x + KEY_MARK_W / 2,
                   y = seg(4)$y - 0.20, yend = seg(4)$y + 0.20),
               color = PAL$ink, linewidth = 1.0, linetype = "22") +
  annotate("text", x = key_text_x, y = key_entries$y, label = key_entries$label,
           hjust = 0, size = KEY_TEXT_SIZE, color = "#3A3A3A")

full <- full + cowplot::draw_plot(p_key, x = 0.02, y = 0.015, width = 0.96, height = 0.145)

# Captions, one per column, drawn ONCE at the composed level and confined to their own column's
# width via an explicit strwrap(), so they cannot bleed into a neighboring panel the way an
# in-ggplot annotate() with clip="off" did.
# The per-panel explanatory captions were removed, owner ruling 2026-08-27. The three-word
# headings carry the distinction and the spoken track explains the rest.

out <- save_figure(full, FIG_ID, width_in = 13.333, height_in = 7.5)
print(out)

rendered_strings <- c(
  title = "A phase boundary determines what information survives",
  panel_titles = paste(gsub("\n", " ", unname(ARCH_TITLE)), collapse = " | "),
  panel_notes = paste(
    "One dose moves forward, the other is dropped.",
    "Both doses continue into confirmation.",
    "The chosen dose's earlier evidence does not carry forward.",
    "The chosen dose's earlier evidence carries forward.",
    sep = " | "
  ),
  stage_labels = "selection | confirmation",
  # The key is drawn text, so it is checked as drawn text. Omitting it would have left the newest
  # strings on the figure as the only ones the jargon check could not fail on.
  key = paste(key_entries$label, collapse = " | ")
)
forbidden <- c("PCS", "\\btruth\\b", "\\bcell\\b", "frozen", "locked", "\\bpolic(y|ies)\\b",
               "select_exclude", "select_incorporate", "exp8")
hit <- FALSE
for (s in rendered_strings) {
  if (any(sapply(forbidden, function(pat) grepl(pat, s, ignore.case = TRUE)))) hit <- TRUE
}
stopifnot(!hit)
cat("[pres4a] jargon check PASSED.\n")
