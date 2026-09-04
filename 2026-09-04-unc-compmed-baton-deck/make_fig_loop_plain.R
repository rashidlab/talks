# Plain-English BATON loop for the main deck (technical loop fig_D lives in backup).
# Four-node cycle, house palette, minimal words.
library(ggplot2)
navy <- "#13294B"; car <- "#4B9CD3"; graph <- "#5B6670"; fog <- "#F4F6F8"

nodes <- data.frame(
  x = c(1.5, 5.0, 8.5, 5.0), y = c(3.0, 4.6, 3.0, 1.4),
  main = c("Propose\na design", "Simulate\ntrials", "Learn from\neverything seen", "Choose the next\ndesign worth trying"),
  sub  = c("", "trial simulator", "surrogate model", "next candidate"))

arrow_df <- data.frame(
  x    = c(2.35, 5.95, 7.65, 4.05),
  y    = c(3.55, 4.35, 2.45, 1.65),
  xend = c(4.05, 7.65, 5.95, 2.35),
  yend = c(4.35, 3.55, 1.65, 2.45))

p <- ggplot() +
  geom_curve(data = arrow_df, aes(x = x, y = y, xend = xend, yend = yend),
             curvature = -0.25, colour = car, linewidth = 1.4,
             arrow = arrow(length = unit(0.3, "cm"), type = "closed")) +
  geom_tile(data = nodes, aes(x, y), width = 2.3, height = 1.15,
            fill = fog, colour = navy, linewidth = 0.6) +
  geom_text(data = nodes, aes(x, y + 0.06, label = main), size = 6.4,
            fontface = "bold", colour = navy, lineheight = 0.9) +
  geom_text(data = subset(nodes, sub != ""), aes(x, y - 0.75, label = sub),
            size = 5.6, colour = graph, fontface = "italic") +
  annotate("text", x = 5.0, y = 3.0, label = "repeat", size = 5.6,
           colour = graph, fontface = "italic") +
  xlim(0.1, 9.9) + ylim(0.4, 5.5) + theme_void() +
  theme(plot.margin = margin(4, 4, 4, 4))
ggsave("images/fig_loop_plain.png", p, width = 9.6, height = 4.6, dpi = 300, bg = "white")
cat("loop written\n")
