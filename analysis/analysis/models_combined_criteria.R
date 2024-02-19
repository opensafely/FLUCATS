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
         obesity_mod = if_else(obesity == 0, 9, obesity))

df_child <- df[df$category == "Child",]
df_adult <- df[df$category == "Adult",]


#Separate models for each outcome, by child/adult status
hosp_child <- fit_model(hosp_24h ~ total_CAT, df_child ,family = "binomial")
hosp_child_susp_cov <- fit_model(hosp_24h_susp_cov ~ total_CAT, df_child ,family = "binomial")
hosp_child_prob_cov <- fit_model(hosp_24h_prob_cov ~ total_CAT, df_child ,family = "binomial")

saveSummary(hosp_child, "output/results/models_combined_criteria/hosp_child_summary.txt")
saveSummary(hosp_child_susp_cov, "output/results/models_combined_criteria/hosp_child_susp_cov_summary.txt")
saveSummary(hosp_child_prob_cov, "output/results/models_combined_criteria/hosp_child_prob_cov_summary.txt")


if (!is.null(hosp_child)) {
  prediction_hosp_c <- predict.glm(hosp_child, df_child, type = "response")
  mroc_hosp_child <- roc(df_child$hosp_24h, prediction_hosp_c, plot = T)
  roc_data_hosp_child <- data.frame(
    fpr = round(1 - mroc_hosp_child$specificities, 4),
    sensitivity = round(mroc_hosp_child$sensitivities, 4),
    thresholds = round(mroc_hosp_child$thresholds, 4)
  )
  write.csv(roc_data_hosp_child, "output/results/models_combined_criteria/roc_data_hosp_child.csv")

  auc_hosp_child <- auc(mroc_hosp_child)
  auc_hosp_child_ci <- ci.auc(mroc_hosp_child)
  auc_hosp_child_ci_str <-  paste("(", round(auc_hosp_child_ci[1], 2), "-", round(auc_hosp_child_ci[2], 2), ")", sep = "")
  generate_calibration_plot(data = df_child, obs = "hosp_24h", pred = "prediction_hosp_c", output_path = "output/results/models_combined_criteria/calibration_hosp_child.csv")


} else {
  write.csv(data.frame(), "output/results/models_combined_criteria/roc_data_hosp_child.csv")
  auc_hosp_child <- NA
  auc_hosp_child_ci_str <- NA
  write.csv(data.frame(), "output/results/models_combined_criteria/calibration_hosp_child.csv")
}


if (!is.null(hosp_child_susp_cov)) {
  prediction_hosp_c_susp_cov <- predict.glm(hosp_child_susp_cov, df_child, type = "response")
  mroc_hosp_child_susp_cov <- roc(df_child$hosp_24h_susp_cov, prediction_hosp_c_susp_cov, plot = T)
  roc_data_hosp_child_susp_cov <- data.frame(
    fpr = round(1 - mroc_hosp_child_susp_cov$specificities, 4),
    sensitivity = round(mroc_hosp_child_susp_cov$sensitivities, 4),
    thresholds = round(mroc_hosp_child_susp_cov$thresholds, 4)
  )
  write.csv(roc_data_hosp_child_susp_cov, "output/results/models_combined_criteria/roc_data_hosp_child_susp_cov.csv")

  auc_hosp_child_susp_cov <- auc(mroc_hosp_child_susp_cov)
  auc_hosp_child_susp_cov_ci <- ci.auc(mroc_hosp_child_susp_cov)
  auc_hosp_child_susp_cov_ci_str <-  paste("(", round(auc_hosp_child_susp_cov_ci[1], 2), "-", round(auc_hosp_child_susp_cov_ci[2], 2), ")", sep = "")
  generate_calibration_plot(data = df_child, obs = "hosp_24h_susp_cov", pred = "prediction_hosp_c_susp_cov", output_path = "output/results/models_combined_criteria/calibration_hosp_child_susp_cov.csv")

} else {
  write.csv(data.frame(), "output/results/models_combined_criteria/roc_data_hosp_child_susp_cov.csv")
  auc_hosp_child_susp_cov <- NA
  auc_hosp_child_susp_cov_ci_str <- NA
  write.csv(data.frame(), "output/results/models_combined_criteria/calibration_hosp_child_susp_cov.csv")
}

