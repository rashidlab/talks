#!/usr/bin/env python3
"""Compose baton-compmed-v3.qmd from baton-compmed-v2.qmd per
baton-compmed-reordered-outline.md. Deterministic; re-runnable."""
import re, sys, pathlib
HERE = pathlib.Path(__file__).parent
src = (HERE / "baton-compmed-v2.qmd").read_text()

# ---- split into YAML header + 54 slides -----------------------------------
m = re.match(r"(---\n.*?\n---\n)", src, re.S)
header, body = m.group(1), src[m.end():]
chunks = re.split(r"\n(?=## )", body.strip("\n"))
S = {i + 1: c.rstrip() + "\n" for i, c in enumerate(chunks)}
assert len(S) == 54, len(S)

def title(chunk, new):
    """Replace the visible title text, keep attributes."""
    return re.sub(r"^## [^{\n]*", "## " + new + " ", chunk, count=1)

def rep(chunk, old, new, tag):
    assert old in chunk, f"[{tag}] anchor not found: {old[:70]}"
    return chunk.replace(old, new)

def set_landing(chunk, new_text, tag, fragment=False):
    """Replace the existing .landing block with a new caption (or remove)."""
    pat = re.compile(r"::: \{\.landing[^}]*\}\n.*?\n:::\n", re.S)
    if not pat.search(chunk):
        raise AssertionError(f"[{tag}] no landing block")
    if new_text is None:
        return pat.sub("", chunk, count=1)
    cls = ".landing .fragment" if fragment else ".landing"
    return pat.sub(f"::: {{{cls}}}\n{new_text}\n:::\n", chunk, count=1)

def add_landing(chunk, text, fragment=False):
    cls = ".landing .fragment" if fragment else ".landing"
    block = f"\n::: {{{cls}}}\n{text}\n:::\n"
    if "::: {.notes}" in chunk:
        i = chunk.index("::: {.notes}")
        return chunk[:i] + block.lstrip("\n") + "\n" + chunk[i:]
    return chunk + block

def set_notes(chunk, notes_md, tag):
    pat = re.compile(r"::: \{\.notes\}\n.*?\n:::\n?", re.S)
    block = "::: {.notes}\n" + notes_md.strip() + "\n:::\n"
    if pat.search(chunk):
        return pat.sub(lambda _: block, chunk, count=1)
    return chunk.rstrip("\n") + "\n\n" + block

def divider(kicker, ttl, question, menu):
    q = f"::: {{.divider-question}}\n{question}\n:::\n" if question else ""
    return (f'## {{.section-divider data-state="hide-footer" data-background-color="#13294B" data-menu-title="{menu}"}}\n\n'
            f"::: {{.divider-inner}}\n::: {{.divider-kicker}}\n{kicker}\n:::\n::: {{.divider-rule}}\n:::\n"
            f"::: {{.divider-title}}\n{ttl}\n:::\n{q}:::\n")

N = {}

# NEW 1 -----------------------------------------------------------------------
N[1] = set_notes(S[1], """**Delivery:** No lab intro. Open on the program. Say here, not later: "By AI-guided I mean model-guided search: a statistical model chooses which candidate design is worth simulating next. It does not make the clinical decisions. We do." """, "n1")

# NEW 2 -----------------------------------------------------------------------
def card(k, t, body):
    b = f'<div style="color: #1A202C; font-size: 0.78em; line-height: 1.4;">{body}</div>' if body else ""
    return (f'  <div style="border: 1px solid #E6EAEF; background: #F4F6F8; padding: 1.1em 1.2em; min-height: 6.4em;">\n'
            f'    <div style="font-family: \'IBM Plex Mono\', monospace; font-size: 0.62em; letter-spacing: 0.08em; color: #2E6A9F; text-transform: uppercase;">{k}</div>\n'
            f'    <div style="font-weight: 700; color: #13294B; font-size: 0.95em; margin: 0.25em 0 0.6em 0;">{t}</div>\n    {b}\n  </div>\n')
N[2] = ('## Overview {data-menu-title="Overview"}\n\n```{=html}\n'
        '<div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 1.2em; margin-top: 3em;">\n'
        + card("Section 1", "The problem", "Complex adaptive design becomes a search problem.")
        + card("Section 2", "BATON", "A search over a trial simulator.")
        + card("Section 3", "Does it work, and what did it change?", "")
        + '</div>\n```\n\n::: {.notes}\n**Delivery:** 30 seconds, spoken over the cards rather than read from them. Section 3 is the destination; say it as a promise, not a spoiler.\n:::\n')

# NEW 3 -----------------------------------------------------------------------
N[3] = divider("Section 1", "The problem", "Why isn't simulation alone enough?", "Section 1: The problem")

# NEW 4 (new) -----------------------------------------------------------------
N[4] = '''## A clinical trial is an experiment built for a decision {data-menu-title="What a trial is"}

::: {.columns style="margin-top: 2.2em;"}
::: {.column width="33%"}
::: {.frame-box style="min-height: 9em; font-size: 0.8em;"}
**The question**<br/>Does the treatment beat a benchmark or a control?
:::
:::
::: {.column width="33%" .fragment}
::: {.frame-box style="min-height: 9em; font-size: 0.8em;"}
**How patients are used**<br/>Single-arm (everyone gets the treatment) or randomized (treatment versus control).
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
'''

# NEW 5 (old 11) --------------------------------------------------------------
c = S[11]
c = set_landing(c, "Maximum N, look timing, futility and efficacy thresholds, priors, margins: **8 to 13 interacting choices**, and every one changes how the trial behaves.", "n5", fragment=True)
c = rep(c, '<img src="images/fig_fixed_vs_adaptive.png" style="max-width: 1150px; max-height: 330px;', '<img src="images/fig_fixed_vs_adaptive.png" style="width: 1150px !important; max-width: 1150px !important; max-height: 420px !important; height: auto !important;', "n5img")
c = rep(c, "::: {.notes}\n", '::: {.notes}\n**Say aloud:** "The design is Bayesian because those decisions rest on posterior probabilities under a model and a prior." Gloss "futility" (the treatment looks unlikely to work) and "interim" (a look before the end).\n\n', "n5notes")
N[5] = c

