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
Current version: v2.3 (March 2026)
All versions are tagged in this repository.

## v2.3 Changelog
- PubChem CID/SMILES coverage: 75.4% (up from 71.8% in v2.2)
- CTS worker resolved 997 additional compounds via PubChem PUG-REST name-to-CID
- 2,741 records improved in correction pass
- DOI: 10.5281/zenodo.19265853

## Buyer Notifications
All dataset buyers receive email notification when a new version is available.
Buyers of v2.0, v2.1, or v2.2 receive the v2.3 update free of charge.

## Breaking Changes
Schema changes are announced minimum 30 days in advance via GitHub Discussions.

## Known Limitations
See METHODOLOGY.md for full documentation of data quality limitations and noise exclusions.
