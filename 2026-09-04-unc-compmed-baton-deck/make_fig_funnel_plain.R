# Fidelity ladder, redrawn 2026-09-03 to match the pipeline that actually ran
# for the manuscript (R/warmstart_core.R run_three_stage_warmstart + the
# post-Stage-1 high-fidelity validation gate; Stage 4 = multiseed_sensitivity.R).
# Bar WIDTH = designs still in play. Configured values from globals.yml:
# 3,000 / 5,000 / 10,000 replications; verification = 5 seeds x 10,000.
# The escalation stage is drawn dashed because it runs only when the
# validation gate fails (it was skipped in essentially all production runs).
library(ggplot2)
navy <- "#13294B"; car <- "#4B9CD3"; deep <- "#2E6A9F"; graph <- "#5B6670"; fog <- "#F4F6F8"; orange <- "#E07C24"
st <- data.frame(
  y = 4:1,
  w = c(8.4, 4.8, 4.8, 2.4),
  lab = c("Explore", "Validate", "Escalate (only if needed)", "Verify"),
  sub = c("3,000 trials each", "10,000 each", "5,000 then 10,000", "5 seeds x 10,000, all must pass"),
  reps = c("many candidate designs, 3,000 simulated trials each\n(space-filling seed, then model-guided batches)",
           "top feasible designs re-simulated at 10,000 each;\nif enough survive, skip straight to verification",
           "runs only if validation fails: narrowed search box,\n5,000 then 10,000 each",
           "the one design you report: 5 independent seeds\nx 10,000; all five must pass"))
fills <- c(fog, "#A8CFEA", "white", deep)
p <- ggplot(st) +
  geom_tile(aes(x = 0, y = y, width = w, height = 0.62),
            fill = fills, colour = navy, linewidth = 0.5,
            linetype = c("solid", "solid", "dashed", "solid")) +
  geom_text(data = st[1:3,], aes(x = 0, y = y + 0.02, label = lab), size = 5.4,
            fontface = "bold", colour = c(navy, navy, graph)) +
  geom_text(data = st[4,], aes(x = 0, y = y + 0.02, label = lab), size = 5.2,
            fontface = "bold", colour = "white") +
  geom_text(aes(x = 0, y = y - 0.47, label = sub), size = 5.0, colour = navy, fontface = "bold") +
  xlim(-5.0, 5.0) + ylim(0.35, 4.45) + theme_void() +
  theme(plot.margin = margin(4, 8, 4, 8))
ggsave("images/fig_funnel_plain.png", p, width = 9.0, height = 4.6, dpi = 300, bg = "white")
cat("funnel written\n")
