library(RPostgres)
library(DBI)
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)

## Condition Occurrence CDM table Transformation

condition_occurrence_cdm_table <- df_clean %>%
  dplyr::arrange(pid, wave_id) %>%
  #select Conditions
  dplyr::select(pid, interview_date, cesd_depression, a_hltb, a_hlbp, a_hldia, a_hlstrk, a_hlast, a_hlhrt,
                a_hlcan, hiv_aids, epilepsy
                ) %>%
  tidyr::pivot_longer(cols = !c(pid, interview_date)
                      , names_to = "name"
                      , values_to = "value"
                      ) %>%
  ##Drop NA in value
  tidyr::drop_na(value) %>%
  dplyr::filter(value %in% "Yes") %>%
  ##Get Condition ConceptID 
  dplyr::left_join(df_usagi_merge_approved %>%
                     dplyr::filter(domainId %in% "Condition") %>%
                     dplyr::select(-c(createdBy, sourceName, domainId))
                   , by = c("name" = "ADD_INFO:variable_name")
                   ) %>%
  dplyr::rename(condition_concept_id = conceptId
                , condition_source_value = `ADD_INFO:variable_description`
                ) %>%
  dplyr::inner_join( person_cdm_table %>%
                       dplyr::select(person_id, person_source_value, provider_id, care_site_id),
                     by = c("pid" = "person_source_value")
                     ) %>%
  dplyr::inner_join(visit_detail_cdm_table %>%
                      dplyr::select(visit_detail_id, visit_occurrence_id, person_id, visit_detail_start_date,
                                    visit_detail_start_datetime, provider_id, visit_detail_source_value,
                                    visit_detail_source_concept_id)
                    , by = c("interview_date"= "visit_detail_start_date"
                             , "person_id" = "person_id"
                             , "provider_id" = "provider_id"
                             )
                    ) %>%
  dplyr::mutate( condition_occurrence_id = dplyr::row_number()
                 , condition_start_datetime = lubridate::as_datetime(interview_date, tz = "UTC")
                 , condition_end_date = NA
                 , condition_type_concept_id = 32883 #Survey
                 , condition_status_concept_id = 32899 #Preliminary diagnosis
                 , condition_end_datetime = NA
                 , stop_reason = NA
                 , condition_source_concept_id = NA
                 , condition_status_source_value = NA
                 ) %>%
  dplyr::rename(condition_start_date = interview_date
                ) %>%
  dplyr::select( condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_start_datetime,
                 condition_end_date, condition_end_datetime, condition_type_concept_id, condition_status_concept_id,
                 stop_reason, provider_id, visit_occurrence_id, visit_detail_id, condition_source_value,
                 condition_source_concept_id, condition_status_source_value
                 ) %>%
  dplyr::mutate(across(c(condition_status_source_value, condition_source_value), ~strtrim(.x, 49)
                       )
                )


## Loading to CDM tables
### Inserting data to specific schema and table
condition_occurrence_cdm_load <- 
  DBI::dbWriteTable(con
                    , name = Id(schema = cdm_schema_name, table = "condition_occurrence")
                    , value = condition_occurrence_cdm_table
                    , overwrite = TRUE
                    , row.names = FALSE
                    , field.types = c(condition_occurrence_id="integer", person_id= "integer", 
                                      condition_concept_id="integer", condition_start_date="date",
                                      condition_start_datetime="timestamp without time zone", condition_end_date="date",
                                      condition_end_datetime="timestamp without time zone",
                                      condition_type_concept_id="integer", condition_status_concept_id="integer",
                                      stop_reason="character varying (20)", provider_id="integer",
                                      visit_occurrence_id="integer", visit_detail_id="integer", 
                                      condition_source_value="character varying (50)", 
                                      condition_source_concept_id="integer", 
                                      condition_status_source_value="character varying (50)"
                                      )
                    )
    
  
### CDM Primary Key Constraints for OMOP Common Data Model 5.4
DBI::dbSendQuery(con, glue::glue("
ALTER TABLE {cdm_schema_name}.condition_occurrence ADD CONSTRAINT xpk_condition_occurrence PRIMARY KEY (condition_occurrence_id);
                                                      ")
                 )
  
