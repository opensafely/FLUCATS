#Continuing from flucatsValidation.R
library(pROC)
library(predtools)
library(dplyr)
library(arrow)

source("analysis/analysis/utils.R")

dir.create("output/results/models_combined_criteria", showWarnings = FALSE)

df <- arrow::read_feather("output/joined/full/input_all_extra_vars.feather")


# convert levels of obesity_mod from 1, 2, 3 to 0, 1, 9
df$obesity_mod <- as.numeric(df$obesity_mod) - 1
df$obesity_mod[df$obesity_mod == 2] <- 9

df$obesity_mod <- as.factor(df$obesity_mod)


df_child <- df[df$category == "Child",]
df_adult <- df[df$category == "Adult",]

print(table(df_child$obesity_mod))
print(table(df_adult$obesity_mod))

#Separate models for each outcome, by child/adult status

hosp_child <- fit_model(hosp_24h ~ total_CAT, df_child,family = "binomial")
hosp_child_susp_cov <- fit_model(hosp_24h_susp_cov ~ total_CAT, df_child ,family = "binomial")
hosp_child_prob_cov <- fit_model(hosp_24h_prob_cov ~ total_CAT, df_child ,family = "binomial")

saveSummary(hosp_child, "output/results/models_combined_criteria/hosp_child_summary.txt")
saveSummary(hosp_child_susp_cov, "output/results/models_combined_criteria/hosp_child_susp_cov_summary.txt")
saveSummary(hosp_child_prob_cov, "output/results/models_combined_criteria/hosp_child_prob_cov_summary.txt")


generate_model_evaluation(hosp_child, df_child, "hosp_24h", "hosp_child", "output/results/models_combined_criteria")


if (!is.null(hosp_child_susp_cov)) {
  df_child$prediction_hosp_c_susp_cov <- predict.glm(hosp_child_susp_cov, df_child, type = "response")
  mroc_hosp_child_susp_cov <- roc(df_child$hosp_24h_susp_cov, df_child$prediction_hosp_c_susp_cov, plot = T)
  roc_data_hosp_child_susp_cov <- data.frame(
    fpr = round(1 - mroc_hosp_child_susp_cov$specificities, 4),
    sensitivity = round(mroc_hosp_child_susp_cov$sensitivities, 4),
    thresholds = round(mroc_hosp_child_susp_cov$thresholds, 4)
  )
  write.csv(roc_data_hosp_child_susp_cov, "output/results/models_combined_criteria/roc_data_hosp_child_susp_cov.csv")

  auc_hosp_child_susp_cov <- auc(mroc_hosp_child_susp_cov)
  auc_hosp_child_susp_cov_ci <- ci.auc(mroc_hosp_child_susp_cov)
  auc_hosp_child_susp_cov_ci_str <- paste("AUC: ", round(auc_hosp_child_susp_cov[2], 5), " (CI: ", round(auc_hosp_child_susp_cov_ci[1], 5), "-", round(auc_hosp_child_susp_cov_ci[3], 5), ")")
  generate_calibration_plot(data = df_child, obs = "hosp_24h_susp_cov", pred = "prediction_hosp_c_susp_cov", output_path = "output/results/models_combined_criteria/calibration_hosp_child_susp_cov.csv")

} else {
  write.csv(data.frame(), "output/results/models_combined_criteria/roc_data_hosp_child_susp_cov.csv")
  auc_hosp_child_susp_cov <- NA
  auc_hosp_child_susp_cov_ci_str <- NA
  write.csv(data.frame(), "output/results/models_combined_criteria/calibration_hosp_child_susp_cov.csv")
}

