library(dplyr)
library(readr)
library(tibble)

working_directory

## Reading the Data dictionary file

data_dictionary_file <- readr::read_csv("./2.data_processing/data_dictionary_sample_data.csv")


## Creating a named vector to quickly assign labels

new_labels <- data_dictionary_file %>%
  dplyr::select(variable, label) %>%
  tibble::deframe()

