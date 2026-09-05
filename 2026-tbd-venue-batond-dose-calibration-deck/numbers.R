# Every finding number on this deck is computed here, from the same objects the two manuscripts
# read, through `R/metrics.R` in the paper repository. Nothing is typed.
#
# ONE AUTHORITY. `BATOND_PAPER_REPO` roots artifact discovery, so this file runs from the talks
# repository and still reads the paper repository's locked results. A missing artifact is an
# error and never a default.
#
# THE EXPRESSIONS ARE COPIED FROM THE MANUSCRIPTS' OWN SETUP CHUNKS, name for name, so a slide and
# a paper sentence quoting the same quantity cannot diverge. Where a manuscript asserts a count in
# words, the assertion travels with the number.

BATOND_REPO <- Sys.getenv("BATOND_PAPER_REPO",
                          path.expand("~/research/trials-research/baton-dosefinding"))
Sys.setenv(BATOND_PAPER_REPO = BATOND_REPO)
source(file.path(BATOND_REPO, "R", "metrics.R"))
M <- metrics()

fmt  <- function(x, digits = 3) formatC(x, format = "f", digits = digits)
pct  <- function(x, digits = 0) paste0(formatC(100 * x, format = "f", digits = digits), "%")
mcse <- function(p, n) sqrt(p * (1 - p) / n)

# PERCENTAGE POINTS, added 2026-09-05 for the generalist deck. A DIFFERENCE of two proportions is
# read far faster as points than as 0.047, so the slides that report a difference report points.
# The helper takes the live difference and multiplies, exactly as `pct` does for a level, so a
# call site can never introduce a typed number by doing the arithmetic itself. A LEVEL still goes
# through `pct` and a bound still goes through `fmt`, because slide 30 shows an estimate and a
# conservative bound side by side and their third decimal is the point of that display.
pp <- function(x, digits = 0) formatC(100 * x, format = "f", digits = digits)

## ---- Framework article -----------------------------------------------------------------

INF  <- M$shared$inference
WOSH <- M$shared$weighted
wo   <- WOSH$frontier
WOS  <- artifact("weighted_objective_study", M)
wo_prov <- WOS$provenance

wo_n      <- nrow(wo)
wo_found  <- sum(wo$outcome == "feasible_found")
wo_nofeas <- sum(wo$outcome == "no_feasible_policy_found")
wo_err    <- sum(wo$outcome == "search_error")
stopifnot(wo_found + wo_nofeas + wo_err == wo_n)

wo_R_search <- wo_prov$R_search
wo_R_verify <- wo_prov$R_verify
wo_evals    <- sum(wo$n_distinct, na.rm = TRUE)
wo_w        <- sort(unique(wo$w))
wo_fams     <- sort(unique(wo$family))
wo_cells    <- function(s) sum(wo$study == s)
wo_scen_s   <- function(s) length(unique(wo$scenario[wo$study == s]))
wo_floor_of <- function(s) if (s == "application") WOSH$floor_application else WOSH$floor_simulation
wo_nmax_cap <- wo_prov$nmax_clinical_bound

CENS      <- INF$counts
cp_feas   <- CENS$corrected_pipeline$feasible
cp_unr    <- CENS$corrected_pipeline$unresolved
cp_locked <- INF$n_locked_cells
stopifnot(cp_feas + cp_unr == cp_locked, cp_locked == wo_found,
          CENS$corrected_pipeline$infeasible == 0L,
          identical(INF$reported_census, "corrected_pipeline"))

CPC        <- INF$con_counts_corrected_pipeline
cp_stop_ok <- CPC$stop0$feasible
cp_exp_ok  <- CPC$expose$feasible
cp_exp_un  <- CPC$expose$unresolved
cp_sel_ok  <- CPC$select$feasible
cp_sel_un  <- CPC$select$unresolved
stopifnot(cp_stop_ok + CPC$stop0$unresolved == cp_locked,
          cp_exp_ok + cp_exp_un == cp_locked,
          cp_sel_ok + cp_sel_un == cp_locked)

