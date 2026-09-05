# Every science figure on this deck, drawn from the same locked artifacts the two manuscripts
# read. No simulation runs here and no value is typed.
#
# ONE RULE THROUGHOUT. In-figure text sits at or above the profile's 16pt-equivalent floor, which
# is about 24px in a 1920-wide render, and every axis is labelled in words rather than in the
# articles' notation. Manuscript figures are re-drawn from their sources at these sizes rather
# than pasted, because a manuscript figure shrunk onto a slide puts its axis labels under the
# floor.
#
# WHAT THE QUARANTINED ARTIFACT COSTS THIS DECK, stated rather than worked around. The framework
# article's attainable-frontier panel A reads `phase_d_boin_safety`, whose producing package state
# could not be established, and `artifact()` refuses it. The domain figure below therefore draws
# only the two quantities that are verified, the exhaustive pass and the expanded-domain best
# found, and the deck makes no claim resting on the quarantined frontier.

BATOND_REPO <- Sys.getenv("BATOND_PAPER_REPO",
                          path.expand("~/research/trials-research/baton-dosefinding"))
Sys.setenv(BATOND_PAPER_REPO = BATOND_REPO)
# RUN FROM THE DECK DIRECTORY. `numbers.R` sits there and the images belong beside it.
OUT <- file.path(getwd(), "images")
stopifnot(file.exists("numbers.R"))
dir.create(OUT, showWarnings = FALSE)

source("numbers.R")

navy <- "#13294B"; car <- "#4B9CD3"; cdeep <- "#2E6A9F"
graphite <- "#5B6670"; fog <- "#F4F6F8"; mist <- "#E6EAEF"; orange <- "#E07C24"
# GOLD IS RESERVED FOR UNRESOLVED, which is neither met nor not met and must never be drawn in
# the colour of either verdict.
gold <- "#B07D00"

# 1920-wide renders. `res` carries the font scaling, so `cex` values stay readable numbers.
png2 <- function(file, w = 1920, h = 1080, res = 150) {
  grDevices::png(file.path(OUT, file), width = w, height = h, res = res, type = "cairo",
                 bg = "white")
}

## ---- 1. The two frozen dose-response truths, drawn as the teaching figure ---------------
## The plateau panel is where the room learns that the highest tolerable dose need not be the
## best dose. Truths come through BATOND's own `truth()` derivation, and the marked targets are
## asserted, exactly as `scripts/fig_scenario_truths.R` does it, so a moved scenario stops the
## build rather than mislabelling a slide.
suppressMessages(pkgload::load_all(file.path("~", "research", "BATOND"), quiet = TRUE))
.src <- readLines(file.path(BATOND_REPO, "scripts", "phase_d_families.R"))
.end <- grep('^beat\\("starting"\\)$', .src)
stopifnot(length(.end) == 1L)
.defs <- tempfile(fileext = ".R"); writeLines(.src[seq_len(.end - 1L)], .defs)
owd <- getwd(); setwd(BATOND_REPO); source(.defs); TR <- mk_truths(); setwd(owd)
stopifnot(identical(TR$OBD_plateau$mtd_set, 3L), identical(TR$OBD_plateau$obd_utility_set, 2L),
          identical(TR$OBD_monotone$mtd_set, 3L), identical(TR$OBD_monotone$obd_utility_set, 3L))
PHI <- TR$OBD_plateau$phi

##
## REVISED 2026-09-05 against the owner review, item 6. Four changes, all inside the artwork.
## The panel headers now say what happens to the patient rather than what happens to the curve.
## The two curves carry their own large direct labels in their own colours, so blue reading as
## benefit and orange reading as harm is stated at projection size rather than inferred from
## small annotations. The toxicity limit is the heaviest line on the panel. And each panel
## carries a callout stating its lesson, with the arithmetic COMPUTED from the truth rather
## than paraphrased.
##
## THE REVIEW'S OWN CALLOUT WORDING WAS "same benefit and less harm" AND THE TRUTH DOES NOT SAY
## THAT. Dose 3 carries two points more benefit than dose 2, not the same benefit, alongside
## twelve points more harm. The figure states both numbers and lets the comparison land on its
## own, because a callout the audience could refute by reading the panel behind it is worse
## than no callout.
tg_lesson <- function(nm) {
  t <- TR[[nm]]; m <- t$mtd_set; o <- t$obd_utility_set
  if (identical(m, o)) {
    c(paste0("Here, dose ", o, " is the better dose"),
      "It is also the highest tolerable dose")
  } else {
    d_eff <- t$p_eff[m] - t$p_eff[o]; d_tox <- t$p_tox[m] - t$p_tox[o]
    # ASSERTED. The callout claims the step up buys less benefit than it costs in harm.
    stopifnot(d_eff > 0, d_tox > 0, d_tox > d_eff)
    c(paste0("Here, dose ", o, " is the better dose"),
      paste0("Dose ", m, " adds ", round(100 * d_eff), " points of benefit and ",
             round(100 * d_tox), " points of harm"))
  }
}

