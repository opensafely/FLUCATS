#FLUCATS: Descriptive results 

library(readr)
library(dplyr)
library(ggplot2)
library(lubridate)


#Import the 16 Flu-CATs monthly files
df <- read_csv("output/input_all.csv.gz") %>% select(sex, age, patient_id, flucats_template, flucats_template_date, flucats_question_35_code, flucats_question_30_86290005_code, flucats_question_30_86290005_numeric_value, flucats_question_30_431314004_code, flucats_question_30_431314004_numeric_value, flucats_question_7_code, flucats_question_36_code, flucats_question_37_162701007_code, flucats_question_37_162705003_code, flucats_question_37_268913004_code, flucats_question_37_162702000_code, flucats_question_37_162704004_code, region) %>% filter(flucats_template==1)


step <- c("Total number of unique patients: ", "Total number of encounters over the time period: ")

attrition <- data.frame(step) %>% 
  mutate(numbers = case_when(step == "Total number of unique patients: " ~ length(unique(df$patient_id)),
                           step == "Total number of encounters over the time period: " ~ nrow(df)))

#Save output
write.csv(attrition, "output/attrition.csv")#moderately sensitive: specify in YAML
rm(attrition)

##Reporting numbers by encounter NOT by patient as each encounter is considered a unique episode
#Generate an encounter ID for each row of the data (assuming that there is no duplication of rows)
df$encounter_id <- 1:nrow(df)

#Histogram of age
histogram_age <- qplot(
  df$age,
  main = "Age distribution of cases",
  geom = "histogram",
  binwidth = 5,
  xlab = "Age (years)",
  ylab = "Frequency",
  fill = I("blue"),
  col = I("red"),
  alpha = I(.2),
  xlim = c(0, 120)
)

histogram_age <- histogram_age + labs(title = "Age distribution of cases") + 
  theme(plot.title = element_text(color = "black", size = 14, face = "bold")) +
  theme(plot.title = element_text(hjust = 0.5))

png(filename="output/age_hist.png")#moderately sensitive: specify in YAML
plot(histogram_age)
dev.off()

# convert flucats_template_date to date format
df$flucats_template_date <- as.Date(df$flucats_template_date, format = "%Y-%m-%d")

#Plot weekly distribution of FLU-CATs encounters
df <- df %>% 
  mutate(template_week = week(flucats_template_date))

flucats_week <- ggplot(df, aes(x = template_week)) +
  geom_bar(fill = I("blue"),
           col = I("red"),
           alpha = I(.2)) + xlab("Week number (of calendar year)") + labs(title = "Week number (of calendar year)") +
  theme(plot.title = element_text(color = "black", size = 14, face = "bold")) +
  theme(plot.title = element_text(hjust = 0.5))
png(filename="output/weekly_template.png")#moderately sensitive: specify in YAML
plot(flucats_week)
dev.off()

# cast all flucats question code columns to ints using a loop
df$flucats_question_35_code <- as.integer(df$flucats_question_35_code)
df$flucats_question_30_86290005_code <- as.integer(df$flucats_question_30_86290005_code)
df$flucats_question_30_431314004_code <- as.integer(df$flucats_question_30_431314004_code)
df$flucats_question_7_code <- as.integer(df$flucats_question_7_code)
df$flucats_question_36_code <- as.integer(df$flucats_question_36_code)
df$flucats_question_37_162701007_code <- as.integer(df$flucats_question_37_162701007_code)
df$flucats_question_37_162705003_code <- as.integer(df$flucats_question_37_162705003_code)
df$flucats_question_37_268913004_code <- as.integer(df$flucats_question_37_268913004_code)
df$flucats_question_37_162702000_code <- as.integer(df$flucats_question_37_162702000_code)
df$flucats_question_37_162704004_code <- as.integer(df$flucats_question_37_162704004_code)


