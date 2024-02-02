#Continue from flucats_descriptive_basic.R
#This script requires the flucats criteria variables created in the above program
library(dplyr)
#Basic demographic characteristics

female <- length(df$gender[df$gender == "Female"])
f_perc <- round((female/total)*100, 2)
male <- length(df$gender[df$gender == "Male"])
m_perc <- round((male/total)*100, 2)

child <- length(df$category[df$category == "Child"])
c_perc <- round((child/total)*100, 2)
adult <- length(df$category[df$category == "Adult"])
a_perc <- round((adult/total)*100, 2)

hospital <- length(df$emergadm_term[df$emergadm_term != ""])
h_perc <- round((hospital/total)*100, 2)

#Could we have the values for the above printed as well please?

#Assumes the date variables are saved in date format
#If not, uncomment the code below
# df <- df %>% 
#   mutate(flucats_template_date = as.Date(flucats_template_date, format = "%m/%d/%y"),
#          bmi_date_measured = as.Date(bmi_date_measured, format = "%m/%d/%y"),
#          icu_admission_date = as.Date(icu_admission_date, format = "%m/%d/%y"),
#          died_any_date_pc = as.Date(died_any_date_pc, format = "%m/%d/%y"),
#          covadm1_dat = as.Date(covadm1_dat, format = "%m/%d/%y"),
#          covadm2_dat = as.Date(covadm2_dat, format = "%m/%d/%y"),
#          pfd1rx_dat = as.Date(pfd1rx_dat, format = "%m/%d/%y"),
#          pfd2rx_dat = as.Date(pfd2rx_dat, format = "%m/%d/%y"),
#          azd1rx_dat = as.Date(azd1rx_dat, format = "%m/%d/%y"),
#          azd2rx_dat = as.Date(azd2rx_dat, format = "%m/%d/%y"),
#          covrx1_dat = as.Date(covrx1_dat, format = "%m/%d/%y"),
#          covrx2_dat = as.Date(covrx2_dat, format = "%m/%d/%y"))

##Define outcomes
#Primary outcomes: Hospital admission within 24 hours of GP assessment, and death 30 days from GP assessment date
df <- df %>% 
  mutate(hosp_24h <- case_when((flucats_template_date - hospital_admission_date)>=0 & (flucats_template_date - hospital_admission_date)<=1 ~ 1,
                               TRUE ~ 0),
         death_30d_pc <- case_when((flucats_template_date - died_any_date)>=0 & (flucats_template_date - died_any_date)<=30 ~ 1,
                                TRUE ~ 0),#Died due to any cause
         death_30d_ons <- case_when((flucats_template_date - covid_related_death_date)>=0 & (flucats_template_date - covid_related_death_date)<=30 ~ 1,
                                   TRUE ~ 0))#Died due to COVID-19
#Secondary outcomes: ICU admission during primary hospital admission, LoS
df <- df %>% 
  mutate(icu_adm <- case_when(hosp_24h == 1 & icu_admission == 1 & (icu_admission >= hospital_admission_date) ~ 1,
                              TRUE ~ 0))

