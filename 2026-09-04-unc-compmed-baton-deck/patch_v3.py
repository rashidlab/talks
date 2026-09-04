b = open('build_v3.py').read()
def swap(a, c, tag):
    global b
    assert a in b, tag; b = b.replace(a, c)

old4 = b[b.index("N[4] = '''"):b.index("# NEW 5 (old 11)")]
new4 = '''N[4] = \'\'\'## A clinical trial is an experiment built for a decision {data-menu-title="What a trial is"}

::: {.columns style="margin-top: 2.2em;"}
::: {.column width="33%"}
::: {.frame-box style="min-height: 9em; font-size: 0.8em;"}
**The question**<br/>Does the treatment beat a benchmark or a control?
:::
:::
::: {.column width="33%" .fragment}
::: {.frame-box style="min-height: 9em; font-size: 0.8em;"}
**How patients are used**<br/>Single-arm (everyone gets the treatment, compared with a benchmark) or randomized (treatment versus control).
:::
:::
::: {.column width="33%" .fragment}
::: {.frame-box style="min-height: 9em; font-size: 0.8em;"}
**Two errors**<br/>Advance a treatment that fails, or drop one that works.
:::
:::
:::

::: {.landing .fragment}
Two choices dominate: how many patients, and which rule decides.
:::

::: {.notes}
**Say aloud (moved off the slide for the 60-word cap):** "Traditional development is organized in phases: choose a dose, look for a signal, then confirm it. Each phase is a trial with its own rule for go or stop." Then the caption: for the calibration problems in this talk, two choices dominate.

**Glosses at first use:** single-arm (everyone gets the study treatment; we compare with a prespecified benchmark), randomized (patients are assigned to treatment or control), objective (the quantity we try to make small, here patients). PFS, when it comes up: "time until the cancer worsens or the patient dies."

**Delivery:** 90 seconds. Slow. This is the slide a genomicist needs.
:::
\'\'\'

'''
b = b.replace(old4, new4)

old6 = b[b.index("N[6] = ("):b.index("# NEW 7 (old 12 minus boxes)")]
new6 = '''N[6] = ('## Feasible designs meet prespecified error-rate and power targets {data-menu-title="Feasibility"}\\n\\n'
        + '::: {.columns}\\n::: {.column width="50%"}\\n::: {.frame-box style="font-size: 0.78em; min-height: 5.2em; border-color: #E07C24;"}\\n**Type I error (false go)**<br/>\\nFraction of simulated trials declaring efficacy when the treatment is inactive. Cap here: **0.10**.\\n:::\\n:::\\n'
        + '::: {.column width="50%"}\\n::: {.frame-box style="font-size: 0.78em; min-height: 5.2em; border-color: #2E6A9F;"}\\n**Power (true go)**<br/>\\nFraction declaring efficacy when the treatment works as hypothesized. Floor here: **0.80**.\\n:::\\n:::\\n:::\\n\\n'
        + '::: {.fullwidth-table .fragment style="margin-top: 1.2em;"}\\n|  | A typical trial | EVOLVE |\\n|:--|:--|:--|\\n| Designs needed | One | Many subtrials |\\n| Design parameters | Few | Many, interacting |\\n| Power and type I error | Often closed-form | Simulation only |\\n:::\\n\\n'
        + '::: {.notes}\\n**Say aloud:** a design meeting both targets is feasible; "in the examples that follow, feasible means power at least 0.80 and type I error at most 0.10." Define the two terms in one breath on the boxes: "power is the chance the trial correctly advances a treatment that works; type I error is the false-go rate when it does not." The table\\'s last row is the point: for these designs, power and type I error come only from simulation. (Timing row dropped for the word cap; say it: "and we had to design repeatedly, on a clock.")\\n\\n**Q&A pocket:** *Why 0.10 here?* Non-registrational screening subtrials; a confirmatory trial carries a confirmatory ceiling (0.05 is the confirmatory convention).\\n:::\\n')

'''
b = b.replace(old6, new6)