if (!is.null(hosp_child_prob_cov)) {
  prediction_hosp_c_prob_cov <- predict.glm(hosp_child_prob_cov, df_child, type = "response")
  mroc_hosp_child_prob_cov <- roc(df_child$hosp_24h_prob_cov, prediction_hosp_c_prob_cov, plot = T)
  roc_data_hosp_child_prob_cov <- data.frame(
    fpr = round(1 - mroc_hosp_child_prob_cov$specificities, 4),
    sensitivity = round(mroc_hosp_child_prob_cov$sensitivities, 4),
    thresholds = round(mroc_hosp_child_prob_cov$thresholds, 4)
  )
  write.csv(roc_data_hosp_child_prob_cov, "output/results/models_combined_criteria/roc_data_hosp_child_prob_cov.csv")

  auc_hosp_child_prob_cov <- auc(mroc_hosp_child_prob_cov)
  auc_hosp_child_prob_cov_ci <- ci.auc(mroc_hosp_child_prob_cov)
  auc_hosp_child_prob_cov_ci_str <-  paste("(", round(auc_hosp_child_prob_cov_ci[1], 2), "-", round(auc_hosp_child_prob_cov_ci[2], 2), ")", sep = "")
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
  prediction_hosp_a <- predict.glm(hosp_adult, df_adult, type = "response")
  mroc_hosp_adult <- roc(df_adult$hosp_24h, prediction_hosp_a, plot = T)
  roc_data_hosp_adult <- data.frame(
    fpr = round(1 - mroc_hosp_adult$specificities, 4),
    sensitivity = round(mroc_hosp_adult$sensitivities, 4),
    thresholds = round(mroc_hosp_adult$thresholds, 4)
  )
  write.csv(roc_data_hosp_adult, "output/results/models_combined_criteria/roc_data_hosp_adult.csv")

  auc_hosp_adult <- auc(mroc_hosp_adult)
  auc_hosp_adult_ci <- ci.auc(mroc_hosp_adult)
  auc_hosp_adult_ci_str <-  paste("(", round(auc_hosp_adult_ci[1], 2), "-", round(auc_hosp_adult_ci[2], 2), ")", sep = "")
  generate_calibration_plot(data = df_adult, obs = "hosp_24h", pred = "prediction_hosp_a", output_path = "output/results/models_combined_criteria/calibration_hosp_adult.csv")

} else {
  write.csv(data.frame(), "output/results/models_combined_criteria/roc_data_hosp_adult.csv")
  auc_hosp_adult <- NA
  auc_hosp_adult_ci_str <- NA
  write.csv(data.frame(), "output/results/models_combined_criteria/calibration_hosp_adult.csv")
}

