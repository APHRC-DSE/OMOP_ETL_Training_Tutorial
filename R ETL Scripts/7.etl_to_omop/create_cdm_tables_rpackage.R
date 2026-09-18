library("CommonDataModel")
library("DatabaseConnector")

# List the currently supported SQL dialects and CDM versions
print(CommonDataModel::listSupportedDialects())
print(CommonDataModel::listSupportedVersions())

# Generate SQL scripts for creating OMOP CDM tables
CommonDataModel::buildRelease(
  cdmVersions = "5.4",
  targetDialects = "postgresql",
  outputfolder = base::file.path(output_Dir, "OMOP_5_4")  # Set output directory 
  )

# Set JDBC drivers path
#Sys.setenv("DATABASECONNECTOR_JAR_FOLDER" = base::file.path(data_Dir, "JDBC Driver postgresql"))

# DatabaseConnector::downloadJdbcDrivers("postgresql") # Uncomment to download JDBC drivers if not already done

## Create CDM tables
create_cdm_tables <- 
  sapply(c(cdm_schema_name,vocabulary_schema_name) , function(x){
  nn <- x 
  
  # Create connection details with additional settings
  extraSettings <- ";databaseName=omop_training;integratedSecurity=false;encrypt=false;trustServerCertificate=true;sslProtocol=TLSv1"
  
  output_folder <- base::file.path(executeDDL_Error_Dir, nn) #create output folder for individual studies
  
  cd <- DatabaseConnector::createConnectionDetails(
    dbms = "postgresql",
    server = paste0("localhost","/",database_name),   # Database name; ensure it's created in the SQL shell
    user = "postgres",
    password = Sys.getenv("postgres_password"),
    pathToDriver = base::file.path(data_Dir, "JDBC Driver postgresql"),
    extraSettings = extraSettings
    )
  
  #list tables in schema
  list_of_tables <- DatabaseConnector::dbListTables(DatabaseConnector::connect(cd), nn)
  
  out <- if (length(list_of_tables)>0) {
    print("OMOP CDM tables already generated")
    } else {
     #instantiate OMOP tables
     CommonDataModel::executeDdl(
       connectionDetails = cd,
       cdmVersion = "5.4",
       cdmDatabaseSchema = nn,  # Replace with your schema name
       executeDdl = TRUE,
       executePrimaryKey = TRUE,
       executeForeignKey = FALSE,
       errorReportFile = base::file.path(output_folder, "errorReportSql.txt")
       )
  }
  
}, simplify = FALSE
)

