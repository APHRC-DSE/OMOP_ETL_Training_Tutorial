
--LOAD OMOP VOCABS
COPY vocabulary.CONCEPT FROM 'your local path to the vocabulary here'
WITH DELIMITER E'\t' 
CSV HEADER QUOTE E'\b';

COPY vocabulary.CONCEPT_RELATIONSHIP FROM 'your local path to the vocabulary here' 
WITH DELIMITER E'\t' 
CSV HEADER QUOTE E'\b';

COPY vocabulary.CONCEPT_ANCESTOR FROM 'your local path to the vocabulary here'
WITH DELIMITER E'\t' 
CSV HEADER QUOTE E'\b';

COPY vocabulary.CONCEPT_SYNONYM FROM 'your local path to the vocabulary here'
WITH DELIMITER E'\t' 
CSV HEADER QUOTE E'\b' ;

COPY vocabulary.DRUG_STRENGTH FROM 'your local path to the vocabulary here' 
WITH DELIMITER E'\t' 
CSV HEADER QUOTE E'\b';

COPY vocabulary.VOCABULARY FROM 'your local path to the vocabulary here'
WITH DELIMITER E'\t' 
CSV HEADER QUOTE E'\b' ;

COPY vocabulary.RELATIONSHIP FROM 'your local path to the vocabulary here'
WITH DELIMITER E'\t' 
CSV HEADER QUOTE E'\b' ;

COPY vocabulary.CONCEPT_CLASS FROM 'your local path to the vocabulary here'
WITH DELIMITER E'\t' 
CSV HEADER QUOTE E'\b' ;

COPY vocabulary.DOMAIN FROM 'your local path to the vocabulary here'
WITH DELIMITER E'\t' 
CSV HEADER QUOTE E'\b' ;