truth_panel <- function(nm, title) {
  t <- TR[[nm]]; D <- length(t$p_tox); x <- seq_len(D)
  # THE RIGHT MARGIN INSIDE THE PANEL CARRIES THE DIRECT LABELS. Set on the data scale rather
  # than in the device margin so the labels sit beside the curve ends they name.
  par(mar = c(8.6, 5.6, 3.6, 1.0), cex.axis = 1.4, cex.main = 1.95)
  plot(NA, xlim = c(0.7, D + 2.5), ylim = c(0, 0.95), xaxt = "n", yaxt = "n",
       xlab = "", ylab = "", main = title, col.main = navy, font.main = 2)
  axis(1, at = x, cex.axis = 1.5, col.axis = navy)
  axis(2, at = seq(0, 0.8, 0.2), cex.axis = 1.35, col.axis = navy)
  mtext("Dose level", side = 1, line = 3.2, cex = 1.5, col = navy)
  mtext("Chance in one patient", side = 2, line = 3.3, cex = 1.45, col = navy)
  # THE LIMIT IS THE HEAVIEST LINE ON THE PANEL, per the review.
  abline(h = PHI, lty = 2, lwd = 5, col = navy)
  text(D + 2.45, PHI - 0.065, "Toxicity limit", cex = 1.4, col = navy, font = 2, adj = 1)
  lines(x, t$p_tox, lwd = 5, type = "b", pch = 19, cex = 2.0, col = orange)
  lines(x, t$p_eff, lwd = 5, type = "b", pch = 17, cex = 2.0, col = cdeep)
  text(D + 0.25, t$p_eff[D], "Benefit", col = cdeep, cex = 1.75, adj = 0, font = 2)
  text(D + 0.25, t$p_tox[D], "Serious\ntoxicity", col = orange, cex = 1.75, adj = 0, font = 2)
  m <- t$mtd_set; o <- t$obd_utility_set
  points(m, t$p_tox[m], pch = 1, cex = 3.8, lwd = 3.5, col = navy)
  text(m, t$p_tox[m] - 0.115, "highest\ntolerable", cex = 1.3, col = navy, font = 2)
  points(o, t$p_eff[o], pch = 5, cex = 3.8, lwd = 3.5, col = navy)
  text(o, t$p_eff[o] + 0.145, "best dose", cex = 1.3, col = navy, font = 2)
  L <- tg_lesson(nm)
  mtext(L[1], side = 1, line = 5.2, cex = 1.55, col = navy, font = 2)
  mtext(L[2], side = 1, line = 6.9, cex = 1.35, col = graphite)
}
png2("fig_targets.png", w = 2000, h = 900, res = 150)
par(mfrow = c(1, 2))
truth_panel("OBD_plateau",  "More dose stops helping")
truth_panel("OBD_monotone", "More dose keeps helping")
dev.off()

## ---- 2. Where a forwarded dose lands, and what the next trial concludes ------------------
## REBUILT 2026-09-05 against the owner review, item 31. The review offered two routes, two
## mini-panels or keeping the single grouped bar chart with all but two comparisons greyed out.
##
## THE MINI-PANELS ARE THE ONLY ROUTE THE DATA SUPPORTS, and the reason is not aesthetic. The
## sentence the review wants the figure to carry is that choosing too low and choosing too high
## have DIFFERENT downstream consequences. The old chart plotted one quantity, confirmation, in
## which both errors simply look like a lower bar. One quantity cannot show two different
## consequences, so no amount of greying makes that chart say the sentence. The two consequences
## are two different quantities and they sit in two different columns of `WF$dose_agg`, so each
## gets its own panel. Too low costs confirmation. Too high causes the next trial to stop for
## toxicity. `p_toxicity` is `mean(arm$reason == "toxicity")` in
## `scripts/phase2_workflow_factorial.R`, the rate at which the confirmatory arm stops for
## toxicity, so the second axis is labelled exactly that.
##
## BOTH DIRECTIONS ARE ALREADY ASSERTED IN `numbers.R`, for every scenario, which is what
## licenses a fixed headline over each panel.
pos_scen <- c("OBD_plateau", "OBD_monotone", "OBD_cliff", "SENS_low", "SENS_steep")
scen_lab <- c(OBD_plateau = "Response\nlevels off", OBD_monotone = "Response\nkeeps rising",
              OBD_cliff = "Low doses\ninactive", SENS_low = "Best dose\nis lowest",
              SENS_steep = "Toxicity rises\nsteeply")
pos_mat <- function(col, rows) sapply(pos_scen, function(s)
  vapply(rows, function(p) wf_pos_avg(s, p, col), numeric(1)))
M_low  <- pos_mat("confirmed", c("at", "below"))
M_high <- pos_mat("toxicity",  c("at", "above"))
# ASSERTED. Each panel's headline is a claim about every column it draws.
stopifnot(all(M_low["at", ] >= M_low["below", ], na.rm = TRUE),
          all(M_high["above", ] > M_high["at", ]))
# SENS_low HAS NO DOSE BELOW ITS BEST DOSE, so its left-panel comparison does not exist. The
# panel keeps the column and says so, because a silently missing bar reads as a zero.
pos_absent <- is.na(M_low["below", ])
stopifnot(identical(unname(which(pos_absent)), 4L))

