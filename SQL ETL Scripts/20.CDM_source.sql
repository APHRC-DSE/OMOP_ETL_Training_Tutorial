 /* ============================================================
    CDM SOURCE
    Metadata describing the source data and OMOP CDM release.
    ============================================================ */

TRUNCATE TABLE nids_cdm.cdm_source;


INSERT INTO nids_cdm.cdm_source (
    cdm_source_name,
    cdm_source_abbreviation,
    cdm_holder,
    source_description,
    source_documentation_reference,
    cdm_etl_reference,
    source_release_date,
    cdm_release_date,
    cdm_version,
    cdm_version_concept_id,
    vocabulary_version
)


WITH source_dates AS (

    /* ========================================================
       Determine the earliest and latest interview dates
       in the source data.
       ======================================================== */

    SELECT
        producer,

        MIN(
            TO_DATE(interview_date, 'DD/MM/YYYY')
        ) AS min_observation_date,

        MAX(
            TO_DATE(interview_date, 'DD/MM/YYYY')
        ) AS max_observation_date

    FROM public.stg_sample_data

    GROUP BY producer
)


SELECT DISTINCT

    /* ========================================================
       Source name
       Equivalent to:
       rename(cdm_source_name = producer)
       ======================================================== */

    producer AS cdm_source_name,


    /* ========================================================
       CDM source abbreviation
       ======================================================== */

    'SALDRU - NIDS'
        AS cdm_source_abbreviation,


    /* CDM holder */

    'APHRC'
        AS cdm_holder,


    /* ========================================================
       Source description
       Equivalent to paste0() in R
       ======================================================== */

    CONCAT(
        'National Income Dynamics Study (NIDS): ',
        'National Household Panel Study from ',
        min_observation_date,
        ' to ',
        max_observation_date
    ) AS source_description,


    /* Source documentation */

    'https://saldru.uct.ac.za/nids/data-access'
        AS source_documentation_reference,


    /* ETL reference */

    'https://github.com/APHRC-DSE/OMOP_ETL_Training_Tutorial'
        AS cdm_etl_reference,


    /* Latest source date */

    max_observation_date
        AS source_release_date,


    /* Current CDM release date */

    CURRENT_DATE
        AS cdm_release_date,


    /* OMOP CDM version */

    '5.4'
        AS cdm_version,


    /* OMOP CDM 5.4.0 concept */

    756265
        AS cdm_version_concept_id,


    /* Vocabulary version */

    'v5.0 29-AUG-26'
        AS vocabulary_version


FROM source_dates;