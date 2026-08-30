# Movement II figures for the conference deck, plus the two-panel architecture forest.
#
# EVERY QUANTITY IS READ LIVE, per docs/TALK_DESIGN-2026-08-30.md Section 9. Nothing here types a
# result. A figure that hardcodes a count is how a slide keeps a number the paper has since
# changed, and the fix is structural rather than a promise to remember.
#
# THE THREE-STATE DISPLAY MUST NOT COLLAPSE TO TWO. Unresolved is not almost feasible and it is
# not failure, it is a statement about what the verification evidence licenses. Any palette or
# legend that renders it as a shade of one of the other two destroys the distinction the movement
# exists to make, so the assertion below fails the build rather than the eye.

suppressPackageStartupMessages({ library(ggplot2); library(grid) })

# THE REPOSITORY ROOT IS RESOLVED BEFORE ANYTHING IS READ, and every path below hangs off it.
# The previous default was ".", which made the reader, the artifacts and the output directory all
# depend on the launch directory, and depend on it silently: run from anywhere but the repository
# root and `source` failed, while run from a sibling checkout it would have read the wrong
# repository's results. `BATOND_PAPER_REPO` is honoured because it is the statement that this IS
# the paper repository, and the fallback walks up for `globals.yml` rather than assuming the
# working directory, matching what `R/globals.R` and `R/metrics.R` already do.
rp <- local({
  env <- Sys.getenv("BATOND_PAPER_REPO", "")
  root <- if (nzchar(trimws(env))) path.expand(trimws(env)) else {
    d <- normalizePath(getwd(), winslash = "/", mustWork = FALSE)
    repeat {
      if (file.exists(file.path(d, "globals.yml"))) break
      p <- dirname(d)
      if (identical(p, d)) stop("movement2_figures: no `globals.yml` at or above `", getwd(),
                                "`. Set BATOND_PAPER_REPO or run from inside the repository.",
                                call. = FALSE)
      d <- p
    }
    d
  }
  if (!dir.exists(root)) stop("movement2_figures: `", root, "` is not a directory.", call. = FALSE)
  root <- normalizePath(root, winslash = "/", mustWork = FALSE)
  function(...) file.path(root, ...)
})
source(rp("R", "metrics.R"))

# ONE ROOT, ASSERTED. This script resolved a root in order to find the reader, and the reader
# resolves one of its own to find the artifacts. If those two ever disagree the figure would be
# drawn from one repository and labelled with another's provenance, which is the two-authorities
# defect in its most expensive form. It costs one comparison to make that impossible.
stopifnot("the script's root and the metrics reader's root must be the same repository" =
            identical(normalizePath(rp(), winslash = "/", mustWork = FALSE),
                      normalizePath(batond_root(), winslash = "/", mustWork = FALSE)))

OUT <- rp("figures", "conference_deck")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

M   <- metrics()
INF <- M$shared$inference
DEL <- M$shared$deliverable

NAVY <- "#13294B"; CAR <- "#4B9CD3"; CARD <- "#2E6A9F"
GRAPH <- "#5B6670"; MIST <- "#E6EAEF"; AMBER <- "#B8860B"

# THE THREE STATES GET THREE HUES, NOT A GRADIENT. Asserted, not assumed.
STATE <- c(feasible = CARD, unresolved = AMBER, infeasible = "#8B1A1A")
stopifnot("the three verdict states must be visually distinct" =
            length(unique(STATE)) == 3L)

base_thm <- theme_minimal(base_size = 11) +
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_line(colour = "#EDF0F2"),
        axis.title = element_text(colour = NAVY, face = "bold", size = 10),
        axis.text  = element_text(colour = GRAPH, size = 9),
        plot.title = element_text(colour = NAVY, face = "bold", size = 13),
        plot.subtitle = element_text(colour = GRAPH, size = 10),
        legend.position = "none",
        plot.margin = margin(10, 14, 8, 10))

save_slide <- function(p, name, w = 10.5, h = 5.6) {
  ggsave(file.path(OUT, paste0(name, ".png")), p, width = w, height = h,
         dpi = 200, bg = "white")
  message("  wrote ", name, ".png")
}

# ---------------------------------------------------------------- the funnel
# FOUR STAGES, AND THE SPLIT IS THE POINT. Search selects on point estimates and verification
# decides on an interval, so the drop from nominated to established is the procedure working.
cnt   <- INF$counts
n_tot <- as.integer(cnt$n_cells_total)
n_loc <- as.integer(cnt$n_locked_cells)
cp    <- cnt$corrected_pipeline
stopifnot(cp$infeasible == 0L,
          cp$feasible + cp$unresolved == n_loc)

