
/* The LOCATION table represents a generic way to capture physical location or address information of Persons and Care Sites.*/
TRUNCATE TABLE nids_cdm.location;

INSERT INTO nids_cdm.location (
    location_id,
    address_1,
    address_2,
    city,
    state,
    zip,
    county,
    location_source_value,
    country_concept_id,
    country_source_value,
    latitude,
    longitude
)

SELECT
    /* Create a unique ID for each province */
    ROW_NUMBER() OVER (ORDER BY s.prov2001) AS location_id,

    /* Province */
    s.prov2001 AS address_1,

    /* Not available in the source */
    NULL AS address_2,
    NULL AS city,
    NULL AS state,
    NULL AS zip,
    NULL AS county,

    /* Keep original province */
    s.prov2001 AS location_source_value,

    /* Get the country concept ID from Usagi */
    u."conceptId"::integer AS country_concept_id,

    /* Keep original country */
    s.country AS country_source_value,

    /* Latitude */
    CASE
        WHEN s.prov2001 = 'KwaZulu-Natal' THEN -28.914195
        WHEN s.prov2001 = 'Eastern Cape' THEN -32.0756215
        WHEN s.prov2001 = 'Western Cape' THEN -38.2812472
        WHEN s.prov2001 = 'Limpopo' THEN -23.7465763
        WHEN s.prov2001 = 'North West' THEN -26.3456605
        WHEN s.prov2001 = 'Mpumalanga' THEN -25.7148848
        WHEN s.prov2001 = 'Gauteng' THEN -26.3090186
        WHEN s.prov2001 = 'Northern Cape' THEN -28.7404099
        WHEN s.prov2001 = 'Free State' THEN -28.6509164
    END AS latitude,

    /* Longitude */
    CASE
        WHEN s.prov2001 = 'KwaZulu-Natal' THEN 28.2396071
        WHEN s.prov2001 = 'Eastern Cape' THEN 23.8229345
        WHEN s.prov2001 = 'Western Cape' THEN 17.3722937
        WHEN s.prov2001 = 'Limpopo' THEN 26.5028853
        WHEN s.prov2001 = 'North West' THEN 22.820788
        WHEN s.prov2001 = 'Mpumalanga' THEN 27.4956626
        WHEN s.prov2001 = 'Gauteng' THEN 27.647979
        WHEN s.prov2001 = 'Northern Cape' THEN 15.7029934
        WHEN s.prov2001 = 'Free State' THEN 24.4232204
    END AS longitude

FROM (
    /* Get one record for each province */
    SELECT DISTINCT
        prov2001,
        country
    FROM public.stg_sample_data
    WHERE prov2001 IS NOT NULL
) s

/* Connect the source country to its Usagi mapping */
LEFT JOIN public.stg_usagi_mapping u
    ON s.country = u."sourceName"
    AND u."ADD_INFO:variable_name" = 'country'
    AND u."mappingStatus" = 'APPROVED';