swap('c = title(S[19], "BATON does not need a closed-form trial model. It needs a simulator.")', 'c = title(S[19], "BATON needs a simulator, not a closed-form trial model")', 'n14t')
swap('''"""**BATON**: Bayesian Adaptive Trial OptimizatioN

**Constrained Bayesian optimization**: Gaussian-process surrogates learn power, type I error, and enrollment from the simulations already run, and guide which candidate to evaluate next.

**You specify**: a power floor, a type I error cap, and what to minimize (expected N, maximum N, or a mix).

**Your simulator**: a parameterized design family; settings and clinical scenarios in, operating characteristics out.""", "n14card")''',
'''"""**BATON**: Bayesian Adaptive Trial OptimizatioN

**Constrained Bayesian optimization**: surrogates learn power, type I error, and enrollment from each simulation and choose the next candidate.

**You specify**: a power floor, a type I error cap, what to minimize.

**Your simulator**: settings and scenarios in, operating characteristics out.""", "n14card")''', 'n14card')
swap('c = c.replace(\'::: {.frame-box style="font-size: 0.7em;"}\', \'::: {.frame-box style="font-size: 0.64em;"}\')', 'c = c.replace(\'::: {.frame-box style="font-size: 0.7em;"}\', \'::: {.frame-box style="font-size: 0.74em;"}\')', 'n14font')
swap('c = set_landing(c, "A closed loop: simulate, learn from everything seen, choose the next design, repeat.", "n14", fragment=True)', 'c = set_landing(c, "A closed loop: simulate, learn, choose the next design, repeat.", "n14", fragment=True)', 'n14cap')
swap('**Spoken, not on the slide:** "We do not need a formula', '**Spoken, not on the slide (and for the word cap):** what to minimize means expected N, maximum N, or a mix; the surrogates are Gaussian processes fit to the simulations already run. "We do not need a formula', 'n14notes')

old21 = b[b.index("N[21] = ("):b.index("# NEW 22 (old 47 rebuilt)")]
new21 = '''N[21] = ('## Across 12 benchmarks: feasible in all 12, median objective gap 2.5% {data-menu-title="Benchmark table"}\\n\\n'
         '[One run per scenario; ratio = BATON\\'s expected null enrollment / Simon\\'s exact optimum.]{.muted style="display:block; font-size: 0.85em; margin-bottom: 0.4em;"}\\n\\n'
         '::: {.fullwidth-table style="font-size: 1.15em;"}\\n| Claim | Value |\\n|:--|:-:|\\n| Feasible design returned | 12 / 12 |\\n| Exact Simon design returned | 4 / 12 |\\n| Median ratio, BATON / Simon | 1.025 |\\n| Worst-case ratio | 1.135 |\\n| Best-case ratio | 1.000 |\\n:::\\n\\n'
         '::: {.landing .fragment}\\nFeasibility is verified directly. Objective optimization remains approximate.\\n:::\\n\\n'
         '::: {.notes}\\n**Say the full sentence:** across 12 benchmark scenarios BATON returned a feasible design in all 12; the median objective gap was 2.5%.\\n\\n**Pull-from-if-needed:** The worst case (ratio 1.135) is a single-seed result; reseeding the 0.20 scenario returns the exact optimum in 8 of 10 runs (previous slide). Never compress this to "recovers the optimum" in every scenario: exact match in 4 of 12, median gap 2.5%, worst 13.5%. The scatter plot is backup B2.\\n:::\\n')

'''
b = b.replace(old21, new21)

swap('''::: {.column width="50%"}
::: {.frame-box style="text-align: center; font-size: 1.05em; line-height: 1.55; border-color: #2E6A9F;"}
**BATON**''', '''::: {.column width="50%" .fragment}
::: {.frame-box style="text-align: center; font-size: 1.05em; line-height: 1.55; border-color: #2E6A9F;"}
**BATON**''', 'n22frag')

old23 = b[b.index("N[23] = ("):b.index("# NEW 24 (old 27)")]
new23 = '''N[23] = ('## Same requirements, different trials {data-menu-title="Two designs"}\\n\\n'
         '::: {.thesis-line style="margin-top: 0.8em;"}\\nMany designs meet power at least 0.80 and type I error at most 0.10. Which should we optimize for?\\n:::\\n\\n'
         '::: {.fragment}\\n[EVOLVE\\'s TNBC cohort, calibrated under different objectives:]{.muted style="display:block; margin: 0.9em 0 0.3em 0;"}\\n\\n'
         '::: {.fullwidth-table}\\n|  | Design A | Design B |\\n|:--|:-:|:-:|\\n| Maximum patients | **47** | **30** |\\n| Expected patients, inactive treatment | **11.7** | **22.8** |\\n| Power | 0.86 | 0.94 |\\n| Type I error | 0.001 | 0.021 |\\n:::\\n:::\\n\\n'
         '::: {.landing .fragment}\\nOne quits losers quickly; one caps the worst case. Neither is better.\\n:::\\n\\n'
         '::: {.notes}\\n**Say the full title aloud:** two designs meet the same statistical requirements and produce very different trials. Build 1 is the hinge from machinery to science; let it sit, then reveal the table. Say plainly that these two arise under different objectives; they are not two outputs of one feasibility run. Caption, spoken in full: "Neither is universally better."\\n\\n**Pull-from-if-needed:** Scenario A, the platform\\'s TNBC cohort, futility-only stopping. Verified values from the philosophy comparison file.\\n\\n**Q&A pocket:** *Why care about expected N when the treatment is inactive?* Most experimental oncology drugs do not work; the ethical cost center is patients enrolled onto an ineffective therapy.\\n:::\\n')

'''
b = b.replace(old23, new23)

