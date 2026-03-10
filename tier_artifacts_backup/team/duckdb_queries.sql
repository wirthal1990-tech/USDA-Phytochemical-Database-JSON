-- =============================================================================
-- ETHNO-API DATASET v2.0 — DuckDB Analytics Query Library
-- =============================================================================
-- Schema: chemical (str) | plant_species (str) | application (str, ~40% null)
--         dosage (str, ~55% null) | pubmed_mentions_2026 (int32)
--         clinical_trials_count_2026 (int32) | chembl_bioactivity_count (int32)
--         patent_count_since_2020 (int32)
--
-- USAGE:
--   import duckdb
--   result = duckdb.sql("SELECT ... FROM read_json_auto('PATH_TO_DATA')")
--
-- !! TO SWITCH TO FULL DATASET: Replace INPUT_FILE value below !!
-- =============================================================================
SET VARIABLE INPUT_FILE = 'ethno_sample_400.json';   -- CHANGE TO: ethno_dataset_2026_v2.json
-- =============================================================================


-- ─────────────────────────────────────────────────────────────────────────────
-- CAT-1: COMPOUND DISCOVERY
-- ─────────────────────────────────────────────────────────────────────────────

-- Q01: Top 25 compounds by PubMed evidence (most-researched)
-- Use case: Identify highest-visibility compounds for literature review prioritization
-- Output: compound name, total PubMed mentions, species count
SELECT
    chemical,
    MAX(pubmed_mentions_2026)      AS pubmed_score,
    COUNT(DISTINCT plant_species)  AS species_count
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
GROUP BY chemical
ORDER BY pubmed_score DESC
LIMIT 25;


-- Q02: Compound search — full-text match on chemical name (parametrize as needed)
-- Use case: Lookup a specific compound across all plant sources
-- Output: all records for the matched compound
SELECT *
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
WHERE lower(chemical) LIKE '%quercetin%'
ORDER BY pubmed_mentions_2026 DESC;


-- Q03: Compounds present in the highest number of distinct plant species
-- Use case: Identify ubiquitous compounds (broad botanical distribution = lower supply risk)
-- Output: compound, species breadth, max PubMed score
SELECT
    chemical,
    COUNT(DISTINCT plant_species)  AS species_breadth,
    MAX(pubmed_mentions_2026)      AS max_pubmed,
    MAX(chembl_bioactivity_count)  AS max_bioassays
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
GROUP BY chemical
ORDER BY species_breadth DESC
LIMIT 30;


-- Q04: Rare compounds — high bioactivity but found in few species (< 3)
-- Use case: Niche compound discovery for exclusivity / IP positioning
-- Output: unique compounds with high signal, low species coverage
SELECT
    chemical,
    COUNT(DISTINCT plant_species)  AS species_count,
    MAX(chembl_bioactivity_count)  AS bioactivity_score,
    MAX(pubmed_mentions_2026)      AS pubmed_score
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
GROUP BY chemical
HAVING species_count < 3 AND bioactivity_score > 10
ORDER BY bioactivity_score DESC
LIMIT 25;


-- ─────────────────────────────────────────────────────────────────────────────
-- CAT-2: EVIDENCE SCORING
-- ─────────────────────────────────────────────────────────────────────────────

-- Q05: Composite evidence score — weighted combination of all 4 enrichment layers
-- Use case: Single-metric ranking for prioritization dashboards
-- Weights: PubMed 0.3 | Trials 0.35 | ChEMBL 0.2 | Patents 0.15
-- Output: compound, individual scores, composite score
SELECT
    chemical,
    MAX(pubmed_mentions_2026)          AS pubmed,
    MAX(clinical_trials_count_2026)    AS trials,
    MAX(chembl_bioactivity_count)      AS bioassays,
    MAX(patent_count_since_2020)       AS patents,
    ROUND(
        (MAX(pubmed_mentions_2026)       * 0.30) +
        (MAX(clinical_trials_count_2026) * 0.35) +
        (MAX(chembl_bioactivity_count)   * 0.20) +
        (MAX(patent_count_since_2020)    * 0.15),
    2) AS composite_score
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
GROUP BY chemical
ORDER BY composite_score DESC
LIMIT 50;


