# Effort over project time, schematic. Same total area for both curves.
suppressPackageStartupMessages({ library(ggplot2) })
navy <- "#13294B"; car <- "#4B9CD3"; deep <- "#2E6A9F"; graph <- "#5B6670"; mist <- "#E6EAEF"; warm <- "#D55E00"
.a <- grep("--file=", commandArgs(FALSE), value = TRUE)
deck <- if (length(.a)) normalizePath(file.path(dirname(sub("--file=", "", .a[1])), "..")) else getwd()
dir.create(file.path(deck, "images"), showWarnings = FALSE)

x <- seq(0, 1, length.out = 400)
usual <- 0.25 + 2.6 * exp(-((x - 0.92) / 0.08)^2)
repro <- 0.25 + 1.5 * exp(-((x - 0.2) / 0.16)^2)
ar <- function(y) sum(y) * (x[2] - x[1])
repro <- repro * ar(usual) / ar(repro)
d <- rbind(data.frame(x = x, y = usual, g = "usual"), data.frame(x = x, y = repro, g = "repro"))
p <- ggplot(d, aes(x, y, colour = g, fill = g)) +
  geom_area(position = "identity", alpha = 0.12, colour = NA) +
  geom_line(linewidth = 1.6) +
  geom_hline(yintercept = 0, colour = "#C9CFD6", linewidth = 0.3) +
  scale_colour_manual(values = c(usual = warm, repro = deep)) + scale_fill_manual(values = c(usual = warm, repro = deep)) +
  annotate("text", x = 0.80, y = 2.62, label = "the usual way\neffort piles up just before submission", hjust = 1, colour = warm, fontface = "bold", size = 4.2, lineheight = 1.0) +
  annotate("text", x = 0.34, y = 1.95, label = "the reproducible way\nmore effort at the start, a flat finish", hjust = 0, colour = deep, fontface = "bold", size = 4.2, lineheight = 1.0) +
  annotate("text", x = 1, y = -0.22, label = "schematic", hjust = 1, colour = "#8A939C", size = 3.2) +
  scale_x_continuous(breaks = c(0.04, 0.96), labels = c("start of project", "submission"), expand = expansion(mult = c(0.01, 0.01))) +
  scale_y_continuous(breaks = NULL) + coord_cartesian(ylim = c(-0.3, 3.0)) +
  labs(x = NULL, y = "effort") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "none", panel.grid.minor = element_blank(), panel.grid.major = element_blank(),
        axis.title.y = element_text(colour = navy, face = "bold", size = 13),
        axis.text.x = element_text(colour = navy, face = "bold", size = 13),
        plot.margin = margin(6, 12, 6, 6))
ggsave(file.path(deck, "images", "fig_time_moves.png"), p, width = 11, height = 3.4, dpi = 200, bg = "white")
