library(RPostgres)
library(DBI)
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)

## Observation CDM table Transformation

observation_cdm_table <- df_clean %>%
  dplyr::arrange(pid, wave_id) %>%
  #select categorical observations
  dplyr::select(pid, interview_date, age_group, education_status, marital_status, occupation_status, a_rel,
                a_emobth, a_emomnd, a_emodep, a_emoeff, a_emohope, a_emofear, a_emoslp, a_emohap, a_emolone, a_emogo
                ) %>%
  tidyr::pivot_longer(cols = !c(pid, interview_date)
                      , names_to = "name"
                      , values_to = "value"
                      ) %>%
  ##Drop NA in value
  tidyr::drop_na(value) %>%
  ##Get Observation ConceptID 
  dplyr::left_join(df_usagi_merge_approved %>%
                     dplyr::filter(sourceName %in% c("Age" ,"Highest level of education", "Marital status",
                                                     "Occupation status", "Religious affiliation",
                                                     "unusually bothered in past week", "trouble focusing in past week",
                                                     "felt depressed in past week", "felt that everything was an effort in past week",
                                                     "felt hopeful about the future in past week", "felt fearful in past week",
                                                     "sleep was restless in past week", "was happy in past week",
                                                     "felt lonely in past week", "could not get going"
                                                     )
                                   ) %>%
                     dplyr::filter(domainId %in% "Observation") %>%
                     dplyr::select(-c(createdBy, sourceName, domainId))
                   , by = c("name" = "ADD_INFO:variable_name")
                   ) %>%
  dplyr::rename(observation_concept_id = conceptId
                , observation_source_value = `ADD_INFO:variable_description`
                ) %>%
  ##Get value_as_concept_id for Observation
  dplyr::left_join(df_usagi_merge_approved %>% dplyr::select(-c(createdBy, domainId, `ADD_INFO:variable_description`))
                   , by = c("value" = "sourceName", "name" = "ADD_INFO:variable_name")
                   ) %>%
  dplyr::rename(value_as_concept_id = conceptId
                , value_as_string = value
                , observation = name
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
  dplyr::mutate(observation_id = dplyr::row_number()
                , observation_datetime = lubridate::as_datetime(interview_date, tz = "UTC")
                , observation_type_concept_id = 32883
                , qualifier_concept_id = NA
                , unit_concept_id = NA
                , observation_source_concept_id = NA
                , unit_source_value = NA
                , qualifier_source_value = NA
                , value_source_value = value_as_string
                ) %>%
  dplyr::rename(observation_date = interview_date
                ) %>%
  ##Get value_as_number for Observations
  dplyr::left_join(df_clean %>%
                     dplyr::arrange(pid, wave_id) %>%
                     #select numeric observation
                     dplyr::select(pid, interview_date, age_yrs
                                   ) %>%
                     dplyr::rename(age_group = age_yrs
                                   ) %>%
                     tidyr::pivot_longer(cols = !c(pid, interview_date)
                                         , names_to = "name"
                                         , values_to = "value"
                                         ) %>%
                     ##Drop NA in value
                     tidyr::drop_na(value)
                   , by = c("observation_date"= "interview_date"
                            , "observation" = "name"
                             , "pid" = "pid"
                             )
                   ) %>%
  dplyr::rename(value_as_number = value
                ) %>%
  ##Link CESD Total scores in Measurement table to Observations 
  dplyr::mutate(cesd = case_when(observation %in% c("a_emobth", "a_emomnd", "a_emodep", "a_emoeff",
                                                    "a_emohope", "a_emofear", "a_emoslp", "a_emohap",
                                                    "a_emolone", "a_emogo") ~ "cesd",
                                 FALSE ~ as.character(observation)
                                 )
                ) %>%
  dplyr::left_join( measurement_cdm_table %>%
                      dplyr::filter(measurement_concept_id == 4164828) %>%
                      dplyr::select(measurement_id, person_id, measurement_date) %>%
                      dplyr::rename(observation_event_id = measurement_id) %>%
                      dplyr::mutate(cesd = "cesd"
                                    , obs_event_field_concept_id = 1147138 #concept_id for measurement_id for CDM v5
                                    ),
                     by = c("person_id" = "person_id"
                            , "observation_date" = "measurement_date"
                            , "cesd" = "cesd"
                            )
                     ) %>%
    dplyr::select(observation_id, person_id, observation_concept_id, observation_date, observation_datetime
                  , observation_type_concept_id, value_as_number, value_as_string, value_as_concept_id
                  , qualifier_concept_id, unit_concept_id, provider_id, visit_occurrence_id, visit_detail_id
                  , observation_source_value, observation_source_concept_id, unit_source_value, qualifier_source_value
                  , value_source_value, observation_event_id, obs_event_field_concept_id
                  ) %>%
    dplyr::mutate(across(c(observation_source_value, value_source_value), ~strtrim(.x, 49)
                         )
                  , value_as_string = strtrim(value_as_string, 59)
                  )

 
## Loading to CDM tables
### Inserting data to specific schema and table
observation_cdm_load <- 
   DBI::dbWriteTable(con
                    , name = Id(schema = cdm_schema_name, table = "observation")
                    , value = observation_cdm_table
                    , overwrite = TRUE
                    , row.names = FALSE
                    , field.types = c(observation_id="integer", person_id="integer", observation_concept_id="integer"
                                      , observation_date="date", observation_datetime="timestamp without time zone"
                                      , observation_type_concept_id="integer", value_as_number="numeric"
                                      , value_as_string="character varying (60)", value_as_concept_id="integer"
                                      , qualifier_concept_id="integer", unit_concept_id="integer", provider_id="integer"
                                      , visit_occurrence_id="integer", visit_detail_id="integer"
                                      , observation_source_value="character varying (50)"
                                      , observation_source_concept_id="integer", unit_source_value="character varying (50)"
                                      , qualifier_source_value="character varying (50)"
                                      , value_source_value="character varying (50)" , observation_event_id="integer"
                                      , obs_event_field_concept_id="integer"
                                      )
                    )
     
## CDM Primary Key Constraints for OMOP Common Data Model 5.4
DBI::dbSendQuery(con, glue::glue("
 ALTER TABLE {cdm_schema_name}.observation ADD CONSTRAINT xpk_observation PRIMARY KEY (observation_id);
                                                       ")
                   )
 

