# Ladder of four ways to make an analysis rerunnable. Smallest text 14.5 pt.
suppressPackageStartupMessages({ library(ggplot2) })
navy <- "#13294B"; car <- "#4B9CD3"; deep <- "#2E6A9F"; graph <- "#5B6670"; mist <- "#E6EAEF"; warm <- "#D55E00"
.a <- grep("--file=", commandArgs(FALSE), value = TRUE)
deck <- if (length(.a)) normalizePath(file.path(dirname(sub("--file=", "", .a[1])), "..")) else getwd()
dir.create(file.path(deck, "images"), showWarnings = FALSE)
fam <- if (nzchar(systemfonts::match_fonts("Archivo")$path[1])) "Archivo" else "sans"
mm <- function(pt) pt / 2.845   # point size to ggplot size
save_png <- function(p, f, w, h) ggsave(file.path(deck, "images", f), p, width = w, height = h, dpi = 200, bg = "white", device = ragg::agg_png)

d <- data.frame(i = 1:4,
  lab = c("A script instead of clicking", "Figures made by the code", "Version control and a DOI", "The same environment every time"),
  sub = c("R or Python file you can rerun", "Quarto or a notebook", "GitHub plus Zenodo", "renv, conda, containers, pipelines"),
  fill = c("#E6EAEF", "#9CC5E4", "#2E6A9F", "#13294B"), txt = c(navy, navy, "white", "white"))
d$x0 <- 0.1 + (d$i - 1) * 0.8; d$x1 <- d$x0 + 4.5; d$yc <- 0.55 + (d$i - 1) * 1.23
p <- ggplot(d) +
  geom_rect(aes(xmin = x0, xmax = x1, ymin = yc - 0.4, ymax = yc + 0.4, fill = fill), colour = navy, linewidth = 0.4) +
  geom_text(aes(x = x0 + 0.2, y = yc, label = lab, colour = txt), hjust = 0, fontface = "bold", size = mm(16), family = fam) +
  geom_text(aes(x = x1 + 0.2, y = yc, label = sub), hjust = 0, colour = graph, size = mm(14.5), family = fam) +
  scale_fill_identity() + scale_colour_identity() +
  coord_cartesian(xlim = c(0, 11), ylim = c(0, 4.8), expand = FALSE) +
  theme_void(base_size = 11) + theme(plot.margin = margin(0, 0, 0, 0))
save_png(p, "fig_four_ways.png", 11, 4.8)
