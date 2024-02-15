library(pROC)
library(predtools)
library(dplyr)
library(arsenal)

# Estimating discriminative ability of the modified ISARIC4C mortality score

#We will use the original df without the adult/child split as the ISARIC4C tool is meant for use in adults (18+ yrs)
#Redefining the primary outcomes. Can comment this out if already defined
#Primary outcomes: Hospital admission within 24 hours of GP assessment, and death 30 days from GP assessment date
df <- df %>% 
  filter(age>=18)

df <- df %>% 
  mutate(hosp_24h = case_when((flucats_template_date - hospital_admission_date)>=0 & (flucats_template_date - hospital_admission_date)<=1 ~ 1,
                               TRUE ~ 0),
         death_30d_pc = case_when((flucats_template_date - died_any_date)>=0 & (flucats_template_date - died_any_date)<=30 ~ 1,
                                   TRUE ~ 0),#Died due to any cause
         death_30d_ons = case_when((flucats_template_date - covid_related_death_date)>=0 & (flucats_template_date - covid_related_death_date)<=30 ~ 1,
                                    TRUE ~ 0))
df <- df %>% 
  mutate(covid_hosp = case_when(hosp_24h == 1 & (hosp_probable_covid ==1 | suspected covid==1) ~ 1,
                                        TRUE ~ 0))#hospitalised due to COVID-19


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
         
         sex_cat = case_when(sex = "M" ~ 1,
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
  rowwise() %>% 
  mutate(comorb_number = sum(asthma, addisons_hypoadrenalism, chronic_heart_disease, chronic_respiratory_disease, ckd35_or_renal_disease, liver_disease,
                              diabetes, obesity, mental_illness, neurological_disorder, hypertension, pneumonia, immunosuppression_disorder, immunosuppression,
                              splenic_disease, na.rm = T))

df <- df %>% 
  mutate(comorb_cat = case_when(comorb_number == 0 ~ 0,
                                comorb_number == 1 ~ 1,
                                comorb_number >= 2 ~ 2))

df <- df %>% 
  mutate(isaric_tot = age_categ + sex_cat + comorb_cat + resp_rate_cat + o2sat_cat)

#Check discrimination and calibration of the total ISARIC score
isaric_mod <- glm(hosp_24h ~ isaric_tot, data = df ,family = "binomial")
df$prediction_hosp <- predict.glm(hosp, df, type = "response")
mroc_hosp <- roc(df$hosp_24h, prediction_hosp, plot = T)#Save plot
auc_hosp <- auc(mroc_hosp) #print value
auc_hosp_ci <- ci.auc(mroc_hosp) #print value

#Repeat for covid-19 hospitalisation
isaric_mod <- glm(covid_hosp ~ isaric_tot, data = df ,family = "binomial")
df$prediction_hosp_covid <- predict.glm(hosp_covid, df, type = "response")
mroc_hosp_covid <- roc(df$covid_hosp, prediction_hosp_covid, plot = T)#Save plot
auc_hosp_covid <- auc(mroc_hosp_covid) #print value
auc_hosp_ci_covid <- ci.auc(mroc_hosp_covid) #print value

#Calibration
calibration_plot(data = df, obs = "hosp_24", pred = "prediction_hosp")
calibration_plot(data = df, obs = "covid_hosp", pred = "prediction_hosp_covid")



  