#Various tables
#Table 1: demographics by hospitalisation
tab1 <- tableby(includeNA(hosp_24h) ~ age + includeNA(sex) + bmi + bmi_primis + includeNA(asthma) + includeNA(addisons_hypoadrenalism)
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
table1 <- summary(tab1, text = T) #Need to print this summary output

#Table 2: demographics by death within 30 days of GP consultation (primary care record)
tab2 <- tableby(includeNA(death_30d_pc) ~ age + includeNA(sex) + bmi + bmi_primis + includeNA(asthma) + includeNA(addisons_hypoadrenalism)
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
table2 <- summary(tab2, text = T) #Need to print this summary output

#Table 3: demographics by death within 30 days of GP consultation (ONS record)
tab3 <- tableby(includeNA(death_30d_ons) ~ age + includeNA(sex) + bmi + bmi_primis + includeNA(asthma) + includeNA(addisons_hypoadrenalism)
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
table3 <- summary(tab3, text = T) #Need to print this summary output


#Table 4: demographics by ICU admission
tab4 <- tableby(includeNA(icu_adm) ~ age + includeNA(sex) + bmi + bmi_primis + includeNA(asthma) + includeNA(addisons_hypoadrenalism)
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
table4 <- summary(tab4, text = T) #Need to print this summary output

#######################################################################
#Repeat of above but for each FluCATs criteria and total CATs score

#Generate total CATs score for each encounter
#Need to stratify by 'adult'/'child' status

df_child <- df %>% 
  filter(age<16)

df_adult <- df %>% 
  filter(age>=16)

df <- df %>% 
  mutate(total_CAT = flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g)

#Table 5-8: flucats criteria by outcome 
#CHILD
tab5_c <- tableby(includeNA(hosp_24h) ~ includeNA(total_CAT) + includeNA(flucats_a) + includeNA(flucats_b) + includeNA(flucats_c) + includeNA(flucats_d) + includeNA(flucats_e) + includeNA(flucats_f) + includeNA(flucats_g), data = df_child, test=FALSE, total=TRUE)
table5_c <- summary(tab5_c, text = T)

tab6_c <- tableby(includeNA(death_30d_pc) ~ includeNA(total_CAT) + includeNA(flucats_a) + includeNA(flucats_b) + includeNA(flucats_c) + includeNA(flucats_d) + includeNA(flucats_e) + includeNA(flucats_f) + includeNA(flucats_g), data = df_child, test=FALSE, total=TRUE)
table6_c <- summary(tab6_c, text = T)

tab7_c <- tableby(includeNA(death_30d_ons) ~ includeNA(total_CAT) + includeNA(flucats_a) + includeNA(flucats_b) + includeNA(flucats_c) + includeNA(flucats_d) + includeNA(flucats_e) + includeNA(flucats_f) + includeNA(flucats_g), data = df_child, test=FALSE, total=TRUE)
table7_c <- summary(tab7_c, text = T)

tab8_c <- tableby(includeNA(icu_adm) ~ includeNA(total_CAT) + includeNA(flucats_a) + includeNA(flucats_b) + includeNA(flucats_c) + includeNA(flucats_d) + includeNA(flucats_e) + includeNA(flucats_f) + includeNA(flucats_g), data = df_child, test=FALSE, total=TRUE)
table8_c <- summary(tab8_c, text = T)

#Table 5-8: flucats criteria by outcome 
#ADULT
tab5_a <- tableby(includeNA(hosp_24h) ~ includeNA(total_CAT) + includeNA(flucats_a) + includeNA(flucats_b) + includeNA(flucats_c) + includeNA(flucats_d) + includeNA(flucats_e) + includeNA(flucats_f) + includeNA(flucats_g), data = df_adult, test=FALSE, total=TRUE)
table5_a <- summary(tab5_a, text = T)

tab6_a <- tableby(includeNA(death_30d_pc) ~ includeNA(total_CAT) + includeNA(flucats_a) + includeNA(flucats_b) + includeNA(flucats_c) + includeNA(flucats_d) + includeNA(flucats_e) + includeNA(flucats_f) + includeNA(flucats_g), data = df_adult, test=FALSE, total=TRUE)
table6_a <- summary(tab6_a, text = T)

tab7_a <- tableby(includeNA(death_30d_ons) ~ includeNA(total_CAT) + includeNA(flucats_a) + includeNA(flucats_b) + includeNA(flucats_c) + includeNA(flucats_d) + includeNA(flucats_e) + includeNA(flucats_f) + includeNA(flucats_g), data = df_adult, test=FALSE, total=TRUE)
table7_a <- summary(tab7_a, text = T)

tab8_a <- tableby(includeNA(icu_adm) ~ includeNA(total_CAT) + includeNA(flucats_a) + includeNA(flucats_b) + includeNA(flucats_c) + includeNA(flucats_d) + includeNA(flucats_e) + includeNA(flucats_f) + includeNA(flucats_g), data = df_adult, test=FALSE, total=TRUE)
table8_a <- summary(tab8_a, text = T)

#######################################################################

#Logistic regression for each outcome where FluCATs criteria are modelled independently
#CHILD
model_hosp_c <- glm( hosp_24h ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_child, family = binomial)
table9_c <- summary(model_hosp_c)

model_death_pc_c <- glm(death_30d_pc ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_child, family = binomial)
table10_c <- summary(model_death_pc_c)

model_death_ons_c <- glm(death_30d_ons ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_child, family = binomial)
table11_c <- summary(model_death_ons_c)

model_icu_c <- glm(icu_adm ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_child, family = binomial)
table12_c <- summary(model_icu_c)

#ADULT
model_hosp_a <- glm( hosp_24h ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_adult, family = binomial)
table9_a <- summary(model_hosp_a)

model_death_pc_a <- glm(death_30d_pc ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_adult, family = binomial)
table10_a <- summary(model_death_pc_a)

model_death_ons_a <- glm(death_30d_ons ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_adult, family = binomial)
table11_a <- summary(model_death_ons_a)

model_icu_a <- glm(icu_adm ~ flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g, data = df_adult, family = binomial)
table12_a <- summary(model_icu_a)