pos_panel <- function(M, cols, head1, head2, ylab, keys) {
  par(mar = c(5.4, 6.2, 5.2, 1.0))
  bp <- barplot(M, beside = TRUE, ylim = c(0, 1.32), col = cols, border = NA,
                names.arg = rep("", ncol(M)), axes = FALSE)
  axis(2, at = seq(0, 1, 0.25), cex.axis = 1.3, col.axis = navy)
  mtext(ylab, side = 2, line = 3.1, cex = 1.35, col = navy)
  mtext(head1, side = 3, line = 2.7, cex = 1.75, col = navy, font = 2)
  mtext(head2, side = 3, line = 0.8, cex = 1.35, col = graphite)
  mtext(scen_lab[pos_scen], side = 1, at = colMeans(bp), line = 2.4, cex = 1.15, col = navy)
  v <- as.vector(M)
  # THREE DIGITS BELOW ONE PERCENT, because the whole point of the inactive-low-doses column is
  # that it is 0.004 rather than 0.00, and two digits would erase the finding. A tiny bar's
  # label is left-anchored on the bar so it runs into the empty space rather than back across
  # its neighbour.
  small <- !is.na(v) & v < 0.01
  lab <- vapply(v, function(z) if (is.na(z)) "" else
    formatC(z, format = "f", digits = if (z < 0.01) 3L else 2L), character(1))
  y <- ifelse(is.na(v), 0, v) + 0.05
  text(as.vector(bp)[!small], y[!small], lab[!small], cex = 1.25, col = navy)
  text(as.vector(bp)[small] - 0.15, y[small], lab[small], cex = 1.25, col = navy, adj = 0)
  # THE KEY SITS ABOVE EVERY BAR AND CARRIES ITS OWN SWATCH, so no colour has to be carried
  # from a corner of the panel back to the data.
  kx <- c(mean(bp[, 2]), mean(bp[, 4])); ky <- 1.21
  rect(kx - 0.62, ky - 0.055, kx - 0.22, ky + 0.055, col = cols, border = NA)
  text(kx - 0.10, ky, keys, cex = 1.4, col = navy, font = 2, adj = 0)
  bp
}
png2("fig_position.png", w = 2000, h = 900, res = 150)
par(mfrow = c(1, 2), cex.axis = 1.3)
bpA <- pos_panel(M_low, c(navy, car), "If the dose is too low",
                 "the next trial is less likely to confirm the drug",
                 "Chance the next trial\nconfirms the drug works",
                 c("right dose", "too low"))
text(bpA[2, which(pos_absent)], 0.22, "no\nlower\ndose", cex = 1.15, col = graphite)
bpB <- pos_panel(M_high, c(navy, orange), "If the dose is too high",
                 "the next trial is more likely to stop for toxicity",
                 "Chance the next trial\nstops for toxicity",
                 c("right dose", "too high"))
dev.off()

## ---- 3. Confirming, and confirming at the right dose -------------------------------------
## The headline cell of the pre-pivot factorial under the single-arm structure, where the
## forwarded dose is the selected dose and no carrying rule intervenes.
## REVISED 2026-09-05 against the owner review, item 32. Decimals become percentages and the
## gap becomes percentage points, which is the unit the review says a generalist processes
## fastest. The two bar labels are the review's own wording.
##
## THE THREE ROUNDED NUMBERS ARE ASSERTED TO COHERE. Printing 71, 21 and a 50 point gap is only
## honest if the rounded difference equals the difference of the rounded parts, and it does not
## have to. If a rerun ever moves either bar across a half point the build stops here rather
## than putting arithmetic on a slide that the audience can do in their heads and refute.
png2("fig_gap.png", w = 2000, h = 820, res = 150)
par(mar = c(3.4, 1.0, 2.4, 1.0))
vals <- c(wf_gap_hd$marg_conf, wf_gap_hd$p_final_dose_in_obd_marginal)
gap_pp <- round(100 * wf_gap_hd$gap)
stopifnot(round(100 * vals[1]) - round(100 * vals[2]) == gap_pp)
bp <- barplot(vals, ylim = c(0, 0.92), col = c(car, navy), border = NA, axes = FALSE,
              names.arg = c("", ""), width = 0.5, space = 0.55)
text(bp, vals + 0.06, paste0(round(100 * vals), " percent"), cex = 2.5, font = 2, col = navy)
text(bp, -0.075, c("The confirmatory trial\nsucceeds", "The program is on the\ntruly best dose"),
     xpd = NA, cex = 1.65, col = navy)
arrows(bp[1] + 0.34, vals[2], bp[1] + 0.34, vals[1], code = 3, length = 0.14, lwd = 4,
       col = orange)
text(bp[1] + 0.42, mean(vals), paste0("gap of ", gap_pp, "\npercentage points"),
     adj = 0, cex = 1.9, font = 2, col = orange)
dev.off()

## ---- 4. Domain dependence at one horizon --------------------------------------------------
## Two verified statements at the same maximum sample size. The prespecified domain was examined
## exhaustively and no design there verified safety-feasible, with every unresolved verdict shown
## as unresolved. The wider domain yielded the design shown, labelled best found, since no
## exhaustive answer exists under that representation.
## REBUILT 2026-09-05 against the owner review, item 25. The review is right that the old chart
## asked the room to hold a search domain and a feasibility verdict at once while reading a
## vertical scale that carried only one plotted point. The scale is gone. What is left is two
## halves stating what each search returned, which is the point the slide makes.
##
## THE NUMBER STAYS EVEN THOUGH THE SCALE GOES. The review says the message is not the exact
## 0.559, and it is not, but a slide claiming a wider search "found an acceptable design" with
## no number attached is a claim the audience cannot size. The number is printed and the axis
## that made it look like a measurement is removed.
##
## UNRESOLVED IS SPELLED OUT IN THE ARTWORK, in gold rather than in either verdict colour,
## because ten settings left unresolved is not ten near misses and the count would otherwise
## read as one.
png2("fig_domain.png", w = 2000, h = 820, res = 150)
par(mar = c(0.6, 0.6, 4.2, 0.6))
plot(NA, xlim = c(0, 2), ylim = c(0, 1), axes = FALSE, xlab = "", ylab = "")
mtext(paste0("Same trial size, ", bb_nmax, " patients"), side = 3, line = 1.2, cex = 1.85,
      col = navy, font = 2)

## Left half. The prespecified domain, examined one design at a time.
rect(0.05, 0.06, 0.94, 0.90, col = mist, border = NA)
text(0.495, 0.815, "Restricted settings", cex = 1.9, col = navy, font = 2)
text(0.495, 0.705, paste0(exh_unique, " designs, examined one by one"), cex = 1.5, col = navy)
text(0.495, 0.52, "None met both\nsafety requirements", cex = 2.0, col = navy, font = 2)
text(0.495, 0.315, paste0(exh_excluded, " ruled out on safety"), cex = 1.5, col = graphite)
text(0.495, 0.215, paste0(exh_unres, " left unresolved"), cex = 1.5, col = gold, font = 2)
text(0.495, 0.115, "unresolved means not enough evidence either way", cex = 1.2, col = gold)