if (!is.null(hosp_adult_susp_cov)) {
  prediction_hosp_a_susp_cov <- predict.glm(hosp_adult_susp_cov, df_adult, type = "response")
  mroc_hosp_adult_susp_cov <- roc(df_adult$hosp_24h_susp_cov, prediction_hosp_a_susp_cov, plot = T)
  roc_data_hosp_adult_susp_cov <- data.frame(
    fpr = round(1 - mroc_hosp_adult_susp_cov$specificities, 4),
    sensitivity = round(mroc_hosp_adult_susp_cov$sensitivities, 4),
    thresholds = round(mroc_hosp_adult_susp_cov$thresholds, 4)
  )
  write.csv(roc_data_hosp_adult_susp_cov, "output/results/models_combined_criteria/roc_data_hosp_adult_susp_cov.csv")

  auc_hosp_adult_susp_cov <- auc(mroc_hosp_adult_susp_cov)
  auc_hosp_adult_susp_cov_ci <- ci.auc(mroc_hosp_adult_susp_cov)
  auc_hosp_adult_susp_cov_ci_str <-  paste("(", round(auc_hosp_adult_susp_cov_ci[1], 2), "-", round(auc_hosp_adult_susp_cov_ci[2], 2), ")", sep = "")
  generate_calibration_plot(data = df_adult, obs = "hosp_24h_susp_cov", pred = "prediction_hosp_a_susp_cov", output_path = "output/results/models_combined_criteria/calibration_hosp_adult_susp_cov.csv")

} else {
  write.csv(data.frame(), "output/results/models_combined_criteria/roc_data_hosp_adult_susp_cov.csv")
  auc_hosp_adult_susp_cov <- NA
  auc_hosp_adult_susp_cov_ci_str <- NA
  write.csv(data.frame(), "output/results/models_combined_criteria/calibration_hosp_adult_susp_cov.csv")
}

if (!is.null(hosp_adult_prob_cov)) {
  prediction_hosp_a_prob_cov <- predict.glm(hosp_adult_prob_cov, df_adult, type = "response")
  mroc_hosp_adult_prob_cov <- roc(df_adult$hosp_24h_prob_cov, prediction_hosp_a_prob_cov, plot = T)
  roc_data_hosp_adult_prob_cov <- data.frame(
    fpr = round(1 - mroc_hosp_adult_prob_cov$specificities, 4),
    sensitivity = round(mroc_hosp_adult_prob_cov$sensitivities, 4),
    thresholds = round(mroc_hosp_adult_prob_cov$thresholds, 4)
  )
  write.csv(roc_data_hosp_adult_prob_cov, "output/results/models_combined_criteria/roc_data_hosp_adult_prob_cov.csv")

  auc_hosp_adult_prob_cov <- auc(mroc_hosp_adult_prob_cov)
  auc_hosp_adult_prob_cov_ci <- ci.auc(mroc_hosp_adult_prob_cov)
  auc_hosp_adult_prob_cov_ci_str <-  paste("(", round(auc_hosp_adult_prob_cov_ci[1], 2), "-", round(auc_hosp_adult_prob_cov_ci[2], 2), ")", sep = "")
  generate_calibration_plot(data = df_adult, obs = "hosp_24h_prob_cov", pred = "prediction_hosp_a_prob_cov", output_path = "output/results/models_combined_criteria/calibration_hosp_adult_prob_cov.csv")
} else {
  write.csv(data.frame(), "output/results/models_combined_criteria/roc_data_hosp_adult_prob_cov.csv")
  auc_hosp_adult_prob_cov <- NA
  auc_hosp_adult_prob_cov_ci_str <- NA
  write.csv(data.frame(), "output/results/models_combined_criteria/calibration_hosp_adult_prob_cov.csv")
}


aucs <- data.frame(auc_hosp_child, auc_hosp_adult, auc_hosp_child_ci_str, auc_hosp_adult_ci_str)
aucs_susp_cov <- data.frame(auc_hosp_child_susp_cov, auc_hosp_adult_susp_cov, auc_hosp_child_susp_cov_ci_str, auc_hosp_adult_susp_cov_ci_str)
aucs_prob_cov <- data.frame(auc_hosp_child_prob_cov, auc_hosp_adult_prob_cov, auc_hosp_child_prob_cov_ci_str, auc_hosp_adult_prob_cov_ci_str)


colnames(aucs) <- c("hosp_child", "hosp_adult", "ci_hosp_child", "ci_hosp_adult")
colnames(aucs_susp_cov) <- c("hosp_child_susp_cov", "hosp_adult_susp_cov", "ci_hosp_child_susp_cov", "ci_hosp_adult_susp_cov")
colnames(aucs_prob_cov) <- c("hosp_child_prob_cov", "hosp_adult_prob_cov", "ci_hosp_child_prob_cov", "ci_hosp_adult_prob_cov")

