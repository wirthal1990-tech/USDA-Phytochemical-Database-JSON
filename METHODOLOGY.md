# Methodology — Ethno-API Phytochemical Dataset v2.2

> **Schema v2.2 · 76,907 records · 24,746 compounds · 2,313 species · 10 fields**

---

## Data Sources

| Source | Version / Access Date | License |
|---|---|---|
| USDA Dr. Duke's Phytochemical and Ethnobotanical Databases | Archive (2024 retirement snapshot) | Public Domain (USDA) |
| PubMed / NCBI E-utilities | Accessed 2026-01 via `esearch.fcgi` | Open (NCBI Terms of Use) |
| ClinicalTrials.gov | API v2, accessed 2026-01 | Public Domain (NLM) |
| ChEMBL | v35 REST API, accessed 2026-02 | CC BY-SA 3.0 |
| PatentsView (USPTO) | API v1, patents since 2020-01-01 | Public Domain (USPTO) |
| PubChem (NCBI) | PUG REST API, accessed 2026-03 | Public Domain (NCBI) |

---

## Schema v2.2

| Field | Type | Null Count | Description |
|---|---|---|---|
| `chemical` | string | 0 | Compound name (natural key, from USDA) |
| `plant_species` | string | 0 | Botanical species name (natural key, from USDA) |
| `application` | string | 38,149 | Documented bioactivity / therapeutic use |
| `dosage` | string | 67,132 | Documented dosage from literature |
| `pubmed_mentions_2026` | Int64 | 0 | PubMed publication mention count (title/abstract search, 2026) |
| `clinical_trials_count_2026` | Int64 | 0 | ClinicalTrials.gov study count mentioning compound |
| `chembl_bioactivity_count` | Int64 | 0 | ChEMBL bioactivity assay count |
| `patent_count_since_2020` | Int64 | 0 | US patent count (USPTO PatentsView, since 2020-01-01) |
| `pubchem_cid` | Int64 | 14,254 | PubChem Compound ID (CID) — 42.4% of unique compounds resolved |
| `canonical_smiles` | string | 14,254 | Canonical SMILES string (PubChem) — 42.4% of unique compounds resolved |

**Enrichment coverage:**

| Field | Non-zero % | Min | Max | Mean |
|---|---|---|---|---|
| `pubmed_mentions_2026` | 78.4% | 0 | 349,640 | 8,646 |
| `clinical_trials_count_2026` | 24.2% | 0 | 4,094 | 12 |
| `chembl_bioactivity_count` | 31.9% | 0 | 7,679 | 85 |
| `patent_count_since_2020` | 37.2% | 0 | 866,143 | 165 |

*Note: Noise compounds (WATER, PROTEIN, GLUCOSE, etc.) and exact duplicates removed in DQA audit (2026-03-16). Post-DQA min is 0.*

---

## Enrichment Pipeline

### 1. PubMed (NCBI E-utilities)

- **Endpoint:** `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi`
- **Query logic:** `term={compound_name}[Title/Abstract]` — substring match on title and abstract fields
- **Rate limiting:** 3 requests/second (NCBI default without API key)
- **Output:** Integer count of matching PubMed articles

### 2. ClinicalTrials.gov (Local XML Snapshot + Aho-Corasick)

- **Source:** AllPublicXML archive, 575,349 studies (March 2026 snapshot)
- **Indexed studies:** 517,205 studies with non-empty `intervention_name` fields (cached in `ct_intervention_index.json`)
- **Algorithm:** Aho-Corasick multi-pattern string matching with word-boundary enforcement
- **Stereo-prefix normalization (v2.2):** Compounds like `(+)-CATECHIN` are indexed as both `(+)-catechin` and `catechin`, covering 18 prefix types: `(+)-`, `(-)-`, `(±)-`, `DL-`, `rac-`, `R-`, `S-`, `RS-`, `cis-`, `trans-`, `alpha-`, `beta-`, `gamma-`, `delta-`, `E-`, `Z-`, `L-`, `D-`
- **Variants in automaton:** 25,705 (from 24,698 unique compounds after skip filter)
- **Runtime:** ~5 seconds (cached intervention index)
- **Output:** Integer count of matching studies per compound

