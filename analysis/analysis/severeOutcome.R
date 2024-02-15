library(arsenal)
library(pROC)
library(predtools)
library(dplyr)

##FluCATs: severe outcome (composite of COVID-19 death/ICU admission)
#We can only only attempt this for adults as <7 events for both outcomes in children

##Define outcomes
#To run this after the flucatsValidation.R program has been run. It relies on the death and icu variables already having been created

#Define the 'severe outcomes' composite outcome
df <- df %>% 
  mutate(severe_outcomes = case_when(covid_death_30d_ons == 1| icu_adm ==1 ~ 1,
                                     TRUE ~ 0))# composite severe outcome

#Various tables
#Table 1: demographics by severe outcome
tab1_so <- tableby(includeNA(severe_outcomes) ~ age + includeNA(sex) + bmi + bmi_primis + includeNA(asthma) + includeNA(addisons_hypoadrenalism)
                + includeNA(chronic_heart_disease) + includeNA(chronic_respiratory_disease) + includeNA(ckd_primis_stage) + includeNA(renal_disease)
                + includeNA(ckd35_or_renal_disease) + includeNA(ckd_os) + includeNA(liver_disease) + includeNA(pregnant)
                + includeNA(diabetes) + includeNA(gestational_diabetes) + includeNA(obesity) + includeNA(mental_illness)
                + includeNA(neurological_disorder) + includeNA(hypertension) + includeNA(pneumonia) + includeNA(immunosuppression_disorder)
                + includeNA(immunosuppression_chemo) + includeNA(splenic_disease) + includeNA(shield) + includeNA(nonshield)
                + includeNA(statins) + includeNA(splenic_disease) + includeNA(shield) + includeNA(nonshield)
                + includeNA(covadm1) + includeNA(covadm2) + includeNA(pfd1rx) + includeNA(pfd2rx)
                + includeNA(azd1rx) + includeNA(azd2rx) + includeNA(covrx1) + includeNA(covrx2)
                + includeNA(ethnicity_opensafely) + includeNA(ethnicity) + includeNA(age_band) + includeNA(homeless)
                + includeNA(residential_care) + includeNA(region) + includeNA() + includeNA(imdQ5)
                , data = df, test=FALSE, total=TRUE)
table1_so <- summary(tab1_so, text = T) #Need to print this summary output

#Define the adult population. We don't have enough events to be able to run this for children
df_adult <- df %>% 
  filter(age>=16)

df_adult <- df_adult %>% 
  mutate(total_CAT = flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g)

tab5_so <- tableby(includeNA(severe_outcome) ~ includeNA(total_CAT) + includeNA(flucats_a) + includeNA(flucats_b) + includeNA(flucats_c) + includeNA(flucats_d) + includeNA(flucats_e) + includeNA(flucats_f) + includeNA(flucats_g), data = df_adult, test=FALSE, total=TRUE)
tab5_so <- summary(tab5_so, text = T)

model_hosp_so <- glm( severe_outcome ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_adult, family = binomial)
table9_so <- summary(model_hosp_so)

#Adjusted models for severe outcomes
df_adult <- df_adult %>% 
  mutate(obesity_mod <- if_else(is.na(obesity), 9, obesity))

df_adult <- df_adult %>% 
  rowwise() %>% 
  mutate(comorb_number <- sum(asthma, addisons_hypoadrenalism, chronic_heart_disease, chronic_respiratory_disease, ckd35_or_renal_disease, liver_disease,
                              diabetes, obesity, mental_illness, neurological_disorder, hypertension, pneumonia, immunosuppression_disorder, immunosuppression,
                              splenic_disease, na.rm = T))

model_so_a_adj <- glm( severe_outcome ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g +
                           age + sex + obesity_mod + comorb_number, data = df_adult, family = binomial)

table9_so_adj <- summary(model_so_a_adj)

model_so_a_adj_totalCAT <- glm( severe_outcome ~ total_CAT +
                                    age + sex + obesity_mod + comorb_number, data = df_adult, family = binomial)
table_totalCAT_adj_so <- summary(model_so_a_adj_totalCAT)


###Discrimination
severe_o <- glm(severe_outcome ~ total_CAT, data = df_adult ,family = "binomial")
df_adult$prediction_severe_outcome <- predict.glm(severe_outcome, df_adult, type = "response")
mroc_severe_outcome <- roc(df_adult$severe_outcome, df_adult$prediction_severe_outcome, plot = T)#Save plot
auc_so_adult <- auc(mroc_severe_outcome) #print value
auc_so_ci <- ci.auc(mroc_severe_outcome) #print value

#calibration plot
calibration_plot(data = df_adult, obs = "severe_outcome", pred = "prediction_severe_outcome")

