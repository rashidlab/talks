# Slide 25: pair BATON and exact Simon expected enrollment under inactive treatment.
# Source: BATON 0.4.0, manuscript Section 4.3 and the validation summary below.

library(ggplot2)

src <- path.expand("~/Downloads/atbo-longleaf/results/validation/multiscenario_simon_summary.csv")
d <- read.csv(src, stringsAsFactors = FALSE)
stopifnot(nrow(d) == 12, all(d$both_satisfied))
d$exact <- d$matches_simon
gap <- d$baton_EN_null - d$simon_EN_null
stopifnot(sum(d$exact) == 4, all(gap >= 0))
worst <- d[which.max(gap), ]

navy <- "#13294B"
blue <- "#4B9CD3"
graphite <- "#5B6670"
mist <- "#E6EAEF"

p <- ggplot(d, aes(simon_EN_null, baton_EN_null)) +
  geom_abline(slope = 1, intercept = 0, colour = graphite, linetype = "dashed",
              linewidth = 0.65) +
  geom_point(aes(fill = exact), shape = 21, size = 4.5, colour = navy, stroke = 0.9,
             show.legend = FALSE) +
  scale_fill_manual(values = c(`TRUE` = navy, `FALSE` = blue)) +
  annotate("segment", x = worst$simon_EN_null - 0.15, xend = 12.8,
           y = worst$baton_EN_null + 0.35, yend = 21.2,
           colour = graphite, linewidth = 0.6) +
  annotate("text", x = 10.1, y = 23.1, label = sprintf("Largest gap\n+%.1f patients (+%.1f%%)",
           max(gap), 100 * (worst$EN_ratio - 1)), colour = navy,
           size = 5.2, family = "Archivo", hjust = 0, lineheight = 0.98) +
  annotate("text", x = 32.2, y = 11.3, label = "Dashed line: equal enrollment",
           colour = graphite, size = 4.8, family = "Archivo", hjust = 1) +
  scale_x_continuous(breaks = seq(10, 30, 5)) +
  scale_y_continuous(breaks = seq(10, 30, 5)) +
  coord_equal(xlim = c(9, 33), ylim = c(9, 33), expand = FALSE) +
  labs(x = "Expected patients · exact Simon design",
       y = "Expected patients · BATON") +
  theme_minimal(base_size = 18, base_family = "Archivo") +
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_line(colour = mist),
        axis.title = element_text(colour = navy, face = "bold"),
        axis.text = element_text(colour = graphite))

ggsave("images/fig_benchmark_paired_040.png", p, width = 6.5, height = 5.4,
       dpi = 250, bg = "white", device = ragg::agg_png)
cat(sprintf("Maximum extra enrollment: %.2f patients; exact matches: %d\n",
            max(gap), sum(d$exact)))
