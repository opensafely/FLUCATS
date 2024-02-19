library(arrow)
library(dplyr)
source("analysis/analysis/utils.R")

dir.create("output/results/models_individual_criteria", showWarnings = FALSE)

df <- arrow::read_feather("output/joined/full/input_all_extra_vars.feather")
flucats_vars <- c("flucats_a", "flucats_b", "flucats_c", "flucats_d", "flucats_e", "flucats_f", "flucats_g", "total_CAT")

df <- df %>%
  mutate(obesity = as.numeric(as.character(obesity)),
         obesity_mod = if_else(is.na(obesity), "missing", as.character(obesity)))


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
model_hosp_c <- glm(hosp_24h ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_child, family = binomial)
saveSummary(model_hosp_c, "output/results/models_individual_criteria/child_hospitalisation.txt")
generate_model_evaluation(model_hosp_c, df_child, "hosp_24h", "hosp_child", "output/results/models_individual_criteria")

model_hosp_c_susp_cov <- glm(hosp_24h_susp_cov ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_child, family = binomial)
saveSummary(model_hosp_c_susp_cov, "output/results/models_individual_criteria/child_hospitalisation_susp_cov.txt")
generate_model_evaluation(model_hosp_c_susp_cov, df_child, "hosp_24h_susp_cov", "hosp_child_susp_cov", "output/results/models_individual_criteria")

model_hosp_c_prob_cov <- glm(hosp_24h_prob_cov ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_child, family = binomial)
saveSummary(model_hosp_c_prob_cov, "output/results/models_individual_criteria/child_hospitalisation_prob_cov.txt")
generate_model_evaluation(model_hosp_c_prob_cov, df_child, "hosp_24h_prob_cov", "hosp_child_prob_cov", "output/results/models_individual_criteria")

model_death_pc_c <- glm(death_30d_pc ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_child, family = binomial)
saveSummary(model_death_pc_c, "output/results/models_individual_criteria/child_death_pc.txt")
generate_model_evaluation(model_death_pc_c, df_child, "death_30d_pc", "death_child_pc", "output/results/models_individual_criteria")

model_death_ons_c <- glm(death_30d_ons ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_child, family = binomial)
saveSummary(model_death_ons_c, "output/results/models_individual_criteria/child_death_ons.txt")
generate_model_evaluation(model_death_ons_c, df_child, "death_30d_ons", "death_child_ons", "output/results/models_individual_criteria")

model_icu_c <- glm(icu_adm ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_child, family = binomial)
saveSummary(model_icu_c, "output/results/models_individual_criteria/child_icu.txt")
generate_model_evaluation(model_icu_c, df_child, "icu_adm", "icu_child", "output/results/models_individual_criteria")

model_covid_death_ons_c <- glm(covid_death_30d_ons ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_child, family = binomial)
saveSummary(model_covid_death_ons_c, "output/results/models_individual_criteria/child_death_ons_covid.txt")
generate_model_evaluation(model_covid_death_ons_c, df_child, "covid_death_30d_ons", "covid_death_child_ons", "output/results/models_individual_criteria")

#ADULT
model_hosp_a <- glm( hosp_24h ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_adult, family = binomial)
saveSummary(model_hosp_a, "output/results/models_individual_criteria/adult_hospitalisation.txt")
generate_model_evaluation(model_hosp_a, df_adult, "hosp_24h", "hosp_adult", "output/results/models_individual_criteria")

model_hosp_a_susp_cov <- glm( hosp_24h_susp_cov ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_adult, family = binomial)
saveSummary(model_hosp_a_susp_cov, "output/results/models_individual_criteria/adult_hospitalisation_susp_cov.txt")
generate_model_evaluation(model_hosp_a_susp_cov, df_adult, "hosp_24h_susp_cov", "hosp_adult_susp_cov", "output/results/models_individual_criteria")

model_hosp_a_prob_cov <- glm( hosp_24h_prob_cov ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_adult, family = binomial)
saveSummary(model_hosp_a_prob_cov, "output/results/models_individual_criteria/adult_hospitalisation_prob_cov.txt")
generate_model_evaluation(model_hosp_a_prob_cov, df_adult, "hosp_24h_prob_cov", "hosp_adult_prob_cov", "output/results/models_individual_criteria")

model_death_pc_a <- glm(death_30d_pc ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_adult, family = binomial)
saveSummary(model_death_pc_a, "output/results/models_individual_criteria/adult_death_pc.txt")
generate_model_evaluation(model_death_pc_a, df_adult, "death_30d_pc", "death_adult_pc", "output/results/models_individual_criteria")

model_death_ons_a <- glm(death_30d_ons ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_adult, family = binomial)
saveSummary(model_death_ons_a, "output/results/models_individual_criteria/adult_death_ons.txt")
generate_model_evaluation(model_death_ons_a, df_adult, "death_30d_ons", "death_adult_ons", "output/results/models_individual_criteria")

