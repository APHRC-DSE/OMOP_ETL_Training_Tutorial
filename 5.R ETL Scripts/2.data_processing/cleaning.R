library(dplyr)
library(readr)
library(stringr)
library(lubridate)
library(labelled)
library(tidyr)
library(tibble)
library(forcats)

## Clean dataset

df_clean <- df_raw %>% 
  dplyr::mutate(interview_date = lubridate::dmy(interview_date)
                , date_of_birth = lubridate::dmy(date_of_birth)
                ) %>%
  labelled::set_variable_labels(!!!new_labels[names(new_labels) %in% names(.)]
                                #labeling variables from data dictionary
                                )


## saving clean dataset
### csv file
readr::write_csv(x = df_clean
                 ,file = base::file.path(output_Dir, "sample_data_final.csv")
                 ,na = ""
                 )

