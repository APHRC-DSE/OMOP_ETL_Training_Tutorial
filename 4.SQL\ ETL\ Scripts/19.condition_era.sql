/* ============================================================
   CONDITION ERA
   Groups condition occurrences by person and condition concept.
   ============================================================ */

TRUNCATE TABLE nids_cdm.condition_era;

INSERT INTO nids_cdm.condition_era (
    condition_era_id,
    person_id,
    condition_concept_id,
    condition_era_start_date,
    condition_era_end_date,
    condition_occurrence_count
)

WITH condition_era_source AS (

    /* ========================================================
       Group condition occurrences by person and condition
       concept.
       ======================================================== */

    SELECT
        person_id,
        condition_concept_id,

        /* Earliest occurrence */
        MIN(condition_start_date)
            AS condition_era_start_date,

        /* Latest occurrence */
        MAX(condition_start_date)
            AS condition_era_end_date,

        /* Number of occurrences */
        COUNT(*)
            AS condition_occurrence_count

    FROM nids_cdm.condition_occurrence

    WHERE condition_start_date IS NOT NULL
      AND condition_concept_id IS NOT NULL

    GROUP BY
        person_id,
        condition_concept_id
)


SELECT

    /* ========================================================
       Create unique condition era ID
       ======================================================== */

    ROW_NUMBER() OVER (
        ORDER BY
            person_id,
            condition_concept_id,
            condition_era_start_date
    )::integer AS condition_era_id,

    person_id,

    condition_concept_id,

    condition_era_start_date,

    condition_era_end_date,

    condition_occurrence_count::integer

FROM condition_era_source;