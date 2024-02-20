library(pROC)
library(predtools)
library(dplyr)


source("analysis/analysis/utils.R")

dir.create("output/results/isaric", showWarnings = FALSE)

df <- arrow::read_feather("output/joined/full/input_all_extra_vars.feather")

# Estimating discriminative ability of the modified ISARIC4C mortality score

#We will use the original df without the adult/child split as the ISARIC4C tool is meant for use in adults (18+ yrs)

df <- df %>% 
  filter(age>=18)


#Define covariates needed
df <- df %>% 
  mutate(age_categ = case_when(age < 50 ~ 0,
                               age >= 50 & age < 60 ~ 2,
                               age >= 60 & age < 69 ~ 4,
                               age >= 70 & age < 79 ~ 6,
                               age >= 80 ~ 7),
         resp_rate_cat = case_when(flucats_question_numeric_value_respiratory_rate_250810003_value <20 & flucats_question_numeric_value_respiratory_rate_250810003_value > 0 ~ 0,
                                    flucats_question_numeric_value_respiratory_rate_271625008_value <20 & flucats_question_numeric_value_respiratory_rate_271625008_value > 0 ~ 0,
                                    flucats_question_numeric_value_respiratory_rate_86290005_value <20 & flucats_question_numeric_value_respiratory_rate_86290005_value > 0 ~ 0,
                                    flucats_question_numeric_value_respiratory_rate_927961000000102_value <20 & flucats_question_numeric_value_respiratory_rate_927961000000102_value > 0 ~ 0,
                                    
                                    flucats_question_numeric_value_respiratory_rate_250810003_value >=20 & flucats_question_numeric_value_respiratory_rate_250810003_value <30 ~ 1,
                                    flucats_question_numeric_value_respiratory_rate_271625008_value >=20 & flucats_question_numeric_value_respiratory_rate_271625008_value <30 ~ 1,
                                    flucats_question_numeric_value_respiratory_rate_86290005_value >=20 & flucats_question_numeric_value_respiratory_rate_86290005_value <30 ~ 1,
                                    flucats_question_numeric_value_respiratory_rate_927961000000102_value >=20 & flucats_question_numeric_value_respiratory_rate_927961000000102_value <30 ~ 1,
                                    
                                    flucats_question_numeric_value_respiratory_rate_250810003_value >=30 ~ 2,
                                    flucats_question_numeric_value_respiratory_rate_271625008_value >=30 ~ 2,
                                    flucats_question_numeric_value_respiratory_rate_86290005_value >=30 ~ 2,
                                    flucats_question_numeric_value_respiratory_rate_927961000000102_value >=30 ~ 2,
                                    
                                    TRUE ~ 0),
         
         sex_cat = case_when(sex == "M" ~ 1,
                             TRUE ~ 0),
         
         o2sat_cat = case_when(flucats_question_numeric_value_oxygen_saturation_431314004_value > 0 & flucats_question_numeric_value_oxygen_saturation_431314004_value <92 ~ 2,
                               flucats_question_numeric_value_oxygen_saturation_852651000000100_value > 0 & flucats_question_numeric_value_oxygen_saturation_852651000000100_value <92 ~ 2,
                               flucats_question_numeric_value_oxygen_saturation_852661000000102_value > 0 & flucats_question_numeric_value_oxygen_saturation_852661000000102_value <92 ~ 2,
                               flucats_question_numeric_value_oxygen_saturation_866661000000106_value > 0 & flucats_question_numeric_value_oxygen_saturation_866661000000106_value <92 ~ 2,
                               flucats_question_numeric_value_oxygen_saturation_866681000000102_value > 0 & flucats_question_numeric_value_oxygen_saturation_866681000000102_value <92 ~ 2,
                               flucats_question_numeric_value_oxygen_saturation_866701000000100_value > 0 & flucats_question_numeric_value_oxygen_saturation_866701000000100_value <92 ~ 2,
                               flucats_question_numeric_value_oxygen_saturation_852651000000100_value > 0 & flucats_question_numeric_value_oxygen_saturation_852651000000100_value <92 ~ 2,
                               flucats_question_numeric_value_oxygen_saturation_866721000000109_value > 0 & flucats_question_numeric_value_oxygen_saturation_866721000000109_value <92 ~ 2,
                               flucats_question_numeric_value_oxygen_saturation_927981000000106_value > 0 & flucats_question_numeric_value_oxygen_saturation_927981000000106_value <92 ~ 2,
                               
                               flucats_question_numeric_value_oxygen_saturation_431314004_value >= 92 ~ 0,
                               flucats_question_numeric_value_oxygen_saturation_852651000000100_value >=92 ~ 0,
                               flucats_question_numeric_value_oxygen_saturation_852661000000102_value >= 92 ~ 0,
                               flucats_question_numeric_value_oxygen_saturation_866661000000106_value >= 92 ~ 0,
                               flucats_question_numeric_value_oxygen_saturation_866681000000102_value >= 92 ~ 0,
                               flucats_question_numeric_value_oxygen_saturation_866701000000100_value >= 92 ~ 0,
                               flucats_question_numeric_value_oxygen_saturation_852651000000100_value >= 92 ~ 0,
                               flucats_question_numeric_value_oxygen_saturation_866721000000109_value >= 92 ~ 0,
                               flucats_question_numeric_value_oxygen_saturation_927981000000106_value >= 92 ~ 0,
                               
                               TRUE ~ 0))