if (!is.null(hosp_child_prob_cov)) {
  df_child$prediction_hosp_c_prob_cov <- predict.glm(hosp_child_prob_cov, df_child, type = "response")
  mroc_hosp_child_prob_cov <- roc(df_child$hosp_24h_prob_cov, df_child$prediction_hosp_c_prob_cov, plot = T)
  roc_data_hosp_child_prob_cov <- data.frame(
    fpr = round(1 - mroc_hosp_child_prob_cov$specificities, 4),
    sensitivity = round(mroc_hosp_child_prob_cov$sensitivities, 4),
    thresholds = round(mroc_hosp_child_prob_cov$thresholds, 4)
  )
  write.csv(roc_data_hosp_child_prob_cov, "output/results/models_combined_criteria/roc_data_hosp_child_prob_cov.csv")

  auc_hosp_child_prob_cov <- auc(mroc_hosp_child_prob_cov)
  auc_hosp_child_prob_cov_ci <- ci.auc(mroc_hosp_child_prob_cov)
  auc_hosp_child_prob_cov_ci_str <- paste("AUC: ", round(auc_hosp_child_prob_cov[2], 5), " (CI: ", round(auc_hosp_child_prob_cov_ci[1], 5), "-", round(auc_hosp_child_prob_cov_ci[3], 5), ")")
  generate_calibration_plot(data = df_child, obs = "hosp_24h_prob_cov", pred = "prediction_hosp_c_prob_cov", output_path = "output/results/models_combined_criteria/calibration_hosp_child_prob_cov.csv")

} else {
  write.csv(data.frame(), "output/results/models_combined_criteria/roc_data_hosp_child_prob_cov.csv")
  auc_hosp_child_prob_cov <- NA
  auc_hosp_child_prob_cov_ci_str <- NA
  write.csv(data.frame(), "output/results/models_combined_criteria/calibration_hosp_child_prob_cov.csv")
}



hosp_adult <- fit_model(hosp_24h ~ total_CAT, df_adult ,family = "binomial")
saveSummary(hosp_adult, "output/results/models_combined_criteria/hosp_adult_summary.txt")

hosp_adult_susp_cov <- fit_model(hosp_24h_susp_cov ~ total_CAT, df_adult ,family = "binomial")
saveSummary(hosp_adult_susp_cov, "output/results/models_combined_criteria/hosp_adult_susp_cov_summary.txt")

hosp_adult_prob_cov <- fit_model(hosp_24h_prob_cov ~ total_CAT, data = df_adult ,family = "binomial")
saveSummary(hosp_adult_prob_cov, "output/results/models_combined_criteria/hosp_adult_prob_cov_summary.txt")

if (!is.null(hosp_adult)) {
  df_adult$prediction_hosp_a <- predict.glm(hosp_adult, df_adult, type = "response")
  mroc_hosp_adult <- roc(df_adult$hosp_24h, df_adult$prediction_hosp_a, plot = T)
  roc_data_hosp_adult <- data.frame(
    fpr = round(1 - mroc_hosp_adult$specificities, 4),
    sensitivity = round(mroc_hosp_adult$sensitivities, 4),
    thresholds = round(mroc_hosp_adult$thresholds, 4)
  )
  write.csv(roc_data_hosp_adult, "output/results/models_combined_criteria/roc_data_hosp_adult.csv")

  auc_hosp_adult <- auc(mroc_hosp_adult)
  auc_hosp_adult_ci <- ci.auc(mroc_hosp_adult)
  auc_hosp_adult_ci_str <-  paste("AUC: ", round(auc_hosp_adult_ci[2], 5), " (CI: ", round(auc_hosp_adult_ci[1], 5), "-", round(auc_hosp_adult_ci[3], 5), ")")
  generate_calibration_plot(data = df_adult, obs = "hosp_24h", pred = "prediction_hosp_a", output_path = "output/results/models_combined_criteria/calibration_hosp_adult.csv")

} else {
  write.csv(data.frame(), "output/results/models_combined_criteria/roc_data_hosp_adult.csv")
  auc_hosp_adult <- NA
  auc_hosp_adult_ci_str <- NA
  write.csv(data.frame(), "output/results/models_combined_criteria/calibration_hosp_adult.csv")
}