write.csv(aucs, "output/results/models_combined_criteria/aucs.csv")
write.csv(aucs_susp_cov, "output/results/models_combined_criteria/aucs_susp_cov.csv")
write.csv(aucs_prob_cov, "output/results/models_combined_criteria/aucs_prob_cov.csv")

# severe outcome

model_so_a_adj_totalCAT <- fit_model(severe_outcome ~ total_CAT +
                                    age + sex + obesity_mod + comorb_number, data = df_adult, family = binomial)

if (!is.null(model_so_a_adj_totalCAT)) {
  saveSummary(model_so_a_adj_totalCAT, "output/results/models_combined_criteria/adult_severe_outcome_ajd.txt")
} else {
  write.csv(data.frame(), "output/results/models_combined_criteria/adult_severe_outcome_ajd.txt")
}

# ###Discrimination
severe_o <- fit_model(severe_outcome ~ total_CAT, data = df_adult ,family = "binomial")

if (!is.null(severe_o)) {
  df_adult$prediction_severe_outcome <- predict.glm(severe_o, df_adult, type = "response")
  mroc_severe_outcome <- roc(df_adult$severe_outcome, df_adult$prediction_severe_outcome, plot = T)
  roc_data_severe_outcome <- data.frame(
    fpr = 1 - mroc_severe_outcome$specificities,
    sensitivity = mroc_severe_outcome$sensitivities,
    thresholds = mroc_severe_outcome$thresholds
  )
  write.csv(roc_data_severe_outcome, "output/results/models_combined_criteria/roc_data_severe_outcome.csv")

  auc_so_adult <- auc(mroc_severe_outcome) 
  auc_so_ci <- ci.auc(mroc_severe_outcome)
  auc_so_ci_str <- paste0(round(auc_so_ci[1], 3), " (", round(auc_so_ci[2], 3), " - ", round(auc_so_ci[3], 3), ")")

  aucs_so <- data.frame(auc_so_adult, auc_so_ci_str)
  colnames(aucs_so) <- c("auc", "ci")
  write.csv(aucs_so, "output/results/models_combined_criteria/aucs_severe_outcome.csv")
  generate_calibration_plot(data = df_adult, obs = "severe_outcome", pred = "prediction_severe_outcome", output_path = "output/results/calibration_summary_severe_outcome.csv")

} else {
  write.csv(data.frame(), "output/results/models_combined_criteria/roc_data_severe_outcome.csv")
  write.csv(data.frame(), "output/results/models_combined_criteria/aucs_severe_outcome.csv")
  write.csv(data.frame(), "output/results/models_combined_criteria/calibration_severe_outcome.csv")
}


# adjusted models

model_hosp_a_adj_totalCAT <- fit_model_if_two_factors(df_adult, "hosp_24h", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_hosp_a_adj_totalCAT, "output/results/models_combined_criteria/adult_hospitalisation_adj.txt")

model_hosp_c_adj_totalCAT <- fit_model_if_two_factors(df_child, "hosp_24h", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_hosp_c_adj_totalCAT, "output/results/models_combined_criteria/child_hospitalisation_adj.txt")

model_covidhosp_a_adj_totalCAT <- fit_model_if_two_factors(df_adult, "covid_hosp_susp", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_covidhosp_a_adj_totalCAT, "output/results/models_combined_criteria/adult_hospitalisation_covid_adj.txt")

model_covidhosp_c_adj_totalCAT <- fit_model_if_two_factors(df_child, "covid_hosp_susp", "total_CAT", "age", "sex", "obesity_mod", "comorb_number")
saveSummary(model_covidhosp_c_adj_totalCAT, "output/results/models_combined_criteria/child_hospitalisation_covid_adj.txt")