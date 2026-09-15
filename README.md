# OMOP_ETL_Training_Tutorial
This repository contains a documentation tutorial on how to ETL a sample population survey data to an OMOP database instance

## Requirements

### Hardware
A laptop/desktop with the following specifications is recommended:

- **Processor:** Intel Core i5 or higher (higher core count is beneficial for parallel processing)
- **RAM:** 16GB (recommended for most OHDSI workloads). If you anticipate running multiple containers or handling large datasets, consider upgrading to 32GB.
- **Storage:** Minimum 500GB, but more (1TB) is better with a Solid-State Drive (SSD)
- **Operating System:** Windows 10 version 2004 and higher (Build 19041 and higher) or Windows 11. This allows you to install the Windows Subsystem for Linux (WSL) and WSL 2 using a single, streamlined command.

### Software

Download and install

- [Java 1.8 or higher](https://www.java.com/en/). But preferably [Java JDK](https://www.oracle.com/africa/java/technologies/downloads/)
- [White rabbit and Rabbit in a hat](https://github.com/OHDSI/WhiteRabbit)
- Athena is a web-based resource tool for OMOP vocabulary. [Link to Register and access](https://athena.ohdsi.org/search-terms/start)
- [Usagi](https://github.com/OHDSI/Usagi)
- [DBMS(PostgreSQL)](https://www.postgresql.org/download/)
- [**R software**](https://www.r-project.org/), followed by [**Rtools**](https://cran.r-project.org/bin/windows/Rtools/) corresponding to your R version then [**RStudio/Posit IDE**](https://posit.co/download/rstudio-desktop/).

## Repo Structure

Inspired by [Cookie Cutter Data Science](https://github.com/drivendata/cookiecutter-data-science).

```
├── LICENSE
├── README.md              <- The top-level README for users.
│
├── Presentations           <- Folder for session presentations
│
├── OHDSI Tools Installation   <- Folder for OHDSI OMOP Tools Installation Guide 
│
├── Data                   <- Folder for the sample data and its data dictionary 
│
├── Usagi Mapping          <- Folder for the source code list and generated Usagi concept list
│
├── SQL ETL Scripts     <- SQL ETL scripts for standardizing the source sample data to OMOP-CDM
│   ├── data
│   ├── 1.scan_report
│   ├── 2.source_code_list
│   ├── 3.usagi_concept
│   ├── 4.mapping
│   ├── 5.etl_to_omop
│   ├── 6.dqd
│   ├── 7.achilles_results           
│   └── 8.atlas_analysis 
│
├── R ETL Scripts      <- R ETL scripts for standardizing the source sample data to OMOP-CDM
│   ├── data
│   ├── Output
│   ├── 1.setup
│   ├── 2.data_processing
│   ├── 3.scan_report
│   ├── 4.source_code_list
│   ├── 5.usagi_concept
│   ├── 6.mapping
│   ├── 7.etl_to_omop
│   ├── 8.dqd
│   ├── 9.achilles_results           
│   └── 10.atlas_analysis
│
├── Atlas Installation   <- Folder for Configuration of Atlas
│   ├── 1.WSL Installation
│   ├── 2.Docker Installation
│   ├── 3.OHDSI-Broadsea_PgAdmin-Container-Atlas-Configuration          
│   └── 4.Restore-CDM-to-AtlasDB_Generate-Results_WebAPIConfiguration    
│
└──
```

## Sample Data

The sample data used for the ETL is available from the [**Data First Repository**](https://www.datafirst.uct.ac.za/) under the **National Income Dynamics Study (NIDS)** collection via identifiers https://doi.org/10.25828/e7w9-m033, https://doi.org/10.25828/j1h1-5m16, https://doi.org/10.25828/7pgq-q106, https://doi.org/10.25828/f4ws-8a78, https://doi.org/10.25828/fw3h-v708. One needs to register and request permission to utilize the publicly available datasets in the Repository.

Records from all five survey waves were merged into a longitudinal dataset and subsequently pre-processed prior to ETL.

### Data Pre-Processing 
The data were restricted to individuals aged 15 years and older who completed the Adult Questionnaire and were successfully interviewed in both the household and adult survey components. Participants with missing CES-D depression scores were excluded.

To ensure complete longitudinal follow-up, only participants with observations in all five survey waves were included. A random 10% sample of eligible participants was then selected using a fixed random seed to support reproducibility. Interview dates were reconstructed from survey date components (day, month, year), and dates of birth were estimated using reported age at interview. For each participant, the earliest available non-missing estimated date of birth was used consistently across all waves. Age at interview was subsequently recalculated using the derived date of birth and interview date, and categorized into four age groups: 15–24 years, 25–39 years, 40–64 years, and 65 years and above.

The final sample dataset contained participant identifiers, survey wave information, interview dates, demographic characteristics (sex, race, province, education, marital status, occupation, and relationship status), mental health indicators including CES-D measures, anthropometric and cardiovascular measurements (body mass index, waist circumference, blood pressure, and pulse rate), and self-reported chronic health conditions including tuberculosis, hypertension, diabetes, stroke, asthma, heart disease, cancer, HIV/AIDS, and epilepsy. Metadata fields identifying the country (South Africa) and data producer (Southern Africa Labour and Development Research Unit) were also retained to support provenance and ETL documentation.

## Database Structure

Create a database in PostgreSQL named `omop_training`.

Then, create 3 schemas
- cdm_schema - `nids_cdm`
- results_schema - `nids_results`
- vocabulary_schema - `vocabulary`

> [!NOTE]
> If you're using PostgreSQL as the ETL tool, you will need to create an additional schema for the data named `nids_data`. If you're using R, the 3 schemas are enough, since one will pre-load the data into the R environment.
