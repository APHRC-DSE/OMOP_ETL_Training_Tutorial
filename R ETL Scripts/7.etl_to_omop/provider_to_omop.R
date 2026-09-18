library(RPostgres)
library(DBI)
library(dplyr)
library(tidyr)
library(readr)

## Provider CDM table Transformation

provider_cdm_table <- df_clean %>%
    ##Distinct Location, sitename
  dplyr::distinct(prov2001, interviewer_id, interviewer_gender) %>%
    ##Drop NA in location name
  tidyr::drop_na(prov2001) %>%
  tidyr::pivot_longer(cols = interviewer_gender
                        , names_to = "name"
                        , values_to = "value"
                        ) %>%
  ##Get ConceptID for interviewer gender
  dplyr::left_join(df_usagi_merge_approved
                   , by = c("value" = "sourceName", "name" = "ADD_INFO:variable_name")
                   ) %>%
  dplyr::right_join(caresite_cdm_table %>%
                      dplyr::select(care_site_id, care_site_name, care_site_source_value),
                    by = c("prov2001" = "care_site_source_value")
                    ) %>%
  dplyr::arrange(care_site_id) %>%
  dplyr::rename(gender_concept_id = conceptId
                , gender_source_value = value
                , provider_source_value = interviewer_id
                ) %>%
  dplyr::mutate(provider_id = 1:n()
                , provider_name = NA
                , npi = NA
                , dea = NA
                , specialty_concept_id = 4303445
                , year_of_birth = NA
                , specialty_source_value = "National Household Panel Survey"
                , specialty_source_concept_id = 0
                , gender_source_concept_id = 0
                ) %>%
  dplyr::select(provider_id, provider_name, npi, dea, specialty_concept_id, care_site_id, year_of_birth,
                gender_concept_id, provider_source_value, specialty_source_value, specialty_source_concept_id,
                gender_source_value, gender_source_concept_id
                )

## Loading to CDM tables
### Inserting data to specific schema and table
provider_cdm_load <- 
  DBI::dbWriteTable(con
                    , name = Id(schema = cdm_schema_name, table = "provider")
                    , value = provider_cdm_table
                    , overwrite = TRUE
                    , row.names = FALSE
                    , field.types = c(provider_id="integer", provider_name= "character varying (255)",
                                      npi="character varying (20)", dea="character varying (20)", 
                                      specialty_concept_id="integer", care_site_id="integer",
                                      year_of_birth="integer", gender_concept_id= "integer",
                                      provider_source_value="character varying (50)", 
                                      specialty_source_value= "character varying (50)",
                                      specialty_source_concept_id="integer", 
                                      gender_source_value="character varying (50)",
                                      gender_source_concept_id="integer"
                                      )
                    )
    
### CDM Primary Key Constraints for OMOP Common Data Model 5.4
DBI::dbSendQuery(con, glue::glue("
ALTER TABLE {cdm_schema_name}.provider ADD CONSTRAINT xpk_provider PRIMARY KEY (provider_id);
                                                      ")
                 )
