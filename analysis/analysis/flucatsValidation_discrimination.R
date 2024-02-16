#Continuing from flucatsValidation.R
library(pROC)
library(predtools)

source("analysis/analysis/utils.R")

# read df child from csv
df <- read.csv("output/input_all_edited.csv")

df$suspected_covid <- as.integer(rowSums(df[, grepl("flucats_question_suspected_covid", names(df))] == 1) > 0)

# create covid_hosp variable - suspected_covid and hosp_24h
df$covid_hosp <- ifelse(df$suspected_covid == 1 & df$hosp_24h == 1, 1, 0)

df_child <- df[df$category == "Child",]
df_adult <- df[df$category == "Adult",]

#Separate models for each outcome, by child/adult status
hosp_child <- fit_model(hosp_24h ~ total_CAT, df_child ,family = "binomial")
hosp_child_susp_cov <- fit_model(hosp_24h_susp_cov ~ total_CAT, df_child ,family = "binomial")
hosp_child_prob_cov <- fit_model(hosp_24h_prob_cov ~ total_CAT, df_child ,family = "binomial")

saveSummary(hosp_child, "output/results/hosp_child_summary.txt")
saveSummary(hosp_child_susp_cov, "output/results/hosp_child_susp_cov_summary.txt")
saveSummary(hosp_child_prob_cov, "output/results/hosp_child_prob_cov_summary.txt")


if (!is.null(hosp_child)) {
  prediction_hosp_c <- predict.glm(hosp_child, df_child, type = "response")
  mroc_hosp_child <- roc(df_child$hosp_24h, prediction_hosp_c, plot = T)
  roc_data_hosp_child <- data.frame(
    fpr = round(1 - mroc_hosp_child$specificities, 4),
    sensitivity = round(mroc_hosp_child$sensitivities, 4),
    thresholds = round(mroc_hosp_child$thresholds, 4)
  )
  write.csv(roc_data_hosp_child, "output/results/roc_data_hosp_child.csv")

  auc_hosp_child <- auc(mroc_hosp_child)
  auc_hosp_child_ci <- ci.auc(mroc_hosp_child)
  auc_hosp_child_ci_str <-  paste("(", round(auc_hosp_child_ci[1], 2), "-", round(auc_hosp_child_ci[2], 2), ")", sep = "")
  calibration <- calibration_plot(data = df_child, obs = "hosp_24h", pred = "prediction_hosp_c", data_summary =  T)
  write.csv(calibration$data_summary, "output/results/calibration_hosp_child.csv")



} else {
  write.csv(data.frame(), "output/results/roc_data_hosp_child.csv")
  auc_hosp_child <- NA
  auc_hosp_child_ci_str <- NA
  write.csv(data.frame(), "output/results/calibration_hosp_child.csv")
}


if (!is.null(hosp_child_susp_cov)) {
  prediction_hosp_c_susp_cov <- predict.glm(hosp_child_susp_cov, df_child, type = "response")
  mroc_hosp_child_susp_cov <- roc(df_child$hosp_24h_susp_cov, prediction_hosp_c_susp_cov, plot = T)
  roc_data_hosp_child_susp_cov <- data.frame(
    fpr = round(1 - mroc_hosp_child_susp_cov$specificities, 4),
    sensitivity = round(mroc_hosp_child_susp_cov$sensitivities, 4),
    thresholds = round(mroc_hosp_child_susp_cov$thresholds, 4)
  )
  write.csv(roc_data_hosp_child_susp_cov, "output/results/roc_data_hosp_child_susp_cov.csv")

  auc_hosp_child_susp_cov <- auc(mroc_hosp_child_susp_cov)
  auc_hosp_child_susp_cov_ci <- ci.auc(mroc_hosp_child_susp_cov)
  auc_hosp_child_susp_cov_ci_str <-  paste("(", round(auc_hosp_child_susp_cov_ci[1], 2), "-", round(auc_hosp_child_susp_cov_ci[2], 2), ")", sep = "")
  calibration <- calibration_plot(data = df_child, obs = "hosp_24h_susp_cov", pred = "prediction_hosp_c_susp_cov", data_summary =  T)
  write.csv(calibration$data_summary, "output/results/calibration_hosp_child_susp_cov.csv")

} else {
  write.csv(data.frame(), "output/results/roc_data_hosp_child_susp_cov.csv")
  auc_hosp_child_susp_cov <- NA
  auc_hosp_child_susp_cov_ci_str <- NA
  write.csv(data.frame(), "output/results/calibration_hosp_child_susp_cov.csv")
}

