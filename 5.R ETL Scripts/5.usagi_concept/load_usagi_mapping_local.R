library(dplyr)
library(readr)

working_directory

## Reading usagi mapping data from local folder

usagi_files <- list.files(path = base::file.path(mainDir, "5.usagi_concept"), pattern = ".csv$",  full.names = T)

df_usagi_list <- sapply(usagi_files, function(x){
  nn <- x
    
  df <- readr::read_csv(nn)
  
}, simplify=FALSE)


## Filter only APPROVED concepts
df_usagi_merge_approved <- dplyr::bind_rows(df_usagi_list) %>%
  dplyr::filter(mappingStatus == "APPROVED") %>%
  dplyr::select(any_of(c("sourceName", "ADD_INFO:variable_name", "ADD_INFO:variable_description",
                         "conceptId", "domainId", "createdBy"))
                )
  
df_usagi_merge_others <- dplyr::bind_rows(df_usagi_list) %>%
  dplyr::filter(mappingStatus != "APPROVED") %>%
  dplyr::select(any_of(c("sourceName", "ADD_INFO:variable_name", "ADD_INFO:variable_description",
                         "conceptId", "domainId", "createdBy"))
                )