cp_cert_rows <- INF$certified_designs_corrected_pipeline
cp_cert_s    <- function(s) sum(cp_cert_rows$study == s)
cp_nmax_rng  <- range(cp_cert_rows$n_max)
cp_coh_rng   <- range(cp_cert_rows$cohort_size)
cp_sel_max_s <- function(s) max(cp_cert_rows$select_estimate[cp_cert_rows$study == s])
stopifnot(cp_nmax_rng[2] <= wo_prov$nmax_clinical_bound)

SEM       <- M$shared$selection_semantics
SEM_CELLS <- SEM$cells
stopifnot(SEM$n_on_application_floor + SEM$n_on_prespecified_floor == SEM$n_cells)

# The prespecified coarse domain and the exhaustive pass at its largest horizon.
PDS       <- M$shared$phase_d
pd_rows   <- PDS$frontier
pd_n_rows <- nrow(pd_rows)
pd_n_feas <- sum(pd_rows$feasible)
pd_floor  <- PDS$selection_floor
pd_stop   <- PDS$stop_floor
pd_expose <- PDS$exposure_ceiling
R_verify  <- PDS$R_verify

EXH60        <- artifact("boin_safety_exhaustive_60", M)
exh_nmax     <- EXH60$n_max
exh_unique   <- EXH60$n_unique
exh_excluded <- EXH60$n_excluded
exh_checked  <- length(EXH60$results)
exh_feasible <- sum(vapply(EXH60$results, function(r) r$safe, logical(1)))
exh_unres    <- exh_checked - exh_feasible

# The expanded domain at the same horizon. Best found under a fixed budget, never an optimum.
BBH       <- M$shared$bench_expanded
bb        <- BBH$rows
bb_nmax   <- BBH$n_max
bb_budget <- BBH$budget
bb_seeds  <- BBH$n_seeds
bb_get    <- function(e) bb$verified_select[bb$engine == e]
bb_ok     <- function(e) BBH$found_rows$verified_select[BBH$found_rows$engine == e]
bb_nfound <- function(e) length(bb_ok(e))
bb_cond   <- function(e) mean(bb_ok(e))
bb_oper   <- function(e) sum(bb_ok(e)) / length(bb_get(e))   # a failure scores zero
bb_best   <- BBH$best_row
# ASSERTED, and the slide states it. Every successful guided run beat every random-search run.
stopifnot(min(bb_ok("batond")) > max(bb_ok("random")))

# The enumerable oracle benchmark.
BAH        <- M$shared$bench_enumerable
BENCH_A    <- artifact("bench_coarse_exact", M)
ba         <- BAH$rows
ba_ref     <- BAH$reference
ba_opt     <- BAH$optimum
ba_nmax    <- BAH$n_max
ba_size    <- BAH$space_size
ba_n_feas  <- sum(ba_ref$safe)
ba_spread  <- max(ba_ref$select[ba_ref$safe]) - min(ba_ref$select[ba_ref$safe])
ba_mcse    <- mcse(ba_opt$select, BENCH_A$provenance$R_reference)
ba_budgets <- BAH$budgets
ba_seeds   <- BAH$n_seeds
ba_regret  <- function(e, b) BAH$zero_regret$mean_regret[
  BAH$zero_regret$engine == e & BAH$zero_regret$budget == b]
ba_zero    <- function(e, b) BAH$zero_regret$n_zero_regret[
  BAH$zero_regret$engine == e & BAH$zero_regret$budget == b]
ba_worst_rnd <- max(ba$regret[ba$engine == "random"], na.rm = TRUE)
# ASSERTED, and the slide states it. Guided search reached zero regret in every run at the
# larger budget and random search did not.
stopifnot(ba_zero("batond", ba_budgets[2]) == ba_seeds,
          ba_regret("random", ba_budgets[2]) > 0)

