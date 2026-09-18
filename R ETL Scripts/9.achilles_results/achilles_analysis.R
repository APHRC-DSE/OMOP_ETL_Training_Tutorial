library(DatabaseConnector)
library(Achilles)

working_directory

#Automated Characterization of Health Information at Large-Scale Longitudinal Evidence Systems (ACHILLES) 
## Achilles provides descriptive statistics on an OMOP CDM database. ACHILLES currently supports CDM version 5.3 and 5.4.

## Create connection details
cd_achilles <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  server = paste0("localhost","/",database_name),
  user = "postgres",
  password = Sys.getenv("postgres_password"),
  port = 5432,
  extraSettings = "tcpKeepAlive=true",
  pathToDriver = base::file.path(data_Dir, "JDBC Driver postgresql")
  )

#Add the default error report logger
#ParallelLogger::addDefaultErrorReportLogger(file.path(Achilles_Analysis_Dir, "errorReportSql.txt"))

options(rstudio.connectionObserver.errorsSuppressed = TRUE)

## Run Achilles
achilles_analysis <- 
  Achilles::achilles(connectionDetails = cd_achilles,
                     cdmDatabaseSchema = cdm_schema_name,
                     resultsDatabaseSchema = results_schema_name,  #no capital letters- brings issues with postgres
                     vocabDatabaseSchema = vocabulary_schema_name,
                     sourceName = "",
                     createTable = TRUE,
                     smallCellCount = 5,
                     cdmVersion = "5.4",
                     createIndices = TRUE,
                     numThreads = 1,
                     outputFolder = Achilles_Analysis_Dir,
                     optimizeAtlasCache = FALSE,
                     verboseMode = TRUE #show all execution steps
                     )
  

