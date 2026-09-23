library(dplyr)
library(readr)
library(janitor)
library(tidyr)
library(writexl)
library(stringr)

working_directory

## Reading data from local folder

data_files <- list.files(path = data_Dir, pattern = ".csv$",  full.names = F)

### since data_files object is only one file, we will read directly instead of using a function

df_raw <- readr::read_csv(file.path(data_Dir, data_files)) %>%
  janitor::clean_names()





