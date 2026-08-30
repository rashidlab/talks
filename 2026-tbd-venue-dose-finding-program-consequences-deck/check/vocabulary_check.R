# ARCHITECTURE VOCABULARY GUARD FOR THIS DECK.
#
# Run it with
#   Rscript check/vocabulary_check.R
# from the deck root. It exits non-zero and names the offending file and line on any violation.
#
# WHY THIS EXISTS. Three figures and the surrounding prose named the same four program
# architectures three different ways. An audience-comprehension pass found the room leaving with
# "keep two doses", a takeaway the deck's own mechanism slide explicitly refuses. The four names
# below are now the deck's canonical set, and a naming convention that lives only in a
# recollection is a naming convention that drifts back. This check makes the convention a build
# failure instead.
#
# WHAT IS AUDIENCE-FACING, WHICH IS THE WHOLE SCOPE OF THIS CHECK.
#   1. The qmd OUTSIDE `::: {.notes}` blocks. Notes are spoken by the presenter, never projected,
#      and the presenter is free to say "the hard-boundary one" out loud. Notes are exempt.
#   2. The string literals of every figure producer whose output the deck embeds. Literals, not
#      whole files, because a comment explaining why a name was retired must be able to write the
#      retired name down. Comments are not projected either.
#
# HOW SCOPE IS DERIVED RATHER THAN LISTED. The images are read out of the qmd, and a producer is
# in scope when its own text names an embedded image. That is why the archival producers and the
# ones whose figures the deck dropped are silently out of scope, and why re-embedding any of them
# pulls its producer back into scope with no edit here. Every embedded image must have a producer,
# so a figure whose producer was never vendored into this repo fails the check rather than
# escaping it.

CANON <- c(
  single             = "Commit early",
  parallel           = "Keep both through confirmation",
  select_exclude     = "Select one, then restart evidence",
  select_incorporate = "Select one, then reuse evidence")

# THE RETIRED VARIANTS. Each pattern is written to tolerate the line breaks a drawn label carries,
# because a figure wraps "Fresh-\nconfirmation" across two lines and a naive literal would miss
# it. Whitespace is normalised to single spaces before matching, so a break reads as a space.
#
# EACH PATTERN IS CHECKED BELOW AGAINST THE CANONICAL SET ITSELF, so a pattern broad enough to
# condemn an approved name cannot ship. That is the failure direction a retired-word list gets
# wrong, and it would turn this guard into an obstacle to using the very vocabulary it enforces.
RETIRED <- c(
  "keep both options"               = "keep\\s+both\\s+options",
  "confirm both doses"              = "confirm\\s+both\\s+doses",
  "fresh-confirmation"              = "fresh-?\\s*confirmation",
  "evidence-reuse"                  = "evidence-?\\s*reuse",
  "select, then restart"            = "select,\\s*then\\s+restart",
  "select, then reuse"              = "select,\\s*then\\s+reuse",
  "versus commit early to one dose" = "versus\\s+commit\\s+early\\s+to\\s+one\\s+dose",
  "commit to one dose"              = "commit\\s+to\\s+one\\s+dose")

fail <- character(0)
note <- function(...) cat(...,  "\n", sep = "")
add <- function(...) fail <<- c(fail, paste0(...))

squash <- function(x) gsub("\\s+", " ", trimws(x))

hits <- function(txt) {
  # Returns the retired-variant names that appear in one normalised string.
  s <- squash(txt)
  names(RETIRED)[vapply(RETIRED, function(p) grepl(p, s, ignore.case = TRUE, perl = TRUE),
                        logical(1))]
}

# ---- THE PATTERNS MUST NOT CONDEMN THE CANONICAL NAMES ---------------------------------------
for (nm in names(CANON)) {
  h <- hits(CANON[[nm]])
  if (length(h)) {
    add("retired-variant pattern '", paste(h, collapse = ", "),
        "' matches the CANONICAL name '", CANON[[nm]], "'. The pattern is too broad.")
  }
}