# NEW 6 (old 9 + boxes from old 12) -------------------------------------------
boxes = re.search(r"::: \{\.columns\}\n::: \{\.column width=\"50%\"\}\n::: \{\.frame-box style=\"font-size: 0\.78em; min-height: 5\.4em; border-color: #E07C24;\"\}.*?\n:::\n:::\n:::\n", S[12], re.S).group(0)
table = re.search(r"\|  \| A typical trial \| EVOLVE \|\n(?:\|.*\|\n)+", S[9]).group(0)
N[6] = ('## Feasible designs meet prespecified error-rate and power targets {data-menu-title="Feasibility"}\n\n'
        + '::: {.columns}\n::: {.column width="50%"}\n::: {.frame-box style="font-size: 0.78em; min-height: 5.2em; border-color: #E07C24;"}\n**Type I error (false go)**<br/>\nShare of simulated trials declaring efficacy under the null. Cap: **0.10**.\n:::\n:::\n'
        + '::: {.column width="50%"}\n::: {.frame-box style="font-size: 0.78em; min-height: 5.2em; border-color: #2E6A9F;"}\n**Power (true go)**<br/>\nShare declaring efficacy when the treatment works as hypothesized. Floor: **0.80**.\n:::\n:::\n:::\n\n'
        + '::: {.fullwidth-table .fragment style="margin-top: 1.2em;"}\n|  | Typical trial | EVOLVE |\n|:--|:--|:--|\n| Designs needed | One | Many subtrials |\n| Design parameters | Few | Many, interacting |\n| Power and type I error | Often closed-form | Simulation only |\n:::\n\n'
        + '::: {.notes}\n**Say aloud:** a design meeting both targets is feasible; "in the examples that follow, feasible means power at least 0.80 and type I error at most 0.10." Define the two terms in one breath on the boxes: "power is the chance the trial correctly advances a treatment that works; type I error is the false-go rate when it does not." The table\'s last row is the point: for these designs, power and type I error come only from simulation. (Timing row dropped for the word cap; say it: "and we had to design repeatedly, on a clock.")\n\n**Q&A pocket:** *Why 0.10 here?* Non-registrational screening subtrials; a confirmatory trial carries a confirmatory ceiling (0.05 is the confirmatory convention).\n:::\n')

# NEW 7 (old 12 minus boxes) --------------------------------------------------
c = S[12]
c = title(c, "Simulation tells us how one candidate behaves. It does not tell us which candidate to try next.")
c = rep(c, '[FDA typically wants **power of at least 0.80** and **type I error of at most 0.05 to 0.10**.]{.muted style="display:block; text-align:center; margin-bottom: 0.4em;"}\n\n', "", "n7fda")
c = c.replace(boxes, "")
c = rep(c, 'style="max-width: 1150px; max-height: 250px; width: auto; height: auto; display: block; margin: 0.3em auto 0 auto;"', 'style="width: 1160px !important; max-width: 1160px !important; height: auto !important; max-height: none !important; display: block; margin: 1.6em auto 0 auto;"', "n7img")
c = rep(c, '[A design meeting your prespecified targets is **feasible**.]{.muted style="display:block; text-align:center;"}\n\n', "", "n7feas")
c = set_landing(c, None, "n7")
c = set_notes(c, """**Gloss aloud:** "null" means the treatment does no better than the benchmark; "alternative" means the improvement we want the power to detect. Point at the two rows: they are exactly these two simulations.

**Delivery:** The title is the conclusion; say it twice if needed. It is the talk's central turn: we know how to evaluate a design, we do not know what to try next.

**Pull-from-if-needed:** FDA's 2019 adaptive-designs guidance treats simulation-demonstrated error control as the expectation for complex designs, not a workaround; the two scenario simulations (null, alternative) are run separately with independent randomness.""", "n7")
N[7] = c

# NEW 8 (old 15) --------------------------------------------------------------
c = S[15]
c = title(c, "EVOLVE: one master protocol, 10 to 15 cohorts opened over time, each needing its own design")
c = rep(c, '<img src="images/fig_A_evolve_platform.png" class="fig-mid"', '<img src="images/fig_A_evolve_platform_v3.png" style="max-height: 415px; display: block; margin: 0.2em auto 0 auto;"', "n8img")
c = c.replace('alt="Schematic of the EVOLVE platform:', 'alt="Schematic of the EVOLVE platform with cohorts tagged single-arm, randomized, and seamless:')
c = set_landing(c, "Not one calibration problem. Ten to fifteen of them, each with its own design, opened on a short clock.", "n8", fragment=True)
c = rep(c, "::: {.notes}\n", '::: {.notes}\n**Define aloud:** platform (one protocol, many treatment cohorts), cohort (a subtrial with its own design), and why each opens "on a clock": cohorts open as biomarkers are discovered, and the design has to be ready when the cohort is.\n\n', "n8notes")
N[8] = c

# NEW 9 (old 13) --------------------------------------------------------------
c = S[13]
c = rep(c, "manual tuning of one subtrial's design<br/>\n[a Bayesian adaptive design with **8 interacting settings**: change one and power, type I error, and sample size all move]{style=\"font-size: 0.8em;\"}", "manual tuning of one subtrial's design<br/>\n**8 interacting settings**", "n9body")
c = rep(c, "power stalled at 0.78, below the 0.80 floor", "power stalled at 0.78 with 39.2 expected patients when the treatment is inactive", "n9orange")
c = rep(c, '::: {style="text-align: center; font-size: 1.2em; color: #E07C24; font-weight: 700;"}', '::: {.fragment style="text-align: center; font-size: 1.2em; color: #E07C24; font-weight: 700;"}', "n9frag")
c = set_landing(c, "Several more subtrials were waiting. And even if you find a feasible design, is it efficient under the objective you actually care about?", "n9", fragment=True)
N[9] = c

# NEW 10 (old 16) -------------------------------------------------------------
c = title(S[16], "This is not just EVOLVE: simulation-calibration recurs across adaptive trial designs")
c = rep(c, "::: {.columns}\n::: {.column width=\"33%\"}\n::: {.frame-box style=\"min-height: 7.4em;", "::: {.columns style=\"margin-top: 3em;\"}\n::: {.column width=\"33%\"}\n::: {.frame-box style=\"min-height: 7.4em;", "n10cols")
c = set_landing(c, "Same shape every time: many interacting settings, operating characteristics evaluated by simulation, and calibration that still requires search.", "n10", fragment=True)
N[10] = c

