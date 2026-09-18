library(RPostgres)
library(DBI)

working_directory

## Create database only if it does not exist
create_database_name <- if (
  !dbGetQuery(
    con,
    glue::glue("SELECT EXISTS (SELECT 1 FROM pg_database WHERE datname = '{database_name}')")
  )[[1]]
) {
  dbExecute(con, glue::glue("CREATE DATABASE {database_name}"))
}


  