fun <- data.frame(
  stage = factor(c("Calibration problems", "Nominated by search",
                   "Verified feasible", "Unresolved"),
                 levels = c("Calibration problems", "Nominated by search",
                            "Verified feasible", "Unresolved")),
  n     = c(n_tot, n_loc, as.integer(cp$feasible), as.integer(cp$unresolved)),
  fill  = c(GRAPH, CAR, STATE[["feasible"]], STATE[["unresolved"]]),
  stringsAsFactors = FALSE)

p_funnel <- ggplot(fun, aes(stage, n)) +
  geom_col(fill = fun$fill, width = 0.62) +
  geom_text(aes(label = n), vjust = -0.55, colour = NAVY, fontface = "bold", size = 5.6) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.18))) +
  labs(x = NULL, y = "Calibration problems",
       title = "Search nominates. Verification decides.",
       subtitle = "No nominated calibration problem verified infeasible on any constraint") +
  base_thm
save_slide(p_funnel, "m2_funnel")

# ------------------------------------------------- the three-state verdict bar
con <- INF$con_counts_corrected_pipeline
cdf <- do.call(rbind, lapply(names(con), function(k) {
  z <- con[[k]]
  data.frame(constraint = k,
             state = factor(c("feasible", "unresolved", "infeasible"),
                            levels = c("feasible", "unresolved", "infeasible")),
             n = as.integer(c(z$feasible, z$unresolved, z$infeasible)),
             stringsAsFactors = FALSE)
}))
lab <- c(stop0 = "Safe stopping", expose = "Overdose exposure", select = "Correct selection")
cdf$constraint <- factor(lab[cdf$constraint], levels = unname(lab))

p_state <- ggplot(cdf, aes(constraint, n, fill = state)) +
  geom_col(width = 0.6) +
  scale_fill_manual(values = STATE) +
  geom_text(data = cdf[cdf$n > 0, ], aes(label = n),
            position = position_stack(vjust = 0.5),
            colour = "white", fontface = "bold", size = 5) +
  # THE STATES ARE NAMED ON THE MARKS, NOT IN A LEGEND. Strip the title and a viewer still has
  # to be able to say which colour is which, or the graphic asserts a two-state reading the
  # analysis does not support. The callout moves to the subtitle, where it cannot collide with
  # a bar whose height is data-dependent.
  annotate("text", x = 3.34, y = con$select$unresolved / 2,
           label = "unresolved", colour = AMBER, fontface = "bold", size = 4.2, hjust = 0) +
  annotate("text", x = 3.34, y = con$select$unresolved + con$select$feasible / 2,
           label = "verified\nfeasible", colour = CARD, fontface = "bold", size = 4.2, hjust = 0) +
  coord_cartesian(xlim = c(0.5, 3.9), clip = "off") +
  labs(x = NULL, y = "Nominated calibration problems",
       title = "Every verdict is three-valued",
       subtitle = paste("Nothing was refuted. Unresolved is not almost feasible and it is not",
                        "failure, it is what the verification evidence licenses")) +
  base_thm
save_slide(p_state, "m2_three_state")

# ------------------------------------------------- feasibility has structure
# DENOMINATORS ARE TOTAL CELLS PER STUDY, derived rather than typed. Falls over loudly if the
# rows cannot supply them, because a share against the wrong denominator is worse than none.
W <- artifact("weighted_objective_study")
stopifnot("weighted_objective_study must carry rows" = !is.null(W$rows))
# ROWS IS A LIST OF CELL RECORDS, NOT A DATA FRAME, so the study field is extracted per element.
# A first version indexed it as a column, got NULL, and the denominator assertion below caught it
# rather than letting every share be computed against nothing.
tot <- table(vapply(W$rows, function(z) as.character(z$study), character(1)))
fbs <- INF$feasible_by_study_corrected_pipeline
stopifnot("every study with a feasible count needs a denominator" =
            all(names(fbs) %in% names(tot)))

sdf <- data.frame(study = names(fbs),
                  feasible = as.integer(unlist(fbs)),
                  total = as.integer(tot[names(fbs)]),
                  stringsAsFactors = FALSE)
slab <- c(simulation = "Prespecified simulation", application = "Application",
          boin12 = "Published benchmark")
