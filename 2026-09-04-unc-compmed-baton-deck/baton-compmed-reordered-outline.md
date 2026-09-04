# BATON talk: reordered outline (v3, 45-minute target)

UNC Computational Medicine Seminar, September 4, 2026. One-hour slot.
Target: 45 minutes to "Questions," 10 to 15 minutes of discussion.
36 main slides (including 3 dividers), 10 backup slides. Planned times below sum to about 40 minutes; delivered talks run 10 to 15% over plan, so this lands at 44 to 46. Do not fill time by re-adding institutional context; fill it by delivering NEW 4 to 7 slowly enough that a genomicist follows, and by letting NEW 20 to 26 breathe so faculty see the evidence.

Notation: **NEW n** is the new slide number; **(old n)** is the slide in baton-compmed-v2.pdf it comes from. Titles are the replacement titles. Captions are the replacement blue caption text. Seconds are planned delivery time.

## Global fixes applied to every slide

- Caption band anchored to a fixed baseline just above the footer; body content fills the space above it. Not every slide needs a caption: where the title already states the conclusion (NEW 7, 16, 17), let the figure breathe.
- Minimum 16 pt-equivalent for any text the audience must read inside a figure; axis labels and legends at 16 pt or larger. Test NEW 20 and NEW 26 full-screen from across a room tonight.
- No imported screenshots in the main deck except the cropped ADAPT technical-areas graphic on NEW 8.
- One vocabulary for objectives throughout: **H0-Optimal (quit losers quickly)**, **Minimax (cap the worst case)**, **Admissible (the compromise)**. Introduced once on NEW 25, used identically afterward. First time H0 appears, write "H0: the treatment does no better than the benchmark."
- Replace E0[N] notation on main-deck axes with "Expected patients if the treatment is inactive." Statisticians lose nothing.
- Plain-English gloss at first use: single-arm, randomized, interim, futility, posterior probability, null and alternative, platform, cohort, subtrial, feasible, objective. PFS: "time until the cancer worsens or the patient dies."
- Say once, on NEW 24 or 25: "From here on, when I say efficient, I mean efficient in patients, not faster computation."
- Method named once, on NEW 15.
- "(Darker = better design.)" appears once, on NEW 11.

---

## Opening

**NEW 1 (old 1). Planning under uncertainty**
Subtitle unchanged (already announced): *AI-guided design of efficient clinical trials with BATON*.
Say on this slide, not later: "By AI-guided I mean model-guided search: a statistical model chooses which candidate design is worth simulating next. It does not make the clinical decisions. We do."
30 s

**NEW 2 (old 2). Overview**
Three cards:
- Section 1: The problem. Complex adaptive design becomes a search problem.
- Section 2: BATON. A search over a trial simulator.
- Section 3: Does it work, and what did it change?
30 s

---

## Section 1: The problem (planned 11 min)

**NEW 3 (old 3, divider). The problem**
Subline: *Why isn't simulation alone enough?*
10 s

**NEW 4 (new). A clinical trial is an experiment built to support a decision**
Three boxes, plain words:
- **The question, for the efficacy trials in this talk**: does the treatment improve an outcome relative to a benchmark or a control?
- **How patients are used**: single-arm (everyone receives the study treatment; outcomes are compared with a prespecified benchmark) or randomized (patients are assigned to treatment or control).
- **Two ways to be wrong**: advance a treatment that does not work, or drop one that does.
One line at the bottom: *Traditional development is organized in phases: choose a dose, look for a signal, then confirm it. Each phase is a trial with its own rule for go or stop.*
Caption: *For the calibration problems in this talk, two choices dominate: how many patients, and what rule decides.*
90 s

**NEW 5 (old 11). Bayesian adaptive trials decide as they go. Each rule adds settings.**
Diagram unchanged. Replace the italic "At each LOOK" note with: *At an interim look we update the probability of benefit using the data so far. Prespecified rules can stop early for futility and, in some designs, for efficacy.*
Say aloud: "The design is Bayesian because those decisions rest on posterior probabilities under a model and a prior." Gloss "futility" (the treatment looks unlikely to work) and "interim" (a look before the end).
Caption: *Maximum N, look timing, futility and efficacy thresholds, priors, margins: 8 to 13 interacting choices, and every one changes how the trial behaves.*
90 s