## Right half. The wider domain at the same trial size. BEST FOUND, never an optimum.
rect(1.06, 0.06, 1.95, 0.90, col = "#E8F0F7", border = NA)
text(1.505, 0.815, "Wider settings", cex = 1.9, col = navy, font = 2)
text(1.505, 0.705, "searched, not listed", cex = 1.5, col = navy)
text(1.505, 0.52, "An acceptable\ndesign was found", cex = 2.0, col = cdeep, font = 2)
text(1.505, 0.315, paste0("best found ",
                          formatC(bb_best$verified_select, format = "f", digits = 3),
                          " chance of picking the right dose"),
     cex = 1.4, col = navy)
text(1.505, 0.185, "both safety requirements met, with room to spare", cex = 1.4,
     col = graphite)
dev.off()

## ---- 5. Where every design can be listed ----------------------------------------------------
## REBUILT 2026-09-04 to answer the question the previous version could not. The old panel plotted
## one scalar, distance from the enumerated best, which is opaque to a room that has never seen a
## regret curve and which hides that the enumeration holds each requirement quantity separately.
## The artifact's reference table carries `select`, `stop0` and `expose` for all 64 designs, so the
## comparison is made characteristic by characteristic here.
##
## THE WORD IS MATCHED, NEVER RECOVERED. `numbers.R` asserts that every run at the larger budget
## returned a design carrying the enumerated best selection, and that among safety-feasible designs
## that value belongs to one tied group sharing a single stopping value and a single exposure
## value. That assertion is what licenses printing the other two characteristics for the returned
## design without knowing which member of the tie it was.
## REVISED 2026-09-05 against the owner review, item 27. The review's point is that this is the
## stronger of the two search results and was the harder of the two to read. Two changes. The
## map now says in words that the listed best and the returned design sit at the same point,
## with the two marks drawn on top of one another and named. And the right panel leads with one
## large statement rather than a two-column table, with the three values kept underneath at
## reading size.
png2("fig_oracle.png", w = 2000, h = 860, res = 150)
layout(matrix(1:2, nrow = 1), widths = c(1.05, 1))

## Panel A. The whole map, which is what listing every design buys and search does not.
par(mar = c(5.2, 5.8, 4.2, 1.2), cex.axis = 1.3)
plot(NA, xlim = c(0.295, 0.585), ylim = c(0.36, 1.06), xlab = "", ylab = "",
     xaxt = "n", yaxt = "n")
axis(1, at = seq(0.30, 0.45, 0.05), cex.axis = 1.4, col.axis = navy)
axis(2, at = seq(0.4, 1.0, 0.2), cex.axis = 1.4, col.axis = navy)
mtext("Chance of picking the right dose", side = 1, line = 3.2, cex = 1.45, col = navy)
mtext("Chance of stopping when\nnothing is safe", side = 2, line = 2.5, cex = 1.45, col = navy)
mtext(paste0("Every one of the ", ba_size, " designs, listed"), side = 3, line = 1.9,
      cex = 1.7, col = navy, font = 2)
mtext(paste0(ba_n_feas, " of them meet both safety requirements"), side = 3, line = 0.4,
      cex = 1.3, col = graphite)
points(ba_ref$select[!ba_ref$safe], ba_ref$stop0[!ba_ref$safe], pch = 4, cex = 2.0, lwd = 3,
       col = graphite)
points(ba_ref$select[ba_ref$safe], ba_ref$stop0[ba_ref$safe], pch = 19, cex = 2.2, col = cdeep)
## THE TWO MARKS ARE DRAWN AT THE SAME COORDINATES ON PURPOSE. The orange ring is the best of
## the safe designs as the full listing gives it. The blue dot under it is what guided search
## returned, and `numbers.R` asserts that every run at the larger budget returned a design
## carrying exactly this selection value, and that among safety-feasible designs that value
## belongs to one tied group sharing a single stopping value. Those two assertions are what
## make the ring and the dot the same point rather than a drawing convenience.
points(ba_opt$select, ba_opt$stop0, pch = 19, cex = 2.2, col = cdeep)
points(ba_opt$select, ba_opt$stop0, pch = 1, cex = 5.2, lwd = 4, col = orange)
segments(ba_opt$select + 0.008, ba_opt$stop0 - 0.025, 0.446, 0.635, lwd = 2.5, col = orange)
text(0.443, 0.595, "Best of the safe ones,\nand what guided search\ncame back with",
     cex = 1.3, col = orange, font = 2, adj = 0)
## THE KEY GOES TOP RIGHT, checked against the panel. Every other corner holds either a design
## or the callout.
legend("topright", pch = c(19, 4), col = c(cdeep, graphite), bty = "n", cex = 1.35,
       pt.cex = c(2.0, 1.8), pt.lwd = 3, text.col = navy, inset = c(0.01, 0.0),
       legend = c("meets both safety requirements", "fails one of them"))

## Panel B. ONE STATEMENT, then the evidence for it at reading size.
## THE WORD IS MATCHED, NEVER RECOVERED, and never an optimum.
par(mar = c(2.0, 0.6, 4.2, 0.6))
plot(NA, xlim = c(0, 1), ylim = c(0, 1), axes = FALSE, xlab = "", ylab = "")
text(0.5, 0.90, paste0("Matched the listed best\non all ", nrow(ba_char), " measures"),
     cex = 2.3, col = cdeep, font = 2, adj = 0.5)
