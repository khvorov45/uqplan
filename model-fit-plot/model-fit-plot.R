# Plots of the fits

library(tidyverse)
library(here)

# Directories used
data_dir <- here("data")
model_fit_dir <- here("model-fit")
model_fit_plot_dir <- here("model-fit-plot")

# Functions ===================================================================

source(file.path(data_dir, "read_data.R"))

read_preds <- function(name) {
  read_csv(
    file.path(model_fit_dir, glue::glue("preds-{name}.csv")),
    col_types = cols(
      group = col_factor(c("Placebo", "Low dose", "High dose 1", "High dose 2"))
    )
  )
}

plot_preds <- function(preds, data) {
  titre_breaks <- 5 * 2^(0:12)
  ggplot(preds, aes(week, fit)) +
    ggdark::dark_theme_bw(verbose = FALSE) +
    theme(
      strip.background = element_blank(),
      panel.grid.minor.y = element_blank()
    ) +
    facet_wrap(~group, nrow = 1) +
    scale_y_continuous(
      "Titre",
      breaks = log(titre_breaks), labels = titre_breaks
    ) +
    geom_line(
      data = data, aes(week, logtitre, group = ind), alpha = 0.2,
      linetype = "31", lwd = 0.1
    ) +
    geom_ribbon(aes(ymin = fit_low, ymax = fit_high), alpha = 0.5) +
    geom_line()
}

save_preds_plot <- function(pl, name, width = 12, height = 7.5) {
  ggdark::ggsave_dark(
    file.path(model_fit_plot_dir, glue::glue("preds-plot-{name}.pdf")), pl,
    width = width, height = height, units = "cm"
  )
}

# Script ======================================================================

sim_norand <- read_data("sim-norand")
sim_norand_preds <- read_preds("sim-norand")
sim_norand_preds_plot <- plot_preds(sim_norand_preds, sim_norand)
save_preds_plot(sim_norand_preds_plot, "sim-norand")
