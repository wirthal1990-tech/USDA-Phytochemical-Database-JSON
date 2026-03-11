# Launch Kit — Ethnobotany & Phytochemical Database 2026

*Copy/paste-ready posts with UTM-tracked links. All prices in EUR netto (§ 19 UStG).*

---

## UTM Link Reference

| Surface | Single €699 | Team €1.349 | Enterprise €1.699 |
|---------|-------------|-------------|-------------------|
| Reddit | [Single](https://buy.stripe.com/00w6oGgFh58v6Toeqsebu02?utm_source=reddit&utm_medium=post&utm_campaign=launch_2026_03) | [Team](https://buy.stripe.com/dRm7sK9cP1Wj0v06Y0ebu03?utm_source=reddit&utm_medium=post&utm_campaign=launch_2026_03) | [Enterprise](https://buy.stripe.com/dRm28q0Gj1WjdhM6Y0ebu04?utm_source=reddit&utm_medium=post&utm_campaign=launch_2026_03) |
| HN | [Single](https://buy.stripe.com/00w6oGgFh58v6Toeqsebu02?utm_source=hackernews&utm_medium=comment&utm_campaign=launch_2026_03) | [Team](https://buy.stripe.com/dRm7sK9cP1Wj0v06Y0ebu03?utm_source=hackernews&utm_medium=comment&utm_campaign=launch_2026_03) | [Enterprise](https://buy.stripe.com/dRm28q0Gj1WjdhM6Y0ebu04?utm_source=hackernews&utm_medium=comment&utm_campaign=launch_2026_03) |
| LinkedIn | [Single](https://buy.stripe.com/00w6oGgFh58v6Toeqsebu02?utm_source=linkedin&utm_medium=article&utm_campaign=launch_2026_03) | [Team](https://buy.stripe.com/dRm7sK9cP1Wj0v06Y0ebu03?utm_source=linkedin&utm_medium=article&utm_campaign=launch_2026_03) | [Enterprise](https://buy.stripe.com/dRm28q0Gj1WjdhM6Y0ebu04?utm_source=linkedin&utm_medium=article&utm_campaign=launch_2026_03) |
| Awesome PR | [Single](https://buy.stripe.com/00w6oGgFh58v6Toeqsebu02?utm_source=awesome_list&utm_medium=pr&utm_campaign=launch_2026_03) | [Team](https://buy.stripe.com/dRm7sK9cP1Wj0v06Y0ebu03?utm_source=awesome_list&utm_medium=pr&utm_campaign=launch_2026_03) | [Enterprise](https://buy.stripe.com/dRm28q0Gj1WjdhM6Y0ebu04?utm_source=awesome_list&utm_medium=pr&utm_campaign=launch_2026_03) |

---

## Reddit — Variant A (Technical / r/datasets, r/bioinformatics)

**Title:** I built a production-ready phytochemical dataset with PubMed + ChEMBL + ClinicalTrials + patent data — 104K records, JSON + Parquet

**Body:**

After months of enrichment pipeline work, I'm releasing the USDA Phytochemical & Ethnobotanical Database as a structured, analysis-ready dataset.

**What's in it:**
- 104,388 records, 24,771 unique compounds, 2,315 species
- 4 enrichment layers: PubMed citations, ChEMBL bioactivity counts, ClinicalTrials.gov study counts, USPTO patent density
- JSON + Parquet + SHA-256 manifest

**Free 400-row sample** (real PubMed data) on GitHub:
https://github.com/wirthal1990-tech/USDA-Phytochemical-Database-JSON?utm_source=reddit&utm_medium=post&utm_campaign=launch_2026_03

Quickstart notebook with DuckDB queries included. Full dataset starts at €699 one-time (no subscription).

Happy to answer questions about the enrichment pipeline or schema design.

---

## Reddit — Variant B (Business angle / r/startups, r/SaaS)

**Title:** From public-domain USDA data to a €699 commercial dataset — how I built a niche data product in 3 months

**Body:**

I took the USDA's phytochemical database (public domain, but unusable CSV files with no cross-references) and turned it into a commercial, analysis-ready dataset.

**The value-add:**
- Merged 4 external APIs (PubMed, ChEMBL, ClinicalTrials.gov, USPTO patents)
- Production schema: 56 fields per record, validated types, consistent naming
- JSON + Parquet + DuckDB-ready

**Market:** Nutraceutical companies, supplement R&D, academic drug discovery labs, biotech startups.

**Pricing:** 3 tiers (€699 / €1.349 / €1.699) — one-time, no subscription.

Free 400-row sample: https://github.com/wirthal1990-tech/USDA-Phytochemical-Database-JSON?utm_source=reddit&utm_medium=post&utm_campaign=launch_2026_03

The economics are counterintuitive — the raw data is free, but the enrichment pipeline cost ~€3K in API calls and engineering time. Most buyers are saving themselves weeks of data wrangling.

---

## Hacker News — Show HN Comment

**Title:** Show HN: Enriched Phytochemical Database – 104K records, PubMed + ChEMBL + Patents (JSON + Parquet)

**Comment:**

I spent the last 3 months building enrichment pipelines on top of the USDA Phytochemical & Ethnobotanical Database. The result: 104,388 records with PubMed citations, ChEMBL bioactivity scores, ClinicalTrials.gov counts, and USPTO patent density — all in a single, normalized JSON + Parquet file.

The free 400-row sample runs with DuckDB out of the box:

https://github.com/wirthal1990-tech/USDA-Phytochemical-Database-JSON?utm_source=hackernews&utm_medium=comment&utm_campaign=launch_2026_03

Schema: 56 fields per record. Every record has all 4 enrichment layers populated. Full dataset: €699 one-time (3 tiers available).

The hard part wasn't the USDA data — it was normalizing 24,771 compound names across 4 different APIs with different naming conventions. Happy to discuss the pipeline architecture.

---

## LinkedIn — Article / Post

**Headline:** Why I Built a €699 Phytochemical Dataset (And What It Means for Drug Discovery)

**Body:**

The USDA maintains a phytochemical database with over 100K records — but it's buried in unusable CSV files with no cross-references to modern research databases.

I spent 3 months building enrichment pipelines that connect each compound to:
📊 PubMed citation counts (how much research exists?)
🧬 ChEMBL bioactivity scores (how biologically active?)
🏥 ClinicalTrials.gov study counts (any clinical evidence?)
📋 USPTO patent density since 2020 (is anyone commercializing this?)

The result: 104,388 structured records spanning 24,771 compounds and 2,315 species.

🔬 Use case: A nutraceutical company can query "which compounds have >50 PubMed mentions, >0 clinical trials, but <5 patents?" — and get a prioritized R&D shortlist in seconds.

Free 400-row sample (real PubMed data): https://github.com/wirthal1990-tech/USDA-Phytochemical-Database-JSON?utm_source=linkedin&utm_medium=article&utm_campaign=launch_2026_03

Full dataset: 3 tiers from €699 — https://ethno-api.com?utm_source=linkedin&utm_medium=article&utm_campaign=launch_2026_03

#PhytoChemistry #DrugDiscovery #DataScience #Bioinformatics #OpenData

---

## Awesome List PR Notes

**Target lists:**
- `awesome-datasets` — Add under "Science" or "Biology"
- `awesome-bioinformatics` — Add under "Databases"
- `awesome-drug-discovery` — if it exists

**PR description template:**

```
### USDA Phytochemical & Ethnobotanical Database (Enriched)

104,388 records · 24,771 compounds · 2,315 species · PubMed + ChEMBL + ClinicalTrials + Patents

- [GitHub (Free 400-row sample)](https://github.com/wirthal1990-tech/USDA-Phytochemical-Database-JSON?utm_source=awesome_list&utm_medium=pr&utm_campaign=launch_2026_03)
- [HuggingFace Dataset](https://huggingface.co/datasets/wirthal1990-tech/USDA-Phytochemical-Database-JSON?utm_source=awesome_list&utm_medium=pr&utm_campaign=launch_2026_03)
- Format: JSON + Parquet · Free sample: CC BY-NC 4.0 · Full dataset: Commercial license from €699
```

**One-liner for list entry:**

```markdown
- [USDA Phytochemical Database (Enriched)](https://github.com/wirthal1990-tech/USDA-Phytochemical-Database-JSON) — 104K records with PubMed, ChEMBL, ClinicalTrials, and patent enrichment layers. Free 400-row sample.
```

---

## Quick Copy: Plain URLs with UTM

```
# GitHub (reddit)
https://github.com/wirthal1990-tech/USDA-Phytochemical-Database-JSON?utm_source=reddit&utm_medium=post&utm_campaign=launch_2026_03

# GitHub (HN)
https://github.com/wirthal1990-tech/USDA-Phytochemical-Database-JSON?utm_source=hackernews&utm_medium=comment&utm_campaign=launch_2026_03

# GitHub (LinkedIn)
https://github.com/wirthal1990-tech/USDA-Phytochemical-Database-JSON?utm_source=linkedin&utm_medium=article&utm_campaign=launch_2026_03

# ethno-api.com (reddit)
https://ethno-api.com?utm_source=reddit&utm_medium=post&utm_campaign=launch_2026_03

# ethno-api.com (HN)
https://ethno-api.com?utm_source=hackernews&utm_medium=comment&utm_campaign=launch_2026_03

# ethno-api.com (LinkedIn)
https://ethno-api.com?utm_source=linkedin&utm_medium=article&utm_campaign=launch_2026_03

# HuggingFace
https://huggingface.co/datasets/wirthal1990-tech/USDA-Phytochemical-Database-JSON?utm_source=reddit&utm_medium=post&utm_campaign=launch_2026_03
```