segments(0.03, 0.71, 0.97, 0.71, col = mist, lwd = 4)
yr <- c(0.58, 0.44, 0.30)
for (i in seq_len(nrow(ba_char))) {
  text(0.03, yr[i], ba_char$label[i], cex = 1.5, col = navy, adj = 0)
  text(0.97, yr[i], formatC(ba_char$value[i], format = "f", digits = 3), cex = 1.6, col = navy,
       font = 2, adj = 1)
}
text(0.5, 0.14, paste0("the same value from the full listing and from the search,\nin ",
                       ba_seeds, " of ", ba_seeds, " runs, after simulating ", ba_budgets[2],
                       " of the ", ba_size),
     cex = 1.3, col = graphite, adj = 0.5)
dev.off()

## ---- 5b. Where nothing can be listed, and one run came back empty ---------------------------
## PROMOTED 2026-09-04 from a speaker note. Search reliability is a result in this project, so the
## run that returned no design is a plotted point rather than a sentence in the notes.
##
## FIVE RUNS AND NO ORACLE. This is the weaker of the two search comparisons and the figure says so
## in its own header, because a reader who meets it without that qualifier will read it as a
## ranking of optimizers, which the article explicitly refuses to claim.
## REVISED 2026-09-05 against the owner review, item 26. The review's finding is that the left
## plot plus two summaries is too much at once, and it is. Three changes.
##
## FIRST, the legend is gone and the two point clouds carry their own names in their own
## colours, so no colour has to be carried from a corner back to the data.
##
## SECOND, ONE SUMMARY REPLACES TWO, and the one kept is the CONSERVATIVE one, the average over
## every run with the empty run scored as zero. That choice is not arbitrary. The other summary
## conditions on the runs that returned something and therefore quietly drops the guided failure,
## which is the single most important fact on this figure. Keeping the optimistic summary alone
## would have been the wrong half to keep. The conditional numbers are not lost to the room,
## because the left panel shows every run individually.
##
## THIRD, THE CAVEAT MOVES INTO THE ARTWORK. Five runs, and no design here is known to be the
## best one. It was previously carried only in the code comment and the speaker notes, which is
## exactly where a qualifier stops travelling with the finding.
png2("fig_reliability.png", w = 2000, h = 860, res = 150)
layout(matrix(1:2, nrow = 1), widths = c(1.4, 1))

## Panel A. Every run, including the empty one.
par(mar = c(5.2, 6.0, 4.4, 1.2), cex.axis = 1.3)
seeds <- sort(unique(bb$seed))
plot(NA, xlim = c(0.55, length(seeds) + 0.45), ylim = c(-0.02, 0.78), xaxt = "n", yaxt = "n",
     xlab = "", ylab = "")
axis(1, at = seq_along(seeds), labels = seeds, cex.axis = 1.45, col.axis = navy)
axis(2, at = seq(0, 0.6, 0.2), cex.axis = 1.4, col.axis = navy)
abline(h = 0, col = mist, lwd = 2)
mtext("Independent run", side = 1, line = 3.2, cex = 1.45, col = navy)
mtext("Chance of picking the right dose,\nindependently verified", side = 2, line = 2.6,
      cex = 1.45, col = navy)
mtext(paste0("Same budget, ", bb_budget, " designs simulated by each"), side = 3, line = 2.1,
      cex = 1.7, col = navy, font = 2)
mtext(paste0(bb_seeds, " runs each, and no design here is known to be the best one"),
      side = 3, line = 0.5, cex = 1.25, col = graphite)
for (e in c("random", "batond")) {
  d <- bb[bb$engine == e, ]
  d <- d[order(d$seed), ]
  ok <- !is.na(d$verified_select)
  points(match(d$seed[ok], seeds), d$verified_select[ok],
         pch = if (e == "batond") 19 else 15, cex = 3.0,
         col = if (e == "batond") cdeep else graphite)
  # THE FAILURE IS A POINT ON THE AXIS, not an omission and not a footnote.
  if (any(!ok)) {
    xf <- match(d$seed[!ok], seeds)
    points(xf, rep(0, length(xf)), pch = 1, cex = 3.4, lwd = 3.5, col = orange)
    text(xf, 0.095, "returned\nnothing", cex = 1.3, col = orange, font = 2)
  }
}
# DIRECT LABELS, each in the colour of the marks it names.
text(0.7, 0.70, "Guided search", cex = 1.6, col = cdeep, font = 2, adj = 0)
text(3.4, 0.185, "Random search", cex = 1.6, col = graphite, font = 2, adj = 0.5)

## Panel B. ONE summary, and it is the one that cannot flatter the guided arm.
par(mar = c(7.0, 5.6, 4.4, 1.2))
vr <- c(bb_oper("batond"), bb_oper("random"))
bp <- barplot(vr, col = c(cdeep, graphite), border = NA, ylim = c(0, 0.70),
              axes = FALSE, names.arg = c("", ""), width = 0.5, space = 0.5)
axis(2, at = seq(0, 0.6, 0.2), cex.axis = 1.4, col.axis = navy)
text(bp, vr + 0.045, formatC(vr, format = "f", digits = 3), cex = 2.0, font = 2, col = navy)
mtext(c("Guided", "Random"), side = 1, at = bp, line = 1.0, cex = 1.6, col = navy, font = 2)
mtext(paste0("Averaged over all ", bb_seeds, " runs"), side = 3, line = 2.1, cex = 1.7,
      col = navy, font = 2)
mtext("the run that returned nothing counts as zero", side = 3, line = 0.5, cex = 1.25,
      col = graphite)
mtext(paste0("guided returned a design in ", bb_nfound("batond"), " of ", bb_seeds,
             " runs\nrandom in ", bb_nfound("random"), " of ", bb_seeds),
      side = 1, line = 4.6, cex = 1.3, col = graphite)
dev.off()

