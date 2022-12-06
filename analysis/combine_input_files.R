
library(readr)
library(dplyr)
library(ggplot2)
library(lubridate)

# array of dates 
dates <- seq(as.Date("2020-04-01"), as.Date("2021-01-01"), by = "month")
# convert dates to strings
dates <- as.character(dates)

#Import the 16 Flu-CATs monthly files
df <- read_csv("output/input_2020-03-01.csv.gz") %>% select(sex, age, patient_id, flucats_template, flucats_template_date, flucats_question_35_code, flucats_question_30_86290005_code, flucats_question_30_86290005_numeric_value, flucats_question_30_431314004_code, flucats_question_30_431314004_numeric_value, flucats_question_7_code, flucats_question_36_code, flucats_question_37_162701007_code, flucats_question_37_162705003_code, flucats_question_37_268913004_code, flucats_question_37_162702000_code, flucats_question_37_162704004_code, region) %>% filter(flucats_template==1)

# iterate over dates, rbind to df
for (i in dates) {
  d2 <- read_csv(paste0("output/input_", i, ".csv.gz")) %>%
    select(sex, age, patient_id, flucats_template, flucats_template_date, flucats_question_35_code, flucats_question_30_86290005_code, flucats_question_30_86290005_numeric_value, flucats_question_30_431314004_code, flucats_question_30_431314004_numeric_value, flucats_question_7_code, flucats_question_36_code, flucats_question_37_162701007_code, flucats_question_37_162705003_code, flucats_question_37_268913004_code, flucats_question_37_162702000_code, flucats_question_37_162704004_code, region) %>% filter(flucats_template==1)

  df <- rbind(df, d2)
}

#Combine them all into one table, as the idea now is that we will analyse data collected over the entire duration as one big file
#Each enounter will be treated as separate. Two encounters from the same patient will be treated as separate encounters

rm(d2)

# save df
write_csv(df, "output/input_all.csv.gz")