-- Q06: Evidence tier classification — categorize compounds by evidence strength
-- Use case: Automated tier assignment for compound prioritization pipelines
-- Output: compound + evidence tier (PLATINUM / GOLD / SILVER / BRONZE)
SELECT
    chemical,
    MAX(pubmed_mentions_2026)       AS pubmed,
    MAX(clinical_trials_count_2026) AS trials,
    CASE
        WHEN MAX(pubmed_mentions_2026) > 5000 AND MAX(clinical_trials_count_2026) > 100
            THEN 'PLATINUM'
        WHEN MAX(pubmed_mentions_2026) > 1000 AND MAX(clinical_trials_count_2026) > 20
            THEN 'GOLD'
        WHEN MAX(pubmed_mentions_2026) > 100
            THEN 'SILVER'
        ELSE 'BRONZE'
    END AS evidence_tier
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
GROUP BY chemical
ORDER BY evidence_tier, pubmed DESC;


-- Q07: High bioactivity + low clinical trials = unexplored candidates
-- Use case: Drug discovery pipeline gap identification
-- Output: compounds with strong in-vitro signal but limited clinical translation
SELECT
    chemical,
    MAX(chembl_bioactivity_count)   AS bioassays,
    MAX(clinical_trials_count_2026) AS trials,
    MAX(pubmed_mentions_2026)       AS pubmed,
    ROUND(
        MAX(chembl_bioactivity_count)::DOUBLE /
        NULLIF(MAX(clinical_trials_count_2026), 0),
    1) AS bioactivity_to_trial_ratio
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
GROUP BY chemical
HAVING bioassays > 5 AND trials < 5
ORDER BY bioactivity_to_trial_ratio DESC
LIMIT 30;


-- Q08: Evidence distribution statistics — dataset-level summary
-- Use case: Due diligence / data quality overview for technical buyers
-- Output: percentile distribution of all 4 enrichment fields
SELECT
    'pubmed_mentions_2026'       AS metric,
    MIN(pubmed_mentions_2026)    AS min_val,
    ROUND(AVG(pubmed_mentions_2026), 1) AS avg_val,
    MEDIAN(pubmed_mentions_2026) AS median_val,
    MAX(pubmed_mentions_2026)    AS max_val,
    COUNT(*)                     AS total_records
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
UNION ALL
SELECT 'clinical_trials_count_2026',
    MIN(clinical_trials_count_2026), ROUND(AVG(clinical_trials_count_2026),1),
    MEDIAN(clinical_trials_count_2026), MAX(clinical_trials_count_2026), COUNT(*)
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
UNION ALL
SELECT 'chembl_bioactivity_count',
    MIN(chembl_bioactivity_count), ROUND(AVG(chembl_bioactivity_count),1),
    MEDIAN(chembl_bioactivity_count), MAX(chembl_bioactivity_count), COUNT(*)
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
UNION ALL
SELECT 'patent_count_since_2020',
    MIN(patent_count_since_2020), ROUND(AVG(patent_count_since_2020),1),
    MEDIAN(patent_count_since_2020), MAX(patent_count_since_2020), COUNT(*)
FROM read_json_auto(GETVARIABLE('INPUT_FILE'));


-- ─────────────────────────────────────────────────────────────────────────────
-- CAT-3: SPECIES ANALYSIS
-- ─────────────────────────────────────────────────────────────────────────────

-- Q09: Most chemically diverse plant species (highest unique compound count)
-- Use case: Identify species for broad-spectrum extraction / sourcing strategy
-- Output: species, compound count, sum of evidence scores
SELECT
    plant_species,
    COUNT(DISTINCT chemical)           AS unique_compounds,
    SUM(pubmed_mentions_2026)          AS total_pubmed,
    SUM(clinical_trials_count_2026)    AS total_trials,
    SUM(chembl_bioactivity_count)      AS total_bioassays
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
GROUP BY plant_species
ORDER BY unique_compounds DESC
LIMIT 25;


-- Q10: Species containing a specific high-value compound (parametrize chemical)
-- Use case: Sourcing analysis — which plants contain the target compound?
-- Output: all species hosting the compound, with dosage data where available
SELECT
    plant_species,
    chemical,
    dosage,
    pubmed_mentions_2026,
    clinical_trials_count_2026
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
WHERE chemical = 'QUERCETIN'
ORDER BY plant_species;