if (!is.null(hosp_adult_susp_cov)) {
  df_adult$prediction_hosp_a_susp_cov <- predict.glm(hosp_adult_susp_cov, df_adult, type = "response")
  mroc_hosp_adult_susp_cov <- roc(df_adult$hosp_24h_susp_cov, df_adult$prediction_hosp_a_susp_cov, plot = T)
  roc_data_hosp_adult_susp_cov <- data.frame(
    fpr = round(1 - mroc_hosp_adult_susp_cov$specificities, 4),
    sensitivity = round(mroc_hosp_adult_susp_cov$sensitivities, 4),
    thresholds = round(mroc_hosp_adult_susp_cov$thresholds, 4)
  )
  write.csv(roc_data_hosp_adult_susp_cov, "output/results/models_combined_criteria/roc_data_hosp_adult_susp_cov.csv")

  auc_hosp_adult_susp_cov <- auc(mroc_hosp_adult_susp_cov)
  auc_hosp_adult_susp_cov_ci <- ci.auc(mroc_hosp_adult_susp_cov)
  auc_hosp_adult_susp_cov_ci_str <-  paste("AUC: ", round(auc_hosp_adult_susp_cov_ci[2], 5), " (CI: ", round(auc_hosp_adult_susp_cov_ci[1], 5), "-", round(auc_hosp_adult_susp_cov_ci[3], 5), ")")
  generate_calibration_plot(data = df_adult, obs = "hosp_24h_susp_cov", pred = "prediction_hosp_a_susp_cov", output_path = "output/results/models_combined_criteria/calibration_hosp_adult_susp_cov.csv")

} else {
  write.csv(data.frame(), "output/results/models_combined_criteria/roc_data_hosp_adult_susp_cov.csv")
  auc_hosp_adult_susp_cov <- NA
  auc_hosp_adult_susp_cov_ci_str <- NA
  write.csv(data.frame(), "output/results/models_combined_criteria/calibration_hosp_adult_susp_cov.csv")
}

if (!is.null(hosp_adult_prob_cov)) {
  df_adult$prediction_hosp_a_prob_cov <- predict.glm(hosp_adult_prob_cov, df_adult, type = "response")
  mroc_hosp_adult_prob_cov <- roc(df_adult$hosp_24h_prob_cov, df_adult$prediction_hosp_a_prob_cov, plot = T)
  roc_data_hosp_adult_prob_cov <- data.frame(
    fpr = round(1 - mroc_hosp_adult_prob_cov$specificities, 4),
    sensitivity = round(mroc_hosp_adult_prob_cov$sensitivities, 4),
    thresholds = round(mroc_hosp_adult_prob_cov$thresholds, 4)
  )
  write.csv(roc_data_hosp_adult_prob_cov, "output/results/models_combined_criteria/roc_data_hosp_adult_prob_cov.csv")

  auc_hosp_adult_prob_cov <- auc(mroc_hosp_adult_prob_cov)
  auc_hosp_adult_prob_cov_ci <- ci.auc(mroc_hosp_adult_prob_cov)
  auc_hosp_adult_prob_cov_ci_str <-  paste("AUC: ", round(auc_hosp_adult_prob_cov_ci[2], 5), " (CI: ", round(auc_hosp_adult_prob_cov_ci[1], 5), "-", round(auc_hosp_adult_prob_cov_ci[3], 5), ")")
  generate_calibration_plot(data = df_adult, obs = "hosp_24h_prob_cov", pred = "prediction_hosp_a_prob_cov", output_path = "output/results/models_combined_criteria/calibration_hosp_adult_prob_cov.csv")
} else {
  write.csv(data.frame(), "output/results/models_combined_criteria/roc_data_hosp_adult_prob_cov.csv")
  auc_hosp_adult_prob_cov <- NA
  auc_hosp_adult_prob_cov_ci_str <- NA
  write.csv(data.frame(), "output/results/models_combined_criteria/calibration_hosp_adult_prob_cov.csv")
}