**NEW 6 (old 9 + definition boxes from old 12). Feasible designs must satisfy prespecified error-rate and power targets**
Top: the two definition boxes moved from old 12 (Type I error, false go; Power, true go). Replace the FDA line with: *In the examples that follow, a feasible design has power at least 0.80 and type I error at most 0.10.* Bottom: the four-row table from old 9, second column header stays **EVOLVE** (the other rows are features of your platform setting; NEW 10 is where you generalize). Table fills the width.
No caption; the table's last row (closed-form vs simulation only) is the point.
90 s

**NEW 7 (old 12, minus the definition boxes). Simulation tells us how one candidate behaves. It does not tell us which candidate to try next.**
Keep the one-candidate-design simulation diagram, enlarged; in-diagram labels at 16 pt in the deck's body font. Gloss "null" as "the treatment does no better than the benchmark" and "alternative" as "the improvement we want the power to detect."
No caption; the title is the conclusion.
75 s

**NEW 8 (old 15, platform diagram; optional cropped old 6 as a build). EVOLVE: one master protocol, 10 to 15 cohorts opened over time, each needing its own design**
Old 15's diagram with the SA/BA/seamless tags spelled out as single-arm / randomized / seamless. Subtitle in smaller text: *ARPA-H ADAPT platform trial. ~700 patients, 15 TBCRC sites.* Fix the ASCII "->" in the rotated label. If you want one beat of ADAPT context, crop old 6 to the three headings and icons and show it as a 15-second build before the diagram.
Define aloud: platform (one protocol, many treatment cohorts), cohort (a subtrial with its own design), and why each opens "on a clock."
Caption: *Not one calibration problem. Ten to fifteen of them, each with its own design, opened on a short clock.*
75 s

**NEW 9 (old 13). One subtrial became a two-week search**
Body: **2 weeks** / manual tuning of one subtrial's design / 8 interacting settings / **power stalled at 0.78 with 39.2 expected patients when the treatment is inactive**.
Caption: *Several more subtrials were waiting. And even if you find a feasible design, is it efficient under the objective you actually care about?*
75 s

**NEW 10 (old 16). This is not just EVOLVE: simulation-calibration recurs across adaptive trial designs**
Three cards unchanged (Phase I dose-finding, Phase II Bayesian designs, Platform trials).
Caption: *Same shape every time: many interacting settings, operating characteristics evaluated by simulation, and calibration that still requires search.*
60 s

**NEW 11 (old 14). Grid search scales poorly; random search wastes evaluations in our benchmark**
Figure unchanged; add "(Darker = better design.)" here only.
Caption: *In two dimensions a grid is easy. As dimensions grow, the number of combinations explodes. Random search spent 93% of its 2,000 evaluations on designs that fail.*
(Confirm from the code which dimension the random-search benchmark used before putting a number on the slide.)
75 s

---

## Section 2: BATON (planned 7 min)

**NEW 12 (old 17, divider). BATON**
Subline: *What should we simulate next?*
10 s

**NEW 13 (old 18). This is a familiar computational problem**
Center the two boxes vertically.
Caption: *The same computational shape as hyperparameter tuning, except feasibility is defined by hard statistical constraints.*
45 s

**NEW 14 (old 19). BATON does not need a closed-form trial model. It needs a simulator.**
Left box rewritten:
- **BATON**: Bayesian Adaptive Trial OptimizatioN
- **Constrained Bayesian optimization**: Gaussian-process surrogates learn power, type I error, and enrollment from the simulations already run, and guide which candidate to evaluate next.
- **You specify**: a power floor, a type I error cap, and what to minimize (expected N, maximum N, or a mix).
- **Your simulator**: a parameterized design family; settings and clinical scenarios in, operating characteristics out.
Loop diagram unchanged.
Spoken, not on the slide: "We do not need a formula that maps thirteen design parameters to power, type I error, and enrollment. We need to be able to simulate a design." Do not say "black box" aloud; to this room it means opaque AI.
Caption: *A closed loop: simulate, learn from everything seen, choose the next design, repeat.*
90 s

