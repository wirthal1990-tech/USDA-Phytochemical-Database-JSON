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