# PROVENANCE SUBTITLES ARE QUOTED, NOT WRITTEN HERE. Each string is the paper's own clause
# describing what distinguishes the study, manuscript/paper_skeleton.qmd lines 2177-2182
# (identically in the rendered manuscript/paper_skeleton.tex lines 1565-1568). A cancer
# researcher seeing the row label once needs the paper's own account of the study, not an
# improvised gloss that could drift from what the paper says.
sprov <- c(
  simulation  = "scenarios drawn from the published two-stage utility evaluation",
  application = "scenarios built on the motivating trial's own thresholds",
  boin12      = "scenarios drawn from the rank-based utility design's published evaluation")
sdf$label    <- ifelse(sdf$study %in% names(slab), slab[sdf$study], sdf$study)
sdf$subtitle <- ifelse(sdf$study %in% names(sprov), sprov[sdf$study], "")
sdf$rest <- sdf$total - sdf$feasible
sdf <- sdf[order(-sdf$feasible / sdf$total), ]
# ROW LABEL IS TWO LINES, the study name on the first and the paper's provenance clause
# underneath it on the second. Plain "\n" rather than a richtext element, because ggtext's
# element_markdown silently failed to parse when merged with theme_minimal() under the
# installed ggplot2 (4.0.3), rendering the raw markup instead of formatted text. Verified by
# direct reproduction before this fallback was chosen, not assumed.
sdf$rowlabel <- paste0(sdf$label, "\n", sdf$subtitle)
sdf$rowlabel <- factor(sdf$rowlabel, levels = rev(sdf$rowlabel))
# THE INTERIOR LABEL IS THE FEASIBLE FRACTION, computed from the same feasible/total this
# script already derives, never typed. Guarded against division by a zero-row study so an
# empty denominator produces NA rather than a silently wrong percentage.
stopifnot("every study needs a positive denominator" = all(sdf$total > 0))
# BOTH DENOMINATORS ON THE MARK. The count is what the campaign census reports and the percent
# is what the eye compares across rows of different size, so the bar carries both rather than
# forcing the reader to divide.
sdf$bar_label <- sprintf("%d of %d, %.0f%%", sdf$feasible, sdf$total,
                         100 * sdf$feasible / sdf$total)

long <- rbind(
  data.frame(label = sdf$rowlabel, part = "Verified feasible", n = sdf$feasible),
  data.frame(label = sdf$rowlabel, part = "Not established",   n = sdf$rest))
long$part <- factor(long$part, levels = c("Verified feasible", "Not established"))

p_struct <- ggplot(long, aes(label, n, fill = part)) +
  geom_col(width = 0.58) +
  scale_fill_manual(values = c("Verified feasible" = STATE[["feasible"]],
                               "Not established" = MIST)) +
  # THE FRACTION SITS ON THE BLUE PORTION ITSELF, not beside the bar, because the feasible
  # share is the number the slide exists to show. White space inside the blue segment is
  # ample for both studies where any cell is feasible at all.
  geom_text(data = sdf[sdf$feasible > 0, ],
            aes(x = rowlabel, y = rest + feasible / 2, label = bar_label),
            inherit.aes = FALSE, colour = "white", fontface = "bold", size = 5.2) +
  # THE ZERO ROW GETS ITS COUNT OUTSIDE THE BAR, because it has no blue segment to carry one and
  # a row silently showing nothing is the study whose result the slide is most interested in.
  # Rows with a blue segment already state both denominators on the mark, so no exterior label.
  geom_text(data = sdf[sdf$feasible == 0, ],
            aes(x = rowlabel, y = total, label = bar_label),
            inherit.aes = FALSE, hjust = -0.12, colour = GRAPH, fontface = "bold", size = 4.6) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.14))) +
  coord_flip() +
  labs(x = NULL, y = "Calibration problems",
       title = "Feasibility is not uniform, and the pattern is informative",
       subtitle = paste("Same design-space dimension and the same coordinate ranges.",
                        "They differ in the truth convention and the scenarios declared")) +
  base_thm +
  # ROW LABELS ENLARGED FOR ROOM DISTANCE. Study name and provenance clause share one text
  # element (two lines via "\n"), so both scale together rather than the subtitle vanishing
  # at slide-projection size.
  theme(axis.text.y = element_text(colour = NAVY, size = 12.5, lineheight = 0.95, hjust = 1),
        # THE WIDE TWO-LINE LABELS SHRINK THE PANEL, and the default plot.title.position
        # ("panel") anchors the title to the panel's left edge, which then pushed the title
        # past the right edge of the canvas. Anchoring to "plot" ties the title to the whole
        # image's left margin instead, independent of how much room the row labels take.
        plot.title.position = "plot")
save_slide(p_struct, "m2_feasibility_structure", h = 5.0, w = 13)

