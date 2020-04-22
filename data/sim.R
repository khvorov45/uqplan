# Simulated data

library(tidyverse)
library(here)

# Directories used
data_dir <- here("data")

# Functions ===================================================================

simulate_data <- function() {
  0
}

# Script ======================================================================

simulate_data(
  n_per_group = 24,
  beta_0 = 0,
  parameters = list(
    reference = c("b0" = 0, "b1" = 0),
  )
)
