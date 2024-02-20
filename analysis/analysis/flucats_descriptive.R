library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)
library(purrr)
library(arrow)

source("analysis/analysis/utils.R")

dir.create("output/results", showWarnings = FALSE)
dir.create("output/results/descriptive", showWarnings = FALSE)

# read df from feather file
df <- arrow::read_feather("output/joined/full/input_all_extra_vars.feather")



# Calculate attrition - number of unique patients and number of encounters over the time period

step <- c("Total number of unique patients: ", "Total number of encounters over the time period: ")

attrition <- data.frame(step) %>% 
  mutate(numbers = case_when(step == "Total number of unique patients: " ~ length(unique(df$patient_id)),
                             step == "Total number of encounters over the time period: " ~ nrow(df)))


attrition <- attrition %>% 
  filter(numbers > 7)
attrition$numbers <- round(attrition$numbers, -1)
write.csv(attrition, "output/results/descriptive/attrition.csv")

# Get summary data for age band
age_band_counts <- df %>%
  count(age_band)

filtered_age_band_counts <- age_band_counts %>%
  filter(n > 7)
filtered_age_band_counts$n_rounded <- round(filtered_age_band_counts$n / 10) * 10
filtered_age_band_counts <- filtered_age_band_counts %>%
  select(-n)
write.csv(filtered_age_band_counts, "output/results/descriptive/age_hist.csv")


# Get counts of template use over time
df <- df %>% 
  mutate(template_week = format(ymd(flucats_template_date), "%Y-%W"))

week_counts <- df %>%
  count(template_week)

filtered_week_counts <- week_counts %>%
  filter(n > 7)
filtered_week_counts$n_rounded <- round(filtered_week_counts$n / 10) * 10
filtered_week_counts <- filtered_week_counts %>%
  select(-n)

write.csv(filtered_week_counts, "output/results/descriptive/weekly_template.csv", row.names = FALSE)


# function to get a table of the given variable
summarise_variable <- function(df, column, output_path, drop_duplicates = FALSE) {
  
  if (drop_duplicates) {
    var <- df[!duplicated(df$patient_id),]
    var <- var[[column]]
  } else {
    var <- df[[column]]
  }
  var_table <- as.data.frame(table(var))
  var_table <- var_table %>% 
    filter(Freq > 7) %>% 
    mutate(Freq = round(Freq, -1))
  
  write.csv(var_table, output_path)
}


summarise_variable(df, "sex", "output/results/descriptive/sex_table.csv", drop_duplicates = TRUE)
summarise_variable(df, "region", "output/results/descriptive/region_table.csv", drop_duplicates = TRUE)
summarise_variable(df, "flucats_a", "output/results/descriptive/flucat_a.csv")
summarise_variable(df, "flucats_b", "output/results/descriptive/flucat_b.csv")
summarise_variable(df, "flucats_c", "output/results/descriptive/flucat_c.csv")
summarise_variable(df, "flucats_d", "output/results/descriptive/flucat_d.csv")
summarise_variable(df, "flucats_e", "output/results/descriptive/flucat_e.csv")
summarise_variable(df, "flucats_f", "output/results/descriptive/flucat_f.csv")
summarise_variable(df, "flucats_g", "output/results/descriptive/flucat_g.csv")

# Calculate the count based on condition
calculate_summary <- function(data, condition_col, condition_val, total) {
  count <- sum(data[[condition_col]] == condition_val, na.rm = TRUE)
  rounded_count <- round(count / 5) * 5
  percentage <- round((rounded_count / total) * 100, 2)
  list(count = rounded_count, percentage = percentage)
}

# Total count of patients
total <- nrow(df)

female_summary <- calculate_summary(df, "sex", "F", total)
male_summary <- calculate_summary(df, "sex", "M", total)
child_summary <- calculate_summary(df, "category", "Child", total)
adult_summary <- calculate_summary(df, "category", "Adult", total)
hospital_summary <- calculate_summary(df, "hospital_admission", 1, total)

