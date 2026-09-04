---
title: "Planning under uncertainty: delivery outline (v2)"
subtitle: "UNC Computational Medicine Seminar, September 4, 2026, 45 minutes"
format:
  pdf:
    geometry: margin=0.8in
    fontsize: 10pt
    colorlinks: true
---

**Three sections, one argument; 43 main slides + 11 backups.** Total advances about 80. Reach the program-failure slide (37) with ~10 minutes left; slides 37 to 41 get 6 to 7 protected minutes.

**Spoken pivots:** Section 1 to 2: *"The problem was never simulation. It was what to simulate next."*
Method to philosophy (slide 25): *"Which of the feasible designs should we optimize for?"*
Section 2 to 3: *"All of this is machinery unless it earns trust and changes the actual trial."*

## The main deck, in order

| # | Slide | Adv | The one thing to land |
|--:|:------|:---:|:----------------------|
| 1 | Title |  | Symposium-style title, transparent hex, logo strip. No lab intro. |
| 2 | Overview |  | 30 to 45 seconds spoken over the bullets; section 3's second line is a promise, not a spoiler. |
| 3 | Section 1: The problem |  | Divider; optional spoken hook already lives on the next slide's notes. |
| 4 | ADAPT challenge |  | ARPA-H asked for biomarkers, treatments, trials co-evolving. One sentence, fast. |
| 5 | Future state |  | Official ARPA-H longitudinal schematic: measure before, during, after; therapies switch. One sentence. |
| 6 | ADAPT components |  | Three integrated components; our team leads the clinical-trial one. |
| 7 | UNC team + EVOLVE |  | Full org chart, steering committee and stat working group outlined. |
| 8 | What ARPA-H asked | 3 | Excerpts, new-ask, the ask, meme. Let each be read. |
| 9 | Collision |  | The right column is the rest of the talk. 30 s. |
| 10 | One equation | 1 | For a simple fixed design: one equation, one unknown. Hold that thought. |
| 11 | Bayesian adaptive knobs | 1 | Timelines, then: every interim decision rule is a setting; 8 to 13 interacting choices. |
| 12 | Count them | 1 | FDA targets up top; null box (orange) and alternative box (blue); feasible = targets met. Then THE pivot. |
| 13 | Two weeks | 1 | First person. Power stalled at 0.78; more subtrials waiting. |
| 14 | Alternatives fail | 2 | Grid panel, then random panel: 136/2,000 = 6.8%. Manual tuning already covered on 13. |
| 15 | 10-15 subtrials |  | Section 1 escalation: not one problem, 10 to 15, on a short clock. |
| 16 | Not unique | 1 | First person: phase I and II hit the same wall. Same shape every time. |
| 17 | Section 2: BATON |  | Speak the pivot: the problem was never simulation. |
| 18 | ML bridge | 2 | ML side first, then trial side, then the constraint difference. |
| 19 | BATON + loop | 2 | Card first, then the loop, then the landing. |
| 20 | Initial sample |  | BATON step 1: space-filling seed, no model yet. One beat. |
| 21 | Surrogate map | 2 | Points first, then the fitted curve with its band: settings in, operating characteristics out. |
| 22 | Acquisition |  | The orange point is not necessarily at the predicted best. |
| 23 | Seed vs walk | 2 | The payoff: seed sketches the map, model places every evaluation after. |
| 24 | Fidelity ladder |  | Explore at 3k, validate top designs at 10k, escalate only if needed, verify at 5 seeds. Never say "three rounds". |
| 25 | Hinge | 1 | Finding feasible designs is not the whole problem. Slow down. |
| 26 | Two designs | 1 | Different objectives; neither universally better. |
| 27 | Philosophies | 4 | Merged: feasibility is not preference; three philosophy cards; transport claim. |
| 28 | Section 3: Evidence |  | Speak the pivot: does it earn trust, and did it matter? |
| 29 | Simon unit test |  | 10 random starts: 8 return the exact Simon design, 2 near-neighbors 0.15 away. Never "recovers". |
| 30 | Benchmark |  | 12 scenarios: 12/12 feasible, 4/12 exact, 2.5% median, 13.5% worst. |
| 31 | Frontier: single-arm | 1 | EVOLVE's TNBC cohort; speak the randomized price line (B9). |
| 32 | Seamless |  | 13 interacting parameters make manual calibration impractical. |
| 33 | Collapse |  | The identical design. Label now clear of the frontier line. |
| 34 | Gate |  | Stage 1 dominates under the null; objectives align. Search as instrument. |
| 35 | Operational impact | 5 | Boxes, then the Admissible line. Bridge moves to 36. |
| 36 | JASA + software |  | Cropped title page + hex, 20 s, then SPEAK THE BRIDGE here: is the trial the right unit? |
| 37 | Program failure | 3 | Hero numbers: 54% late-stage; 21 of 138 dose PMRs. Well designed locally, poorly optimized globally. |
| 38 | Sotorasib | 1 | 960 mg carried to approval; FDA-required 240 vs 960; similar PFS at one-quarter the dose. |
| 39 | Extensions | 3 | Toward phaseless development: possible futures, earlier decisions, across trials. Goal line. |
| 40 | Development programs | 3 | Pipeline dims, reversal chain, then huge: phase structure becomes a design variable. 2+ min. |
| 41 | Summary | 3 | Three lines; spoken close on which workable design we want, and why. |
| 42 | Acknowledgments |  | MPIs and statisticians by name; funding is the footer row. |
| 43 | Questions |  | Leave up; routing index in notes. |

## Backups (44 to 54)

B1 GP/acquisition (code-verified answers) · B2 Simon per-scenario ·
B6 manual-vs-BATON in full · B3 parameters and assumed truths · B5 related
work · B4 bidirectional · B10 known failure modes and limits · B7 what I am
not arguing · B8 ten-seed reproducibility · B9 randomized-cohort frontier.

## If running long

Planned cuts already made. Remaining option: slide 9 (collision table), one
spoken sentence. Emergency valve: past 30 minutes at the Section 3 divider, speak
slide 29's headline numbers while advancing to the EVOLVE frontier.

## Q&A quick routes

Conventions: slide 10 notes. Bayesian-frequentist hybrid: slide 11 notes.
Random search "beat you": slide 14 notes, then 29 to 30. GP/acquisition/CRN detail:
backup B1. Simon seed accounting: slide 29 notes, B2. Collapse artifact:
slide 33 notes. Unspent alpha: slide 31 notes. Multi-objective BO, philosophy
lock: slide 27 notes. Two-week detail: B6. Company/translation: one
sentence, disclose verbally.
