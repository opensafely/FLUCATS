#FLUCATS: Descriptive results 

library(readr)
library(dplyr)
library(ggplot2)
library(lubridate)

dir.create("output/results", showWarnings = FALSE)

#Import the 16 Flu-CATs monthly files
df <- read_csv("output/joined/full/input_all.csv", guess_max=10000) 


step <- c("Total number of unique patients: ", "Total number of encounters over the time period: ")

attrition <- data.frame(step) %>% 
  mutate(numbers = case_when(step == "Total number of unique patients: " ~ length(unique(df$patient_id)),
                             step == "Total number of encounters over the time period: " ~ nrow(df)))

# remove any rows in attrition where number column <=7
attrition <- attrition %>% 
  filter(numbers > 7)

# round all values in attrition 'numbers' column to the nearest 10
attrition$numbers <- round(attrition$numbers, -1)


#Save output
write.csv(attrition, "output/results/attrition.csv")#moderately sensitive: specify in YAML
rm(attrition)

##Reporting numbers by encounter NOT by patient as each encounter is considered a unique episode
#Generate an encounter ID for each row of the data (assuming that there is no duplication of rows)
df$encounter_id <- 1:nrow(df)


# Plot age band counts
# Step 1: Aggregate the data
age_band_counts <- df %>%
  count(age_band)

# Step 2: Filter out age bands with counts <= 7
filtered_age_band_counts <- age_band_counts %>%
  filter(n > 7)

# Step 3: Round counts of remaining age bands to the nearest 10
filtered_age_band_counts$n_rounded <- round(filtered_age_band_counts$n / 10) * 10

# Step 4: Plot the histogram with the filtered and rounded data
histogram_age <- ggplot(filtered_age_band_counts, aes(x = age_band, y = n_rounded)) +
  geom_bar(stat = "identity", fill = "blue", color = "red", alpha = 0.2) +
  labs(title = "Age Distribution of Cases", x = "Age Band", y = "Rounded Count") +
  theme(plot.title = element_text(color = "black", size = 14, face = "bold"))

# Step 5: Save the plot and underlaying data
png(filename="output/results/age_hist.png")#moderately sensitive: specify in YAML
plot(histogram_age)
dev.off()

# drop the non-rounded column
filtered_age_band_counts <- filtered_age_band_counts %>%
  select(-n)
write.csv(filtered_age_band_counts, "output/results/age_hist.csv")#moderately sensitive: specify in YAML

# convert flucats_template_date to date format
df$flucats_template_date <- as.Date(df$flucats_template_date, format = "%Y-%m-%d")

# Step 1: Aggregate the data by week
df <- df %>% 
  mutate(template_week = week(ymd(flucats_template_date)))

week_counts <- df %>%
  count(template_week)

# Step 2: Filter out weeks with counts <= 7
filtered_week_counts <- week_counts %>%
  filter(n > 7)

# Step 3: Round counts of remaining weeks to the nearest 10
filtered_week_counts$n_rounded <- round(filtered_week_counts$n / 10) * 10

# Step 4: Plot the histogram with the filtered and rounded data
flucats_week <- ggplot(filtered_week_counts, aes(x = template_week, y = n_rounded)) +
  geom_bar(stat = "identity", fill = "blue", color = "red", alpha = 0.2) +
  xlab("Week number (of calendar year)") +
  ylab("Count") +
  labs(title = "Week number (of calendar year)") +
  theme(plot.title = element_text(color = "black", size = 14, face = "bold"))

# Save the plot
png(filename="output/results/weekly_template.png")
plot(flucats_week)
dev.off()

# Step 5: Output the histogram data as a table
filtered_week_counts <- filtered_week_counts %>%
  select(-n)
write.csv(filtered_week_counts, "output/results/weekly_template.csv", row.names = FALSE)

library(purrr)

# for each column that starts with flucats_question but doesnt end in numeric_value print the 
# unique values
# df %>% 
#  select(starts_with("flucats_question")) %>%
# select(-ends_with("numeric_value"))%>%
#  map(~unique(.x))%>% 
#  map(~print(.x))


#df$flucats_question_35_code <- as.integer(df$flucats_question_35_code)
#df$flucats_question_30_86290005_code <- as.integer(df$flucats_question_30_86290005_code)
#df$flucats_question_30_431314004_code <- as.integer(df$flucats_question_30_431314004_code)
#df$flucats_question_7_code <- as.integer(df$flucats_question_7_code)
#df$flucats_question_36_code <- as.integer(df$flucats_question_36_code)
#df$flucats_question_37_162701007_code <- as.integer(df$flucats_question_37_162701007_code)
#df$flucats_question_37_162705003_code <- as.integer(df$flucats_question_37_162705003_code)
#df$flucats_question_37_268913004_code <- as.integer(df$flucats_question_37_268913004_code)
#df$flucats_question_37_162702000_code <- as.integer(df$flucats_question_37_162702000_code)
#df$flucats_question_37_162704004_code <- as.integer(df$flucats_question_37_162704004_code)


