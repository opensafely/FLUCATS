#Discrimination and calibration for hospitalisation
####
library(arsenal)
library(pROC)
library(predtools)
library(dplyr)

#Separate models for each type of hospitalisation, by child/adult status
hosp_child <- glm(hosp_24h ~ total_CAT, data = df_child ,family = "binomial")
df_child$prediction_hosp_c <- predict.glm(hosp_child, df_child, type = "response")
mroc_hosp_child <- roc(df_child$hosp_24h, prediction_hosp_c, plot = T)#Save plot
auc_hosp_child <- auc(mroc_hosp_child) #print value
auc_hosp_child_ci <- ci.auc(mroc_hosp_child) #print value

hosp_adult <- glm(hosp_24h ~ total_CAT, data = df_adult ,family = "binomial")
df_adult$prediction_hosp_a <- predict.glm(hosp_adult, df_adult, type = "response")
mroc_hosp_adult <- roc(df_adult$hosp_24h, prediction_hosp_a, plot = T)#Save plot
auc_hosp_adult <- auc(mroc_hosp_adult) #print value
auc_hosp_adult_ci <- ci.auc(mroc_hosp_adult) #print value

#THIS NEEDS TO BE REPEATED FOR COVID-HOSPITALISATION AS WELL

#Calibration
calibration_plot(data = df_child, obs = "hosp_24", pred = "prediction_hosp_c")
calibration_plot(data = df_adult, obs = "hosp_24", pred = "prediction_hosp_a")

