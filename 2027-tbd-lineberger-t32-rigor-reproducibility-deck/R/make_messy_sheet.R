# Messy lab sheet (xlsx), its tidy version (csv), and a drawn-grid PNG of the messy sheet.
suppressPackageStartupMessages({ library(ggplot2); library(openxlsx); library(data.table) })
.a <- grep("--file=", commandArgs(FALSE), value = TRUE)
deck <- if (length(.a)) normalizePath(file.path(dirname(sub("--file=", "", .a[1])), "..")) else getwd()
res <- normalizePath(file.path(deck, "..", "rigor-reproducibility-resources"), mustWork = FALSE)
dir.create(file.path(res, "examples"), recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(deck, "images"), showWarnings = FALSE)
navy <- "#13294B"
YEL <- "#FFE699"; GRN <- "#C6E0B4"; HDR <- "#D9D9D9"

# ---- raw content, as typed ----
mice <- data.frame(
  mouse = c("M01","M02","M03","M04","M05","M06","M07"),
  group = c("Control","Control","Control","Treated","Treated","Treated","Treated"),
  date  = c("3/4/25","2025-03-04","March 4","3/4/25","2025-03-04","March 5","3/5/25"),
  d0 = c("12.3 mm3","11.8 mm3","","13.0 mm3","12.1 mm3","10.9 mm3",""),
  d7 = c("45.1 mm3","50.4","38.0 mm3","20.2 mm3","18.9 mm3","15.6 mm3","17.2 mm3"),
  d14 = c("130.2 mm3","141.9 mm3","","22.5 mm3","","19.8 mm3","24.0 mm3"),
  gene = c("TP53","MYC","KRAS","SEPT2","KRAS","MYC","TP53"),
  note = c("","re-measured","found dead before d14","bad injection?","","dose 2x?",""),
  stringsAsFactors = FALSE)
excluded_mouse <- "M04"; remeasured <- list(c("M02", "d7"))
# tidy-sheet blank meanings
reason <- list(M03_d0 = "not_measured", M03_d14 = "died", M05_d14 = "not_measured", M07_d0 = "below_detection")
mice$d0[mice$mouse == "M03"] <- ""   # kept blank on purpose
num <- function(s) suppressWarnings(as.numeric(sub(" mm3", "", s)))
m <- function(col) { v <- num(mice[[col]]); mean(v, na.rm = TRUE) }
totals <- c("Mean", "", "", sprintf("%.1f", m("d0")), sprintf("%.1f", m("d7")), sprintf("%.1f", m("d14")), "", "")
# layout: row order with the totals row inside the data (after M05)
body <- rbind(mice[1:5, ], NA, mice[6:7, ])

# ---- xlsx ----
wb <- createWorkbook(); addWorksheet(wb, "Sheet1")
hs <- createStyle(textDecoration = "bold", fgFill = HDR, halign = "center", valign = "center", border = "TopBottomLeftRight")
writeData(wb, 1, "Mouse", startCol = 1, startRow = 1); mergeCells(wb, 1, cols = 1, rows = 1:2)
writeData(wb, 1, "Group", startCol = 2, startRow = 1); mergeCells(wb, 1, cols = 2, rows = 1:2)
writeData(wb, 1, "Date", startCol = 3, startRow = 1); mergeCells(wb, 1, cols = 3, rows = 1:2)
writeData(wb, 1, "Tumor volume", startCol = 4, startRow = 1); mergeCells(wb, 1, cols = 4:6, rows = 1)
writeData(wb, 1, t(c("Day 0", "Day 7", "Day 14")), startCol = 4, startRow = 2, colNames = FALSE)
writeData(wb, 1, "Marker", startCol = 7, startRow = 1); mergeCells(wb, 1, cols = 7, rows = 1:2)
writeData(wb, 1, "Notes", startCol = 8, startRow = 1); mergeCells(wb, 1, cols = 8, rows = 1:2)
addStyle(wb, 1, hs, rows = 1:2, cols = 1:8, gridExpand = TRUE)
for (i in seq_len(nrow(body))) {
  r <- 2 + i
  if (i == 6) {  # totals row
    for (j in 1:8) if (totals[j] != "") writeData(wb, 1, if (j %in% 4:6) as.numeric(totals[j]) else totals[j], startCol = j, startRow = r)
    addStyle(wb, 1, createStyle(textDecoration = "bold"), rows = r, cols = 1:8, gridExpand = TRUE)
    next }
  for (j in 1:8) {
    v <- body[i, j]
    if (is.na(v) || v == "") next
    if (j == 7 && v == "SEPT2") {   # what Excel does to SEPT2
      writeData(wb, 1, as.Date("2025-09-02"), startCol = j, startRow = r)
      addStyle(wb, 1, createStyle(numFmt = "d-mmm"), rows = r, cols = j, stack = TRUE)
    } else writeData(wb, 1, v, startCol = j, startRow = r)
  }
  if (body$mouse[i] == excluded_mouse) addStyle(wb, 1, createStyle(fgFill = YEL), rows = r, cols = 1:8, gridExpand = TRUE, stack = TRUE)
  if (body$mouse[i] == "M02") addStyle(wb, 1, createStyle(fgFill = GRN), rows = r, cols = 5, stack = TRUE)
}
setColWidths(wb, 1, cols = 1:8, widths = c(8, 10, 12, 11, 11, 11, 9, 24))
xf <- file.path(res, "examples", "messy-sheet.xlsx")
saveWorkbook(wb, xf, overwrite = TRUE)
# openxlsx leaves dangling drawing relationships (no drawing part is written); strip them so openpyxl loads the file.
tmpd <- tempfile(); dir.create(tmpd); unzip(xf, exdir = tmpd)
rl <- file.path(tmpd, "xl", "worksheets", "_rels", "sheet1.xml.rels")
txt <- readLines(rl, warn = FALSE)
txt <- gsub('<Relationship [^>]*relationships/(drawing|vmlDrawing)"[^>]*/>', "", txt)
writeLines(txt, rl)
old_wd <- setwd(tmpd); on.exit(setwd(old_wd), add = TRUE)
unlink(xf); zip(xf, files = list.files(".", recursive = TRUE, all.files = TRUE), flags = "-X -q")
setwd(old_wd)

