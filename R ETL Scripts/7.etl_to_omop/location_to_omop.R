library(RPostgres)
library(DBI)
library(dplyr)
library(tidyr)
library(readr)

## Location CDM table Transformation

location_cdm_table <- df_clean %>%
    ##Distinct Location
  dplyr::distinct(prov2001, country) %>%
    ##Drop NA in location name
  tidyr::drop_na(prov2001) %>%
  tidyr::pivot_longer(cols = country
                      , names_to = "name"
                      , values_to = "value"
                      ) %>%
  ##Get ConceptID for Country
  dplyr::left_join(df_usagi_merge_approved
                   , by = c("value" = "sourceName", "name" = "ADD_INFO:variable_name")
                   ) %>%
  dplyr::mutate(latitude = case_when(prov2001 == "KwaZulu-Natal" ~ -28.914195,
                                     prov2001 == "Eastern Cape" ~ -32.0756215, 
                                     prov2001 == "Western Cape" ~ -38.2812472, 
                                     prov2001 == "Limpopo" ~ -23.7465763, 
                                     prov2001 == "North West" ~ -26.3456605, 
                                     prov2001 == "Mpumalanga" ~ -25.7148848, 
                                     prov2001 == "Gauteng" ~ -26.3090186, 
                                     prov2001 == "Northern Cape" ~ -28.7404099,
                                     prov2001 == "Free State" ~ -28.6509164,
                                     FALSE ~ as.numeric(prov2001)
                                     ) #latitude
                , longitude = case_when(prov2001 == "KwaZulu-Natal" ~ 28.2396071,
                                        prov2001 == "Eastern Cape" ~ 23.8229345,
                                        prov2001 == "Western Cape" ~ 17.3722937,
                                        prov2001 == "Limpopo" ~ 26.5028853,
                                        prov2001 == "North West" ~ 22.820788,
                                        prov2001 == "Mpumalanga" ~ 27.4956626,
                                        prov2001 == "Gauteng" ~ 27.647979,
                                        prov2001 == "Northern Cape" ~ 15.7029934,
                                        prov2001 == "Free State" ~ 24.4232204,
                                        FALSE ~ as.numeric(prov2001)
                                        ) #longitude
                , latitude = round(latitude, 7)
                , longitude = round(longitude, 7)
                , address_2 = NA
                , city = NA
                , state = NA
                , zip = NA
                , county = NA
                , location_id = dplyr::row_number()
                , location_source_value = prov2001
                ) %>%
  dplyr::rename(country_concept_id = conceptId
                , country_source_value = value
                , address_1 = prov2001
                ) %>%
  dplyr::select(location_id, address_1, address_2 , city, state, zip, county, location_source_value,
                country_concept_id, country_source_value, latitude, longitude)
    

## Loading to CDM tables

### Inserting data to specific schema and table

location_cdm_load <- 
  DBI::dbWriteTable(con
                    , name = Id(schema = cdm_schema_name, table = "location")
                    , value = location_cdm_table
                    , overwrite = TRUE
                    , row.names = FALSE
                    , field.types = c(location_id="integer", address_1= "character varying (50)",
                                      address_2="character varying (50)", city="character varying (50)",
                                      state="character varying (2)", zip="character varying (9)",
                                      county= "character varying (20)", location_source_value="character varying (50)",
                                      country_concept_id= "integer", country_source_value="character varying (80)",
                                      latitude="numeric", longitude="numeric"
                                      )
                    )

### CDM Primary Key Constraints for OMOP Common Data Model 5.4
DBI::dbSendQuery(con, glue::glue("
 ALTER TABLE {cdm_schema_name}.location ADD CONSTRAINT xpk_location PRIMARY KEY (location_id);
                                                       ")
                 )

