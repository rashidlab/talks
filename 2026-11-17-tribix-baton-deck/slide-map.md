# Slide map for the current TriBix keynote

Updated 2026-11-16 for the published deck. It has 39 main slides through Questions, a references slide, a backup divider, and 14 backup slides (55 pages). The sections below this table are historical. Their slide numbers refer to earlier versions of the deck and no longer match.

| Current | Menu title | Slide title |
|--:|:--|:--|
| 1 | Title | (divider) |
| 2 | Section 1: The stakes | (divider) |
| 3 | Phases | Drug development usually follows three phases before approval |
| 4 | Operation TrialBlazer | The U.S. is concerned about its lead in early clinical research |
| 5 | Time and cost | Developing one new therapy is slow and expensive |
| 6 | Late failure | Many problems become apparent only in late-stage trials |
| 7 | Sotorasib | Early decisions become downstream commitments |
| 8 | The open question | How best to design early trials for later success is not yet clear |
| 9 | The turn | Better early trials are possible. Designing them is the hard part. |
| 10 | Section 2: The design problem | (divider) |
| 11 | What a trial is | A clinical trial is an experiment built for a decision |
| 12 | Fixed versus adaptive | An adaptive trial can act on an interim result |
| 13 | Feasibility | A good design has to meet four requirements at once |
| 14 | Count them | Simulation tests one design in two scenarios |
| 15 | 10-15 subtrials | One EVOLVE protocol can host 10 to 15 subtrials |
| 16 | Manual tuning | I could not verify that a hand-tuned design met the power target |
| 17 | Alternatives fail | A grid search can produce 100 million candidate designs |
| 18 | Section 3: BATON | (divider) |
| 19 | BATON in one picture | BATON in one picture |
| 20 | Fitting the prediction model | A nonlinear model predicts how untested designs might behave |
| 21 | Choosing the next design | BATON balances potential improvement with feasibility |
| 22 | Section 4: BATON in practice | (divider) |
| 23 | Known answer and 12 benchmarks | Sanity check: a known answer tells us how close BATON gets |
| 24 | Grid contrast | EVOLVE designs have too many settings to try every one |
| 25 | Operational impact | EVOLVE had to settle each subtrial’s max sample size in advance |
| 26 | Two designs | Same requirements, different trials |
| 27 | Objectives and frontier | EVOLVE's TNBC subtrial: three objectives, three designs |
| 28 | Seamless design example | The same workflow calibrated a more complex trial |
| 29 | Imperfect biomarkers | What if the trial assumes perfect classification? |
| 30 | PSA: AI-generated simulations | A public service announcement on AI-written simulations |
| 31 | Judgment stays with you | You can’t evaluate what you don’t know, and you should never outsource your judgment to an external tool. |
| 32 | Section 5: Whole-program calibration | (divider) |
| 33 | What Phase III inherits | What does Phase III inherit? |
| 34 | Illustrative confirmation paths | An early dose rule can shape Phase III confirmation |
| 35 | PARTNER and reuse of evidence | How PARTNER counted early patients in the final comparison |
| 36 | Whole-program search and early evidence | Extend BATON from one trial to the whole program |
| 37 | BATON roadmap | Where BATON goes next |
| 38 | Acknowledgments | Acknowledgments |
| 39 | Questions | (divider) |
| 40 | References | References |
| 41 | Backup | (divider) |
| 42 | B1: GP + ECI | Backup: the surrogate and the acquisition |
| 43 | B2: Benchmark plot | Backup: ten starts on one Simon benchmark |
| 44 | B3: Parameters | Backup: what the constraints and parameters actually are |
| 45 | B4: Related work | Backup: related work and what BATON adds |
| 46 | B5: Limitations | Backup: known failure modes and limits |
| 47 | B6: Bidirectional | Backup: bidirectional stopping variants |
| 48 | B7: Reproducibility | Backup: ten seeds, one design |
| 49 | B8: Randomized frontier | Backup: the randomized-subtrial frontier |
| 50 | B9: ARPA-H ask | Backup: the ARPA-H ask and the N-of-1 addition |
| 51 | B10: ADAPT + team | Backup: ADAPT technical areas and the EVOLVE team |
| 52 | B11: Benchmark table | Backup: Across 12 benchmarks: feasible in all 12, mean objective gap 3.6% |
| 53 | B12: Search initialization | Backup: The seed sketches the map. Then BATON proposes each batch. |
| 54 | B13: Seamless trial | Backup: Calibrating a seamless design |
| 55 | B14: Verification | Backup: verifying the final design with fresh simulations |

Changes on 2026-11-16, in order of the deck. The Overview slide was removed. Slide 9 became the Section 1 close. Slide 13 was rebuilt around four requirements. The BATON picture and workflow slides were merged into slide 19. The verification slide moved to backup B14. Section 4 was renamed BATON in practice and gained the grid contrast slide (24). The two dose slides were merged into slide 34, and the two whole-program slides into slide 36. A references slide was added after Questions.