#FluCATs 1: Respiratory distress
df <- df %>% 
  mutate(flucats_a = case_when(flucats_question_35_code == 162892000 ~ "respiratory distress",
                               flucats_question_35_code == 162889004 ~ "normal respiration",
                               is.na(flucats_question_35_code) ~"NA",
                                     TRUE ~ "other"),
         flucats_b = case_when(flucats_question_30_86290005_code == 86290005 & age <1 & flucats_question_30_86290005_numeric_value >=50 & !is.na(flucats_question_30_86290005_numeric_value)~ "increased RR",
                               flucats_question_30_86290005_code == 86290005 & age >=1 & age <16 & flucats_question_30_86290005_numeric_value >=40 & !is.na(flucats_question_30_86290005_numeric_value)~ "increased RR",
                               flucats_question_30_86290005_code == 86290005 & age >=16 & flucats_question_30_86290005_numeric_value >=30 & !is.na(flucats_question_30_86290005_numeric_value)~ "increased RR",
                               #For question 30 we also have code 431314004 (peripheral O2 saturation)
                               
                               flucats_question_30_86290005_code == 86290005 & age <1 & flucats_question_30_86290005_numeric_value <50 & !is.na(flucats_question_30_86290005_numeric_value)~ "normal RR",
                               flucats_question_30_86290005_code == 86290005 & age >=1 & age <16 & flucats_question_30_86290005_numeric_value <40 & !is.na(flucats_question_30_86290005_numeric_value)~ "normal RR",
                               flucats_question_30_86290005_code == 86290005 & age >=16 & flucats_question_30_86290005_numeric_value <30 & !is.na(flucats_question_30_86290005_numeric_value)~ "normal RR",
                               
                               flucats_question_30_86290005_code == 86290005 & age <1 & is.na(flucats_question_30_86290005_numeric_value)~ "RR code = 86290005 but RR value missing",
                               flucats_question_30_86290005_code == 86290005 & age >=1 & age <16 & is.na(flucats_question_30_86290005_numeric_value)~ "RR code = 86290005 but RR value missing",
                               flucats_question_30_86290005_code == 86290005 & age >=16 & is.na(flucats_question_30_86290005_numeric_value)~ "RR code = 86290005 but RR value missing"
                               ),
         flucats_c = case_when(flucats_question_30_431314004_code == 431314004 & flucats_question_30_431314004_numeric_value <=92 ~ "O2 saturation <=92%",
                               flucats_question_30_431314004_code == 431314004 & flucats_question_30_431314004_numeric_value >92 ~ "O2 saturation >92%",
                               flucats_question_30_431314004_code == 431314004 & is.na(flucats_question_30_431314004_numeric_value) ~ "code = 431314004 but value missing"),
         
         
         flucats_d = case_when(!is.na(flucats_question_7_code) ~ flucats_question_7_code,
                               is.na(flucats_question_7_code) ~ flucats_question_7_code),
         
         flucats_e = case_when(flucats_question_36_code == 162685008 ~ "dehydrated",
                               flucats_question_36_code == 312450001 ~ "not dehydrated"),
         
         flucats_f = case_when(flucats_question_37_162701007_code == 162701007 ~ "fully conscious",
                               flucats_question_37_162705003_code == 162705003 ~ "semiconscious",
                               flucats_question_37_268913004_code == 268913004 ~ "unconscious/comatose",
                               flucats_question_37_162702000_code == 162702000 ~ "162702000",
                               flucats_question_37_162704004_code == 162704004 ~ "162704004",
                               TRUE ~ "NA"))
         

sex_table <- table(df$sex)
region_table <- table(df$region)

flucat_a_table <- table(df$flucats_a)
flucat_b_table <- table(df$flucats_b)
flucat_c_table <- table(df$flucats_c)
flucat_d_table <- table(df$flucats_d)
flucat_e_table <- table(df$flucats_e)
flucat_f_table <- table(df$flucats_f)

#Write descriptive tables
write.csv(flucat_a_table, "output/flucat_a.csv")#moderately sensitive: specify in YAML
write.csv(flucat_b_table, "output/flucat_b.csv")
write.csv(flucat_c_table, "output/flucat_c.csv")
write.csv(flucat_d_table, "output/flucat_d.csv")
write.csv(flucat_e_table, "output/flucat_e.csv")
write.csv(flucat_f_table, "output/flucat_f.csv")

write.csv(sex_table, "output/sex_table.csv")
write.csv(region_table, "output/region_table.csv")
