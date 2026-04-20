# Methodology — Ethno-API Phytochemical Dataset v2.4.0

> **Schema v2.4.0 · 76,907 records · 24,746 compounds · 2,313 species · 16 fields**

---

## Data Sources

| Source | Version / Access Date | License |
|---|---|---|
| USDA Dr. Duke's Phytochemical and Ethnobotanical Databases | Archive (2024 retirement snapshot) | Public Domain (USDA) |
| PubMed / NCBI E-utilities | Accessed 2026-01 via `esearch.fcgi` | Open (NCBI Terms of Use) |
| ClinicalTrials.gov | AllPublicXML local snapshot (2026-03) | Public Domain (NLM) |
| ChEMBL | v35 REST API, accessed 2026-02 | CC BY-SA 3.0 |
| PatentsView (USPTO) | API v1, patents since 2020-01-01 | Public Domain (USPTO) |
| PubChem (NCBI) | PUG REST API, accessed 2026-03 | Public Domain (NCBI) |

---

## Schema v2.4.0

| Field | Type | Sample Null Count (n=400) | Description |
|---|---|---|---|
| `chemical` | string | 0 | Compound name (natural key, from USDA) |
| `plant_species` | string | 0 | Botanical species name (natural key, from USDA) |
| `application` | string | 213 | Documented bioactivity / therapeutic use |
| `dosage` | string | 352 | Documented dosage from literature |
| `pubmed_mentions_2026` | Int64 | 0 | PubMed publication mention count (title/abstract search, 2026) |
| `clinical_trials_count_2026` | Int64 | 0 | ClinicalTrials.gov study count mentioning compound |
| `chembl_bioactivity_count` | Int64 | 0 | ChEMBL bioactivity assay count |
| `patent_count_since_2020` | nullable numeric | 4 | US patent count (USPTO PatentsView, since 2020-01-01) |
| `pubchem_cid` | nullable numeric | 107 | PubChem Compound ID (CID) |
| `canonical_smiles` | string | 107 | Canonical SMILES string (PubChem) |
| `compound_type` | string | 0 | Compound classification (`discrete_phytochemical`, `substance_class`, `complex_mixture`, `inorganic_element`, `generic_ambiguous`) |
| `patent_count_method` | string | 0 | Patent query method metadata |
| `partner_cid` | nullable numeric | 391 | Partner CID candidate used for unresolved compounds |
| `inchi_key` | float64 (sample parquet, all-null) | 400 | Logical field meaning is InChIKey text when populated; sample export currently serializes all-null values as numeric-null |
| `iupac_verified` | nullable string | 395 | IUPAC verification value from partner matching workflow |
| `partner_match_method` | nullable string | 391 | Partner matching method (e.g. `name_join`, `pubchem_name_resolve`) |

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

- Merges all 5 enrichment outputs (PubMed, ClinicalTrials, ChEMBL, Patents, PubChem SMILES/CID) into unified dataset
- Exports: JSON (indent=2), Parquet (Snappy compressed), MANIFEST (SHA-256 checksums + statistics)
- 3-pass verification: record count, schema validation, checksum match

### 6. PubChem (PUG REST API)

- **Endpoint:** `https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/{name}/JSON`
- **Query logic:** Name-to-CID resolution, returns `CID` + `CanonicalSMILES`
- **Queries:** 24,746 unique compound names
- **Resolved:** 11,481 compounds (46.4% of unique chemicals)
- **Unresolved:** 13,265 compounds (null in schema)
- **Rate limit:** 0.35s between requests, checkpoint-resumable
- **Runtime:** 3.2 hours (24,746 queries)
- **Output fields:** `canonical_smiles`, `pubchem_cid`

> **Why 53.6% are null:** Phytochemical trivial names (e.g. "TANNIN", "RESIN"), plant mixture descriptions (e.g. "ESSENTIAL OIL"), and non-specific ethnobotanical terms are not indexed in PubChem's compound database by name. These are inherent limitations of the source data, not pipeline failures.

### 7. CTS Synonym Enrichment (v2.4)

- **Goal:** Reduce the null-rate for `pubchem_cid` and `canonical_smiles` through systematic name variant resolution
- **Candidates:** 14,197 compounds without PubChem CID (after excluding truncated names and length < 3)
- **CTS API test:** UC Davis Chemical Translation Service tested first — **0% yield** for all ethnobotanical trivial names → CTS not suitable for this nomenclature
- **PubChem PUG-REST name variants:** 4 variants per compound:
  1. Original (e.g. `GALACTURONIC-ACID`)
  2. Hyphens → spaces (`galacturonic acid`)
  3. Lowercase (`galacturonic-acid`)
  4. Lowercase + spaces (`galacturonic acid`)
- **Checkpoint system:** Resume-safe, persisted every 100 API calls
- **Runtime:** ~3.5 hours at ~4.5 req/s
- **Result:** 997 unique compounds newly resolved (7.0% of candidates), 2,741 records improved
- **Coverage improvement:** 42.4% → **46.4%** unique compounds (10,484 → 11,481), 71.8% → **75.4%** records (55,217 → 57,958)
- **Remaining nulls:** 13,265 unique compounds (53.6%) are genuinely unresolvable — collective nouns (tannins, phytosterols, mucilage), historical herbal medicine names without PubChem entries, unresolved USDA Dr. Duke nomenclature from the 1980s/90s

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
| v2.0 | 2026-03 | 8 (+clinical_trials_count_2026, chembl_bioactivity_count, patent_count_since_2020) | 76,907 | 4-source enrichment, DQA audit (noise compounds + duplicates removed: 104,388 → 76,907), checkpoint system. Superseded by v2.1/v2.2. |
| v2.1 | 2026-03 | 10 (+pubchem_cid, canonical_smiles) | 76,907 | PubChem CID + SMILES enrichment (10,484 chemicals resolved, 71.8% record coverage — corrected to 42.4% in v2.2) |
| v2.2 | 2026-03 | 10 (same schema) | 76,907 | Stereo-prefix normalization for CT matching (+2 compounds), corrected SMILES coverage reporting (42.4% of unique chemicals), local CT XML matching replaces API |
| **v2.4** | **2026-03** | **10 (same schema)** | **76,907** | **CTS synonym enrichment: 997 compounds resolved via PubChem name variants (hyphen→space normalization), PubChem CID coverage 42.4%→46.4% unique / 71.8%→75.4% records** |
| **v2.4.0** | **2026-04** | **16 (+compound_type, patent_count_method, partner_cid, inchi_key, iupac_verified, partner_match_method)** | **76,907** | **CID audit, compound classification, patent method transparency, partner crossmatch fields, RESIN/RESINS CID correction, inorganic/generic reclassification** |

---

## File Integrity (Repository Artifacts)

| File | Size (bytes) | SHA-256 |
|---|---|---|
| `ethno_sample_400.json` | 226228 | `e7cdd6bd5156dd1ff71ce23523923a00b5f9b9931fea566f3a264e7319ccab44` |
| `ethno_sample_400.parquet` | 33485 | `694fb4e03ef026a97104368c991707553cc9c609e780a2f2f38ec2cef21d8e07` |
| `quickstart.ipynb` | 10660 | `08b62f1adb2b7b4c7e22a09a51f318da3d849256450db97960b2dce45dc13697` |
| `MANIFEST_v2.json` | 1883 | `8b5054afd3351a86ac8248bae448f18b3e77028ff605dfc031a2eda7549d150d` |

Repo note: Commercial full-release binaries (`ethno_dataset_2026_v2.4.0.*`, ZIP bundles) are not stored in this public sample repository and therefore are not verifiable here.
