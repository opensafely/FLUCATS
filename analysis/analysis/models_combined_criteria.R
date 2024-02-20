#Continuing from flucatsValidation.R
library(pROC)
library(predtools)
library(dplyr)
library(arrow)

source("analysis/analysis/utils.R")

dir.create("output/results/models_combined_criteria", showWarnings = FALSE)

df <- arrow::read_feather("output/joined/full/input_all_extra_vars.feather")


df <- df %>%
  mutate(obesity = as.numeric(as.character(obesity)),
         obesity_mod = if_else(is.na(obesity), "missing", as.character(obesity)))


df$obesity_mod <- ifelse(df$obesity_mod == "1", "yes", df$obesity_mod)
df$obesity_mod <- ifelse(df$obesity_mod == "0", "no", df$obesity_mod)

# convert to factor



df_child <- df[df$category == "Child",]
df_adult <- df[df$category == "Adult",]

df_child$obesity_mod <- factor(df_child$obesity_mod, levels = c("yes", "no", "missing"))
df_adult$obesity_mod <- factor(df_adult$obesity_mod, levels = c("yes", "no", "missing"))

print(table(df_child$obesity_mod))
print(table(df_adult$obesity_mod))


#Separate models for each outcome, by child/adult status

fit_model_and_evaluate(hosp_24h ~ total_CAT, df_child, "binomial", "hosp_24h", "hosp_child", "output/results/models_combined_criteria")
fit_model_and_evaluate(hosp_24h_susp_cov ~ total_CAT, df_child, "binomial", "hosp_24h_susp_cov", "hosp_child_susp_cov", "output/results/models_combined_criteria")
fit_model_and_evaluate(hosp_24h_prob_cov ~ total_CAT, df_child, "binomial", "hosp_24h_prob_cov", "hosp_child_prob_cov", "output/results/models_combined_criteria")

# hosp_child <- fit_model(hosp_24h ~ total_CAT, df_child,family = "binomial")
# hosp_child_susp_cov <- fit_model(hosp_24h_susp_cov ~ total_CAT, df_child ,family = "binomial")
# hosp_child_prob_cov <- fit_model(hosp_24h_prob_cov ~ total_CAT, df_child ,family = "binomial")

# saveSummary(hosp_child, "output/results/models_combined_criteria/hosp_child_summary.txt")
# saveSummary(hosp_child_susp_cov, "output/results/models_combined_criteria/hosp_child_susp_cov_summary.txt")
# saveSummary(hosp_child_prob_cov, "output/results/models_combined_criteria/hosp_child_prob_cov_summary.txt")


# generate_model_evaluation(hosp_child, df_child, "hosp_24h", "hosp_child", "output/results/models_combined_criteria")

# generate_model_evaluation(hosp_child_susp_cov, df_child, "hosp_24h_susp_cov", "hosp_child_susp_cov", "output/results/models_combined_criteria")

# generate_model_evaluation(hosp_child_prob_cov, df_child, "hosp_24h_prob_cov", "hosp_child_prob_cov", "output/results/models_combined_criteria")



# hosp_adult <- fit_model(hosp_24h ~ total_CAT, df_adult ,family = "binomial")
# saveSummary(hosp_adult, "output/results/models_combined_criteria/hosp_adult_summary.txt")

# hosp_adult_susp_cov <- fit_model(hosp_24h_susp_cov ~ total_CAT, df_adult ,family = "binomial")
# saveSummary(hosp_adult_susp_cov, "output/results/models_combined_criteria/hosp_adult_susp_cov_summary.txt")

# hosp_adult_prob_cov <- fit_model(hosp_24h_prob_cov ~ total_CAT, data = df_adult ,family = "binomial")
# saveSummary(hosp_adult_prob_cov, "output/results/models_combined_criteria/hosp_adult_prob_cov_summary.txt")

# generate_model_evaluation(hosp_adult, df_adult, "hosp_24h", "hosp_adult", "output/results/models_combined_criteria")

# generate_model_evaluation(hosp_adult_susp_cov, df_adult, "hosp_24h_susp_cov", "hosp_adult_susp_cov", "output/results/models_combined_criteria")


# generate_model_evaluation(hosp_adult_prob_cov, df_adult, "hosp_24h_prob_cov", "hosp_adult_prob_cov", "output/results/models_combined_criteria")