> **Why local instead of API:** The ClinicalTrials.gov v2 API rejects IUPAC names containing brackets, arrows, and parentheses with HTTP 400 errors. The local XML approach eliminates rate limits, API failures, and network dependency entirely.

### 3. ChEMBL (REST API v35)

- **Endpoint:** `https://www.ebi.ac.uk/chembl/api/data/activity`
- **Query logic:** Direct compound name lookup → if no hit, PubChem canonical name resolution → ChEMBL molecule search → bioactivity count
- **Fallback chain:** `compound_name` → PubChem → InChIKey → ChEMBL
- **Rate limiting:** 3 requests/second (`time.sleep(0.33)`)
- **Checkpoint:** `chembl_checkpoint.json` — every 100 compounds
- **Error handling:** `-1` logged for API failures (see `chembl_errors.log`)

> **Attribution:** ChEMBL data is from https://www.ebi.ac.uk/chembl/ (ChEMBL v35), licensed under CC BY-SA 3.0. Attribution required for downstream redistribution.

### 4. PatentsView (USPTO API v1)

- **Endpoint:** `https://api.patentsview.org/patents/query`
- **Query logic:** Patents since 2020-01-01 with compound name in title or abstract
- **Rate limiting:** 45 requests/minute (PatentsView limit), semaphore(2) + 1.4s sleep
- **Checkpoint:** `patent_checkpoint.json` — every 100 compounds
- **Requirement:** Free API key via `PATENTSVIEW_API_KEY` environment variable

### 5. Merge & Export (`master_export_v2.py`)

- Merges all 4 enrichment outputs + PubChem SMILES/CID into unified dataset
- Exports: JSON (indent=2), Parquet (Snappy compressed), MANIFEST (SHA-256 checksums + statistics)
- 3-pass verification: record count, schema validation, checksum match

### 6. PubChem (PUG REST API)

- **Endpoint:** `https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/{name}/JSON`
- **Query logic:** Name-to-CID resolution, returns `CID` + `CanonicalSMILES`
- **Queries:** 24,746 unique compound names
- **Resolved:** 10,484 compounds (42.4% of unique chemicals)
- **Unresolved:** 14,262 compounds (null in schema)
- **Rate limit:** 0.35s between requests, checkpoint-resumable
- **Runtime:** 3.2 hours (24,746 queries)
- **Output fields:** `canonical_smiles`, `pubchem_cid`

> **Why 57.6% are null:** Phytochemical trivial names (e.g. "TANNIN", "RESIN"), plant mixture descriptions (e.g. "ESSENTIAL OIL"), and non-specific ethnobotanical terms are not indexed in PubChem's compound database by name. These are inherent limitations of the source data, not pipeline failures.

---

## Known Limitations

1. **ClinicalTrials.gov substring matching** inflates counts for compounds with common names (e.g., "ACID" matches many unrelated trials). Consider filtering by exact intervention match for precision-critical uses.

2. **PubMed counts include review articles** — the search does not distinguish original research from reviews, meta-analyses, or editorials. Use as a relative popularity signal, not an absolute measure.

3. **ChEMBL coverage ~34%** — approximately two-thirds of compounds are too obscure for structural data in ChEMBL. These receive `chembl_bioactivity_count = 0`.

4. **Species names** — USDA synonyms are not always current binomial nomenclature. Some legacy names may not match modern taxonomic databases (e.g., NCBI Taxonomy, GBIF).

5. **PubMed `-1` values** — historical API errors were present in pre-DQA data. Post-DQA (2026-03-16), all `-1` values have been removed along with noise compounds.

6. **Patent counts (PatentsView)** — limited to US patents only. International patents (WIPO, EPO) are not included.

---

## Noise Exclusion

