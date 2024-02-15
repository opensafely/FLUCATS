#Continuing from flucatsValidation.R
library(pROC)

saveSummary <- function(model, filename) {
  sink(filename)
  print(summary(model))
  sink()
}

# read df child from csv
df <- read.csv("output/input_all_edited.csv")
df_child <- df[df$category == "Child",]
df_adult <- df[df$category == "Adult",]

#Separate models for each outcome, by child/adult status
hosp_child <- glm(hosp_24h ~ total_CAT, data = df_child ,family = "binomial")
hosp_child_susp_cov <- glm(hosp_24h_susp_cov ~ total_CAT, data = df_child ,family = "binomial")
hosp_child_prob_cov <- glm(hosp_24h_prob_cov ~ total_CAT, data = df_child ,family = "binomial")

saveSummary(hosp_child, "output/results/hosp_child_summary.txt")
saveSummary(hosp_child_susp_cov, "output/results/hosp_child_susp_cov_summary.txt")
saveSummary(hosp_child_prob_cov, "output/results/hosp_child_prob_cov_summary.txt")

prediction_hosp_c <- predict.glm(hosp_child, df_child, type = "response")
prediction_hosp_c_susp_cov <- predict.glm(hosp_child_susp_cov, df_child, type = "response")
prediction_hosp_c_prob_cov <- predict.glm(hosp_child_prob_cov, df_child, type = "response")

mroc_hosp_child <- roc(df_child$hosp_24h, prediction_hosp_c, plot = T)
mroc_hosp_child_susp_cov <- roc(df_child$hosp_24h_susp_cov, prediction_hosp_c_susp_cov, plot = T)
mroc_hosp_child_prob_cov <- roc(df_child$hosp_24h_prob_cov, prediction_hosp_c_prob_cov, plot = T)

roc_data_hosp_child <- data.frame(
  fpr = round(1 - mroc_hosp_child$specificities, 4),
  sensitivity = round(mroc_hosp_child$sensitivities, 4),
  thresholds = round(mroc_hosp_child$thresholds, 4)
)
write.csv(roc_data_hosp_child, "output/results/roc_data_hosp_child.csv")

roc_data_hosp_child_susp_cov <- data.frame(
  fpr = round(1 - mroc_hosp_child_susp_cov$specificities, 4),
  sensitivity = round(mroc_hosp_child_susp_cov$sensitivities, 4),
  thresholds = round(mroc_hosp_child_susp_cov$thresholds, 4)
)

write.csv(roc_data_hosp_child_susp_cov, "output/results/roc_data_hosp_child_susp_cov.csv")

roc_data_hosp_child_prob_cov <- data.frame(
  fpr = round(1 - mroc_hosp_child_prob_cov$specificities, 4),
  sensitivity = round(mroc_hosp_child_prob_cov$sensitivities, 4),
  thresholds = round(mroc_hosp_child_prob_cov$thresholds, 4)
)

write.csv(roc_data_hosp_child_prob_cov, "output/results/roc_data_hosp_child_prob_cov.csv")




auc_hosp_child <- auc(mroc_hosp_child)
auc_hosp_child_ci <- ci.auc(mroc_hosp_adult)

auc_hosp_child_susp_cov <- auc(mroc_hosp_child_susp_cov)
aur_hosp_child_susp_cov_ci <- ci.auc(mroc_hosp_child_susp_cov)

auc_hosp_child_prob_cov <- auc(mroc_hosp_child_prob_cov)
aur_hosp_child_prob_cov_ci <- ci.auc(mroc_hosp_child_prob_cov)

hosp_adult <- glm(hosp_24h ~ total_CAT, data = df_adult ,family = "binomial")
saveSummary(hosp_adult, "output/results/hosp_adult_summary.txt")

hosp_adult_susp_cov <- glm(hosp_24h_susp_cov ~ total_CAT, data = df_adult ,family = "binomial")
saveSummary(hosp_adult_susp_cov, "output/results/hosp_adult_susp_cov_summary.txt")

hosp_adult_prob_cov <- glm(hosp_24h_prob_cov ~ total_CAT, data = df_adult ,family = "binomial")
saveSummary(hosp_adult_prob_cov, "output/results/hosp_adult_prob_cov_summary.txt")