if (!is.null(hosp_child_prob_cov)) {
  prediction_hosp_c_prob_cov <- predict.glm(hosp_child_prob_cov, df_child, type = "response")
  mroc_hosp_child_prob_cov <- roc(df_child$hosp_24h_prob_cov, prediction_hosp_c_prob_cov, plot = T)
  roc_data_hosp_child_prob_cov <- data.frame(
    fpr = round(1 - mroc_hosp_child_prob_cov$specificities, 4),
    sensitivity = round(mroc_hosp_child_prob_cov$sensitivities, 4),
    thresholds = round(mroc_hosp_child_prob_cov$thresholds, 4)
  )
  write.csv(roc_data_hosp_child_prob_cov, "output/results/roc_data_hosp_child_prob_cov.csv")

  auc_hosp_child_prob_cov <- auc(mroc_hosp_child_prob_cov)
  auc_hosp_child_prob_cov_ci <- ci.auc(mroc_hosp_child_prob_cov)
  auc_hosp_child_prob_cov_ci_str <-  paste("(", round(auc_hosp_child_prob_cov_ci[1], 2), "-", round(auc_hosp_child_prob_cov_ci[2], 2), ")", sep = "")
  calibration <- calibration_plot(data = df_child, obs = "hosp_24h_prob_cov", pred = "prediction_hosp_c_prob_cov", data_summary =  T)
  write.csv(calibration$data_summary, "output/results/calibration_hosp_child_prob_cov.csv")

} else {
  write.csv(data.frame(), "output/results/roc_data_hosp_child_prob_cov.csv")
  auc_hosp_child_prob_cov <- NA
  auc_hosp_child_prob_cov_ci_str <- NA
  write.csv(data.frame(), "output/results/calibration_hosp_child_prob_cov.csv")
}



hosp_adult <- fit_model(hosp_24h ~ total_CAT, df_adult ,family = "binomial")
saveSummary(hosp_adult, "output/results/hosp_adult_summary.txt")

hosp_adult_susp_cov <- fit_model(hosp_24h_susp_cov ~ total_CAT, df_adult ,family = "binomial")
saveSummary(hosp_adult_susp_cov, "output/results/hosp_adult_susp_cov_summary.txt")

hosp_adult_prob_cov <- fit_model(hosp_24h_prob_cov ~ total_CAT, data = df_adult ,family = "binomial")
saveSummary(hosp_adult_prob_cov, "output/results/hosp_adult_prob_cov_summary.txt")

if (!is.null(hosp_adult)) {
  prediction_hosp_a <- predict.glm(hosp_adult, df_adult, type = "response")
  mroc_hosp_adult <- roc(df_adult$hosp_24h, prediction_hosp_a, plot = T)
  roc_data_hosp_adult <- data.frame(
    fpr = round(1 - mroc_hosp_adult$specificities, 4),
    sensitivity = round(mroc_hosp_adult$sensitivities, 4),
    thresholds = round(mroc_hosp_adult$thresholds, 4)
  )
  write.csv(roc_data_hosp_adult, "output/results/roc_data_hosp_adult.csv")

  auc_hosp_adult <- auc(mroc_hosp_adult)
  auc_hosp_adult_ci <- ci.auc(mroc_hosp_adult)
  auc_hosp_adult_ci_str <-  paste("(", round(auc_hosp_adult_ci[1], 2), "-", round(auc_hosp_adult_ci[2], 2), ")", sep = "")
  calibration <- calibration_plot(data = df_adult, obs = "hosp_24h", pred = "prediction_hosp_a", data_summary =  T)
  write.csv(calibration$data_summary, "output/results/calibration_hosp_adult.csv")

} else {
  write.csv(data.frame(), "output/results/roc_data_hosp_adult.csv")
  auc_hosp_adult <- NA
  auc_hosp_adult_ci_str <- NA
  write.csv(data.frame(), "output/results/calibration_hosp_adult.csv")
}

