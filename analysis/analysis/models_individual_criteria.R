library(arrow)
library(dplyr)
source("analysis/analysis/utils.R")

dir.create("output/results/models_individual_criteria", showWarnings = FALSE)

df <- arrow::read_feather("output/joined/full/input_all_extra_vars.feather")
flucats_vars <- c("flucats_a", "flucats_b", "flucats_c", "flucats_d", "flucats_e", "flucats_f", "flucats_g", "total_CAT")

print(table(df$obesity))
df <- df %>%
  mutate(obesity = as.numeric(as.character(obesity)),
         obesity_mod = if_else(is.na(obesity), "missing", as.character(obesity)))

print(table(df$obesity_mod))

df$obesity_mod <- ifelse(df$obesity_mod == "1", "yes", df$obesity_mod)
df$obesity_mod <- ifelse(df$obesity_mod == "0", "no", df$obesity_mod)

# convert to factor
df$obesity_mod <- as.factor(df$obesity_mod)


df <- df %>% 
  mutate(across(all_of(flucats_vars), as.numeric))


df_adult <- df[df$category == "Adult",]
df_child <- df[df$category == "Child",]


#Logistic regression for each outcome where FluCATs criteria are modelled independently
#CHILD

fit_model_and_evaluate(hosp_24h ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, df_child, "binomial", "hosp_24h", "hosp_child", "output/results/models_individual_criteria")

fit_model_and_evaluate(hosp_24h_susp_cov ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, df_child, "binomial", "hosp_24h_susp_cov", "hosp_child_susp_cov", "output/results/models_individual_criteria")

fit_model_and_evaluate(hosp_24h_prob_cov ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, df_child, "binomial", "hosp_24h_prob_cov", "hosp_child_prob_cov", "output/results/models_individual_criteria")

fit_model_and_evaluate(death_30d_pc ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, df_child, "binomial", "death_30d_pc", "death_child_pc", "output/results/models_individual_criteria")

fit_model_and_evaluate(death_30d_ons ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, df_child, "binomial", "death_30d_ons", "death_child_ons", "output/results/models_individual_criteria")

fit_model_and_evaluate(icu_adm ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, df_child, "binomial", "icu_adm", "icu_child", "output/results/models_individual_criteria")

fit_model_and_evaluate(covid_death_30d_ons ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, df_child, "binomial", "covid_death_30d_ons", "covid_death_child_ons", "output/results/models_individual_criteria")

#ADULT
fit_model_and_evaluate(hosp_24h ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, df_adult, "binomial", "hosp_24h", "hosp_adult", "output/results/models_individual_criteria")

fit_model_and_evaluate(hosp_24h_susp_cov ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, df_adult, "binomial", "hosp_24h_susp_cov", "hosp_adult_susp_cov", "output/results/models_individual_criteria")

fit_model_and_evaluate(hosp_24h_prob_cov ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, df_adult, "binomial", "hosp_24h_prob_cov", "hosp_adult_prob_cov", "output/results/models_individual_criteria")

fit_model_and_evaluate(death_30d_pc ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, df_adult, "binomial", "death_30d_pc", "death_adult_pc", "output/results/models_individual_criteria")

fit_model_and_evaluate(death_30d_ons ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, df_adult, "binomial", "death_30d_ons", "death_adult_ons", "output/results/models_individual_criteria")

fit_model_and_evaluate(icu_adm ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, df_adult, "binomial", "icu_adm", "icu_adult", "output/results/models_individual_criteria")

fit_model_and_evaluate(covid_death_30d_ons ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, df_adult, "binomial", "covid_death_30d_ons", "covid_death_adult_ons", "output/results/models_individual_criteria")

# severe outcome

fit_model_and_evaluate(severe_outcome ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, df_adult, "binomial", "severe_outcome", "severe_outcome_adult", "output/results/models_individual_criteria")

# #Adjusted models for severe outcomes

fit_model_and_evaluate(severe_outcome ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g + age + sex + obesity_mod + comorb_number, df_adult, "binomial", "severe_outcome", "severe_outcome_adult_adj", "output/results/models_individual_criteria")

# Other adjusted models

# Usage
fit_model_and_evaluate(hosp_24h ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g + age + sex + obesity_mod + comorb_number, df_adult, "binomial", "hosp_24h", "hosp_adult_adj", "output/results/models_individual_criteria")

fit_model_and_evaluate(hosp_24h ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g + age + sex + obesity_mod + comorb_number, df_child, "binomial", "hosp_24h", "hosp_child_adj", "output/results/models_individual_criteria")

fit_model_and_evaluate(covid_hosp_susp ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g + age + sex + obesity_mod + comorb_number, df_adult, "binomial", "covid_hosp_susp", "covid_hosp_susp_adult_adj", "output/results/models_individual_criteria")

fit_model_and_evaluate(covid_hosp_susp ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g + age + sex + obesity_mod + comorb_number, df_child, "binomial", "covid_hosp_susp", "covid_hosp_susp_child_adj", "output/results/models_individual_criteria")

fit_model_and_evaluate(covid_hosp_prob ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g + age + sex + obesity_mod + comorb_number, df_adult, "binomial", "covid_hosp_prob", "covid_hosp_prob_adult_adj", "output/results/models_individual_criteria")

fit_model_and_evaluate(covid_hosp_prob ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g + age + sex + obesity_mod + comorb_number, df_child, "binomial", "covid_hosp_prob", "covid_hosp_prob_child_adj", "output/results/models_individual_criteria")