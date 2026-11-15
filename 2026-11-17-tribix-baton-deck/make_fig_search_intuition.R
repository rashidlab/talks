# make_fig_search_intuition.R
# Two-panel search-intuition schematic for the compmed BATON deck, adapted from
# manuscript/adapt_arpa_symposium_talk.qmd (slides at lines 411 and 439 there).
# ILLUSTRATIVE: the quality surface and both search patterns are synthetic
# (set.seed below), drawn to teach the guided-walk idea. They are NOT
# simulation output; the measured comparison lives in fig_sample_efficiency.png.
# Brand: navy #13294B, carolina #4B9CD3, carolina-deep #2E6A9F, graphite
# #5B6670, fog #F4F6F8. Surface uses a fog-to-navy ramp (colorblind-safe,
# no red-green); the guided trajectory is drawn in carolina shades.

library(ggplot2)

set.seed(2025)
grid_x <- rep(1:10, each = 10)
grid_y <- rep(1:10, times = 10)
grid_quality <- 100 - sqrt((grid_x - 7.5)^2 + (grid_y - 6.2)^2) * 8 + rnorm(100, 0, 3)
grid_df <- data.frame(x = grid_x, y = grid_y, q = grid_quality)

base_theme <- theme_minimal(base_size = 12) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 20, color = "#13294B"),
        plot.subtitle = element_text(hjust = 0.5, size = 16, color = "#5B6670"),
        axis.title = element_text(size = 17, face = "bold", color = "#13294B"),
        axis.text = element_blank(), panel.grid = element_blank(),
        plot.margin = margin(4, 4, 4, 4))

surface_scale <- scale_fill_gradientn(
  colors = c("#FFFFFF", "#DCE7F1", "#7EB8E4", "#2E6A9F", "#13294B"),
  guide = "none")

# Panel A: exhaustive grid, every cell evaluated
p_grid <- ggplot() +
  geom_tile(data = grid_df, aes(x = x, y = y, fill = q), alpha = 0.95) +
  geom_point(data = grid_df, aes(x = x, y = y), size = 1.6, alpha = 0.55, color = "#5B6670") +
  coord_fixed() +
  labs(title = "Grid search", subtitle = "100 evaluations on a fixed lattice",
       x = "Efficacy threshold", y = "Futility threshold") +
  base_theme + surface_scale

# Panel B: model-guided walk, same surface, 30 evaluations homing in
bo_points <- data.frame(
  iter = 1:30,
  x = c(5, 3, 7, 8, 6, 7.5, 7.2, 7.8, 7.4, 7.6, 7.55, 7.48, 7.52, 7.51, 7.50,
        7.49, 7.51, 7.50, 7.50, 7.51, 7.50, 7.50, 7.50, 7.50, 7.50, 7.50, 7.50, 7.50, 7.50, 7.50),
  y = c(4, 7, 5, 8, 6, 6, 6.3, 6.1, 6.25, 6.15, 6.22, 6.18, 6.21, 6.20, 6.20,
        6.19, 6.20, 6.20, 6.20, 6.20, 6.20, 6.20, 6.20, 6.20, 6.20, 6.20, 6.20, 6.20, 6.20, 6.20)
)

p_bo <- ggplot() +
  geom_tile(data = grid_df, aes(x = x, y = y, fill = q), alpha = 0.8) +
  geom_point(data = bo_points, aes(x = x, y = y, color = iter), size = 3.0) +
  geom_point(data = bo_points, aes(x = x, y = y), size = 3.0, shape = 21,
             fill = NA, color = "white", stroke = 0.4) +
  scale_color_gradient(low = "#F2B36B", high = "#9C4A08", guide = "none") +
  coord_fixed() +
  labs(title = "Model-guided search", subtitle = "30 evaluations; repeated cells overlap",
       x = "Efficacy threshold", y = "Futility threshold") +
  base_theme + surface_scale

out <- "images"
ggsave(file.path(out, "fig_search_grid.png"),   p_grid, width = 4.6, height = 4.9, dpi = 300, bg = "white")
ggsave(file.path(out, "fig_search_guided.png"), p_bo,   width = 4.6, height = 4.9, dpi = 300, bg = "white")
cat("written: images/fig_search_grid.png, images/fig_search_guided.png\n")

# Panel C: space-filling initial sample (BO Stage 0). Illustrative LHS-like
# scatter; the production runs use a 60-point Latin-hypercube initial design
# (manuscript Section on multi-fidelity staging), shown here with fewer points
# for legibility.
set.seed(11)
n_init_illus <- 15
lhs_x <- (sample(1:n_init_illus) - runif(n_init_illus)) / n_init_illus * 9 + 1
lhs_y <- (sample(1:n_init_illus) - runif(n_init_illus)) / n_init_illus * 9 + 1
init_df <- data.frame(x = lhs_x, y = lhs_y)

p_init <- ggplot() +
  geom_tile(data = grid_df, aes(x = x, y = y, fill = q), alpha = 0.8) +
  geom_point(data = init_df, aes(x = x, y = y), size = 3.2, color = "#E07C24") +
  geom_point(data = init_df, aes(x = x, y = y), size = 3.2, shape = 21,
             fill = NA, color = "white", stroke = 0.4) +
  coord_fixed() +
  labs(title = "A space-filling sample",
       subtitle = "scattered designs seed the model",
       x = "Efficacy threshold", y = "Futility threshold") +
  base_theme + surface_scale

ggsave(file.path(out, "fig_search_init.png"), p_init, width = 4.6, height = 4.9, dpi = 300, bg = "white")
cat("written: images/fig_search_init.png\n")

# Panel D: random search, 100 uniformly random evaluations on the same surface,
# drawn in graphite like the grid so it reads as "the alternative", not as the
# orange BATON seed. Illustrative; the measured number (136 of 2,000 feasible)
# comes from results/validation/random_search_summary.csv.
set.seed(2026)
rand_df <- data.frame(x = runif(100, 0.5, 10.5), y = runif(100, 0.5, 10.5))
p_rand <- ggplot() +
  geom_tile(data = grid_df, aes(x = x, y = y, fill = q), alpha = 0.95) +
  geom_point(data = rand_df, aes(x = x, y = y), size = 1.6, alpha = 0.7, color = "#5B6670") +
  coord_fixed() +
  labs(title = "Random search", subtitle = "100 evaluations, placed at random",
       x = "Efficacy threshold", y = "Futility threshold") +
  base_theme + surface_scale
ggsave(file.path(out, "fig_search_random.png"), p_rand, width = 4.6, height = 4.9, dpi = 300, bg = "white")
cat("written: images/fig_search_random.png\n")
