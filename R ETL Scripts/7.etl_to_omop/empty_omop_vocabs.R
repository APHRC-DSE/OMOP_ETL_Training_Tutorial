library(RPostgres)
library(DBI)
library(glue)

working_directory

# Empty Vocabularies in OMOP CDM Tables

empty_omop_vocabs <- 
  sapply(c(cdm_schema_name, vocabulary_schema_name), function(x){
  nn <- x
  
  query_set_search_path <- DBI::dbExecute(con, sprintf("SET search_path TO %s", nn))
  
  #Truncating quickly removes all data from a table while maintaining the table structure and associated constraints.
  
  empty_vocab_tables <- DBI::dbSendQuery(con, glue::glue("
      TRUNCATE TABLE {nn}.concept, {nn}.concept_relationship, {nn}.concept_ancestor, {nn}.concept_synonym,
      {nn}.drug_strength, {nn}.vocabulary, {nn}.relationship, {nn}.concept_class, {nn}.domain
      ;")
                                    )
  
  
}, simplify = FALSE
)



