library(pROC)
library(dplyr)
library(predtools)
library(ggplot2) 

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
  
  # if the sum of the split by column is less than 100, aggregate some of the variables:
  # age_band - over and under 50
  # ckd_primis_stage - over and under 3
  # region - drop
  # ethnicity_opensafely - white (1, 2, 3) and non-white
  # imdQ5 - over and under 3


  if (sum(df$split_by) < 100) {
    # if age_band in the variables, split into over and under 50
    if ("age_band" %in% variables) {
      df$age_band <- ifelse(df$age_band > 50, "Over 50", "Under 50")
    }
    if ("ckd_primis_stage" %in% variables) {
      df$ckd_primis_stage <- ifelse(df$ckd_primis_stage %in% c("3", "4", "5"), "Over 3", "Under 3")
    }
    if ("region" %in% variables) {
       df$region <- NULL
    }
    if ("ethnicity_opensafely" %in% variables) {
      df$ethnicity_opensafely <- ifelse(df$ethnicity_opensafely %in% c("1", "2", "3"), "White", "Non-white")
    }
    if ("ethnicity" %in% variables) {
      df$ethnicity <- ifelse(df$ethnicity %in% c(1, 2, 3), "White", "Non-white")
    }
    if ("imdQ5" %in% variables) {
      df$imdQ5 <- ifelse(df$imdQ5 %in% c("4", "5"), "Over 3", "Under 3")
    }
  }

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
  
  vars_to_drop = c()

  tryCatch({

    
    for (var in all.vars(formula)) {
      print(var)
      print(table(data[[var]]))
      if (length(unique(data[[var]])) < 2) {
        vars_to_drop <- c(vars_to_drop, var)
      }

    }

    # remove any vars_to_drop from the formula
    if (length(vars_to_drop) > 0) {
      formula <- update(formula, . ~ . - paste(vars_to_drop, collapse = " + "))
    }
    print(formula)

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

  data = as.data.frame(data)
  print("Generating calibration plot")
  print(output_path)

  print(table(data[[obs]]))
  
  #
  print(table(data[[pred]] > 0.5))

  data <- data[, c(obs, pred)]
  
  # print shape of data
  print(dim(data))
  print(head(data))

  output <- tryCatch({
    calibration_plot_safe(data = data, obs = obs, pred = pred, data_summary = TRUE)
  }, error = function(e) {
    message("An error occurred, writing error message to CSV. Error: ", e)
    return(NULL)  #
  })


  if (!is.null(output)) {
    write.csv(output$data_summary, output_path, row.names = FALSE)

  } else {
    write.csv(data.frame(), output_path)
  }

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
      
      # if length of roc_data >10, then aggregate the data
      if (length(roc_data$thresholds) > 10) {
        roc_data <- roc_data[!is.infinite(roc_data$thresholds), ]

        desired_thresholds <- quantile(roc_data$thresholds, probs = seq(roc_data$thresholds[1], roc_data$thresholds[length(roc_data$thresholds)], length.out = 10))
        print(desired_thresholds)
        aggregated_roc_data <- data.frame(fpr = numeric(0), sensitivity = numeric(0), thresholds = numeric(0))
        for (threshold in desired_thresholds) {
          idx <- which.min(abs(roc_data$thresholds - threshold))
          aggregated_roc_data <- rbind(aggregated_roc_data, roc_data[idx, ])
        }
        aggregated_roc_data <- aggregated_roc_data[!duplicated(aggregated_roc_data$thresholds), ]

        aggregated_roc_data$thresholds <- round(aggregated_roc_data$thresholds, 6)
        aggregated_roc_data$fpr <- round(aggregated_roc_data$fpr, 6)
        aggregated_roc_data$sensitivity <- round(aggregated_roc_data$sensitivity, 6)
        
        write.csv(aggregated_roc_data, file.path(results_dir, paste("roc_data_aggregated", model_name, ".csv", sep = "_")), row.names = FALSE)
    
      }
      

      write.csv(roc_data, file.path(results_dir, paste("roc_data", model_name, ".csv", sep = "_")))
      
    
    # AUC and its CI
    auc_value <- auc(mroc) 
    auc_ci <- ci.auc(mroc)
    auc_ci_str <- paste("AUC: ", round(auc_ci[2], 5), " (CI: ", round(auc_ci[1], 5), "-", round(auc_ci[3], 5), ")")
    
    aucs_data <- data.frame(auc = auc_ci_str)
    write.csv(aucs_data, file.path(results_dir, paste("aucs", model_name, ".csv", sep = "_")))


    }
    print(file.path(results_dir, paste("calibration_summary", model_name, ".csv", sep = "_")))

    # check if any nas in the outcome and predictions
    if (sum(is.na(dataset[[outcome_name]])) > 0 | sum(is.na(dataset$predictions)) > 0) {
      message("There are NAs in the outcome or predictions.")
    }

    generate_calibration_plot(data = dataset, obs = outcome_name, pred = "predictions", output_path = file.path(results_dir, paste("calibration_summary", model_name, ".csv", sep = "_")))
    
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

roundmid_any <- function(x, to=6){
  # like round_any, but centers on (integer) midpoint of the rounding points
  ceiling(x/to)*to - (floor(to/2)*(x!=0))
}

# source: https://github.com/resplab/predtools/blob/4d90f59c22485177c65cfae3778ec16ec48e950a/R/calibPlot.R
calibration_plot_safe <- function(data,
                             obs,
                             follow_up = NULL,
                             pred,
                             group = NULL,
                             nTiles = 10,
                             legendPosition = "right",
                             title = NULL,
                             x_lim = NULL,
                             y_lim = NULL,
                             xlab = "Prediction",
                             ylab = "Observation",
                             points_col_list = NULL,
                             data_summary = FALSE) {
  
  if (! exists("obs") | ! exists("pred")) stop("obs and pred can not be null.")
  
  n_groups <- length(unique(data[ , group]))
  
  if (is.null(follow_up)) data$follow_up <- 1

  if (! is.null(group)) {
    data %>%
      group_by(!!sym(group)) %>%
      mutate(decile = ntile(!!sym(pred), nTiles)) %>%
      group_by(.data$decile, !!sym(group)) %>%
      summarise(obsRate = mean(!!sym(obs) / follow_up, na.rm = T),
                obsRate_SE = sd(!!sym(obs) / follow_up, na.rm = T) / sqrt(n()),
                obsNo = n(),
                predRate = mean(!!sym(pred), na.rm = T)) -> dataDec_mods
    colnames(dataDec_mods)[colnames(dataDec_mods) == "group"] <- group
  }
  else {
    data %>%
      mutate(decile = ntile(!!sym(pred), nTiles)) %>%
      group_by(.data$decile) %>%
      summarise(obsRate = mean(!!sym(obs) / follow_up, na.rm = T),
                obsRate_SE = sd(!!sym(obs) / follow_up, na.rm = T) / sqrt(n()),
                obsNo = n(),
                predRate = mean(!!sym(pred), na.rm = T)) -> dataDec_mods
  }

  
  # get the number of events - obsNo * obsRate
  dataDec_mods$events <- as.integer(dataDec_mods$obsNo * dataDec_mods$obsRate)

  # midpoint 6 rounding for events
  dataDec_mods$events <- roundmid_any(dataDec_mods$events, to = 6)
  # midpoint 6 rounding for obsNo
  dataDec_mods$obsNo <- roundmid_any(dataDec_mods$obsNo, to = 6)

  # recalculate obsRate
  dataDec_mods$obsRate <- dataDec_mods$events / dataDec_mods$obsNo

  dataDec_mods$obsRate_UCL <- dataDec_mods$obsRate + 1.96 * dataDec_mods$obsRate_SE
  dataDec_mods$obsRate_LCL <- dataDec_mods$obsRate - 1.96 * dataDec_mods$obsRate_SE
  
  # drop events
  dataDec_mods <- dataDec_mods %>% select(-events)

  dataDec_mods <- as.data.frame(dataDec_mods)

  
  if (! is.null(group)) {
    dataDec_mods[ , group] <- factor(dataDec_mods[ , group])
    calibPlot_obj <-
      ggplot(data = dataDec_mods, aes(y = .data$obsRate, x = .data$predRate, group = !!sym(group), color = !!sym(group))) +
      geom_point() +
      lims(x = ifelse(rep(is.null(x_lim), 2), c(min(dataDec_mods$predRate), max(dataDec_mods$predRate)), x_lim),
           y = ifelse(rep(is.null(y_lim), 2), c(min(dataDec_mods$obsRate_LCL), max(dataDec_mods$obsRate_UCL)), y_lim)) +
      geom_errorbar(aes(ymax = .data$obsRate_UCL, ymin = .data$obsRate_LCL)) +
      geom_abline(intercept = 0, slope = 1) +
      scale_color_manual(values = ifelse(rep(is.null(points_col_list), n_groups),
                                         (ggplot2::scale_colour_brewer(palette = "Set3")$palette(8)[c(4 : 8, 1 : 3)])[c(1 : n_groups)],
                                         points_col_list)) +
      labs(x = ifelse(is.null(xlab), pred, xlab),
           y = ifelse(is.null(ylab), obs, ylab),
           title = title) +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank(), axis.line = element_line(colour = "black"),
            legend.key = element_rect(fill = "white"),
            axis.text = element_text(colour = "black", size = 12),
            legend.position = legendPosition)
  }
  else {
    calibPlot_obj <-
      ggplot(data = dataDec_mods, aes(y = .data$obsRate, x = .data$predRate)) +
      geom_point(color = ggplot2::scale_colour_brewer(palette = "Set3")$palette(8)[5]) +
      lims(x = ifelse(rep(is.null(x_lim), 2), c(min(dataDec_mods$predRate), max(dataDec_mods$predRate)), x_lim),
           y = ifelse(rep(is.null(y_lim), 2), c(min(dataDec_mods$obsRate_LCL), max(dataDec_mods$obsRate_UCL)), y_lim)) +
      geom_errorbar(aes(ymax = .data$obsRate_UCL, ymin = .data$obsRate_LCL),
                    col = ifelse(is.null(points_col_list),
                                 ggplot2::scale_colour_brewer(palette = "Set3")$palette(8)[5],
                                 points_col_list)) +
      geom_abline(intercept = 0, slope = 1) +
      scale_color_manual(values = ifelse(is.null(points_col_list),
                                         ggplot2::scale_colour_brewer(palette = "Set3")$palette(8)[5],
                                         points_col_list)) +
      labs(x = ifelse(is.null(xlab), pred, xlab),
           y = ifelse(is.null(ylab), obs, ylab),
           title = title) +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank(), axis.line = element_line(colour = "black"),
            axis.text = element_text(colour = "black", size = 12),
            legend.position = legendPosition)
  }
 
  res_list <- list(calibration_plot = calibPlot_obj)
  if (data_summary) res_list$data_summary <- dataDec_mods

  return(res_list)
}