# make_fig_novice_visuals.R
# Three novice-scaffolding figures for the compmed BATON deck (trainee-review pass).
# 1. fig_fixed_vs_adaptive.png : side-by-side trial timelines (SCHEMATIC)
# 2. fig_tally_strip.png       : one design -> 10,000 draws -> behavior, using
#    Design 1's REAL verified numbers (cohortA_H0_fut: power 0.863, type I
#    0.0013, E0[N] 11.66 from philosophy_comparison_heritage.csv)
# 3. fig_frontier_novice.png   : constraints-vs-choice scatter; the three
#    labeled points are the REAL Scenario A designs; the background cloud is
#    illustrative (drawn to teach the region idea).
# Brand: navy #13294B, carolina #4B9CD3, deep #2E6A9F, graphite #5B6670,
# fog #F4F6F8, mist #E6EAEF; accent orange #E07C24 only for STOP marks.

library(ggplot2)

navy <- "#13294B"; car <- "#4B9CD3"; deep <- "#2E6A9F"
graph <- "#5B6670"; fog <- "#F4F6F8"; mist <- "#E6EAEF"; orange <- "#E07C24"

th <- theme_void() + theme(plot.margin = margin(6, 10, 6, 10))

# ---------- 1. Fixed vs adaptive timeline ----------
lab <- function(x, y, l, size = 4.6, col = navy, face = "bold", hj = 0.5)
  annotate("text", x = x, y = y, label = l, size = size, colour = col,
           fontface = face, hjust = hj, lineheight = 0.95)

p1 <- ggplot() + xlim(0, 100) + ylim(0, 10) +
  # Row 1: traditional
  lab(1, 9.0, "TRADITIONAL", 4.2, graph, "bold", 0) +
  annotate("rect", xmin = 14, xmax = 62, ymin = 8.0, ymax = 9.6, fill = fog, colour = navy, linewidth = 0.4) +
  lab(38, 8.8, "Enroll all 50 patients", 4.4, navy, "plain") +
  annotate("segment", x = 62, xend = 70, y = 8.8, yend = 8.8, colour = navy,
           arrow = arrow(length = unit(0.22, "cm"), type = "closed"), linewidth = 0.7) +
  annotate("point", x = 73, y = 8.8, shape = 23, size = 7, fill = car, colour = navy) +
  lab(77, 8.8, "Analyze once", 4.2, navy, "plain", 0) +
  lab(77, 7.6, "GO / STOP", 5.0, deep, "bold", 0) +
  # Row 2: adaptive
  lab(1, 5.2, "ADAPTIVE", 4.2, graph, "bold", 0) +
  annotate("rect", xmin = 14, xmax = 30, ymin = 4.2, ymax = 5.8, fill = fog, colour = navy, linewidth = 0.4) +
  lab(22, 5.0, "Enroll 10", 4.0, navy, "plain") +
  annotate("point", x = 33.5, y = 5.0, shape = 23, size = 7, fill = orange, colour = navy) +
  lab(33.5, 3.4, "LOOK", 5.0, graph, "bold") +
  annotate("rect", xmin = 37, xmax = 53, ymin = 4.2, ymax = 5.8, fill = fog, colour = navy, linewidth = 0.4) +
  lab(45, 5.0, "Enroll 10", 4.0, navy, "plain") +
  annotate("point", x = 56.5, y = 5.0, shape = 23, size = 7, fill = orange, colour = navy) +
  lab(56.5, 3.4, "LOOK", 5.0, graph, "bold") +
  annotate("rect", xmin = 60, xmax = 70, ymin = 4.2, ymax = 5.8, fill = fog, colour = navy, linewidth = 0.4) +
  lab(65, 5.0, "...", 4.6, navy, "plain") +
  annotate("point", x = 73, y = 5.0, shape = 23, size = 7, fill = car, colour = navy) +
  lab(77, 5.0, "Final analysis", 4.2, navy, "plain", 0) +
  lab(77, 3.8, "GO / STOP", 5.0, deep, "bold", 0) +
  # LOOK legend
  lab(14, 1.6, "At an interim look we update the probability of benefit using the data so far.", 4.6, navy, "plain", 0) +
  lab(14, 0.6, "Prespecified rules can stop early for futility and, in some designs, for efficacy.", 4.6, navy, "plain", 0) +
  th
ggsave("images/fig_fixed_vs_adaptive.png", p1, width = 10.5, height = 3.4, dpi = 300, bg = "white")