df <- df %>% 
  mutate(comorb_cat = case_when(comorb_number == 0 ~ 0,
                                comorb_number == 1 ~ 1,
                                comorb_number >= 2 ~ 2))

df <- df %>% 
  mutate(isaric_tot = sum(age_categ + sex_cat + comorb_cat + resp_rate_cat + o2sat_cat))


#Check discrimination and calibration of the total ISARIC score
isaric_mod <- fit_model(hosp_24h ~ isaric_tot, data = df ,family = "binomial")
saveSummary(isaric_mod, "output/results/isaric/isaric_mod_hosp_24h.txt")

if (!is.null(isaric_mod)) {
  df$prediction_hosp <- predict(isaric_mod, df, type = "response")
  mroc_hosp <- roc(df$hosp_24h, df$prediction_hosp, plot = T)
  roc_data_hosp <- data.frame(
    fpr = 1 - mroc_hosp$specificities,
    sensitivity = mroc_hosp$sensitivities,
    thresholds = mroc_hosp$thresholds
  )
  write.csv(roc_data_hosp, "output/results/isaric/isaric_roc_data_hosp.csv")


  auc_hosp <- auc(mroc_hosp) #print value
  auc_hosp_ci <- ci.auc(mroc_hosp) #print value
  auc_hosp_ci_str <- paste0("AUC: ", round(auc_hosp_ci[2], 5), " (", round(auc_hosp_ci[1], 5), " - ", round(auc_hosp_ci[3], 5), ")")

  aucs_hosp <- data.frame(auc_hosp, auc_hosp_ci_str)
  colnames(aucs_hosp) <- c("auc", "ci")
  write.csv(aucs_hosp, "output/results/isaric/isaric_aucs_hosp_isaric.csv")

  generate_calibration_plot(data = df, obs = "hosp_24h", pred = "prediction_hosp", output_path = "output/results/isaric_calibration_summary_hosp.csv")



} else {
  write.csv(data.frame(), "output/results/isaric/isaric_roc_data_hosp.csv")
  write.csv(data.frame(), "output/results/isaric/isaric_aucs_hosp_isaric.csv")
  write.csv(data.frame(), "output/results/isaric/isaric_calibration_summary_hosp.csv")
}


isaric_mod_susp_cov <- fit_model(covid_hosp_susp ~ isaric_tot, data = df ,family = "binomial")
saveSummary(isaric_mod_susp_cov, "output/results/isaric/isaric_mod_susp_cov.txt")