-- Q11: Species with highest aggregate evidence across all compounds they contain
-- Use case: Identify botanically "richest" species for portfolio prioritization
-- Output: species ranked by total composite evidence score
SELECT
    plant_species,
    COUNT(DISTINCT chemical)        AS compound_count,
    ROUND(SUM(
        pubmed_mentions_2026 * 0.30 +
        clinical_trials_count_2026 * 0.35 +
        chembl_bioactivity_count * 0.20 +
        patent_count_since_2020 * 0.15
    ), 0)                           AS total_evidence_score
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
GROUP BY plant_species
ORDER BY total_evidence_score DESC
LIMIT 20;


-- Q12: Cross-species compound overlap matrix (top 10 compounds x their species)
-- Use case: Sourcing redundancy analysis — multi-source supply chain resilience
-- Output: pivot-style view of compound-species co-occurrence
SELECT
    chemical,
    string_agg(DISTINCT plant_species, ' | ' ORDER BY plant_species) AS species_list,
    COUNT(DISTINCT plant_species)                                     AS species_count
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
WHERE chemical IN (
    SELECT chemical FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
    GROUP BY chemical ORDER BY MAX(pubmed_mentions_2026) DESC LIMIT 10
)
GROUP BY chemical
ORDER BY species_count DESC;


-- ─────────────────────────────────────────────────────────────────────────────
-- CAT-4: APPLICATION INTELLIGENCE
-- ─────────────────────────────────────────────────────────────────────────────

-- Q13: Anti-inflammatory compound panel — all relevant applications
-- Use case: Inflammation research target list generation
-- Output: compounds with anti-inflammatory applications, ranked by evidence
SELECT
    chemical,
    application,
    MAX(pubmed_mentions_2026)       AS pubmed,
    MAX(clinical_trials_count_2026) AS trials,
    MAX(chembl_bioactivity_count)   AS bioassays,
    COUNT(DISTINCT plant_species)   AS species_count
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
WHERE lower(application) LIKE '%anti%inflam%'
   OR lower(application) LIKE '%antiinflam%'
   OR lower(application) LIKE '%lipoxygenase%'
GROUP BY chemical, application
ORDER BY trials DESC, pubmed DESC;


-- Q14: Application category frequency — what therapeutic areas are most represented?
-- Use case: Market sizing / therapeutic area coverage assessment
-- Output: application keywords ranked by compound count
SELECT
    CASE
        WHEN lower(application) LIKE '%cancer%' OR lower(application) LIKE '%antitumor%'
             OR lower(application) LIKE '%anticancer%' THEN 'Oncology'
        WHEN lower(application) LIKE '%anti%inflam%' OR lower(application) LIKE '%antiinflam%'
             THEN 'Anti-Inflammatory'
        WHEN lower(application) LIKE '%antibacter%' OR lower(application) LIKE '%antimicrob%'
             OR lower(application) LIKE '%antibiotic%' THEN 'Antimicrobial'
        WHEN lower(application) LIKE '%antioxid%' THEN 'Antioxidant'
        WHEN lower(application) LIKE '%antiviral%' THEN 'Antiviral'
        WHEN lower(application) LIKE '%neuroprot%' OR lower(application) LIKE '%neuro%'
             THEN 'Neuroprotective'
        WHEN lower(application) LIKE '%cardio%' OR lower(application) LIKE '%heart%'
             THEN 'Cardiovascular'
        WHEN application IS NULL THEN 'Unclassified'
        ELSE 'Other'
    END                             AS therapeutic_area,
    COUNT(DISTINCT chemical)        AS unique_compounds,
    SUM(clinical_trials_count_2026) AS total_trials
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
GROUP BY therapeutic_area
ORDER BY unique_compounds DESC;


-- Q15: Compounds with dosage data AND high evidence (quantified IC50/dose)
-- Use case: Pre-clinical feasibility filter — only candidates with dose data
-- Output: compounds where dosage is reported and evidence is strong
SELECT
    chemical,
    plant_species,
    dosage,
    pubmed_mentions_2026,
    clinical_trials_count_2026,
    chembl_bioactivity_count
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
WHERE dosage IS NOT NULL
  AND (lower(dosage) LIKE '%ic50%' OR lower(dosage) LIKE '%mg%' OR lower(dosage) LIKE '%mm%')
  AND chembl_bioactivity_count > 5
ORDER BY chembl_bioactivity_count DESC
LIMIT 50;


