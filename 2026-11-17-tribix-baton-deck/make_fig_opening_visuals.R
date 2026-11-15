# make_fig_opening_visuals.R
# Illustrations for slides 6, 7 and 9 (Section 1). No number appears that is not already on its
# slide. Slides 5 and 8 use native HTML in the qmd instead.
#   images/fig_australia_slope.png  slide 6: two verified endpoints only (Hitchen et al. 2024,
#                                    18 trials in 2012, 75 in 2022), two points and one line,
#                                    no yearly series.
#   images/fig_late_failure_dots.png slide 7: 10 by 10 dots, 54 shaded (Hwang et al. 2016, 54% of 640).
#   images/fig_signal_gap.png       slide 9: schematic, small early trial with a short-term
#                                    readout, large later trial with a long-term readout, joined
#                                    by an arrow marked uncertain. No proportions implied.
# Deck colors: navy #13294B, carolina #4B9CD3, graphite #5B6670, hairline #E6EAEF.
library(ggplot2)
navy <- "#13294B"; car <- "#4B9CD3"; graph <- "#5B6670"; mist <- "#E6EAEF"; fog <- "#F4F6F8"
fam <- "Archivo"
tx <- function(x, y, l, size = 6, col = navy, face = "plain", hj = 0.5)
  annotate("text", x = x, y = y, label = l, size = size, colour = col, fontface = face,
           hjust = hj, family = fam, lineheight = 0.95)
save <- function(p, f, w, h) ggsave(file.path("images", f), p, width = w, height = h, dpi = 250,
                                    bg = "white", device = ragg::agg_png)

# ---- slide 6: two-point slope chart --------------------------------------------
s <- data.frame(year = c(2012, 2022), n = c(18, 75))
p6 <- ggplot(s, aes(year, n)) +
  geom_segment(aes(x = 2012, xend = 2022, y = 18, yend = 75), colour = car, linewidth = 2) +
  geom_point(size = 9, shape = 21, fill = navy, colour = "white", stroke = 1.5) +
  tx(2012, 30, "18", 11, navy, "bold") + tx(2022, 87, "75", 11, navy, "bold") +
  scale_x_continuous(breaks = c(2012, 2022), limits = c(2010.6, 2023.4)) +
  scale_y_continuous(limits = c(0, 95), breaks = NULL) +
  labs(x = NULL, y = NULL) +
  theme_minimal(base_size = 22, base_family = fam) +
  theme(panel.grid = element_blank(), axis.text.x = element_text(colour = graph, size = 24),
        axis.line.x = element_line(colour = mist, linewidth = 0.8))
save(p6, "fig_australia_slope.png", 7.0, 3.6)

# ---- slide 7: 54 of 100 dots ---------------------------------------------------
g <- expand.grid(col = 1:10, row = 10:1)
g$k <- seq_len(nrow(g)); g$fail <- g$k <= 54
p7 <- ggplot(g, aes(col, row)) +
  geom_point(aes(fill = fail), shape = 21, size = 8.2, colour = "white", stroke = 0.6,
             show.legend = FALSE) +
  scale_fill_manual(values = c(`TRUE` = navy, `FALSE` = mist)) +
  coord_fixed(xlim = c(0.5, 10.5), ylim = c(0.5, 10.5)) + theme_void()
save(p7, "fig_late_failure_dots.png", 3.4, 3.4)

# ---- slide 9: early signal to late outcome, link uncertain ----------------------
people <- function(x0, y0, nx, ny, step) {
  d <- expand.grid(i = 0:(nx - 1), j = 0:(ny - 1)); data.frame(x = x0 + d$i * step, y = y0 + d$j * step)
}
e <- people(5.5, 4.2, 3, 2, 3.4); l <- people(54.5, 2.6, 8, 5, 3.4)
p9 <- ggplot() + xlim(0, 100) + ylim(-7, 27) +
  annotate("rect", xmin = 2, xmax = 16.3, ymin = 1.6, ymax = 10.2, fill = fog, colour = navy, linewidth = 0.5) +
  geom_point(data = e, aes(x, y), size = 4.6, colour = car) +
  tx(2, 14.2, "Early trial", 6.2, navy, "bold", 0) + tx(9.2, -2.6, "small", 5.6, graph) +
  annotate("segment", x = 18, xend = 28, y = 5.9, yend = 5.9, colour = navy, linewidth = 1,
           arrow = arrow(length = unit(0.22, "cm"), type = "closed")) +
  tx(23.5, -1.2, "short-term\nsignal", 5.4, navy) +
  annotate("segment", x = 32.5, xend = 50, y = 5.9, yend = 5.9, colour = graph, linewidth = 1,
           linetype = "dashed", arrow = arrow(length = unit(0.22, "cm"), type = "closed")) +
  tx(41.5, 11.6, "?", 12, graph, "bold") + tx(41.5, -1.2, "uncertain\nlink", 5.4, graph) +
  annotate("rect", xmin = 51.5, xmax = 81.5, ymin = 0, ymax = 19.4, fill = fog, colour = navy, linewidth = 0.5) +
  geom_point(data = l, aes(x, y), size = 4.6, colour = car) +
  tx(66.5, 23.6, "Later trial", 6.2, navy, "bold") + tx(66.5, -3.4, "large", 5.6, graph) +
  annotate("segment", x = 83, xend = 98, y = 9.7, yend = 9.7, colour = navy, linewidth = 1,
           arrow = arrow(length = unit(0.22, "cm"), type = "closed")) +
  tx(91, 16.2, "long-term\noutcome", 5.4, navy) +
  theme_void()
save(p9, "fig_signal_gap.png", 7.0, 3.3)
cat("wrote slides 6, 7, 9 figures\n")