# NEW 11 (old 14) -------------------------------------------------------------
c = title(S[14], "Grid search scales poorly; random search wastes evaluations in our benchmark")
c = rep(c, '''::: {.columns style="align-items: center;"}
::: {.column width="50%"}
<img src="images/fig_search_grid.png" class="fig-tall" alt="Heatmap of a fictional two-dimensional design-space slice, darker meaning better, covered by a uniform lattice of one hundred evaluation dots, most sitting in light low-quality regions."/>
:::
::: {.column width="50%" .fragment}
<img src="images/fig_search_random.png" class="fig-tall" alt="The same heatmap with one hundred evaluation dots scattered uniformly at random; most again land in light low-quality regions."/>
:::
:::
''', '''```{=html}
<div style="display: flex; justify-content: center; align-items: center; gap: 2.5em; margin-top: 0.2em;">
<img src="images/fig_search_grid.png" style="height: 395px;" alt="Heatmap of a fictional two-dimensional design-space slice, darker meaning better, covered by a uniform lattice of one hundred evaluation dots, most sitting in light low-quality regions."/>
<img src="images/fig_search_random.png" class="fragment" style="height: 395px;" alt="The same heatmap with one hundred evaluation dots scattered uniformly at random; most again land in light low-quality regions."/>
</div>
```
''', "n11row")
c = set_landing(c, "In two dimensions a grid is easy. As dimensions grow, the number of combinations explodes. Random search spent 93% of its 2,000 evaluations on designs that fail. (Darker = better design.)", "n11", fragment=True)
c = rep(c, "::: {.notes}\n", "::: {.notes}\n**Confirmed 2026-09-04 (scripts/run_random_search_analysis.R, results/validation/random_search_summary.csv):** the random-search benchmark drew 2,000 configurations uniformly over the binary two-stage (Simon-type) design space, the same parameter family as the Simon benchmark (efficacy and futility thresholds, stage-1 size, total size) over its own search box, 2,000 simulations each; not commensurable with the ten-seed reproducibility run; 136 feasible (6.8%); best random design expected null N 17.75 in 9.3 minutes. If asked which dimension: the Simon-type parameters, not the 8- or 13-parameter EVOLVE designs.\n\n", "n11notes")
N[11] = c

# NEW 12 -----------------------------------------------------------------------
N[12] = divider("Section 2", "BATON", "What should we simulate next?", "Section 2: BATON")

# NEW 13 (old 18) --------------------------------------------------------------
c = rep(S[18], "::: {.columns}\n::: {.column width=\"50%\"}\n::: {.frame-box style=\"text-align: center;\"}\n**Machine learning**", "::: {.columns style=\"margin-top: 4.5em;\"}\n::: {.column width=\"50%\"}\n::: {.frame-box style=\"text-align: center;\"}\n**Machine learning**", "n13cols")
c = set_landing(c, "The same computational shape as hyperparameter tuning, except feasibility is defined by hard statistical constraints.", "n13", fragment=True)
c = set_notes(c, "**Delivery:** This is where the room recognizes the problem as theirs. One sentence on the difference, then advance to the method.", "n13")
N[13] = c

# NEW 14 (old 19) --------------------------------------------------------------
c = title(S[19], "BATON needs a simulator, not a formula")
c = rep(c, """**BATON**<br/>Bayesian Adaptive Trial OptimizatioN<br/>[Model-guided: a probabilistic model learns from the simulations already run and picks the next one worth paying for.]{.muted style="font-size: 0.9em;"}

**You specify:** a power floor, a type I error cap, and what to minimize (expected N, maximum N, or a mix).

**Your simulator:** design settings plus null and alternative scenarios in; power, type I error, and enrollment out.""",
"""**BATON**: Bayesian Adaptive Trial OptimizatioN

**Constrained Bayesian optimization**: surrogates learn power, type I error, and enrollment; they choose the next candidate.

**You specify**: a power floor, a type I error cap, what to minimize.

**Your simulator**: settings and scenarios in, operating characteristics out.""", "n14card")
c = c.replace('::: {.frame-box style="font-size: 0.7em;"}', '::: {.frame-box style="font-size: 0.74em;"}')
c = c.replace('::: {.column width="34%"}', '::: {.column width="38%"}').replace('::: {.column width="66%" .fragment}', '::: {.column width="62%" .fragment}')
c = set_landing(c, "A closed loop: simulate, learn, choose, repeat.", "n14", fragment=True)
c = set_notes(c, """**Spoken, not on the slide (and for the word cap):** what to minimize means expected N, maximum N, or a mix; the surrogates are Gaussian processes fit to the simulations already run. "We do not need a formula that maps thirteen design parameters to power, type I error, and enrollment. We need to be able to simulate a design." Do not say "black box" aloud; to this room it means opaque AI.

**Pull-from-if-needed:** Formal names: Monte Carlo simulator, Gaussian-process surrogate, feasibility-aware acquisition (expected improvement times probability of feasibility), multi-seed verification.""", "n14")
N[14] = c

# NEW 15 (old 21) --------------------------------------------------------------
c = title(S[21], "A surrogate predicts designs we have not paid to simulate")
c = set_landing(c, "Design settings in, trial behavior out, and the model says how sure it is.", "n15", fragment=True)
N[15] = c

# NEW 16 (old 22) --------------------------------------------------------------
c = title(S[22], "The next simulation goes where it has the greatest expected value for improving the feasible design")
c = set_landing(c, "Balance the potential improvement in the objective against the probability that the design satisfies the constraints.", "n16", fragment=True)
c = rep(c, "**Q&A pocket:** *Acquisition details?*", "**Name it once here if asked:** this is expected constrained improvement; backup B1 has the formula.\n\n**Q&A pocket:** *Acquisition details?*", "n16notes")
c = c.replace('<img src="images/fig_acquisition_regions.png" class="fig-mid"', '<img src="images/fig_acquisition_regions.png" style="max-height: 400px; display: block; margin: 0 auto;"')
N[16] = c