if (!is.null(isaric_mod)) {
  df$prediction_hosp_covid_susp <- predict(isaric_mod_susp_cov, df, type = "response")
  mroc_hosp_covid <- roc(df$covid_hosp_susp, df$prediction_hosp_covid_susp, plot = T)
  roc_data_hosp_covid <- data.frame(
    fpr = 1 - mroc_hosp_covid$specificities,
    sensitivity = mroc_hosp_covid$sensitivities,
    thresholds = mroc_hosp_covid$thresholds
  )
  write.csv(roc_data_hosp_covid, "output/results/isaric/isaric_roc_data_hosp_susp_cov.csv")


  auc_hosp_covid <- auc(mroc_hosp_covid)
  auc_hosp_covid_ci <- ci.auc(mroc_hosp_covid) 
  auc_hosp_covid_ci_str <- paste0("AUC: ", round(auc_hosp_covid_ci[2], 5), " (", round(auc_hosp_covid_ci[1], 5), " - ", round(auc_hosp_covid_ci[3], 5), ")")

  aucs_hosp_covid <- data.frame(auc_hosp_covid_ci_str)
  colnames(aucs_hosp_covid) <- c("ci")
  write.csv(aucs_hosp_covid, "output/results/isaric/isaric_aucs_hosp_susp_cov_isaric.csv")


  generate_calibration_plot(data = df, obs = "covid_hosp_susp", pred = "prediction_hosp_covid_susp", output_path = "output/results/isaric_calibration_summary_hosp_susp_cov.csv")


} else {

  write.csv(data.frame(), "output/results/isaric/isaric_roc_data_hosp_susp_cov.csv")
  write.csv(data.frame(), "output/results/isaric/isaric_aucs_hosp_susp_cov_isaric.csv")
  write.csv(data.frame(), "output/results/isaric/isaric_calibration_summary_hosp_susp_cov.csv")
}




isaric_mod_prob_cov <- fit_model(covid_hosp_susp ~ isaric_tot, data = df ,family = "binomial")
saveSummary(isaric_mod_prob_cov, "output/results/isaric/isaric_mod_prob_cov.txt")

if (!is.null(isaric_mod)) {
  df$prediction_hosp_covid_prob <- predict(isaric_mod_prob_cov, df, type = "response")
  mroc_hosp_covid <- roc(df$covid_hosp_susp, df$prediction_hosp_covid_prob, plot = T)
  roc_data_hosp_covid <- data.frame(
    fpr = 1 - mroc_hosp_covid$specificities,
    sensitivity = mroc_hosp_covid$sensitivities,
    thresholds = mroc_hosp_covid$thresholds
  )
  write.csv(roc_data_hosp_covid, "output/results/isaric/isaric_roc_data_hosp_prob_cov.csv")


  auc_hosp_covid <- auc(mroc_hosp_covid)
  auc_hosp_covid_ci <- ci.auc(mroc_hosp_covid) 
  auc_hosp_covid_ci_str <- paste0("AUC: ", round(auc_hosp_covid_ci[2], 5), " (", round(auc_hosp_covid_ci[1], 5), " - ", round(auc_hosp_covid_ci[3], 5), ")")

  aucs_hosp_covid <- data.frame(auc_hosp_covid_ci_str)
  colnames(aucs_hosp_covid) <- c("ci")
  write.csv(aucs_hosp_covid, "output/results/isaric/isaric_aucs_hosp_prob_cov_isaric.csv")


  generate_calibration_plot(data = df, obs = "covid_hosp_prob", pred = "prediction_hosp_covid_prob", output_path = "output/results/isaric_calibration_summary_hosp_susp_cov.csv")


} else {

  write.csv(data.frame(), "output/results/isaric/isaric_roc_data_hosp_prob_cov.csv")
  write.csv(data.frame(), "output/results/isaric/isaric_aucs_hosp_prob_cov_isaric.csv")
  write.csv(data.frame(), "output/results/isaric/isaric_calibration_summary_hosp_prob_cov.csv")
}