-- Q16: Application diversity per compound — how many distinct uses does it have?
-- Use case: Multi-indication potential screening
-- Output: compounds with broadest application spectrum
SELECT
    chemical,
    COUNT(DISTINCT application)     AS application_count,
    array_to_string(list_slice(list_sort(list_distinct(list(application))), 1, 5), ' | ') AS sample_applications,
    MAX(pubmed_mentions_2026)       AS pubmed
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
WHERE application IS NOT NULL
GROUP BY chemical
ORDER BY application_count DESC
LIMIT 25;


-- ─────────────────────────────────────────────────────────────────────────────
-- CAT-5: IP + CLINICAL PIPELINE INTELLIGENCE
-- ─────────────────────────────────────────────────────────────────────────────

-- Q17: IP whitespace candidates — high research, low patent activity
-- Use case: Freedom-to-operate screening, identify underpatented compounds
-- Output: compounds with strong scientific signal but sparse patent landscape
SELECT
    chemical,
    MAX(pubmed_mentions_2026)       AS pubmed,
    MAX(clinical_trials_count_2026) AS trials,
    MAX(chembl_bioactivity_count)   AS bioassays,
    MAX(patent_count_since_2020)    AS patents_since_2020,
    ROUND(
        MAX(pubmed_mentions_2026)::DOUBLE /
        NULLIF(MAX(patent_count_since_2020), 0),
    1)                              AS research_to_patent_ratio
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
GROUP BY chemical
HAVING pubmed > 50 AND patents_since_2020 < 5
ORDER BY research_to_patent_ratio DESC
LIMIT 30;


-- Q18: High-patent compounds — active commercial investment landscape
-- Use case: Competitive intelligence — where is industry money going?
-- Output: most-patented compounds since 2020
SELECT
    chemical,
    MAX(patent_count_since_2020)    AS patents_since_2020,
    MAX(pubmed_mentions_2026)       AS pubmed,
    MAX(clinical_trials_count_2026) AS trials,
    COUNT(DISTINCT plant_species)   AS species_count
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
GROUP BY chemical
ORDER BY patents_since_2020 DESC
LIMIT 25;


-- Q19: Clinical pipeline progression index
-- Use case: Identify compounds progressing from research to clinical validation
-- Heuristic: high PubMed (research base) + growing trials + bioactivity confirmed
-- Output: ranked pipeline candidates
SELECT
    chemical,
    MAX(pubmed_mentions_2026)       AS pubmed,
    MAX(clinical_trials_count_2026) AS trials,
    MAX(chembl_bioactivity_count)   AS bioassays,
    MAX(patent_count_since_2020)    AS patents,
    ROUND(
        (LEAST(MAX(pubmed_mentions_2026)       / 1000.0, 1.0) * 25) +
        (LEAST(MAX(clinical_trials_count_2026) / 100.0,  1.0) * 35) +
        (LEAST(MAX(chembl_bioactivity_count)   / 500.0,  1.0) * 25) +
        (LEAST(MAX(patent_count_since_2020)    / 50.0,   1.0) * 15),
    1)                              AS pipeline_score_0_to_100
FROM read_json_auto(GETVARIABLE('INPUT_FILE'))
GROUP BY chemical
ORDER BY pipeline_score_0_to_100 DESC
LIMIT 20;


-- Q20: Dataset completeness audit — null rates and coverage per field
-- Use case: Technical due diligence, reproducibility documentation
-- Output: field-level completeness statistics
SELECT
    COUNT(*)                                                    AS total_records,
    COUNT(chemical)                                             AS chemical_count,
    COUNT(plant_species)                                        AS species_count,
    COUNT(application)                                          AS application_non_null,
    ROUND(COUNT(application) * 100.0 / COUNT(*), 1)            AS application_coverage_pct,
    COUNT(dosage)                                               AS dosage_non_null,
    ROUND(COUNT(dosage) * 100.0 / COUNT(*), 1)                 AS dosage_coverage_pct,
    COUNT(pubmed_mentions_2026)                                 AS pubmed_count,
    COUNT(clinical_trials_count_2026)                           AS trials_count,
    COUNT(chembl_bioactivity_count)                             AS chembl_count,
    COUNT(patent_count_since_2020)                              AS patent_count
FROM read_json_auto(GETVARIABLE('INPUT_FILE'));