# Creating a dataframe for the summaries
summary_df <- data.frame(
  Group = c("Female", "Male", "Child", "Adult", "Hospital Admission"),
  Count = c(female_summary$count, male_summary$count, child_summary$count, adult_summary$count, hospital_summary$count),
  Percentage = c(female_summary$percentage, male_summary$percentage, child_summary$percentage, adult_summary$percentage, hospital_summary$percentage)
)

write.csv(summary_df, "output/results/descriptive/demographics.csv", row.names = FALSE)


# save table of outcomes - this is the sum of each of the following columns in adults, children and total
# hosp_24h, hosp_24h_susp_cov, hosp_24h_prob_cov, death_30d_pc, death_30d_ons, icu_adm, severe_outcome


outcomes <- df %>%
  ungroup() %>%
  summarise(
    hosp_24h = sum(hosp_24h),
    hosp_24h_susp_cov = sum(hosp_24h_susp_cov),
    hosp_24h_prob_cov = sum(hosp_24h_prob_cov),
    death_30d_pc = sum(death_30d_pc),
    death_30d_ons = sum(death_30d_ons),
    icu_adm = sum(icu_adm),
    severe_outcome = sum(severe_outcome)
  )

# the above, but filtered to children and adults
outcomes_child <- df %>%
  ungroup() %>%
  filter(category == "Child") %>%
  summarise(
    hosp_24h = sum(hosp_24h),
    hosp_24h_susp_cov = sum(hosp_24h_susp_cov),
    hosp_24h_prob_cov = sum(hosp_24h_prob_cov),
    death_30d_pc = sum(death_30d_pc),
    death_30d_ons = sum(death_30d_ons),
    icu_adm = sum(icu_adm),
    severe_outcome = sum(severe_outcome)
  )

outcomes_adult <- df %>%
  ungroup() %>%
  filter(category == "Adult") %>%
  summarise(
    hosp_24h = sum(hosp_24h),
    hosp_24h_susp_cov = sum(hosp_24h_susp_cov),
    hosp_24h_prob_cov = sum(hosp_24h_prob_cov),
    death_30d_pc = sum(death_30d_pc),
    death_30d_ons = sum(death_30d_ons),
    icu_adm = sum(icu_adm),
    severe_outcome = sum(severe_outcome)
  )


outcomes <- rbind(outcomes, outcomes_child, outcomes_adult)
outcomes_combined <- outcomes %>%
  mutate_all(~ifelse(. <= 7, 0, .)) %>%
  mutate_all(~round(./5) * 5)

# set row names
rownames(outcomes_combined) <- c("Total", "Child", "Adult")


write.csv(outcomes_combined, "output/results/descriptive/outcomes.csv", row.names = TRUE)

df_child <- df %>% 
  filter(age<16)

df_adult <- df %>% 
  filter(age>=16)

variables <- c("age","age_band","sex","region","bmi","bmi_primis","asthma","addisons_hypoadrenalism",
               "chronic_heart_disease","chronic_respiratory_disease","ckd_primis_stage",
               "renal_disease","ckd35_or_renal_disease","ckd_os","liver_disease","pregnant",
               "diabetes","gestational_diabetes","obesity","mental_illness",
               "neurological_disorder","hypertension","pneumonia","immunosuppression_disorder",
               "immunosuppression_chemo","splenic_disease","shield","nonshield",
               "statins","covadm1","covadm2","pfd1rx","pfd2rx",
               "azd1rx","azd2rx","covrx1", "covrx2",
               "ethnicity_opensafely","ethnicity","homeless",
               "residential_care","imdQ5")

#Various tables
print("filtering")
# print table of all split_by
for (split_by in c("hosp_24h", "hosp_24h_susp_cov", "hosp_24h_prob_cov", "death_30d_pc", "death_30d_ons", "icu_adm", "severe_outcome")) {
  print(split_by)
  print(table(df[[split_by]]))
}

# Table 1: demographics by hospitalisation
summarise_and_export_data(df, variables, "output/results/descriptive/demographic_summary_hospitalisation.csv", split_by="hosp_24h")