#FluCATs 1: Respiratory distress
df <- df %>% 
  mutate(flucats_a = case_when(flucats_question_severe_respiratory_distress_162892000 == 1 ~ "yes", 
                               TRUE ~ "no"),
         flucats_b = case_when(flucats_question_respiratory_rate_162916002 ==1 ~ "yes",   
                               
                               age <1 & flucats_question_numeric_value_respiratory_rate_250810003_value >=50 & flucats_question_numeric_value_respiratory_rate_250810003_value > 0 ~ "yes",
                               age >=1 & age <16 & flucats_question_numeric_value_respiratory_rate_250810003_value >=40 & flucats_question_numeric_value_respiratory_rate_250810003_value > 0 ~ "yes",
                               age >=16 & flucats_question_numeric_value_respiratory_rate_250810003_value >=30 & flucats_question_numeric_value_respiratory_rate_250810003_value > 0 ~ "yes",
                               #For question 30 we also have code 431314004 (peripheral O2 saturation)
                               
                               age <1 & flucats_question_numeric_value_respiratory_rate_271625008_value <50 & flucats_question_numeric_value_respiratory_rate_271625008_value > 0 ~ "yes",
                               age >=1 & age <16 & flucats_question_numeric_value_respiratory_rate_271625008_value <40 & flucats_question_numeric_value_respiratory_rate_271625008_value > 0 ~ "yes",
                               age >= 16 & flucats_question_numeric_value_respiratory_rate_271625008_value >=30 & flucats_question_numeric_value_respiratory_rate_271625008_value > 0 ~ "yes",
                               
                               age <1 & flucats_question_numeric_value_respiratory_rate_86290005_value <50 & flucats_question_numeric_value_respiratory_rate_86290005_value > 0 ~ "yes",
                               age >=1 & age <16 & flucats_question_numeric_value_respiratory_rate_86290005_value <40 & flucats_question_numeric_value_respiratory_rate_86290005_value > 0 ~ "yes",
                               age >= 16 & flucats_question_numeric_value_respiratory_rate_86290005_value >=30 & flucats_question_numeric_value_respiratory_rate_86290005_value > 0 ~ "yes",

                               age <1 & flucats_question_numeric_value_respiratory_rate_927961000000102_value <50 & flucats_question_numeric_value_respiratory_rate_927961000000102_value > 0 ~ "yes",
                               age >=1 & age <16 & flucats_question_numeric_value_respiratory_rate_927961000000102_value <40 & flucats_question_numeric_value_respiratory_rate_927961000000102_value > 0 ~ "yes",
                               age >=16 & flucats_question_numeric_value_respiratory_rate_927961000000102_value >=30 & flucats_question_numeric_value_respiratory_rate_927961000000102_value > 0 ~ "yes",
                               TRUE ~ "no"),
         flucats_c = case_when(flucats_question_numeric_value_oxygen_saturation_431314004_value > 0 & flucats_question_numeric_value_oxygen_saturation_431314004_value <=92 ~ "yes",
                               flucats_question_numeric_value_oxygen_saturation_852651000000100_value > 0 & flucats_question_numeric_value_oxygen_saturation_852651000000100_value <=92 ~ "yes",
                               flucats_question_numeric_value_oxygen_saturation_852661000000102_value > 0 & flucats_question_numeric_value_oxygen_saturation_852661000000102_value <=92 ~ "yes",
                               flucats_question_numeric_value_oxygen_saturation_866661000000106_value > 0 & flucats_question_numeric_value_oxygen_saturation_866661000000106_value <=92 ~ "yes",
                               flucats_question_numeric_value_oxygen_saturation_866681000000102_value > 0 & flucats_question_numeric_value_oxygen_saturation_866681000000102_value <=92 ~ "yes",
                               flucats_question_numeric_value_oxygen_saturation_866701000000100_value > 0 & flucats_question_numeric_value_oxygen_saturation_866701000000100_value <=92 ~ "yes",
                               flucats_question_numeric_value_oxygen_saturation_852651000000100_value > 0 & flucats_question_numeric_value_oxygen_saturation_852651000000100_value <=92 ~ "yes",
                               flucats_question_numeric_value_oxygen_saturation_866721000000109_value > 0 & flucats_question_numeric_value_oxygen_saturation_866721000000109_value <=92 ~ "yes",
                               flucats_question_numeric_value_oxygen_saturation_927981000000106_value > 0 & flucats_question_numeric_value_oxygen_saturation_927981000000106_value <=92 ~ "yes",

                               TRUE ~ "no"),
         
         
         flucats_d = case_when(flucats_question_respiratory_exhaustion_1023001 == 1 ~ "yes", 
                               flucats_question_respiratory_exhaustion_162896002 == 1 ~ "yes", 
                               flucats_question_respiratory_exhaustion_162900004 == 1 ~ "yes", 
                               flucats_question_respiratory_exhaustion_162901000 == 1 ~ "yes", 
                               flucats_question_respiratory_exhaustion_207053005 == 1 ~ "yes", 
                               flucats_question_respiratory_exhaustion_268927009 == 1 ~ "yes", 
                               TRUE ~ "no"),
         
         flucats_e = case_when(flucats_question_dehydration_or_shock_162685008 == 1 ~ "yes",
                               TRUE ~ "no"),
         
         flucats_f = case_when(flucats_question_altered_conscious_level_162702000 ==1 ~ "yes",
                               flucats_question_altered_conscious_level_162704004 ==1 ~ "yes",
                               flucats_question_altered_conscious_level_162705003 ==1 ~ "yes",
                               flucats_question_altered_conscious_level_268913004 ==1 ~ "yes",
                               TRUE ~ "no"),
                               
         flucats_g = case_when(flucats_question_causing_clinical_concern_162666005 ==1 ~ "yes",
                               flucats_question_clinical_concern_note_37331000000100 ==1 ~ "yes",
                               TRUE ~ "no"))