if (!is.null(hosp_adult_susp_cov)) {
  prediction_hosp_a_susp_cov <- predict.glm(hosp_adult_susp_cov, df_adult, type = "response")
  mroc_hosp_adult_susp_cov <- roc(df_adult$hosp_24h_susp_cov, prediction_hosp_a_susp_cov, plot = T)
  roc_data_hosp_adult_susp_cov <- data.frame(
    fpr = round(1 - mroc_hosp_adult_susp_cov$specificities, 4),
    sensitivity = round(mroc_hosp_adult_susp_cov$sensitivities, 4),
    thresholds = round(mroc_hosp_adult_susp_cov$thresholds, 4)
  )
  write.csv(roc_data_hosp_adult_susp_cov, "output/results/roc_data_hosp_adult_susp_cov.csv")

  auc_hosp_adult_susp_cov <- auc(mroc_hosp_adult_susp_cov)
  auc_hosp_adult_susp_cov_ci <- ci.auc(mroc_hosp_adult_susp_cov)
  auc_hosp_adult_susp_cov_ci_str <-  paste("(", round(auc_hosp_adult_susp_cov_ci[1], 2), "-", round(auc_hosp_adult_susp_cov_ci[2], 2), ")", sep = "")
  calibration <- calibration_plot(data = df_adult, obs = "hosp_24h_susp_cov", pred = "prediction_hosp_a_susp_cov", data_summary =  T)
  write.csv(calibration$data_summary, "output/results/calibration_hosp_adult_susp_cov.csv")

} else {
  write.csv(data.frame(), "output/results/roc_data_hosp_adult_susp_cov.csv")
  auc_hosp_adult_susp_cov <- NA
  auc_hosp_adult_susp_cov_ci_str <- NA
  write.csv(data.frame(), "output/results/calibration_hosp_adult_susp_cov.csv")
}

if (!is.null(hosp_adult_prob_cov)) {
  prediction_hosp_a_prob_cov <- predict.glm(hosp_adult_prob_cov, df_adult, type = "response")
  mroc_hosp_adult_prob_cov <- roc(df_adult$hosp_24h_prob_cov, prediction_hosp_a_prob_cov, plot = T)
  roc_data_hosp_adult_prob_cov <- data.frame(
    fpr = round(1 - mroc_hosp_adult_prob_cov$specificities, 4),
    sensitivity = round(mroc_hosp_adult_prob_cov$sensitivities, 4),
    thresholds = round(mroc_hosp_adult_prob_cov$thresholds, 4)
  )
  write.csv(roc_data_hosp_adult_prob_cov, "output/results/roc_data_hosp_adult_prob_cov.csv")

  auc_hosp_adult_prob_cov <- auc(mroc_hosp_adult_prob_cov)
  auc_hosp_adult_prob_cov_ci <- ci.auc(mroc_hosp_adult_prob_cov)
  auc_hosp_adult_prob_cov_ci_str <-  paste("(", round(auc_hosp_adult_prob_cov_ci[1], 2), "-", round(auc_hosp_adult_prob_cov_ci[2], 2), ")", sep = "")
  calibration <- calibration_plot(data = df_adult, obs = "hosp_24h_prob_cov", pred = "prediction_hosp_a_prob_cov", data_summary =  T)
  write.csv(calibration$data_summary, "output/results/calibration_hosp_adult_prob_cov.csv")
} else {
  write.csv(data.frame(), "output/results/roc_data_hosp_adult_prob_cov.csv")
  auc_hosp_adult_prob_cov <- NA
  auc_hosp_adult_prob_cov_ci_str <- NA
  write.csv(data.frame(), "output/results/calibration_hosp_adult_prob_cov.csv")
}


aucs <- data.frame(auc_hosp_child, auc_hosp_adult, auc_hosp_child_ci_str, auc_hosp_adult_ci_str)
aucs_susp_cov <- data.frame(auc_hosp_child_susp_cov, auc_hosp_adult_susp_cov, auc_hosp_child_susp_cov_ci_str, auc_hosp_adult_susp_cov_ci_str)
aucs_prob_cov <- data.frame(auc_hosp_child_prob_cov, auc_hosp_adult_prob_cov, auc_hosp_child_prob_cov_ci_str, auc_hosp_adult_prob_cov_ci_str)


colnames(aucs) <- c("hosp_child", "hosp_adult", "ci_hosp_child", "ci_hosp_adult")
colnames(aucs_susp_cov) <- c("hosp_child_susp_cov", "hosp_adult_susp_cov", "ci_hosp_child_susp_cov", "ci_hosp_adult_susp_cov")
colnames(aucs_prob_cov) <- c("hosp_child_prob_cov", "hosp_adult_prob_cov", "ci_hosp_child_prob_cov", "ci_hosp_adult_prob_cov")

write.csv(aucs, "output/results/aucs.csv")
write.csv(aucs_susp_cov, "output/results/aucs_susp_cov.csv")
write.csv(aucs_prob_cov, "output/results/aucs_prob_cov.csv")