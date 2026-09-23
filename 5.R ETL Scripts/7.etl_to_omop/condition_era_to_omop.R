library(RPostgres)
library(DBI)
library(dplyr)
library(tidyr)
library(readr)

## Condition era CDM table Transformation

condition_era_cdm_table <- condition_occurrence_cdm_table %>%
  dplyr::select(condition_occurrence_id, person_id, condition_concept_id, condition_start_date) %>%
  dplyr::group_by(person_id, condition_concept_id) %>%
  dplyr::summarise(condition_era_start_date = min(condition_start_date)
                   , condition_era_end_date = max(condition_start_date)
                   , condition_occurrence_count = length(person_id)
                   , .groups = "drop"
                   ) %>%
  dplyr::mutate(condition_era_id = dplyr::row_number()
                ) %>%
  dplyr::select(condition_era_id, person_id, condition_concept_id, condition_era_start_date, condition_era_end_date,
                condition_occurrence_count
                )
  

## Loading to CDM tables
### Inserting data to specific schema and table
condition_era_cdm_load <- 
  DBI::dbWriteTable(con
                    , name = Id(schema = cdm_schema_name, table = "condition_era")
                    , value = condition_era_cdm_table
                    , overwrite = TRUE
                    , row.names = FALSE
                    , field.types = c(condition_era_id="integer", person_id= "integer", condition_concept_id="integer",
                                      condition_era_start_date="date", condition_era_end_date="date", 
                                      condition_occurrence_count="integer"
                                      )
                    )
   
### CDM Primary Key Constraints for OMOP Common Data Model 5.4
DBI::dbSendQuery(con, glue::glue("
 ALTER TABLE {cdm_schema_name}.condition_era ADD CONSTRAINT xpk_condition_era PRIMARY KEY (condition_era_id);
                                                       ")
                 )


