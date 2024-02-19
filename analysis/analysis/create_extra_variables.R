library(readr)
library(dplyr)
library(arrow)

df <- read_csv("output/joined/full/input_all.csv", guess_max=10000) 


##Reporting numbers by encounter NOT by patient as each encounter is considered a unique episode
#Generate an encounter ID for each row of the data (assuming that there is no duplication of rows)
df$encounter_id <- 1:nrow(df)

# set anyone under 16 to be a child
df <- df %>% 
  mutate(category = case_when(age < 16 ~ "Child",
                              TRUE ~ "Adult"))

df$flucats_template_date <- as.Date(df$flucats_template_date, format = "%Y-%m-%d")

# Define flucats criteria

df <- df %>% 
  mutate(flucats_a = case_when(flucats_question_severe_respiratory_distress_162892000 == 1 ~ 1, 
                               TRUE ~ 0),
         flucats_b = case_when(flucats_question_respiratory_rate_162916002 ==1 ~ 1,   
                               
                               age <1 & flucats_question_numeric_value_respiratory_rate_250810003_value >=50 & flucats_question_numeric_value_respiratory_rate_250810003_value > 0 ~ 1,
                               age >=1 & age <16 & flucats_question_numeric_value_respiratory_rate_250810003_value >=40 & flucats_question_numeric_value_respiratory_rate_250810003_value > 0 ~ 1,
                               age >=16 & flucats_question_numeric_value_respiratory_rate_250810003_value >=30 & flucats_question_numeric_value_respiratory_rate_250810003_value > 0 ~ 1,
                               #For question 30 we also have code 431314004 (peripheral O2 saturation)
                               
                               age <1 & flucats_question_numeric_value_respiratory_rate_271625008_value <50 & flucats_question_numeric_value_respiratory_rate_271625008_value > 0 ~ 1,
                               age >=1 & age <16 & flucats_question_numeric_value_respiratory_rate_271625008_value <40 & flucats_question_numeric_value_respiratory_rate_271625008_value > 0 ~ 1,
                               age >= 16 & flucats_question_numeric_value_respiratory_rate_271625008_value >=30 & flucats_question_numeric_value_respiratory_rate_271625008_value > 0 ~ 1,
                               
                               age <1 & flucats_question_numeric_value_respiratory_rate_86290005_value <50 & flucats_question_numeric_value_respiratory_rate_86290005_value > 0 ~ 1,
                               age >=1 & age <16 & flucats_question_numeric_value_respiratory_rate_86290005_value <40 & flucats_question_numeric_value_respiratory_rate_86290005_value > 0 ~ 1,
                               age >= 16 & flucats_question_numeric_value_respiratory_rate_86290005_value >=30 & flucats_question_numeric_value_respiratory_rate_86290005_value > 0 ~ 1,

                               age <1 & flucats_question_numeric_value_respiratory_rate_927961000000102_value <50 & flucats_question_numeric_value_respiratory_rate_927961000000102_value > 0 ~ 1,
                               age >=1 & age <16 & flucats_question_numeric_value_respiratory_rate_927961000000102_value <40 & flucats_question_numeric_value_respiratory_rate_927961000000102_value > 0 ~ 1,
                               age >=16 & flucats_question_numeric_value_respiratory_rate_927961000000102_value >=30 & flucats_question_numeric_value_respiratory_rate_927961000000102_value > 0 ~ 1,
                               TRUE ~ 0),
         flucats_c = case_when(flucats_question_numeric_value_oxygen_saturation_431314004_value > 0 & flucats_question_numeric_value_oxygen_saturation_431314004_value <=92 ~ 1,
                               flucats_question_numeric_value_oxygen_saturation_852651000000100_value > 0 & flucats_question_numeric_value_oxygen_saturation_852651000000100_value <=92 ~ 1,
                               flucats_question_numeric_value_oxygen_saturation_852661000000102_value > 0 & flucats_question_numeric_value_oxygen_saturation_852661000000102_value <=92 ~ 1,
                               flucats_question_numeric_value_oxygen_saturation_866661000000106_value > 0 & flucats_question_numeric_value_oxygen_saturation_866661000000106_value <=92 ~ 1,
                               flucats_question_numeric_value_oxygen_saturation_866681000000102_value > 0 & flucats_question_numeric_value_oxygen_saturation_866681000000102_value <=92 ~ 1,
                               flucats_question_numeric_value_oxygen_saturation_866701000000100_value > 0 & flucats_question_numeric_value_oxygen_saturation_866701000000100_value <=92 ~ 1,
                               flucats_question_numeric_value_oxygen_saturation_852651000000100_value > 0 & flucats_question_numeric_value_oxygen_saturation_852651000000100_value <=92 ~ 1,
                               flucats_question_numeric_value_oxygen_saturation_866721000000109_value > 0 & flucats_question_numeric_value_oxygen_saturation_866721000000109_value <=92 ~ 1,
                               flucats_question_numeric_value_oxygen_saturation_927981000000106_value > 0 & flucats_question_numeric_value_oxygen_saturation_927981000000106_value <=92 ~ 1,

                               TRUE ~ 0),
         
         
         flucats_d = case_when(flucats_question_respiratory_exhaustion_1023001 == 1 ~ 1, 
                               flucats_question_respiratory_exhaustion_162896002 == 1 ~ 1, 
                               flucats_question_respiratory_exhaustion_162900004 == 1 ~ 1, 
                               flucats_question_respiratory_exhaustion_162901000 == 1 ~ 1, 
                               flucats_question_respiratory_exhaustion_207053005 == 1 ~ 1, 
                               flucats_question_respiratory_exhaustion_268927009 == 1 ~ 1, 
                               TRUE ~ 0),
         
         flucats_e = case_when(flucats_question_dehydration_or_shock_162685008 == 1 ~ 1,
                               TRUE ~ 0),
         
         flucats_f = case_when(flucats_question_altered_conscious_level_162702000 ==1 ~ 1,
                               flucats_question_altered_conscious_level_162704004 ==1 ~ 1,
                               flucats_question_altered_conscious_level_162705003 ==1 ~ 1,
                               flucats_question_altered_conscious_level_268913004 ==1 ~ 1,
                               TRUE ~ 0),
                               
         flucats_g = case_when(flucats_question_causing_clinical_concern_162666005 ==1 ~ 1,
                               flucats_question_clinical_concern_note_37331000000100 ==1 ~ 1,
                               TRUE ~ 0))

