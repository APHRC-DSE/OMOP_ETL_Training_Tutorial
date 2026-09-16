DROP TABLE IF EXISTS public.stg_usagi_mapping;

CREATE TABLE public.stg_usagi_mapping (
    "sourceCode"                     BIGINT,
    "sourceName"                     TEXT,
    "sourceFrequency"                BIGINT,
    "sourceAutoAssignedConceptIds"   TEXT,
    "ADD_INFO:variable_name"         TEXT,
    "ADD_INFO:variable_description"  TEXT,
    "matchScore"                     NUMERIC,
    "mappingStatus"                  TEXT,
    "equivalence"                    TEXT,
    "statusSetBy"                    TEXT,
    "statusSetOn"                    BIGINT,
    "conceptId"                      BIGINT,
    "conceptName"                    TEXT,
    "domainId"                       TEXT,
    "mappingType"                    TEXT,
    "comment"                        TEXT,
    "createdBy"                      TEXT,
    "createdOn"                      BIGINT,
    "assignedReviewer"               TEXT
);


COPY public.stg_usagi_mapping
FROM 'your local path to the usagi mapping file here' /*Change the path here to your local path of the usagi mapping file*/
WITH (
    FORMAT CSV,
    HEADER TRUE,
    DELIMITER ',',
    QUOTE '"',
    ENCODING 'UTF8'
);

------------------------------------------------------------------
/*Import/Export: Manual Import*/

Filename:       /*Select the path here to your local path of the usagi mapping file here*/
Format:         csv
Encoding:       UTF8
Header:         Yes
Delimiter:      ,
Quote:          "
