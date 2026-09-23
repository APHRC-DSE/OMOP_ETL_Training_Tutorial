library(RPostgres)
library(DBI)
library(dplyr)
library(lubridate)
library(tidyr)
library(readr)

## Person CDM table Transformation

person_cdm_table <- df_clean %>%
  dplyr::arrange(pid, wave_id) %>%
  dplyr::select(pid, date_of_birth, best_gen, best_race, prov2001, interviewer_id
                ) %>%
    ##Distinct individual ID
  dplyr::distinct(pid, .keep_all = TRUE) %>%
  #If no year of birth is available all the person’s data should be dropped from the CDM instance.
  tidyr::drop_na(date_of_birth) %>% 
  tidyr::pivot_longer(cols = best_gen
                      , names_to = "name"
                      , values_to = "value"
                      ) %>%
  ##Get ConceptID for Gender
  dplyr::left_join(df_usagi_merge_approved %>% dplyr::select(-createdBy)
                   , by = c("value" = "sourceName", "name" = "ADD_INFO:variable_name")
                   ) %>%
  dplyr::rename(gender_concept_id = conceptId
                , gender_source_value = value
                , gender = name
                ) %>%
  tidyr::pivot_longer(cols = best_race
                      , names_to = "name"
                      , values_to = "value"
                      ) %>%
  ##Get ConceptID for Race
  dplyr::left_join(df_usagi_merge_approved %>% dplyr::select(-createdBy)
                   , by = c("value" = "sourceName", "name" = "ADD_INFO:variable_name")
                   ) %>%
  dplyr::rename(race_concept_id = conceptId
                , race_source_value = value
                , race = name
                ) %>%
  dplyr::inner_join( caresite_cdm_table %>%
                       dplyr::select(care_site_id, location_id, care_site_source_value),
                     by = c("prov2001" = "care_site_source_value")
                     ) %>%
  dplyr::inner_join( provider_cdm_table %>%
                       dplyr::select(care_site_id, provider_id, provider_source_value),
                     by = c("care_site_id" = "care_site_id", "interviewer_id" = "provider_source_value")
                     ) %>%
  #If only year of birth is given, use the 15th of June of that year.
  dplyr::mutate( person_id = dplyr::row_number()
                 , year_of_birth = lubridate::year(date_of_birth)
                 , month_of_birth = lubridate::month(date_of_birth)
                 , day_of_birth = lubridate::day(date_of_birth)
                 , birth_datetime = lubridate::as_datetime(date_of_birth, tz = "UTC")
                 , ethnicity_concept_id = 1547281
                 , gender_source_concept_id = 0
                 , race_source_concept_id = 0
                 , ethnicity_source_value = "Subsaharan Africa"
                 , ethnicity_source_concept_id = 0
                 , across(c(gender_concept_id), ~tidyr::replace_na(.x, 4214687) #Gender unknown (Non-standard but Valid)
                          )
                 ) %>%
  dplyr::rename(person_source_value = pid
                ) %>%
  dplyr::select(person_id, gender_concept_id, year_of_birth, month_of_birth, day_of_birth, birth_datetime, race_concept_id
                , ethnicity_concept_id, location_id, provider_id, care_site_id, person_source_value, gender_source_value
                , gender_source_concept_id, race_source_value, race_source_concept_id, ethnicity_source_value
                , ethnicity_source_concept_id
                )


## Loading to CDM tables
### Inserting data to specific schema and table
person_cdm_load <- 
  DBI::dbWriteTable(con
                    , name = Id(schema = cdm_schema_name, table = "person")
                    , value = person_cdm_table
                    , overwrite = TRUE
                    , row.names = FALSE
                    , field.types = c(person_id="integer", gender_concept_id= "integer", year_of_birth="integer",
                                      month_of_birth="integer", day_of_birth="integer", 
                                      birth_datetime="timestamp without time zone", race_concept_id="integer", 
                                      ethnicity_concept_id= "integer", location_id="integer", provider_id= "integer", 
                                      care_site_id="integer", person_source_value="character varying (50)",
                                      gender_source_value="character varying (50)", gender_source_concept_id="integer",
                                      race_source_value="character varying (50)", race_source_concept_id="integer",
                                      ethnicity_source_value="character varying (50)", ethnicity_source_concept_id="integer"
                                      )
                    )
    
### CDM Primary Key Constraints for OMOP Common Data Model 5.4
DBI::dbSendQuery(con, glue::glue("
ALTER TABLE {cdm_schema_name}.person ADD CONSTRAINT xpk_person PRIMARY KEY (person_id);
                                                      ")
                 )