# NEW 17 (old 20 + old 23) -----------------------------------------------------
N[17] = '''## The seed sketches the map. Then BATON proposes each batch. {data-menu-title="Seed then search"}

```{=html}
<div style="display: flex; justify-content: center; align-items: center; gap: 2.5em; margin-top: 0.6em;">
<img src="images/fig_search_init.png" style="height: 470px;" alt="Heatmap of a fictional design-space slice, darker meaning better, with fifteen scattered space-filling evaluation dots and no lattice."/>
<img src="images/fig_search_guided.png" class="fragment" style="height: 470px;" alt="The same surface with thirty model-guided evaluations clustering on the dark high-quality basin; repeated cells overlap. No connecting lines."/>
</div>
```

::: {.landing .fragment}
Initial points learn broadly; later points concentrate where the answer may improve.
:::

::: {.notes}
**Delivery:** "Step one is not clever: scatter a small sample so the model has something to learn from. After that, every batch is placed by the model." One beat per panel.

**Pull-from-if-needed:** Production runs seed with a 60-point Latin-hypercube design at low fidelity, then hand over to model-guided selection in batches of 3. Points here are illustrative (synthetic surface), not real design coordinates.
:::
'''

# NEW 18 (old 24) --------------------------------------------------------------
c = S[24]
c = rep(c, 'alt="Ladder of four stages.', 'alt="Ladder of four stages with one large sublabel under each box: Explore, 3,000 trials each; Validate, 10,000 each; Escalate only if needed, 5,000 then 10,000; Verify, 5 seeds x 10,000, all must pass. Original description:', "n18alt")
c = set_landing(c, "Cheap screening for the many, expensive re-checks for the few, multi-seed verification for the one design you report.", "n18", fragment=True)
c = c.replace('<img src="images/fig_funnel_plain.png" class="fig-mid"', '<img src="images/fig_funnel_plain.png" style="max-height: 435px; display: block; margin: 0.3em auto 0 auto;"')
N[18] = c

# NEW 19 -----------------------------------------------------------------------
N[19] = divider("Section 3", "The evidence", "Feasibility, efficiency, and richer designs", "Section 3: Evidence")

# NEW 20 (old 29) --------------------------------------------------------------
c = title(S[29], "On a problem with a known answer, BATON recovers the optimum or a near-neighbor")
c = rep(c, "[Simon two-stage designs: every possible design can be enumerated, so the exact optimum is known. **One benchmark scenario, 10 independent BATON runs.**]{.muted}",
        "[Simon's two-stage design: enroll n1, stop if too few responses, otherwise enroll to n. Every candidate in this design class can be enumerated, so the exact constrained optimum is known.]{.muted style=\"display:block; font-size: 0.85em;\"}", "n20sub")
c = c.replace('class="fig-mid" style="max-height: 403px;"', 'class="fig-mid" style="max-height: 400px;"')
c = set_landing(c, "10 random starts: 8 return Simon's exact optimal design; 2 land 0.15 patients away.", "n20", fragment=True)
N[20] = c

# NEW 21 (old 46 table) --------------------------------------------------------
tbl46 = re.search(r"\| Claim \| Value \|\n(?:\|.*\|\n)+", S[46]).group(0)
N[21] = ('## Across 12 benchmarks: feasible in all 12, median objective gap 2.5% {data-menu-title="Benchmark table"}\n\n'
         '[One run per scenario; ratio = BATON\'s expected null enrollment / Simon\'s exact optimum.]{.muted style="display:block; font-size: 0.85em; margin-bottom: 0.4em;"}\n\n'
         '::: {.fullwidth-table style="font-size: 1.15em;"}\n| Claim | Value |\n|:--|:-:|\n| Feasible design returned | 12 / 12 |\n| Exact Simon design returned | 4 / 12 |\n| Median ratio, BATON / Simon | 1.025 |\n| Worst-case ratio | 1.135 |\n| Best-case ratio | 1.000 |\n:::\n\n'
         '::: {.landing .fragment}\nFeasibility is verified directly. Objective optimization remains approximate.\n:::\n\n'
         '::: {.notes}\n**Say the full sentence:** across 12 benchmark scenarios BATON returned a feasible design in all 12; the median objective gap was 2.5%.\n\n**Pull-from-if-needed:** The worst case (ratio 1.135) is a single-seed result; reseeding the 0.20 scenario returns the exact optimum in 8 of 10 runs (previous slide). Never compress this to "recovers the optimum" in every scenario: exact match in 4 of 12, median gap 2.5%, worst 13.5%. The scatter plot is backup B2.\n:::\n')

# NEW 22 (old 47 rebuilt) ------------------------------------------------------
N[22] = '''## In EVOLVE, BATON found a feasible design where manual tuning had stalled {data-menu-title="Manual vs BATON"}

::: {.columns style="margin-top: 3.2em;"}
::: {.column width="50%"}
::: {.frame-box style="text-align: center; font-size: 1.05em; line-height: 1.55; border-color: #E07C24;"}
**MANUAL**<br/>2 weeks<br/>power 0.78<br/>**39.2 expected patients if inactive**<br/>infeasible
:::
:::
::: {.column width="50%" .fragment}
::: {.frame-box style="text-align: center; font-size: 1.05em; line-height: 1.55; border-color: #2E6A9F;"}
**BATON**<br/>~4-hour workflow<br/>power 0.86<br/>**11.7 expected patients if inactive**<br/>feasible
:::
:::
:::

[Illustrative comparison, not a controlled benchmark across analysts. Same simulator, same constraints.]{.muted style="display:block; text-align:center; font-size: 0.72em; margin-top: 0.8em;"}

::: {.notes}
**Delivery:** The callback to the two-week slide. Same simulator, same constraints; a single illustrative comparison documented in the paper's web appendix.
:::
'''