# aucs <- data.frame(auc_hosp_child_ci_str, auc_hosp_adult_ci_str)
aucs_susp_cov <- data.frame(auc_hosp_child_susp_cov_ci_str, auc_hosp_adult_susp_cov_ci_str)
aucs_prob_cov <- data.frame(auc_hosp_child_prob_cov_ci_str, auc_hosp_adult_prob_cov_ci_str)


# colnames(aucs) <- c("ci_hosp_child", "ci_hosp_adult")
colnames(aucs_susp_cov) <- c("ci_hosp_child_susp_cov", "ci_hosp_adult_susp_cov")
colnames(aucs_prob_cov) <- c("ci_hosp_child_prob_cov", "ci_hosp_adult_prob_cov")

# write.csv(aucs, "output/results/models_combined_criteria/aucs.csv")
write.csv(aucs_susp_cov, "output/results/models_combined_criteria/aucs_susp_cov.csv")
write.csv(aucs_prob_cov, "output/results/models_combined_criteria/aucs_prob_cov.csv")

# severe outcome

model_so_a_adj_totalCAT <- fit_model(severe_outcome ~ total_CAT +
                                    age + sex + obesity_mod + comorb_number, data = df_adult, family = binomial)

if (!is.null(model_so_a_adj_totalCAT)) {
  saveSummary(model_so_a_adj_totalCAT, "output/results/models_combined_criteria/severe_outcome_adult_ajd_summary.txt")
} else {
  write.csv(data.frame(), "output/results/models_combined_criteria/severe_outcome_adult_ajd_summary.txt")
}

generate_model_evaluation(model_so_a_adj_totalCAT, df_adult, "severe_outcome", "severe_outcome_adj", "output/results/models_combined_criteria/severe_outcome")


# ###Discrimination
model_so_a_totalCAT <- fit_model(severe_outcome ~ total_CAT, data = df_adult ,family = "binomial")

if (!is.null(model_so_a_totalCAT)) {
  saveSummary(model_so_a_totalCAT, "output/results/models_combined_criteria/severe_outcome_summary.txt")
} else {
  write.csv(data.frame(), "output/results/models_combined_criteria/severe_outcome_summary.txt")
}

generate_model_evaluation(model_so_a_totalCAT, df_adult, "severe_outcome", "severe_outcome", "output/results/models_combined_criteria/severe_outcome")




# adjusted models

model_hosp_a_adj_totalCAT <- fit_model_if_two_factors(df_adult, "hosp_24h", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_hosp_a_adj_totalCAT, "output/results/models_combined_criteria/hosp_adult_adj_summary.txt")

model_hosp_c_adj_totalCAT <- fit_model_if_two_factors(df_child, "hosp_24h", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_hosp_c_adj_totalCAT, "output/results/models_combined_criteria/hosp_child_adj_summary.txt")



model_covidhosp_a_adj_totalCAT <- fit_model_if_two_factors(df_adult, "covid_hosp_susp", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_covidhosp_a_adj_totalCAT, "output/results/models_combined_criteria/hosp_adult_susp_cov_adj_summary.txt")

model_covidhosp_c_adj_totalCAT <- fit_model_if_two_factors(df_child, "covid_hosp_susp", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_covidhosp_c_adj_totalCAT, "output/results/models_combined_criteria/hosp_child_susp_cov_adj_summary.txt")


model_covidhosp_prob_a_adj_totalCAT <- fit_model_if_two_factors(df_adult, "covid_hosp_prob", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_covidhosp_a_adj_totalCAT, "output/results/models_combined_criteria/hosp_adult_prob_cov_adj_summary.txt")

model_covidhosp_prob_c_adj_totalCAT <- fit_model_if_two_factors(df_child, "covid_hosp_prob", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_covidhosp_c_adj_totalCAT, "output/results/models_combined_criteria/hosp_child_prob_covid_adj_summary.txt")