# WHAT THE ENUMERABLE BENCHMARK HOLDS PER DESIGN, and it is more than a distance. The reference
# table carries `select`, `stop0` and `expose` for every one of the 64 designs, so the comparison
# against the enumerated best can be made characteristic by characteristic rather than as one
# scalar. `safe` in this artifact is the SAFETY PAIR ONLY, stopping and exposure, because here
# selection is the objective rather than a constraint. The slide says "matched", never "recovered".
ba_safe   <- ba_ref[ba_ref$safe, ]
ba_tieset <- ba_safe[abs(ba_safe$select - max(ba_safe$select)) < 1e-12, ]
# ASSERTED, and it is what licenses the per-characteristic slide. Every run at the larger budget
# returned a design carrying the enumerated best selection, and among safety-feasible designs that
# value belongs to one tied group whose members share the same stopping and the same exposure. So
# the returned design's other two characteristics are identified without knowing which member it is.
stopifnot(nrow(ba_tieset) >= 1L,
          length(unique(ba_tieset$stop0)) == 1L,
          length(unique(ba_tieset$expose)) == 1L,
          ba_opt$policy_id %in% ba_tieset$policy_id,
          all(abs(ba$ref_select[ba$engine == "batond" & ba$budget == ba_budgets[2]] -
                    ba_opt$select) < 1e-12))
ba_n_tied <- nrow(ba_tieset)
ba_char   <- data.frame(
  label = c("Picks the right dose", "Stops when nothing is safe", "Rarely overexposes"),
  value = c(ba_opt$select, ba_opt$stop0, ba_opt$expose))

# The eight-policy domain, enumerated exactly.
BENCH_U   <- artifact("bench_uboin_enumerate", M)
bu        <- BENCH_U$rows
bu_size   <- BENCH_U$space_size
bu_nmax   <- sort(unique(bu$n_max))
bu_at     <- function(n) bu[bu$n_max == n, ]
bu_best   <- function(n) max(bu_at(n)$select_obd)
bu_allsafe <- all(bu$safety_feasible)
stopifnot(isTRUE(bu_allsafe))

# What a trial team receives.
DLV     <- M$shared$deliverable
DLV_REQ <- DLV$requirements

# The reference protocol's own published exact optimal-dose selection, external and cited.
PUB_OBD_SELECT_S1 <- unname(M$published$pangea_exact_obd_select[["S1"]])
PUB_OBD_SELECT_S3 <- unname(M$published$pangea_exact_obd_select[["S3"]])

FAMILYWISE <- INF$familywise

## ---- Downstream article ----------------------------------------------------------------

WF   <- artifact("phase2_workflow_factorial", M)
wf       <- WF$factorial_table
wf_R     <- WF$provenance$phase1_replicates
wf_simon <- WF$simon_design
wf_sp    <- WF$provenance$simon_design_params
wf_gap   <- unique(wf$transition_gap_months)
stopifnot(length(wf_gap) == 1L)
wf_scen <- c("OBD_plateau", "OBD_monotone", "OBD_cliff", "SENS_low", "SENS_steep")
stopifnot(setequal(unique(wf$scenario), wf_scen))
wf_marg <- function(d) d$p_confirmed * (1 - d$p_no_dose)
wf$marg_conf <- wf_marg(wf)

wf_pos <- do.call(rbind, lapply(wf_scen, function(s) {
  da  <- WF$dose_agg[[s]]
  obd <- which(vapply(da, function(z) z$p_obd_hit, numeric(1)) > 0)
  stopifnot(length(obd) == 1L)
  pos <- ifelse(seq_along(da) < obd, "below", ifelse(seq_along(da) == obd, "at", "above"))
  data.frame(scenario = s, position = pos,
             confirmed = vapply(da, function(z) z$p_confirmed, numeric(1)),
             toxicity  = vapply(da, function(z) z$p_toxicity,  numeric(1)))
}))
wf_pos_avg <- function(s, p, col) {
  v <- wf_pos[[col]][wf_pos$scenario == s & wf_pos$position == p]
  if (!length(v)) NA_real_ else mean(v)
}
# BOTH directional claims the slide makes are asserted, exactly as the article asserts them.
for (s in wf_scen) {
  stopifnot(wf_pos_avg(s, "at", "confirmed") >=
              max(c(wf_pos_avg(s, "below", "confirmed"),
                    wf_pos_avg(s, "above", "confirmed")), na.rm = TRUE),
            wf_pos_avg(s, "above", "toxicity") > wf_pos_avg(s, "at", "toxicity"))
}
wf_cliff_below <- wf_pos_avg("OBD_cliff", "below", "confirmed")
wf_cliff_at    <- wf_pos_avg("OBD_cliff", "at", "confirmed")
wf_mcse_max    <- mcse(0.5, wf_R)

