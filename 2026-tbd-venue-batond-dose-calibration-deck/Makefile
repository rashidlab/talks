# Rebuild the deck from the paper repository's locked artifacts.
#
# BATOND_PAPER_REPO IS THE AUTHORITY. It roots artifact discovery inside `R/metrics.R`, so both
# `numbers.R` and the figure producers read the declared repository from this directory rather
# than whatever the working directory happens to sit above.

BATOND_PAPER_REPO ?= $(HOME)/research/trials-research/baton-dosefinding
export BATOND_PAPER_REPO

DECK := batond-generalist

.PHONY: all figures deck qa clean

all: figures deck qa

## Science figures, from the locked artifacts. Method cartoons, relabelled for dose finding.
figures:
	Rscript figure-producers/deck_figs.R
	Rscript figure-producers/make_fig_loop_plain.R
	Rscript figure-producers/make_fig_map_simple.R
	Rscript figure-producers/make_fig_acquisition.R

deck:
	quarto render $(DECK).qmd

## PDF via decktape, never Chrome print-to-PDF. Also rasterizes, builds contact sheets, counts
## words per slide, and greps the extracted text for the prohibited strings.
##
## MAIN COUNT ROSE FROM 36 TO 39 on 2026-09-04, when search reliability, the three-way trade-off
## and the spine became slides. The profile's 36-slide plan was sized for a 45-minute slot, so the
## timing sheet and the cut order need rebuilding before this deck is delivered.
qa:
	python3 deck_qa.py $(DECK).html --main 40

clean:
	rm -rf qa/p-*.png qa/contact-*.png $(DECK).pdf