sex <- df[!duplicated(df$patient_id),]$sex
region <- df[!duplicated(df$patient_id),]$region

sex_table <- as.data.frame(table(sex))
sex_table <- sex_table %>%
  filter(Freq > 7) %>%
  mutate(Freq = round(Freq, -1))

region_table <- as.data.frame(table(region))
region_table <- region_table %>%
  filter(Freq > 7) %>%
  mutate(Freq = round(Freq, -1))

flucat_a_table <- as.data.frame(table(df$flucats_a))
flucat_a_table <- flucat_a_table %>%
  filter(Freq > 7) %>%
  mutate(Freq = round(Freq, -1))

flucat_b_table <- as.data.frame(table(df$flucats_b))
flucat_b_table <- flucat_b_table %>%
  filter(Freq > 7) %>%
  mutate(Freq = round(Freq, -1))

flucat_c_table <- as.data.frame(table(df$flucats_c))
flucat_c_table <- flucat_c_table %>%
  filter(Freq > 7) %>%
  mutate(Freq = round(Freq, -1))

flucat_d_table <- as.data.frame(table(df$flucats_d))
flucat_d_table <- flucat_d_table %>%
  filter(Freq > 7) %>%
  mutate(Freq = round(Freq, -1))

flucat_e_table <- as.data.frame(table(df$flucats_e))
flucat_e_table <- flucat_e_table %>%
  filter(Freq > 7) %>%
  mutate(Freq = round(Freq, -1))

flucat_f_table <- as.data.frame(table(df$flucats_f))
flucat_f_table <- flucat_f_table %>%
  filter(Freq > 7) %>%
  mutate(Freq = round(Freq, -1))

flucat_g_table <- as.data.frame(table(df$flucats_g))
flucat_g_table <- flucat_g_table %>%
  filter(Freq > 7) %>%
  mutate(Freq = round(Freq, -1))


write.csv(flucat_a_table, "output/results/flucat_a.csv")#moderately sensitive: specify in YAML
write.csv(flucat_b_table, "output/results/flucat_b.csv")
write.csv(flucat_c_table, "output/results/flucat_c.csv")
write.csv(flucat_d_table, "output/results/flucat_d.csv")
write.csv(flucat_e_table, "output/results/flucat_e.csv")
write.csv(flucat_f_table, "output/results/flucat_f.csv")
write.csv(flucat_g_table, "output/results/flucat_g.csv")

write.csv(sex_table, "output/results/sex_table.csv")
write.csv(region_table, "output/results/region_table.csv")



#Continue from flucats_descriptive_basic.R
#This script requires the flucats criteria variables created in the above program
library(dplyr)


#Basic demographic characteristics

total <- length(df$patient_id)
female <- length(df$sex[df$sex == "Female"])
f_perc <- round((female/total)*100, 2)
male <- length(df$sex[df$sex == "Male"])
m_perc <- round((male/total)*100, 2)

# set anyone under 16 to be a child
df <- df %>% 
  mutate(category = case_when(age < 16 ~ "Child",
                              TRUE ~ "Adult"))

child <- length(df$category[df$category == "Child"])
c_perc <- round((child/total)*100, 2)
adult <- length(df$category[df$category == "Adult"])
a_perc <- round((adult/total)*100, 2)

hospital <- length(df$hospital_admission[df$hospital_admission == 1])
h_perc <- round((hospital/total)*100, 2)

demographics <- data.frame(f_perc, m_perc, c_perc, a_perc, h_perc)
write.csv(demographics, "output/results/demographics.csv")


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