**NEW 15 (old 21). A surrogate predicts designs we have not paid to simulate**
Figure unchanged. Sixty seconds; the room knows GPs.
Caption: *Design settings in, trial behavior out, and the model says how sure it is.*
60 s

**NEW 16 (old 22). The next simulation goes where it has the greatest expected value for improving the feasible design**
Figure unchanged.
Caption: *Balance the potential improvement in the objective against the probability that the design satisfies the constraints.*
(This is expected constrained improvement; backup B1 has the formula if asked.)
75 s

**NEW 17 (old 20 as left panel + old 23 right panel). The seed sketches the map. Then BATON proposes each batch.**
Left: space-filling seed. Right: model-guided search. Remove the connecting lines. Do not jitter real design coordinates; show multiplicity with marker size or the subtitle *30 evaluations; repeated cells overlap.*
No caption.
60 s

**NEW 18 (old 24). Spend precision where it matters**
Delete the gray descriptions and the two vertical side labels. Under each stage box put one large sublabel: **3,000 trials each** / **10,000 each** / **5,000 then 10,000** / **5 seeds x 10,000, all must pass**. Narrate the rest.
Caption: *Cheap screening for the many, expensive re-checks for the few, multi-seed verification for the one design you report.*
75 s

---

## Section 3: The evidence (planned 16 min)

**NEW 19 (old 28, divider). The evidence**
Subline: *Feasibility, efficiency, and richer designs*
10 s

**NEW 20 (old 29). On a problem with a known answer, BATON recovers the optimum or a near-neighbor**
Subtitle: *Simon's two-stage design: enroll n1, stop if too few responses, otherwise enroll to n. Every candidate in this design class can be enumerated, so the exact constrained optimum is known.*
Figure: annotations at 16 pt; y-axis relabeled *Expected patients if the treatment is inactive (best feasible so far)*; delete the "next admissible design 17.89" annotation.
Caption: *10 random starts: 8 return Simon's exact optimal design; 2 land 0.15 patients away.*
105 s

**NEW 21 (old 46 table, replacing old 30). Across 12 benchmarks, BATON returned a feasible design in all 12; the median objective gap was 2.5%**
The five-row table from old 46, enlarged to fill the slide. Subtitle: *One run per scenario, one seed each; ratio is BATON's expected null enrollment over Simon's exact optimum.*
Caption: *Reported designs are verified directly for feasibility. Objective optimization remains approximate.*
75 s

**NEW 22 (old 47, promoted). In EVOLVE, BATON found a feasible design where manual tuning had stalled**
Two columns, large: **MANUAL**: 2 weeks / power 0.78 / **39.2 expected patients if inactive** / infeasible; **BATON**: ~4-hour workflow / power 0.86 / **11.7 expected patients if inactive** / feasible. Small line: *Illustrative comparison, not a controlled benchmark across analysts. Same simulator, same constraints.*
No caption; this is the callback to NEW 9.
75 s

**NEW 23 (old 25 + old 26, as a build). Two designs meet the same statistical requirements. They produce very different trials.**
Build 1: *The feasible region can contain many designs that all satisfy power at least 0.80 and type I error at most 0.10. Which one should we optimize for?*
Build 2: the table from old 26, widened, with subtitle *EVOLVE's triple-negative breast cancer (TNBC) cohort, calibrated under different objectives:*
Caption: *One quits losers quickly. One caps the worst-case commitment. Neither is universally better.*
90 s

**NEW 24 (old 27). The objective should reflect the trial you actually want**
Three cards; each card title becomes the unified label: **H0-Optimal (quit losers quickly)**, **Minimax (cap the worst case)**, **Admissible (the compromise)**. Add "H0: the treatment does no better than the benchmark" under the first card.
Caption: *Frequentist two-stage designs made these tradeoffs explicit for decades. BATON makes the same tradeoffs explicit when exhaustive enumeration is impractical.*
75 s

