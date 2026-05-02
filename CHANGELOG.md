# CHANGELOG — Ethno-API Phytochemical Dataset

All notable changes are documented here.
Format: [version] · [date] · [summary]

---

## v2.4.0 · April 2026

### Dataset
- +4 columns: `partner_cid`, `inchi_key`, `iupac_verified`, `partner_match_method`
- 76,907 records, 24,746 unique chemicals, 2,313 species
- Advisor file `iupac_cid_resolutions.json` (1,197 CIDs) committed

### M3 — SMILES Reverse Validation Gate
- Full-run on 76,907 records (~58s, 266MB RSS)
- Verdicts: validated 11,981 · plausible 8,370 · review_required 37,361 · invalidated 45 · insufficient_data 19,150
- Bug fix: thiol-false-alcohol class eliminated
- Logic: strictest-verdict-wins aggregation enforced
- Selftest: 11/11 PASS
- Co-validated by Dominic Fagan (BSc chemistry)

### M2 — RAG Retrieval Bridge
- Corpus rebuilt: ~660k → ~1.55M PubMed abstracts (error rate < 0.136%)
- compounds_pmids: 2,768,594 rows, 0 duplicates
- Retrieval verified: semantic · compound-filtered · multilingual
- Canonical table: public.abstracts (ethnodb)

### Distribution
- Deployed to GitHub · HuggingFace · Zenodo (DOI 10.5281/zenodo.19660107) · Kaggle
- All consistency checks: PASS

---

## v2.2.0–v2.3.1 · March–April 2026

- CID correction: GANODERIC-ACID-G (CID 16661 invalidated, NULLed)
- 35 stereoisomer-prefix corrections on achiral compounds
- compound_type column added (discrete_phytochemical / inorganic_element / complex_mixture / substance_class / generic_ambiguous)
- patent_count_method column added (methodology transparency)

---

## In Development — v3.0 (target: Q3 2026)

- validated_compound_activities table: compound × activity × pmid_evidence + origin flag (usda / literature / both)
- Semantic search on 1.55M abstracts per compound × activity
- Manual domain-expert review: Dominic Fagan (BSc chemistry)
