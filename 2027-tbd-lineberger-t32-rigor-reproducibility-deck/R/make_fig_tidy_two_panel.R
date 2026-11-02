# Wide lab sheet (left) to long tidy table (right), drawn in inch coordinates. Smallest text 13 pt (about 20 px at 1280 display).
suppressPackageStartupMessages({ library(ggplot2) })
navy <- "#13294B"; car <- "#4B9CD3"; deep <- "#2E6A9F"; graph <- "#5B6670"; mist <- "#E6EAEF"; warm <- "#D55E00"
.a <- grep("--file=", commandArgs(FALSE), value = TRUE)
deck <- if (length(.a)) normalizePath(file.path(dirname(sub("--file=", "", .a[1])), "..")) else getwd()
dir.create(file.path(deck, "images"), showWarnings = FALSE)
fam <- if (nzchar(systemfonts::match_fonts("Archivo")$path[1])) "Archivo" else "sans"
mm <- function(pt) pt / 2.845   # point size to ggplot size
save_png <- function(p, f, w, h) ggsave(file.path(deck, "images", f), p, width = w, height = h, dpi = 200, bg = "white", device = ragg::agg_png)

cell <- function(x0, x1, yc, h, lab, fill = "white", col = navy, bold = FALSE, bord = "#B8C0C8")
  data.frame(xm = (x0 + x1) / 2, w = x1 - x0, y = yc, h = h, lab = lab, fill = fill, col = col, bold = bold, bord = bord, stringsAsFactors = FALSE)
flagf <- "#FBE3D1"; gh <- "#F2F4F6"; rh <- 0.46
L <- list(); add <- function(z) L[[length(L) + 1]] <<- z
ex <- c(0.1, 0.95, 1.8, 2.65, 3.5, 4.7)
add(cell(ex[1], ex[2], 3.9, 0.6, "", gh))
add(cell(ex[2], ex[4] + 0.85, 3.9, 0.6, "Treatment A /\nTreatment B", flagf, warm, TRUE, warm))
add(cell(ex[5], ex[6], 3.9, 0.6, "", gh))
hd <- c("sample", "Day0", "Day7", "Day14", "note")
for (j in 1:5) add(cell(ex[j], ex[j + 1], 3.37, rh, hd[j], gh, navy, TRUE))
vals <- rbind(c("S1", "12", "45", "130", ""), c("S2", "11", "50", "142", ""),
              c("S3", "10", "38", "died", "mouse 3 ??"), c("S4", "12", "46", "128", ""))
for (r in 1:4) for (j in 1:5) {
  v <- vals[r, j]; bad <- v %in% c("died", "mouse 3 ??")
  add(cell(ex[j], ex[j + 1], 3.37 - rh * r, rh, v, if (bad) flagf else "white", if (bad) warm else navy, FALSE, if (bad) warm else "#B8C0C8")) }
rx <- c(5.85, 6.95, 8.1, 8.7, 10.65)
nm <- c("sample_id", "treatment", "day", "tumor_volume_mm3")
for (k in 1:4) add(cell(rx[k], rx[k + 1], 3.97, rh, nm[k], gh, navy, TRUE))
td <- data.frame(id = c("S1","S1","S1","S2","S2","S2"), tr = "A", day = c(0,7,14,0,7,14), v = c(12,45,130,11,50,142))
for (r in 1:6) { vv <- c(td$id[r], td$tr[r], td$day[r], td$v[r])
  for (k in 1:4) add(cell(rx[k], rx[k + 1], 3.97 - rh * r, rh, vv[k], "white", navy)) }
add(cell(rx[1], rx[5], 3.97 - rh * 7, rh, "...", "white", graph, TRUE))
d <- do.call(rbind, L)
p <- ggplot(d) +
  geom_tile(aes(xm, y, width = w, height = h, fill = fill, colour = bord), linewidth = 0.35) +
  geom_text(aes(xm, y, label = lab, colour = col, fontface = ifelse(bold, "bold", "plain")), size = mm(13), lineheight = 0.95, family = fam) +
  annotate("segment", x = 4.9, xend = 5.6, y = 2.2, yend = 2.2, colour = navy, linewidth = 1.5, arrow = arrow(length = unit(0.2, "in"), type = "closed")) +
  annotate("text", x = 2.4, y = 4.55, label = "How it is typed", colour = navy, fontface = "bold", size = mm(17), family = fam) +
  annotate("text", x = 8.25, y = 4.55, label = "How the computer wants it", colour = navy, fontface = "bold", size = mm(17), family = fam) +
  scale_fill_identity() + scale_colour_identity() +
  coord_cartesian(xlim = c(0, 11), ylim = c(0, 4.8), expand = FALSE) +
  theme_void(base_size = 11) + theme(plot.margin = margin(0, 0, 0, 0))
save_png(p, "fig_tidy_two_panel.png", 11, 4.8)
