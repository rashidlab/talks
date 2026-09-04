# make_fig_map_simple.R
# Two-step "simulations -> prediction model" schematic for the compmed deck.
# ILLUSTRATIVE (set.seed): one design knob on x, one operating characteristic
# on y. Panel 1: the seed evaluations with Monte Carlo error bars. Panel 2: the
# same points plus a Gaussian-process fit with an uncertainty band, standing in
# for BATON's surrogate from design settings to operating characteristics.
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
    scale_x_continuous(breaks = c(0.05, 0.95), labels = c("lenient", "strict")),
    scale_y_continuous(breaks = c(0.4, 0.6, 0.8, 1.0)), coord_cartesian(ylim = c(0.35, 1.03), xlim = c(0, 1)),
    labs(x = "One design setting (e.g. futility threshold)", y = "Power"),
    theme_minimal(base_size = 13),
    theme(panel.grid.minor = element_blank(), panel.grid.major = element_line(colour = "#EDF0F2"),
          axis.title = element_text(colour = navy, face = "bold", size = 18),
          axis.text = element_text(colour = graph, size = 16),
          plot.title = element_text(colour = navy, face = "bold", size = 17, hjust = 0.5),
          plot.subtitle = element_text(colour = graph, size = 13, hjust = 0.5),
          plot.margin = margin(6, 12, 6, 6))
  )
}
pts <- list(
  geom_errorbar(data = obs, aes(x = x, ymin = y - 1.96 * se, ymax = y + 1.96 * se),
                width = 0.015, colour = orange, linewidth = 0.7),
  geom_point(data = obs, aes(x = x, y = y), colour = orange, size = 3.4),
  geom_point(data = obs, aes(x = x, y = y), shape = 21, fill = NA, colour = "white", size = 3.4, stroke = 0.4)
)

p1 <- ggplot() + pts +
  labs(title = "What the simulations told us",
       subtitle = "each point = one design, simulated thousands of times (bars: Monte Carlo error)") +
  base()

p2 <- ggplot() +
  geom_ribbon(data = band, aes(x = x, ymin = lo, ymax = hi), fill = car, alpha = 0.22) +
  geom_line(data = band, aes(x = x, y = m), colour = deep, linewidth = 1.3) +
  pts +
  annotate("label", x = 0.72, y = 0.50, label = "model’s prediction\nfor designs never simulated",
           size = 5.0, colour = deep, fontface = "bold", label.size = 0, fill = "white") +
  annotate("label", x = 0.31, y = 0.97, label = "wider band =\nless certain",
           size = 5.2, colour = graph, label.size = 0, fill = "white") +
  labs(title = "Fit a prediction model through them",
       subtitle = "design settings in, trial behavior out, with uncertainty") +
  base()

ggsave("images/fig_map_points.png", p1, width = 8.6, height = 4.4, dpi = 300, bg = "white")
ggsave("images/fig_map_model.png",  p2, width = 8.6, height = 4.4, dpi = 300, bg = "white")
cat("written: images/fig_map_points.png, images/fig_map_model.png\n")