# tidy-sheet.csv is produced by examples/recipe.R from the messy sheet (not written here).

# ---- drawn grid (a SUBSET of the xlsx: rows M01-M05 plus the Mean row, 7 of 8 columns, no Group column) ----
# Inch coordinates on an 11 x 4.8 canvas. Smallest text 14 pt (about 22 px at 1280 px display).
fam <- if (nzchar(systemfonts::match_fonts("Archivo")$path[1])) "Archivo" else "sans"
mm <- function(pt) pt / 2.845
sub_rows <- body[c(1:4, 6, 5), ]                 # M01..M04, the Mean row, M05
sub_cols <- c(1, 3, 4, 5, 6, 7, 8)               # Mouse, Date, Day 0, Day 7, Day 14, Marker, Notes
cwi <- c(0.85, 1.45, 1.35, 1.35, 1.4, 1.0, 2.2)  # inches; gutter 0.5 + sum = 10.1, scaled to fill 11
gut <- 0.5; sc <- (11 - gut) / sum(cwi); cwi <- cwi * sc
x0 <- gut + c(0, cumsum(cwi))[1:7]
rowh <- (4.8 - 0.4) / 8; top <- 4.8 - 0.4              # 0.4 in column-letter strip, 8 rows
cells <- list()
add <- function(r1, r2, c1, c2, lab, fill = "white", bold = FALSE)
  cells[[length(cells) + 1]] <<- data.frame(xmin = x0[c1], xmax = x0[c2] + cwi[c2], ymax = top - (r1 - 1) * rowh, ymin = top - r2 * rowh, lab = lab, fill = fill, bold = bold, stringsAsFactors = FALSE)
add(1, 2, 1, 1, "Mouse", HDR, TRUE); add(1, 2, 2, 2, "Date", HDR, TRUE); add(1, 1, 3, 5, "Tumor volume", HDR, TRUE)
add(2, 2, 3, 3, "Day 0", HDR, TRUE); add(2, 2, 4, 4, "Day 7", HDR, TRUE); add(2, 2, 5, 5, "Day 14", HDR, TRUE)
add(1, 2, 6, 6, "Marker", HDR, TRUE); add(1, 2, 7, 7, "Notes", HDR, TRUE)
for (i in seq_len(nrow(sub_rows))) {
  r <- 2 + i; row <- sub_rows[i, ]
  if (is.na(row$mouse)) { tt <- c("Mean", "", totals[4:6], "", ""); for (j in 1:7) add(r, r, j, j, tt[j], "white", TRUE); next }
  rf <- if (row$mouse == excluded_mouse) YEL else "white"
  vals <- as.character(unlist(row[sub_cols])); vals[vals == "SEPT2"] <- "2-Sep"; vals[is.na(vals)] <- ""
  for (j in 1:7) add(r, r, j, j, vals[j], if (row$mouse == "M02" && j == 4) GRN else rf)
}
d <- do.call(rbind, cells); d$xm <- (d$xmin + d$xmax) / 2; d$ym <- (d$ymin + d$ymax) / 2
g <- data.frame(xmin = 0, xmax = gut, ymax = top - (0:7) * rowh, ymin = top - (1:8) * rowh, lab = as.character(1:8))
cl <- data.frame(xmin = x0, xmax = x0 + cwi, lab = LETTERS[1:7], ymin = top, ymax = 4.8)
p <- ggplot() +
  geom_rect(data = d, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = fill), colour = "#B8B8B8", linewidth = 0.3) +
  geom_text(data = d, aes(xm, ym, label = lab, fontface = ifelse(bold, "bold", "plain")), colour = "black", size = mm(14), family = fam) +
  geom_rect(data = g, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), fill = "#F0F0F0", colour = "#B8B8B8", linewidth = 0.3) +
  geom_text(data = g, aes(x = (xmin + xmax) / 2, y = (ymin + ymax) / 2, label = lab), colour = "#707070", size = mm(14), family = fam) +
  geom_rect(data = cl, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), fill = "#F0F0F0", colour = "#B8B8B8", linewidth = 0.3) +
  geom_text(data = cl, aes(x = (xmin + xmax) / 2, y = (ymin + ymax) / 2, label = lab), colour = "#707070", size = mm(14), family = fam) +
  scale_fill_identity() + coord_cartesian(xlim = c(0, 11), ylim = c(0, 4.8), expand = FALSE) +
  theme_void(base_size = 11) + theme(plot.margin = margin(0, 0, 0, 0))
ggsave(file.path(deck, "images", "fig_messy_sheet.png"), p, width = 11, height = 4.8, dpi = 200, bg = "white", device = ragg::agg_png)