# NEW 23 (old 25 + old 26) -----------------------------------------------------
tbl26 = re.search(r"\|  \| Design A \| Design B \|\n(?:\|.*\|\n)+", S[26]).group(0)
tbl26 = tbl26.replace("| Average patients *if the drug fails* |", "| Expected patients *if the treatment is inactive* |")
N[23] = ('## Same requirements, different trials {data-menu-title="Two designs"}\n\n'
         '::: {.thesis-line style="margin-top: 0.8em;"}\nMany designs meet power \u2265 0.80 and type I error \u2264 0.10. Which should we optimize for?\n:::\n\n'
         '::: {.fragment}\n[EVOLVE\'s TNBC cohort, different objectives:]{.muted style="display:block; margin: 0.9em 0 0.3em 0;"}\n\n'
         '::: {.fullwidth-table}\n|  | Design A | Design B |\n|:--|:-:|:-:|\n| Maximum patients | **47** | **30** |\n| Expected patients, inactive treatment | **11.7** | **22.8** |\n| Power | 0.86 | 0.94 |\n| Type I error | 0.001 | 0.021 |\n:::\n:::\n\n'
         '::: {.landing .fragment}\nOne quits losers quickly; one caps the worst case. Neither is better.\n:::\n\n'
         '::: {.notes}\n**Say the full title aloud:** two designs meet the same statistical requirements and produce very different trials. Build 1 is the hinge from machinery to science; let it sit, then reveal the table. Say plainly that these two arise under different objectives; they are not two outputs of one feasibility run. Caption, spoken in full: "Neither is universally better."\n\n**Pull-from-if-needed:** Scenario A, the platform\'s TNBC cohort, futility-only stopping. Verified values from the philosophy comparison file.\n\n**Q&A pocket:** *Why care about expected N when the treatment is inactive?* Most experimental oncology drugs do not work; the ethical cost center is patients enrolled onto an ineffective therapy.\n:::\n')

# NEW 24 (old 27) --------------------------------------------------------------
c = S[27]
c = rep(c, "A feasibility criterion tells us whether a design is acceptable. It does not encode which acceptable design we **prefer**.\n\n", "", "n24intro")
c = title(c, "The objective should reflect the trial you want")
c = rep(c, "<h4>“Quit losers quickly”</h4>\n<span class=\"ext-status\">H0-Optimal</span>\n<p>Minimize average N when the drug fails.",
        "<h4>H0-Optimal (quit losers quickly)</h4>\n<span class=\"ext-status\">H0: no better than the benchmark</span>\n<p>Minimize expected N under the null; larger maximum N.", "n24c1")
c = rep(c, "<h4>“Cap the worst case”</h4>\n<span class=\"ext-status\">Minimax</span>\n<p>Minimize maximum N.<br/><em>Tradeoff: more patients when the drug fails.</em></p>",
        "<h4>Minimax (cap the worst case)</h4>\n<p>Minimize maximum N; more patients under the null.</p>", "n24c2")
c = rep(c, "<h4>“The compromise”</h4>\n<span class=\"ext-status\">Admissible</span>", "<h4>Admissible (the compromise)</h4>", "n24c3")
c = set_landing(c, "Two-stage designs made these tradeoffs explicit for decades; BATON does so at scale.", "n24", fragment=True)
c = c.replace("<p>Weighted blend of the two.<br/><em>Trades one against the other, explicitly.</em></p>", "<p>A weighted blend, explicit.</p>").replace("<br/><em>Tradeoff: may need a larger maximum N.</em>", "")
c = rep(c, "**Delivery, spoken transition into this slide:**", "**Spoken (moved off the slide):** \"A feasibility criterion tells us whether a design is acceptable. It does not encode which acceptable design we prefer.\" Full caption: \"Frequentist two-stage designs made these tradeoffs explicit for decades. BATON makes the same tradeoffs explicit when exhaustive enumeration is impractical.\"\n\n**Say once, here:** \"From here on, when I say efficient, I mean efficient in patients, not faster computation.\"\n\n**Delivery, spoken transition into this slide:**", "n24notes")
N[24] = c

# NEW 25 (old 31) --------------------------------------------------------------
c = title(S[31], "EVOLVE's TNBC cohort: three objectives, three designs")
c = rep(c, '<img src="images/fig_R1_singlearm.png" class="fig-tall"', '<img src="images/fig_R1_singlearm_v3.png" style="width: 100%; height: auto;"', "n25img")
c = rep(c, "- quit losers quickly: 47 max, **11.7** if inactive\n- the compromise: 31 max, **11.9**\n- cap the worst case: 30 max, **22.8**",
        "- H0-Optimal: 47 max, **11.7** if the treatment is inactive\n- Admissible: 31 max, **11.9**\n- Minimax: 30 max, **22.8**", "n25bul")
c = rep(c, "::: {.landing .fragment}\nThe compromise keeps almost all of H0-Optimal's efficiency at almost Minimax's cap.\n:::\n\n:::\n:::\n",
        ":::\n:::\n\n::: {.landing .fragment}\nFor one additional patient of maximum capacity, Admissible saves about eleven patients on average when the treatment is inactive. That made the compromise especially attractive.\n:::\n", "n25land")
c = rep(c, "::: {.notes}\n", "::: {.notes}\n**Speaker check (not verifiable from the repo):** if this exact Admissible TNBC design is the one in the protocol, say \"That is the design we ran\"; otherwise keep the caption wording (\"especially attractive\"); slide 29 gives the fuller operational choice.\n\n", "n25notes")
N[25] = c

# NEW 26 (old 32) --------------------------------------------------------------
c = title(S[32], "Search makes a 13-parameter seamless design practical to calibrate")
c = rep(c, '<img src="images/fig_B_design_types.png" class="fig-mid"', '<img src="images/fig_B_design_types_v3.png" style="width: 1000px; max-width: 1000px; height: auto; display: block; margin: 0.2em auto 0 auto;"', "n26img")
c = set_landing(c, "Screen first with a single-arm stage, then demand randomized evidence from the cohorts that earn it. Thirteen interacting parameters, calibrated by automated search.", "n26", fragment=True)
c = c.rstrip("\n") + '\n\n::: {.notes}\n**Say aloud:** "This is the kind of design we can now seriously consider, because calibration is tractable." And: "The first stage lets us screen with fewer patients before committing to randomized evidence."\n:::\n'
N[26] = c

# NEW 27 (old 33) --------------------------------------------------------------
c = title(S[33], "Two philosophies converged on the same 13-parameter design")
c = c.replace("Seamless trade-off plane with five philosophies: three occupy distinct points while Minimax and Admissible land on one identical point at maximum 108 and expected 87.6, circled.", "Seamless trade-off plane with three philosophies: H0-Optimal at maximum 150, and Minimax and Admissible landing on one identical point at maximum 108 and expected 87.6, circled.")
c = rep(c, '<img src="images/fig_R3_seamless_pareto.png" class="fig-mid"', '<img src="images/fig_R3_seamless_pareto_v3.png" style="max-height: 435px; display: block; margin: 0 auto;"', "n27img")
c = c.replace('alt="Seamless trade-off plane with five philosophies: three occupy distinct points', 'alt="Seamless trade-off plane with three philosophies: H0-Optimal, and the collapsed Minimax equals Admissible point, circled;')
c = set_landing(c, "Minimax and Admissible calibrated to the identical design. That is not a coincidence, and the next slide shows why.", "n27", fragment=True)
N[27] = c