wf$gap    <- wf$marg_conf - wf$p_final_dose_in_obd_marginal
.prim     <- wf$structure == "S" & wf$scenario %in% c("OBD_plateau", "OBD_monotone")
wf_gap_hd <- wf[.prim, ][which.max(wf$gap[.prim]), ]

wf$horizon_key <- ifelse(is.na(wf$n_max), "none", as.character(wf$n_max))
wf_wide <- reshape(wf[, c("phase1_design", "horizon_key", "scenario", "structure",
                          "marg_conf", "p_final_dose_in_obd_marginal",
                          "mean_total_enrollment", "mean_total_program_months")],
                   direction = "wide", timevar = "structure",
                   idvar = c("phase1_design", "horizon_key", "scenario"))
stopifnot(nrow(wf_wide) * 2L == nrow(wf))
wf_d_conf <- wf_wide$marg_conf.R - wf_wide$marg_conf.S
wf_d_n    <- wf_wide$mean_total_enrollment.R - wf_wide$mean_total_enrollment.S
wf_d_mo   <- wf_wide$mean_total_program_months.R - wf_wide$mean_total_program_months.S
wf_lab    <- c(OBD_plateau = "Efficacy plateaus", OBD_monotone = "Efficacy rises throughout",
               OBD_cliff = "Low doses inactive", SENS_low = "Best dose is the lowest",
               SENS_steep = "Toxicity rises steeply")
wf_E <- WF$answer_E
wf_worst_conf <- wf_E$scenario[wf_E$three_plus_three_worst_on_confirmed]
wf_333 <- function(s, col) wf_E[[col]][wf_E$scenario == s]

## ---- The three-way trade-off -------------------------------------------------------------
# ONE ARTIFACT AND ONE ROW PER POINT. The three quantities the trade-off slide plots, the verified
# chance of picking the right dose, the chance the next trial confirms, and the expected patients
# across both phases, all sit on the SAME row of the factorial table. Nothing is joined across
# incompatible sets, which is the only reason a three-way display is honest here.
#
# THE THIRD AXIS EXISTS BECAUSE THIS ARTIFACT CARRIES BOTH PHASES. The framework article's
# frontier carries selection against trial size and no downstream quantity at all, so a three-way
# view built from it would have to be joined to something else. This one does not.
TW_SCEN <- c("OBD_plateau", "OBD_monotone")
tw <- wf[wf$structure == "S" & wf$scenario %in% TW_SCEN &
           wf$phase1_design != "three_plus_three",
         c("phase1_design", "n_max", "scenario", "select_estimate", "stop0_estimate",
           "marg_conf", "mean_total_enrollment", "mean_total_program_months", "oc_source")]
tw <- tw[order(tw$scenario, tw$phase1_design, tw$n_max), ]
# ASSERTED. Every point plotted carries an independently verified selection estimate. The
# uncalibrated reference design is excluded from this display precisely because its row does not.
stopifnot(nrow(tw) == 18L, all(tw$oc_source == "verified"),
          !anyNA(tw$select_estimate), !anyNA(tw$marg_conf),
          all(wf$oc_source[wf$phase1_design == "three_plus_three"] == "observed"))
tw_fams <- c("boin", "uboin", "boin12")
tw_lab  <- c(boin = "Toxicity only", uboin = "Toxicity, then benefit",
             boin12 = "Benefit against harm throughout")
stopifnot(setequal(tw_fams, unique(tw$phase1_design)))
tw_nmax <- sort(unique(tw$n_max))
tw_at <- function(f, n, s, col)
  tw[[col]][tw$phase1_design == f & tw$n_max == n & tw$scenario == s]
