/* ============================================================
   VISIT_OCCURRENCE TABLE
   The VISIT_OCCURRENCE table keeps information about each encounter a person has with the healthcare/study system.
   Create one visit for each participant interview
   ============================================================ */

/* ============================================================
   VISIT_OCCURRENCE TABLE

   One interview/wave = one visit.
   ============================================================ */


/* Remove old records */
TRUNCATE TABLE nids_cdm.visit_occurrence;


/* Load interviews into VISIT_OCCURRENCE */
INSERT INTO nids_cdm.visit_occurrence (
    visit_occurrence_id,
    person_id,
    visit_concept_id,
    visit_start_date,
    visit_start_datetime,
    visit_end_date,
    visit_end_datetime,
    visit_type_concept_id,
    provider_id,
    care_site_id,
    visit_source_value,
    visit_source_concept_id,
    admitted_from_concept_id,
    admitted_from_source_value,
    discharged_to_concept_id,
    discharged_to_source_value,
    preceding_visit_occurrence_id
)

SELECT

    /* Give every interview a unique Visit ID */
    ROW_NUMBER() OVER (
        ORDER BY s.pid, s.wave_id
    )::integer AS visit_occurrence_id,


    /* OMOP person ID */
    p.person_id,


    /* Home Visit */
    581476 AS visit_concept_id,


    /* Interview date = visit start date */
    TO_DATE(
        s.interview_date,
        'DD/MM/YYYY'
    ) AS visit_start_date,


    /* Visit start datetime */
    TO_DATE(
        s.interview_date,
        'DD/MM/YYYY'
    )::timestamp AS visit_start_datetime,


    /* Same-day visit */
    TO_DATE(
        s.interview_date,
        'DD/MM/YYYY'
    ) AS visit_end_date,


    /* Visit end datetime */
    TO_DATE(
        s.interview_date,
        'DD/MM/YYYY'
    )::timestamp AS visit_end_datetime,


    /* Visit record type */
    32883 AS visit_type_concept_id,


    /* Provider/interviewer from PERSON */
    p.provider_id,


    /* Care site from PERSON */
    p.care_site_id,


    /* Description of the source encounter */
    'National Household Panel Survey Interview'::varchar(50)
        AS visit_source_value,


    /* No source concept ID */
    0 AS visit_source_concept_id,


    /* Home Visit */
    581476 AS admitted_from_concept_id,

    'Home Visit'::varchar(50)
        AS admitted_from_source_value,


    /* Home Visit */
    581476 AS discharged_to_concept_id,

    'Home Visit'::varchar(50)
        AS discharged_to_source_value,


    /*
       Find the previous visit for the same person.

       COUNT counts how many visits this person has had
       up to the previous wave.

       If this is the first visit, return NULL.
    */
    CASE
        WHEN ROW_NUMBER() OVER (
            PARTITION BY p.person_id
            ORDER BY s.wave_id
        ) = 1
        THEN NULL

        ELSE (
            ROW_NUMBER() OVER (
                ORDER BY s.pid, s.wave_id
            ) - 1
        )::integer
    END AS preceding_visit_occurrence_id


/* Start from the source interviews */
FROM public.stg_sample_data s


/*
   Match the original participant ID to PERSON
   so that we can get the OMOP person_id,
   provider_id and care_site_id.
*/
INNER JOIN nids_cdm.person p
    ON s.pid::varchar(50) = p.person_source_value


/* Only create visits for interviews that have a date */
WHERE NULLIF(s.interview_date, '') IS NOT NULL


/* Keep visits in participant/wave order */
ORDER BY s.pid, s.wave_id;