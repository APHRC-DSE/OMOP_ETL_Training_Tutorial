library(RPostgres)
library(DBI)
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)

## CDM Source table Transformation

cdm_source_cdm_table <- df_clean %>%
    ##latest event date in the source data i.e interview_date
    dplyr::mutate(min_observation_date = min(interview_date, na.rm = TRUE)
                  , max_observation_date = max(interview_date, na.rm = TRUE)
                  ) %>%
    ##Distinct producer Name
    dplyr::distinct(producer, min_observation_date, max_observation_date) %>%
    dplyr::mutate( cdm_holder = "APHRC"
                   , cdm_source_abbreviation = "SALDRU - NIDS"
                   , cdm_version_concept_id = 756265 #OMOP CDM Version 5.4.0
                   , vocabulary_version = "v5.0 29-AUG-26"
                   , cdm_version = "5.4"
                   , cdm_etl_reference = "https://github.com/APHRC-DSE/OMOP_ETL_Training_Tutorial"
                   , cdm_release_date = Sys.Date()
                   , source_documentation_reference = "https://saldru.uct.ac.za/nids/data-access"
                   , source_description = paste0("National Income Dynamics Study (NIDS): National Household Panel Study from "
                                                 , min_observation_date
                                                 , " to ", max_observation_date
                                                 )
                   ) %>%
    dplyr::rename( cdm_source_name = producer
                   , source_release_date = max_observation_date
                   ) %>%
    dplyr::select( cdm_source_name, cdm_source_abbreviation, cdm_holder, source_description, source_documentation_reference
                   , cdm_etl_reference, source_release_date, cdm_release_date, cdm_version, cdm_version_concept_id
                   , vocabulary_version
                   )


## Loading to CDM tables
### Inserting data to specific schema and table
cdm_source_cdm_load <- 
  DBI::dbWriteTable(con
                    , name = Id(schema = cdm_schema_name, table = "cdm_source")
                    , value = cdm_source_cdm_table
                    , overwrite = TRUE
                    , row.names = FALSE
                    , field.types = c(cdm_source_name="character varying (255)"
                                      , cdm_source_abbreviation="character varying (25)"
                                      , cdm_holder="character varying (255)", source_description="text"
                                      , source_documentation_reference="character varying (255)"
                                      , cdm_etl_reference="character varying (255)" , source_release_date="date"
                                      , cdm_release_date="date", cdm_version="character varying (10)"
                                      , cdm_version_concept_id="integer", vocabulary_version="character varying (20)"
                                      )
                    )
  
