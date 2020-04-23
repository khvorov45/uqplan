# Model fitting

library(tidyverse)
library(here)
library(lme4)

# Directories used
data_dir <- here("data")
model_fit_dir <- here("model-fit")

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

fit_norand <- function(data) {
  lm(logtitre ~ week + hockey + group:week + group:hockey, data)
}

gen_predict <- function(fit, data) {
  all_weeks <- unique(data$week)
  all_groups <- unique(data$group)
  to_pred <- tibble(
    week = rep(all_weeks, length(all_groups)),
    group = rep(all_groups, each = length(all_weeks)),
    hockey = if_else(week < 2L, 0, week - 2L)
  )
  preds <- predict(fit, to_pred, se.fit = TRUE)
  mutate(
    to_pred,
    fit = preds$fit, fit_se = preds$se.fit,
    fit_low = fit - qnorm(0.975) * fit_se,
    fit_high = fit + qnorm(0.975) * fit_se
  )
}

save_preds <- function(data, name) {
  write_csv(data, file.path(model_fit_dir, glue::glue("preds-{name}.csv")))
}

# Script ======================================================================

sim_norand <- read_data("sim-norand")
fit_norand_sim_norand <- fit_norand(sim_norand)
preds_sim_norand <- gen_predict(fit_norand_sim_norand, sim_norand)
save_preds(preds_sim_norand, "sim-norand")