prediction_hosp_a <- predict.glm(hosp_adult, df_adult, type = "response")
prediction_hosp_a_susp_cov <- predict.glm(hosp_adult_susp_cov, df_adult, type = "response")
prediction_hosp_a_prob_cov <- predict.glm(hosp_adult_prob_cov, df_adult, type = "response")

mroc_hosp_adult <- roc(df_adult$hosp_24h, prediction_hosp_a, plot = T)
mroc_hosp_adult_susp_cov <- roc(df_adult$hosp_24h_susp_cov, prediction_hosp_a_susp_cov, plot = T)
mroc_hosp_adult_prob_cov <- roc(df_adult$hosp_24h_prob_cov, prediction_hosp_a_prob_cov, plot = T)

roc_data_hosp_adult <- data.frame(
  fpr = round(1 - mroc_hosp_adult$specificities, 4),
  sensitivity = round(mroc_hosp_adult$sensitivities, 4),
  thresholds = round(mroc_hosp_adult$thresholds, 4)
)
write.csv(roc_data_hosp_adult, "output/results/roc_data_hosp_adult.csv")

roc_data_hosp_adult_susp_cov <- data.frame(
  fpr = round(1 - mroc_hosp_adult_susp_cov$specificities, 4),
  sensitivity = round(mroc_hosp_adult_susp_cov$sensitivities, 4),
  thresholds = round(mroc_hosp_adult_susp_cov$thresholds, 4)
)

write.csv(roc_data_hosp_adult_susp_cov, "output/results/roc_data_hosp_adult_susp_cov.csv")

roc_data_hosp_adult_prob_cov <- data.frame(
  fpr = round(1 - mroc_hosp_adult_prob_cov$specificities, 4),
  sensitivity = round(mroc_hosp_adult_prob_cov$sensitivities, 4),
  thresholds = round(mroc_hosp_adult_prob_cov$thresholds, 4)
)

write.csv(roc_data_hosp_adult_prob_cov, "output/results/roc_data_hosp_adult_prob_cov.csv")

auc_hosp_adult <- auc(mroc_hosp_adult)
auc_hosp_adult_ci <- ci.auc(mroc_hosp_adult)

auc_hosp_adult_susp_cov <- auc(mroc_hosp_adult_susp_cov)
aur_hosp_adult_susp_cov_ci <- ci.auc(mroc_hosp_adult_susp_cov)

auc_hosp_adult_prob_cov <- auc(mroc_hosp_adult_prob_cov)
aur_hosp_adult_prob_cov_ci <- ci.auc(mroc_hosp_adult_prob_cov)

# death_child_pc <- glm(death_30d_pc ~ total_CAT, data = df_child ,family = "binomial")
# prediction_dpc_c <- predict.glm(death_child_pc, df_child, type = "response")
# mroc_dpc_child <- roc(df_child$death_30d_pc, prediction_dpc_c, plot = T)
# roc_data_dpc_child <- data.frame(
#   fpr = 1 - mroc_dpc_child$specificities,
#   sensitivity = mroc_dpc_child$sensitivities,
#   thresholds = mroc_dpc_child$thresholds
# )
# write.csv(roc_data_dpc_child, "output/results/roc_data_dpc_child.csv")
# auc_dpc_child <- auc(mroc_dpc_child)

# death_adult_pc <- glm(death_30d_pc ~ total_CAT, data = df_adult ,family = "binomial")
# prediction_dpc_a <- predict.glm(death_adult_pc, df_adult, type = "response")
# mroc_dpc_adult <- roc(df_adult$death_30d_pc, prediction_dpc_a, plot = T)
# roc_data_dpc_adult <- data.frame(
#   fpr = 1 - mroc_dpc_adult$specificities,
#   sensitivity = mroc_dpc_adult$sensitivities,
#   thresholds = mroc_dpc_adult$thresholds
# )
# write.csv(roc_data_dpc_adult, "output/results/roc_data_dpc_adult.csv")
# auc_dpc_adult <- auc(mroc_dpc_adult)


