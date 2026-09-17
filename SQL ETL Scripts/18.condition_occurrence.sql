/* ============================================================
   CONDITION OCCURRENCE
   Stores participant-reported/preliminary conditions.
   ============================================================ */

TRUNCATE TABLE nids_cdm.condition_occurrence;

INSERT INTO nids_cdm.condition_occurrence (
    condition_occurrence_id,
    person_id,
    condition_concept_id,
    condition_start_date,
    condition_start_datetime,
    condition_end_date,
    condition_end_datetime,
    condition_type_concept_id,
    condition_status_concept_id,
    stop_reason,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    condition_source_value,
    condition_source_concept_id,
    condition_status_source_value
)


WITH condition_source AS (

    /* ========================================================
       Turn condition columns into rows
       ======================================================== */

    SELECT
        pid,
        interview_date,
        'cesd_depression' AS variable_name,
        cesd_depression::varchar AS value
    FROM public.stg_sample_data
    WHERE cesd_depression IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'a_hltb',
        a_hltb::varchar
    FROM public.stg_sample_data
    WHERE a_hltb IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'a_hlbp',
        a_hlbp::varchar
    FROM public.stg_sample_data
    WHERE a_hlbp IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'a_hldia',
        a_hldia::varchar
    FROM public.stg_sample_data
    WHERE a_hldia IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'a_hlstrk',
        a_hlstrk::varchar
    FROM public.stg_sample_data
    WHERE a_hlstrk IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'a_hlast',
        a_hlast::varchar
    FROM public.stg_sample_data
    WHERE a_hlast IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'a_hlhrt',
        a_hlhrt::varchar
    FROM public.stg_sample_data
    WHERE a_hlhrt IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'a_hlcan',
        a_hlcan::varchar
    FROM public.stg_sample_data
    WHERE a_hlcan IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'hiv_aids',
        hiv_aids::varchar
    FROM public.stg_sample_data
    WHERE hiv_aids IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'epilepsy',
        epilepsy::varchar
    FROM public.stg_sample_data
    WHERE epilepsy IS NOT NULL
)


SELECT

    /* ========================================================
       Create OMOP condition occurrence ID
       ======================================================== */

    ROW_NUMBER() OVER (
        ORDER BY
            p.person_id,
            TO_DATE(c.interview_date, 'DD/MM/YYYY'),
            c.variable_name
    )::integer AS condition_occurrence_id,


    p.person_id,


    /* ========================================================
       Condition concept from Usagi
       ======================================================== */

    uc."conceptId"::integer AS condition_concept_id,


    /* Condition start date */

    TO_DATE(
        c.interview_date,
        'DD/MM/YYYY'
    ) AS condition_start_date,


    /* Condition start datetime */

    TO_DATE(
        c.interview_date,
        'DD/MM/YYYY'
    )::timestamp AS condition_start_datetime,


    /* No end date available */

    NULL::date AS condition_end_date,

    NULL::timestamp AS condition_end_datetime,


    /* Survey */

    32883 AS condition_type_concept_id,


    /* Preliminary diagnosis */

    32899 AS condition_status_concept_id,


    NULL::varchar(20) AS stop_reason,


    p.provider_id,

    vd.visit_occurrence_id,

    vd.visit_detail_id,


    /* ========================================================
       Original source description
       ======================================================== */

    LEFT(
        uc."ADD_INFO:variable_description",
        49
    ) AS condition_source_value,


    NULL::integer AS condition_source_concept_id,

    NULL::varchar(50) AS condition_status_source_value


FROM condition_source c


/* ============================================================
   Get OMOP person
   ============================================================ */

INNER JOIN nids_cdm.person p
    ON c.pid::varchar(50) = p.person_source_value


/* ============================================================
   Get condition concept from Usagi
   ============================================================ */

INNER JOIN public.stg_usagi_mapping uc
    ON c.variable_name =
       uc."ADD_INFO:variable_name"

   AND uc."domainId" = 'Condition'

   AND uc."mappingStatus" = 'APPROVED'


/* ============================================================
   Keep only participants who answered "Yes"

   This is equivalent to:

       filter(value %in% "Yes")
   ============================================================ */

   AND c.value = 'Yes'


/* ============================================================
   Link condition to Visit Detail
   ============================================================ */

INNER JOIN nids_cdm.visit_detail vd
    ON p.person_id = vd.person_id

   AND TO_DATE(
       c.interview_date,
       'DD/MM/YYYY'
   ) = vd.visit_detail_start_date

   AND p.provider_id = vd.provider_id;