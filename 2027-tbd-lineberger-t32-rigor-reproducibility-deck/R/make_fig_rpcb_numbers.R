# RP:CB three numbers. Source: Errington et al., eLife 2021 (10.7554/eLife.71601, 10.7554/eLife.67995). Citation is on the slide caption.
# 4 with public data are marked among all 193 planned dots, not inside the 50 completed block.
suppressPackageStartupMessages({ library(ggplot2) })
navy <- "#13294B"; car <- "#4B9CD3"; deep <- "#2E6A9F"; graph <- "#5B6670"; mist <- "#E6EAEF"; warm <- "#D55E00"
.a <- grep("--file=", commandArgs(FALSE), value = TRUE)
deck <- if (length(.a)) normalizePath(file.path(dirname(sub("--file=", "", .a[1])), "..")) else getwd()
dir.create(file.path(deck, "images"), showWarnings = FALSE)
fam <- if (nzchar(systemfonts::match_fonts("Archivo")$path[1])) "Archivo" else "sans"
mm <- function(pt) pt / 2.845   # point size to ggplot size
save_png <- function(p, f, w, h) ggsave(file.path(deck, "images", f), p, width = w, height = h, dpi = 200, bg = "white", device = ragg::agg_png)

n <- 193; ncol <- 25
g <- data.frame(k = 1:n); g$col <- (g$k - 1) %% ncol; g$row <- (g$k - 1) %/% ncol
pub <- c(79, 118, 151, 187)       # positions chosen for display only, the source gives the count (4 of 193)
g$grp <- ifelse(g$k %in% pub, "pub", ifelse(g$k <= 50, "done", "planned"))
w <- ncol - 1
nums <- data.frame(x = c(0.13, 0.5, 0.87) * w, n = c("193", "50", "4"),
  cap = c("experiments planned", "completed", "had the data public"), colr = c(graph, navy, warm))
p <- ggplot() +
  geom_text(data = nums, aes(x = x, y = 3.0, label = n, colour = colr), fontface = "bold", size = mm(80), family = fam) +
  geom_text(data = nums, aes(x = x, y = -0.2, label = cap, colour = colr), size = mm(20), family = fam) +
  geom_point(data = g[g$grp %in% c("done", "planned"), ], aes(col, -row - 1.5, fill = grp), shape = 21, size = 5.4, colour = "white", stroke = 0.4) +
  geom_point(data = g[g$grp == "pub", ], aes(col, -row - 1.5), shape = 21, size = 7.6, fill = warm, colour = navy, stroke = 1) +
  scale_fill_manual(values = c(done = navy, planned = mist)) + scale_colour_identity() +
  scale_x_continuous(limits = c(-1.2, w + 1.2)) + scale_y_continuous(limits = c(-9.8, 4.6)) +
  theme_void(base_size = 11) + theme(legend.position = "none", plot.margin = margin(2, 6, 2, 6))
save_png(p, "fig_rpcb_numbers.png", 11, 4.8)
