#Continuing from flucatsValidation.R
library(pROC)
library(predtools)
library(dplyr)
library(arrow)

source("analysis/analysis/utils.R")

dir.create("output/results/models_combined_criteria", showWarnings = FALSE)

df <- arrow::read_feather("output/joined/full/input_all_extra_vars.feather")

print(table(df$obesity))
df <- df %>%
  mutate(obesity = as.numeric(as.character(obesity)),
         obesity_mod = if_else(is.na(obesity), "missing", as.character(obesity)))

print(table(df$obesity_mod))
df$obesity_mod <- ifelse(df$obesity_mod == "1", "no", df$obesity_mod)
df$obesity_mod <- ifelse(df$obesity_mod == "2", "yes", df$obesity_mod)

df$obesity_mod <- factor(df$obesity_mod, levels = c("yes", "no", "missing"))

df_child <- df[df$category == "Child",]
df_adult <- df[df$category == "Adult",]


#Separate models for each outcome, by child/adult status

fit_model_and_evaluate(hosp_24h ~ total_CAT, df_child, "binomial", "hosp_24h", "hosp_child", "output/results/models_combined_criteria")
fit_model_and_evaluate(hosp_24h_susp_cov ~ total_CAT, df_child, "binomial", "hosp_24h_susp_cov", "hosp_child_susp_cov", "output/results/models_combined_criteria")
fit_model_and_evaluate(hosp_24h_prob_cov ~ total_CAT, df_child, "binomial", "hosp_24h_prob_cov", "hosp_child_prob_cov", "output/results/models_combined_criteria")

fit_model_and_evaluate(hosp_24h ~ total_CAT, df_adult, "binomial", "hosp_24h", "hosp_adult", "output/results/models_combined_criteria")
fit_model_and_evaluate(hosp_24h_susp_cov ~ total_CAT, df_adult, "binomial", "hosp_24h_susp_cov", "hosp_adult_susp_cov", "output/results/models_combined_criteria")
fit_model_and_evaluate(hosp_24h_prob_cov ~ total_CAT, df_adult, "binomial", "hosp_24h_prob_cov", "hosp_adult_prob_cov", "output/results/models_combined_criteria")

# severe outcome

fit_model_and_evaluate(severe_outcome ~ total_CAT +
                                    age + sex + obesity_mod + comorb_number, df_adult, "binomial", "severe_outcome", "severe_outcome_adj", "output/results/models_combined_criteria")

fit_model_and_evaluate(severe_outcome ~ total_CAT, df_adult, "binomial", "severe_outcome", "severe_outcome", "output/results/models_combined_criteria")

# adjusted models

fit_model_and_evaluate(hosp_24h ~ total_CAT + age + sex + obesity_mod + comorb_number, df_adult, "binomial", "hosp_24h", "hosp_adult_adj", "output/results/models_combined_criteria")

fit_model_and_evaluate(hosp_24h ~ total_CAT + age + sex + obesity_mod + comorb_number, df_child, "binomial", "hosp_24h", "hosp_child_adj", "output/results/models_combined_criteria")

fit_model_and_evaluate(covid_hosp_susp ~ total_CAT + age + sex + obesity_mod + comorb_number, df_adult, "binomial", "covid_hosp_susp", "covid_hosp_susp_adult_adj", "output/results/models_combined_criteria")

fit_model_and_evaluate(covid_hosp_susp ~ total_CAT + age + sex + obesity_mod + comorb_number, df_child, "binomial", "covid_hosp_susp", "covid_hosp_susp_child_adj", "output/results/models_combined_criteria")

fit_model_and_evaluate(covid_hosp_prob ~ total_CAT + age + sex + obesity_mod + comorb_number, df_adult, "binomial", "covid_hosp_prob", "covid_hosp_prob_adult_adj", "output/results/models_combined_criteria")

fit_model_and_evaluate(covid_hosp_prob ~ total_CAT + age + sex + obesity_mod + comorb_number, df_child, "binomial", "covid_hosp_prob", "covid_hosp_prob_child_adj", "output/results/models_combined_criteria")