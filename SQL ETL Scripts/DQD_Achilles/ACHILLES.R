#utils::install.packages("DatabaseConnector")
###utils::install.packages("rstudioapi")
#install.packages("remotes")
#remotes::install_github("OHDSI/Achilles")

#options(rstudio.connectionObserver.errorsSuppressed = TRUE)

#utils::file.edit("~/.Renviron") # Store password credentials in .Renviron

### Setting work directory
working_directory <- base::setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
working_directory

library(DatabaseConnector)
library(Achilles)

## Path to jdbc drivers
driver_path <- base::file.path(working_directory, "JDBC Driver postgresql")

## database name, schemas and output folder

database_name <- "omop_training"
cdm_schema <- "nids_cdm"
results_schema <- "nids_results"

## Create connection to database
cd_achilles <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  server = paste0("localhost","/",database_name),
  user = "postgres",
  password = Sys.getenv("postgres_password"),
  port = 5432,
  pathToDriver = driver_path  #path to jdbc drivers
)


#run achilles
Achilles::achilles(connectionDetails = cd_achilles,
                   cdmDatabaseSchema = cdm_schema,
                   resultsDatabaseSchema = results_schema,
                   sourceName = "",
                   createTable = TRUE,
                   smallCellCount = 5,
                   cdmVersion = "5.4",
                   createIndices = TRUE,
                   numThreads = 1,
                   outputFolder = "achilles_output",
                   optimizeAtlasCache = FALSE
                   )

