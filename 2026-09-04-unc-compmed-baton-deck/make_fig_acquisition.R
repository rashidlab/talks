# make_fig_acquisition.R
# "Where should the next expensive simulation be spent?" -- acquisition-function
# intuition for the compmed BATON deck.
#
# SCHEMATIC ILLUSTRATION. Nothing here is simulation output. The feasibility
# boundary, the uncertainty band, the low-enrollment sub-region and every
# plotted evaluation are hand-drawn constructs whose only job is to teach the
# idea that a constrained-BO acquisition rule does NOT sample at the predicted
# best design. It samples where an expensive evaluation is most informative
# about improving the FEASIBLE optimum: on the uncertain edge of the feasible
# set, next to the region that looks cheapest.
#
# Visual grammar is shared with make_fig_search_intuition.R so the three
# design-space panels read as one system: same axis labels ("Efficacy
# threshold" / "Futility threshold"), blank axis text, bold navy axis titles,
# theme_minimal base, no legends, on-figure annotation only.
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
ylim <- c(0, 8.6)

# ---- feasibility boundary: gently wavy, near-vertical curve -----------------
# infeasible to the LEFT of xb(y), feasible to the RIGHT.
xb <- function(y) 5.0 + 1.35 * sin((y - 4) / 2.2)

yy <- seq(ylim[1], ylim[2], length.out = 400)
bx <- xb(yy)
band <- 0.80  # half-width of the "uncertain" ribbon

bound_df <- data.frame(x = bx, y = yy)

infeasible_poly <- data.frame(
  x = c(bx, xlim[1], xlim[1]),
  y = c(yy, ylim[2], ylim[1])
)
feasible_poly <- data.frame(
  x = c(bx, xlim[2], xlim[2]),
  y = c(yy, ylim[2], ylim[1])
)

band_df <- data.frame(y = yy, xmin = bx - band, xmax = bx + band)

# ---- low predicted enrollment sub-region (inside the feasible set) ----------
th <- seq(0, 2 * pi, length.out = 240)
ell <- function(cx, cy, a, b, rot = 0) {
  x0 <- a * cos(th); y0 <- b * sin(th)
  data.frame(x = cx + x0 * cos(rot) - y0 * sin(rot),
             y = cy + x0 * sin(rot) + y0 * cos(rot))
}
low_en <- ell(8.15, 4.55, 2.75, 1.85, rot = 0.16)

# ---- hatching for the uncertainty ribbon ------------------------------------
# short diagonals stepped along y, each spanning the local ribbon width
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

# ---- evaluated points -------------------------------------------------------
past_infeasible <- data.frame(
  x = c(1.55, 2.85, 3.45, 1.95, 2.05),
  y = c(6.95, 7.75, 5.55, 4.35, 2.55)
)
past_feasible <- data.frame(
  x = c(7.05, 9.00, 11.75, 11.35, 12.65, 8.10),
  y = c(1.25, 7.35,  5.85,  1.90,  3.55, 6.85)
)
next_pt  <- data.frame(x = xb(4.95), y = 4.95)
# the model's predicted best design: deep inside the cheap region, far from the
# boundary, and therefore NOT where the next evaluation buys the most.
pred_best <- data.frame(x = 9.35, y = 3.40)

# labels drawn with a white plate (geom_label) rather than annotate(), because
# annotate() drops `label.size` and leaves a visible box border.
plate_labs <- data.frame(
  x     = c(6.37, 2.35),
  y     = c(7.75, 0.85),
  lab   = c("uncertain", "next simulation"),
  col   = c(graphite, accent),
  sz    = c(3.9, 4.3)
)

