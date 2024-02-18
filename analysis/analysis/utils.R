saveSummary <- function(model, filename) {
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
  tryCatch({
    model <- glm(formula, data = data, family = family)
    if (!model$converged) {
      stop("Model did not converge")
    }
    return(model)
  }, error = function(e) {
    warning(paste("Error in fitting model:", e))
    return(NULL)
  })
}



generate_calibration_plot <- function(data, obs, pred, output_path) {
  output <- tryCatch({
    calibration_plot(data = data, obs = obs, pred = pred, data_summary = TRUE)
  }, error = function(e) {
    
    message("An error occurred, writing error message to CSV.")
    data.frame(Error = e$message)
  })


  output_file <- if ("Error" %in% names(output)) {
    paste0(output_path)
  } else {
    paste0(output_path)
  }
  
  # Write the output or error message to the specified CSV file
  write.csv(output, output_file, row.names = FALSE)

}