# NEW 28 (old 34) --------------------------------------------------------------
c = title(S[34], "The gate rarely opens when the treatment is inactive, so the two objectives collapse")
c = c.replace("for every philosophy.", "for each of the three philosophies shown.")
c = rep(c, 'src="images/fig_R4_conversion_gate.png"', 'src="images/fig_R4_conversion_gate_v3.png"', "n28img")
c = set_landing(c, "When the treatment is inactive, only ~4% of trials reach stage 2. Expected enrollment therefore changes very little with stage-2 size, so the maximum-enrollment component drives the Admissible solution toward Minimax. H0-Optimal can tolerate a larger stage 2 because its objective never penalizes maximum N.", "n28", fragment=True)
c = c.replace('class="fig-mid" alt="Bar chart', 'class="fig-mid" style="max-height: 390px;" alt="Bar chart')
c = c.rstrip("\n") + '\n\n::: {.notes}\n**Say:** "In this design region the two objectives effectively align." **Close with:** "The search became an instrument for understanding the design."\n:::\n'
N[28] = c

# NEW 29 (old 35) --------------------------------------------------------------
c = title(S[35], "BATON informed EVOLVE's operational decisions")
c = rep(c, "**Capacity**: maximum N locked ~3 months before first enrollment, from frontier curves.", "**Capacity**: maximum N locked 3 months before first enrollment, from the frontier.", "n29a")
c = rep(c, "**Interim data locks**: look spacing sets the analysis calendar the safety board shares.", "**Interim calendar**: look spacing set the safety board's schedule.", "n29b")
c = rep(c, "**Turnaround**: a feasible design in under 45 minutes per run; full workflow about 4 hours.", "**Turnaround**: a feasible design in under 45 minutes; workflow about 4 hours.", "n29c")
c = c.replace("min-height: 4.0em; font-size: 0.82em;", "min-height: 5.6em; font-size: 0.88em;")
c = c.replace("**Program planning**: enrollment and timeline projections across 10 to 15 sequential subtrials.", "**Program planning**: enrollment and timeline projections for 10 to 15 subtrials.")
c = rep(c, "::: {.columns}\n::: {.column width=\"50%\"}\n::: {.frame-box .fragment", "::: {.columns style=\"margin-top: 1.4em;\"}\n::: {.column width=\"50%\"}\n::: {.frame-box .fragment", "n29cols")
c = set_landing(c, "We generally chose Admissible designs: efficient enrollment, early stopping, bounded capacity.", "n29", fragment=True)
c = rep(c, "**Delivery:** Land the Admissible line, then advance. The bridge question is spoken on the next slide (JASA + software), so the room hears it immediately before the program-failure slide answers it.",
        "**Delivery:** Land the Admissible line, then advance. Speak the bridge on the next slide: \"BATON solved the problem in front of us. But working on it raised a more uncomfortable question: what if the trial is not the right unit to optimize?\"", "n29notes")
N[29] = c

# NEW 30 (old 36 rebuilt) ------------------------------------------------------
N[30] = '''## BATON is designed as a general framework, not an EVOLVE-specific tool {data-menu-title="Framework"}

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
'''

# NEW 30b (restored, sourced number only) ---------------------------------------
N["30b"] = '''## Problems often emerge late {data-menu-title="Late failure"}

::: {style="text-align: center; margin-top: 2.2em;"}
<span style="font-size: 3.6em; font-weight: 800; color: #13294B; line-height: 1;">54%</span><br/>
[of 640 therapeutics reaching phase 3 or pivotal trials **failed in late-stage development**; 57% of failures for inadequate efficacy]{style="display:block; max-width: 70%; margin: 0.4em auto 0 auto; font-size: 0.8em; color: #5B6670;"}
:::

::: {.landing .fragment}
Locally reasonable decisions can leave problems that only become visible downstream.
:::

[Hwang et al., JAMA Internal Medicine 2016]{.muted style="display:block; text-align:center; font-size:0.62em; margin-top: 1.2em;"}

::: {.notes}
**Delivery:** 20 to 30 seconds. Say the denominator precisely (640 novel therapeutics reaching phase 3 or pivotal trials, 1998 to 2008; PMID 27723879), never "half of drugs fail phase III." Then, spoken only: "And dose questions persist after approval: FDA\'s own postmarketing-requirement records, as we have compiled them, show dose-optimization requirements on a meaningful share of oncology approvals, taking years to fulfill." No number on that; the primary analysis is not yet traced. Then sotorasib gives the human-scale example.

**Honesty line:** "These late-stage failures are a different problem from the one I just showed you solved. They are the problem this machinery might reach."
:::
'''

# NEW 31 (old 38) --------------------------------------------------------------
c = S[38]
c = rep(c, "**similar progression-free survival at one-quarter the dose**", "**median PFS was similar at 240 mg and 960 mg**", "n31line")
c = set_landing(c, "The optimal-dose question remained unresolved until after approval.", "n31", fragment=True)
c = c.replace("selected for development, then approval<br/>", "selected, developed, approved<br/>").replace("**960 mg**: highest dose tested in phase I<br/>", "**960 mg**: highest phase I dose tested<br/>")
c = rep(c, "[FDA Oncologic Drugs Advisory Committee review of sotorasib dosing and CodeBreaK 200, October 2023]{.muted style=\"display:block; text-align:center; font-size:0.55em; margin-top:0.4em;\"}",
        "[Source: CodeBreaK 100 dose comparison; Ann Oncol 2023, Eur J Cancer 2024]{.muted style=\"display:block; text-align:center; font-size:0.62em; margin-top:0.5em;\"}", "n31src")