117 compounds classified as noise (including generic biochemical terms like PROTEIN, PROTEINS, WATER, LEAD, GLUCOSE with inflated PubMed matches that are not specific phytochemicals) were identified. 24 of these were present in the dataset and removed during the DQA audit (2026-03-16), eliminating 11,744 records.

**Exclusion criteria:**
- Solvents (e.g., ACETONE, ETHANOL, METHANOL)
- Common elements and minerals (e.g., ALUMINUM, CALCIUM, IRON)
- Generic or non-specific entries (e.g., ACIDS, ALCOHOL, ASH, FAT, FIBER, PROTEIN, WATER)
- Industrial chemicals with no phytochemical relevance

Full list: [`noise_exclusion_list.txt`](noise_exclusion_list.txt)

---

## Reproducibility

All enrichment scripts are available in the repository:

| Script | Purpose | Approx. Runtime |
|---|---|---|
| `clinicaltrials_enricher.py` | ClinicalTrials.gov enrichment | ~2-3 hours |
| `chembl_enricher.py` | ChEMBL bioactivity enrichment | ~51 hours |
| `patent_enricher.py` | PatentsView patent count enrichment | ~10 hours |
| `master_export_v2.py` | Merge & export (JSON + Parquet + Manifest) | ~5 minutes |

- **Hardware:** Hetzner CCX33 (8 vCPU, 32 GB RAM, AMD EPYC)
- **Checkpoint files** enable resume after interruption — no need to restart from scratch
- **Deterministic output** given the same API responses (APIs may return different counts over time as new publications/trials/patents are added)

---

## License

- **Base USDA data:** Public Domain (U.S. Government work)
- **Enrichment layer + compiled dataset:**
  - Free 400-row sample: CC BY 4.0
  - Full dataset: Commercial license (single-entity, team, or enterprise)
- **Enrichment scripts:** Available in this repository for transparency

---

## Version History

| Version | Date | Fields | Records | Changes |
|---|---|---|---|---|
| v1.0 | 2026-01 | 5 (chemical, plant_species, application, dosage, pubmed_mentions_2026) | 104,388 | Initial release with PubMed enrichment |
| v2.0 | 2026-03 | 8 (+clinical_trials_count_2026, chembl_bioactivity_count, patent_count_since_2020) | 76,907 | 4-source enrichment, DQA audit (noise compounds + duplicates removed: 104,388 → 76,907), checkpoint system |
| v2.1 | 2026-03 | 10 (+pubchem_cid, canonical_smiles) | 76,907 | PubChem CID + SMILES enrichment (10,484 chemicals resolved, 71.8% record coverage — corrected to 42.4% in v2.2) |
| v2.2 | 2026-03 | 10 (same schema) | 76,907 | Stereo-prefix normalization for CT matching (+2 compounds), corrected SMILES coverage reporting (42.4% of unique chemicals), local CT XML matching replaces API |

---

## File Integrity

| File | Size | SHA-256 |
|---|---|---|
| `ethno_dataset_2026_v2.json` | 16.3 MB | `cf517675c263eefb96c18a74a0238d0e142067eda2175259fde10db66a081bc3` |
| `ethno_dataset_2026_v2.parquet` | 800 KB | `cd152dd830f769a8e86c2661f0650f20bd936452835d6ee4cad60549068c7b40` |
| `ethno_dataset_2026_v2.1_FINAL.json` | 24.5 MB | `ae86ba33d76273dc52330ca5d75234d93f8a6d3a8db106186d39470a3c1a0db0` |
| `ethno_dataset_2026_v2.2.json` | 25.4 MB | `7cb5719f9763f84f1cb8176b462d51fd9df5750e7cfa78e497263b7631ebba13` |
| `ethno_dataset_2026_v2.2.parquet` | 1.2 MB | `118d28bf08b784868b60fc1445a0fdd6817d5d8a492015c51d975cf8e8e5a132` |

Export timestamp: `2026-03-22T14:29:03Z` (v2.2 final)
