# Spaghetti plots

library(tidyverse)
library(here)

# Directories used
data_dir <- here("data")
data_plot_dir <- here("data-plot")

# Functions ===================================================================

read_data <- function(name, col_types = cols()) {
  read_csv(
    file.path(data_dir, glue::glue("{name}.csv")),
    col_types = col_types
  )
}

spag_plot <- function(dat) {
  ggplot(dat, aes(week, logtitre)) +
    ggdark::dark_theme_bw(verbose = FALSE) +
    facet_wrap(~group, nrow = 1) +
    geom_line(aes(group = ind))
}

save_spag <- function(pl, name, width = 12, height = 7.5) {
  ggdark::ggsave_dark(
    file.path(data_plot_dir, glue::glue("spag-{name}.pdf")), pl,
    width = width, height = height, units = "cm"
  )
}

# Script ======================================================================

sim_expected <- read_data(
  "sim-expected",
  cols(
    group = col_factor(c("reference", "low_dose", "high_dose_1", "high_dose_2"))
  )
)
sim_expected_spag <- spag_plot(sim_expected)
save_spag(sim_expected_spag, "sim-expected")