c = c.replace('::: {.frame-box style="max-width: 56%; margin: 0 auto; text-align: center; font-size: 0.95em;"}', '::: {.frame-box style="max-width: 60%; margin: 0 auto; text-align: center; font-size: 0.9em;"}')
c = rep(c, "**Pull-from-if-needed:**", "**Confirmed 2026-09-04 (CodeBreaK 100 randomized dose comparison, 960 vs 240 mg, n = 209; Ann Oncol 2023 VP4, Eur J Cancer 2024):** median PFS 5.4 vs 5.6 months (HR 0.95, 95% CI 0.67 to 1.35); ORR 32.7% vs 24.8%; median OS 13.0 vs 11.7 months (HR 0.75, 95% CI 0.53 to 1.07). FDA considered the postmarketing requirement fulfilled in December 2023 and 960 mg remains the labeled dose. Do not say \"similar efficacy\": ORR and OS trended toward 960 mg; PFS is the endpoint that was similar. Gloss PFS aloud: \"time until the cancer worsens or the patient dies.\"\n\n**Pull-from-if-needed:**", "n31notes")
N[31] = c

# NEW 32 (old 40) --------------------------------------------------------------
c = S[40]
c = c.replace('<div style="border:1px solid #13294B; background:#F4F6F8; padding:0.7em 1.0em; text-align:center;">', '<div style="border:1px solid #13294B; background:#F4F6F8; padding:0.45em 0.9em; text-align:center; min-height: 3.8em; display:flex; flex-direction:column; justify-content:center; font-size: 0.9em;">')
c = c.replace('gap:0.6em; margin: 0.7em auto 0.2em auto; max-width: 92%;', 'gap:0.6em; margin: 0.2em auto 0.1em auto; max-width: 92%;')
c = rep(c, "selection inherited<br/>", "choice carries forward<br/>", "n32a")
c = rep(c, "debt accumulates<br/>", "uncertainty carries forward<br/>", "n32b")
c = rep(c, "must repay remaining debt", "must resolve remaining uncertainty", "n32c")
c = rep(c, "phased&ensp;·&ensp;seamless&ensp;·&ensp;**potentially phaseless**", "phased&ensp;·&ensp;seamless&ensp;·&ensp;**potentially phaseless**", "n32d")
c = set_landing(c, "Phase structure becomes a design variable.", "n32", fragment=True)
c = c.replace('::: {.landing .fragment}\nPhase structure becomes a design variable.\n:::', '::: {.landing .fragment style="font-size: 1.25em;"}\nPhase structure becomes a design variable.\n:::')
c = c.replace('::: {.fragment style="max-width: 70%; margin: 0.3em auto 0 auto; border: 2px solid #2E6A9F; background: #FFFFFF; text-align: center; padding: 0.45em 0.8em; font-size: 0.8em;" fragment-index="1"}', '::: {.fragment style="max-width: 78%; margin: 0.35em auto 0 auto; border: 2px solid #2E6A9F; background: #FFFFFF; text-align: center; padding: 0.45em 1em; font-size: 0.88em; line-height: 1.35;" fragment-index="1"}')
c = c.replace("Then say the clarification:", "Then say the clarification, aloud and explicitly: \"Phaseless does not mean confirmation-less. It means phase boundaries are design choices rather than assumptions.\"")
N[32] = c

# NEW 33 (old 39) --------------------------------------------------------------
c = title(S[39], "Extending the same search logic across development")
c = rep(c, '<span class="ext-status">BATON-C &middot; in progress, with Amber Young</span>\n<p>Optimize across a <em>prespecified family</em> of plausible clinical futures, not one assumed truth.</p>',
        '<span class="ext-status">BATON-C &middot; in progress, with Amber Young</span>\n<p>Optimize over a <em>prespecified family</em> of plausible truths, not one.</p>', "n33a")
c = rep(c, '<span class="ext-status">BATON-D &middot; in progress, working name</span>\n<p>Optimize dose-finding rules for safety <em>and</em> what every later trial inherits.</p>',
        '<span class="ext-status">BATON-D &middot; in progress</span>\n<p>Optimize dose-finding rules for safety <em>and</em> for what later trials inherit.</p>', "n33b")
c = rep(c, '<span class="ext-status">phaseless development &middot; long-term goal</span>', '<span class="ext-status">Phaseless / whole-program design &middot; long-term goal</span>', "n33c")
c = c.replace("as <em>one linked program</em>.", "as <em>one program</em>.")
c = set_landing(c, None, "n33")
N[33] = c

# NEW 34 (old 52 promoted) -----------------------------------------------------
c = S[52].replace("## Backup: what I am not arguing {.backup-slide data-menu-title=\"B7: Not arguing\"}", "## What I am not arguing {data-menu-title=\"Not arguing\"}")
c = rep(c, "**Not** that trials are currently miscalibrated. Feasible designs found by hand are feasible. The claim is that the *choice among them* has been invisible.",
        "**Not** that hand-designed trials are miscalibrated. In complex design spaces, the alternatives and their tradeoffs may never get explored systematically.", "n34a")
c = rep(c, "**Not** that one philosophy is right. H0-Optimal and Minimax encode different, legitimate priorities. The method is deliberately neutral among them.",
        "**Not** that one philosophy is right. H0-Optimal and Minimax encode different, legitimate priorities.", "n34b")
c = rep(c, "**Not** that optimization replaces statisticians. It replaces the *grid search* part of their month, not the judgment part.",
        "**Not** that optimization replaces statisticians. It automates the search, not the judgment.", "n34c")
c = c.replace("::: {.disclaimer}", "::: {.disclaimer .fragment}")
c = set_notes(c, "**Delivery:** 20 seconds, not 45. Say only: \"The point is not to replace statistical judgment; it is to automate the search that supports it.\" Then straight to the takeaways.", "n34")
N[34] = c

# NEW 35 (old 41) --------------------------------------------------------------
c = rep(S[41], """1. Simulation can tell us how a proposed adaptive trial behaves, but not what design to try next.

2. BATON turns trial calibration into a guided, constrained search, and makes the tradeoffs among workable designs explicit.

3. The larger opportunity: optimize the **sequence of decisions** across development, toward programs that reach reliable answers faster, with fewer patients.""",
"""1. For complex adaptive trials, simulation tells us how a candidate behaves; design is the search for what to try next.

2. BATON searches the simulator for feasible, efficient designs and makes the patient-use tradeoffs explicit.

3. Tractable calibration lets us consider richer adaptive trials; the same search logic extends to other decisions across development.""", "n35")
c = c.replace("**Delivery:** Reassurance line worth speaking before the close:", "**Delivery (the cut not-arguing slide, in one spoken line):** \"The point is not to replace statistical judgment; it is to automate the search that supports it.\" Reassurance line worth speaking before the close:")
N[35] = c

