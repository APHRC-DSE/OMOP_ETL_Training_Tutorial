----------------------------------------------------------------------

--1. LOCATION
-- Check how many locations were loaded
SELECT COUNT(*) AS total_locations
FROM nids_cdm.location;

-- View the locations
SELECT
    location_id,
    location_source_value,
    country_source_value,
    latitude,
    longitude
FROM nids_cdm.location
ORDER BY location_id;

----------------------------------------------------------------------
--2. CARE_SITE
-- Check how many care sites were loaded
SELECT COUNT(*) AS total_care_sites
FROM nids_cdm.care_site;

-- Check which location each care site belongs to
SELECT
    cs.care_site_id,
    cs.care_site_name,
    cs.care_site_source_value,
    l.location_source_value
FROM nids_cdm.care_site cs
INNER JOIN nids_cdm.location l
    ON cs.location_id = l.location_id
ORDER BY cs.care_site_id;

----------------------------------------------------------------------
--3. PROVIDER
-- Check how many providers were loaded
SELECT COUNT(*) AS total_providers
FROM nids_cdm.provider;

-- Check each provider and their care site
SELECT
    pr.provider_id,
    pr.provider_source_value,
    pr.gender_source_value,
    pr.gender_concept_id,
    cs.care_site_name,
    cs.care_site_source_value
FROM nids_cdm.provider pr
INNER JOIN nids_cdm.care_site cs
    ON pr.care_site_id = cs.care_site_id
ORDER BY pr.provider_id;

----------------------------------------------------------------------
--4. PERSON
-- Check how many participants were loaded
SELECT COUNT(*) AS total_people
FROM nids_cdm.person;

-- View participants and their linked provider/care site
SELECT
    p.person_id,
    p.person_source_value,
    p.gender_source_value,
    p.gender_concept_id,
    p.race_source_value,
    p.race_concept_id,
    p.year_of_birth,
    p.provider_id,
    p.care_site_id
FROM nids_cdm.person p
ORDER BY p.person_id
LIMIT 20;

----------------------------------------------------------------------
--5. VISIT_OCCURRENCE
-- Check how many visits/interviews were loaded
SELECT COUNT(*) AS total_visits
FROM nids_cdm.visit_occurrence;

-- View the sequence of visits for participants
SELECT
    visit_occurrence_id,
    person_id,
    visit_start_date,
    provider_id,
    care_site_id,
    preceding_visit_occurrence_id
FROM nids_cdm.visit_occurrence
ORDER BY person_id, visit_start_date
LIMIT 30;

/*The second query is especially useful because you should see something like:

person_id   visit_id   date          previous_visit
1           1          2008-04-03    NULL
1           2          2010-07-27    1
1           3          2012-07-09    2 */


----------------------------------------------------------------------
--6. VISIT_DETAIL
-- Check how many Visit Details were loaded
SELECT COUNT(*) AS total_visit_details
FROM nids_cdm.visit_detail;

-- Check that Visit Details are linked to Visit Occurrences
SELECT
    vd.visit_detail_id,
    vd.person_id,
    vd.visit_detail_start_date,
    vd.visit_occurrence_id,
    vd.preceding_visit_detail_id
FROM nids_cdm.visit_detail vd
ORDER BY vd.person_id, vd.visit_detail_start_date
LIMIT 30;

----------------------------------------------------------------------
--7. OBSERVATION_PERIOD
-- Check how many observation periods were created
SELECT COUNT(*) AS total_observation_periods
FROM nids_cdm.observation_period;

-- See the period during which each person was observed
SELECT
    person_id,
    observation_period_start_date,
    observation_period_end_date
FROM nids_cdm.observation_period
ORDER BY person_id
LIMIT 20;

/*For your dataset, this should help demonstrate that:

First interview ─────────────────── Last interview
       │                                  │
       └──── Observation Period ───────────┘*/

----------------------------------------------------------------------      
--8. MEASUREMENT
-- Check how many measurements were loaded
SELECT COUNT(*) AS total_measurements
FROM nids_cdm.measurement;

-- View some measurements and the visits they belong to
SELECT
    m.measurement_id,
    m.person_id,
    m.measurement_concept_id,
    m.measurement_date,
    m.value_as_number,
    m.value_as_concept_id,
    m.unit_concept_id,
    m.visit_occurrence_id,
    m.visit_detail_id
FROM nids_cdm.measurement m
ORDER BY m.person_id, m.measurement_date
LIMIT 30;

----------------------------------------------------------------------
--9. OBSERVATION
-- Check how many observations were loaded
SELECT COUNT(*) AS total_observations
FROM nids_cdm.observation;

-- View observations and their values
SELECT
    o.observation_id,
    o.person_id,
    o.observation_concept_id,
    o.observation_date,
    o.value_as_string,
    o.value_as_number,
    o.value_as_concept_id,
    o.visit_occurrence_id,
    o.visit_detail_id
FROM nids_cdm.observation o
ORDER BY o.person_id, o.observation_date
LIMIT 30;