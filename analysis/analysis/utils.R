library(pROC)
library(dplyr)
library(predtools)

ensureDirExists <- function(filepath) {
  dir <- dirname(filepath)
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }
}

saveSummary <- function(model, filename) {
  ensureDirExists(filename)
  if (!is.null(model)) {
    sink(filename)
    print(summary(model))
    sink()
  } else {
    write.csv(data.frame(), filename)
  }
}


summarise_and_export_data <- function(df, variables, output_file, split_by = NULL) {
  
  summarise_data <- function(df, var) {
    if (is.numeric(df[[var]])) {
      count = sum(!is.na(df[[var]]))
      # if count is <=7 set to 0. Round to nearest 5.
      if (count <= 7) {
        mean = 0
        sd = 0
        count = 0
      } else {
        count = round(count/5) * 5
        mean = round(mean(df[[var]], na.rm = TRUE), 2)
        sd = round(sd(df[[var]], na.rm = TRUE), 2)
      }

      data_frame <- data.frame(category = var, category_value = "Mean", count = count, mean = mean, sd = sd)
      
      if (sum(is.na(df[[var]])) > 0) {
        count = sum(is.na(df[[var]]))
        if (count <= 7) {
          count = 0
        } else {
          count = round(count/5) * 5
        }
        data_frame <- rbind(data_frame, data.frame(category = var, category_value = "Missing", count = count, mean = "-", sd="-"))
      }
    } else {
     
      if (sum(is.na(df[[var]])) > 0) {
        df[[var]] <- as.character(df[[var]])
        df[[var]] <- replace(df[[var]], is.na(df[[var]]), "Missing")
        df[[var]] <- as.factor(df[[var]])
      }
  
      table_results <- table(df[[var]])
      levels = as.character(names(table_results))
      counts = as.numeric(table_results)

      counts <- ifelse(counts <= 7, 0, counts)
      counts <- round(counts/5) * 5

      var_vector <- rep(var, length(levels))
      mean_vector <- rep("-", length(levels))
      sd_vector <- rep("-", length(levels))    
      df_levels <- data.frame(category = var_vector, category_value = levels, count = counts, mean = mean_vector, sd = sd_vector)
      
      data_frame <- df_levels
    }
    return(data_frame)
  }
  
  process_subset <- function(subset_df) {
    results_list <- lapply(variables, function(var) summarise_data(subset_df, var))
    summary_table <- do.call(rbind, results_list)
    return(summary_table)
  }
  
  if (!is.null(split_by) && split_by %in% names(df)) {
    unique_values <- unique(df[[split_by]])
    all_summaries <- lapply(unique_values, function(val) {
      subset_df <- df[df[[split_by]] == val, ]
      subset_summary <- process_subset(subset_df)
      subset_summary$outcome <- as.character(val)
      return(subset_summary)
    })
    final_summary <- do.call(rbind, all_summaries)
  } else {
    final_summary <- process_subset(df)
  }
  
  write.csv(final_summary, output_file, row.names = FALSE)
}


fit_model <- function(formula, data, family) {
  
  if (length(unique(data[[as.character(formula[[2]])]])) < 2) {
    return(NULL)
  }
  
  tryCatch({
    model <- glm(formula, data = data, family = family, na.action = na.omit)
    if (!model$converged) {
      stop("Model did not converge")
    }
    return(model)
  }, error = function(e) {
    warning(paste("Error in fitting model:", e))
    return(NULL)
  })
}



fit_model_if_two_factors <- function(df, y_var, ...){
  if(length(unique(df[[y_var]])) >= 2){
    formula <- as.formula(paste(y_var, "~", paste(list(...), collapse = " + ")))
    model <- glm(formula, data = df, family = binomial, na.action = na.omit)
    return(model)
  } else {
    return(NULL)
  }
}



generate_calibration_plot <- function(data, obs, pred, output_path) {
  print("Generating calibration plot")
  print(output_path)

  print(table(data[[obs]]))
  
  #
  print(table(data[[pred]] > 0.5))

  output <- tryCatch({
    calibration_plot(data = data, obs = obs, pred = pred, data_summary = TRUE)
  }, error = function(e) {
    
    # add errro message
    message("An error occurred, writing error message to CSV. Error: ", e)

  
  })


  output_file <- if ("Error" %in% names(output)) {
    paste0(output_path)
  } else {
    paste0(output_path)
  }
  
  # Write the output or error message to the specified CSV file
  write.csv(output, output_file, row.names = FALSE)

}


generate_model_evaluation <- function(model, dataset, outcome_name, model_name, results_dir) {
  
  
  
  if (!is.null(model)) {
    # Predict the outcome
    dataset$predictions <- predict.glm(model, dataset, type = "response", na.action = na.omit)
    
  
    if (length(unique(dataset[[outcome_name]])) < 2) {    
      write.csv(data.frame(), file.path(results_dir, paste("roc_data", model_name, ".csv", sep = "_")))
      write.csv(data.frame(), file.path(results_dir, paste("aucs", model_name, ".csv", sep = "_")))

    }
    else {
      mroc <- roc(dataset[[outcome_name]], dataset$predictions, plot = TRUE)
      roc_data <- data.frame(
        fpr = 1 - mroc$specificities,
        sensitivity = mroc$sensitivities,
        thresholds = mroc$thresholds
      )
      
      write.csv(roc_data, file.path(results_dir, paste("roc_data", model_name, ".csv", sep = "_")))
    
    
    # AUC and its CI
    auc_value <- auc(mroc) 
    auc_ci <- ci.auc(mroc)
    auc_ci_str <- paste("AUC: ", round(auc_ci[2], 5), " (CI: ", round(auc_ci[1], 5), "-", round(auc_ci[3], 5), ")")
    
    aucs_data <- data.frame(auc = auc_ci_str)
    write.csv(aucs_data, file.path(results_dir, paste("aucs", model_name, ".csv", sep = "_")))
    
    }
    print(file.path(results_dir, paste("calibration_summary", model_name, ".csv", sep = "_")))
    generate_calibration_plot(data = dataset, obs = outcome_name, pred = predictions, output_path = file.path(results_dir, paste("calibration_summary", model_name, ".csv", sep = "_")))
    
  } else {
    # Write empty files if the model is null
    write.csv(data.frame(), file.path(results_dir, paste("roc_data", model_name, ".csv", sep = "_")))
    write.csv(data.frame(), file.path(results_dir, paste("aucs", model_name, ".csv", sep = "_")))
    write.csv(data.frame(), file.path(results_dir, paste("calibration", model_name, ".csv", sep = "_")))
  }
}



# function that combines fit_model, saveSummary and generate_model_evaluation

fit_model_and_evaluate <- function(formula, data, family, outcome_name, model_name, results_dir) {
  if (!dir.exists(results_dir)) {
    dir.create(results_dir, recursive = TRUE)
  }

  # remove any rows where any columns used in the formula are NA
  data <- data[complete.cases(data[, all.vars(formula)]), ]
  
  model <- fit_model(formula, data, family)
  saveSummary(model, file.path(results_dir, paste(model_name, "summary.txt", sep = "_")))
 
  generate_model_evaluation(model, data, outcome_name, model_name, results_dir)
}