# ---------- 2. One design -> 10,000 draws -> behavior ----------
set.seed(7)
mk_row <- function(y, p_go, n = 20) {
  go <- c(rep(TRUE, round(p_go * n)), rep(FALSE, n - round(p_go * n)))
  data.frame(x = seq(37, 60, length.out = n), y = y, go = sample(go))
}
r_works <- mk_row(6.9, 0.85)   # icon rows are illustrative samples;
r_fails <- mk_row(4.1, 0.0)    # the printed numbers are the real ones
p2 <- ggplot() + xlim(0, 100) + ylim(0, 10) +
  # design card
  annotate("rect", xmin = 2, xmax = 22, ymin = 3.2, ymax = 7.8, fill = "white", colour = navy, linewidth = 0.5) +
  lab(12, 6.6, "One candidate\ndesign", 5.4) +
  lab(12, 4.4, "(one setting of\nthe knobs)", 5.0, graph, "plain") +
  annotate("segment", x = 23, xend = 33, y = 5.5, yend = 5.5, colour = navy,
           arrow = arrow(length = unit(0.24, "cm"), type = "closed"), linewidth = 0.8) +
  lab(28, 6.9, "simulate\n10,000 times", 5.0, graph, "plain") +
  # icon rows
  lab(36, 8.5, "Alternative is true (drug works):", 4.9, deep, "bold", 0) +
  geom_point(data = r_works, aes(x, y), shape = 22, size = 4.6,
             fill = ifelse(r_works$go, car, mist), colour = "white") +
  lab(61.5, 6.9, "8,630 say GO", 4.9, deep, "bold", 0) +
  lab(36, 5.6, "Null is true (no effect):", 4.9, orange, "bold", 0) +
  geom_point(data = r_fails, aes(x, y), shape = 22, size = 4.6,
             fill = ifelse(r_fails$go, orange, mist), colour = "white") +
  lab(61.5, 4.1, "only 13 say GO", 4.9, orange, "bold", 0) +
  # gauges
  annotate("rect", xmin = 79, xmax = 100, ymin = 1.4, ymax = 9.2, fill = fog, colour = mist, linewidth = 0.5) +
  lab(89.5, 8.2, "Power = 0.86", 5.0, deep) +
  lab(89.5, 6.1, "Type I error =\n13 / 10,000", 5.0, orange) +
  lab(89.5, 3.2, "Avg. patients\nunder null = 11.7", 4.7, orange) +
    th
ggsave("images/fig_tally_strip.png", p2, width = 10.5, height = 3.1, dpi = 300, bg = "white")

# ---------- 3. Constraints vs choice (novice frontier) ----------
set.seed(11)
# illustrative infeasible cloud + feasible cloud; three REAL scenario A designs.
# The infeasible marks must all lie OUTSIDE the calibrated box [10.2,26.5]x[27.5,51].
inf <- data.frame(x = runif(60, 9, 35.5), y = runif(60, 24.5, 56))
inside <- inf$x > 10.2 & inf$x < 26.5 & inf$y > 27.5 & inf$y < 51
inf <- inf[!inside, ]
inf <- inf[seq_len(min(nrow(inf), 22)), ]
feas <- data.frame(x = c(12.6, 13.8, 15.5, 17.9, 20.4, 14.9, 16.8, 19.5, 24.5, 21.8),
                   y = c(44, 39, 36.5, 34, 32.5, 48, 41, 37, 31.5, 33.5))
real <- data.frame(x = c(11.7, 11.9, 22.8), y = c(47, 31, 30),
                   nick = c('"Quit losers quickly"', '"The compromise"', '"Cap the worst case"'),
                   formal = c("H0-Optimal", "Admissible", "Minimax"))
p3 <- ggplot() +
  annotate("rect", xmin = 10.2, xmax = 26.5, ymin = 27.5, ymax = 51, fill = fog, colour = car, linewidth = 0.5, linetype = "dashed") +
  annotate("text", x = 25.9, y = 49.6, label = "all of these are calibrated", size = 4.0,
           colour = deep, fontface = "italic", hjust = 1) +
  geom_point(data = inf, aes(x, y), shape = 4, size = 2.6, colour = "#B9C0C7", stroke = 1.1) +
  annotate("text", x = 31.5, y = 52.5, label = "not allowed:\npower or type I fails", size = 3.6,
           colour = graph, lineheight = 0.9) +
  geom_point(data = feas, aes(x, y), size = 2.6, colour = car, alpha = 0.8) +
  geom_point(data = real, aes(x, y), size = 5, shape = 21, fill = deep, colour = navy, stroke = 0.8) +
  geom_text(data = real, aes(x, y, label = nick), size = 4.3, fontface = "bold",
            colour = navy, vjust = -1.4) +
  geom_text(data = real, aes(x, y, label = formal), size = 3.5, colour = graph, vjust = 2.3) +
  scale_x_continuous(limits = c(8, 36)) + scale_y_continuous(limits = c(24, 57)) +
  labs(x = "Average patients enrolled if the drug fails",
       y = "Maximum patients committed") +
  theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank(), panel.grid.major = element_line(colour = "#EDF0F2"),
        axis.title = element_text(size = 12, face = "bold", colour = navy),
        axis.text = element_text(size = 9, colour = graph))
ggsave("images/fig_frontier_novice.png", p3, width = 8.6, height = 4.7, dpi = 300, bg = "white")
cat("three figures written\n")