model_icu_a <- glm(icu_adm ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_adult, family = binomial)
saveSummary(model_icu_a, "output/results/models_individual_criteria/adult_icu.txt")
generate_model_evaluation(model_icu_a, df_adult, "icu_adm", "icu_adult", "output/results/models_individual_criteria")

model_covid_death_ons_a <- glm(covid_death_30d_ons ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_adult, family = binomial)
saveSummary(model_covid_death_ons_a, "output/results/models_individual_criteria/adult_death_ons_covid.txt")
generate_model_evaluation(model_covid_death_ons_a, df_adult, "covid_death_30d_ons", "covid_death_adult_ons", "output/results/models_individual_criteria")



# severe outcome

model_hosp_so <- fit_model(severe_outcome ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, df_adult, binomial)

if (!is.null(model_hosp_so)) {
  saveSummary(model_hosp_so, "output/results/models_individual_criteria/adult_severe_outcome_summary.txt")
} else {
  write.csv(data.frame(), "output/results/models_individual_criteria/adult_severe_outcome_summary.txt")
}

generate_model_evaluation(model_hosp_so, df_adult, "severe_outcome", "severe_outcome_adult", "output/results/models_individual_criteria")

# #Adjusted models for severe outcomes

model_so_a_adj <- fit_model(severe_outcome ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g +
                           age + sex + obesity_mod + comorb_number, data = df_adult, family = binomial)

if (!is.null(model_so_a_adj)) {
  saveSummary(model_so_a_adj, "output/results/models_individual_criteria/adult_severe_outcome_adj.txt")
} else {
  write.csv(data.frame(), "output/results/models_individual_criteria/adult_severe_outcome_adj.txt")
}

generate_model_evaluation(model_so_a_adj, df_adult, "severe_outcome", "severe_outcome_adult_adj", "output/results/models_individual_criteria")



# Other adjusted models

# Usage
model_hosp_a_adj <- fit_model_if_two_factors(df_adult, "hosp_24h", "flucats_a", "flucats_b", "flucats_c", "flucats_d", "flucats_e", "flucats_f", "flucats_g", "age", "sex", "obesity_mod", "comorb_number")
#adults: any hospitalisation within 24 hours of GP assessment
saveSummary(model_hosp_a_adj, "output/results/models_individual_criteria/adult_hospitalisation_adj.txt")
generate_model_evaluation(model_hosp_a_adj, df_adult, "hosp_24h", "hosp_adult_adj", "output/results/models_individual_criteria")

model_hosp_c_adj <- fit_model_if_two_factors(df_child, "hosp_24h", "flucats_a", "flucats_b", "flucats_c", "flucats_d", "flucats_e", "flucats_f", "flucats_g", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_hosp_c_adj, "output/results/models_individual_criteria/child_hospitalisation_adj.txt")
generate_model_evaluation(model_hosp_c_adj, df_child, "hosp_24h", "hosp_child_adj", "output/results/models_individual_criteria")

model_covidhosp_a_adj <- fit_model_if_two_factors(df_adult, "covid_hosp_susp", "flucats_a", "flucats_b", "flucats_c", "flucats_d", "flucats_e", "flucats_f", "flucats_g", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_covidhosp_a_adj, "output/results/models_individual_criteria/adult_hospitalisation_covid_adj.txt")
generate_model_evaluation(model_covidhosp_a_adj, df_adult, "covid_hosp_susp", "covid_hosp_susp_adult_adj", "output/results/models_individual_criteria")

model_covidhosp_c_adj <- fit_model_if_two_factors(df_child, "covid_hosp_susp", "flucats_a", "flucats_b", "flucats_c", "flucats_d", "flucats_e", "flucats_f", "flucats_g", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_covidhosp_c_adj, "output/results/models_individual_criteria/child_hospitalisation_covid_adj.txt")
generate_model_evaluation(model_covidhosp_c_adj, df_child, "covid_hosp_susp", "covid_hosp_susp_child_adj", "output/results/models_individual_criteria")


model_covidhosp_a_adj <- fit_model_if_two_factors(df_adult, "covid_hosp_prob", "flucats_a", "flucats_b", "flucats_c", "flucats_d", "flucats_e", "flucats_f", "flucats_g", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_covidhosp_a_adj, "output/results/models_individual_criteria/adult_hospitalisation_covid_adj.txt")
generate_model_evaluation(model_covidhosp_a_adj, df_adult, "covid_hosp_prob", "covid_hosp_prob_adult_adj", "output/results/models_individual_criteria")

model_covidhosp_c_adj <- fit_model_if_two_factors(df_child, "covid_hosp_prob", "flucats_a", "flucats_b", "flucats_c", "flucats_d", "flucats_e", "flucats_f", "flucats_g", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_covidhosp_c_adj, "output/results/models_individual_criteria/child_hospitalisation_covid_adj.txt")
generate_model_evaluation(model_covidhosp_c_adj, df_child, "covid_hosp_prob", "covid_hosp_prob_child_adj", "output/results/models_individual_criteria")