#adjusted models
#run after the flucatsValidation.R program has been run first

#We will be running glms modelling the association between individuals FluCATs criteria and outcomes adjusting for a set of covariates

############################
# ADJUSTED MODELS
############################
# We will only run this for hospital admissions due to low numbers for other outcomes
# Do the needed data prep for the confounders
# Add 'missing'category for obesity
library(dplyr)

source("analysis/analysis/utils.R")

df <- read.csv("output/input_all_edited.csv")


df$suspected_covid <- as.integer(rowSums(df[, grepl("flucats_question_suspected_covid", names(df))] == 1) > 0)

# create covid_hosp variable - suspected_covid and hosp_24h
df$covid_hosp <- ifelse(df$suspected_covid == 1 & df$hosp_24h == 1, 1, 0)


df_child <- df[df$category == "Child",]
df_adult <- df[df$category == "Adult",]


df_adult <- df_adult %>% 
  mutate(obesity = as.numeric(as.character(obesity)),
         obesity_mod = if_else(obesity == 0, 9, obesity))

df_child <- df_child %>% 
  mutate(obesity = as.numeric(as.character(obesity)),
         obesity_mod = if_else(obesity == 0, 9, obesity))

comorbidity_vars <- c("asthma", "addisons_hypoadrenalism", "chronic_heart_disease", "chronic_respiratory_disease", "ckd35_or_renal_disease", "liver_disease",
                      "diabetes", "mental_illness", "neurological_disorder", "hypertension", "pneumonia", "immunosuppression_disorder", "immunosuppression_chemo",
                      "splenic_disease")
# comorbidity_vars - these need to be converte to numeric
df_adult <- df_adult %>% 
  mutate(across(all_of(comorbidity_vars), as.numeric))

df_child <- df_child %>% 
  mutate(across(all_of(comorbidity_vars), as.numeric))

df_adult <- df_adult %>% 
  rowwise() %>% 
  mutate(comorb_number = sum(asthma, addisons_hypoadrenalism, chronic_heart_disease, chronic_respiratory_disease, ckd35_or_renal_disease, liver_disease,
                              diabetes, obesity, mental_illness, neurological_disorder, hypertension, pneumonia, immunosuppression_disorder, immunosuppression_chemo,
                              splenic_disease, na.rm = T))

df_child <- df_child %>% 
  rowwise() %>% 
  mutate(comorb_number = sum(asthma, addisons_hypoadrenalism, chronic_heart_disease, chronic_respiratory_disease, ckd35_or_renal_disease, liver_disease,
                              diabetes, obesity, mental_illness, neurological_disorder, hypertension, pneumonia, immunosuppression_disorder, immunosuppression_chemo,
                              splenic_disease, na.rm = T))

fit_model_if_two_factors <- function(df, y_var, ...){
  if(length(unique(df[[y_var]])) >= 2){
    formula <- as.formula(paste(y_var, "~", paste(..., collapse = " + ")))
    model <- glm(formula, data = df, family = binomial)
    return(model)
  } else {
    return(NULL)
  }
}

# Usage
model_hosp_a_adj <- fit_model_if_two_factors(df_adult, "hosp_24h", "flucats_a", "flucats_b", "flucats_c", "flucats_d", "flucats_e", "flucats_f", "flucats_g", "age", "sex", "obesity_mod", "comorb_number")
#adults: any hospitalisation within 24 hours of GP assessment
saveSummary(model_hosp_a_adj, "output/results/adjusted_hospitalisation_a.txt")

model_hosp_a_adj_totalCAT <- fit_model_if_two_factors(df_adult, "hosp_24h", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_hosp_a_adj_totalCAT, "output/results/adjusted_hospitalisation_totalCAT_a.txt")

model_hosp_c_adj <- fit_model_if_two_factors(df_child, "hosp_24h", "flucats_a", "flucats_b", "flucats_c", "flucats_d", "flucats_e", "flucats_f", "flucats_g", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_hosp_c_adj, "output/results/adjusted_hospitalisation_c.txt")

model_hosp_c_adj_totalCAT <- fit_model_if_two_factors(df_child, "hosp_24h", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_hosp_c_adj_totalCAT, "output/results/adjusted_hospitalisation_totalCAT_c.txt")

model_covidhosp_a_adj <- fit_model_if_two_factors(df_adult, "covid_hosp", "flucats_a", "flucats_b", "flucats_c", "flucats_d", "flucats_e", "flucats_f", "flucats_g", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_covidhosp_a_adj, "output/results/adjusted_cov_hospitalisation_a.txt")

model_covidhosp_a_adj_totalCAT <- fit_model_if_two_factors(df_adult, "covid_hosp", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_covidhosp_a_adj_totalCAT, "output/results/adjusted_cov_hospitalisation_totalCAT_a.txt")

model_covidhosp_c_adj <- fit_model_if_two_factors(df_child, "covid_hosp", "flucats_a", "flucats_b", "flucats_c", "flucats_d", "flucats_e", "flucats_f", "flucats_g", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_covidhosp_c_adj, "output/results/adjusted_cov_hospitalisation_c.txt")

model_covidhosp_c_adj_totalCAT <- fit_model_if_two_factors(df_child, "covid_hosp", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_covidhosp_c_adj_totalCAT, "output/results/adjusted_cov_hospitalisation_totalCAT_c.txt")