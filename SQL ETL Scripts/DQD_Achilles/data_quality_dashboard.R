################################################################################
#1.Installing Required packages

#utils::install.packages("DatabaseConnector")
#utils::install.packages("rstudioapi")
#utils::install.packages("remotes")
#remotes::install_github("OHDSI/DataQualityDashboard")

#options(rstudio.connectionObserver.errorsSuppressed = TRUE)

################################################################################
#2.Store password credentials in .Renviron

#utils::file.edit("~/.Renviron") 

################################################################################
#3.Setup

### Setting work directory
working_directory <- base::setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

working_directory

################################################################################
#3.Load Required packages

library(DatabaseConnector)
library(DataQualityDashboard)

################################################################################
#3.Data Quality dashboard

#DQD dashboard for the study data

#VIEWING CHECKS 
#To see description of checks using R, execute the command below:

#checks <- DataQualityDashboard::listDqChecks(cdmVersion = "5.4") # Put the version of the CDM you are using

## Path to jdbc drivers
driver_path <- base::file.path(working_directory, "JDBC Driver postgresql")

## database name, schemas and output folder
database_name <- "omop_training"
cdm_schema <- "nids_cdm"
results_schema <- "nids_results"
vocabulary_schema <- "vocabulary"

## Create connection to database
cd_dqd <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  server = paste0("localhost","/",database_name),
  user = "postgres",
  password = Sys.getenv("postgres_password"),
  port = 5432,
  pathToDriver = driver_path  #path to jdbc drivers
  )


#run Data Quality Dashboard 
DataQualityDashboard::executeDqChecks(connectionDetails = cd_dqd,
                                      cdmDatabaseSchema = cdm_schema, # database schema name of the CDM
                                      resultsDatabaseSchema = results_schema, # database schema name of the results
                                      vocabDatabaseSchema = vocabulary_schema, #default is to set it as the cdmDatabaseSchema
                                      cdmSourceName = "", # a human readable name for your CDM source
                                      cdmVersion = "5.4", # the CDM version you are targeting. Currently supports 5.2, 5.3, and 5.4
                                      numThreads = 1, #determine how many threads (concurrent SQL sessions) to use
                                      sqlOnly = FALSE, # set to TRUE if you just want to get the SQL scripts and not actually run the queries
                                      sqlOnlyUnionCount = 1,
                                      sqlOnlyIncrementalInsert =  FALSE, # set to TRUE if you want the generated SQL queries to calculate DQD
                                      outputFolder = "dqd_output", #where should the results and logs go?
                                      outputFile = "dqd_results.json",
                                      verboseMode = FALSE, # set to FALSE if you don't want the logs to be printed to the console
                                      writeToTable = TRUE, # set to FALSE if you want to skip writing to a SQL table in the results schema
                                      writeTableName = "dqd_results", #The name of the results table. Default 'dqdashboard_results'
                                      writeToCsv = FALSE, # set to FALSE if you want to skip writing to csv file
                                      csvFile = "", # only needed if writeToCsv is set to TRUE
                                      checkLevels = c("TABLE", "FIELD", "CONCEPT"),
                                      tablesToExclude = c("CONCEPT", "VOCABULARY", "CONCEPT_ANCESTOR", "CONCEPT_RELATIONSHIP", "CONCEPT_CLASS"
                                                          , "CONCEPT_SYNONYM", "RELATIONSHIP", "DOMAIN", "DRUG_STRENGTH"
                                                          )
                                      )

## View Dashboard
DataQualityDashboard::viewDqDashboard(base::file.path(working_directory, "dqd_output", "dqd_results.json")
                                      )


