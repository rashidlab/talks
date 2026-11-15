# make_fig_needle_haystack.R
# Illustrative grid and model-guided search diagrams for slides 18 and 20.
# The haystack shows 10^8 combinations of ten values for eight settings.
# The zoomed grid, starting sample and search path are schematics.
# The measured Scenario B comparison is maintained in the slide source.

navy  <- "#13294B"
blue  <- "#4B9CD3"
ink   <- "#1A202C"
muted <- "#5A6472"
gold  <- "#F2A900"
pal   <- colorRampPalette(c("#F0D2C6", "#FBF1DC", "#F3E9B8", "#5DB573"))(100)
top <- 6.35; bot <- 2.75; iw <- top - bot

# Map only (legend drawn separately, so the two figures can place it differently).
needle_map <- function(ix0, iy0, grid_slice = FALSE) {
  f <- function(u, v) {
    ridge <- 1.3 * exp(-(v - (0.30 + 0.50 * u))^2 / 0.003) * exp(-(u - 0.62)^2 / 0.07)
    decoy <- 0.5 * exp(-((u - 0.22)^2 + (v - 0.74)^2) / 0.008) +
      0.45 * exp(-((u - 0.80)^2 + (v - 0.22)^2) / 0.007)
    max(ridge, decoy)
  }
  n <- if (grid_slice) 10 else 26
  cell <- iw / n
  for (i in seq_len(n)) for (j in seq_len(n)) {
    u <- (i - 0.5) / n
    v <- (j - 0.5) / n
    score <- f(u, v)
    left <- ix0 + (i - 1) * cell
    bottom <- iy0 + (j - 1) * cell
    if (grid_slice) {
      feasible <- score >= 0.68
      fill <- if (feasible) "#87C99A" else "#F1EAE5"
      rect(left, bottom, left + cell, bottom + cell, col = fill, border = "white", lwd = 0.8)
      if (feasible && u >= 0.60 && u <= 0.75) {
        rect(left + 0.02, bottom + 0.02, left + cell - 0.02, bottom + cell - 0.02,
             border = navy, lwd = 3)
      }
    } else {
      k <- 1 + floor(99 * min(1, score))
      rect(left, bottom, left + cell, bottom + cell, col = pal[k], border = NA)
    }
  }
  rect(ix0, iy0, ix0 + iw, iy0 + iw, border = navy, lwd = 2)
}
legend_goals <- function(x, y) {
  rect(x, y - 0.15, x + 0.32, y + 0.15, col = "#87C99A", border = NA)
  text(x + 0.48, y, "Feasible", adj = 0, cex = 1.9, font = 2, col = navy)
  text(x + 0.48, y - 0.46, "Meets power and type I error targets", adj = 0, cex = 1.48, col = ink)
  y <- y - 1.34
  rect(x, y - 0.15, x + 0.32, y + 0.15, col = "#87C99A", border = navy, lwd = 3)
  text(x + 0.48, y, "Feasible with lower enrollment", adj = 0, cex = 1.8, font = 2, col = navy)
  text(x + 0.48, y - 0.46, "Fewer patients expected on average", adj = 0, cex = 1.48, col = ink)
}
header <- function(x, h, s, adj = 0.5) {
  text(x, 7.75, h, cex = 1.6, font = 2, col = blue, adj = adj)
  text(x, 7.1, s, cex = 2.2, font = 2, col = navy, adj = adj)
}

# ---- Figure 1: the haystack and the needle (no BATON yet) -----------------------
png("images/fig_needle_haystack.png", width = 3800, height = 1900, res = 300,
    type = "cairo", family = "Lato")
par(mar = c(0, 0, 0, 0), bg = "white")
plot.new(); plot.window(xlim = c(0.25, 15.6), ylim = c(0.35, 8.1), asp = 1)
set.seed(7)
h0 <- 0.45; hw <- 4.2; hc <- h0 + hw / 2
header(hc, "GRID SEARCH", "100,000,000 designs")
gx <- seq(h0 + 0.06, h0 + hw - 0.06, length.out = 58)
gy <- seq(bot + 0.06, top - 0.06, length.out = 50)
g <- expand.grid(x = gx, y = gy)
points(g$x + runif(nrow(g), -0.025, 0.025), g$y + runif(nrow(g), -0.025, 0.025),
       pch = 16, cex = 0.22, col = "#B7BDC5")
