# Load necessary library
library(dplyr)

# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)


# The first argument is the output directory
output_dir <- args[1]

# The rest of the arguments are file paths
file_paths <- args[-1]


for (i in 1:length(file_paths)) {
  file_paths[i] <- paste0(output_dir, "/", file_paths[i])
}

# Ensure the output directory exists or create it
if(!dir.exists(output_dir)){
  dir.create(output_dir, recursive = TRUE)
}


read_file_with_name <- function(file_path) {

    # try and read the file - if it is empty, return NULL

    tryCatch({
        df <- read.csv(file_path, header = TRUE, stringsAsFactors = FALSE)
        if(nrow(df) > 0) {
            df <- df[1, ]
            row.names(df) <- basename(file_path)
            return(df)
        }
        else {
            return(NULL)
        }
    }, error = function(e) {
        return(NULL)
    })
 
  
}

# Read files and concatenate
all_data <- do.call(rbind, lapply(file_paths, read_file_with_name))

# if all_data is empty, create an empty data frame
if (is.null(all_data)) {
  all_data <- data.frame()
}

# Save the concatenated data frame to the output directory
write.csv(all_data, file.path(output_dir, "aucs_combined.csv"), row.names = TRUE)