## Historical map from CompMed to the prior TriBix deck

## Alignment pass, 2026-11-14 (BATON 0.4.0 package)

The table below is renumbered for the alignment pass. Deck now 54 slides, 42 main through Questions. One slide added (21, "BATON in one picture"), two backups removed (old CompMed 27 and 28, previously B12 and B13). Every "New" number from 21 up moved by one. Slides changed in place: 5, 6, 7, 8, 9 (illustrations), 15 (0.4.0 counts), 17 (retitled "Tuning one subtrial by hand did not reach the power target", no numbers), 18 (retitled "Grid search scales poorly, and random search rarely finds the best design", haystack figure), 27, 28 (retitled "In EVOLVE's triple-negative cohort, BATON returned three feasible designs"), 29, 30, 31 (notes), 32, 34, and backups B2, B6, B7, B8, B11. Details in align-report.md.


Old numbers are CompMed v3 (baton-compmed-v3.qmd). New numbers are baton-tribix.qmd as rendered after the fix pass of 2026-11-14 (55 slides, 41 through Questions). The table was first generated by build_tribix.py, which is now stale and must not be rerun. slide-numbers.txt is the pre-fix-pass key and is superseded by this table.

| Old | Slide | New | Status | Note |
|---|---|---|---|---|
| 1 | Title | 1 | kept | venue line and footer changed to NextGen TriBix Symposium, November 17, 2026; notes 'open on the stakes' |
| 2 | Overview | 2 | kept | rewritten for five sections per the design doc (57 words) |
| 3 | Divider 1: The problem | 11 | moved | becomes Divider 2, 'The design problem', same question |
| 4 | A clinical trial is an experiment built for a decision | 12 | moved | unchanged |
| 5 | Bayesian adaptive trials decide as they go | 13 | split (was merged into 12) | fix pass: own slide again; new title and patient-terms boxes (PI request), old 5 title kept as the closing line, old 5 caption to notes |
| 6 | Feasible designs meet prespecified targets | 14 | split (was merged into 12) | fix pass: old 6 title and boxes word for word, null gloss line and calibration definition added; table spoken from notes |
| 7 | Simulation tells us how one candidate behaves | 15 | moved | fix pass: figure regenerated so '10,000 times' clears the box (visual HIGH) |
| 8 | EVOLVE: one master protocol | 16 | moved | one-line EVOLVE gloss added (first visible use); old 10 content in notes |
| 9 | One subtrial became a two-week search | 17 | moved | alignment pass: retitled "Tuning one subtrial by hand did not reach the power target", unsourced numbers removed |
| 10 | This is not just EVOLVE | 16 (notes) | cut to notes | content and notes moved to the notes of slide 16 |
| 11 | Grid search scales poorly | 18 | moved | alignment pass: haystack figure, withdrawn random-search claim replaced by the 0.4.0 Table 5 line |
| 12 | Divider 2: BATON | 19 | moved | becomes Divider 3 |
| 13 | This is a familiar computational problem | 20 | moved | unchanged |
| 14 | BATON needs a simulator, not a formula | 22 | moved | unchanged |
| 15 | A surrogate predicts designs | 23 | merged | with old 16; both figures kept as a three-build stack, captions to notes |
| 16 | The next simulation goes where | 23 | merged | title becomes the caption of slide 22 |
| 17 | The seed sketches the map | 24 | moved | unchanged |
| 18 | Spend precision where it matters | 25 | moved | unchanged |
| 19 | Divider 3: The evidence | 26 | moved | becomes Divider 4, 'The evidence and the limits', new question |
| 20 | On a problem with a known answer | 27 | merged | with the summary line of old 21; Simon explainer to notes; fix pass: figure 335px, 12-benchmark line set apart from the landing line with 'Exact Simon design in 4 of 12' added (accuracy A-1) |
| 21 | Across 12 benchmarks | 27 and B11 | merged | summary line and caveat on slide 26; table to backup B11 |
| 22 | In EVOLVE, BATON found a feasible design | 28 | moved | alignment pass: manual box removed, retitled "In EVOLVE's triple-negative cohort, BATON returned three feasible designs", 0.4.0 values; notes call back to slide 17 |
| 23 | Same requirements, different trials | 29 | moved | TNBC expanded to 'triple-negative (TNBC)' |
| 24 | The objective should reflect the trial you want | 30 | merged | folded into old 25; three glosses on the list, slide text and notes to notes of 27 |
| 25 | EVOLVE's TNBC cohort: three objectives | 30 | merged | list items carry the objective glosses |
| 26 | Search makes a 13-parameter seamless design practical | 31 | moved | old 27 and 28 summarized in notes; fix pass: second build zooms into the seamless panel (visual HIGH) |
| 27 | Two philosophies converged | removed | removed (alignment pass) | BATON 0.4.0 has no Admissible seamless design, so the collapse story and the gate slide no longer hold |
| 28 | The gate rarely opens | removed | removed (alignment pass) | BATON 0.4.0 has no Admissible seamless design, so the collapse story and the gate slide no longer hold |
| 29 | BATON informed EVOLVE's operational decisions | 32 | moved | bridge note retargeted to slide 35 |
| 30 | BATON is designed as a general framework | 36 | moved | unchanged, carries the bridge question |
| 31 | Problems often emerge late | 7 | moved | late-failure plant line added (PI 2026-11-14), hedged and set apart from the citation in the fix pass (accuracy D-1); honesty line moved to slide 36 notes |
| 32 | Early decisions become downstream commitments | 8 | moved | PFS spelled out; 'Source:' label dropped for the cap |
| 33 | We optimize the trial. The program is what succeeds. | 37 | moved | callback to slides 7 and 8 added to notes |
| 34 | Extending the same search logic across development | 39 | moved | 'with Amber Young' restored to the card by the PI (2026-11-14 hand edit) |
| 35 | What I hope you remember | 40 | kept | rewritten: thesis verbatim, two takeaways, closing line on time, cost and patients |
| 36 | Acknowledgments | 41 | moved | unchanged |
| 37 | Questions | 42 | moved | Q&A routing index rebuilt for the new numbering |
| 38 | Backup divider | 43 | moved | unchanged |
| B1 | GP + ECI | 44 | moved | unchanged (backup number kept) |
| B2 | Benchmark scatter | 45 | moved | unchanged (backup number kept) |
| B3 | Parameters | 46 | moved | unchanged (backup number kept) |
| B4 | Related work | 47 | moved | unchanged (backup number kept) |
| B5 | Limitations | 48 | moved | unchanged (backup number kept) |
| B6 | Bidirectional | 49 | moved | unchanged (backup number kept) |
| B7 | Ten seeds | 50 | moved | unchanged (backup number kept) |
| B8 | Randomized frontier | 51 | moved | unchanged (backup number kept) |
| B9 | ARPA-H ask | 52 | moved | unchanged (backup number kept) |
| B10 | ADAPT + team | 53 | moved | unchanged (backup number kept) |
| new | Divider 1: The stakes | 3 | new | 'Why does a new therapy take so long?' |
| new | N1 Developing one new therapy is slow and expensive | 4 | new | 10.5 years (BIO 2021) and $1.1 billion (Wouters 2020, corrected 2022), VERIFIED rows |
| new | N2 Phase I cancer trials in Australia rose fourfold in ten years | 6 | new | retitled in the fix pass (accuracy B-4); 18 to 75 (Hitchen 2024) visible, China 2021 (HHS) spoken only |
| new | Phases I, II, III (fix pass) | 5 | new | native three-box strip, clarity deck-level HIGH; its own slide because N1 is near the cap |
| new | N6 How best to design early trials for later success is not yet clear | 9 | new | the open question, three reasons (PI 2026-11-14); separate slide because slide 7 had no room |
| new | N3 More efficient trials exist. They are harder to design. | 10 | new | thesis line |
| new | N4 What the AI does here, and what it does not | 33 | new | fix pass: landing line defines AI here, items shortened |
| new | N5 Where the AI search falls short | 34 | new | plain-language B5; retitled and corrected in the fix pass (A-3, D-7) |
| new | Divider 5: The program | 35 | new | 'What if we designed the whole path at once?' |
| new | N7 Ask the same kind of search how to set up early trials for later success | 38 | new | late-failure payoff (PI 2026-11-14); separate slide because old 33 and 34 had no room |
| new | BATON in one picture (needle graphic, alignment pass) | 21 | new | after "This is a familiar computational problem"; fig_needle_baton.png from make_fig_needle_haystack.R |

