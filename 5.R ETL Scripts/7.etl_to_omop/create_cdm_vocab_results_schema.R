library(RPostgres)
library(DBI)

working_directory


# Create a new schema for each study
create_cdm_schema_name <- dbExecute(con, paste0("CREATE SCHEMA IF NOT EXISTS ", cdm_schema_name, ";")
                                    )
  

# Create results schema for each study
create_results_schema_name <- dbExecute(con, paste0("CREATE SCHEMA IF NOT EXISTS ", results_schema_name, ";")
                                        )

#Create a single vocabulary schema
create_vocabulary_schema_name <- dbExecute(con, paste0("CREATE SCHEMA IF NOT EXISTS ", vocabulary_schema_name, ";")
                                           )

  