# ==============================================================================================
# PART 1. THE QMD, WITH SPEAKER NOTES REMOVED.
# ==============================================================================================

qmd_path <- Sys.glob("*.qmd")
if (length(qmd_path) != 1L) {
  add("expected exactly one .qmd at the deck root, found ", length(qmd_path), ".")
  qmd_path <- character(0)
}

audience_lines <- data.frame(line = integer(0), text = character(0), stringsAsFactors = FALSE)
if (length(qmd_path) == 1L) {
  raw <- readLines(qmd_path, warn = FALSE)
  # A depth counter rather than a toggle. A fenced div that opens inside a notes block would
  # otherwise close the block early and let the rest of the note into the audience text.
  depth <- 0L
  notes_depth <- NA_integer_
  keep <- logical(length(raw))
  for (i in seq_along(raw)) {
    s <- trimws(raw[i])
    opens <- grepl("^:::+\\s*\\S", s)
    closes <- grepl("^:::+\\s*$", s)
    if (opens) {
      depth <- depth + 1L
      if (is.na(notes_depth) && grepl("\\.notes", s)) notes_depth <- depth
      keep[i] <- is.na(notes_depth)
    } else if (closes) {
      keep[i] <- is.na(notes_depth)
      if (!is.na(notes_depth) && depth == notes_depth) notes_depth <- NA_integer_
      depth <- max(0L, depth - 1L)
    } else {
      keep[i] <- is.na(notes_depth)
    }
  }
  audience_lines <- data.frame(line = which(keep), text = raw[keep], stringsAsFactors = FALSE)
  note(sprintf("qmd %s: %d lines, %d audience-facing, %d in speaker notes.",
               qmd_path, length(raw), sum(keep), sum(!keep)))
  # A notes-stripper that strips everything, or nothing, would pass this file vacuously.
  if (sum(keep) == 0L || sum(!keep) == 0L) {
    add("the speaker-note stripper kept ", sum(keep), " of ", length(raw),
        " lines, which means it is not separating notes from audience text.")
  }
  for (k in seq_len(nrow(audience_lines))) {
    h <- hits(audience_lines$text[k])
    if (length(h)) {
      add(qmd_path, ":", audience_lines$line[k], " audience-facing prose uses the retired '",
          paste(h, collapse = ", "), "'.")
    }
  }
}

# ==============================================================================================
# PART 2. THE FIGURE PRODUCERS THE DECK ACTUALLY EMBEDS.
# ==============================================================================================

qmd_body <- paste(audience_lines$text, collapse = "\n")
# Only markdown image placements count. The YAML logo and any other chrome is not a figure, has
# no producer, and would turn the coverage requirement below into noise. The alt text is allowed
# to be anything, so a caption added later does not quietly drop a figure out of scope.
embedded <- unique(unlist(regmatches(
  qmd_body,
  gregexpr("(?<=!\\[)[^]]*\\]\\([^)]+\\.png(?=[)\\s{])", qmd_body, perl = TRUE))))
embedded <- unique(sub(".*\\(", "", embedded))
note(sprintf("qmd embeds %d images: %s", length(embedded), paste(embedded, collapse = ", ")))
if (length(embedded) == 0L) {
  add("no embedded images were found in the qmd body, so the producer scan would be vacuous.")
}

producer_files <- setdiff(
  c(Sys.glob("*.R"), Sys.glob("figure-producers/*.R"), Sys.glob("scripts/*.R")),
  normalizePath("check/vocabulary_check.R", mustWork = FALSE))
producer_files <- producer_files[!grepl("^check/", producer_files)]

