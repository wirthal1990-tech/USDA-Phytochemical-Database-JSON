---
license: cc-by-nc-4.0
task_categories:
  - text-generation
  - question-answering
  - feature-extraction
  - table-question-answering
language:
  - en
tags:
  - phytochemistry
  - ethnobotany
  - drug-discovery
  - pubmed
  - rag
  - pharmacology
  - natural-products
  - usda
  - bioactivity
pretty_name: "EthnoBotany Phytochemical Dataset (400-Row Sample)"
size_categories:
  - n<1K
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
      dtype: int64
  splits:
    - name: sample
      num_examples: 400
---

# EthnoBotany Phytochemical Dataset — 400-Row Sample Pack

> The **400 most heavily researched** phytochemical compounds from Dr. Duke's USDA Phytochemical & Ethnobotanical Database, enriched with 2026 PubMed publication mention counts.

[![License: CC BY-NC 4.0](https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc/4.0/)
[![Dataset: 400 rows](https://img.shields.io/badge/Sample-400%20rows-blue.svg)](#)
[![Full Dataset: 104k rows](https://img.shields.io/badge/Full%20Dataset-104%2C388%20rows-green.svg)](https://buy.stripe.com/4gM6oG74HcAXcdI2HKebu00)
[![Format: JSON + Parquet](https://img.shields.io/badge/Format-JSON%20%2B%20Parquet-orange.svg)](#formats)

---

## What's Inside

This sample contains **400 unique compounds** — one representative record per chemical — ranked by **PubMed publication mention count** (descending). Every record in this sample has been cited in at least **10,183 PubMed publications**.

| Metric | Value |
|--------|-------|
| **Rows** | 400 |
| **Unique Compounds** | 400 |
| **Unique Species** | 161 |
| **PubMed Range** | 10,183 – 3,280,238 mentions |
| **Median PubMed Mentions** | 26,229 |
| **JSON Size** | 66.9 KB |
| **Parquet Size** | 15.2 KB |

---

## Schema

| Column | Type | Description |
|--------|------|-------------|
| `chemical` | string | Compound name (e.g., QUERCETIN, CURCUMIN) |
| `plant_species` | string | Botanical species name (e.g., *Camellia sinensis*) |
| `application` | string \| null | Documented bioactivity (e.g., Antiinflammatory) |
| `dosage` | string \| null | Dosage from literature (e.g., 500 mg/day) |
| `pubmed_mentions_2026` | int64 | PubMed title/abstract mention count (2026) |

---

## Sample Records

```json
[
  {
    "chemical": "QUERCETIN",
    "plant_species": "Camellia sinensis",
    "application": "Antiinflammatory",
    "dosage": "500-1000 mg/day",
    "pubmed_mentions_2026": 31310
  },
  {
    "chemical": "CURCUMIN",
    "plant_species": "Curcuma longa",
    "application": "Antiinflammatory",
    "dosage": null,
    "pubmed_mentions_2026": 26229
  },
  {
    "chemical": "CAFFEINE",
    "plant_species": "Camellia sinensis",
    "application": "Analgesic",
    "dosage": "100-200 mg",
    "pubmed_mentions_2026": 41399
  }
]
```

---

## Quick Start

### Python (pandas)

```python
import pandas as pd

# From Parquet (recommended — 15 KB, typed columns)
df = pd.read_parquet("ethno_sample_400.parquet")

# From JSON
df = pd.read_json("ethno_sample_400.json")

# Top compounds by research volume
top = df.nlargest(10, "pubmed_mentions_2026")
print(top[["chemical", "plant_species", "pubmed_mentions_2026"]])
```

### HuggingFace Datasets

```python
from datasets import load_dataset

ds = load_dataset("YOUR_USERNAME/ethno-phytochemical-sample", split="sample")
print(ds[0])
```

### DuckDB (SQL)

```sql
SELECT chemical, plant_species, pubmed_mentions_2026
FROM read_parquet('ethno_sample_400.parquet')
WHERE pubmed_mentions_2026 > 50000
ORDER BY pubmed_mentions_2026 DESC;
```

---

## Formats

| File | Size | Format |
|------|------|--------|
| `ethno_sample_400.json` | 66.9 KB | UTF-8 JSON array, 400 objects |
| `ethno_sample_400.parquet` | 15.2 KB | Apache Parquet, Snappy compression |
| `ethno_sample_400_manifest.json` | — | SHA-256 checksums, schema, statistics |

### Integrity Verification

```bash
sha256sum ethno_sample_400.json
# cc4a841153477b9709544f602611da877b02065d6ad96156f38e444da5bde29b

sha256sum ethno_sample_400.parquet
# 7c4556bfd138af046988cba691d57ba853b92898b5bf19ec2649425355eeb54e
```

---

## Use Cases

| Use Case | How |
|----------|-----|
| **RAG Pipeline Grounding** | Embed compound–species pairs to ground LLMs in real phytochemical data |
| **Drug Discovery Screening** | Filter by bioactivity, cross-reference PubMed volume |
| **Nutraceutical Market Intel** | Identify trending compounds by publication velocity |
| **ML Model Training** | Compound–activity classification, species–compound prediction |
| **Data Pipeline Prototyping** | Validate your ETL before committing to the full 104k dataset |

---

## 🔓 Need the Full Dataset?

This sample is **0.38%** of the complete dataset.

| | Sample (Free) | Full Dataset |
|---|---|---|
| **Rows** | 400 | **104,388** |
| **Unique Compounds** | 400 | **24,771** |
| **Unique Species** | 161 | **2,315** |
| **PubMed Enrichment** | ✅ | ✅ |
| **JSON** | 66.9 KB | **16.4 MB** |
| **Parquet** | 15.2 KB | **761 KB** |
| **SHA-256 Manifest** | ✅ | ✅ |
| **Price** | Free | **€499 one-time** |
| **License** | CC BY-NC 4.0 | Commercial perpetual |

### **[→ Purchase Full Dataset (€499, Instant Download)](https://buy.stripe.com/4gM6oG74HcAXcdI2HKebu00)**

Includes JSON + Parquet + SHA-256 manifest. Perpetual commercial license. No subscription.

---

## Data Source

**USDA Dr. Duke's Phytochemical and Ethnobotanical Databases** — public-domain U.S. government data, structured and enriched by the EthnoBotany API team. PubMed mention counts sourced from NCBI E-utilities (title/abstract field search, 2026).

No LLM-generated or synthetic data. Every record is traceable to peer-reviewed sources.

---

## Citation

```bibtex
@dataset{ethnobotany_sample_2026,
  title   = {EthnoBotany Phytochemical Dataset (400-Row Sample)},
  author  = {Alexander Wirth},
  year    = {2026},
  url     = {https://ethno-api.com/enterprise.html},
  note    = {Top 400 compounds by PubMed mentions from USDA Duke's DB, enriched with 2026 PubMed counts}
}
```

## License

This sample is released under [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/). Commercial use requires the [full dataset license](https://buy.stripe.com/4gM6oG74HcAXcdI2HKebu00).

---

<p align="center">
  <strong><a href="https://ethno-api.com">ethno-api.com</a></strong> · Phytochemical Data Infrastructure<br>
  <a href="https://ethno-api.com/enterprise.html">Enterprise Dataset</a> · <a href="mailto:founder@ethno-api.com">Contact</a>
</p>
