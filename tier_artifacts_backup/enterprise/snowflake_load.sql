-- =============================================================================
-- ETHNO-API DATASET v2.0 — Snowflake Import Script
-- =============================================================================
-- Loads ethno_dataset_2026_v2.parquet from Cloudflare R2 into Snowflake.
-- Tested with: Snowflake Standard Edition + Snowflake Enterprise Edition
-- Estimated load time: < 2 minutes for full 104,388-record dataset
-- =============================================================================

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │  CONFIGURATION BLOCK — Edit only this section                           │
-- └─────────────────────────────────────────────────────────────────────────┘
SET R2_ACCOUNT_ID    = '<YOUR_CLOUDFLARE_ACCOUNT_ID>';
SET R2_ACCESS_KEY    = '<YOUR_R2_ACCESS_KEY_ID>';
SET R2_SECRET_KEY    = '<YOUR_R2_SECRET_ACCESS_KEY>';
SET R2_BUCKET        = 'ethno-api-storage';           -- do not change
SET TARGET_DB        = 'ETHNO_API';                   -- your target database
SET TARGET_SCHEMA    = 'PUBLIC';                       -- your target schema
SET TARGET_TABLE     = 'PHYTOCHEMICAL_DATASET_V2';    -- table name
-- ─────────────────────────────────────────────────────────────────────────


-- STEP 1: Create database + schema (skip if already exists)
CREATE DATABASE IF NOT EXISTS IDENTIFIER($TARGET_DB);
USE DATABASE IDENTIFIER($TARGET_DB);
CREATE SCHEMA IF NOT EXISTS IDENTIFIER($TARGET_SCHEMA);
USE SCHEMA IDENTIFIER($TARGET_SCHEMA);


-- STEP 2: Create target table with exact v2.0 schema
CREATE OR REPLACE TABLE IDENTIFIER($TARGET_TABLE) (
    chemical                    VARCHAR(500)    NOT NULL,
    plant_species               VARCHAR(500)    NOT NULL,
    application                 VARCHAR(1000),           -- ~40% NULL expected
    dosage                      VARCHAR(500),            -- ~55% NULL expected
    pubmed_mentions_2026        INTEGER         NOT NULL,
    clinical_trials_count_2026  INTEGER         NOT NULL,
    chembl_bioactivity_count    INTEGER         NOT NULL,
    patent_count_since_2020     INTEGER         NOT NULL
)
COMMENT = 'Ethno-API v2.0 — 104388 phytochemical records enriched with PubMed, ClinicalTrials, ChEMBL, PatentsView';


-- STEP 3: Create external stage pointing to Cloudflare R2 (S3-compatible)
CREATE OR REPLACE STAGE ETHNO_R2_STAGE
    URL = CONCAT('s3://', $R2_BUCKET, '/')
    CREDENTIALS = (
        AWS_KEY_ID     = $R2_ACCESS_KEY
        AWS_SECRET_KEY = $R2_SECRET_KEY
    )
    ENDPOINT = CONCAT($R2_ACCOUNT_ID, '.r2.cloudflarestorage.com')
    FILE_FORMAT = (
        TYPE             = 'PARQUET'
        SNAPPY_COMPRESSION = TRUE
    )
    COMMENT = 'Cloudflare R2 stage for Ethno-API dataset files';


-- STEP 4: Preview staged files (verify connectivity before loading)
LIST @ETHNO_R2_STAGE PATTERN = '.*v2.*';


-- STEP 5: Load Parquet into table (recommended — fastest, smallest file)
COPY INTO IDENTIFIER($TARGET_TABLE)
FROM (
    SELECT
        $1:chemical::VARCHAR                    AS chemical,
        $1:plant_species::VARCHAR               AS plant_species,
        $1:application::VARCHAR                 AS application,
        $1:dosage::VARCHAR                      AS dosage,
        $1:pubmed_mentions_2026::INTEGER        AS pubmed_mentions_2026,
        $1:clinical_trials_count_2026::INTEGER  AS clinical_trials_count_2026,
        $1:chembl_bioactivity_count::INTEGER    AS chembl_bioactivity_count,
        $1:patent_count_since_2020::INTEGER     AS patent_count_since_2020
    FROM @ETHNO_R2_STAGE/ethno_dataset_2026_v2.parquet
)
FILE_FORMAT = (TYPE = 'PARQUET' SNAPPY_COMPRESSION = TRUE)
ON_ERROR = 'ABORT_STATEMENT';


-- STEP 6 (ALTERNATIVE): Load from JSON if Parquet load fails
-- Uncomment the block below only if Step 5 fails
/*
COPY INTO IDENTIFIER($TARGET_TABLE)
FROM (
    SELECT
        $1:chemical::VARCHAR,
        $1:plant_species::VARCHAR,
        $1:application::VARCHAR,
        $1:dosage::VARCHAR,
        $1:pubmed_mentions_2026::INTEGER,
        $1:clinical_trials_count_2026::INTEGER,
        $1:chembl_bioactivity_count::INTEGER,
        $1:patent_count_since_2020::INTEGER
    FROM @ETHNO_R2_STAGE/ethno_dataset_2026_v2.json
)
FILE_FORMAT = (TYPE = 'JSON' STRIP_OUTER_ARRAY = TRUE)
ON_ERROR = 'ABORT_STATEMENT';
*/


-- STEP 7: Verify load
SELECT COUNT(*) AS total_records FROM IDENTIFIER($TARGET_TABLE);
-- Expected: 104388

SELECT
    COUNT(DISTINCT chemical)    AS unique_compounds,
    COUNT(DISTINCT plant_species) AS unique_species,
    MAX(pubmed_mentions_2026)   AS max_pubmed,
    MAX(clinical_trials_count_2026) AS max_trials
FROM IDENTIFIER($TARGET_TABLE);
-- Expected: 24771 compounds, 2315 species

-- Sample output
SELECT * FROM IDENTIFIER($TARGET_TABLE)
WHERE chemical = 'QUERCETIN'
LIMIT 5;
-- Expected: pubmed_mentions_2026 = 31310


-- STEP 8: Recommended index — cluster by chemical for compound lookups
ALTER TABLE IDENTIFIER($TARGET_TABLE)
CLUSTER BY (chemical);


-- STEP 9: Grant read access to your team (adjust role names as needed)
-- GRANT SELECT ON TABLE IDENTIFIER($TARGET_TABLE) TO ROLE ANALYST;
-- GRANT SELECT ON TABLE IDENTIFIER($TARGET_TABLE) TO ROLE DATA_SCIENCE;
