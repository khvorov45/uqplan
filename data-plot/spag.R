# Spaghetti plots

library(tidyverse)
library(here)

# Directories used
data_dir <- here("data")
data_plot_dir <- here("data-plot")

# Functions ===================================================================

source(file.path(data_dir, "read_data.R"))

spag_plot <- function(dat) {
  titre_breaks <- 5 * 2^(0:12)
  ggplot(dat, aes(week, logtitre)) +
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
    geom_line(aes(group = ind), alpha = 0.2) +
    geom_line(aes(y = logtitre_exp), lwd = 1, col = "red")
}

save_spag <- function(pl, name, width = 12, height = 7.5) {
  ggdark::ggsave_dark(
    file.path(data_plot_dir, glue::glue("spag-{name}.pdf")), pl,
    width = width, height = height, units = "cm"
  )
}

# Script ======================================================================

sim_norand <- read_data("sim-norand")
sim_norand_spag <- spag_plot(sim_norand)
save_spag(sim_norand_spag, "sim-norand")