**NEW 25 (old 31). EVOLVE's TNBC cohort: three objectives, three designs**
Chart unchanged except the x-axis relabel. Bullets with unified labels:
- H0-Optimal: 47 max, **11.7** if the treatment is inactive
- Admissible: 31 max, **11.9**
- Minimax: 30 max, **22.8**
Caption: *Allowing one more patient in the maximum saves about eleven patients on average when the treatment is inactive. That is why we preferred the Admissible design.*
(If the protocol confirms this exact design was implemented, "That is the design we ran" is stronger; otherwise keep the line above.)
90 s

**NEW 26 (old 32). Search makes a 13-parameter seamless design practical to calibrate**
Figure unchanged; in-figure italic labels at 16 pt; drop the "posterior Pr(...)" labels on the SA and BA rows. Say aloud: "This is the kind of design we can now seriously consider, because calibration is tractable."
Caption: *Screen first with a single-arm stage, then demand randomized evidence from the cohorts that earn it. Thirteen interacting parameters, calibrated by automated search.*
Spoken: "The first stage lets us screen with fewer patients before committing to randomized evidence."
105 s

**NEW 27 (old 33). Two philosophies converged on the same 13-parameter design**
Chart: keep H0-Optimal and Minimax = Admissible; gray H1-Optimal and Balanced-EN and label them "other objectives," or drop them.
Caption: *Minimax and Admissible calibrated to the identical design. That is not a coincidence, and the next slide shows why.*
60 s

**NEW 28 (old 34). The gate rarely opens when the treatment is inactive, so the two objectives collapse**
Bar chart; match whichever objectives survived on NEW 27.
Caption: *When the treatment is inactive, only ~4% of trials reach stage 2. Expected enrollment therefore changes very little with stage-2 size, so the maximum-enrollment component drives the Admissible solution toward Minimax. H0-Optimal can tolerate a larger stage 2 because its objective never penalizes maximum N.*
(The one caption allowed to run three lines.) Say: "In this design region the two objectives effectively align." Close with: "The search became an instrument for understanding the design."
90 s

**NEW 29 (old 35). BATON informed EVOLVE's operational decisions**
Four boxes:
- **Capacity**: BATON's feasible frontier was used to lock maximum N about 3 months before first enrollment.
- **Interim calendar**: look spacing came out of the search and set the safety board's analysis schedule.
- **Program planning**: enrollment and timeline projections across 10 to 15 sequential subtrials.
- **Turnaround**: in our EVOLVE workflow, a feasible design in under 45 minutes per run; full workflow about 4 hours.
Caption: *In EVOLVE we generally chose the Admissible designs: efficient enrollment, early stopping, bounded capacity.*
75 s

**NEW 30 (old 36, rebuilt native). BATON is designed as a general framework, not an EVOLVE-specific tool**
No manuscript screenshot. BATON hex logo, then three native lines: **Manuscript under review at JASA** / **Open-source R package** / **Bring your own trial simulator**. Thirty seconds, no more.
30 s

---

## Ending (planned 5 min)

**NEW 31 (old 38). Early decisions become downstream commitments**
Sotorasib box; change the last line to *median PFS was similar at 240 mg and 960 mg*; make the source line visible at 16 pt. Do not say "similar efficacy" (ORR and OS trended toward 960).
Caption: *The optimal-dose question remained unresolved until after approval.*
60 s

**NEW 32 (old 40). We optimize the trial. The program is what succeeds.**
Phase diagram with the arrows relabeled *choice carries forward* / *uncertainty carries forward* and the confirmatory box *must resolve remaining uncertainty*. Keep the "What if we reverse the logic?" box.
Caption: *Long-term idea: phase structure becomes a design variable.*
75 s

