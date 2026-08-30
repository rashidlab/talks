#!/usr/bin/env python3
"""VENDORED PRODUCER SYNCHRONIZATION GUARD.

THE CONTRACT THIS ENFORCES.

    The research repository is the scientific authority.
    The deck carries a frozen delivery snapshot.

Every figure producer in this deck is a byte copy of a script in baton-dosefinding.
Nothing recorded that, nothing checked it, and a byte copy with no recorded lineage is
indistinguishable from a fork. The two directions of drift have very different
consequences and the guard treats them differently.

  EDITING THE DECK'S COPY is a defect. It creates a second authority for a scientific
  figure, and the paper and the slide can then disagree with nobody able to say which is
  right. This fails.

  THE RESEARCH REPOSITORY MOVING ON is not a defect. The deck is a delivery snapshot of
  a stated moment and is supposed to hold still. This is reported and does not fail.

  THE RESEARCH REPOSITORY BEING ABSENT is not a defect either. The deck must render on a
  machine that has only the deck, so a missing repository, an unresolvable commit or a
  missing source file each SKIP the comparison for that producer. Only divergence fails.

WHY A CONTENT HASH AND NOT AN MTIME. A copy carries no timestamp relationship to its
source, and a checkout resets mtimes wholesale. sha256 of the bytes is the only statement
about a snapshot that survives being moved between machines.

WHY THE RECORD CARRIES A COMMIT AS WELL AS A HASH. A hash says two files agree. It cannot
say what the deck's copy was taken FROM, which is the question anyone auditing a figure in
the talk actually has. The commit answers that, and it is the handle for recovering the
source when the working tree has moved on.

WHY UNCOMMITTED SOURCES ARE RECORDED AS SUCH RATHER THAN ROUNDED TO HEAD. Several
producers were vendored from a research working tree that had uncommitted edits, and one
whole directory is untracked. Recording HEAD for those would name a commit that does not
contain the vendored bytes, which is a provenance claim the record cannot support. They
are marked `uncommitted`, checked against the research working tree instead, and the
absence of a durable source is visible rather than papered over.

USAGE
  python3 check/vendor_sync.py            verify the manifest against both repositories
  python3 check/vendor_sync.py --record   re-vendor: rewrite the manifest from current state

EXIT CODES
  0  every producer agrees with its recorded source, or the comparison was skipped
  1  at least one producer diverged, or the census is incomplete
  2  the guard could not run
"""

import hashlib
import json
import os
import subprocess
import sys
from datetime import date
from pathlib import Path

DECK = Path(__file__).resolve().parent.parent
MANIFEST = DECK / "check" / "vendored-producers.json"

# The default location of the scientific authority. `BATOND_PAPER_REPO` overrides it, which
# is the same variable the producers themselves use to root their artifact reads, so one
# statement of "where the paper repository is" serves both.
DEFAULT_REPO = Path("~/research/trials-research/baton-dosefinding").expanduser()

CONTRACT = ("The research repository is the scientific authority. "
            "The deck carries a frozen delivery snapshot.")


def sha256_bytes(b):
    return hashlib.sha256(b).hexdigest()


def sha256_file(p):
    return sha256_bytes(Path(p).read_bytes())


