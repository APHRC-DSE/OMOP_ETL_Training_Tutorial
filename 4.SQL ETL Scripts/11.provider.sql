/*The PROVIDER table contains a list of uniquely identified healthcare providers; duplication is not allowed.
 These are individuals providing hands-on healthcare to patients,such as physicians, nurses, midwives, physical therapists etc.*/

TRUNCATE TABLE nids_cdm.provider;

INSERT INTO nids_cdm.provider (
    provider_id,
    provider_name,
    npi,
    dea,
    specialty_concept_id,
    care_site_id,
    year_of_birth,
    gender_concept_id,
    provider_source_value,
    specialty_source_value,
    specialty_source_concept_id,
    gender_source_value,
    gender_source_concept_id
)

SELECT

    /* Create a new OMOP provider ID */
    ROW_NUMBER() OVER (
        ORDER BY c.care_site_id, s.interviewer_id
    )::integer AS provider_id,

    /* Not available in source */
    NULL AS provider_name,
    NULL AS npi,
    NULL AS dea,

    /* Concept id for Research data collection */
    4303445 AS specialty_concept_id,

    /* Link interviewer to the care site in their province */
    c.care_site_id,

    /* Not available in source */
    NULL AS year_of_birth,

    /* Get Male/Female concept ID from Usagi */
    u."conceptId"::integer AS gender_concept_id,

    /* Keep original interviewer ID */
    s.interviewer_id AS provider_source_value,

    /* use "National Household Panel Survey" as specialty_source_value*/
    'National Household Panel Survey'
        AS specialty_source_value,

    0 AS specialty_source_concept_id,

    /* Keep original gender */
    s.interviewer_gender AS gender_source_value,

    0 AS gender_source_concept_id

FROM (

    /* Get each unique interviewer and province */
    SELECT DISTINCT
        prov2001,
        interviewer_id,
        interviewer_gender

    FROM public.stg_sample_data

    WHERE prov2001 IS NOT NULL
      AND interviewer_id IS NOT NULL

) s


/* Get gender concept from approved Usagi mapping */
LEFT JOIN public.stg_usagi_mapping u
    ON s.interviewer_gender = u."sourceName"
   AND u."ADD_INFO:variable_name" = 'interviewer_gender'
   AND u."mappingStatus" = 'APPROVED'


/* Connect interviewer province to CARE_SITE */
INNER JOIN nids_cdm.care_site c
    ON s.prov2001 = c.care_site_source_value

ORDER BY c.care_site_id, s.interviewer_id;