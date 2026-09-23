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
├── 1.OHDS Tools Installation
│   ├── OHDSI_OMOP_Prerequisites_and_Installation_Guide.pdf
│   └── README.md
├── 2.Scan Report
│   └── ScanReport.xlsx
├── 3.Usagi Mapping
│   ├── source_code_list.xlsx
│   └── usagi_mapping_concept_list.csv
├── 4.SQL ETL Scripts
│   ├── 1.loading source data.sql
│   ├── 10.caresite.sql
│   ├── 11.provider.sql
│   ├── 12.person.sql
│   ├── 13.visit occurrence.sql
│   ├── 14.visit_detail.sql
│   ├── 15.observation period.sql
│   ├── 16.measurements.sql
│   ├── 17.observation.sql
│   ├── 18.condition_occurrence.sql
│   ├── 19.condition_era.sql
│   ├── 2.loading usagi mapping table.sql
│   ├── 20.CDM_source.sql
│   ├── 3.create_schemas.sql
│   ├── 4.cdm_schema_postgresql_5.4_ddl.sql
│   ├── 5.cdm_schema_postgresql_5.4_primary_keys.sql
│   ├── 6.vocabulary_schema_postgresql_5.4_ddl.sql
│   ├── 7.vocabulary_postgresql_5.4_primary_keys.sql
│   ├── 8.load omop vocabs.sql
│   ├── 9.location.sql
│   ├── DQD_Achilles
│   └── inspect tables.sql
├── 5.R ETL Scripts
│   ├── 1.setup
│   ├── 10.atlas_analysis
│   ├── 2.data_processing
│   ├── 3.scan_report
│   ├── 4.source_code_list
│   ├── 5.usagi_concept
│   ├── 7.etl_to_omop
│   ├── 8.dqd
│   ├── 9.achilles_results
│   ├── Output
│   ├── data
│   └── main.R
├── 6. Atlas Installation
│   ├── 1.WSL Installation
│   ├── 2.Docker Installation
│   ├── 3.OHDSI-Broadsea_PgAdmin-Container-Atlas-Configuration
│   ├── 4.Restore-CDM-to-AtlasDB_Generate-Results_WebAPIConfiguration
│   └── README.md
├── 7. Data
│   ├── data_dictionary_sample_data.csv
│   └── sample_data.csv
├── 8.Presentations
│   ├── DQD and Achilles.pdf
│   ├── Faraja_MH_OMOP_Training_Summary.pdf
│   ├── Introduction to OMOP CDM_2026.pptx
│   ├── Introduction to OMOP-OHDSI.pdf
│   ├── Introduction to SQL Scripting
│   ├── OMOP_Standardized_Vocabularies.pdf
│   ├── WhiteRabbit.pptx
│   └── placeholder.txt
├── 
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
> If you're using PostgreSQL as the ETL tool, you will use an additional schema for the data named `public`. If you're using R, the 3 schemas are enough, since one will pre-load the data into the R environment.



0 directories, 0 files
7.Data  [error opening dir]

0 directories, 0 files