# create new var - total_CAT - this is the sum of all the flucats
df <- df %>% 
  mutate(total_CAT = flucats_a + flucats_b + flucats_c + flucats_d + flucats_e + flucats_f + flucats_g)

columns_to_factor <- c("flucats_a", "flucats_b", "flucats_c", "flucats_d", "flucats_e", "flucats_f", "flucats_g", "total_CAT")

df <- df %>%
  mutate(across(all_of(columns_to_factor), as.factor))
  
# Define suspected and probable COVID-19
df <- df %>% 
    mutate(suspected_covid = case_when(rowSums(select(., starts_with("flucats_question_suspected_covid"))) > 0 ~ 1,
                                        TRUE ~ 0),
            probable_covid = case_when(rowSums(select(., starts_with("flucats_question_probable_covid"))) > 0 ~ 1,
                                       TRUE ~ 0))

##Define outcomes
#Primary outcomes: Hospital admission within 24 hours of GP assessment, and death 30 days from GP assessment date


df <- df %>% 
  mutate(hosp_24h = case_when(
    (flucats_template_date - hospital_admission_date) >= 0 & (flucats_template_date - hospital_admission_date) <= 1 ~ 1,
    TRUE ~ 0
    ),
    hosp_24h_susp_cov = case_when(
    (flucats_template_date - hospital_admission_date) >= 0 & (flucats_template_date - hospital_admission_date) <= 1 & (suspected_covid==1) ~ 1,
    TRUE ~ 0
    ),
    hosp_24h_prob_cov = case_when(
    (flucats_template_date - hospital_admission_date) >= 0 & (flucats_template_date - hospital_admission_date) <= 1 & (probable_covid==1) ~ 1,
    TRUE ~ 0
    ),
    
         death_30d_pc = case_when((flucats_template_date - died_any_date_pc) >= 0 & (flucats_template_date - died_any_date_pc) <= 30 ~ 1,
                                TRUE ~ 0), # Died due to any cause (primary care record)
         death_30d_ons = case_when((flucats_template_date - died_any_date) >= 0 & (flucats_template_date - died_any_date) <= 30 ~ 1,
                                   TRUE ~ 0), # Died due to any cause (ons deaths record)
         covid_death_30d_ons = case_when((flucats_template_date - covid_related_death_date) >= 0 & (flucats_template_date - covid_related_death_date) <= 30 ~ 1,
                                   TRUE ~ 0) # Died due to COVID-19 (ons deaths record)
         )
#Secondary outcomes: ICU admission during primary hospital admission, LoS
df <- df %>% 
  mutate(icu_adm = case_when(hosp_24h == 1 & icu_admission == 1 & (icu_admission_date >= hospital_admission_date) ~ 1,
                              TRUE ~ 0))