# STRING LITERALS ONLY, taken from R's own parser rather than a regex over the file. A regex
# cannot tell a drawn label from a comment discussing one, and this check must let a comment name
# a retired variant while forbidding a figure from drawing it.
literals_of <- function(path) {
  pd <- tryCatch({
    parse(path, keep.source = TRUE)
    utils::getParseData(parse(path, keep.source = TRUE))
  }, error = function(e) NULL)
  if (is.null(pd)) {
    add(path, " does not parse, so its drawn strings cannot be read.")
    return(data.frame(line = integer(0), value = character(0), stringsAsFactors = FALSE))
  }
  st <- pd[pd$token == "STR_CONST", c("line1", "text")]
  if (!nrow(st)) return(data.frame(line = integer(0), value = character(0),
                                   stringsAsFactors = FALSE))
  vals <- vapply(st$text, function(z) {
    tryCatch(as.character(eval(parse(text = z))), error = function(e) z)
  }, character(1), USE.NAMES = FALSE)
  data.frame(line = st$line1, value = vals, stringsAsFactors = FALSE)
}

LIT <- lapply(producer_files, literals_of)
names(LIT) <- producer_files

# A producer is in scope when one of its literals names an embedded image.
in_scope <- character(0)
covers <- setNames(vector("list", length(embedded)), embedded)
for (p in producer_files) {
  vals <- LIT[[p]]$value
  stems <- sub("\\.png$", "", embedded)
  named <- embedded[vapply(seq_along(embedded), function(j)
    any(grepl(stems[j], vals, fixed = TRUE)), logical(1))]
  if (length(named)) {
    in_scope <- c(in_scope, p)
    for (img in named) covers[[img]] <- c(covers[[img]], p)
  }
}
uncovered <- names(covers)[lengths(covers) == 0L]
if (length(uncovered)) {
  add("no producer in this repo writes ", paste(uncovered, collapse = ", "),
      ". Vendor the producer here or the deck ships a figure whose drawn text nothing checks.")
}
note(sprintf("%d of %d producers are in scope: %s", length(in_scope), length(producer_files),
             paste(basename(in_scope), collapse = ", ")))

for (p in in_scope) {
  L <- LIT[[p]]
  for (k in seq_len(nrow(L))) {
    h <- hits(L$value[k])
    if (length(h)) {
      add(p, ":", L$line[k], " a drawn string uses the retired '",
          paste(h, collapse = ", "), "'.")
    }
  }
}

# ==============================================================================================
# PART 3. THE POSITIVE HALF. NAMING ONE ARCHITECTURE MEANS NAMING ALL FOUR THE SAME WAY.
# ==============================================================================================
#
# Absence of the retired names is not presence of the canonical ones. A producer renamed to a
# fourth private vocabulary would pass Part 2 untouched. The rule is all-or-nothing per artifact,
# which is self-scoping, so a figure that names no architecture stays out of it.

canon_audit <- function(where, blob) {
  s <- squash(blob)
  present <- vapply(CANON, function(cn) grepl(cn, s, fixed = TRUE), logical(1))
  if (any(present) && !all(present)) {
    add(where, " names ", sum(present), " of the four architectures. Naming any means naming all",
        " four with the canonical strings. Missing: ",
        paste(sprintf("'%s'", CANON[!present]), collapse = ", "), ".")
  }
  any(present)
}

named_anywhere <- FALSE
if (length(qmd_path) == 1L) {
  named_anywhere <- canon_audit(paste0(qmd_path, " (audience-facing prose)"), qmd_body) ||
    named_anywhere
}
for (p in in_scope) {
  named_anywhere <- canon_audit(p, paste(LIT[[p]]$value, collapse = " ")) || named_anywhere
}
# A vacuous pass is the failure mode this whole project keeps paying for. If nothing anywhere
# names an architecture, Part 3 checked nothing and says so.
if (!named_anywhere) {
  add("nothing in the deck names any of the four canonical architectures, so the positive check ",
      "ran on no content and proves nothing.")
}

# ==============================================================================================
# VERDICT.
# ==============================================================================================

if (length(fail)) {
  note("")
  note("VOCABULARY CHECK FAILED, ", length(fail), " problem(s).")
  for (f in fail) note("  ", f)
  note("")
  note("The canonical four are:")
  for (cn in CANON) note("  ", cn)
  quit(status = 1L)
}

note("")
note("VOCABULARY CHECK PASSED. The four architectures are named identically in the deck prose ",
     "and in every figure producer the deck embeds.")
