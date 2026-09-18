library(RPostgres)
library(DBI)
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)

## Measurement CDM table Transformation

measurement_cdm_table <- df_clean %>%
  dplyr::arrange(pid, wave_id) %>%
  #select numeric measurements
  dplyr::select(pid, interview_date, cesd_total_score, adult_bmi, adult_waist, adult_bp_systolic, 
                adult_bp_diastolic, adult_bp_pulse
                ) %>%
  tidyr::pivot_longer(cols = !c(pid, interview_date)
                      , names_to = "name"
                      , values_to = "value"
                      ) %>%
  ##Drop NA in value
  tidyr::drop_na(value) %>%
  ##Get Measurements ConceptID
  dplyr::left_join(df_usagi_merge_approved %>%
                     dplyr::filter(sourceName %in% c("CES-D Depression self-rating scale" ,"Body mass index",
                                                     "Waist circumference", "Systolic Blood Pressure",
                                                     "Diastolic Blood Pressure", "Pulse"
                                                     )
                                   ) %>%
                     dplyr::filter(domainId %in% "Measurement") %>%
                     dplyr::select(-c(createdBy, sourceName, `ADD_INFO:variable_description`, domainId))
                   , by = c("name" = "ADD_INFO:variable_name")
                   ) %>%
  dplyr::rename(measurement_concept_id = conceptId
                ) %>%
  ##Get Unit ConceptID for Measurement
  dplyr::left_join(df_usagi_merge_approved %>%
                     dplyr::filter(domainId %in% "Unit") %>%
                     dplyr::select(-c(createdBy, sourceName, domainId))
                   , by = c("name" = "ADD_INFO:variable_name")
                   ) %>%
  dplyr::rename(unit_concept_id = conceptId
                , unit_source_value = `ADD_INFO:variable_description`
                , measurement = name
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
  dplyr::mutate(measurement_id = dplyr::row_number()
                , measurement_datetime = lubridate::as_datetime(interview_date, tz = "UTC")
                , measurement_time = "00:00:00"
                , measurement_type_concept_id = 32883
                , operator_concept_id = NA
                , range_low = NA
                , range_high = NA
                , measurement_source_value = value
                , measurement_source_concept_id = NA
                , unit_source_concept_id = NA
                , measurement_event_id = NA
                , meas_event_field_concept_id = NA
                ) %>%
  dplyr::rename(measurement_date = interview_date
                , value_as_number = value
                ) %>%
  ##Get value_as_concept_id for Measurements - Categorical
  dplyr::left_join(df_clean %>%
                     dplyr::arrange(pid, wave_id) %>%
                     #select numeric measurements
                     dplyr::select(pid, interview_date, adult_bmi_group
                                   ) %>%
                     dplyr::rename(adult_bmi = adult_bmi_group
                                   ) %>%
                     tidyr::pivot_longer(cols = !c(pid, interview_date)
                                         , names_to = "name"
                                         , values_to = "value"
                                         ) %>%
                     ##Drop NA in value
                     tidyr::drop_na(value)
                   , by = c("measurement_date"= "interview_date"
                            , "measurement" = "name"
                             , "pid" = "pid"
                             )
                   ) %>%
  dplyr::left_join(df_usagi_merge_approved %>% 
                     dplyr::select(-c(createdBy, domainId, `ADD_INFO:variable_description`))
                   , by = c("value" = "sourceName")
                   ) %>%
  dplyr::rename(value_as_concept_id = conceptId
                , value_source_value = value
                , measurement_group = `ADD_INFO:variable_name`
                ) %>%
  dplyr::select( measurement_id, person_id, measurement_concept_id, measurement_date, measurement_datetime
                 , measurement_time, measurement_type_concept_id, operator_concept_id, value_as_number
                 , value_as_concept_id, unit_concept_id, range_low, range_high, provider_id, visit_occurrence_id
                 , visit_detail_id, measurement_source_value, measurement_source_concept_id, unit_source_value
                 , unit_source_concept_id, value_source_value, measurement_event_id, meas_event_field_concept_id
                 )
                     
  
## Loading to CDM tables
### Inserting data to specific schema and table
measurement_cdm_load <- 
  DBI::dbWriteTable(con
                    , name = Id(schema = cdm_schema_name, table = "measurement")
                    , value = measurement_cdm_table
                    , overwrite = TRUE
                    , row.names = FALSE
                    , field.types = c(measurement_id="integer", person_id="integer", measurement_concept_id="integer"
                                      , measurement_date="date", measurement_datetime="timestamp without time zone"
                                      , measurement_time="character varying (10)", measurement_type_concept_id="integer"
                                      , operator_concept_id="integer", value_as_number="numeric"
                                      , value_as_concept_id="integer" , unit_concept_id="integer", range_low="numeric"
                                      , range_high="numeric", provider_id="integer" , visit_occurrence_id="integer"
                                      , visit_detail_id="integer", measurement_source_value="character varying (50)"
                                      , measurement_source_concept_id="integer", unit_source_value="character varying (50)"
                                      , unit_source_concept_id="integer", value_source_value="character varying (50)"
                                      , measurement_event_id="integer", meas_event_field_concept_id="integer"
                                      )
                    )
    
  
### CDM Primary Key Constraints for OMOP Common Data Model 5.4
DBI::dbSendQuery(con, glue::glue("
ALTER TABLE {cdm_schema_name}.measurement ADD CONSTRAINT xpk_measurement PRIMARY KEY (measurement_id);
                                                      ")
                 )
  

