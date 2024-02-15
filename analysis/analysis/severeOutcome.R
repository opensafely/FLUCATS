
library(pROC)
library(predtools)
library(dplyr)

source("analysis/analysis/flucats_descriptive.R")



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

#Various tables
#Table 1: demographics by severe outcome
summarise_and_export_data(df, variables, "output/results/tab1_so.csv", split_by="severe_outcome")


summarise_and_export_data(df_adult, flucats_vars, "output/results/table_5_a_so.csv" , split_by="severe_outcome")

model_hosp_so <- glm( severe_outcome ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_adult, family = binomial)
saveSummary(model_hosp_so, "output/results/table_9_a_so.txt")

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
  mutate(comorb_number <- sum(asthma, addisons_hypoadrenalism, chronic_heart_disease, chronic_respiratory_disease, ckd35_or_renal_disease, liver_disease,
                              diabetes, obesity, mental_illness, neurological_disorder, hypertension, pneumonia, immunosuppression_disorder, immunosuppression_chemo,
                              splenic_disease, na.rm = T))

model_so_a_adj <- glm( severe_outcome ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g +
                           age + sex + obesity_mod + comorb_number, data = df_adult, family = binomial)

saveSummary(model_so_a_adj, "output/results/table_9_a_so_adj.txt")

model_so_a_adj_totalCAT <- glm( severe_outcome ~ total_CAT +
                                    age + sex + obesity_mod + comorb_number, data = df_adult, family = binomial)

saveSummary(model_so_a_adj_totalCAT, "output/results/table_9_a_so_adj_totalCAT.txt")                       

# ###Discrimination
severe_o <- glm(severe_outcome ~ total_CAT, data = df_adult ,family = "binomial")
df_adult$prediction_severe_outcome <- predict.glm(severe_outcome, df_adult, type = "response")
mroc_severe_outcome <- roc(df_adult$severe_outcome, df_adult$prediction_severe_outcome, plot = T)
roc_data_severe_outcome <- data.frame(
  fpr = 1 - mroc_severe_outcome$specificities,
  sensitivity = mroc_severe_outcome$sensitivities,
  thresholds = mroc_severe_outcome$thresholds
)
write.csv(roc_data_severe_outcome, "output/results/roc_data_severe_outcome.csv")


auc_so_adult <- auc(mroc_severe_outcome) #print value
auc_so_ci <- ci.auc(mroc_severe_outcome) #print value

aucs_so <- data.frame(auc_so_adult, ci_so_adult = auc_so_ci)
colnames(aucs_so) <- c("auc", "ci")
write.csv(aucs_so, "output/results/aucs_so.csv")

# #calibration plot
plot, d_summary <- calibration_plot(data = df_adult, obs = "severe_outcome", pred = "prediction_severe_outcome", data_summary=T)

write.csv(d_summary, "output/results/calibration_summary_severe_outcome.csv")


