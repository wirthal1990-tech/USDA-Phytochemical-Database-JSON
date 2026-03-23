# Update Policy — Ethno-API Dataset

## Release Schedule
The full dataset is refreshed annually.
Next scheduled update: Q1 2027.

## Enrichment Sources
- PubMed via NCBI E-utilities (esearch)
- ClinicalTrials.gov API v2
- ChEMBL REST API (with PubChem InChIKey fallback)
- PatentsView REST API (USPTO)
- PubChem PUG REST API (CID + Canonical SMILES)

## Versioning
Current version: v2.2 (March 2026)
All versions are tagged in this repository.

## Buyer Notifications
All dataset buyers receive email notification when a new version is available.
Buyers of v2.0 or v2.1 receive the v2.2 update free of charge.

## Breaking Changes
Schema changes are announced minimum 30 days in advance via GitHub Discussions.

## Known Limitations
See METHODOLOGY.md for full documentation of data quality limitations and noise exclusions.
