# Duke timeline, four points. Years only. Smallest text 15 pt (about 24 px at 1280 px display).
suppressPackageStartupMessages({ library(ggplot2) })
navy <- "#13294B"; car <- "#4B9CD3"; deep <- "#2E6A9F"; graph <- "#5B6670"; mist <- "#E6EAEF"; warm <- "#D55E00"
.a <- grep("--file=", commandArgs(FALSE), value = TRUE)
deck <- if (length(.a)) normalizePath(file.path(dirname(sub("--file=", "", .a[1])), "..")) else getwd()
dir.create(file.path(deck, "images"), showWarnings = FALSE)
fam <- if (nzchar(systemfonts::match_fonts("Archivo")$path[1])) "Archivo" else "sans"
mm <- function(pt) pt / 2.845   # point size to ggplot size
save_png <- function(p, f, w, h) ggsave(file.path(deck, "images", f), p, width = w, height = h, dpi = 200, bg = "white", device = ragg::agg_png)

ev <- data.frame(x = c(2006, 2009, 2010, 2011),
  year = c("2006", "2009", "2010", "2011"),
  body = c("Nature Medicine paper\npublished",
           "Baggerly and Coombes publish\ntheir reconstruction,\ntrials suspended",
           "Duke review finds the errors\ndid not affect the findings,\ntrials restart",
           "Nature Medicine paper\nretracted"),
  up = c(TRUE, FALSE, TRUE, FALSE))
ev$s <- ifelse(ev$up, 1, -1)
p <- ggplot(ev) +
  annotate("segment", x = 2005.5, xend = 2011.9, y = 0, yend = 0, colour = navy, linewidth = 1.6) +
  geom_segment(aes(x = x, xend = x, y = 0, yend = s * 0.32), colour = graph, linewidth = 0.5) +
  geom_point(aes(x = x, y = 0), shape = 21, size = 7, fill = "white", colour = navy, stroke = 1.8) +
    geom_text(aes(x = x, y = s * 0.4, label = year, vjust = ifelse(up, 0, 1)), colour = navy, fontface = "bold", size = mm(22), family = fam) +
  geom_text(aes(x = x, y = s * 0.82, label = body, vjust = ifelse(up, 0, 1)), colour = navy, size = mm(16), lineheight = 1.0, family = fam) +
  scale_x_continuous(limits = c(2005.1, 2012.3)) + scale_y_continuous(limits = c(-1.5, 1.5)) +
  theme_void(base_size = 11) + theme(plot.margin = margin(2, 4, 2, 4))
save_png(p, "fig_duke_timeline.png", 11, 3.4)
