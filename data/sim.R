# Simulated data

library(tidyverse)

# Directories used
data_dir <- here::here("data")

# Functions ===================================================================

#' Simulate data
#'
#' The underlying model is for post-intervention titres.
#'
#' @param n_per_group Number of participants in a group.
#' @param weeks Post-intervention week indexes.
#' @param beta_0,beta_base,beta_base Regression parameters.
#' @param group_parameters Group-associated regression parameters expressed
#'   as deviations from the reference.
#' @param random_sds Random effect standard deviations.
#' @param logtitre_sd Logtitre standard deviation.
simulate_data <- function(n_per_group, weeks, beta_0, beta_base, beta_week,
                          group_parameters, random_sds, logtitre_sd,
                          logtitre_base_mean, logtitre_base_sd) {
  tibble(
    group = names(group_parameters),
    beta_0_group = beta_0 +
      map_dbl(group, ~ group_parameters[[.x]][["beta_0"]]),
    beta_base_group = beta_base +
      map_dbl(group, ~ group_parameters[[.x]][["beta_base"]]),
    beta_week_group = beta_week +
      map_dbl(group, ~ group_parameters[[.x]][["beta_week"]])
  ) %>%
    slice(rep(1:n(), each = n_per_group)) %>%
    mutate(
      ind = 1:n(),
      logtitre_base = rnorm(n(), logtitre_base_mean, logtitre_base_sd),
      beta_0_ind = rnorm(n(), beta_0_group, random_sds[["beta_0"]]),
      beta_base_ind = rnorm(n(), beta_base_group, random_sds[["beta_base"]]),
      beta_week_ind = rnorm(n(), beta_week_group, random_sds[["beta_week"]])
    ) %>%
    slice(rep(1:n(), each = length(weeks))) %>%
    mutate(
      week = rep(weeks, n_per_group * length(group_parameters)),
      logtitre_group_exp = beta_0_group + beta_base_group * logtitre_base +
        beta_week_group * week,
      logtitre_ind_exp = beta_0_ind + beta_base_ind * logtitre_base +
        beta_week_ind * week,
      logtitre_ind = rnorm(n(), logtitre_ind_exp, logtitre_sd)
    )
}

mod_std_pars <- function(std_pars, ...) {
  new_pars <- list(...)
  for (new_par in names(new_pars)) {
    std_pars[[new_par]] <- new_pars[[new_par]]
  }
  std_pars
}

save_sim <- function(data, name) {
  write_csv(data, file.path(data_dir, glue::glue("sim-{name}.csv")))
}

# Script ======================================================================

# Everything is expressed as deviation from the reference
group_parameters <- list(
  placebo = c("beta_0" = 0, "beta_base" = 0, "beta_week" = 0),
  low_dose = c("beta_0" = 2, "beta_base" = 0, "beta_week" = 0),
  high_dose_1 = c("beta_0" = 3, "beta_base" = 0, "beta_week" = 0),
  high_dose_2 = c("beta_0" = 4, "beta_base" = 0, "beta_week" = 0)
)

std_pars <- list(
  n_per_group = 24, weeks = seq(2, 8, 2),
  beta_0 = 0, beta_base = 1, beta_week = -0.1,
  group_parameters = group_parameters,
  random_sds = list("beta_0" = 0, "beta_base" = 0, "beta_week" = 0),
  logtitre_sd = 0.5, logtitre_base_mean = 1, logtitre_base_sd = 0.5
)

simulation_parameters <- list(
  norand = std_pars,
  rand = mod_std_pars(
    std_pars,
    random_sds = list("beta_0" = 0.25, "beta_base" = 0, "beta_week" = 0.1),
    logtitre_sd = 0.3
  )
)

simulated_data <- map(simulation_parameters, ~ do.call(simulate_data, .x))

iwalk(simulated_data, save_sim)
