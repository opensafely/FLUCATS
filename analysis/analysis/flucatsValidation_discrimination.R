#Continuing from flucatsValidation.R
library(pROC)

# read df child from csv
df_child <- read.csv("output/input_all_edited.csv")

#Separate models for each outcome, by child/adult status
hosp_child <- glm(hosp_24h ~ total_CAT, data = df_child ,family = "binomial")
prediction_hosp_c <- predict.glm(hosp_child, df_child, type = "response")
mroc_hosp_child <- roc(df_child$hosp_24h, prediction_hosp_c, plot = T)
roc_data_hosp_child <- data.frame(
  specificity = 1 - mroc_hosp_child$specificities,
  sensitivity = mroc_hosp_child$sensitivities,
  thresholds = mroc_hosp_child$thresholds
)
write.csv(roc_data_hosp_child, "output/results/roc_data_hosp_child.csv")
auc_hosp_child <- auc(mroc_hosp_child)

hosp_adult <- glm(hosp_24h ~ total_CAT, data = df_adult ,family = "binomial")
prediction_hosp_a <- predict.glm(hosp_adult, df_adult, type = "response")
mroc_hosp_adult <- roc(df_adult$hosp_24h, prediction_hosp_a, plot = T)
roc_data_hosp_adult <- data.frame(
  specificity = 1 - mroc_hosp_adult$specificities,
  sensitivity = mroc_hosp_adult$sensitivities,
  thresholds = mroc_hosp_adult$thresholds
)
write.csv(roc_data_hosp_adult, "output/results/roc_data_hosp_adult.csv")
auc_hosp_adult <- auc(mroc_hosp_adult)

death_child_pc <- glm(death_30d_pc ~ total_CAT, data = df_child ,family = "binomial")
prediction_dpc_c <- predict.glm(death_child_pc, df_child, type = "response")
mroc_dpc_child <- roc(df_child$death_30d_pc, prediction_dpc_c, plot = T)
roc_data_dpc_child <- data.frame(
  specificity = 1 - mroc_dpc_child$specificities,
  sensitivity = mroc_dpc_child$sensitivities,
  thresholds = mroc_dpc_child$thresholds
)
write.csv(roc_data_dpc_child, "output/results/roc_data_dpc_child.csv")
auc_dpc_child <- auc(mroc_dpc_child)

death_adult_pc <- glm(death_30d_pc ~ total_CAT, data = df_adult ,family = "binomial")
prediction_dpc_a <- predict.glm(death_adult_pc, df_adult, type = "response")
mroc_dpc_adult <- roc(df_adult$death_30d_pc, prediction_dpc_a, plot = T)
roc_data_dpc_adult <- data.frame(
  specificity = 1 - mroc_dpc_adult$specificities,
  sensitivity = mroc_dpc_adult$sensitivities,
  thresholds = mroc_dpc_adult$thresholds
)
write.csv(roc_data_dpc_adult, "output/results/roc_data_dpc_adult.csv")
auc_dpc_adult <- auc(mroc_dpc_adult)


#
death_child_ons <- glm(death_30d_ons ~ total_CAT, data = df_child ,family = "binomial")
prediction_ons_c <- predict.glm(death_child_ons, df_child, type = "response")
mroc_ons_child <- roc(df_child$death_30d_ons, prediction_ons_c, plot = T)
roc_data_ons_child <- data.frame(
  specificity = 1 - mroc_ons_child$specificities,
  sensitivity = mroc_ons_child$sensitivities,
  thresholds = mroc_ons_child$thresholds
)
write.csv(roc_data_ons_child, "output/results/roc_data_ons_child.csv")
auc_ons_child <- auc(mroc_ons_child)

death_adult_ons <- glm(death_30d_ons ~ total_CAT, data = df_adult ,family = "binomial")
prediction_ons_a <- predict.glm(death_adult_ons, df_adult, type = "response")
mroc_ons_adult <- roc(df_adult$death_30d_ons, prediction_ons_a, plot = T)
roc_data_ons_adult <- data.frame(
  specificity = 1 - mroc_ons_adult$specificities,
  sensitivity = mroc_ons_adult$sensitivities,
  thresholds = mroc_ons_adult$thresholds
)
write.csv(roc_data_ons_adult, "output/results/roc_data_ons_adult.csv")
auc_ons_adult <- auc(mroc_ons_adult)

#
icu_child <- glm(icu_adm ~ total_CAT, data = df_child ,family = "binomial")
prediction_icu_c <- predict.glm(icu_child, df_child, type = "response")
mroc_icu_child <- roc(df_child$icu_adm, prediction_icu_c, plot = T)
roc_data_icu_child <- data.frame(
  specificity = 1 - mroc_icu_child$specificities,
  sensitivity = mroc_icu_child$sensitivities,
  thresholds = mroc_icu_child$thresholds
)
write.csv(roc_data_icu_child, "output/results/roc_data_icu_child.csv")
auc_icu_child <- auc(mroc_icu_child)

icu_adult <- glm(icu_adm ~ total_CAT, data = df_adult ,family = "binomial")
prediction_icu_a <- predict.glm(icu_adult, df_adult, type = "response")
mroc_icu_adult <- roc(df_adult$icu_adm, prediction_icu_a, plot = T)
roc_data_icu_adult <- data.frame(
  specificity = 1 - mroc_icu_adult$specificities,
  sensitivity = mroc_icu_adult$sensitivities,
  thresholds = mroc_icu_adult$thresholds
)
write.csv(roc_data_icu_adult, "output/results/roc_data_icu_adult.csv")
auc_icu_adult <- auc(mroc_icu_adult)


aucs <- data.frame(auc_hosp_child, auc_hosp_adult, auc_dpc_child, auc_dpc_adult, auc_ons_child, auc_ons_adult, auc_icu_child, auc_icu_adult)

colnames(aucs) <- c("hosp_child", "hosp_adult", "dpc_child", "dpc_adult", "ons_child", "ons_adult", "icu_child", "icu_adult")

write.csv(aucs, "output/results/aucs.csv")