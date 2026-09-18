library(RPostgres)
library(DBI)
library(glue)

working_directory

# Loading Vocabularies in OMOP CDM Tables

load_omop_vocabs <- 
  sapply(vocabulary_schema_name, function(x){
  nn <- x
  
  #Set path to your downloaded and unzipped Vocabularies from Athena
  path_concept_vocabs <- glue::glue(vocab_folder_path, "\\CONCEPT.csv")
  path_concept_relationship_vocabs <- glue::glue(vocab_folder_path, "\\CONCEPT_RELATIONSHIP.csv")
  path_concept_ancestor_vocabs <- glue::glue(vocab_folder_path, "\\CONCEPT_ANCESTOR.csv")
  path_concept_synonym_vocabs <- glue::glue(vocab_folder_path, "\\CONCEPT_SYNONYM.csv")
  path_drug_strength_vocabs <- glue::glue(vocab_folder_path, "\\DRUG_STRENGTH.csv")
  path_vocabulary_vocabs <- glue::glue(vocab_folder_path, "\\VOCABULARY.csv")
  path_relationship_vocabs <- glue::glue(vocab_folder_path, "\\RELATIONSHIP.csv")
  path_concept_class_vocabs <- glue::glue(vocab_folder_path, "\\CONCEPT_CLASS.csv")
  path_domain_vocabs <- glue::glue(vocab_folder_path, "\\DOMAIN.csv")
  
  query_set_search_path <- DBI::dbExecute(con, sprintf("SET search_path TO %s", nn))
  
  list_schema_tables <- DBI::dbListTables(con)
  
  data_exists <- sapply(list_schema_tables, function(y){
    DBI::dbGetQuery(con, paste0("SELECT CASE 
        WHEN EXISTS (SELECT * FROM ", y , " LIMIT 1) THEN 1
        ELSE 0 
      END")
              )
   
  }, simplify = FALSE
   )
  
  load_concept_table <- if (data_exists[["concept"]]$case == 1) {
    print("vocabulary exists in vocabulary schema-concept table")
    } else {
      DBI::dbSendQuery(con, glue::glue("
      COPY {nn}.CONCEPT FROM '{path_concept_vocabs}'
      WITH DELIMITER E'\t' 
      CSV HEADER QUOTE E'\b';
                          ")
                  )
    }
  
  load_concept_relationship_table <- if (data_exists[["concept_relationship"]]$case == 1) {
    print("vocabulary exists in vocabulary schema-concept relationship table")
    } else {
      DBI::dbSendQuery(con, glue::glue("
      COPY {nn}.CONCEPT_RELATIONSHIP FROM '{path_concept_relationship_vocabs}'
      WITH DELIMITER E'\t' 
      CSV HEADER QUOTE E'\b';
                          ")
                  )
      }
  
  load_concept_ancestor_table <- if (data_exists[["concept_ancestor"]]$case == 1) {
    print("vocabulary exists in vocabulary schema-concept ancestor table")
    } else {
      DBI::dbSendQuery(con, glue::glue("
      COPY {nn}.CONCEPT_ANCESTOR FROM '{path_concept_ancestor_vocabs}'
      WITH DELIMITER E'\t' 
      CSV HEADER QUOTE E'\b';
                            ")
                  )
  }
  
  load_concept_synonym_table <- if (data_exists[["concept_synonym"]]$case == 1) {
    print("vocabulary exists in vocabulary schema-concept synonym table")
    } else {
      DBI::dbSendQuery(con, glue::glue("
      COPY {nn}.CONCEPT_SYNONYM FROM '{path_concept_synonym_vocabs}'
      WITH DELIMITER E'\t' 
      CSV HEADER QUOTE E'\b';
                            ")
                  )
      }
  
  load_drug_strength_table <- if (data_exists[["drug_strength"]]$case == 1) {
    print("vocabulary exists in vocabulary schema-drug strength table")
    } else {
      DBI::dbSendQuery(con, glue::glue("
        COPY {nn}.DRUG_STRENGTH FROM '{path_drug_strength_vocabs}'
        WITH DELIMITER E'\t' 
        CSV HEADER QUOTE E'\b';
                              ")
                  )
      }
  
  
  load_vocabulary_table <- if (data_exists[["vocabulary"]]$case == 1) {
    print("vocabulary exists in vocabulary schema-vocabulary table")
    } else {
      DBI::dbSendQuery(con, glue::glue("
        COPY {nn}.VOCABULARY FROM '{path_vocabulary_vocabs}'
        WITH DELIMITER E'\t' 
        CSV HEADER QUOTE E'\b';
                              ")
                  )
      }
  
  load_relationship_table <- if (data_exists[["relationship"]]$case == 1) {
    print("vocabulary exists in vocabulary schema-relationship table")
  } else {
    DBI::dbSendQuery(con, glue::glue("
    COPY {nn}.RELATIONSHIP FROM '{path_relationship_vocabs}'
    WITH DELIMITER E'\t' 
    CSV HEADER QUOTE E'\b';
                            ")
                )
    }
  
  load_concept_class_table <- if (data_exists[["concept_class"]]$case == 1) {
    print("vocabulary exists in vocabulary schema-concept class table")
    } else {
      DBI::dbSendQuery(con, glue::glue("
      COPY {nn}.CONCEPT_CLASS FROM '{path_concept_class_vocabs}'
      WITH DELIMITER E'\t' 
      CSV HEADER QUOTE E'\b';
                                ")
                  )
      }
  
  
  load_domain_table <- if (data_exists[["domain"]]$case == 1) {
    print("vocabulary exists in vocabulary schema-domain table")
    } else {
      DBI::dbSendQuery(con, glue::glue("
      COPY {nn}.DOMAIN FROM '{path_domain_vocabs}'
      WITH DELIMITER E'\t' 
      CSV HEADER QUOTE E'\b';
                            ")
                  )
      }
  
  
}, simplify = FALSE
)



