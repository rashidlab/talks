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
echo "=== control 2, the staleness guard must refuse a render older than any of its sources ==="
#
# WHY THREE SOURCES AND NOT ONE. With embed-resources the figures and the included
# partials are inlined at render time, so an edit to either leaves the HTML holding
# stale bytes with nothing in the output to reveal it. A guard watching only the qmd
# certified that HTML as current, which is the exact failure the guard exists to
# prevent. Each class below is edited on its own and must produce a refusal on its own.
#
# The touches are reverted afterwards, so a passing selftest leaves the tree as it
# found it and does not itself make the real deck look stale.
stale_case () {
  local LABEL="$1" TARGET="$2" PORT="$3"
  local BEFORE
  BEFORE=$(stat -c %y "$TARGET")
  touch "$TARGET"
  set +e
  node tools/viewport-preflight.mjs --html tools/fixtures/preflight-fixture.html --port "$PORT" >/dev/null 2>&1
  local RC=$?
  set -e
  touch -d "$BEFORE" "$TARGET"
  if [ "$RC" -ne 2 ]; then
    echo "FAIL: $LABEL, expected exit 2 from the staleness guard, got $RC"
    exit 1
  fi
  echo "  $LABEL returned 2 as required"
}

stale_case "the source qmd"        tools/fixtures/preflight-fixture.qmd  9352
stale_case "an embedded image"     RLlogoA.png                           9353
stale_case "an included partial"   tools/fixtures/fixture-partial.html   9354

echo
echo "=== control 3, a clean tree must still pass the staleness guard ==="
# The negative control for the negative control. A guard that refused everything would
# satisfy all three cases above and be useless, so it must also let untouched input
# through. Exit 1 is the overflow verdict on slide 3 and means the guard was cleared.
set +e
node tools/viewport-preflight.mjs --html tools/fixtures/preflight-fixture.html --port 9355 >/dev/null 2>&1
CLEAN_RC=$?
set -e
if [ "$CLEAN_RC" -eq 2 ]; then
  echo "FAIL: the staleness guard refused an untouched tree"
  exit 1
fi
echo "clean tree cleared the staleness guard"

echo
echo "SELF-TEST PASSED. The gate fails on overflow, passes on fitting content, and refuses a render"
echo "older than its qmd, its embedded images or its included partials."