summarise_and_export_data(df, variables, "output/results/descriptive/demographic_summary_hospitalisation_susp_cov.csv", split_by="hosp_24h_susp_cov")

summarise_and_export_data(df, variables, "output/results/descriptive/demographic_summary_hospitalisation_prob_cov.csv", split_by="hosp_24h_prob_cov")

#Table 2: demographics by death within 30 days of GP consultation (primary care record)
summarise_and_export_data(df, variables, "output/results/descriptive/demographic_summary_death_pc.csv", split_by="death_30d_pc")

#Table 3: demographics by death within 30 days of GP consultation (ONS record)
summarise_and_export_data(df, variables, "output/results/descriptive/demographic_summary_death_ons.csv", split_by="death_30d_ons")

#Table 4: demographics by ICU admission
summarise_and_export_data(df, variables, "output/results/descriptive/demographic_summary_icu.csv", split_by="icu_adm")

# Table 5: demographics by severe outcome
summarise_and_export_data(df, variables, "output/results/descriptive/demographic_summary_severe_outcome.csv", split_by="severe_outcome")

# Table 6: demographics by severe outcome in adults
summarise_and_export_data(df_adult, variables, "output/results/descriptive/demographic_summary_severe_outcome_adult.csv", split_by="severe_outcome")



flucats_vars <- c("total_CAT", "flucats_a", "flucats_b", "flucats_c", "flucats_d", "flucats_e", "flucats_f", "flucats_g")

#Table 5-8: flucats criteria by outcome 
#CHILD
summarise_and_export_data(df_child, flucats_vars, "output/results/descriptive/flucat_criteria_counts_child_hospitalisation.csv", split_by="hosp_24h")
summarise_and_export_data(df_child, flucats_vars, "output/results/descriptive/flucat_criteria_counts_child_hospitalisation_susp_cov.csv", split_by="hosp_24h_susp_cov")
summarise_and_export_data(df_child, flucats_vars, "output/results/descriptive/flucat_criteria_counts_child_hospitalisation_prob_cov.csv", split_by="hosp_24h_prob_cov")
summarise_and_export_data(df_child, flucats_vars, "output/results/descriptive/flucat_criteria_counts_child_death_pc.csv", split_by="death_30d_pc")
summarise_and_export_data(df_child, flucats_vars, "output/results/descriptive/flucat_criteria_counts_child_death_ons.csv", split_by="death_30d_ons")
summarise_and_export_data(df_child, flucats_vars, "output/results/descriptive/flucat_criteria_counts_child_icu.csv", split_by="icu_adm")
summarise_and_export_data(df_child, flucats_vars, "output/results/descriptive/flucat_criteria_counts_child_severe_outcome.csv", split_by="severe_outcome")

#Table 5-8: flucats criteria by outcome 
#ADULT

summarise_and_export_data(df_adult, flucats_vars, "output/results/descriptive/flucat_criteria_counts_adult_hospitalisation.csv", split_by="hosp_24h")
summarise_and_export_data(df_adult, flucats_vars, "output/results/descriptive/flucat_criteria_counts_adult_hospitalisation_susp_cov.csv", split_by="hosp_24h_susp_cov")
summarise_and_export_data(df_adult, flucats_vars, "output/results/descriptive/flucat_criteria_counts_adult_hospitalisation_prob_cov.csv", split_by="hosp_24h_prob_cov")
summarise_and_export_data(df_adult, flucats_vars, "output/results/descriptive/flucat_criteria_counts_adult_death_pc.csv", split_by="death_30d_pc")
summarise_and_export_data(df_adult, flucats_vars, "output/results/descriptive/flucat_criteria_counts_adult_death_ons.csv", split_by="death_30d_ons")
summarise_and_export_data(df_adult, flucats_vars, "output/results/descriptive/flucat_criteria_counts_adult_icu.csv", split_by="icu_adm")
summarise_and_export_data(df_adult, flucats_vars, "output/results/descriptive/flucat_criteria_counts_adult_severe_outcome.csv", split_by="severe_outcome")
