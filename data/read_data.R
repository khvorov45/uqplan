read_data <- function(name) {
  read_csv(
    file.path(data_dir, glue::glue("{name}.csv")),
    col_types = cols(
      group = col_factor(
        c("placebo", "low_dose", "high_dose_1", "high_dose_2")
      ),
      week = col_integer()
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