#Define the 'severe outcomes' composite outcome
df <- df %>% 
  mutate(severe_outcome = case_when(covid_death_30d_ons == 1| icu_adm ==1 ~ 1,
                                     TRUE ~ 0))# composite severe outcome

# format dates

df <- df %>% 
  mutate(flucats_template_date = as.Date(flucats_template_date, format = "%m/%d/%y"),
         bmi_date_measured = as.Date(bmi_date_measured, format = "%m/%d/%y"),
         hospital_admission_date = as.Date(hospital_admission_date, format = "%m/%d/%y"),
         icu_admission_date = as.Date(icu_admission_date, format = "%m/%d/%y"),
         died_any_date_pc = as.Date(died_any_date_pc, format = "%m/%d/%y"),
         covadm1_dat = as.Date(covadm1_dat, format = "%m/%d/%y"),
         covadm2_dat = as.Date(covadm2_dat, format = "%m/%d/%y"),
         pfd1rx_dat = as.Date(pfd1rx_dat, format = "%m/%d/%y"),
         pfd2rx_dat = as.Date(pfd2rx_dat, format = "%m/%d/%y"),
         azd1rx_dat = as.Date(azd1rx_dat, format = "%m/%d/%y"),
         azd2rx_dat = as.Date(azd2rx_dat, format = "%m/%d/%y"),
         covrx1_dat = as.Date(covrx1_dat, format = "%m/%d/%y"),
         covrx2_dat = as.Date(covrx2_dat, format = "%m/%d/%y"))

# convert age to numeric
df$age <- as.numeric(df$age)

# List of columns to convert to factors
columns_to_factor <- c("asthma", "addisons_hypoadrenalism", "chronic_heart_disease",
                       "chronic_respiratory_disease", "ckd_primis_stage", "renal_disease",
                       "ckd35_or_renal_disease", "ckd_os", "liver_disease", "pregnant",
                       "diabetes", "gestational_diabetes", "obesity", "mental_illness",
                       "neurological_disorder", "hypertension", "pneumonia",
                       "immunosuppression_disorder", "immunosuppression_chemo",
                       "splenic_disease", "shield", "nonshield", "statins", "covadm1",
                       "covadm2", "pfd1rx", "pfd2rx", "azd1rx", "azd2rx", "covrx1", 
                       "covrx2", "ethnicity_opensafely", "ethnicity", "homeless",
                       "residential_care", "imdQ5")


# Convert all specified columns to factors
df <- df %>%
  mutate(across(all_of(columns_to_factor), as.factor))

# for numeric variables, set 0 to NA
df$bmi <- ifelse(df$bmi == 0, NA, df$bmi)
df$bmi_primis <- ifelse(df$bmi_primis == 0, NA, df$bmi_primis)

df$bmi <- ifelse(df$bmi > 50, NA, df$bmi)
df$bmi_primis <- ifelse(df$bmi_primis > 50, NA, df$bmi_primis)


# get comorbitity number
df <- df %>%
  mutate(obesity = as.numeric(as.character(obesity)),
         obesity_mod = if_else(is.na(obesity), 9, obesity),
         obesity_mod = as.factor(obesity_mod))


comorbidity_vars <- c("asthma", "addisons_hypoadrenalism", "chronic_heart_disease", "chronic_respiratory_disease", "ckd35_or_renal_disease", "liver_disease", "obesity", "obesity_mod",
                      "diabetes", "mental_illness", "neurological_disorder", "hypertension", "pneumonia", "immunosuppression_disorder", "immunosuppression_chemo",
                      "splenic_disease")
# comorbidity_vars - these need to be converte to numeric
df <- df %>% 
  mutate(across(all_of(comorbidity_vars), as.numeric))

df <- df %>% 
  rowwise() %>% 
  mutate(comorb_number = sum(asthma, addisons_hypoadrenalism, chronic_heart_disease, chronic_respiratory_disease, ckd35_or_renal_disease, liver_disease,
                              diabetes, obesity, mental_illness, neurological_disorder, hypertension, pneumonia, immunosuppression_disorder, immunosuppression_chemo,
                              splenic_disease, na.rm = T))

# convert comoridity vars back
df <- df %>% 
  mutate(across(all_of(comorbidity_vars), as.factor))

df$covid_hosp_susp <- ifelse(df$suspected_covid == 1 & df$hosp_24h == 1, 1, 0)
df$covid_hosp_prob <- ifelse(df$probable_covid == 1 & df$hosp_24h == 1, 1, 0)

# save the data as feather
write_feather(df, "output/joined/full/input_all_extra_vars.feather") 