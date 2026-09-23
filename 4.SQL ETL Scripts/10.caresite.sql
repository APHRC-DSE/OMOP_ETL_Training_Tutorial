/*The CARE_SITE table contains a list of uniquely identified institutional (physical or organizational) units 
where healthcare delivery is practiced (offices, wards, hospitals, clinics, etc.). */
TRUNCATE TABLE nids_cdm.care_site;


/* Load CARE_SITE */
INSERT INTO nids_cdm.care_site (
    care_site_id,
    care_site_name,
    place_of_service_concept_id,
    location_id,
    care_site_source_value,
    place_of_service_source_value
)

SELECT

    /* Create a unique care site ID */
    ROW_NUMBER() OVER (ORDER BY s.prov2001)::integer
        AS care_site_id,

    /* Producer becomes the care site name */
    s.producer AS care_site_name,

    /* Home Visit concept id */
    581476 AS place_of_service_concept_id,

    /* Get location ID from LOCATION table */
    l.location_id,

    /* Province becomes the care site source value */
    s.prov2001 AS care_site_source_value,

    /* No source value available */
    NULL AS place_of_service_source_value

FROM (
    /* One producer/province combination */
    SELECT DISTINCT
        prov2001,
        producer
    FROM public.stg_sample_data
    WHERE prov2001 IS NOT NULL
) s

/* Match each province to the LOCATION table */
INNER JOIN nids_cdm.location l
    ON s.prov2001 = l.location_source_value;