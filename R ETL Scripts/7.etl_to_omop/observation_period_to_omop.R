library(RPostgres)
library(DBI)
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)

## Observation Period CDM table Transformation

observation_period_cdm_table <- df_clean %>%
  dplyr::arrange(pid, wave_id) %>%
  dplyr::select(pid, interview_date) %>%
  dplyr::inner_join( person_cdm_table %>%
                       dplyr::select( person_id, person_source_value),
                     by = c("pid"= "person_source_value")
                     ) %>%
  tidyr::drop_na(interview_date) %>% #If no interview_date is available, the record should be dropped from the CDM instance.
  dplyr::group_by(person_id) %>%
  dplyr::summarise(observation_period_start_date = min(interview_date, na.rm = TRUE)
                   , observation_period_end_date = max(interview_date, na.rm = TRUE)
                   , .groups = "drop"
                   ) %>%
  dplyr::mutate(observation_period_id = dplyr::row_number()
                , period_type_concept_id = 32883
                ) %>%
  dplyr::select( observation_period_id, person_id, observation_period_start_date, observation_period_end_date,
                 period_type_concept_id
                 )


## Loading to CDM tables
### Inserting data to specific schema and table
observation_period_cdm_load <- 
  DBI::dbWriteTable(con
                    , name = Id(schema = cdm_schema_name, table = "observation_period")
                    , value = observation_period_cdm_table
                    , overwrite = TRUE
                    , row.names = FALSE
                    , field.types = c(observation_period_id="integer", person_id= "integer", 
                                      observation_period_start_date="date", observation_period_end_date="date",
                                      period_type_concept_id="integer"
                                      )
                    )
    
### CDM Primary Key Constraints for OMOP Common Data Model 5.4
DBI::dbSendQuery(con, glue::glue("
ALTER TABLE {cdm_schema_name}.observation_period ADD CONSTRAINT xpk_observation_period PRIMARY KEY (observation_period_id);
                                                      ")
                 )
