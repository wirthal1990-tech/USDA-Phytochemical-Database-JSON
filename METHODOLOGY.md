# Methodology — Ethno-API Phytochemical Dataset v2.0

> **Schema v2.0 · 104,388 records · 24,771 compounds · 2,315 species · 8 fields**

---

## Data Sources

| Source | Version / Access Date | License |
|---|---|---|
| USDA Dr. Duke's Phytochemical and Ethnobotanical Databases | Archive (2024 retirement snapshot) | Public Domain (USDA) |
| PubMed / NCBI E-utilities | Accessed 2026-01 via `esearch.fcgi` | Open (NCBI Terms of Use) |
| ClinicalTrials.gov | API v2, accessed 2026-01 | Public Domain (NLM) |
| ChEMBL | v35 REST API, accessed 2026-02 | CC BY-SA 3.0 |
| PatentsView (USPTO) | API v1, patents since 2020-01-01 | Public Domain (USPTO) |

---

## Schema v2.0

| Field | Type | Null Count | Description |
|---|---|---|---|
| `chemical` | string | 0 | Compound name (natural key, from USDA) |
| `plant_species` | string | 0 | Botanical species name (natural key, from USDA) |
| `application` | string | 47,324 | Documented bioactivity / therapeutic use |
| `dosage` | string | 90,340 | Documented dosage from literature |
| `pubmed_mentions_2026` | Int64 | 0 | PubMed publication mention count (title/abstract search, 2026) |
| `clinical_trials_count_2026` | Int64 | 0 | ClinicalTrials.gov study count mentioning compound |
| `chembl_bioactivity_count` | Int64 | 0 | ChEMBL bioactivity assay count |
| `patent_count_since_2020` | Int64 | 0 | US patent count (USPTO PatentsView, since 2020-01-01) |

**Enrichment coverage:**

| Field | Non-zero % | Min | Max | Mean |
|---|---|---|---|---|
| `pubmed_mentions_2026` | 80.9% | -1 | 3,280,238 | 63,676 |
| `clinical_trials_count_2026` | 33.8% | 0 | 6,181 | 105 |
| `chembl_bioactivity_count` | 33.7% | 0 | 7,679 | 84 |
| `patent_count_since_2020` | 46.3% | 0 | 866,143 | 846 |

*Note: `pubmed_mentions_2026 = -1` indicates an API error during enrichment (logged, not retried).*

---

## Enrichment Pipeline

### 1. PubMed (NCBI E-utilities)

- **Endpoint:** `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi`
- **Query logic:** `term={compound_name}[Title/Abstract]` — substring match on title and abstract fields
- **Rate limiting:** 3 requests/second (NCBI default without API key)
- **Output:** Integer count of matching PubMed articles

### 2. ClinicalTrials.gov (API v2)

- **Endpoint:** `https://clinicaltrials.gov/api/v2/studies`
- **Query logic:** Free-text search for compound name across study titles and interventions
- **Rate limiting:** 5 requests/second, checkpoint every 100 compounds
- **Runtime:** ~2-3 hours for 24,771 unique compounds
- **Checkpoint:** `ct_checkpoint.json` — enables resume after interruption

### 3. ChEMBL (REST API v35)

- **Endpoint:** `https://www.ebi.ac.uk/chembl/api/data/activity`
- **Query logic:** Direct compound name lookup → if no hit, PubChem canonical name resolution → ChEMBL molecule search → bioactivity count
- **Fallback chain:** `compound_name` → PubChem → InChIKey → ChEMBL
- **Rate limiting:** 3 requests/second (`time.sleep(0.33)`)
- **Checkpoint:** `chembl_checkpoint.json` — every 100 compounds
- **Error handling:** `-1` logged for API failures (see `chembl_errors.log`)

### 4. PatentsView (USPTO API v1)

- **Endpoint:** `https://api.patentsview.org/patents/query`
- **Query logic:** Patents since 2020-01-01 with compound name in title or abstract
- **Rate limiting:** 45 requests/minute (PatentsView limit), semaphore(2) + 1.4s sleep
- **Checkpoint:** `patent_checkpoint.json` — every 100 compounds
- **Requirement:** Free API key via `PATENTSVIEW_API_KEY` environment variable

### 5. Merge & Export (`master_export_v2.py`)

- Merges all 4 enrichment outputs into unified dataset
- Exports: JSON (compact), Parquet (Snappy compressed), MANIFEST (SHA-256 checksums + statistics)
- 3-pass verification: record count, schema validation, checksum match

---

## Known Limitations

1. **ClinicalTrials.gov substring matching** inflates counts for compounds with common names (e.g., "ACID" matches many unrelated trials). Consider filtering by exact intervention match for precision-critical uses.

2. **PubMed counts include review articles** — the search does not distinguish original research from reviews, meta-analyses, or editorials. Use as a relative popularity signal, not an absolute measure.

3. **ChEMBL coverage ~34%** — approximately two-thirds of compounds are too obscure for structural data in ChEMBL. These receive `chembl_bioactivity_count = 0`.

4. **Species names** — USDA synonyms are not always current binomial nomenclature. Some legacy names may not match modern taxonomic databases (e.g., NCBI Taxonomy, GBIF).

5. **PubMed `-1` values** — indicate API errors during enrichment. These are a small fraction and are logged but not retried in the current pipeline.

6. **Patent counts (PatentsView)** — limited to US patents only. International patents (WIPO, EPO) are not included.

---

## Noise Exclusion

117 compounds classified as noise (including generic biochemical terms like PROTEIN, PROTEINS, WATER, LEAD, GLUCOSE with >500K PubMed matches that are not specific phytochemicals) and excluded from the enriched dataset.

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
  - Free 400-row sample: CC BY-NC 4.0
  - Full dataset: Commercial license (single-entity, team, or enterprise)
- **Enrichment scripts:** Available in this repository for transparency

---

## Version History

| Version | Date | Fields | Records | Changes |
|---|---|---|---|---|
| v1.0 | 2026-01 | 5 (chemical, plant_species, application, dosage, pubmed_mentions_2026) | 104,388 | Initial release with PubMed enrichment |
| v2.0 | 2026-03 | 8 (+clinical_trials_count_2026, chembl_bioactivity_count, patent_count_since_2020) | 104,388 | 4-source enrichment, noise exclusion (117 compounds removed from enrichment), checkpoint system |

---

## File Integrity

| File | Size | SHA-256 |
|---|---|---|
| `ethno_dataset_2026.json` | 23.3 MB | `c762a5b4769c78fc4ea63b4d6cf54d51109ac37bb0a01c4ce378668466f4878f` |
| `ethno_dataset_2026.parquet` | 975 KB | `38f8387612e5ee584d0d11b21c02c89a5850500d723c34bbe4bcacd6d6fe51b0` |

Export timestamp: `2026-03-11T12:32:03.467767+00:00`