def git(repo, *args):
    """Run git in `repo`, returning (ok, stdout_bytes). Never raises on a git failure,
    because every git failure here means "the source is not available", which is a skip
    and not an error."""
    try:
        r = subprocess.run(["git", "-C", str(repo), *args],
                           stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    except OSError:
        return False, b""
    return r.returncode == 0, r.stdout


def find_repo():
    env = os.environ.get("BATOND_PAPER_REPO", "").strip()
    cand = Path(env).expanduser() if env else DEFAULT_REPO
    return cand if cand.is_dir() else None


def deck_producers():
    """The census of deck R scripts, DERIVED rather than listed.

    Every `.R` file in the deck is either vendored from the research repository or native
    to the deck, and the manifest has to account for all of them. A file in neither list is
    a census failure, because the interesting case is a producer that arrived without
    anyone recording where it came from, and a hand-maintained list would simply not
    mention it."""
    out = []
    for p in sorted(DECK.rglob("*.R")):
        rel = p.relative_to(DECK)
        # Quarto's sidecar directory holds render byproducts, not sources.
        if any(part.endswith("_files") for part in rel.parts):
            continue
        out.append(rel.as_posix())
    return out


# ---------------------------------------------------------------------------
# Record
# ---------------------------------------------------------------------------

def record(repo):
    if repo is None:
        print("vendor-sync: cannot record without the research repository. "
              "Set BATOND_PAPER_REPO or place it at %s." % DEFAULT_REPO, file=sys.stderr)
        return 2

    ok, head = git(repo, "rev-parse", "HEAD")
    if not ok:
        print("vendor-sync: %s is not a git repository." % repo, file=sys.stderr)
        return 2
    head = head.decode().strip()

    producers, native, unrecorded = [], [], []
    for rel in deck_producers():
        name = Path(rel).name
        matches = [q for q in repo.rglob(name) if ".git" not in q.parts]
        if not matches:
            native.append(rel)
            continue
        if len(matches) > 1:
            # AMBIGUITY IS REFUSED, NEVER GUESSED. Picking one of two same-named scripts
            # would record a provenance claim with a coin flip behind it.
            unrecorded.append({"vendored": rel, "reason":
                               "matches %d files in the research repository: %s"
                               % (len(matches), ", ".join(
                                   str(m.relative_to(repo)) for m in matches))})
            continue

        src = matches[0]
        src_rel = src.relative_to(repo).as_posix()
        snap = sha256_file(DECK / rel)

        # WHICH SOURCE DO THE VENDORED BYTES ACTUALLY COME FROM. Ask the blob at HEAD
        # first, since a committed source is a durable one. Fall back to the working tree
        # and say so. Match neither and the snapshot has no source at all, which is the
        # drift this guard exists to surface and must not be recorded as if it were fine.
        okb, blob = git(repo, "show", "%s:%s" % (head, src_rel))
        wt = src.read_bytes()
        if okb and sha256_bytes(blob) == snap:
            state, source_sha = "committed", snap
        elif sha256_bytes(wt) == snap:
            state, source_sha = "uncommitted", snap
        else:
            # A SNAPSHOT WITH NO SOURCE IS RECORDED AS EXACTLY THAT, and `check` fails on
            # it. Two weaker designs were rejected. Silently recording the deck's bytes
            # would make the deck its own authority, which is the contract inverted.
            # Aborting the whole recording would leave every other producer unrecorded
            # because of one, and would hide the open item in a console message instead of
            # putting it in the artifact where the next person will find it.
            unrecorded.append({
                "vendored": rel,
                "source_path": src_rel,
                "reason": "the deck's copy matches neither the committed source at %s nor "
                          "the research working tree, so it has diverged from the "
                          "scientific authority. Land the change in the research "
                          "repository, then re-record." % head[:12]})
            continue

        producers.append({
            "vendored": rel,
            "source_path": src_rel,
            "source_commit": head,
            "source_state": state,
            "source_sha256": source_sha,
            "snapshot_sha256": snap,
        })

    MANIFEST.write_text(json.dumps({
        "contract": CONTRACT,
        "source_repo": "baton-dosefinding",
        "source_repo_default_path": str(DEFAULT_REPO),
        "source_repo_env": "BATOND_PAPER_REPO",
        "recorded_at": date.today().isoformat(),
        "deck_native": native,
        "unrecorded": unrecorded,
        "producers": producers,
    }, indent=2) + "\n")
    print("vendor-sync: recorded %d vendored producers and %d deck-native scripts at %s"
          % (len(producers), len(native), head[:12]))
    if unrecorded:
        # NONZERO EXIT so a recording that could not establish every provenance is never
        # mistaken for a clean one.
        print("vendor-sync: %d producer(s) COULD NOT BE RECORDED and `check` will fail on "
              "them." % len(unrecorded), file=sys.stderr)
        for u in unrecorded:
            print("  %s: %s" % (u["vendored"], u["reason"]), file=sys.stderr)
        return 1
    return 0


# ---------------------------------------------------------------------------
# Check
# ---------------------------------------------------------------------------

def check(repo):
    if not MANIFEST.exists():
        print("vendor-sync: no manifest at %s. Run --record." % MANIFEST, file=sys.stderr)
        return 2
    man = json.loads(MANIFEST.read_text())
    producers = man["producers"]
    unrecorded = man.get("unrecorded", [])
    recorded = ({e["vendored"] for e in producers}
                | set(man.get("deck_native", []))
                | {u["vendored"] for u in unrecorded})

    failures, notices, skipped, compared = [], [], 0, 0

    # THE CENSUS FIRST. A producer nobody recorded is the case a per-entry check cannot
    # see, because it iterates the record and the record does not mention it.
    for rel in deck_producers():
        if rel not in recorded:
            failures.append("%s is an R script the manifest does not account for. Run "
                            "--record, or declare it deck-native." % rel)
    for rel in sorted(recorded):
        if not (DECK / rel).exists():
            failures.append("%s is recorded but is not in the deck." % rel)

    # A PRODUCER WITH NO ESTABLISHED SOURCE IS A FAILURE AND NOT A CATEGORY OF ITS OWN.
    # It sits in the manifest so the open item is written down rather than remembered, and
    # it fails every run until it is closed.
    for u in unrecorded:
        failures.append("%s has no recorded source. %s" % (u["vendored"], u["reason"]))

    for e in producers:
        rel, vend = e["vendored"], DECK / e["vendored"]
        if not vend.exists():
            continue  # already reported by the census pass
        snap = sha256_file(vend)

        # THE SNAPSHOT'S OWN INTEGRITY, checked with no second repository involved. This is
        # the direction that matters and it must not depend on the research repository
        # being present, because the deck is the thing being handed to a room.
        if snap != e["snapshot_sha256"]:
            failures.append(
                "%s has been edited since it was vendored.\n"
                "      recorded %s\n      on disk  %s\n"
                "      The research repository is the authority. Make the change there, at "
                "%s, then re-vendor with --record."
                % (rel, e["snapshot_sha256"][:16], snap[:16], e["source_path"]))
            continue

        if repo is None:
            skipped += 1
            continue

        if e["source_state"] == "committed":
            ok, blob = git(repo, "show", "%s:%s" % (e["source_commit"], e["source_path"]))
            if not ok:
                # A rewritten history or a shallow clone is absence, not divergence.
                skipped += 1
                continue
            src = sha256_bytes(blob)
        else:
            sp = repo / e["source_path"]
            if not sp.exists():
                skipped += 1
                continue
            src = sha256_file(sp)

        compared += 1
        if src != snap:
            where = ("%s:%s" % (e["source_commit"][:12], e["source_path"])
                     if e["source_state"] == "committed"
                     else "the research working tree at %s" % e["source_path"])
            failures.append(
                "%s diverges from its recorded source %s.\n"
                "      source   %s\n      snapshot %s"
                % (rel, where, src[:16], snap[:16]))
            continue

        # NOT A FAILURE. The snapshot is frozen on purpose, so the authority moving past it
        # is the expected state of any deck older than a day. Reported so that whoever
        # re-renders a figure knows the snapshot is behind before they wonder why.
        wt = repo / e["source_path"]
        if wt.exists() and sha256_file(wt) != snap:
            notices.append("%s: the research copy has moved past this snapshot" % rel)

    print("VENDORED PRODUCER SYNC  %s" % man["contract"])
    print("  manifest              %d vendored, %d deck-native, recorded %s"
          % (len(producers), len(man.get("deck_native", [])), man.get("recorded_at", "?")))
    print("  research repository   %s" % (repo if repo else "ABSENT, source comparison skipped"))
    print("  compared              %d" % compared)
    print("  skipped               %d  (source unavailable, which is not a failure)" % skipped)
    for n in notices:
        print("  NOTICE  %s" % n)

    if failures:
        print("")
        print("FAIL. %d vendored producer problem(s)." % len(failures))
        for f in failures:
            print("  %s" % f)
        return 1
    print("")
    print("PASS. Every vendored producer agrees with the source it records.")
    return 0


if __name__ == "__main__":
    repo = find_repo()
    sys.exit(record(repo) if "--record" in sys.argv[1:] else check(repo))
