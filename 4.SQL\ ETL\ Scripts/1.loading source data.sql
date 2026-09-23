DROP TABLE IF EXISTS public.stg_sample_data;

CREATE TABLE public.stg_sample_data (
    pid                     BIGINT,
    wave_id                 VARCHAR(20),
    interview_date          VARCHAR(50),
    date_of_birth           VARCHAR(50),
    prov2001                VARCHAR(100),
    best_gen                VARCHAR(50),
    best_race               VARCHAR(100),
    age_yrs                 NUMERIC,
    age_group               VARCHAR(50),
    education_status        VARCHAR(255),
    marital_status          VARCHAR(255),
    occupation_status       VARCHAR(255),

    a_rel                   VARCHAR(255),
    a_emobth                VARCHAR(255),
    a_emomnd                VARCHAR(255),
    a_emodep                VARCHAR(255),
    a_emoeff                VARCHAR(255),
    a_emohope               VARCHAR(255),
    a_emofear               VARCHAR(255),
    a_emoslp                VARCHAR(255),
    a_emohap                VARCHAR(255),
    a_emolone               VARCHAR(255),
    a_emogo                 VARCHAR(255),

    cesd_total_score        NUMERIC,
    cesd_depression         VARCHAR(255),

    adult_bmi               NUMERIC,
    adult_bmi_group         VARCHAR(100),
    adult_waist             NUMERIC,
    adult_bp_systolic       NUMERIC,
    adult_bp_diastolic      NUMERIC,
    adult_bp_pulse          NUMERIC,

    a_hltb                  VARCHAR(255),
    a_hlbp                  VARCHAR(255),
    a_hldia                 VARCHAR(255),
    a_hlstrk                VARCHAR(255),
    a_hlast                 VARCHAR(255),
    a_hlhrt                 VARCHAR(255),
    a_hlcan                 VARCHAR(255),

    hiv_aids                VARCHAR(255),
    epilepsy                VARCHAR(255),

    country                 VARCHAR(100),
    producer                VARCHAR(255),

    interviewer_id          BIGINT,
    interviewer_gender      VARCHAR(50)
);


COPY public.stg_sample_data
FROM 'your local path to sample data here' /*Change the path here to your local path of the sample data*/
WITH (
    FORMAT CSV,
    HEADER TRUE,
    DELIMITER ',',
    ENCODING 'UTF8'
);

------------------------------------------------------------------
/*Import/Export: Manual Import*/

Filename: /*Select the path here to your local path of the sample data*/

Format:
csv

Encoding:
UTF8

Under Options:

Header: Yes
Delimiter: ,
Quote: "
Escape: "

-----------------------------------------------------------------------
/*Check if the data has loaded*/

SELECT COUNT(*)
FROM public.stg_sample_data;



SELECT *
FROM public.stg_sample_data
LIMIT 10;



SELECT COUNT(DISTINCT pid) AS number_of_people
FROM public.stg_sample_data;
SELECT
    wave_id,
    COUNT(*) AS records
FROM public.stg_sample_data
GROUP BY wave_id
ORDER BY wave_id;


SELECT
    pid,
    wave_id,
    interview_date,
    date_of_birth
FROM public.stg_sample_data
LIMIT 20;



SELECT DISTINCT
    prov2001,
    country
FROM public.stg_sample_data
ORDER BY country, prov2001;