# severe outcome

fit_model_and_evaluate(severe_outcome ~ total_CAT +
                                    age + sex + obesity_mod + comorb_number, df_adult, "binomial", "severe_outcome", "severe_outcome_adj", "output/results/models_combined_criteria")

# model_so_a_adj_totalCAT <- fit_model(severe_outcome ~ total_CAT +
#                                     age + sex + obesity_mod + comorb_number, data = df_adult, family = binomial)
                                  

# if (!is.null(model_so_a_adj_totalCAT)) {
#   saveSummary(model_so_a_adj_totalCAT, "output/results/models_combined_criteria/severe_outcome_adult_ajd_summary.txt")
# } else {
#   write.csv(data.frame(), "output/results/models_combined_criteria/severe_outcome_adult_ajd_summary.txt")
# }

# generate_model_evaluation(model_so_a_adj_totalCAT, df_adult, "severe_outcome", "severe_outcome_adj", "output/results/models_combined_criteria/severe_outcome")


# # ###Discrimination
# model_so_a_totalCAT <- fit_model(severe_outcome ~ total_CAT, data = df_adult ,family = "binomial")

# generate_model_evaluation(model_so_a_totalCAT, df_adult, "severe_outcome", "severe_outcome", "output/results/models_combined_criteria/severe_outcome")




# adjusted models

fit_model_and_evaluate(hosp_24h ~ total_CAT + age + sex + obesity_mod + comorb_number, df_adult, "binomial", "hosp_adult", "hosp_adult_adj", "output/results/models_combined_criteria")
# model_hosp_a_adj_totalCAT <- fit_model_if_two_factors(df_adult, "hosp_24h", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
# saveSummary(model_hosp_a_adj_totalCAT, "output/results/models_combined_criteria/hosp_adult_adj_summary.txt")
# generate_model_evaluation(model_hosp_a_adj_totalCAT, df_adult, "hosp_24h", "hosp_adult_adj", "output/results/models_combined_criteria")

# model_hosp_c_adj_totalCAT <- fit_model_if_two_factors(df_child, "hosp_24h", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
# saveSummary(model_hosp_c_adj_totalCAT, "output/results/models_combined_criteria/hosp_child_adj_summary.txt")
# generate_model_evaluation(model_hosp_c_adj_totalCAT, df_child, "hosp_24h", "hosp_child_adj", "output/results/models_combined_criteria")


# model_covidhosp_a_adj_totalCAT <- fit_model_if_two_factors(df_adult, "covid_hosp_susp", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
# saveSummary(model_covidhosp_a_adj_totalCAT, "output/results/models_combined_criteria/hosp_adult_susp_cov_adj_summary.txt")
# generate_model_evaluation(model_covidhosp_a_adj_totalCAT, df_adult, "covid_hosp_susp", "hosp_adult_susp_cov_adj", "output/results/models_combined_criteria")


# model_covidhosp_c_adj_totalCAT <- fit_model_if_two_factors(df_child, "covid_hosp_susp", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
# saveSummary(model_covidhosp_c_adj_totalCAT, "output/results/models_combined_criteria/hosp_child_susp_cov_adj_summary.txt")
# generate_model_evaluation(model_covidhosp_c_adj_totalCAT, df_child, "covid_hosp_susp", "hosp_child_susp_cov_adj", "output/results/models_combined_criteria")


# model_covidhosp_prob_a_adj_totalCAT <- fit_model_if_two_factors(df_adult, "covid_hosp_prob", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
# saveSummary(model_covidhosp_a_adj_totalCAT, "output/results/models_combined_criteria/hosp_adult_prob_cov_adj_summary.txt")
# generate_model_evaluation(model_covidhosp_a_adj_totalCAT, df_adult, "covid_hosp_prob", "hosp_adult_prob_cov_adj", "output/results/models_combined_criteria")

# model_covidhosp_prob_c_adj_totalCAT <- fit_model_if_two_factors(df_child, "covid_hosp_prob", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
# saveSummary(model_covidhosp_c_adj_totalCAT, "output/results/models_combined_criteria/hosp_child_prob_cov_adj_summary.txt")
# generate_model_evaluation(model_covidhosp_c_adj_totalCAT, df_child, "covid_hosp_prob", "hosp_child_prob_cov_adj", "output/results/models_combined_criteria")