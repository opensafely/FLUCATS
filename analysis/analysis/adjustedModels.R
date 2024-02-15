#adjusted models
#run after the flucatsValidation.R program has been run first

#We will be running glms modelling the association between individuals FluCATs criteria and outcomes adjusting for a set of covariates

############################
# ADJUSTED MODELS
############################
# We will only run this for hospital admissions due to low numbers for other outcomes
# Do the needed data prep for the confounders
# Add 'missing'category for obesity
df_adult <- df_adult %>% 
  mutate(obesity_mod <- if_else(is.na(obesity), 9, obesity))

df_adult <- df_adult %>% 
  rowwise() %>% 
  mutate(comorb_number <- sum(asthma, addisons_hypoadrenalism, chronic_heart_disease, chronic_respiratory_disease, ckd35_or_renal_disease, liver_disease,
                              diabetes, obesity, mental_illness, neurological_disorder, hypertension, pneumonia, immunosuppression_disorder, immunosuppression,
                              splenic_disease, na.rm = T))

df_child <- df_child %>% 
  mutate(obesity_mod <- if_else(is.na(obesity), 9, obesity))

df_child <- df_child %>% 
  rowwise() %>% 
  mutate(comorb_number <- sum(asthma, addisons_hypoadrenalism, chronic_heart_disease, chronic_respiratory_disease, ckd35_or_renal_disease, liver_disease,
                              diabetes, obesity, mental_illness, neurological_disorder, hypertension, pneumonia, immunosuppression_disorder, immunosuppression,
                              splenic_disease, na.rm = T))

#adults: any hospitalisation within 24 hours of GP assessment
model_hosp_a_adj <- glm( hosp_24h ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g +
                           age + sex + obesity_mod + comorb_number, data = df_adult, family = binomial)

table9_a_adj <- summary(model_hosp_a_adj)

model_hosp_a_adj_totalCAT <- glm( hosp_24h ~ total_CAT +
                                    age + sex + obesity_mod + comorb_number, data = df_adult, family = binomial)

table_totalCAT_adj <- summary(model_hosp_a_adj_totalCAT)


#child: any hospitalisation within 24 hours of GP assessment
model_hosp_c_adj <- glm( hosp_24h ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g +
                           age + sex + obesity_mod + comorb_number, data = df_child, family = binomial)

table9_c_adj <- summary(model_hosp_c_adj)

model_hosp_c_adj_totalCAT <- glm( hosp_24h ~ total_CAT +
                                    age + sex + obesity_mod + comorb_number, data = df_child, family = binomial)

table_totalCAT_adj <- summary(model_hosp_c_adj_totalCAT)

##########################################
# To Louis: Could you please replace the outcomes below with the COVID-19 hospitalisation variable that you have created?
##########################################
#adults: any hospitalisation within 24 hours of GP assessment
model_covidhosp_a_adj <- glm( hosp_24h ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g +
                                age + sex + obesity_mod + comorb_number, data = df_adult, family = binomial) #to change outcome before running

table9_a_adj_cov <- summary(model_covidhosp_a_adj)

model_covidhosp_a_adj_totalCAT <- glm( hosp_24h ~ total_CAT +
                                         age + sex + obesity_mod + comorb_number, data = df_adult, family = binomial) #to change outcome before running

table_totalCAT_adj_cov <- summary(model_covidhosp_a_adj_totalCAT)


#child: any hospitalisation within 24 hours of GP assessment
model_covidhosp_c_adj <- glm( hosp_24h ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g +
                                age + sex + obesity_mod + comorb_number, data = df_child, family = binomial) #to change outcome before running

table9_c_adj_covid <- summary(model_covidhosp_c_adj)

model_covidhosp_c_adj_totalCAT <- glm( hosp_24h ~ total_CAT +
                                         age + sex + obesity_mod + comorb_number, data = df_child, family = binomial) #to change outcome before running

table_totalCAT_adj_covid <- summary(model_covidhosp_c_adj_totalCAT)



