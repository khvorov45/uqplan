# Spaghetti plots

library(tidyverse)
library(here)

# Directories used
data_dir <- here("data")
data_plot_dir <- here("data-plot")

# Functions ===================================================================

read_data <- function(name) {
  read_csv(
    file.path(data_dir, glue::glue("{name}.csv")),
    col_types = cols(
      group = col_factor(c("placebo", "low_dose", "high_dose_1", "high_dose_2"))
    )
  ) %>%
    mutate(
      group = recode(
        group,
        "placebo" = "Placebo", "low_dose" = "Low dose",
        "high_dose_1" = "High dose 1", "high_dose_2" = "High dose 2"
      )
    )
}

spag_plot <- function(dat) {
  titre_breaks <- 5 * 2^(0:12)
  ggplot(dat, aes(week, logtitre)) +
    ggdark::dark_theme_bw(verbose = FALSE) +
    theme(strip.background = element_blank()) +
    facet_wrap(~group, nrow = 1) +
    scale_y_continuous(
      "Titre",
      breaks = log(titre_breaks), labels = titre_breaks
    ) +
    geom_line(aes(group = ind))
}

save_spag <- function(pl, name, width = 12, height = 7.5) {
  ggdark::ggsave_dark(
    file.path(data_plot_dir, glue::glue("spag-{name}.pdf")), pl,
    width = width, height = height, units = "cm"
  )
}

# Script ======================================================================

sim_expected <- read_data("sim-expected")
sim_expected_spag <- spag_plot(sim_expected)
save_spag(sim_expected_spag, "sim-expected")

sim_norand <- read_data("sim-norand")
sim_norand_spag <- spag_plot(sim_norand)
save_spag(sim_norand_spag, "sim-norand")