# NEW 36, Questions, Backup divider ---------------------------------------------
N[36] = S[42]
Q = S[43]
BD = S[44]

# Backups -----------------------------------------------------------------------
B = {}
B[1] = S[45]
B[2] = S[30].replace('<img src="images/fig4_benchmark_efficiency.png" class="fig-mid"', '<img src="images/fig4_benchmark_efficiency.png" style="max-height: 390px; display: block; margin: 0 auto;"').replace("## Across 12 different benchmark scenarios {data-menu-title=\"Benchmark\"}", "## Backup: the 12-benchmark scatter {.backup-slide data-menu-title=\"B2: Benchmark scatter\"}")
B[3] = S[48]
B[4] = S[49]
B[5] = S[50]
B[6] = S[51]
B[7] = rep(S[53], "For a method meant to sit inside regulatory submissions, this is not a nicety. It is what regulatory credibility requires.",
           "For a method meant to sit inside regulatory submissions, this is not a nicety. That is the bar for a design going into a regulatory submission.", "b7")
B[8] = S[54].replace('<img src="images/fig_R2_betweenarm.png" class="fig-mid"', '<img src="images/fig_R2_betweenarm.png" style="max-height: 440px; display: block; margin: 0 auto;"')
B[9] = S[8].replace("## The trial had to learn while the program was running {data-menu-title=\"What ARPA-H asked\"}", "## Backup: the ARPA-H ask and the N-of-1 addition {.backup-slide data-menu-title=\"B9: ARPA-H ask\"}")
B[10] = '''## Backup: ADAPT technical areas and the EVOLVE team {.backup-slide data-menu-title="B10: ADAPT + team"}

::: {.columns style="align-items: flex-start;"}
::: {.column width="50%"}
<img src="images/harvest_components_crop.png" style="width: 100%;" alt="Cropped official ADAPT technical-areas graphic: three circles for TA1 therapy recommendation, TA2 evolutionary clinical trial, and TA3 cancer treatment and analysis platform, with their sub-bullets; source slide number, footer, and highlight box removed."/>
:::
::: {.column width="50%"}
<img src="images/harvest_team26.png" style="width: 100%;" alt="Official Meet the Team slide: MPI photographs and roles beside tables for the steering committee, fifteen participating TBCRC sites, and the working groups."/>
:::
:::

::: {.notes}
**Pull-from-if-needed:** For questions about the program: three technical areas (our team leads the clinical-trial component), metastatic breast cancer, master protocol, biomarker-defined subtrials, TBCRC network.
:::
'''

# Backup menu titles in outline order (B1..B10); stale v2 letters removed
import re as _re
_labels = {1: "GP + ECI", 2: "Benchmark scatter", 3: "Parameters", 4: "Related work", 5: "Limitations",
           6: "Bidirectional", 7: "Reproducibility", 8: "Randomized frontier", 9: "ARPA-H ask", 10: "ADAPT + team"}
for _k in B:
    B[_k] = _re.sub(r'data-menu-title="B\d+: [^"]*"', f'data-menu-title="B{_k}: {_labels[_k]}"', B[_k], count=1)
# Q&A routing index rewritten for v3 numbering
Q = _re.sub(r"\*\*Q&A routing index:\*\*.*?\n:::", """**Q&A routing index (v3 numbering):**
- *Why 0.10 / 0.80, conventions* -> slide 6 notes.
- *Bayesian vs frequentist hybrid* -> slide 5 notes.
- *Random search "beat" you* -> slide 11 notes; slides 20 to 21.
- *GP, acquisition, correlated constraints, CRN* -> backup B1 (code-verified answers).
- *Simon seed accounting, worst case* -> slide 21 notes; backup B2 (scatter), B7 (ten seeds).
- *Collapse an artifact?* -> slide 27 notes; slide 28.
- *Unspent alpha at 0.001, search-box edges* -> slide 25 notes; backup B3.
- *Multi-objective BO; when is the philosophy locked* -> slide 24 notes.
- *Two-weeks story detail* -> slide 22 (manual vs BATON).
- *Limits, failure modes* -> backup B5. *Bidirectional stopping* -> B6. *Randomized cohort* -> B8.
- *ARPA-H requirements, the program* -> backups B9, B10.
- *Company / translation* -> disclose relationship verbally; keep to one sentence.
:::""", Q, count=1, flags=_re.S)
assert "v3 numbering" in Q
# NEW 29 notes: the full comparison is now main slide 22
N[29] = N[29].replace("(backup B6 has the full numbers)", "(slide 22 has the full numbers)")
assert "backup B6" not in N[29]

# Fill the space above the caption band on the two panel slides
N[15] = N[15].replace('<img src="images/fig_map_points.png" class="fig-tall"', '<img src="images/fig_map_points.png" class="fig-tall" style="height: 470px;"').replace('<img src="images/fig_map_model.png" class="fig-tall fragment"', '<img src="images/fig_map_model.png" class="fig-tall fragment" style="height: 470px;"')
N[17] = N[17].replace('class="fig-tall" alt="Heatmap of a fictional', 'class="fig-tall" style="height: 470px;" alt="Heatmap of a fictional').replace('class="fig-tall" alt="The same surface with thirty', 'class="fig-tall" style="height: 470px;" alt="The same surface with thirty')
N[20] = N[20].replace('class="fig-mid" style="max-height: 400px;"', 'class="fig-mid" style="max-height: 400px; height: auto; width: auto; max-width: 1180px;"')

# Assemble ---------------------------------------------------------------------
order = [N[i] for i in range(1, 31)] + [N['30b']] + [N[i] for i in range(31, 37) if i != 34] + [Q, BD] + [B[i] for i in range(1, 11)]  # NEW 34 deleted per speaker, 2026-09-04
out = header + "\n" + "\n\n".join(x.rstrip("\n") + "\n" for x in order)
assert out.count("\n## ") == 48, out.count("\n## ")
(HERE / "baton-compmed-v3.qmd").write_text(out)
print("wrote baton-compmed-v3.qmd with", out.count("\n## "), "slides")
