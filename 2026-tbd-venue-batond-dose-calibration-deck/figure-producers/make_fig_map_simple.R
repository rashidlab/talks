dir.create("images", showWarnings = FALSE)
# make_fig_map_simple.R
# Two-step "simulations -> prediction model" schematic for the generalist deck.
# ILLUSTRATIVE (set.seed): one design knob on x, one operating characteristic
# on y. Panel 1: the seed evaluations with Monte Carlo error bars. Panel 2: the
# same points plus a Gaussian-process fit with an uncertainty band, standing in
# for BATON's surrogate from design settings to operating characteristics.
#
# Generalist revision, 2026-09-05. Every mark now carries a direct label in
# plain language rather than a legend or an inferred convention.
#   orange points  -> "designs we simulated"   (drawn at geom_point, obs)
#   blue line      -> "predicted performance"  (drawn from band$m, the km mean)
#   blue band      -> "uncertainty"            (drawn from band$lo, band$hi)
# The two panels share base(), ends() and the orange label, so the reveal of
# panel 2 over panel 1 stays registered to the pixel.
#
# Axis direction, verified from code rather than from the picture. truth() is
# monotone increasing in x away from the small dip near 0.25, so the right hand
# end is the high correct-selection end, and the original break-to-label pairing
# put "strict" there. More patients demanded at a dose is what buys that, so the
# right end reads "more patients required" and the left end reads "fewer
# patients required at a dose".
suppressPackageStartupMessages({ library(ggplot2); library(DiceKriging) })
navy <- "#13294B"; car <- "#4B9CD3"; deep <- "#2E6A9F"
graph <- "#5B6670"; fog <- "#F4F6F8"; mist <- "#E6EAEF"; orange <- "#E07C24"

set.seed(3)
truth <- function(x) 0.55 + 0.37 * plogis((x - 0.55) * 12) - 0.10 * exp(-((x - 0.25) / 0.08)^2)
x_obs <- sort(c(0.06, 0.16, 0.27, 0.36, 0.47, 0.58, 0.66, 0.78, 0.9))
se_obs <- runif(length(x_obs), 0.025, 0.045)
y_obs <- truth(x_obs) + rnorm(length(x_obs), 0, se_obs)
obs <- data.frame(x = x_obs, y = y_obs, se = se_obs)

km_fit <- km(design = data.frame(x = x_obs), response = y_obs,
             noise.var = se_obs^2, covtype = "matern5_2", control = list(trace = FALSE))
xg <- seq(0, 1, length.out = 200)
pr <- predict(km_fit, newdata = data.frame(x = xg), type = "UK")
band <- data.frame(x = xg, m = pr$mean, lo = pr$lower95, hi = pr$upper95)

base <- function() {
  list(
    scale_x_continuous(breaks = NULL),
    scale_y_continuous(breaks = c(0.4, 0.6, 0.8, 1.0)),
    coord_cartesian(ylim = c(0.30, 1.16), xlim = c(0, 1)),
    labs(x = "One design setting (patients needed at each dose)",
         y = "Chance of choosing\nthe right dose",
         caption = "Schematic illustration"),
    theme_minimal(base_size = 13),
    theme(panel.grid.minor = element_blank(), panel.grid.major = element_line(colour = "#EDF0F2"),
          axis.title = element_text(colour = navy, face = "bold", size = 19),
          axis.text = element_text(colour = graph, size = 16),
          plot.title = element_text(colour = navy, face = "bold", size = 19, hjust = 0.5),
          plot.subtitle = element_text(colour = graph, size = 14, hjust = 0.5),
          plot.caption = element_text(colour = graph, size = 12, face = "italic", hjust = 1),
          plot.margin = margin(6, 12, 4, 6))
  )
}

# the two ends of the design setting, in plain language, drawn inside the panel
# so a long phrase cannot collide with the y axis title
ends <- list(
  annotate("text", x = 0.005, y = 0.345, hjust = 0, label = "fewer patients required at a dose",
           colour = graph, size = 5.4, fontface = "bold"),
  annotate("text", x = 0.995, y = 0.345, hjust = 1, label = "more patients required",
           colour = graph, size = 5.4, fontface = "bold")
)

pts <- list(
  geom_errorbar(data = obs, aes(x = x, ymin = y - 1.96 * se, ymax = y + 1.96 * se),
                width = 0.015, colour = orange, linewidth = 0.7),
  geom_point(data = obs, aes(x = x, y = y), colour = orange, size = 3.8),
  geom_point(data = obs, aes(x = x, y = y), shape = 21, fill = NA, colour = "white", size = 3.8, stroke = 0.4)
)

# direct label on the orange points, identical in both panels
pts_label <- list(
  annotate("curve", x = 0.330, y = 0.912, xend = 0.362, yend = 0.674,
           curvature = -0.24, linewidth = 0.7, colour = orange,
           arrow = arrow(length = unit(0.18, "cm"), type = "closed")),
  annotate("text", x = 0.265, y = 0.965, hjust = 0, label = "designs we simulated",
           colour = orange, size = 6.4, fontface = "bold")
)

p1 <- ggplot() + pts + pts_label + ends +
  labs(title = "What the simulations told us",
       subtitle = "Each point is one design, simulated thousands of times. Bars show simulation error.") +
  base()

p2 <- ggplot() +
  geom_ribbon(data = band, aes(x = x, ymin = lo, ymax = hi), fill = car, alpha = 0.22) +
  geom_line(data = band, aes(x = x, y = m), colour = deep, linewidth = 1.4) +
  pts + pts_label + ends +
  # direct label on the band
  annotate("curve", x = 0.100, y = 0.762, xend = 0.118, yend = 0.594,
           curvature = 0.25, linewidth = 0.7, colour = deep,
           arrow = arrow(length = unit(0.18, "cm"), type = "closed")) +
  annotate("text", x = 0.015, y = 0.815, hjust = 0, label = "uncertainty",
           colour = deep, size = 6.4, fontface = "bold") +
  # direct label on the fitted line
  annotate("curve", x = 0.690, y = 0.560, xend = 0.748, yend = 0.848,
           curvature = -0.28, linewidth = 0.7, colour = deep,
           arrow = arrow(length = unit(0.18, "cm"), type = "closed")) +
  annotate("text", x = 0.565, y = 0.495, hjust = 0, label = "predicted performance",
           colour = deep, size = 6.4, fontface = "bold") +
  # the one callout the audience should leave with
  annotate("text", x = 0.005, y = 1.100, hjust = 0,
           label = "Where the band is wide, we are less sure.",
           colour = navy, size = 7.0, fontface = "bold") +
  annotate("curve", x = 0.795, y = 1.100, xend = 0.945, yend = 1.020,
           curvature = -0.30, linewidth = 0.8, colour = navy,
           arrow = arrow(length = unit(0.19, "cm"), type = "closed")) +
  labs(title = "Fit a prediction model through them",
       subtitle = "Settings go in, predicted trial performance comes out, with uncertainty.") +
  base()

ggsave("images/fig_map_points.png", p1, width = 8.6, height = 4.6, dpi = 300, bg = "white")
ggsave("images/fig_map_model.png",  p2, width = 8.6, height = 4.6, dpi = 300, bg = "white")
cat("written: images/fig_map_points.png, images/fig_map_model.png\n")
