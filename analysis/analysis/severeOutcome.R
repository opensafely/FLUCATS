library(pROC)
library(predtools)
library(dplyr)

source("analysis/analysis/utils.R")

df <- read.csv("output/input_all_edited.csv")
df_child <- df[df$category == "Child",]
df_adult <- df[df$category == "Adult",]

#Define the 'severe outcomes' composite outcome
df <- df %>% 
  mutate(severe_outcome = case_when(covid_death_30d_ons == 1| icu_adm ==1 ~ 1,
                                     TRUE ~ 0))# composite severe outcome

df_child <- df_child %>% 
  mutate(severe_outcome = case_when(covid_death_30d_ons == 1| icu_adm ==1 ~ 1,
                                     TRUE ~ 0))# composite severe outcome

df_adult <- df_adult %>% 
  mutate(severe_outcome = case_when(covid_death_30d_ons == 1| icu_adm ==1 ~ 1,
                                     TRUE ~ 0))# composite severe outcome


variables <- c("age","age_band","sex","region","bmi","bmi_primis","asthma","addisons_hypoadrenalism",
               "chronic_heart_disease","chronic_respiratory_disease","ckd_primis_stage",
               "renal_disease","ckd35_or_renal_disease","ckd_os","liver_disease","pregnant",
               "diabetes","gestational_diabetes","obesity","mental_illness",
               "neurological_disorder","hypertension","pneumonia","immunosuppression_disorder",
               "immunosuppression_chemo","splenic_disease","shield","nonshield",
               "statins","covadm1","covadm2","pfd1rx","pfd2rx",
               "azd1rx","azd2rx","covrx1", "covrx2",
               "ethnicity_opensafely","ethnicity","homeless",
               "residential_care","imdQ5")

flucats_vars <- c("total_CAT", "flucats_a", "flucats_b", "flucats_c", "flucats_d", "flucats_e", "flucats_f", "flucats_g")


#Various tables
#Table 1: demographics by severe outcome
summarise_and_export_data(df, variables, "output/results/tab1_so.csv", split_by="severe_outcome")


summarise_and_export_data(df_adult, flucats_vars, "output/results/table_5_a_so.csv" , split_by="severe_outcome")
model_hosp_so <- fit_model(severe_outcome ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, df_adult, binomial)

if (!is.null(model_hosp_so)) {
  saveSummary(model_hosp_so, "output/results/table_9_a_so.txt")
} else {
  write.csv(data.frame(), "output/results/table_9_a_so.txt")
}


# #Adjusted models for severe outcomes
df_adult <- df_adult %>% 
  mutate(obesity = as.numeric(as.character(obesity)),
         obesity_mod = if_else(obesity == 0, 9, obesity))


comorbidity_vars <- c("asthma", "addisons_hypoadrenalism", "chronic_heart_disease", "chronic_respiratory_disease", "ckd35_or_renal_disease", "liver_disease",
                      "diabetes", "mental_illness", "neurological_disorder", "hypertension", "pneumonia", "immunosuppression_disorder", "immunosuppression_chemo",
                      "splenic_disease")
# comorbidity_vars - these need to be converte to numeric
df_adult <- df_adult %>% 
  mutate(across(all_of(comorbidity_vars), as.numeric))


df_adult <- df_adult %>% 
  rowwise() %>% 
  mutate(comorb_number = sum(asthma, addisons_hypoadrenalism, chronic_heart_disease, chronic_respiratory_disease, ckd35_or_renal_disease, liver_disease,
                              diabetes, obesity, mental_illness, neurological_disorder, hypertension, pneumonia, immunosuppression_disorder, immunosuppression_chemo,
                              splenic_disease, na.rm = T))

model_so_a_adj <- fit_model(severe_outcome ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g +
                           age + sex + obesity_mod + comorb_number, data = df_adult, family = binomial)

if (!is.null(model_so_a_adj)) {
  saveSummary(model_so_a_adj, "output/results/table_9_a_so_adj.txt")
} else {
  write.csv(data.frame(), "output/results/table_9_a_so_adj.txt")
}


model_so_a_adj_totalCAT <- fit_model(severe_outcome ~ total_CAT +
                                    age + sex + obesity_mod + comorb_number, data = df_adult, family = binomial)

if (!is.null(model_so_a_adj_totalCAT)) {
  saveSummary(model_so_a_adj_totalCAT, "output/results/table_9_a_so_adj_totalCAT.txt")
} else {
  write.csv(data.frame(), "output/results/table_9_a_so_adj_totalCAT.txt")
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
  write.csv(roc_data_severe_outcome, "output/results/roc_data_severe_outcome.csv")

  auc_so_adult <- auc(mroc_severe_outcome) 
  auc_so_ci <- ci.auc(mroc_severe_outcome)
  auc_so_ci_str <- paste0(round(auc_so_ci[1], 3), " (", round(auc_so_ci[2], 3), " - ", round(auc_so_ci[3], 3), ")")

  aucs_so <- data.frame(auc_so_adult, auc_so_ci_str)
  colnames(aucs_so) <- c("auc", "ci")
  write.csv(aucs_so, "output/results/aucs_so.csv")


  # print value counts for the severe outcome and the prediction
  print(table(df_adult$severe_outcome))
  print(table(df_adult$prediction_severe_outcome > 0.5))

  output <- calibration_plot(data = df_adult, obs = "severe_outcome", pred = "prediction_severe_outcome", data_summary=T)

  write.csv(output$data_summary, "output/results/calibration_summary_severe_outcome.csv")

} else {
  write.csv(data.frame(), "output/results/roc_data_severe_outcome.csv")
  write.csv(data.frame(), "output/results/aucs_so.csv")
  write.csv(data.frame(), "output/results/calibration_summary_severe_outcome.csv")
}

