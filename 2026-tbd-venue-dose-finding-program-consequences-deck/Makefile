# Command surface for the deck.
#
# The one rule that matters: never present a deck that has not passed `make preflight`.
# RevealJS does not clip or warn when content falls below the 1280x720 canvas, so
# overflow is invisible to the author and total to the audience.

DECK := dose-finding-program-consequences
PY ?= python3

.PHONY: all render preflight check selftest vocabulary vendor-sync vendor-record clean

all: check

render:
	quarto render $(DECK).qmd

# Renders first, so the gate can never certify a stale HTML file. The gate also
# refuses stale input on its own, but doing the render here removes the failure mode
# where somebody runs the gate, sees green, and has not rendered their fix.
preflight: render
	node tools/viewport-preflight.mjs

# The four program architectures must carry one name each, in the projected prose and in every
# figure the deck embeds. Three names for four things is what sent a room away with a takeaway
# the deck's own mechanism slide refuses. Reads sources only, so it needs no render and runs
# before the slow gate.
vocabulary:
	Rscript check/vocabulary_check.R

# The research repository is the scientific authority and this deck carries a frozen delivery
# snapshot of its figure producers. Every producer records the commit it came from and the hash of
# the bytes it copied, and this refuses when a snapshot has drifted from what it records. The deck
# has to render on a machine that has only the deck, so an absent research repository skips the
# comparison rather than failing it. Sources only, so it runs before the slow gate.
vendor-sync:
	$(PY) check/vendor_sync.py

# Re-vendor. Run it after landing a producer change in the research repository, never to make a
# failing `vendor-sync` go quiet, which would record the deck as its own authority.
vendor-record:
	$(PY) check/vendor_sync.py --record

# What to run before handing the deck to anyone.
check: selftest vocabulary vendor-sync preflight

# Proves the gate can fail. See tools/preflight-selftest.sh for why this is not
# optional ceremony.
selftest:
	bash tools/preflight-selftest.sh

clean:
	rm -rf $(DECK)_files tools/fixtures/preflight-fixture.html tools/fixtures/preflight-fixture_files
