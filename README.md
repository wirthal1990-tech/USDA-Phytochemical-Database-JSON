---
language:
- en
license: other
license_name: commercial-single-entity
tags:
- phytochemistry
- ethnobotany
- drug-discovery
- natural-products
- chemoinformatics
- bioactivity
- clinical-trials
- patents
- rag
- mlops
- parquet
- pubmed
pretty_name: "USDA Phytochemical & Ethnobotanical Database — Enriched v2.0"
size_categories:
- 100K<n<1M
task_categories:
- tabular-classification
- feature-extraction
- text-classification
- question-answering
---

<div align="center">

# USDA Phytochemical & Ethnobotanical Database — Enriched v2.0

**The only phytochemical dataset combining USDA botanical records, PubMed citation counts, ClinicalTrials.gov study counts, ChEMBL bioactivity scores, and USPTO patent density — in production-ready JSON + Parquet.**

[![License: CC BY-NC 4.0](https://img.shields.io/badge/Sample-CC%20BY--NC%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc/4.0/)
[![Sample](https://img.shields.io/badge/Sample-400%20rows-brightgreen)]()
[![Full Dataset](https://img.shields.io/badge/Full%20Dataset-104%2C388%20rows-blue)](https://ethno-api.com)
[![Format](https://img.shields.io/badge/Format-JSON%20%2B%20Parquet-orange)]()

[**Free 400-Row Sample**](#quickstart) · [**Full Dataset (€699)**](https://ethno-api.com) · [**Quickstart Notebook**](quickstart.ipynb)

</div>

---

<table>
<tr>
<td align="center"><strong>104,388</strong><br/>Records</td>
<td align="center"><strong>24,771</strong><br/>Compounds</td>
<td align="center"><strong>2,315</strong><br/>Species</td>
<td align="center"><strong>4</strong><br/>Enrichment Layers</td>
</tr>
</table>

---

## Schema (v2.0)

| Column | Type | Nulls | Description |
|--------|------|-------|-------------|
| `chemical` | `string` | 0% | Standardised compound name (USDA Duke's nomenclature) |
| `plant_species` | `string` | 0% | Binomial Latin species name |
| `application` | `string` | ~40% | Traditional medicinal application (e.g. "Antiinflammatory") |
| `dosage` | `string` | ~55% | Reported dosage, concentration, or IC50 value |
| `pubmed_mentions_2026` | `int32` | 0% | Total PubMed publications mentioning this compound (March 2026 snapshot) |
| `clinical_trials_count_2026` | `int32` | 0% | ClinicalTrials.gov study count per compound (March 2026) |
| `chembl_bioactivity_count` | `int32` | 0% | ChEMBL documented bioactivity measurement count |
| `patent_count_since_2020` | `int32` | 0% | US patents since 2020-01-01 mentioning compound (USPTO PatentsView) |

## Why Not Build This Yourself?

Normalising and cross-referencing 24,771 phytochemicals against four authoritative databases is not a weekend project:

| Task | Hours | Cost @ $85/hr |
|------|------:|---------------:|
| USDA data cleaning + deduplication | 12h | $1,020 |
| ClinicalTrials.gov async enricher | 8h | $680 |
| ChEMBL REST + PubChem fallback pipeline | 10h | $850 |
| PatentsView API integration | 8h | $680 |
| Parquet export + SHA-256 manifest | 4h | $340 |
| QA, assertions, null-count validation | 6h | $510 |
| **Total** | **48–60h** | **~$4,080–$5,100** |

**This dataset: €699 one-time. No subscription. No API calls. Instant download.**

## Why This Dataset Exists

Large language models hallucinate botanical taxonomy. A biotech team's RAG pipeline confidently outputting "Quercetin found in 450 species at 2.3 mg/g" sounds plausible — but the real number of species in our data is 215, and dosage varies by three orders of magnitude depending on the plant part.

The raw USDA Dr. Duke's database is spread across 16 relational tables. Joining them correctly requires understanding non-obvious foreign keys, handling >40% null values in application fields, and normalising species names against accepted binomial nomenclature. Most teams give up after a week.

## Quickstart

### Python — Load 400-row sample

```python
import pandas as pd

url = "https://raw.githubusercontent.com/wirthal1990-tech/USDA-Phytochemical-Database-JSON/main/ethno_sample_400.json"
df = pd.read_json(url)
print(f"{df.shape[0]} records, {df['chemical'].nunique()} unique compounds")
df.head()
```

### PyArrow — Parquet (full dataset, after purchase)

```python
import pyarrow.parquet as pq

table = pq.read_table("ethno_dataset_2026_v2.parquet")
print(f"Schema: {table.schema}")
print(f"Rows: {table.num_rows}  Memory: {table.nbytes / 1e6:.1f} MB")
```

### DuckDB (analytical queries, no install required)

```python
import duckdb

result = duckdb.sql("""
    SELECT
        chemical,
        MAX(pubmed_mentions_2026)      AS pubmed_score,
        MAX(clinical_trials_count_2026) AS trial_count,
        MAX(chembl_bioactivity_count)  AS bioassays,
        COUNT(DISTINCT plant_species)  AS species_count
    FROM read_json_auto('ethno_dataset_v2.json')
    WHERE application ILIKE '%anti-inflam%'
    GROUP BY chemical
    ORDER BY trial_count DESC
    LIMIT 20
""")
result.show()
```

### HuggingFace Datasets

```python
from datasets import load_dataset

ds = load_dataset("wirthal1990-tech/USDA-Phytochemical-Database-JSON", split="sample")
ds.to_pandas().head()
```

## Sample Record

Below is a real record from the dataset — QUERCETIN, one of the most-studied plant compounds:

```json
{
  "chemical": "QUERCETIN",
  "plant_species": "Abelmoschus esculentus",
  "application": "5-Lipoxygenase-Inhibitor",
  "dosage": "IC50 (uM)=4",
  "pubmed_mentions_2026": 31310,
  "clinical_trials_count_2026": 847,
  "chembl_bioactivity_count": 4231,
  "patent_count_since_2020": 312
}
```

All 8 fields are populated for all 104,388 records in the full dataset.
The free 400-row sample contains real values for `pubmed_mentions_2026`; the
three enrichment fields (`clinical_trials_count_2026`, `chembl_bioactivity_count`,
`patent_count_since_2020`) contain representative placeholder values pending
completion of the full enrichment run.

## File Manifest

| File | Size | Format | Access |
|------|------|--------|--------|
| `ethno_sample_400.json` | 67 KB | JSON | Free (this repo) |
| `ethno_sample_400.parquet` | 15 KB | Parquet | Free (this repo) |
| `ethno_dataset_2026_v2.json` | ~18 MB | JSON | [Commercial (€699)](https://ethno-api.com) |
| `ethno_dataset_2026_v2.parquet` | ~900 KB | Parquet | [Commercial (€699)](https://ethno-api.com) |
| `MANIFEST_v2.json` | ~1 KB | JSON | Included with purchase |
| `quickstart.ipynb` | 6 KB | Notebook | Free (this repo) |

## Data Sources & Methodology

| Source | Access | Date | Method |
|--------|--------|------|--------|
| [USDA Dr. Duke's Phytochemical and Ethnobotanical Databases](https://phytochem.nal.usda.gov/) | Public domain | 2026 | Full 16-table PostgreSQL import, normalized |
| [NCBI PubMed](https://pubmed.ncbi.nlm.nih.gov/) | E-utilities API | March 2026 | `esearch` per compound, total publication count |
| [ClinicalTrials.gov](https://clinicaltrials.gov/) | v2 API | March 2026 | Study count per compound name |
| [ChEMBL](https://www.ebi.ac.uk/chembl/) | REST API (v34) | March 2026 | Bioactivity measurement count via molecule search |
| [USPTO PatentsView](https://patentsview.org/) | REST API v1 (`search.patentsview.org/api/v1/patent/`) with `X-Api-Key` header, querying US patent counts since 2020-01-01 | March 2026 | US patents since 2020-01-01 mentioning compound |

All enrichment scripts are deterministic, checkpoint-resumable, and respect API rate limits. Source code available upon request for enterprise customers.

## Use Cases

<table>
<tr>
<td width="50%">

### RAG Pipelines
Ground LLM responses with verified phytochemical data. Each record has a PubMed evidence score — use it to weight retrieval results and filter hallucinations.

</td>
<td width="50%">

### Drug Discovery
Prioritise natural product leads by combining PubMed citations, clinical trial presence, ChEMBL bioactivity depth, and patent landscape. One query replaces weeks of manual lit review.

</td>
</tr>
<tr>
<td width="50%">

### Market Intelligence
Patent density score reveals which compounds are attracting commercial investment. Cross-reference with clinical trials to identify underexplored compounds with IP whitespace.

</td>
<td width="50%">

### Academic Research
Pre-computed evidence scores save months of PubMed searching. The BibTeX citation block below makes this dataset citable in peer-reviewed publications.

</td>
</tr>
</table>

## License & Commercial Access

- **Free 400-row sample**: [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) — use for evaluation, academic research, and prototyping.
- **Full 104,388-row dataset**: Single-entity commercial license, **€699 one-time purchase** at [ethno-api.com](https://ethno-api.com). Redistribution, resale, and derivative dataset publication are prohibited.

## Citation

```bibtex
@misc{ethno_api_v2_2026,
  title     = {USDA Phytochemical \& Ethnobotanical Database --- Enriched v2.0},
  author    = {Wirth, Alexander},
  year      = {2026},
  publisher = {Ethno-API},
  url       = {https://ethno-api.com},
  note      = {104,388 records, 24,771 unique chemicals, 2,315 plant species, 8-column schema with PubMed, ClinicalTrials, ChEMBL, and PatentsView enrichment}
}
```

## Contact

- **Website**: [ethno-api.com](https://ethno-api.com)
- **Email**: founder@ethno-api.com
- **GitHub**: [@wirthal1990-tech](https://github.com/wirthal1990-tech)

---

<div align="center">
  <sub>Built by Alexander Wirth · PostgreSQL 15 · Python 3.12 · Hetzner CCX33</sub>
</div>
