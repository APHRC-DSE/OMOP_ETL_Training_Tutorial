library(RPostgres)
library(DBI)
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)

## Visit Detail CDM table Transformation

visit_detail_cdm_table <- df_clean %>%
  dplyr::arrange(pid, wave_id) %>%
  dplyr::select(pid, wave_id, interview_date) %>%
  dplyr::inner_join( person_cdm_table %>%
                       dplyr::select(person_id, person_source_value, provider_id, care_site_id),
                     by = c("pid" = "person_source_value")
                     ) %>%
  dplyr::inner_join( visit_occurrence_cdm_table %>%
                       dplyr::select(visit_occurrence_id, person_id, visit_start_date, provider_id, care_site_id),
                     by = c("person_id" = "person_id", "interview_date" = "visit_start_date",
                            "provider_id" = "provider_id", "care_site_id" = "care_site_id"
                            )
                     ) %>%
  dplyr::mutate(visit_detail_id = dplyr::row_number()
                , visit_detail_concept_id = 581476
                , visit_detail_start_datetime = lubridate::as_datetime(interview_date, tz = "UTC")
                , visit_detail_end_date = interview_date
                , visit_detail_end_datetime = lubridate::as_datetime(interview_date, tz = "UTC")
                , visit_detail_type_concept_id = 32883
                , visit_detail_source_value = "National Household Panel Survey Interview"
                , visit_detail_source_concept_id = 0
                , admitted_from_concept_id = 581476
                , admitted_from_source_value = "Home Visit"
                , discharged_to_concept_id = 581476
                , discharged_to_source_value = "Home Visit"
                , preceding_visit_detail_id = visit_detail_id
                , parent_visit_detail_id = NA
                ) %>%
  dplyr::rename( visit_detail_start_date = interview_date) %>%
  dplyr::group_by(pid, visit_detail_source_concept_id) %>%
  dplyr::mutate(first_visit_detail_id = min(visit_detail_id)
                ) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(preceding_visit_detail_id = ifelse(preceding_visit_detail_id==first_visit_detail_id, NA,
                                                   preceding_visit_detail_id-1)
                ) %>%
  dplyr::select( visit_detail_id, person_id, visit_detail_concept_id, visit_detail_start_date, visit_detail_start_datetime,
                 visit_detail_end_date, visit_detail_end_datetime, visit_detail_type_concept_id, provider_id, care_site_id,
                 visit_detail_source_value, visit_detail_source_concept_id, admitted_from_concept_id,
                 admitted_from_source_value, discharged_to_source_value, discharged_to_concept_id,
                 preceding_visit_detail_id, parent_visit_detail_id, visit_occurrence_id
                 )
    

## Loading to CDM tables
### Inserting data to specific schema and table

visit_detail_cdm_load <- 
  DBI::dbWriteTable(con
                    , name = Id(schema = cdm_schema_name, table = "visit_detail")
                    , value = visit_detail_cdm_table
                    , overwrite = TRUE
                    , row.names = FALSE
                    , field.types = c(visit_detail_id="integer", person_id= "integer", visit_detail_concept_id="integer",
                                      visit_detail_start_date="date", visit_detail_start_datetime="timestamp without time zone",
                                      visit_detail_end_date="date", visit_detail_end_datetime="timestamp without time zone",
                                      visit_detail_type_concept_id="integer", provider_id= "integer", 
                                      care_site_id="integer",  visit_detail_source_value= "character varying (50)",
                                      visit_detail_source_concept_id="integer", admitted_from_concept_id="integer", 
                                      admitted_from_source_value="character varying (50)", 
                                      discharged_to_source_value="character varying (50)", 
                                      discharged_to_concept_id="integer", preceding_visit_detail_id="integer",
                                      parent_visit_detail_id="integer", visit_occurrence_id="integer"
                                      )
                    )
    
    
### CDM Primary Key Constraints for OMOP Common Data Model 5.4
DBI::dbSendQuery(con, glue::glue("
ALTER TABLE {cdm_schema_name}.visit_detail ADD CONSTRAINT xpk_visit_detail PRIMARY KEY (visit_detail_id);
                                                      ")
                 )
  
