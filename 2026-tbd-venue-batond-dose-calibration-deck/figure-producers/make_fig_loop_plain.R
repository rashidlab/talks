# Plain-English BATON loop for the main deck (technical loop fig_D lives in backup).
# Four-node cycle, house palette, minimal words.
dir.create("images", showWarnings = FALSE)
library(ggplot2)
navy <- "#13294B"; car <- "#4B9CD3"; graph <- "#5B6670"; fog <- "#F4F6F8"

# NUMBERED, AND THE THREE JARGON SUB-LABELS ARE GONE. The owner's review asks for four numbered
# steps and for "surrogate model" to be removed, because a generalist does not need the model's
# name at the point the loop is introduced. The other two sub-labels went with it, since the step
# names already say what each box does and three italic asides under four boxes read as clutter
# rather than as information.
nodes <- data.frame(
  x = c(1.5, 5.0, 8.5, 5.0), y = c(3.0, 4.6, 3.0, 1.4),
  main = c("1. Propose\nsettings", "2. Simulate\ntrials", "3. Learn what\nworked",
           "4. Choose where\nto try next"),
  sub  = c("", "", "", ""))
# ASSERTED. The arrows are drawn between fixed coordinates rather than derived from the node
# order, so a renumbering that did not match the arrow direction would silently teach the loop
# backwards. Step 1 sits left, 2 top, 3 right, 4 bottom, and the arrow list must run 1 to 2 to 3
# to 4 and back.
stopifnot(identical(substr(nodes$main, 1, 1), c("1", "2", "3", "4")))

arrow_df <- data.frame(
  x    = c(2.7, 6.3, 7.3, 3.7),
  y    = c(3.55, 4.35, 2.45, 1.65),
  xend = c(3.7, 7.3, 6.3, 2.7),
  yend = c(4.35, 3.55, 1.65, 2.45))

p <- ggplot() +
  geom_curve(data = arrow_df, aes(x = x, y = y, xend = xend, yend = yend),
             curvature = -0.25, colour = car, linewidth = 1.4,
             arrow = arrow(length = unit(0.3, "cm"), type = "closed")) +
  geom_tile(data = nodes, aes(x, y), width = 3.0, height = 1.2,
            fill = fog, colour = navy, linewidth = 0.6) +
  geom_text(data = nodes, aes(x, y + 0.06, label = main), size = 5.8,
            fontface = "bold", colour = navy, lineheight = 0.9) +
  geom_text(data = subset(nodes, sub != ""), aes(x, y - 0.75, label = sub),
            size = 5.6, colour = graph, fontface = "italic") +
  annotate("text", x = 5.0, y = 3.0, label = "BATON-D repeats\nthis loop", size = 6.0,
           colour = navy, fontface = "bold", lineheight = 0.95) +
  xlim(-0.2, 10.2) + ylim(0.4, 5.5) + theme_void() +
  theme(plot.margin = margin(4, 4, 4, 4))
ggsave("images/fig_loop_plain.png", p, width = 9.6, height = 4.6, dpi = 300, bg = "white")
cat("loop written\n")