## ---- 5c. The three-way trade-off -------------------------------------------------------------
## ADDED 2026-09-04. THE THREE QUANTITIES SIT ON ONE ROW of the workflow factorial, so the display
## joins nothing. The framework article's frontier carries selection against trial size and no
## downstream quantity, so a three-way view built from it would have to be joined across sets and
## would not be honest. This one is not built from it.
##
## THE UNCALIBRATED REFERENCE DESIGN IS ABSENT ON PURPOSE. Its selection is observed rather than
## independently verified, which `numbers.R` asserts, and mixing the two on one axis would put a
## weaker number beside stronger ones with nothing on the slide to separate them.
## PATIENTS ARE THE POINT AREA, NOT A PRINTED NUMBER BESIDE EVERY POINT. Printed counts collided,
## and worst where the finding is, since the two largest U-BOIN horizons sit almost on top of each
## other. That near-coincidence is the attainable-performance plateau the article establishes by
## enumeration, so the display has to survive it rather than be defeated by it.
## REVISED 2026-09-05 against the owner review, item 28. The review counted the encodings and
## it was right, there were six. Two go. The dot-size encoding of patients is gone, and the
## legend is gone in favour of a label written at the end of each line.
##
## WHAT REPLACES THE SIZE ENCODING. Within every family the points are ordered by trial-size
## ceiling and selection rises with it, which `numbers.R` asserts for both response shapes, so
## moving right along a line already means a bigger trial. The panel says that in one line
## under the axis instead of asking the room to compare circle areas.
##
## THE PANEL ORDER IS REVERSED FROM THE PREVIOUS VERSION, and this contradicts the review's own
## left and right assignment while serving its intent. The review asked for "usually helps" on
## the left and "but not always" on the right. In the data the exception lives in the plateau
## panel, which was on the left. So the panels swap rather than the labels, the room meets the
## rule before the exception, and the exception is the last thing on the slide. NOTE FOR ANY
## PROSE THAT REFERS TO A SIDE. Left is now response keeps rising, right is response levels off,
## which is the opposite of `fig_targets`.
tw_col <- c(boin = orange, uboin = graphite, boin12 = cdeep)
## THE LESSON OVER EACH PANEL IS ASSERTED, not asserted about. Under a rising response every
## family bought more confirmation from a better dose choice. Under a plateau one family did
## not, and that single family is what the slide is for.
tw_gain <- function(s, f) {
  d <- tw[tw$scenario == s & tw$phase1_design == f, ]; d <- d[order(d$n_max), ]
  d$marg_conf[nrow(d)] - d$marg_conf[1]
}
tw_gains <- function(s) vapply(tw_fams, function(f) tw_gain(s, f), numeric(1))
stopifnot(all(tw_gains("OBD_monotone") > 0), any(tw_gains("OBD_plateau") < 0))
tw_head <- list(OBD_monotone = c("Response keeps rising",
                                 "A better dose choice bought a better program"),
                OBD_plateau  = c("Response levels off",
                                 "Here it did not, for one design family"))
## THE FAMILY NAMES ARE SET OVER TWO LINES HERE rather than in `numbers.R`, which several other
## displays read. A label written beside a line has to fit beside the line, and the single-line
## forms do not.
tw_short <- c(boin = "Toxicity only", uboin = "Toxicity,\nthen benefit",
              boin12 = "Benefit against\nharm throughout")
stopifnot(setequal(names(tw_short), tw_fams))
## LABEL POSITIONS ARE HAND PLACED PER PANEL and checked against the drawn panel, because the
## three line ends crowd differently under each response shape.
tw_labpos <- list(
  OBD_monotone = list(boin = c(0.575, 0.679, 0), uboin = c(0.335, 0.458, 0),
                      boin12 = c(0.512, 0.548, 0)),
  OBD_plateau  = list(boin = c(0.575, 0.700, 0), uboin = c(0.300, 0.762, 0.5),
                      boin12 = c(0.512, 0.888, 0)))
tw_pan <- function(s) {
  par(mar = c(6.6, 5.8, 4.4, 1.4), cex.axis = 1.3)
  plot(NA, xlim = c(0.21, 0.70), ylim = c(0.42, 0.94), xaxt = "n", yaxt = "n",
       xlab = "", ylab = "")
  axis(1, at = seq(0.25, 0.55, 0.10), cex.axis = 1.4, col.axis = navy)
  axis(2, at = seq(0.5, 0.9, 0.10), cex.axis = 1.4, col.axis = navy)
  mtext("Chance of picking the right dose", side = 1, line = 3.2, cex = 1.45, col = navy)
  mtext("each line runs from the smallest trial to the largest", side = 1, line = 4.9,
        cex = 1.2, col = graphite)
  mtext("Chance the next trial\nconfirms the drug works", side = 2, line = 2.6, cex = 1.45,
        col = navy)
  mtext(tw_head[[s]][1], side = 3, line = 2.1, cex = 1.7, col = navy, font = 2)
  mtext(tw_head[[s]][2], side = 3, line = 0.5, cex = 1.3, col = graphite)
  for (f in tw_fams) {
    d <- tw[tw$phase1_design == f & tw$scenario == s, ]
    d <- d[order(d$n_max), ]
    lines(d$select_estimate, d$marg_conf, lwd = 4.5, col = tw_col[[f]])
    points(d$select_estimate, d$marg_conf, pch = 19, cex = 2.6, col = tw_col[[f]])
    # DIRECT LABEL BESIDE THE LINE, in the line's own colour, replacing the legend.
    n <- tw_labpos[[s]][[f]]
    text(n[1], n[2], tw_short[[f]], cex = 1.35, col = tw_col[[f]], font = 2, adj = n[3])
  }
}
png2("fig_tradeoff.png", w = 2000, h = 880, res = 150)
par(mfrow = c(1, 2))
tw_pan("OBD_monotone")
tw_pan("OBD_plateau")
dev.off()

