# Simulated data

library(tidyverse)
library(here)

# Directories used
data_dir <- here("data")

# Functions ===================================================================

simulate_data <- function(n_per_group, beta_0, beta_week, beta_hockey,
                          group_parameters, random_sds, logtitre_sd) {
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
    beta_week_group = beta_week + map_dbl(
      group, ~ group_parameters[[.x]][["beta_week"]]
    ),
    beta_hockey_group = beta_hockey + map_dbl(
      group, ~ group_parameters[[.x]][["beta_hockey"]]
    )
  ) %>%
    group_by(ind) %>%
    mutate(
      beta_week_ind = rnorm(
        1, first(beta_week_group), random_sds[["beta_week"]]
      ),
      beta_hockey_ind = rnorm(
        1, first(beta_hockey_group), random_sds[["beta_hockey"]]
      )
    ) %>%
    ungroup() %>%
    mutate(
      hockey = if_else(week < 2L, 0L, week - 2L),
      logtitre_exp =
        beta_0_ind + beta_week_ind * week + beta_hockey_ind * hockey,
      logtitre = rnorm(n(), logtitre_exp, logtitre_sd)
    )
}

save_sim <- function(data, name) {
  write_csv(data, file.path(data_dir, glue::glue("sim-{name}.csv")))
}

# Script ======================================================================

# Everything is expressed as deviation from the reference
group_parameters <- list(
  placebo = c("beta_week" = 0, "beta_hockey" = 0),
  low_dose = c("beta_week" = 2, "beta_hockey" = -2.1),
  high_dose_1 = c("beta_week" = 3, "beta_hockey" = -3.07),
  high_dose_2 = c("beta_week" = 4, "beta_hockey" = -4.05)
)

expected <- simulate_data(
  n_per_group = 1,
  beta_0 = 0,
  beta_week = 0,
  beta_hockey = 0,
  group_parameters = group_parameters,
  random_sds = list("beta_0" = 0, "beta_week" = 0, "beta_hockey" = 0),
  logtitre_sd = 0
)
save_sim(expected, "expected")
