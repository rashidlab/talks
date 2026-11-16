# make_fig_tradeoff_040.R
# Trade-off planes for the BATON 0.4.0 package, replacing fig_R1_singlearm_v3.png (slide 29)
# and fig_R2_betweenarm.png (backup B8), which plotted pre-revision designs.
# Source: ~/Downloads/atbo-longleaf/results/retune_xphil/final_summary_designs.csv, the file
# behind Tables 3 and 4 and Figure 1 of manuscript/jasa_manuscript_reduced.pdf (rendered
# 2026-11-13). Rows R01 to R03 (Scenario A, TNBC single-arm) and R23 to R25 (Scenario B,
# between-arm). Values read from the file and rounded as the manuscript rounds them.
# Plain-word axes, on-figure labels, no legend. The dashed line is a visual guide, not a
# characterized frontier (manuscript Figure 1 caption).
# Outputs: images/fig_tradeoff_tnbc_040.png, images/fig_tradeoff_betweenarm_040.png

library(ggplot2)
src <- path.expand("~/Downloads/atbo-longleaf/results/retune_xphil/final_summary_designs.csv")
d <- read.csv(src, stringsAsFactors = FALSE)
navy <- "#13294B"; car <- "#4B9CD3"; graph <- "#5B6670"; mist <- "#E6EAEF"

plane <- function(ids, names, nudge, xlim, ylim, out, w = 7.4, h = 4.6, values = TRUE, highlight = NULL,
                  y_label = "Most patients the trial can enroll") {
  x <- d[match(ids, d$design), ]
  stopifnot(nrow(x) == 3, all(x$certified))
  x$name <- names
  x$fill <- if (is.null(highlight)) rep(car, nrow(x)) else ifelse(x$name == highlight, "#E07C24", car)
  x$lab <- if (values) sprintf("%s\n%d max, %.1f expected", x$name, x$N_max, x$E0N) else x$name
  x$lx <- x$E0N + nudge[, 1]; x$ly <- x$N_max + nudge[, 2]
  p <- ggplot(x, aes(E0N, N_max)) +
    geom_path(linetype = "dashed", colour = graph, linewidth = 0.6) +
    geom_point(aes(fill = fill), size = 6, shape = 21, colour = navy, stroke = 1.2) +
    scale_fill_identity() +
    geom_text(aes(x = lx, y = ly, label = lab), size = 7, colour = navy, family = "Archivo",
              lineheight = 0.95, hjust = 0) +
    scale_x_continuous(limits = xlim) + scale_y_continuous(limits = ylim) +
    labs(x = "Expected patients if the treatment is ineffective",
         y = y_label) +
    theme_minimal(base_size = 21, base_family = "Archivo") +
    theme(panel.grid.minor = element_blank(), panel.grid.major = element_line(colour = mist),
          axis.title = element_text(colour = navy, face = "bold"),
          axis.text = element_text(colour = graph), plot.margin = margin(8, 14, 8, 8))
  ggsave(out, p, width = w, height = h, dpi = 250, bg = "white", device = ragg::agg_png)
  print(x[, c("design", "name", "N_max", "E0N", "power", "type1")])
}

plane(c("R01", "R02", "R03"), c("Optimal", "Admissible", "Minimax"),
      nudge = rbind(c(0.6, 0.15), c(0.6, 0.6), c(-2.2, -0.75)),
      xlim = c(9, 24), ylim = c(27.5, 34), out = "images/fig_tradeoff_tnbc_040.png",
      values = FALSE, highlight = "Admissible", y_label = "Max sample size")  # slide 27 lists the values beside the figure
plane(c("R23", "R24", "R25"), c("Optimal", "Admissible", "Minimax"),
      nudge = rbind(c(1, 0.2), c(1, 2.8), c(-5.4, -2.6)),
      xlim = c(56, 76), ylim = c(82, 106), out = "images/fig_tradeoff_betweenarm_040.png",
      y_label = "Max sample size")