## ---- 6. The two rankings cross -------------------------------------------------------------
## THE JOINED FIGURE IS GONE. It was kept building through the revision pass only so the deck
## never referenced a file that did not exist mid-pass. The pass is over, the slide is now two
## slides, and nothing references `fig_discordance.png`, so building it would leave dead output
## that the next reader has to work out is unused.

## ---- 6a and 6b. The same two halves, split, per the owner review, item 33 --------------------
## The review's finding is that the crossing lines alone carry the ranking reversal and that the
## cost bars beside them are a second idea competing for the same attention. So the halves become
## two figures. `fig_discordance.png` above keeps building unchanged.
##
## THE COST FIGURE DRAWS THE WHOLE PROFILE, not the three bars the joined version showed. Reading
## the artifact rather than the old figure shows why that mattered. `e7_qmap` gives program
## success from every dose, and the two doses either side of the target are NOT alike. The dose
## below is worth 0.693 and the dose above is worth 0.279. A figure with one bar labelled "the
## dose next door" says a miss is cheap, when a miss in one direction is cheap and a miss in the
## other is not. The full profile says the true thing and is no harder to read.

## 6a. The crossing lines, on their own and at full width.
png2("fig_discordance_lines.png", w = 2000, h = 780, res = 150)
par(mar = c(6.2, 1.6, 4.6, 3.0), cex.axis = 1.3)
A <- e7_pair_structural
pcs <- unname(E7Q$PCS[c(A$A, A$B)]); pos <- unname(E7Q$POS[c(A$A, A$B)])
stopifnot(pcs[1] > pcs[2], pos[1] < pos[2],
          abs((pcs[1] - pcs[2]) - A$dPCS) < 1e-8, abs((pos[1] - pos[2]) - A$dPOS) < 1e-8)
## THE PAIR'S FAMILY IS READ FROM THE KEY, not assumed. The note under the header claims the two
## designs come from one family, so the build establishes that before drawing it.
d_fams <- vapply(c(A$A, A$B), function(k) strsplit(k, "\\|")[[1]][3], character(1))
stopifnot(length(unique(d_fams)) == 1L)
plot(NA, xlim = c(0.52, 2.30), ylim = range(c(pcs, pos)) + c(-0.075, 0.055), xaxt = "n",
     yaxt = "n", xlab = "", ylab = "", bty = "n")
mtext("The two rankings cross", side = 3, line = 2.2, cex = 2.0, col = navy, font = 2)
mtext("one design family, calibrated two different ways, judged on one truth", side = 3,
      line = 0.5, cex = 1.35, col = graphite)
axis(1, at = 1:2, tick = FALSE, cex.axis = 1.5, padj = 0.75, col.axis = navy,
     labels = c("Chance of picking the\nright dose in phase I",
                "Chance the program succeeds,\nconfirmation included"))
dlab <- c("Design A", "Design B")
for (i in 1:2) {
  lines(1:2, c(pcs[i], pos[i]), lwd = 6, col = c(cdeep, orange)[i])
  points(1:2, c(pcs[i], pos[i]), pch = 19, cex = 3.2, col = c(cdeep, orange)[i])
  text(0.94, pcs[i], formatC(pcs[i], format = "f", digits = 3), cex = 1.6, col = navy, adj = 1)
  text(2.04, pos[i], formatC(pos[i], format = "f", digits = 3), cex = 1.6, col = navy, adj = 0)
  # DIRECT LABEL, beside the left end of each line and in that line's colour.
  text(0.55, pcs[i], dlab[i], cex = 1.6, col = c(cdeep, orange)[i], font = 2, adj = 0)
}
## THE CALLOUT GOES BELOW BOTH LINES, checked against the drawn panel. Every other region of
## this frame is either crossed by a line or holds an endpoint value.
text(1.35, min(c(pcs, pos)) - 0.038, "the better design flips", cex = 1.55, col = graphite,
     font = 2, adj = 0.5)
## THE QUALIFIER TRAVELS WITH THE FINDING, inside the artwork. Two of thirty-six compared pairs
## carry a reversal the evidence supports, and this figure draws one of them.
mtext(paste0("one of the ", e7_supported_n, " reversals the evidence supports, out of ",
             e7_P_total, " pairs compared"),
      side = 1, line = 4.4, cex = 1.3, col = graphite)
dev.off()

## 6b. Why, and it is the whole profile rather than three chosen bars.
png2("fig_discordance_costs.png", w = 2000, h = 720, res = 150)
par(mar = c(5.4, 7.0, 4.6, 1.6), cex.axis = 1.3)
q_dose <- setdiff(names(e7_qmap), "none")
qv2 <- unname(e7_qmap[c(q_dose, "none")])
# ASSERTED. The figure marks one bar as the right dose and shows nothing beating it, and it
# shows no dose at all as worth nothing.
# ASSERTED, both halves of the sub-header. The target dose is the best of them, no dose at all
# is worth nothing, and the step down costs far less than the step up.
stopifnot(e7_qmap[[as.character(e7_dstar)]] == max(e7_qmap), e7_qmap[["none"]] == 0,
          e7_qmap[[as.character(e7_dstar - 1L)]] > e7_qmap[[as.character(e7_dstar + 1L)]])
q_is_star <- c(q_dose == as.character(e7_dstar), FALSE)
q_is_none <- c(rep(FALSE, length(q_dose)), TRUE)
bp2 <- barplot(qv2, ylim = c(0, 1.06), border = NA, axes = FALSE,
               names.arg = rep("", length(qv2)),
               col = ifelse(q_is_star, navy, ifelse(q_is_none, orange, graphite)))
