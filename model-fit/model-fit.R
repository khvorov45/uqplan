# Model fitting

library(tidyverse)

# Directories used
data_dir <- here::here("data")
model_fit_dir <- here::here("model-fit")

# Functions ===================================================================

source(file.path(data_dir, "read_data.R"))

fit_norand <- function(data) {
  lm(logtitre ~ week + hockey + group:week + group:hockey, data)
}

fit_rand <- function(data) {
  lme4::lmer(
    logtitre ~ week + hockey + group:week + group:hockey +
      (week + hockey | ind),
    data,
    control = lme4::lmerControl(optimizer = "Nelder_Mead")
  )
}

gen_to_pred <- function(data) {
  all_weeks <- unique(data$week)
  all_groups <- unique(data$group)
  to_pred <- tibble(
    week = rep(all_weeks, length(all_groups)),
    group = rep(all_groups, each = length(all_weeks)),
    hockey = if_else(week < 2L, 0L, week - 2L)
  )
}

gen_predict <- function(fit, data) {
  to_pred <- gen_to_pred(data)
  preds <- predict(fit, to_pred, se.fit = TRUE)
  mutate(
    to_pred,
    fit = preds$fit, fit_se = preds$se.fit,
    fit_low = fit - qnorm(0.975) * fit_se,
    fit_high = fit + qnorm(0.975) * fit_se
  )
}

predict_rand <- function(fit, data) {
  to_pred <- gen_to_pred(data)
  predict(fit, to_pred, re.form = NA)
}

save_preds <- function(data, name) {
  write_csv(data, file.path(model_fit_dir, glue::glue("preds-{name}.csv")))
}

# Script ======================================================================

sim_norand <- read_data("sim-norand")
fit_sim_norand <- fit_norand(sim_norand)
preds_sim_norand <- gen_predict(fit_sim_norand, sim_norand)
save_preds(preds_sim_norand, "sim-norand")

sim_rand <- read_data("sim-rand")
fit_sim_rand <- fit_rand(sim_rand)

sim_rand %>%
  group_by(ind) %>%
  mutate(logtitre_base = logtitre[week == 0L]) %>%
  ungroup() %>%
  filter(week > 0L)