# ---- panel ------------------------------------------------------------------
p <- ggplot() +
  # regions
  geom_polygon(data = infeasible_poly, aes(x, y), fill = mist, colour = NA) +
  geom_polygon(data = feasible_poly, aes(x, y), fill = carolina,
               alpha = 0.17, colour = NA) +
  geom_polygon(data = low_en, aes(x, y), fill = cdeep, alpha = 0.30, colour = NA) +
  geom_path(data = low_en, aes(x, y), colour = cdeep, linewidth = 0.45, alpha = 0.65) +
  # uncertainty ribbon over the boundary
  geom_ribbon(data = band_df, aes(y = y, xmin = xmin, xmax = xmax),
              fill = fog, alpha = 0.80) +
  geom_segment(data = hatch, aes(x = x, xend = xend, y = y, yend = yend),
               colour = graphite, linewidth = 0.28, alpha = 0.30) +
  geom_path(data = bound_df, aes(x, y), colour = graphite,
            linewidth = 0.8, linetype = "22") +
  # evaluated points
  geom_point(data = past_infeasible, aes(x, y), shape = 4,
             colour = graphite, size = 4.2, stroke = 1.15) +
  geom_point(data = past_feasible, aes(x, y), shape = 21, fill = cdeep,
             colour = "white", size = 4.3, stroke = 0.7) +
  # the model's predicted best (deliberately subdued: we do NOT sample here)
  geom_point(data = pred_best, aes(x, y), shape = 23, fill = "white",
             colour = graphite, size = 4.6, stroke = 0.9) +
  geom_text(data = pred_best, aes(x, y - 1.00, label = "predicted best"),
            colour = graphite, size = 4.7, fontface = "bold") +
  # next candidate
  geom_point(data = next_pt, aes(x, y), shape = 21, fill = NA,
             colour = accent, size = 9.0, stroke = 1.0) +
  geom_point(data = next_pt, aes(x, y), shape = 21, fill = accent,
             colour = "white", size = 4.6, stroke = 0.9) +
  # annotation arrow to the next candidate
  annotate("curve", x = 2.35, y = 1.15, xend = next_pt$x - 0.85, yend = next_pt$y - 0.85,
           curvature = -0.28, linewidth = 0.75, colour = accent,
           arrow = arrow(length = unit(0.18, "cm"), type = "closed")) +
  # region labels
  annotate("text", x = 1.95, y = 5.85, label = "probably\ninfeasible",
           colour = graphite, size = 5.8, fontface = "bold", lineheight = 0.95) +
  annotate("text", x = 12.15, y = 7.45, label = "probably\nfeasible",
           colour = cdeep, size = 5.8, fontface = "bold", lineheight = 0.95) +
  annotate("text", x = 8.55, y = 4.55, label = "low predicted\nenrollment",
           colour = navy, size = 5.8, fontface = "bold", lineheight = 0.95) +
  geom_label(data = plate_labs, aes(x, y, label = lab), colour = plate_labs$col,
             size = plate_labs$sz, fill = "white", linewidth = 0,
             fontface = "bold", label.padding = unit(0.13, "lines")) +
  # caption tag
  annotate("text", x = 13.85, y = 0.30, label = "Schematic illustration",
           colour = graphite, size = 4.1, fontface = "italic", hjust = 1) +
  scale_x_continuous(limits = xlim, expand = c(0, 0)) +
  scale_y_continuous(limits = ylim, expand = c(0, 0)) +
  labs(x = "Efficacy threshold", y = "Futility threshold") +
  theme_minimal(base_size = 12) +
  theme(
    axis.title  = element_text(size = 12, face = "bold", colour = navy),
    axis.text   = element_blank(),
    panel.grid  = element_blank(),
    panel.border = element_rect(colour = mist, fill = NA, linewidth = 0.6),
    legend.position = "none",
    plot.margin = margin(6, 6, 4, 4)
  )

if (!dir.exists("images")) dir.create("images", showWarnings = FALSE)
ggsave("images/fig_acquisition_regions.png", p,
       width = 8.6, height = 4.7, dpi = 300, bg = "white")
cat("written: images/fig_acquisition_regions.png\n")