Rows: 48 old (37 main, the backup divider, B1 to B10) plus 11 new = 59.

Counts per status: cut to notes 1, kept 3, merged 6, split 2, moved 34, removed 2, new 11.

Slide count check: kept 3 + moved 34 + split 2 + merged 6 rows giving 3 slides + B11 split out of old 21 = 43 slides from the old deck, plus 11 new = 54, which equals the 54 pages of the rendered PDF (deck_qa.py, alignment pass). Through Questions: 42.

Dividers (slides 3, 11, 19, 26, 35) are roadmap outlines since the fix pass: the five Overview section names in order, the current one highlighted with its question beneath, the others dimmed (#8FA3BF on navy, 5.6:1).

## Late-failure thread (PI, 2026-11-14, fix pass wording)

- Plant: slide 7 (old 31) carries one visible line, set apart from the Hwang citation, "Some may be set up by early choices. Early trials could be designed with later ones in mind." Notes give dose, sample size and signal to continue, say it is our view and not the paper's, and "we come back to this at the end". No method named.
- Open question: slide 9 (N6) right after sotorasib, three reasons, with the visible landing line "We return to this at the end."
- Payoff: slide 38 (N7) between the program slide (37) and the extensions (39). Opens with the visible line "Back to the 54% that failed late." and closes on "Work in progress. No result yet."
- Summary: slide 40 second takeaway, "The same search logic is being extended to early trials for later success."
