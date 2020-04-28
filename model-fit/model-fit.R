# Model fitting

library(tidyverse)

# Directories used
data_dir <- here::here("data")
model_fit_dir <- here::here("model-fit")

# Functions ===================================================================

source(file.path(data_dir, "read_data.R"))

fit_norand <- function(data) {
  lm(logtitre_ind ~ group + logtitre_base + week, data)
}

fit_rand <- function(data) {
  lme4::lmer(
    logtitre_ind ~ group + logtitre_base + week + (1 | ind),
    data,
    control = lme4::lmerControl(optimizer = "Nelder_Mead")
  )
}

# Script ======================================================================

sim_norand <- read_data("sim-norand")
fit_sim_norand <- fit_norand(sim_norand)

sim_rand <- read_data("sim-rand")
fit_sim_rand <- fit_rand(sim_rand)
