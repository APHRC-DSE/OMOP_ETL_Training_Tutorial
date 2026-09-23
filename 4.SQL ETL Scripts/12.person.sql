/*This table serves as the central identity management for all Persons in the database. It contains 
records that uniquely identify each person or patient, and some demographic information. */

TRUNCATE TABLE nids_cdm.person;

INSERT INTO nids_cdm.person (
    person_id,
    gender_concept_id,
    year_of_birth,
    month_of_birth,
    day_of_birth,
    birth_datetime,
    race_concept_id,
    ethnicity_concept_id,
    location_id,
    provider_id,
    care_site_id,
    person_source_value,
    gender_source_value,
    gender_source_concept_id,
    race_source_value,
    race_source_concept_id,
    ethnicity_source_value,
    ethnicity_source_concept_id
)

WITH person_source AS (

    /* Keep one record for each participant */
    SELECT DISTINCT ON (s.pid)
        s.pid,
        s.date_of_birth,
        s.best_gen,
        s.best_race,
        s.prov2001,
        s.interviewer_id

    FROM public.stg_sample_data s

    WHERE s.pid IS NOT NULL
      AND s.date_of_birth IS NOT NULL

    ORDER BY s.pid, s.wave_id
)

SELECT

    /* Create OMOP person ID */
    ROW_NUMBER() OVER (ORDER BY ps.pid)::integer
        AS person_id,

    /* Gender concept from Usagi */
    COALESCE(ug."conceptId"::integer, 4214687)
        AS gender_concept_id,

    /* Date of birth */
    EXTRACT(
        YEAR FROM TO_DATE(ps.date_of_birth, 'DD/MM/YYYY')
    )::integer AS year_of_birth,

    EXTRACT(
        MONTH FROM TO_DATE(ps.date_of_birth, 'DD/MM/YYYY')
    )::integer AS month_of_birth,

    EXTRACT(
        DAY FROM TO_DATE(ps.date_of_birth, 'DD/MM/YYYY')
    )::integer AS day_of_birth,

    TO_DATE(ps.date_of_birth, 'DD/MM/YYYY')::timestamp
        AS birth_datetime,

    /* Race concept from Usagi */
    ur."conceptId"::integer
        AS race_concept_id,

    /* Sub-Saharan Africa */
    1547281 AS ethnicity_concept_id,

    cs.location_id,

    pr.provider_id,

    cs.care_site_id,

    /* Original participant ID */
    ps.pid::varchar(50)
        AS person_source_value,

    ps.best_gen::varchar(50)
        AS gender_source_value,

    0 AS gender_source_concept_id,

    ps.best_race::varchar(50)
        AS race_source_value,

    0 AS race_source_concept_id,

    'Subsaharan Africa'::varchar(50)
        AS ethnicity_source_value,

    0 AS ethnicity_source_concept_id


FROM person_source ps


/* Get gender concept from Usagi */
LEFT JOIN public.stg_usagi_mapping ug
    ON ps.best_gen = ug."sourceName"
   AND ug."ADD_INFO:variable_name" = 'best_gen'
   AND ug."mappingStatus" = 'APPROVED'


/* Get race concept from Usagi */
LEFT JOIN public.stg_usagi_mapping ur
    ON ps.best_race = ur."sourceName"
   AND ur."ADD_INFO:variable_name" = 'best_race'
   AND ur."mappingStatus" = 'APPROVED'


/* Get care site and location */
INNER JOIN nids_cdm.care_site cs
    ON ps.prov2001 = cs.care_site_source_value


/* Get provider */
INNER JOIN nids_cdm.provider pr
    ON ps.interviewer_id::varchar(50) = pr.provider_source_value
   AND cs.care_site_id = pr.care_site_id;