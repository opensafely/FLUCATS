# import required libraries
library(tidyverse)
library(readr)
library(dplyr)

df <- read_csv("output/input_2021-01-01.csv") %>% select(flucats_template, flucats_template_date, flucats_question_30_86290005_code, flucats_question_30_86290005_numeric_value, flucats_question_30_431314004_code, flucats_question_30_431314004_numeric_value, flucats_question_7_code, flucats_question_37_162701007_code, flucats_question_37_162705003_code, flucats_question_37_268913004_code, flucats_question_37_162702000_code, flucats_question_37_162704004_code) %>% filter(flucats_template==1)


# for each column that starts with flucats_question but doesnt end in numeric_value print the unique values
df %>% 
  select(starts_with("flucats_question")) %>%
  select(ends_with("code"))%>%
  map(~unique(.x))%>% 
  map(~print(.x))