nx <- h0 + 3.1; ny <- 4.85; zs <- 0.3
rect(nx - zs, ny - zs, nx + zs, ny + zs, col = "white", border = navy, lwd = 2)
points(nx, ny, pch = 21, bg = gold, col = navy, cex = 1.6, lwd = 1.2)
text(hc, 2.25, "10 options for each of", cex = 1.8, col = muted)
text(hc, 1.65, "8 design choices, each tested", cex = 1.8, col = muted)
text(hc, 1.05, "on thousands of simulated trials", cex = 1.8, col = muted)
ix0 <- 6.0
segments(nx + zs, ny + zs, ix0, bot + iw, col = navy, lwd = 1.2, lty = 2)
segments(nx + zs, ny - zs, ix0, bot, col = navy, lwd = 1.2, lty = 2)
needle_map(ix0, bot, grid_slice = TRUE)
header(ix0 + iw / 2, "TWO-SETTING SLICE", "One design per cell")
text(ix0 - 0.34, bot + iw / 2, "Futility threshold", srt = 90,
     cex = 1.5, col = navy, font = 2)
text(ix0 + iw / 2, bot - 0.40, "Efficacy threshold", cex = 1.5, col = navy, font = 2)
text(ix0 + iw / 2, bot - 0.98, "Each cell pairs two values.", cex = 1.5, col = muted)
text(ix0 + iw / 2, bot - 1.51, "Other six settings held fixed.", cex = 1.5, col = muted)
legend_goals(ix0 + iw + 0.38, 5.55)
dev.off()

# ---- Figures 2 and 3: same design space, before and after fitting ------------
start_panel <- function(filename) {
  png(filename, width = 1380, height = 1380, res = 300,
      type = "cairo", family = "Lato")
  par(mar = c(0, 0, 0, 0), bg = "white", xaxs = "i", yaxs = "i")
  plot.new()
  plot.window(xlim = c(-0.07, iw + 0.07), ylim = c(-0.07, iw + 0.07), asp = 1)
}
set.seed(36)
strata <- (seq_len(13) - 0.5) / 13
initial_x <- iw * strata
initial_y <- iw * sample(strata)

start_panel("images/fig_needle_seed.png")
rect(0, 0, iw, iw, col = "#F4F6F8", border = navy, lwd = 2)
points(initial_x, initial_y, pch = 21, bg = muted, col = "white", cex = 2.1, lwd = 1.25)
dev.off()

start_panel("images/fig_needle_baton.png")
needle_map(0, 0)
points(initial_x, initial_y, pch = 21, bg = "#8C949C", col = "white", cex = 2.1, lwd = 1.25)

# The arrows connect five simulated design settings in order.
path <- rbind(c(0.13, 0.19), c(0.80, 0.25), c(0.23, 0.77),
              c(0.79, 0.73), c(0.66, 0.62))
x <- path[, 1] * iw
y <- path[, 2] * iw
for (i in seq_len(nrow(path) - 1)) {
  dx <- x[i + 1] - x[i]
  dy <- y[i + 1] - y[i]
  distance <- sqrt(dx^2 + dy^2)
  trim <- 0.17 / distance
  arrows(x[i] + dx * trim, y[i] + dy * trim,
         x[i + 1] - dx * trim, y[i + 1] - dy * trim,
         length = 0.11, angle = 25, col = navy, lwd = 5)
}
early <- seq_len(nrow(path) - 1)
points(x[early], y[early], pch = 21, bg = navy, col = "white", cex = 5.2, lwd = 2)
text(x[early], y[early], early, col = "white", font = 2, cex = 2.1)
points(tail(x, 1), tail(y, 1), pch = 23, bg = "#E07C24", col = navy, cex = 5.7, lwd = 2)
text(tail(x, 1), tail(y, 1), "5", col = navy, font = 2, cex = 2.1)
dev.off()
cat("Wrote images/fig_needle_haystack.png, images/fig_needle_seed.png and images/fig_needle_baton.png\n")
