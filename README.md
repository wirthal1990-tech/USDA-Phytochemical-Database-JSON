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
pretty_name: "USDA Phytochemical & Ethnobotanical Database — Enriched v2.0"
size_categories:
- 100K<n<1M
task_categories:
- tabular-classification
- feature-extraction
---

<div align="center">

# 🌿 USDA Phytochemical & Ethnobotanical Database — Enriched v2.0

**The most comprehensive, ML-ready phytochemical dataset available.**

[![Records](https://img.shields.io/badge/records-104%2C388-brightgreen)]()
[![Chemicals](https://img.shields.io/badge/unique_chemicals-24%2C771-blue)]()
[![Species](https://img.shields.io/badge/species-2%2C315-orange)]()
[![Schema](https://img.shields.io/badge/schema-8_columns-informational)]()
[![License](https://img.shields.io/badge/license-commercial-red)]()
[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.pending-blue)]()

[**Free 400-Row Sample**](#quickstart) · [**Full Dataset (€699)**](https://buy.stripe.com/4gM6oG74HcAXcdI2HKebu00) · [**API Docs**](https://ethno-api.com)

</div>

---

## What Is This?

A cross-referenced dataset linking **24,771 phytochemicals** to **2,315 plant species** with traditional-use annotations, dosages, and four enrichment layers from authoritative scientific databases:

| Column | Type | Source | Description |
|--------|------|--------|-------------|
| `chemical` | `string` | USDA Duke's | Standardised compound name |
| `plant_species` | `string` | USDA Duke's | Binomial species name |
| `application` | `string` | USDA Duke's | Traditional medicinal use |
| `dosage` | `string` | USDA Duke's | Reported dosage / concentration |
| `pubmed_mentions_2026` | `int32` | NCBI PubMed | Publication count (2026 snapshot) |
| `clinical_trials_count_2026` | `int32` | ClinicalTrials.gov | Active + completed trial count |
| `chembl_bioactivity_count` | `int32` | ChEMBL / PubChem | Bioassay data points |
| `patent_count_since_2020` | `int32` | PatentsView (USPTO) | US patents since 2020-01-01 |

## Why v2.0?

Version 1.0 had 5 columns. Version 2.0 adds three high-value enrichment columns that **no other public dataset** provides in a single file:

- **ClinicalTrials.gov** — Filter compounds that have already entered human trials
- **ChEMBL bioactivity** — Prioritise compounds with extensive *in-vitro* / *in-vivo* data
- **USPTO patents** — Gauge commercial interest and IP landscape

Together, these fields enable use cases like:
- 🎯 **Lead prioritisation** — rank compounds by combined evidence score
- 📊 **Patent landscape analysis** — identify white-space opportunities
- 🤖 **ML feature engineering** — ready-made features for drug-discovery models
- 🧬 **Ethnopharmacology research** — link traditional use to modern evidence

## Quickstart

### Python (400-row free sample)

```python
import pandas as pd

url = "https://raw.githubusercontent.com/wirthal1990-tech/USDA-Phytochemical-Database-JSON/main/ethno_sample_400.json"
df = pd.read_json(url)

# Top 10 chemicals with most clinical trials
print(df.nlargest(10, "pubmed_mentions_2026")[["chemical", "plant_species", "pubmed_mentions_2026"]])
```

### Load Parquet (full dataset, after purchase)

```python
import pandas as pd

df = pd.read_parquet("ethno_dataset_v2.parquet")
print(f"Shape: {df.shape}")
print(df.describe())
```

### HuggingFace Datasets

```python
from datasets import load_dataset

ds = load_dataset("wirthal1990-tech/USDA-Phytochemical-Database-JSON")
print(ds["train"].features)
```

## File Manifest

| File | Size | Format | Description |
|------|------|--------|-------------|
| `ethno_sample_400.json` | ~120 KB | JSON | Free sample (400 unique chemicals) |
| `ethno_sample_400.parquet` | ~15 KB | Parquet | Free sample (columnar) |
| `ethno_dataset_v2.json` | ~18 MB | JSON | **Full dataset** (commercial) |
| `ethno_dataset_v2.parquet` | ~900 KB | Parquet | **Full dataset** (columnar, commercial) |
| `ethno_dataset_v2_manifest.json` | ~1 KB | JSON | Schema, stats, SHA-256 checksums |

## Data Sources & Methodology

1. **Base data** — [USDA Dr. Duke's Phytochemical and Ethnobotanical Databases](https://phytochem.nal.usda.gov/) (public domain)
2. **PubMed enrichment** — NCBI E-utilities API, queried March 2026 for each of 24,771 compounds
3. **ClinicalTrials.gov** — v2 API, querying intervention field per compound
4. **ChEMBL** — REST API with PubChem InChIKey fallback for compounds not directly indexed
5. **PatentsView** — POST API for US patent counts since 2020-01-01

All enrichment scripts are deterministic, checkpoint-resumable, and respect API rate limits.

## Citation

```bibtex
@dataset{ethno_api_v2_2026,
  title     = {USDA Phytochemical & Ethnobotanical Database — Enriched v2.0},
  author    = {Wirthal, Alexander},
  year      = {2026},
  publisher = {Ethno-API},
  url       = {https://ethno-api.com},
  note      = {104,388 records, 24,771 chemicals, 2,315 species, 8-column schema}
}
```

## License

The **free 400-row sample** is provided under CC-BY-4.0 for evaluation.

The **full dataset** is sold under a single-entity commercial license (€699 one-time).
Redistribution, resale, and derivative dataset publication are prohibited.
See [ethno-api.com](https://ethno-api.com) for full terms.

## Contact

- **Website**: [ethno-api.com](https://ethno-api.com)
- **Email**: founder@ethno-api.com
- **GitHub**: [@wirthal1990-tech](https://github.com/wirthal1990-tech)

---

<div align="center">
  <sub>Built with 🧪 by Ethno-API · Hetzner CCX33 · PostgreSQL 15 · Python 3.12</sub>
</div>