tw_span <- function(s, col)
  vapply(tw_fams, function(f) tw_at(f, max(tw_nmax), s, col) - tw_at(f, min(tw_nmax), s, col),
         numeric(1))
# ASSERTED, and both halves of the trade-off slide's claim rest on it. Going from the smallest
# trial-size ceiling to the largest raises the chance of picking the right dose in every family,
# and it costs patients in every family.
stopifnot(all(tw_span("OBD_plateau", "select_estimate") > 0),
          all(tw_span("OBD_monotone", "select_estimate") > 0),
          all(tw_span("OBD_plateau", "mean_total_enrollment") > 0))
tw_d_sel <- range(c(tw_span("OBD_plateau", "select_estimate"),
                    tw_span("OBD_monotone", "select_estimate")))
tw_d_n   <- range(c(tw_span("OBD_plateau", "mean_total_enrollment"),
                    tw_span("OBD_monotone", "mean_total_enrollment")))

ADV     <- artifact("phase2_adversarial", M)
adv_wc  <- ADV$combined_worst_count_confirmation
adv_wq  <- ADV$combined_worst_count_quality
adv_tot <- length(wf_scen) + length(ADV$provenance$scenario_target)

# Discordance, architectures, second geometry.
E7Q  <- artifact("exp7_q3_primary", M)
E7P  <- artifact("exp7_persistence", M)
E8Q  <- artifact("exp8_q5_primary", M)
E9Q7 <- artifact("exp9_q7", M)
E9Q8 <- artifact("exp9_q8", M)

e7_qmap        <- E7Q$qmap
e7_dstar       <- E7Q$dstar
e7_q_target    <- unname(e7_qmap[as.character(e7_dstar)])
e7_q_neighbour <- unname(e7_qmap[as.character(e7_dstar - 1L)])
e7_res         <- E7Q$res
e7_observed    <- sum(e7_res$observed)
e7_supported_n <- sum(e7_res$supported)
e7_supported   <- e7_res[e7_res$supported, ]
e7_pair_structural <- e7_supported[grepl("boin12\\|0\\.5", e7_supported$A), ]
e7_pair_primary    <- e7_supported[grepl("boin12\\|1$", e7_supported$A), ]
e7_persist_structural <- E7P[E7P$A == e7_pair_structural$A & E7P$B == e7_pair_structural$B, ]
e7_persist_primary    <- E7P[E7P$A == e7_pair_primary$A    & E7P$B == e7_pair_primary$B, ]
e7_n_modules <- nrow(e7_persist_structural)
e7_P_total   <- E7Q$P_total

e9_P_total <- E9Q7$P_total
e9_n_observed_inversions  <- sum(E9Q7$res$observed)
e9_n_supported_inversions <- sum(E9Q7$res$supported)

e8_con <- E8Q$contrasts
e9_con <- E9Q8$contrasts
e8c <- function(id) e8_con[e8_con$contrast == id, ]
e9c <- function(id) e9_con[e9_con$contrast == id, ]
e8_pcc <- E8Q$per_cell_contrasts
e8_sign_dis <- e8_pcc[e8_pcc$sign_disagreement, ]
e8_sign_dis_cellkeys <- sort(unique(e8_sign_dis$cellkey))
e8_sign_dis_policies <- sort(unique(sub("\\|.*$", "", e8_sign_dis_cellkeys)))

SVS <- artifact("phase2_seamless_vs_split", M)
sv_n <- SVS$null_headline
sv_ref_seam <- sv_n$seamless_reference_size
sv_ratio    <- sv_n$seamless_naive / sv_ref_seam
sv_prim <- SVS$main_table[SVS$main_table$scenario != "NULL_at_floor" &
                            SVS$main_table$role == "primary", ]
sv_mo_saved <- unlist(lapply(split(sv_prim, sv_prim$scenario), function(d) {
  s <- d$mean_total_program_months[d$route == "SPLIT"]
  m <- d$mean_total_program_months[d$route == "SEAMLESS"]
  if (!length(s) || !length(m)) return(NULL)
  mean(s) - mean(m)
}))
sv_mo_rng <- range(sv_mo_saved)

