TRUNCATE TABLE nids_cdm.measurement;

INSERT INTO nids_cdm.measurement (
    measurement_id,
    person_id,
    measurement_concept_id,
    measurement_date,
    measurement_datetime,
    measurement_time,
    measurement_type_concept_id,
    operator_concept_id,
    value_as_number,
    value_as_concept_id,
    unit_concept_id,
    range_low,
    range_high,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    measurement_source_value,
    measurement_source_concept_id,
    unit_source_value,
    unit_source_concept_id,
    value_source_value,
    measurement_event_id,
    meas_event_field_concept_id
)

WITH measurement_source AS (

    /* Turn measurement columns into rows */
    SELECT
        pid,
        interview_date,
        'cesd_total_score' AS variable_name,
        cesd_total_score::numeric AS value
    FROM public.stg_sample_data
    WHERE cesd_total_score IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'adult_bmi',
        adult_bmi::numeric
    FROM public.stg_sample_data
    WHERE adult_bmi IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'adult_waist',
        adult_waist::numeric
    FROM public.stg_sample_data
    WHERE adult_waist IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'adult_bp_systolic',
        adult_bp_systolic::numeric
    FROM public.stg_sample_data
    WHERE adult_bp_systolic IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'adult_bp_diastolic',
        adult_bp_diastolic::numeric
    FROM public.stg_sample_data
    WHERE adult_bp_diastolic IS NOT NULL

    UNION ALL

    SELECT
        pid,
        interview_date,
        'adult_bp_pulse',
        adult_bp_pulse::numeric
    FROM public.stg_sample_data
    WHERE adult_bp_pulse IS NOT NULL
)

SELECT

    /* Create OMOP measurement ID */
    ROW_NUMBER() OVER (
        ORDER BY p.person_id, m.interview_date, m.variable_name
    )::integer AS measurement_id,

    p.person_id,

    /* Measurement concept from Usagi */
    mc."conceptId"::integer AS measurement_concept_id,

    TO_DATE(m.interview_date, 'DD/MM/YYYY')
        AS measurement_date,

    TO_DATE(m.interview_date, 'DD/MM/YYYY')::timestamp
        AS measurement_datetime,

    '00:00:00' AS measurement_time,

    32883 AS measurement_type_concept_id,

    NULL AS operator_concept_id,

    /* Actual numeric result */
    m.value AS value_as_number,

    /* BMI category concept from Usagi */
    bmi."conceptId"::integer AS value_as_concept_id,

    /* Unit concept from Usagi */
    unit."conceptId"::integer AS unit_concept_id,

    NULL AS range_low,
    NULL AS range_high,

    p.provider_id,

    vd.visit_occurrence_id,

    vd.visit_detail_id,

    /* store the numeric value here */
    m.value::varchar(50) AS measurement_source_value,

    NULL AS measurement_source_concept_id,

    /* Unit description from Usagi */
    unit."ADD_INFO:variable_description"::varchar(50)
        AS unit_source_value,

    NULL AS unit_source_concept_id,

    /* BMI category, when available */
    CASE
        WHEN m.variable_name = 'adult_bmi'
        THEN s.adult_bmi_group::varchar(50)
        ELSE NULL
    END AS value_source_value,

    NULL AS measurement_event_id,

    NULL AS meas_event_field_concept_id


FROM measurement_source m


/* Get OMOP person */
INNER JOIN nids_cdm.person p
    ON m.pid::varchar(50) = p.person_source_value


/* Get measurement concept from Usagi */
LEFT JOIN public.stg_usagi_mapping mc
    ON m.variable_name = mc."ADD_INFO:variable_name"
   AND mc."domainId" = 'Measurement'
   AND mc."mappingStatus" = 'APPROVED'


/* Get unit concept from Usagi */
LEFT JOIN public.stg_usagi_mapping unit
    ON m.variable_name = unit."ADD_INFO:variable_name"
   AND unit."domainId" = 'Unit'
   AND unit."mappingStatus" = 'APPROVED'


/* Link measurement to Visit Detail */
INNER JOIN nids_cdm.visit_detail vd
    ON p.person_id = vd.person_id
   AND TO_DATE(m.interview_date, 'DD/MM/YYYY')
       = vd.visit_detail_start_date
   AND p.provider_id = vd.provider_id


/* Get BMI category from original source */
LEFT JOIN public.stg_sample_data s
    ON m.pid = s.pid
   AND m.interview_date = s.interview_date


/* Map BMI category to OMOP concept */
LEFT JOIN public.stg_usagi_mapping bmi
    ON s.adult_bmi_group = bmi."sourceName"
   AND bmi."ADD_INFO:variable_name" = 'adult_bmi_group'
   AND bmi."mappingStatus" = 'APPROVED';



