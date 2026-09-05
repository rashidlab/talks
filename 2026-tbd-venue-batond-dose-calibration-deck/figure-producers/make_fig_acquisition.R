# make_fig_acquisition.R
# "Where should the next expensive simulation be spent?" for the generalist
# BATON-D deck. The file name is historical. The audience-facing vocabulary
# "acquisition function" is BANNED on slides and appears nowhere in the artwork.
#
# SCHEMATIC ILLUSTRATION. Nothing here is simulation output. The boundary, the
# uncertainty ribbon, the best-predicted sub-region and every plotted evaluation
# are hand-drawn constructs whose only job is to teach the idea that the search
# does NOT sample at the design it currently predicts is best. It samples where
# an expensive evaluation is most informative about improving the best design
# that also meets every requirement, meaning the uncertain edge next to the
# region that looks best.
#
# Generalist revision, 2026-09-05, against the owner review of slide 18.
#   - Three regions only, "unlikely to work", "promising", "best predicted".
#   - The three competing terms of the previous version are gone. "probably
#     feasible" becomes "promising", and "predicted best" and "fewest patients
#     predicted" are collapsed into the single region label "best predicted",
#     which is what the low-objective sub-region always was. The separate
#     diamond marker for the predicted-best point is removed with them.
#   - One large callout on the next simulation carries the two-part reason.
#   - Past evaluations are drawn with ONE glyph, labelled once. The earlier
#     cross-versus-dot pair asked the audience to decode a convention that was
#     never written down anywhere in the artwork.
#
# Brand palette ONLY: navy #13294B, carolina #4B9CD3, carolina-deep #2E6A9F,
# graphite #5B6670, fog #F4F6F8, mist #E6EAEF, accent orange #E07C24.

library(ggplot2)

navy     <- "#13294B"
carolina <- "#4B9CD3"
cdeep    <- "#2E6A9F"
graphite <- "#5B6670"
fog      <- "#F4F6F8"
mist     <- "#E6EAEF"
accent   <- "#E07C24"

xlim <- c(0, 14)
ylim <- c(0, 8.6)        # the map itself
ystrip <- -2.30          # the callout sits below the map, in white space

# ---- boundary between "unlikely to work" and "promising" --------------------
# unlikely to the LEFT of xb(y), promising to the RIGHT.
xb <- function(y) 5.0 + 1.35 * sin((y - 4) / 2.2)

yy <- seq(ylim[1], ylim[2], length.out = 400)
bx <- xb(yy)
band <- 0.80  # half-width of the "not sure" ribbon

bound_df <- data.frame(x = bx, y = yy)

unlikely_poly <- data.frame(
  x = c(bx, xlim[1], xlim[1]),
  y = c(yy, ylim[2], ylim[1])
)
promising_poly <- data.frame(
  x = c(bx, xlim[2], xlim[2]),
  y = c(yy, ylim[2], ylim[1])
)

band_df <- data.frame(y = yy, xmin = bx - band, xmax = bx + band)

# ---- best-predicted sub-region, inside the promising set --------------------
th <- seq(0, 2 * pi, length.out = 240)
ell <- function(cx, cy, a, b, rot = 0) {
  x0 <- a * cos(th); y0 <- b * sin(th)
  data.frame(x = cx + x0 * cos(rot) - y0 * sin(rot),
             y = cy + x0 * sin(rot) + y0 * cos(rot))
}
best_pred <- ell(8.55, 4.45, 2.85, 1.95, rot = 0.16)

# ---- light hatching so the pale ribbon stays visible on a projector ---------
ht <- seq(ylim[1] - 1.0, ylim[2] + 0.2, by = 0.40)
hatch <- data.frame(
  y    = ht,
  yend = ht + 0.80,
  x    = xb(ht) - band,
  xend = xb(ht + 0.80) + band
)
hatch <- hatch[hatch$yend > ylim[1] & hatch$y < ylim[2], ]
hatch$y    <- pmax(hatch$y, ylim[1])
hatch$yend <- pmin(hatch$yend, ylim[2])

# ---- designs already simulated, ONE glyph, both sides of the boundary -------
past <- data.frame(
  x = c(1.30, 3.70, 3.55, 2.10, 7.20, 9.10, 11.80, 11.40, 12.70, 8.20),
  y = c(4.90, 7.15, 5.35, 2.90, 1.40, 7.40,  5.90,  2.00,  3.60,  6.90)
)
next_pt <- data.frame(x = xb(4.95), y = 4.95)