RC <- artifact("phase2_reserved_cohort", M)
rc <- RC$sweep
rc_f       <- sort(unique(rc$f_target))
rc_null    <- rc[rc$scenario == "NULL_at_floor", ]
rc_at <- function(fam, f, col, sc = "NULL_at_floor") {
  rc[[col]][rc$family == fam & rc$f_target == f & rc$scenario == sc]
}
# ASSERTED, and the slide states it. The zero-reserve arm fails its reference and every
# positive reserve passes.
stopifnot(all(!rc_null$pass_reference[rc_null$f_target == 0]),
          all(rc_null$pass_reference[rc_null$f_target > 0]))
rc_corner  <- RC$corner
rc_res_min <- min(rc$n_reserve[rc$f_target == unname(rc_corner)[1]])
rc_res_max <- max(rc$n_reserve)
rc_bias_max <- max(abs(rc$mean_bias[rc$f_target > 0]), na.rm = TRUE)
rc_rule  <- RC$provenance$confirmation_rule
rc_crit  <- function(n) min((0:n)[1 - pbinom((0:n) - 1L, n, rc_rule$p0) <= rc_rule$alpha])
rc_power <- function(n) 1 - pbinom(rc_crit(n) - 1L, n, WF$provenance$simon_design_params$p1)

ASSOC <- M$shared$association

# THE DEPENDENCE RULER ON BACKUP B8. Its bar positions are computed from the same three
# quantities the slide prints, on the full attainable range, so a redrawn scale cannot drift
# from the numbers printed beside it. Percent of the attainable span, left edge at the most
# negative attainable correlation.
assoc_pos <- function(r) 100 * (r - ASSOC$rho_fh_lo_min) /
  (ASSOC$rho_fh_hi_max - ASSOC$rho_fh_lo_min)

## ---- Backup-slide quantities ------------------------------------------------------------

# The reference protocol's own configuration, read from its authority rather than typed.
source(file.path(BATOND_REPO, "R", "pangea_config.R"))
PANGEA <- pangea_protocol_config()

# The exposure-tolerance sensitivity, recomputed from locked artifacts without simulation.
ALPHA_OD  <- artifact("alpha_od_sensitivity", M)
ao_levels <- sort(ALPHA_OD$provenance$alpha_od_levels)
stopifnot(length(ao_levels) == 3L, any(abs(ao_levels - pd_expose) < 1e-12))
ao_pd     <- ALPHA_OD$phase_d_families
# ASSERTED, exactly as the article asserts it. The backup states no overall verdict moves.
if (any(ao_pd$overall_verdict_0.05 != ao_pd$overall_verdict_0.10) ||
    any(ao_pd$overall_verdict_0.20 != ao_pd$overall_verdict_0.10)) {
  stop("The backup slide states no overall verdict moves with the exposure tolerance.",
       call. = FALSE)
}
ao_ex <- ALPHA_OD$boin_safety_exhaustive_60
stopifnot(ao_ex$n_max == exh_nmax, ao_ex$n_safety_feasible_0.10 == 0L)

# Locked designs re-scored on six added situations. No re-calibration anywhere.
GRID_SENS <- artifact("grid_sensitivity_reverdict", M)
GSH       <- M$shared$grid_sensitivity
gs_worst      <- GSH$worst_overdose
gs_n_exceed   <- sum(gs_worst$overdose_fraction > pd_expose)
# ASSERTED. The backup attributes every exceedance to the toxicity-only family.
stopifnot(all(gs_worst$family[gs_worst$overdose_fraction > pd_expose] == "boin"))
gs_max_expose <- max(gs_worst$overdose_fraction)
gs_fut        <- GSH$futile_rows
gs_fut_boin   <- max(gs_fut$stop_no_dose_selected[gs_fut$family == "boin"])
gs_fut_util   <- range(gs_fut$stop_no_dose_selected[gs_fut$family != "boin"])
gs_low        <- GSH$low_rows
gs_low_boin   <- max(gs_low$select_obd_utility[gs_low$family == "boin"])
gs_low_util   <- range(gs_low$select_obd_utility[gs_low$family != "boin"])
