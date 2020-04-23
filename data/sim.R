# Simulated data

library(tidyverse)
library(here)

# Directories used
data_dir <- here("data")

# Functions ===================================================================

simulate_data <- function(n_per_group, beta_0, group_parameters, random_sds) {
  weeks <- c(0L, 2L, 4L, 6L, 8L)
  tibble(
    ind = rep(
      seq_len(n_per_group * length(group_parameters)),
      each = length(weeks)
    ),
    week = rep(weeks, length(group_parameters) * n_per_group),
    group = rep(
      names(group_parameters),
      each = length(weeks) * n_per_group
    ),
    beta_0_ind = rep(
      rnorm(
        n_per_group * length(group_parameters), beta_0, random_sds[["beta_0"]]
      ),
      each = length(weeks)
    ),
    b1_before_group = map_dbl(
      group, ~ group_parameters[[.x]][["b1_before"]]
    ),
    b1_after_group = map_dbl(
      group, ~ group_parameters[[.x]][["b1_after"]]
    ),
    b1_before_ind = rep(rnorm(
      n_per_group * length(group_parameters),
      unique(b1_before_group), random_sds[["b1_before"]]
    ), each = length(weeks)),
    b1_after_ind = rep(rnorm(
      n_per_group * length(group_parameters),
      unique(b1_after_group), random_sds[["b1_after"]]
    ), each = length(weeks)),
    hockey = if_else(week < 2L, 0L, week - 2L),
    logtitre = beta_0_ind + b1_before_ind * week + b1_after_ind * hockey
  )
}

# Script ======================================================================

# Everything is expressed as parameters, not differences
group_parameters <- list(
  reference = c("b1_before" = 0, "b1_after" = 0),
  low_dose = c("b1_before" = 3, "b1_after" = -0.1),
  high_dose_1 = c("b1_before" = 4, "b1_after" = -0.07),
  high_dose_2 = c("b1_before" = 5, "b1_after" = -0.05)
)

simulated_data <- simulate_data(
  n_per_group = 24,
  beta_0 = 0,
  group_parameters = group_parameters,
  random_sds = list("beta_0" = 1, "b1_before" = 1.2, "b1_after" = 0.02)
)

write_csv(simulated_data, file.path(data_dir, "sim.csv"))
