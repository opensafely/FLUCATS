#Continuing from flucatsValidation.R
library(pROC)

# read df child from csv
df_child <- read.csv("output/input_all_edited.csv")


#Separate models for each outcome, by child/adult status
hosp_child <- glm(hosp_24h ~ total_CAT, data = df_child ,family = "binomial")
prediction_hosp_c <- predict.glm(hosp_child, df_child, type = "response")
mroc_hosp_child <- roc(df_child$hosp_24h, prediction_hosp_c, plot = T)#Save plot
auc_hosp_child <- auc(mroc_hosp_child) #print value

hosp_adult <- glm(hosp_24h ~ total_CAT, data = df_adult ,family = "binomial")
prediction_hosp_a <- predict.glm(hosp_adult, df_adult, type = "response")
mroc_hosp_adult <- roc(df_adult$hosp_24h, prediction_hosp_a, plot = T)#Save plot
auc_hosp_adult <- auc(mroc_hosp_adult) #print value

#
death_child_pc <- glm(death_30d_pc ~ total_CAT, data = df_child ,family = "binomial")
prediction_dpc_c <- predict.glm(death_child_pc, df_child, type = "response")
mroc_dpc_child <- roc(df_child$death_30d_pc, prediction_dpc_c, plot = T)#Save plot
auc_dpc_child <- auc(mroc_dpc_child) #print value

death_adult_pc <- glm(death_30d_pc ~ total_CAT, data = df_adult ,family = "binomial")
prediction_dpc_a <- predict.glm(death_adult_pc, df_adult, type = "response")
mroc_dpc_adult <- roc(df_adult$death_30d_pc, prediction_dpc_a, plot = T)#Save plot
auc_dpc_adult <- auc(mroc_dpc_adult) #print value

#
death_child_ons <- glm(death_30d_ons ~ total_CAT, data = df_child ,family = "binomial")
prediction_ons_c <- predict.glm(death_child_ons, df_child, type = "response")
mroc_ons_child <- roc(df_child$death_30d_ons, prediction_ons_c, plot = T)#Save plot
auc_ons_child <- auc(mroc_ons_child) #print value

death_adult_ons <- glm(death_30d_ons ~ total_CAT, data = df_adult ,family = "binomial")
prediction_ons_a <- predict.glm(death_adult_ons, df_adult, type = "response")
mroc_ons_adult <- roc(df_adult$death_30d_ons, prediction_ons_a, plot = T)#Save plot
auc_ons_adult <- auc(mroc_ons_adult) #print value

#
icu_child <- glm(icu_adm ~ total_CAT, data = df_child ,family = "binomial")
prediction_icu_c <- predict.glm(icu_child, df_child, type = "response")
mroc_icu_child <- roc(df_child$icu_adm, prediction_icu_c, plot = T)#Save plot
auc_icu_child <- auc(mroc_icu_child) #print value

icu_adult <- glm(icu_adm ~ total_CAT, data = df_adult ,family = "binomial")
prediction_icu_a <- predict.glm(icu_adult, df_adult, type = "response")
mroc_icu_adult <- roc(df_adult$icu_adm, prediction_icu_a, plot = T)#Save plot
auc_icu_adult <- auc(mroc_icu_adult) #print value

