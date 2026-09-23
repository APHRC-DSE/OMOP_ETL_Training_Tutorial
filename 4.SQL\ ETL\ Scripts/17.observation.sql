/* ============================================================
   OBSERVATION
   Stores categorical observations about each participant.
   ============================================================ */

TRUNCATE TABLE nids_cdm.observation;

INSERT INTO nids_cdm.observation (
    observation_id,
    person_id,
    observation_concept_id,
    observation_date,
    observation_datetime,
    observation_type_concept_id,
    value_as_number,
    value_as_string,
    value_as_concept_id,
    qualifier_concept_id,
    unit_concept_id,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    observation_source_value,
    observation_source_concept_id,
    unit_source_value,
    qualifier_source_value,
    value_source_value,
    observation_event_id,
    obs_event_field_concept_id
)


WITH observation_source AS (

    /* Turn observation columns into rows */

    SELECT
        pid,
        interview_date,
        'age_group' AS variable_name,
        age_group::varchar AS value
    FROM public.stg_sample_data
    WHERE age_group IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'education_status',
        education_status::varchar
    FROM public.stg_sample_data
    WHERE education_status IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'marital_status',
        marital_status::varchar
    FROM public.stg_sample_data
    WHERE marital_status IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'occupation_status',
        occupation_status::varchar
    FROM public.stg_sample_data
    WHERE occupation_status IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'a_rel',
        a_rel::varchar
    FROM public.stg_sample_data
    WHERE a_rel IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'a_emobth',
        a_emobth::varchar
    FROM public.stg_sample_data
    WHERE a_emobth IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'a_emomnd',
        a_emomnd::varchar
    FROM public.stg_sample_data
    WHERE a_emomnd IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'a_emodep',
        a_emodep::varchar
    FROM public.stg_sample_data
    WHERE a_emodep IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'a_emoeff',
        a_emoeff::varchar
    FROM public.stg_sample_data
    WHERE a_emoeff IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'a_emohope',
        a_emohope::varchar
    FROM public.stg_sample_data
    WHERE a_emohope IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'a_emofear',
        a_emofear::varchar
    FROM public.stg_sample_data
    WHERE a_emofear IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'a_emoslp',
        a_emoslp::varchar
    FROM public.stg_sample_data
    WHERE a_emoslp IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'a_emohap',
        a_emohap::varchar
    FROM public.stg_sample_data
    WHERE a_emohap IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'a_emolone',
        a_emolone::varchar
    FROM public.stg_sample_data
    WHERE a_emolone IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'a_emogo',
        a_emogo::varchar
    FROM public.stg_sample_data
    WHERE a_emogo IS NOT NULL
)


SELECT

    /* Create OMOP observation ID */
    ROW_NUMBER() OVER (
        ORDER BY p.person_id, o.interview_date, o.variable_name
    )::integer AS observation_id,

    p.person_id,

    /* Observation concept from Usagi */
    uo."conceptId"::integer AS observation_concept_id,

    TO_DATE(o.interview_date, 'DD/MM/YYYY')
        AS observation_date,

    TO_DATE(o.interview_date, 'DD/MM/YYYY')::timestamp
        AS observation_datetime,

    32883 AS observation_type_concept_id,


    /* Age is also available as a numeric value */
    CASE
        WHEN o.variable_name = 'age_group'
        THEN s.age_yrs::numeric
        ELSE NULL
    END AS value_as_number,


    /* Original categorical answer */
    LEFT(o.value, 59) AS value_as_string,


    /* Concept representing the categorical answer */
    uv."conceptId"::integer AS value_as_concept_id,


    NULL::integer AS qualifier_concept_id,

    NULL::integer AS unit_concept_id,

    p.provider_id,

    vd.visit_occurrence_id,

    vd.visit_detail_id,


    /* Description of the source observation */
    LEFT(
        uo."ADD_INFO:variable_description",
        49
    ) AS observation_source_value,


    NULL::integer AS observation_source_concept_id,

    NULL::varchar(50) AS unit_source_value,

    NULL::varchar(50) AS qualifier_source_value,

    LEFT(o.value, 49) AS value_source_value,


    /* Link CES-D questions to the CES-D total measurement */
    CASE
        WHEN o.variable_name IN (
            'a_emobth',
            'a_emomnd',
            'a_emodep',
            'a_emoeff',
            'a_emohope',
            'a_emofear',
            'a_emoslp',
            'a_emohap',
            'a_emolone',
            'a_emogo'
        )
        THEN m.measurement_id
        ELSE NULL
    END AS observation_event_id,


    CASE
        WHEN o.variable_name IN (
            'a_emobth',
            'a_emomnd',
            'a_emodep',
            'a_emoeff',
            'a_emohope',
            'a_emofear',
            'a_emoslp',
            'a_emohap',
            'a_emolone',
            'a_emogo'
        )
        AND m.measurement_id IS NOT NULL
        THEN 1147138
        ELSE NULL
    END AS obs_event_field_concept_id


FROM observation_source o


/* Get OMOP person */
INNER JOIN nids_cdm.person p
    ON o.pid::varchar(50) = p.person_source_value


/* Get observation concept from Usagi */
LEFT JOIN public.stg_usagi_mapping uo
    ON o.variable_name = uo."ADD_INFO:variable_name"
   AND uo."domainId" = 'Observation'
   AND uo."mappingStatus" = 'APPROVED'


/* Get categorical value concept from Usagi */
LEFT JOIN public.stg_usagi_mapping uv
    ON o.value = uv."sourceName"
   AND o.variable_name = uv."ADD_INFO:variable_name"
   AND uv."mappingStatus" = 'APPROVED'


/* Link observation to Visit Detail */
INNER JOIN nids_cdm.visit_detail vd
    ON p.person_id = vd.person_id
   AND TO_DATE(o.interview_date, 'DD/MM/YYYY')
       = vd.visit_detail_start_date
   AND p.provider_id = vd.provider_id


/* Get age in years from original source */
LEFT JOIN public.stg_sample_data s
    ON o.pid = s.pid
   AND o.interview_date = s.interview_date


/* Find the CES-D total score measurement */
LEFT JOIN nids_cdm.measurement m
    ON p.person_id = m.person_id
   AND TO_DATE(o.interview_date, 'DD/MM/YYYY')
       = m.measurement_date
   AND m.measurement_concept_id = 4164828;