swap('c = rep(c, "<h4>“Quit losers quickly”</h4>', 'c = rep(c, "A feasibility criterion tells us whether a design is acceptable. It does not encode which acceptable design we **prefer**.\\n\\n", "", "n24intro")\nc = title(c, "The objective should reflect the trial you want")\nc = rep(c, "<h4>“Quit losers quickly”</h4>', 'n24intro')
swap('<span class=\\"ext-status\\">H0: the treatment does no better than the benchmark</span>\\n<p>Minimize expected N when the treatment is inactive.", "n24c1")',
     '<span class=\\"ext-status\\">H0: no better than the benchmark</span>\\n<p>Minimize expected N under the null.", "n24c1")', 'n24c1')
swap('"<h4>Minimax (cap the worst case)</h4>\\n<span class=\\"ext-status\\">worst-case commitment</span>\\n<p>Minimize maximum N.<br/><em>Tradeoff: more patients when the treatment is inactive.</em></p>", "n24c2")',
     '"<h4>Minimax (cap the worst case)</h4>\\n<span class=\\"ext-status\\">worst-case commitment</span>\\n<p>Minimize maximum N.<br/><em>Tradeoff: more patients under the null.</em></p>", "n24c2")', 'n24c2')
swap('c = set_landing(c, "Frequentist two-stage designs made these tradeoffs explicit for decades. BATON makes the same tradeoffs explicit when exhaustive enumeration is impractical.", "n24", fragment=True)',
     'c = set_landing(c, "Two-stage designs made these tradeoffs explicit for decades; BATON does so where enumeration is impractical.", "n24", fragment=True)\nc = c.replace("<p>Weighted blend of the two.<br/><em>Trades one against the other, explicitly.</em></p>", "<p>Weighted blend of the two, explicitly.</p>").replace("<em>Tradeoff: may need a larger maximum N.</em>", "<em>Tradeoff: larger maximum N.</em>")', 'n24cap')
swap('"**Say once, here:** \\"From here on', '"**Spoken (moved off the slide):** \\"A feasibility criterion tells us whether a design is acceptable. It does not encode which acceptable design we prefer.\\" Full caption: \\"Frequentist two-stage designs made these tradeoffs explicit for decades. BATON makes the same tradeoffs explicit when exhaustive enumeration is impractical.\\"\\n\\n**Say once, here:** \\"From here on', 'n24notes')

swap('"**Capacity**: BATON\'s feasible frontier was used to lock maximum N about 3 months before first enrollment."', '"**Capacity**: the feasible frontier locked maximum N 3 months before first enrollment."', 'n29a')
swap('"**Interim calendar**: look spacing came out of the search and set the safety board\'s analysis schedule."', '"**Interim calendar**: look spacing from the search set the safety board\'s schedule."', 'n29b')
swap('"**Turnaround**: in our EVOLVE workflow, a feasible design in under 45 minutes per run; full workflow about 4 hours."', '"**Turnaround**: feasible design in under 45 minutes per run; workflow about 4 hours."', 'n29c')
swap('c = c.replace("min-height: 4.0em; font-size: 0.82em;", "min-height: 5.6em; font-size: 0.88em;")',
     'c = c.replace("min-height: 4.0em; font-size: 0.82em;", "min-height: 5.6em; font-size: 0.88em;")\nc = c.replace("**Program planning**: enrollment and timeline projections across 10 to 15 sequential subtrials.", "**Program planning**: enrollment and timeline projections for 10 to 15 subtrials.")', 'n29d')
swap('c = set_landing(c, "In EVOLVE we generally chose the Admissible designs: efficient enrollment, early stopping, bounded capacity.", "n29", fragment=True)', 'c = set_landing(c, "We generally chose Admissible designs: efficient enrollment, early stopping, bounded capacity.", "n29", fragment=True)', 'n29cap')

