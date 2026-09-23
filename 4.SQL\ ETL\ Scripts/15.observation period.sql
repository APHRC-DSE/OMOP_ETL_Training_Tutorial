/* ============================================================
   OBSERVATION_PERIOD
   Defines the period during which each person is observed.
   ============================================================ */

TRUNCATE TABLE nids_cdm.observation_period;

INSERT INTO nids_cdm.observation_period (
    observation_period_id,
    person_id,
    observation_period_start_date,
    observation_period_end_date,
    period_type_concept_id
)

SELECT

    /* Create one Observation Period ID per person */
    ROW_NUMBER() OVER (
        ORDER BY p.person_id
    )::integer AS observation_period_id,

    p.person_id,

    /* First interview = start of observation */
    MIN(
        TO_DATE(s.interview_date, 'DD/MM/YYYY')
    ) AS observation_period_start_date,

    /* Last interview = end of observation */
    MAX(
        TO_DATE(s.interview_date, 'DD/MM/YYYY')
    ) AS observation_period_end_date,

    /* Observation period type */
    32883 AS period_type_concept_id


FROM public.stg_sample_data s


/* Match source participant to OMOP PERSON */
INNER JOIN nids_cdm.person p
    ON s.pid::varchar(50) = p.person_source_value


/* Drop records without an interview date */
WHERE s.interview_date IS NOT NULL
  AND s.interview_date <> ''


/* Create one observation period per person */
GROUP BY p.person_id;