# ------------------------------------------------------- the deliverable card
# A PROTOCOL EXCERPT, NOT A RESULTS TABLE. Every coordinate is an output of the calibration.
# TUNING IS A TWO-COLUMN NAME/VALUE FRAME, NOT A NAMED VECTOR. A first version mapped over
# names(tun) and got the COLUMN names, rendering the single line "name = target, value = 0.2"
# on a slide whose entire claim is that every coordinate is a calibration output. It looked like
# a formatted line rather than an error, which is why it survived to a rendered image.
tun <- DEL$tuning
stopifnot("tuning must be a name/value frame" =
            is.data.frame(tun), all(c("name", "value") %in% names(tun)), nrow(tun) > 1L)
N_TUNE <- nrow(tun)

# THIS WRITES THE HTML THE QMD `{{< include >}}`S, NOT A RASTER IMAGE. The `.protocol-card`
# markup already lives in content-slides.css and reads well on the slide, so the fix for the
# literal-string version is to keep that markup and generate its values here, never to replace
# the card with a picture of one. Every scalar is checked for presence before any HTML is
# written, because sprintf("%s", NULL) silently returns character(0) rather than erroring, and a
# card built from a silently-dropped field is exactly the blank-placeholder failure mode this
# repo forbids (see the figure script that silently substituted simulated data, CLAUDE.md).
required <- c("family_label", "n_max", "cohort_size", "start_dose", "n_dose_cap",
              "verdict", "familywise", "m")
missing_fields <- required[!vapply(required, function(f) {
  v <- DEL[[f]]
  length(v) == 1L && !is.na(v) && !identical(v, "")
}, logical(1))]
if (length(missing_fields) > 0L) {
  stop("deliverable card: shared$deliverable is missing or has a malformed field: ",
       paste(missing_fields, collapse = ", "),
       ". Refusing to write a card that would render blank for these values.", call. = FALSE)
}

# Minimal HTML escaping. The fields are calibration output (numbers, short labels), not free
# text, but a card is not the place to assume that stays true forever.
html_esc <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;",  x, fixed = TRUE)
  gsub(">", "&gt;", x, fixed = TRUE)
}

# THREE VERDICT STATES, SAME PALETTE AS THE REST OF THE DECK'S CSS (.state-card in
# content-slides.css), not the ggplot STATE constants above, which are a separate palette for a
# separate medium. Asserted rather than assumed, same reasoning as the STATE check at the top of
# this file: an unrecognised verdict string must fail the build, not render an uncoloured badge.
verdict_class <- as.character(DEL$verdict)
stopifnot("verdict must be one of the three states the deck's badge CSS defines" =
            verdict_class %in% c("feasible", "unresolved", "infeasible"))
verdict_label <- sprintf("Verified %s", verdict_class)

card_html <- c(
  '<div class="protocol-card">',
  sprintf('  <div class="row"><span class="label">Design family</span><span class="value">%s</span></div>',
          html_esc(DEL$family_label)),
  sprintf('  <div class="row"><span class="label">Maximum sample size</span><span class="value">%s patients, cohorts of %s</span></div>',
          DEL$n_max, DEL$cohort_size),
  sprintf('  <div class="row"><span class="label">Starting dose</span><span class="value">Level %s</span></div>',
          DEL$start_dose),
  sprintf('  <div class="row"><span class="label">Per-dose accrual cap</span><span class="value">%s patients</span></div>',
          DEL$n_dose_cap),
  '  <div class="row"><span class="label">Verification verdict</span>',
  '    <span class="value verdict-cell">',
  sprintf('      <span class="verdict-badge %s">%s</span>', verdict_class, html_esc(verdict_label)),
  # PLAIN ENGLISH ON THE CARD, EXACT TERM IN THE NOTES. "familywise 0.05" is precise and
  # unreadable in one pass to a scientist who is not a statistician, and this card exists to show
  # a trial team what it receives.
  sprintf('      <span class="verdict-detail">%s%% error control across the %s requirements checked together</span>',
          format(100 * as.numeric(DEL$familywise), trim = TRUE), DEL$m),
  '    </span>',
  '  </div>',
  sprintf('  <div class="row"><span class="label">Tuning vector</span><span class="value">%d calibrated settings supplied with the protocol</span></div>',
          N_TUNE),
  '</div>')

card_path <- rp("figures", "conference_deck", "m2_deliverable_card.html")
writeLines(card_html, card_path)
message("  wrote m2_deliverable_card.html (read live from shared$deliverable, verdict = ",
        verdict_class, ", m = ", DEL$m, ", familywise = ", DEL$familywise, ", tuning rows = ",
        N_TUNE, ")")

message("movement II figures complete, written to ", OUT)
