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
                               
                              #  age_band <1 & flucats_question_numeric_value_respiratory_rate_250810003_value >=50 & flucats_question_numeric_value_respiratory_rate_250810003_value > 0 ~ "yes",
                              #  age_band >=1 & age_band <16 & flucats_question_numeric_value_respiratory_rate_250810003_value >=40 & flucats_question_numeric_value_respiratory_rate_250810003_value > 0 ~ "yes",
                               age_band != "missing" & flucats_question_numeric_value_respiratory_rate_250810003_value >=30 & flucats_question_numeric_value_respiratory_rate_250810003_value > 0 ~ "yes",
                               #For question 30 we also have code 431314004 (peripheral O2 saturation)
                               
                              #  age_band <1 & flucats_question_numeric_value_respiratory_rate_271625008_value <50 & flucats_question_numeric_value_respiratory_rate_271625008_value > 0 ~ "yes",
                              #  age_band >=1 & age_band <16 & flucats_question_numeric_value_respiratory_rate_271625008_value <40 & flucats_question_numeric_value_respiratory_rate_271625008_value > 0 ~ "yes",
                               age_band != "missing" & flucats_question_numeric_value_respiratory_rate_271625008_value >=30 & flucats_question_numeric_value_respiratory_rate_271625008_value > 0 ~ "yes",
                               
                              #  age_band <1 & flucats_question_numeric_value_respiratory_rate_86290005_value <50 & flucats_question_numeric_value_respiratory_rate_86290005_value > 0 ~ "yes",
                              #  age_band >=1 & age_band <16 & flucats_question_numeric_value_respiratory_rate_86290005_value <40 & flucats_question_numeric_value_respiratory_rate_86290005_value > 0 ~ "yes",
                               age_band != "missing" & flucats_question_numeric_value_respiratory_rate_86290005_value >=30 & flucats_question_numeric_value_respiratory_rate_86290005_value > 0 ~ "yes",

                              #  age_band <1 & flucats_question_numeric_value_respiratory_rate_927961000000102_value <50 & flucats_question_numeric_value_respiratory_rate_927961000000102_value > 0 ~ "yes",
                              #  age_band >=1 & age_band <16 & flucats_question_numeric_value_respiratory_rate_927961000000102_value <40 & flucats_question_numeric_value_respiratory_rate_927961000000102_value > 0 ~ "yes",
                               age_band != "missing" & flucats_question_numeric_value_respiratory_rate_927961000000102_value >=30 & flucats_question_numeric_value_respiratory_rate_927961000000102_value > 0 ~ "yes",
                               
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
                               !is.na(flucats_question_clinical_concern_note_37331000000100) ~ "yes",
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
