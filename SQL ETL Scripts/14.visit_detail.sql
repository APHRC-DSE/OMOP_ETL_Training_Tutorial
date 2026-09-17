/* ============================================================
   VISIT_DETAIL TABLE

   Create one Visit Detail for every interview and connect it
   to the Visit Occurrence that was created earlier.
   ============================================================ */


/* Remove existing records before loading again */
TRUNCATE TABLE nids_cdm.visit_detail;


/* Insert transformed interview records into VISIT_DETAIL */
INSERT INTO nids_cdm.visit_detail (
    visit_detail_id,
    person_id,
    visit_detail_concept_id,
    visit_detail_start_date,
    visit_detail_start_datetime,
    visit_detail_end_date,
    visit_detail_end_datetime,
    visit_detail_type_concept_id,
    provider_id,
    care_site_id,
    visit_detail_source_value,
    visit_detail_source_concept_id,
    admitted_from_concept_id,
    admitted_from_source_value,
    discharged_to_source_value,
    discharged_to_concept_id,
    preceding_visit_detail_id,
    parent_visit_detail_id,
    visit_occurrence_id
)

SELECT

    /* Create a unique Visit Detail ID for every interview */
    ROW_NUMBER() OVER (
        ORDER BY s.pid, s.wave_id
    )::integer AS visit_detail_id,


    /* Get the OMOP person ID */
    p.person_id,

   /* Standard concept used for Home Visit */
581476 AS visit_detail_concept_id,


/* Interview date becomes the Visit Detail start date */
TO_DATE(s.interview_date, 'DD/MM/YYYY')
    AS visit_detail_start_date,


/* Start date as a timestamp */
TO_DATE(s.interview_date, 'DD/MM/YYYY')::timestamp
    AS visit_detail_start_datetime,


/* Same-day encounter: end date = start date */
TO_DATE(s.interview_date, 'DD/MM/YYYY')
    AS visit_detail_end_date,


/* End date as a timestamp */
TO_DATE(s.interview_date, 'DD/MM/YYYY')::timestamp
    AS visit_detail_end_datetime,

    /* Type concept used for this source record */
    32883 AS visit_detail_type_concept_id,


    /* Provider/interviewer already linked through PERSON */
    p.provider_id,


    /* Care site already linked through PERSON */
    p.care_site_id,


    /* Description of the encounter */
    'National Household Panel Survey Interview'::varchar(50)
        AS visit_detail_source_value,


    /* No source concept ID for the source description */
    0 AS visit_detail_source_concept_id,


    /* Standard concept used for Home Visit */
    581476 AS admitted_from_concept_id,


    /* Admission source description */
    'Home Visit'::varchar(50)
        AS admitted_from_source_value,


    /* Discharge destination description */
    'Home Visit'::varchar(50)
        AS discharged_to_source_value,


    /* Standard concept used for Home Visit */
    581476 AS discharged_to_concept_id,


    /*
       Find the previous Visit Detail for the same person.

       The first interview for each person gets NULL.
       For later interviews, the previous Visit Detail ID
       is one less than the current generated ID.
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
    END AS preceding_visit_detail_id,


    /* No parent Visit Detail */
    NULL::integer AS parent_visit_detail_id,


    /* Connect this detail to its Visit Occurrence */
    vo.visit_occurrence_id

/* Start with the source interviews */
FROM public.stg_sample_data s


/* ============================================================
   Match the participant to PERSON
   ============================================================ */

/*
   Match the original pid to person_source_value
   to obtain the OMOP person_id, provider_id and care_site_id.
*/
INNER JOIN nids_cdm.person p
    ON s.pid::varchar(50) = p.person_source_value


/* ============================================================
   Match the interview to VISIT_OCCURRENCE
   ============================================================ */

/*
   Find the Visit Occurrence belonging to this interview
   using the person, interview date, provider and care site.
*/
/* Match the interview to its Visit Occurrence */
INNER JOIN nids_cdm.visit_occurrence vo
    ON p.person_id = vo.person_id

   /* Same interview date */
   AND TO_DATE(s.interview_date, 'DD/MM/YYYY')
       = vo.visit_start_date

   /* Same provider/interviewer */
   AND p.provider_id = vo.provider_id

   /* Same care site */
   AND p.care_site_id = vo.care_site_id


/* Only interviews with a date can become Visit Details */
WHERE s.interview_date IS NOT NULL
  AND s.interview_date <> '';
