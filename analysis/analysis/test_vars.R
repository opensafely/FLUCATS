library(dplyr)
library(lubridate)
library(testthat)



output_dir <- "output"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

txt_file <- file("output/test_vars.txt", open = "wt")
sink(txt_file, type = "message")


create_mock_df <- function() {
  df <- data.frame(
    flucats_template_date = as.Date(c('2020-01-01', '2020-02-01')),
    hospital_admission_date = as.Date(c('2020-01-01', '2020-02-02')), # hospital admission on the same day and the next day
    suspected_covid = c(1, 0),
    probable_covid = c(0, 1),
    died_any_date_pc = as.Date(c('2020-01-15', '2020-01-25')), # died after template and died before template (both within 30 days)
    died_any_date = as.Date(c('2020-01-01', '2020-02-02')), # on the same day and one day after
    covid_related_death_date = as.Date(c('2020-01-01', '2020-02-02'))
  )
  
  df %>% 
    mutate(
      hosp_24h = case_when(
        (flucats_template_date - hospital_admission_date) >= 0 & (flucats_template_date - hospital_admission_date) <= 1 ~ 1,
        TRUE ~ 0
      ),
      hosp_24h_susp_cov = case_when(
        (flucats_template_date - hospital_admission_date) >= 0 & (flucats_template_date - hospital_admission_date) <= 1 & (suspected_covid==1) ~ 1,
        TRUE ~ 0
      ),
      hosp_24h_prob_cov = case_when(
        (flucats_template_date - hospital_admission_date) >= 0 & (flucats_template_date - hospital_admission_date) <= 1 & (probable_covid==1) ~ 1,
        TRUE ~ 0
      ),
      death_30d_pc = case_when(
        (flucats_template_date - died_any_date_pc) <= 30 & (flucats_template_date - died_any_date_pc) >= 0 ~ 1,
        TRUE ~ 0
      ),
      death_30d_ons = case_when(
        (flucats_template_date - died_any_date) <= 30 & (flucats_template_date - died_any_date) >= 0 ~ 1,
        TRUE ~ 0
      ),
      covid_death_30d_ons = case_when(
        (flucats_template_date - covid_related_death_date) <= 30 & (flucats_template_date - covid_related_death_date) >= 0 ~ 1,
        TRUE ~ 0
      )
    )
}


test_that("hospital admission within 24 hours is correctly identified", {
  df <- create_mock_df()
  expect_equal(df$hosp_24h, c(1, 1)) 
})

test_that("suspected COVID cases admitted within 24 hours are correctly identified", {
  df <- create_mock_df()
  expect_equal(df$hosp_24h_susp_cov, c(1, 0))
})

test_that("probable COVID cases admitted within 24 hours are correctly identified", {
  df <- create_mock_df()
  expect_equal(df$hosp_24h_prob_cov, c(0, 1))
})

test_that("deaths within 30 days (pc) of hospital admission are correctly identified", {
  df <- create_mock_df()
  expect_equal(df$death_30d_pc, c(1, 0))
})

test_that("deaths within 30 days (ons) of hospital admission are correctly identified", {
  df <- create_mock_df()
  expect_equal(df$death_30d_ons, c(1, 1)) 
})


sink(type = "message")
close(txt_file)