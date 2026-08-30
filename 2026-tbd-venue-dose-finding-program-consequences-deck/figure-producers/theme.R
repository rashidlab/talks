# SHARED VISUAL SYSTEM for the ARPA-H statistics meeting figure set.
#
# Sourced by every script under scripts/figures/arpa_stats_meeting/. Central home for the
# color-blind-safe palette, the unified visual grammar (retained/discarded/comparator/status),
# typography, and the save_figure() helper that emits pdf, svg, and a >= 2400px png together.
#
# Read-only with respect to results/. This file draws nothing from result artifacts, only from
# design choices fixed once here so all six figures agree.

suppressPackageStartupMessages({
  library(ggplot2)
  library(grid)
})

ROOT <- rprojroot::find_root(rprojroot::has_file("CLAUDE.md"))
FIG_DIR <- file.path(ROOT, "figures", "arpa_stats_meeting")
if (!dir.exists(FIG_DIR)) dir.create(FIG_DIR, recursive = TRUE)

# ---------------------------------------------------------------------------------------------
# PALETTE. Okabe-Ito colorblind-safe qualitative set, restricted to the roles the brief defines.
# ---------------------------------------------------------------------------------------------

PAL <- list(
  retained    = "#0072B2",  # deep blue.    Information retained / evidence that carries forward.
  discarded   = "#D55E00",  # vermillion.   Information discarded / eliminated / abandoned.
  comparator  = "#8C8C8C",  # neutral gray. Reference or comparator material, not itself a finding.
  accent      = "#009E73",  # bluish green. Reserved for a single third state when one is needed
                             #               (e.g. "unresolved" / "open question"), never reused
                             #               for retained or discarded.
  ink         = "#1A1A1A",  # near-black text.
  paper       = "#FFFFFF",
  gridline    = "#E5E5E5",
  panel_bg    = "#FAFAFA"
)

# Inferential-status encoding. Distinguished by BOTH color-independent shape/linetype AND a text
# tag, per the brief's "do not use color alone" rule.
STATUS <- list(
  supported     = list(linetype = "solid",  alpha = 1.00, label = "Supported (prespecified comparison)"),
  descriptive   = list(linetype = "dashed", alpha = 0.85, label = "Descriptive"),
  conceptual    = list(linetype = "dotted", alpha = 0.70, label = "Conceptual illustration")
)

# SUPERSEDES an earlier "Application truth: monotone efficacy" wording. Owner ruling mid-build:
# audience-facing figures carry no internal analysis vocabulary ("truth", "application track").
APPLICATION_BADGE_TEXT <- "One clinical scenario: efficacy increases with dose"

# ---------------------------------------------------------------------------------------------
# TYPOGRAPHY. Large sizes for conference-room legibility. No showtext/sysfonts installed, so we
# stay on system sans-serif rather than depend on an unavailable font backend.
# ---------------------------------------------------------------------------------------------

BASE_FAMILY <- "sans"

theme_arpa <- function(base_size = 20) {
  theme_minimal(base_size = base_size, base_family = BASE_FAMILY) +
    theme(
      plot.title = element_text(size = rel(1.35), face = "bold", color = PAL$ink,
                                 margin = margin(b = 6), hjust = 0),
      plot.subtitle = element_text(size = rel(0.95), color = "#3A3A3A",
                                    margin = margin(b = 12), hjust = 0),
      plot.caption = element_text(size = rel(0.62), color = "#6A6A6A", hjust = 0,
                                   margin = margin(t = 10)),
      axis.title = element_text(size = rel(0.9), color = PAL$ink),
      axis.text = element_text(size = rel(0.85), color = PAL$ink),
      panel.grid.major = element_line(color = PAL$gridline, linewidth = 0.4),
      panel.grid.minor = element_blank(),
      legend.position = "none",   # direct labels preferred; panels that must keep a legend override this
      plot.background = element_rect(fill = PAL$paper, color = NA),
      panel.background = element_rect(fill = PAL$paper, color = NA),
      plot.margin = margin(16, 20, 12, 16)
    )
}

# ---------------------------------------------------------------------------------------------
# EXPORT. 16:9-friendly. Emits .pdf, .svg, and a >= 2400px-wide .png for every figure.
# ---------------------------------------------------------------------------------------------

save_figure <- function(plot, id, width_in = 13.333, height_in = 7.5, dpi = 300) {
  stopifnot(width_in * dpi >= 2400)
  base <- file.path(FIG_DIR, id)
  ggsave(paste0(base, ".pdf"), plot = plot, width = width_in, height = height_in,
         units = "in", device = cairo_pdf, bg = "white")
  ggsave(paste0(base, ".svg"), plot = plot, width = width_in, height = height_in,
         units = "in", device = svglite::svglite, bg = "white")
  ggsave(paste0(base, ".png"), plot = plot, width = width_in, height = height_in,
         units = "in", dpi = dpi, bg = "white")
  png_w <- round(width_in * dpi)
  message(sprintf("[save_figure] %s: pdf/svg/png written, png width = %d px (>= 2400 required)",
                   id, png_w))
  invisible(list(pdf = paste0(base, ".pdf"), svg = paste0(base, ".svg"),
                  png = paste0(base, ".png"), png_width_px = png_w))
}

# Small helper other scripts use to print the required pre-plot verification banner.
verify_banner <- function(figure_id, source_artifact, producer, fields, expected, observed) {
  cat("=====================================================================\n")
  cat("FIGURE", figure_id, "verification banner\n")
  cat("  source artifact :", source_artifact, "\n")
  cat("  producer script  :", producer, "\n")
  cat("  fields used      :", paste(fields, collapse = ", "), "\n")
  cat("  expected         :", expected, "\n")
  cat("  observed         :", observed, "\n")
  cat("=====================================================================\n")
}