old30 = b[b.index("N[30] = '''"):b.index("# NEW 31 (old 38)")]
new30 = '''N[30] = \'\'\'## BATON is designed as a general framework, not an EVOLVE-specific tool {data-menu-title="Framework"}

::: {.columns style="align-items: center; margin-top: 0.6em;"}
::: {.column width="60%"}
<img src="images/jasa_titlecrop.png" style="width: 100%; border: 1px solid #E6EAEF;" alt="Cropped title block of the BATON manuscript: Constrained Bayesian Optimization for Calibration of Bayesian Adaptive Clinical Trials, under review."/>
:::
::: {.column width="40%"}
<img src="images/baton_hex_official.png" style="height: 170px; display: block; margin: 0 auto 0.6em auto;" alt="Official BATON package hex sticker."/>

::: {style="text-align: center; font-size: 0.9em; line-height: 1.6; color: #13294B;"}
**Manuscript under review at JASA**<br/>
**Open-source R package**<br/>
**Bring your own trial simulator**
:::
:::
:::

::: {.notes}
**Delivery:** 20 seconds: "It is written up, under review, and the package is open source; bring your own simulator." Then speak the bridge: "BATON solved the problem in front of us. But working on it raised a more uncomfortable question. What if the trial is not actually the right unit to optimize?" Advance on the question.
:::
\'\'\'

'''
b = b.replace(old30, new30)

swap('c = set_landing(c, "The optimal-dose question remained unresolved until after approval.", "n31", fragment=True)',
     'c = set_landing(c, "The optimal-dose question remained unresolved until after approval.", "n31", fragment=True)\nc = c.replace("selected for development, then approval<br/>", "selected, developed, approved<br/>")', 'n31chain')
swap('"[Source: FDA Oncologic Drugs Advisory Committee review of sotorasib dosing and CodeBreaK 200, October 2023]{.muted', '"[Source: FDA ODAC review of sotorasib dosing, CodeBreaK 200, October 2023]{.muted', 'n31src')
swap('c = title(S[39], "We are extending the same search logic to decisions across development")', 'c = title(S[39], "Extending the same search logic across development")', 'n33t')
swap("'<span class=\"ext-status\">BATON-D &middot; in progress</span>\\n<p>Optimize dose-finding rules for safety <em>and</em> for what every later trial inherits.</p>', \"n33b\")",
     "'<span class=\"ext-status\">BATON-D &middot; in progress</span>\\n<p>Optimize dose-finding rules for safety <em>and</em> for what later trials inherit.</p>', \"n33b\")", 'n33b')
swap('c = set_notes(c, "**Delivery:** 20 seconds, not 45.', 'c = c.replace("::: {.disclaimer}", "::: {.disclaimer .fragment}")\nc = set_notes(c, "**Delivery:** 20 seconds, not 45.', 'n34frag')
swap('''"""1. For complex adaptive trials, simulation tells us how a candidate behaves; design is the search for what to try next.

2. BATON searches the simulator for feasible, efficient designs and makes the patient-use tradeoffs among them explicit.

3. Making calibration tractable lets us seriously consider richer adaptive trials, and we are extending the same search logic to other decisions across development.""", "n35")''',
'''"""1. For complex adaptive trials, simulation tells us how a candidate behaves; design is the search for what to try next.

2. BATON searches the simulator for feasible, efficient designs and makes the patient-use tradeoffs explicit.

3. Tractable calibration lets us consider richer adaptive trials; the same search logic extends to other decisions across development.""", "n35")''', 'n35')

for tag, txt in [('n8', "Not one calibration problem. Ten to fifteen of them, each with its own design, opened on a short clock."),
                 ('n16', "Balance the potential improvement in the objective against the probability that the design satisfies the constraints."),
                 ('n18', "Cheap screening for the many, expensive re-checks for the few, multi-seed verification for the one design you report."),
                 ('n20', "10 random starts: 8 return Simon's exact optimal design; 2 land 0.15 patients away."),
                 ('n26', "Screen first with a single-arm stage, then demand randomized evidence from the cohorts that earn it. Thirteen interacting parameters, calibrated by automated search."),
                 ('n27', "Minimax and Admissible calibrated to the identical design. That is not a coincidence, and the next slide shows why.")]:
    swap(f'c = set_landing(c, "{txt}", "{tag}")', f'c = set_landing(c, "{txt}", "{tag}", fragment=True)', tag+'frag')
b = b.replace('never penalizes maximum N.", "n28")', 'never penalizes maximum N.", "n28", fragment=True)')
swap('c = rep(c, "power stalled at 0.78, below the 0.80 floor", "power stalled at 0.78 with 39.2 expected patients when the treatment is inactive", "n9orange")',
     'c = rep(c, "power stalled at 0.78, below the 0.80 floor", "power stalled at 0.78 with 39.2 expected patients when the treatment is inactive", "n9orange")\nc = rep(c, \'::: {style="text-align: center; font-size: 1.2em; color: #E07C24; font-weight: 700;"}\', \'::: {.fragment style="text-align: center; font-size: 1.2em; color: #E07C24; font-weight: 700;"}\', "n9frag")', 'n9frag')
# Overview cards: fit content
swap('padding: 1.1em 1.2em; min-height: 8.5em;', 'padding: 1.1em 1.2em; min-height: 6.4em;', 'n2cards')
open('build_v3.py','w').write(b); print("composer patched")
