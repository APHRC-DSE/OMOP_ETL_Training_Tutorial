library(RPostgres)
library(DBI)
library(dplyr)
library(tidyr)
library(readr)

## Care Site CDM table Transformation

caresite_cdm_table <- df_clean %>%
    ##Distinct Location, sitename
  dplyr::distinct(prov2001, producer) %>%
    ##Drop NA in location name
  tidyr::drop_na(prov2001) %>%
  dplyr::inner_join(location_cdm_table %>%
                      dplyr::select(location_id, location_source_value),
                    by = c("prov2001" = "location_source_value")
                    ) %>%
  dplyr::mutate(care_site_id = dplyr::row_number()
                , place_of_service_concept_id = 581476 #Homevisit
                , place_of_service_source_value = NA_character_
                ) %>%
  dplyr::rename(care_site_name = producer
                , care_site_source_value = prov2001
                ) %>%
  dplyr::select(care_site_id, care_site_name, place_of_service_concept_id, location_id, care_site_source_value,
                place_of_service_source_value
                ) %>%
  dplyr::mutate(care_site_source_value = strtrim(care_site_source_value, 49)
                , place_of_service_source_value = strtrim(place_of_service_source_value, 49)
                )


## Loading to CDM tables

### Inserting data to specific schema and table
caresite_cdm_load <- 
  DBI::dbWriteTable(con
                    , name = Id(schema = cdm_schema_name, table = "care_site")
                    , value = caresite_cdm_table
                    , overwrite = TRUE
                    , row.names = FALSE
                    , field.types = c(care_site_id="integer", care_site_name= "character varying (255)",
                                      place_of_service_concept_id="integer", location_id="integer",
                                      care_site_source_value="character varying (50)", 
                                      place_of_service_source_value= "character varying (50)"
                                      )
                    )
    
### CDM Primary Key Constraints for OMOP Common Data Model 5.4
DBI::dbSendQuery(con, glue::glue("
ALTER TABLE {cdm_schema_name}.care_site  ADD CONSTRAINT xpk_care_site PRIMARY KEY (care_site_id);
                                                      ")
                 )
