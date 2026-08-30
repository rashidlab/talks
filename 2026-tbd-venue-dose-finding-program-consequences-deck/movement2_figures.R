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

rp <- function(...) file.path(Sys.getenv("BATOND_PAPER_REPO", "."), ...)
source(rp("R", "metrics.R"))

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
  labs(x = NULL, y = "Cells",
       title = "Search nominates. Verification decides.",
       subtitle = "No nominated cell verified infeasible on any constraint") +
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
  labs(x = NULL, y = "Nominated cells",
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
sdf$label <- ifelse(sdf$study %in% names(slab), slab[sdf$study], sdf$study)
sdf$rest <- sdf$total - sdf$feasible
sdf <- sdf[order(-sdf$feasible / sdf$total), ]
sdf$label <- factor(sdf$label, levels = rev(sdf$label))

long <- rbind(
  data.frame(label = sdf$label, part = "Verified feasible", n = sdf$feasible),
  data.frame(label = sdf$label, part = "Not established",   n = sdf$rest))
long$part <- factor(long$part, levels = c("Verified feasible", "Not established"))

p_struct <- ggplot(long, aes(label, n, fill = part)) +
  geom_col(width = 0.58) +
  scale_fill_manual(values = c("Verified feasible" = STATE[["feasible"]],
                               "Not established" = MIST)) +
  geom_text(data = long[long$part == "Verified feasible" & long$n > 0, ],
            aes(label = n), position = position_stack(vjust = 0.5),
            colour = "white", fontface = "bold", size = 5) +
  geom_text(data = sdf, aes(x = label, y = total, label = paste0("of ", total)),
            inherit.aes = FALSE, hjust = -0.18, colour = GRAPH, size = 4.2) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.14))) +
  coord_flip() +
  labs(x = NULL, y = "Cells",
       title = "Feasibility is not uniform, and the pattern is informative",
       subtitle = paste("Same design-space dimension and the same coordinate ranges.",
                        "They differ in the truth convention and the scenarios declared")) +
  base_thm
save_slide(p_struct, "m2_feasibility_structure", h = 4.6)

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
  sprintf('      <span class="verdict-detail">%s claims, familywise %s</span>', DEL$m, DEL$familywise),
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