# ---- panel ------------------------------------------------------------------
p <- ggplot() +
  # regions
  geom_polygon(data = unlikely_poly, aes(x, y), fill = mist, colour = NA) +
  geom_polygon(data = promising_poly, aes(x, y), fill = carolina,
               alpha = 0.17, colour = NA) +
  geom_polygon(data = best_pred, aes(x, y), fill = cdeep, alpha = 0.30, colour = NA) +
  geom_path(data = best_pred, aes(x, y), colour = cdeep, linewidth = 0.45, alpha = 0.65) +
  # the uncertain edge between them
  geom_ribbon(data = band_df, aes(y = y, xmin = xmin, xmax = xmax),
              fill = fog, alpha = 0.80) +
  geom_segment(data = hatch, aes(x = x, xend = xend, y = y, yend = yend),
               colour = graphite, linewidth = 0.28, alpha = 0.26) +
  geom_path(data = bound_df, aes(x, y), colour = graphite,
            linewidth = 0.9, linetype = "22") +
  # a frame around the map only, so the callout strip below stays white
  annotate("rect", xmin = xlim[1], xmax = xlim[2], ymin = ylim[1], ymax = ylim[2],
           fill = NA, colour = mist, linewidth = 0.6) +
  # designs already simulated
  geom_point(data = past, aes(x, y), shape = 21, fill = graphite,
             colour = "white", size = 3.4, stroke = 0.7, alpha = 0.85) +
  annotate("segment", x = 7.62, y = 0.88, xend = 7.28, yend = 1.26,
           linewidth = 0.5, colour = graphite) +
  annotate("text", x = 7.70, y = 0.78, hjust = 0, label = "designs we already simulated",
           colour = graphite, size = 5.0) +
  # the next simulation
  geom_point(data = next_pt, aes(x, y), shape = 21, fill = NA,
             colour = accent, size = 11.0, stroke = 1.1) +
  geom_point(data = next_pt, aes(x, y), shape = 21, fill = accent,
             colour = "white", size = 5.2, stroke = 0.9) +
  annotate("curve", x = 3.30, y = -1.05, xend = next_pt$x - 0.62, yend = next_pt$y - 0.70,
           curvature = -0.26, linewidth = 0.9, colour = accent,
           arrow = arrow(length = unit(0.22, "cm"), type = "closed")) +
  # the three regions
  annotate("text", x = 2.05, y = 6.45, label = "unlikely\nto work",
           colour = graphite, size = 7.4, fontface = "bold", lineheight = 0.95) +
  annotate("text", x = 11.85, y = 7.55, label = "promising",
           colour = cdeep, size = 7.4, fontface = "bold") +
  annotate("text", x = 8.55, y = 4.45, label = "best\npredicted",
           colour = navy, size = 7.4, fontface = "bold", lineheight = 0.95) +
  # what the ribbon along the boundary means
  annotate("curve", x = 4.85, y = 7.95, xend = 6.22, yend = 7.42,
           curvature = -0.24, linewidth = 0.5, colour = graphite,
           arrow = arrow(length = unit(0.14, "cm"), type = "closed")) +
  annotate("text", x = 4.68, y = 8.02, hjust = 1, label = "not sure which side\nof this line",
           colour = graphite, size = 5.0, fontface = "bold", lineheight = 0.95) +
  # the one callout the audience should leave with
  annotate("text", x = 6.95, y = ystrip + 0.75, hjust = 0.5, size = 6.6,
           label = "Try here. It could beat our current best,",
           colour = navy, fontface = "bold") +
  annotate("text", x = 6.95, y = ystrip - 0.15, hjust = 0.5, size = 6.6,
           label = "and it might meet the requirements.",
           colour = navy, fontface = "bold") +
  annotate("text", x = 14.0, y = ystrip - 1.55, hjust = 1, label = "Schematic illustration",
           colour = graphite, size = 4.3, fontface = "italic") +
  scale_x_continuous(limits = xlim, expand = c(0, 0)) +
  coord_cartesian(ylim = c(ystrip - 1.9, ylim[2] + 0.14), expand = FALSE, clip = "off") +
  labs(x = "One design setting", y = "Another design setting") +
  theme_minimal(base_size = 12) +
  theme(
    axis.title  = element_text(size = 14, face = "bold", colour = navy),
    axis.text   = element_blank(),
    panel.grid  = element_blank(),
    legend.position = "none",
    plot.margin = margin(6, 6, 4, 4)
  )

if (!dir.exists("images")) dir.create("images", showWarnings = FALSE)
ggsave("images/fig_acquisition_regions.png", p,
       width = 8.4, height = 4.9, dpi = 300, bg = "white")
cat("written: images/fig_acquisition_regions.png\n")
