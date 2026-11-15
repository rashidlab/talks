# Typical BATON sequence for the EVOLVE single-arm example.
# The optional search escalation remains in the slide's speaker notes.
library(ggplot2)

navy <- "#13294B"
deep <- "#2E6A9F"
stages <- data.frame(
  y = 3:1,
  width = c(8.4, 5.9, 5.1),
  label = c("Search many designs", "Recheck promising designs", "Verify with fresh simulations"),
  detail = c("3,000 simulated trials per design", "10,000 per design", "5 independent runs of 10,000 per scenario"),
  fill = c("#F4F6F8", "#A8CFEA", deep),
  text_colour = c(navy, navy, "white")
)

p <- ggplot(stages) +
  geom_tile(aes(x = 0, y = y, width = width, fill = fill), height = 0.61,
            colour = navy, linewidth = 0.5) +
  geom_text(aes(x = 0, y = y, label = label, colour = text_colour),
            size = 5.1, fontface = "bold") +
  geom_text(aes(x = 0, y = y - 0.48, label = detail), size = 4.5, colour = navy) +
  scale_fill_identity() +
  scale_colour_identity() +
  coord_cartesian(xlim = c(-4.5, 4.5), ylim = c(0.32, 3.39), expand = FALSE) +
  theme_void() +
  theme(plot.margin = margin(5, 8, 5, 8))

ggsave("images/fig_funnel_plain.png", p, width = 9.0, height = 4.6, dpi = 300, bg = "white")