axis(2, at = seq(0, 1, 0.25), cex.axis = 1.4, col.axis = navy)
mtext("Chance the program\nsucceeds from that dose", side = 2, line = 3.4, cex = 1.45,
      col = navy)
mtext("Not every wrong choice costs the same", side = 3, line = 2.2, cex = 2.0, col = navy,
      font = 2)
mtext("one step low costs little, one step high costs a great deal", side = 3, line = 0.5,
      cex = 1.35, col = graphite)
mtext(c(paste("Dose", q_dose), "No dose\nat all"), side = 1, at = bp2, line = 2.0, cex = 1.35,
      col = navy)
text(bp2, qv2 + 0.05, formatC(qv2, format = "f", digits = 3), cex = 1.5, font = 2, col = navy)
text(bp2[q_is_star], qv2[q_is_star] + 0.155, "the right dose", cex = 1.45, col = navy,
     font = 2)
dev.off()

## ---- 7. The four architecture contrasts, both geometries ------------------------------------
## Point estimate and Bonferroni-adjusted interval, the article's own multiplicity family, on
## correct-final-dose support. Supported and unsupported are distinguished by shape rather than
## by grey, per the profile's rule against de-emphasis by greying.
##
## REVISED 2026-09-05 against the owner review, item 34.
##
## WHERE THE REVIEW AND THE ARTIFACT DISAGREE, AND THE ARTIFACT WINS. The review proposes four
## short action labels ending in "Carry one" for the fourth category. The fourth contrast is not
## an action at all. `E8Q$contrasts` reads it as "select_incorporate minus select_exclude, the
## boundary function alone", so it is the difference between the two re-pick rules, holding the
## carry fixed. Labelling it "Carry one" would name a different comparison from the one plotted.
## It is labelled as the difference it is, and the footnote states the two baselines, because
## the first three are measured against forwarding a single dose and the fourth is not.
##
## THE OLD LABEL WAS ALSO WRONG IN THE SAME DIRECTION. "The carry alone" reads as carrying a
## dose, and the contrast isolates carrying the earlier DATA.
cids <- c("C1", "C2", "C3", "C4")
clab <- c(C1 = "Carry both doses,\nconfirm both",
          C2 = "Carry both, re-pick one,\ndiscard old data",
          C3 = "Carry both, re-pick one,\nkeep old data",
          C4 = "Keeping old data,\non its own")
## ASSERTED, and the callout says it. In both response shapes the first architecture's interval
## sits entirely above every other architecture's interval, which is what "clearly" is doing.
for (g in list(e8c, e9c)) {
  o <- setdiff(cids, "C1")
  stopifnot(g("C1")$ci_lo > max(vapply(o, function(i) g(i)$ci_hi, numeric(1))))
}
png2("fig_architecture.png", w = 2000, h = 820, res = 150)
# THE LEFT MARGIN AND THE LABEL ARE SIZED TO THE SLOT. At this render height a long rotated
# axis label runs past both ends of the plot region and is clipped at the device edge, which is
# how an axis label ends up shown twice and readable neither time.
par(mar = c(8.2, 6.0, 3.6, 2.6), cex.axis = 1.3)
xs <- seq_along(cids)
lo <- c(sapply(cids, function(i) e8c(i)$ci_lo), sapply(cids, function(i) e9c(i)$ci_lo))
hi <- c(sapply(cids, function(i) e8c(i)$ci_hi), sapply(cids, function(i) e9c(i)$ci_hi))
plot(NA, xlim = c(0.55, 4.5), ylim = range(c(lo, hi)) + c(-0.075, 0.118), xaxt = "n",
     yaxt = "n", xlab = "", ylab = "", col.lab = navy)
axis(2, cex.axis = 1.4, col.axis = navy)
mtext("Change in the chance of\nending on the right dose", side = 2, line = 2.9, cex = 1.4,
      col = navy)
abline(h = 0, lwd = 3, col = graphite, lty = 2)
axis(1, at = xs, labels = FALSE)
mtext(clab[cids], side = 1, at = xs, line = 2.9, cex = 1.3, col = navy)
draw <- function(get, off, col) {
  for (k in seq_along(cids)) {
    r <- get(cids[k]); sup <- isTRUE(r$supported)
    segments(xs[k] + off, r$ci_lo, xs[k] + off, r$ci_hi, lwd = 4.5, col = col)
    points(xs[k] + off, r$estimate, pch = if (sup) 19 else 1, cex = 2.9, lwd = 3.5, col = col)
  }
}
draw(e8c, -0.13, cdeep); draw(e9c, 0.13, orange)
## THE CALLOUT SITS OVER THE FIRST CATEGORY, which is where the review asked for it and where
## the assertion above licenses it.
text(1, max(hi) + 0.062, "Only carrying both\nclearly helped", cex = 1.5, col = navy, font = 2)
legend("topright", bty = "n", cex = 1.45, text.col = navy, inset = c(0.01, 0.0),
       legend = c("Response keeps rising", "Response levels off"), pch = 19, pt.cex = 2.2,
       col = c(cdeep, orange))
## THE SHAPE KEY IS SPELLED OUT rather than named. Filled and open are the difference between
## evidence for a real change and no evidence for one, and "supported" alone does not say that
## to a room meeting the word for the first time.
legend("bottomright", bty = "n", cex = 1.3, text.col = navy, inset = c(0.01, 0.0),
       legend = c("the evidence supports a real change", "it does not"),
       pch = c(19, 1), pt.cex = 2.2, pt.lwd = 3, col = graphite)
mtext(paste0("The first three are measured against forwarding one dose. ",
             "The last compares the two re-pick rules."),
      side = 1, line = 6.2, cex = 1.25, col = graphite)
dev.off()

cat("figures written to ", OUT, "\n")