**NEW 33 (old 39). We are extending the same search logic to decisions across development**
Three cards:
- **Across possible futures** (BATON-C, in progress, with Amber Young): optimize over a prespecified family of plausible truths, not one.
- **Earlier in development** (BATON-D, in progress): optimize dose-finding rules for safety and for what every later trial inherits.
- **Across trials** (long-term goal): optimize dose, population, interim, and confirmatory decisions as one linked program.
No caption; the title is the claim, and it is labeled as work in progress.
60 s

**NEW 34 (old 52, promoted). What I am not arguing**
Three lines:
- *Not that hand-designed trials are miscalibrated. In complex design spaces, the alternatives and their tradeoffs may never get explored systematically.*
- *Not that one philosophy is right. H0-Optimal and Minimax encode different, legitimate priorities.*
- *Not that optimization replaces statisticians. It automates the search, not the judgment.*
Deliver in 20 seconds, not 45. Say only: "The point is not to replace statistical judgment; it is to automate the search that supports it." Then straight to the takeaways.
20 s

**NEW 35 (old 41, rewritten). What I hope you remember**
1. For complex adaptive trials, simulation tells us how a candidate behaves; design is the search for what to try next.
2. BATON searches the simulator for feasible, efficient designs and makes the patient-use tradeoffs among them explicit.
3. Making calibration tractable lets us seriously consider richer adaptive trials, and we are extending the same search logic to other decisions across development.
60 s

**NEW 36 (old 42). Acknowledgments**
20 s

**Questions (old 43).** Email, lab site, R package, JASA line.

---

## Planned timing

| Portion | Slides | Planned | Delivered (expect +12%) |
|---|---|---:|---:|
| Opening | 1 to 2 | 1:00 | 1:10 |
| Trial teaching and the EVOLVE problem | 3 to 11 | 10:40 | 12:00 |
| BATON method | 12 to 18 | 6:55 | 7:45 |
| Evidence | 19 to 30 | 14:40 | 16:30 |
| Ending and takeaways | 31 to 36 | 5:20 | 6:00 |
| **To "Questions"** | | **38:35** | **43:30** |

## Backup slides (after Questions)

- B1 (old 45) The surrogate and the acquisition; labels at 16 pt.
- B2 (old 30) The 12-benchmark scatter, in case someone wants the plot.
- B3 (old 48) What the constraints and parameters actually are.
- B4 (old 49) Related work and what BATON adds.
- B5 (old 50) Known failure modes and limits.
- B6 (old 51) Bidirectional stopping variants.
- B7 (old 53) Ten seeds, one design. Replace "It is what regulatory credibility requires" with "That is the bar for a design going into a regulatory submission."
- B8 (old 54) The randomized-cohort frontier.
- B9 (old 8) The ARPA-H ask and the N-of-1 addition, for questions about requirements.
- B10 (old 6 + old 7, cropped) ADAPT technical areas and EVOLVE team, for questions about the program.

## Cut from the deck entirely

Old 4 (website screenshot), old 5 (future-state figure), old 10 (frequentist convenient property; its content is the last row of NEW 6), old 37 (54% and 21 of 138).

## Checkpoints during delivery

- NEW 11 done: ~13 min
- NEW 18 done: ~21 min (if this slide goes up after 22 min, start trimming now)
- NEW 26 done: ~31 min
- NEW 30 done: ~37 min
- NEW 35 up: ~42 to 43 min
- Questions: 44 to 45 min

Rehearse tonight to 39 to 41 minutes, not 45. The room adds the rest.

## If running long on the day

Cut in this order: NEW 31 Sotorasib (60 s), NEW 34 (20 s), NEW 30 (30 s), NEW 15 (60 s), NEW 27 folded into NEW 28's first build (60 s). Live rule: at NEW 30 past 39 minutes, skip 31; past 40, skip 31 and 34 and keep 32 to 33 short. Do not cut NEW 27 and 28 early; they are what separates a research talk from a software demo for the faculty in the room.

## Three lines to confirm against the paper or protocol before tomorrow

1. NEW 11: which dimension the 2,000-evaluation random-search benchmark used.
2. NEW 25: whether the Admissible TNBC design shown was the one implemented.
3. NEW 31: the exact PFS medians and the ORR/OS direction from the ODAC materials.