# #
# death_child_ons <- glm(death_30d_ons ~ total_CAT, data = df_child ,family = "binomial")
# prediction_ons_c <- predict.glm(death_child_ons, df_child, type = "response")
# mroc_ons_child <- roc(df_child$death_30d_ons, prediction_ons_c, plot = T)
# roc_data_ons_child <- data.frame(
#   fpr = 1 - mroc_ons_child$specificities,
#   sensitivity = mroc_ons_child$sensitivities,
#   thresholds = mroc_ons_child$thresholds
# )
# write.csv(roc_data_ons_child, "output/results/roc_data_ons_child.csv")
# auc_ons_child <- auc(mroc_ons_child)

# death_adult_ons <- glm(death_30d_ons ~ total_CAT, data = df_adult ,family = "binomial")
# prediction_ons_a <- predict.glm(death_adult_ons, df_adult, type = "response")
# mroc_ons_adult <- roc(df_adult$death_30d_ons, prediction_ons_a, plot = T)
# roc_data_ons_adult <- data.frame(
#   fpr = 1 - mroc_ons_adult$specificities,
#   sensitivity = mroc_ons_adult$sensitivities,
#   thresholds = mroc_ons_adult$thresholds
# )
# write.csv(roc_data_ons_adult, "output/results/roc_data_ons_adult.csv")
# auc_ons_adult <- auc(mroc_ons_adult)

# #
# icu_child <- glm(icu_adm ~ total_CAT, data = df_child ,family = "binomial")
# prediction_icu_c <- predict.glm(icu_child, df_child, type = "response")
# mroc_icu_child <- roc(df_child$icu_adm, prediction_icu_c, plot = T)
# roc_data_icu_child <- data.frame(
#   fpr = 1 - mroc_icu_child$specificities,
#   sensitivity = mroc_icu_child$sensitivities,
#   thresholds = mroc_icu_child$thresholds
# )
# write.csv(roc_data_icu_child, "output/results/roc_data_icu_child.csv")
# auc_icu_child <- auc(mroc_icu_child)

# icu_adult <- glm(icu_adm ~ total_CAT, data = df_adult ,family = "binomial")
# prediction_icu_a <- predict.glm(icu_adult, df_adult, type = "response")
# mroc_icu_adult <- roc(df_adult$icu_adm, prediction_icu_a, plot = T)
# roc_data_icu_adult <- data.frame(
#   fpr = 1 - mroc_icu_adult$specificities,
#   sensitivity = mroc_icu_adult$sensitivities,
#   thresholds = mroc_icu_adult$thresholds
# )
# write.csv(roc_data_icu_adult, "output/results/roc_data_icu_adult.csv")
# auc_icu_adult <- auc(mroc_icu_adult)


aucs <- data.frame(auc_hosp_child, auc_hosp_adult, ci_hosp_child = auc_hosp_child_ci, 
  ci_hosp_adult = auc_hosp_adult_ci)
aucs_susp_cov <- data.frame(auc_hosp_child_susp_cov, auc_hosp_adult_susp_cov, ci_hosp_child_susp_cov = aur_hosp_child_susp_cov_ci, 
  ci_hosp_adult_susp_cov = aur_hosp_adult_susp_cov_ci)
aucs_prob_cov <- data.frame(auc_hosp_child_prob_cov, auc_hosp_adult_prob_cov, ci_hosp_child_prob_cov = aur_hosp_child_prob_cov_ci, 
  ci_hosp_adult_prob_cov = aur_hosp_adult_prob_cov_ci)


colnames(aucs) <- c("hosp_child", "hosp_adult", "ci_hosp_child", "ci_hosp_adult")
colnames(aucs_susp_cov) <- c("hosp_child_susp_cov", "hosp_adult_susp_cov", "ci_hosp_child_susp_cov", "ci_hosp_adult_susp_cov")
colnames(aucs_prob_cov) <- c("hosp_child_prob_cov", "hosp_adult_prob_cov", "ci_hosp_child_prob_cov", "ci_hosp_adult_prob_cov")

write.csv(aucs, "output/results/aucs.csv")
write.csv(aucs_susp_cov, "output/results/aucs_susp_cov.csv")
write.csv(aucs_prob_cov, "output/results/aucs_prob_cov.csv")