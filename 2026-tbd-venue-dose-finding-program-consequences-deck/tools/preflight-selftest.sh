#!/usr/bin/env bash
#
# Exercises tools/viewport-preflight.mjs against known-bad and known-good input.
#
# WHY. The gate's only job is to fail on overflowing slides. If it silently stopped
# measuring, if a Chrome update changed the geometry API, or if a refactor broke the
# element walk, the gate would go green on a broken deck and nobody would notice
# until the room did. This script forces it onto input where it MUST fail, and onto
# input where it MUST pass, through the same quarto and CSS path as the real deck.
#
# Run it after any change to the gate, to the stylesheets, or to Chrome.
set -euo pipefail

cd "$(dirname "$0")/.."
DECK_DIR="$PWD"

echo "=== rendering the control fixture ==="
( cd tools/fixtures && quarto render preflight-fixture.qmd >/dev/null )

echo
echo "=== control 1, the gate must FAIL on the overfilled slide and PASS the safe one ==="
# --expect-fail 3 asserts the flagged set is EXACTLY {3}. Slide 1 is the title slide,
# slide 2 is the safe slide, slide 3 is the overfilled slide. A gate that stopped
# detecting overflow reports {} and this fails. A gate that over-flags reports {2,3}
# and this also fails.
node tools/viewport-preflight.mjs \
  --html tools/fixtures/preflight-fixture.html \
  --port 9351 --expect-fail 3 --verbose

echo
echo "=== control 2, the staleness guard must refuse a render older than its source ==="
touch tools/fixtures/preflight-fixture.qmd
set +e
node tools/viewport-preflight.mjs --html tools/fixtures/preflight-fixture.html --port 9352 >/dev/null 2>&1
STALE_RC=$?
set -e
if [ "$STALE_RC" -ne 2 ]; then
  echo "FAIL: expected exit 2 from the staleness guard, got $STALE_RC"
  exit 1
fi
echo "staleness guard returned 2 as required"

echo
echo "SELF-TEST PASSED. The gate fails on overflow, passes on fitting content, and refuses stale renders."
