# make_fig_tally_040.R
# Slide 15 ("Simulation tells us how one candidate behaves..."): one design, simulated many
# times, and the two counts that become power and type I error.
# Replaces images/fig_tally_strip.png (make_fig_novice_visuals.R section 2), which printed the
# pre-revision design (power 0.863, type I 0.0013, 11.66 expected patients).
# Source, BATON 0.4.0 package: ~/Downloads/atbo-longleaf/results/retune_xphil/
#   final_summary_designs.csv, row design R01 (cohortA_H0_fut, the Table 3 H0-Optimal design of
#   manuscript/jasa_manuscript_reduced.pdf): certification at five fresh seeds, 50,000 simulated
#   trials pooled per hypothesis, power_count, type1_count, E0N. Read from the file, not typed.
# Output: images/fig_tally_strip_040.png

library(ggplot2)
src <- path.expand("~/Downloads/atbo-longleaf/results/retune_xphil/final_summary_designs.csv")
d <- read.csv(src, stringsAsFactors = FALSE)
r <- d[d$design == "R01", ]
stopifnot(nrow(r) == 1, r$sid == "cohortA_H0_fut", r$n_pooled == 50000, isTRUE(r$certified))
fmt <- function(x) format(x, big.mark = ",", trim = TRUE)
n_go1 <- r$power_count; n_go0 <- r$type1_count; R <- r$n_pooled

navy <- "#13294B"; car <- "#4B9CD3"; deep <- "#2E6A9F"
graph <- "#5B6670"; fog <- "#F4F6F8"; mist <- "#E6EAEF"; orange <- "#E07C24"
lab <- function(x, y, l, size = 4.6, col = navy, face = "bold", hj = 0.5)
  annotate("text", x = x, y = y, label = l, size = size, colour = col,
           fontface = face, hjust = hj, lineheight = 0.95, family = "Archivo")
set.seed(7)
mk_row <- function(y, p_go, n = 20) {
  go <- c(rep(TRUE, round(p_go * n)), rep(FALSE, n - round(p_go * n)))
  data.frame(x = seq(37, 60, length.out = n), y = y, go = sample(go))
}
r_works <- mk_row(6.9, n_go1 / R)   # icon rows are illustrative samples of 20;
r_fails <- mk_row(4.1, n_go0 / R)   # the printed counts are the real ones
p <- ggplot() + xlim(0, 100) + ylim(0, 10) +
  annotate("rect", xmin = 1, xmax = 20, ymin = 3.2, ymax = 7.8, fill = "white", colour = navy, linewidth = 0.5) +
  lab(10.5, 6.6, "One candidate\ndesign", 5.4) +
  lab(10.5, 4.4, "(one setting of\nthe knobs)", 5.0, graph, "plain") +
  annotate("segment", x = 21, xend = 34, y = 5.5, yend = 5.5, colour = navy,
           arrow = arrow(length = unit(0.24, "cm"), type = "closed"), linewidth = 0.8) +
  lab(27.8, 6.9, paste0("simulate\n", fmt(R), " times"), 5.0, graph, "plain") +
  lab(36, 8.5, "Alternative is true (drug works):", 4.9, deep, "bold", 0) +
  geom_point(data = r_works, aes(x, y), shape = 22, size = 4.6,
             fill = ifelse(r_works$go, car, mist), colour = "white") +
  lab(61.5, 6.9, paste(fmt(n_go1), "say GO"), 4.9, deep, "bold", 0) +
  lab(36, 5.6, "Null is true (no effect):", 4.9, orange, "bold", 0) +
  geom_point(data = r_fails, aes(x, y), shape = 22, size = 4.6,
             fill = ifelse(r_fails$go, orange, mist), colour = "white") +
  lab(61.5, 4.1, paste("only", fmt(n_go0), "say GO"), 4.9, orange, "bold", 0) +
  annotate("rect", xmin = 79, xmax = 100, ymin = 1.4, ymax = 9.2, fill = fog, colour = mist, linewidth = 0.5) +
  lab(89.5, 8.2, sprintf("Power = %.2f", n_go1 / R), 5.0, deep) +
  lab(89.5, 6.1, paste0("Type I error =\n", fmt(n_go0), " / ", fmt(R)), 5.0, orange) +
  lab(89.5, 3.2, sprintf("Avg. patients\nif inactive = %.1f", r$E0N), 4.7, orange) +
  theme_void() + theme(plot.margin = margin(6, 10, 6, 10))
ggsave("images/fig_tally_strip_040.png", p, width = 10.5, height = 3.1, dpi = 300, bg = "white",
       device = ragg::agg_png)
cat("power", n_go1 / R, "type1", n_go0 / R, "E0N", r$E0N, "\n")
