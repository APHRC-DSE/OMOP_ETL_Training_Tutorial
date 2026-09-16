/* ============================================================
   VISIT_DETAIL TABLE

   VISIT_DETAIL stores more detailed information about an encounter.

   In this dataset, each participant interview is represented
   as one Visit Detail and is connected to the Visit Occurrence
   that we created earlier.
   ============================================================ */

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


/* ============================================================
   Prepare the Visit Detail records
   ============================================================ */

WITH visit_details AS (

    SELECT

        /*
           Create a unique sequential Visit Detail ID
           for every interview/wave.
        */
        ROW_NUMBER() OVER (
            ORDER BY s.pid, s.wave_id
        )::integer AS visit_detail_id,


        /*
           Get the OMOP person_id from PERSON.
           This identifies who had the interview.
        */
        p.person_id,


        /* Keep source fields needed during the transformation */
        s.pid,
        s.wave_id,


        /*
           Convert the source interview date from text
           into a PostgreSQL DATE.
        */
        TO_DATE(
            NULLIF(s.interview_date, ''),
            'DD/MM/YYYY'
        ) AS interview_date,


        /*
           Provider and care site were already assigned
           when the PERSON table was created.
        */
        p.provider_id,
        p.care_site_id,


        /*
           Get the visit_occurrence_id so that this
           Visit Detail can be linked to its parent visit.
        */
        vo.visit_occurrence_id


    FROM public.stg_sample_data s


    /* ========================================================
       Match the source participant to PERSON
       ======================================================== */

    INNER JOIN nids_cdm.person p
        ON s.pid::varchar(50) = p.person_source_value


    /* ========================================================
       Match the interview to VISIT_OCCURRENCE
       =======================================================   */
    INNER JOIN nids_cdm.visit_occurrence vo
        ON p.person_id = vo.person_id

       /* Same interview date */
       AND TO_DATE(
               NULLIF(s.interview_date, ''),
               'DD/MM/YYYY'
           ) = vo.visit_start_date

       /* Same provider/interviewer */
       AND p.provider_id = vo.provider_id

       /* Same care site */
       AND p.care_site_id = vo.care_site_id


    /*
       An interview must have a date
       to be included as a Visit Detail.
    */
    WHERE NULLIF(s.interview_date, '') IS NOT NULL
),


/* ============================================================
   Find the previous Visit Detail
   ============================================================ */

details_with_previous AS (

    SELECT
        *,
        LAG(visit_detail_id) OVER (
            PARTITION BY person_id
            ORDER BY wave_id
        )::integer AS preceding_visit_detail_id

    FROM visit_details
)

/* ============================================================
   Create the final VISIT_DETAIL records
   ============================================================ */

SELECT

    /* Unique ID for this Visit Detail */
    visit_detail_id,


    /* OMOP person who had the interview */
    person_id,


    /* Standard concept used for Home Visit */
    581476 AS visit_detail_concept_id,


    /* Interview date becomes the Visit Detail start date */
    interview_date AS visit_detail_start_date,


    /* Store the start date as a timestamp as well */
    interview_date::timestamp
        AS visit_detail_start_datetime,

    interview_date AS visit_detail_end_date,


    /* Store the end date as a timestamp */
    interview_date::timestamp
        AS visit_detail_end_datetime,


    /* Type concept used for this source record */
    32883 AS visit_detail_type_concept_id,


    /* Provider/interviewer associated with the participant */
    provider_id,


    /* Care site associated with the participant */
    care_site_id,


    /* Description of the encounter in the source study */
    'National Household Panel Survey Interview'::varchar(50)
        AS visit_detail_source_value,

    0 AS visit_detail_source_concept_id,


    /* Standard concept used for Home Visit */
    581476 AS admitted_from_concept_id,


    /* Preserve the admission source description */
    'Home Visit'::varchar(50)
        AS admitted_from_source_value,


    /* Preserve the discharge destination description */
    'Home Visit'::varchar(50)
      AS discharged_to_source_value,


    /* Standard concept used for Home Visit */
    581476 AS discharged_to_concept_id,

    preceding_visit_detail_id,

    NULL::integer AS parent_visit_detail_id,

    visit_occurrence_id


FROM details_with_previous

ORDER BY visit_detail_id;