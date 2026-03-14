---
annotations_creators:
- machine-generated
language_creators:
- found
language:
- en
license: cc-by-nc-4.0
multilinguality: monolingual
pretty_name: "USDA Phytochemical & Ethnobotanical Database — Enriched v2.0"
size_categories:
- 100K<n<1M
source_datasets:
- original
task_categories:
- tabular-classification
- feature-extraction
- text-classification
- question-answering
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
- usda
- llm-grounding
- biotech
dataset_info:
  features:
    - name: chemical
      dtype: string
    - name: plant_species
      dtype: string
    - name: application
      dtype: string
    - name: dosage
      dtype: string
    - name: pubmed_mentions_2026
      dtype: int32
    - name: clinical_trials_count_2026
      dtype: int32
    - name: chembl_bioactivity_count
      dtype: int32
    - name: patent_count_since_2020
      dtype: int32
  splits:
    - name: sample
      num_examples: 400
  config_name: default
---

> ⚡ **Early Access — First 10 buyers: 57 % off.** Single €299 · Team €549 · Enterprise €899. [→ ethno-api.com](https://ethno-api.com)

<div align="center">

# USDA Phytochemical & Ethnobotanical Database — Enriched v2.0

**The only phytochemical dataset combining USDA botanical records, PubMed citation counts, ClinicalTrials.gov study counts, ChEMBL bioactivity scores, and USPTO patent density — in production-ready JSON + Parquet.**

[![License: CC BY-NC 4.0](https://img.shields.io/badge/Sample-CC%20BY--NC%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc/4.0/)
[![Sample](https://img.shields.io/badge/Sample-400%20rows-brightgreen)](https://huggingface.co/datasets/wirthal1990-tech/USDA-Phytochemical-Database-JSON)
[![Full Dataset](https://img.shields.io/badge/Full%20Dataset-104%2C388%20rows-blue)](https://ethno-api.com)
[![Format](https://img.shields.io/badge/Format-JSON%20%2B%20Parquet-orange)](https://ethno-api.com)
[![HuggingFace](https://img.shields.io/badge/%F0%9F%A4%97%20HuggingFace-Dataset-yellow)](https://huggingface.co/datasets/wirthal1990-tech/USDA-Phytochemical-Database-JSON)

[**Free 400-Row Sample ↓**](#quickstart) · [⚡ **Single €299 Early Bird →**](https://buy.stripe.com/7sY9AS1KncAX5Pk0zCebu06?utm_source=github&utm_medium=readme&utm_campaign=launch_2026_03) · [⚡ **Team €549 Early Bird →**](https://buy.stripe.com/14AdR8bkX8kHelQ0zCebu07?utm_source=github&utm_medium=readme&utm_campaign=launch_2026_03) · [⚡ **Enterprise €899 Early Bird →**](https://buy.stripe.com/fZu00iex930nelQ824ebu08?utm_source=github&utm_medium=readme&utm_campaign=launch_2026_03)

> **Enrichment status (March 2026):** All four enrichment layers (PubMed, ClinicalTrials.gov, ChEMBL, PatentsView) are **complete and final**. The free 400-row sample contains real enrichment values.

</div>

---

| Records | Compounds | Species | Enrichment Layers |
|--------:|----------:|--------:|------------------:|
| **104,388** | **24,771** | **2,315** | **4** |

---

## Schema (v2.0)

| Column | Type | Nulls | Description |
|--------|------|-------|-------------|
| `chemical` | `string` | 0% | Standardised compound name (USDA Duke’s nomenclature) |
| `plant_species` | `string` | 0% | Binomial Latin species name |
| `application` | `string` | ~40% | Traditional medicinal application (e.g. “Antiinflammatory”) |
| `dosage` | `string` | ~55% | Reported dosage, concentration, or IC50 value |
| `pubmed_mentions_2026` | `int32` | 0% | Total PubMed publications mentioning this compound (March 2026 snapshot) |
| `clinical_trials_count_2026` | `int32` | 0% | ClinicalTrials.gov study count per compound (March 2026) |
| `chembl_bioactivity_count` | `int32` | 0% | ChEMBL documented bioactivity measurement count |
| `patent_count_since_2020` | `int32` | 0% | US patents since 2020-01-01 mentioning compound (USPTO PatentsView) |

---

## Pricing & Licensing

| Tier | Price | Includes | Purchase |
|------|-------|----------|----------|
| **Single Entity** | ⚡ **€299** netto (Early Bird, reg. €699) | JSON + Parquet + SHA-256 Manifest. 1 juristische Person, interne Nutzung. Perpetual license. | [⚡ **Buy Now →**](https://buy.stripe.com/7sY9AS1KncAX5Pk0zCebu06?utm_source=github&utm_medium=readme&utm_campaign=launch_2026_03) |
| **Team** | ⚡ **€549** netto (Early Bird, reg. €1.349) | Alles aus Single + `duckdb_queries.sql` (20 Queries, 5 Kategorien) + `compound_priority_score.py` + 4 Pre-computed Views (Top-500 nach PubMed, Trials, Patent-Dichte, Anti-Inflammatory Panel). Unbegrenzte interne Nutzer einer juristischen Person. | [⚡ **Buy Now →**](https://buy.stripe.com/14AdR8bkX8kHelQ0zCebu07?utm_source=github&utm_medium=readme&utm_campaign=launch_2026_03) |
| **Enterprise** | ⚡ **€899** netto (Early Bird, reg. €1.699) | Alles aus Team + `snowflake_load.sql` + `chromadb_ingest.py` + `pinecone_ingest.py` + `embedding_guide.md` (ClinicalBERT, RAG-Pipelines) + Compound Opportunity Matrix + Clinical Pipeline Gaps CSV + Pre-chunked RAG JSONL. Multi-Entity / Konzernnutzung, interne Produktintegration erlaubt. | [⚡ **Buy Now →**](https://buy.stripe.com/fZu00iex930nelQ824ebu08?utm_source=github&utm_medium=readme&utm_campaign=launch_2026_03) |

> Gemäß § 19 UStG wird keine Umsatzsteuer berechnet. Alle Preise netto. One-time purchase — keine Subscription, keine wiederkehrenden Kosten.

---

## Why Not Build This Yourself?

Normalising and cross-referencing **24,771 phytochemicals** across multiple authoritative sources is not a weekend project.

| Scope | Effort | Cost @ $85/hr |
|------|------:|---------------:|
| USDA cleaning + normalization + enrichment + exports + QA | **48–60h** | **~$4,080–$5,100** |

**This dataset: €299 Early Bird (regular €699). No subscription. No API calls. Download link sent instantly after payment. Valid for 72 hours. See ethno-api.com.**

---

## Why This Dataset Exists

Large language models hallucinate botanical taxonomy. A biotech team’s RAG pipeline confidently outputting “Quercetin found in 450 species at 2.3 mg/g” sounds plausible — but the real number of species in our data is 215, and dosage varies by three orders of magnitude depending on the plant part.

The raw USDA Dr. Duke’s database is spread across 16 relational tables. Joining them correctly requires understanding non-obvious foreign keys, handling >40% null values in application fields, and normalising species names against accepted binomial nomenclature. Most teams give up after a week.

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

Download link delivered instantly after payment (valid 72h). See ethno-api.com.

```python
import pyarrow.parquet as pq

table = pq.read_table("ethno_dataset_2026_v2.parquet")
print(f"Schema: {table.schema}")
print(f"Rows: {table.num_rows}  Memory: {table.nbytes / 1e6:.1f} MB")
```

### DuckDB (analytical queries — sample included)

```python
import duckdb

result = duckdb.sql("""
    SELECT
        chemical,
        MAX(pubmed_mentions_2026)       AS pubmed_score,
        MAX(clinical_trials_count_2026) AS trial_count,
        MAX(chembl_bioactivity_count)   AS bioassays,
        COUNT(DISTINCT plant_species)   AS species_count
    FROM read_json_auto('ethno_sample_400.json')
    GROUP BY chemical
    ORDER BY trial_count DESC
    LIMIT 20
""")
result.show()
```

### HuggingFace Datasets

```python
from datasets import load_dataset

ds = load_dataset(
    "wirthal1990-tech/USDA-Phytochemical-Database-JSON",
    split="sample",
    trust_remote_code=False
)
df = ds.to_pandas()
print(f"Records: {len(df)} | Columns: {list(df.columns)}")
df.head()
```

> **Note:** The `split="sample"` loads `ethno_sample_400.json` (400 rows, 8 columns).
> The full 104,388-row dataset is available at [ethno-api.com](https://ethno-api.com).

## Sample Record

Below is a real record from the dataset — QUERCETIN, one of the most-studied plant compounds:

```json
{
  "chemical": "QUERCETIN",
  "plant_species": "Drimys winteri",
  "application": "5-Lipoxygenase-Inhibitor",
  "dosage": "IC50 (uM)=4",
  "pubmed_mentions_2026": 31310,
  "clinical_trials_count_2026": 81,
  "chembl_bioactivity_count": 2871,
  "patent_count_since_2020": 73
}
```

All 8 fields are populated for all 104,388 records in the full dataset.
The free 400-row sample contains real, final enrichment values across all four layers.

## File Manifest

| File | Size | Format | Access |
|------|------|--------|--------|
| `ethno_sample_400.json` | 108 KB | JSON | Free (this repo) |
| `ethno_sample_400.parquet` | 20 KB | Parquet | Free (this repo) |
| `quickstart.ipynb` | 9 KB | Notebook | Free (this repo) |
| `ethno_dataset_2026_v2.json` | ~23 MB | JSON | Included in all tiers |
| `ethno_dataset_2026_v2.parquet` | ~975 KB | Parquet | Included in all tiers |
| `MANIFEST_v2.json` (SHA-256) | ~1 KB | JSON | Included in all tiers |
| `duckdb_queries.sql` (20 Queries) | ~13 KB | SQL | Team + Enterprise |
| `compound_priority_score.py` | ~5 KB | Python | Team + Enterprise |
| `snowflake_load.sql` | ~6 KB | SQL | Enterprise |
| `chromadb_ingest.py` | ~6 KB | Python | Enterprise |
| `pinecone_ingest.py` | ~6 KB | Python | Enterprise |
| `embedding_guide.md` | ~7 KB | Markdown | Enterprise |

## Data Sources & Provenance

All enrichment layers are derived from authoritative, publicly accessible scientific databases and represent a **March 2026 snapshot**.

| Source | Snapshot | What it contributes |
|--------|----------|---------------------|
| [USDA Dr. Duke’s Phytochemical and Ethnobotanical Databases](https://phytochem.nal.usda.gov/) | 2026 | Canonical plant–compound–application baseline across 2,315 species |
| [NCBI PubMed](https://pubmed.ncbi.nlm.nih.gov/) | March 2026 | Compound-level publication evidence score |
| [ClinicalTrials.gov](https://clinicaltrials.gov/) | March 2026 | Compound-level clinical research activity score |
| [ChEMBL](https://www.ebi.ac.uk/chembl/) | March 2026 | Compound-level bioactivity measurement depth |
| [USPTO PatentsView](https://patentsview.org/) | March 2026 | Compound-level commercial IP activity score |

Enrichment methodology is documented in [`METHODOLOGY.md`](METHODOLOGY.md). Source code is available to **Enterprise** license holders upon request under **NDA**.

## Use Cases

- **RAG Pipelines** — Ground LLM responses with verified phytochemical data. Each record has a PubMed evidence score — use it to weight retrieval results and filter hallucinations.
- **Drug Discovery** — Prioritise natural product leads by combining PubMed citations, clinical trial presence, ChEMBL bioactivity depth, and patent landscape. One query replaces weeks of manual lit review.
- **Market Intelligence** — Patent density score reveals which compounds are attracting commercial investment. Cross-reference with clinical trials to identify underexplored compounds with IP whitespace.
- **Academic Research** — Pre-computed evidence scores save months of PubMed searching. The BibTeX citation block below makes this dataset citable in peer-reviewed publications.

## Dataset Versions

| Version | Records | Schema | Status |
|---------|--------:|--------|--------|
| v1.0 | 104,388 | 5 columns (USDA baseline) | Deprecated |
| **v2.0** | **104,388** | **8 columns (+ PubMed, ClinicalTrials, ChEMBL, Patents)** | **Current** |

The free sample (`ethno_sample_400.json`) uses the v2.0 schema with final enrichment values across all four layers.

## License & Commercial Access

- **Free 400-row sample**: [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) — use for evaluation, academic research, and prototyping.
- **Single Entity License — €299 Early Bird** (reg. €699) one-time: [⚡ **Buy →**](https://buy.stripe.com/7sY9AS1KncAX5Pk0zCebu06?utm_source=github&utm_medium=readme&utm_campaign=launch_2026_03) — 1 legal entity, internal use, perpetual. No redistribution.
- **Team License — €549 Early Bird** (reg. €1.349) one-time: [⚡ **Buy →**](https://buy.stripe.com/14AdR8bkX8kHelQ0zCebu07?utm_source=github&utm_medium=readme&utm_campaign=launch_2026_03) — all employees of 1 legal entity, unlimited internal users, includes analytics toolkit.
- **Enterprise License — €899 Early Bird** (reg. €1.699) one-time: [⚡ **Buy →**](https://buy.stripe.com/fZu00iex930nelQ824ebu08?utm_source=github&utm_medium=readme&utm_campaign=launch_2026_03) — multi-entity / group use, internal product integration rights, full RAG integration toolkit.

> Gemäß § 19 UStG wird keine Umsatzsteuer berechnet.

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
