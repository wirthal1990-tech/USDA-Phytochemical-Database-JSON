# Update Policy — Ethno-API Dataset

## Release Schedule
The full dataset is refreshed annually.
Next scheduled update: Q1 2027.

## Enrichment Sources
- PubMed via NCBI E-utilities (esearch)
- ClinicalTrials.gov AllPublicXML local snapshot
- ChEMBL REST API (with PubChem InChIKey fallback)
- PatentsView REST API (USPTO)
- PubChem PUG REST API (CID + Canonical SMILES)

## Versioning
Current version: v2.4.0 (April 2026)
All versions are tagged in this repository.

## v2.4.0 Changelog
- Added partner_cid column (cross-matched PubChem CID from COCONUT/FooDB)
- Added inchi_key column (InChI key for structural identification)
- Added iupac_verified column (IUPAC verification value from partner matching workflow)
- Added partner_match_method column (cross-match methodology transparency)
- Null-CID reduced to 17,616 (-8% vs v2.3.1)
- Schema expanded from 12 to 16 columns
- DOI: 10.5281/zenodo.19660107

## v2.3.1 Changelog
- Added compound_type column (5 categories: discrete_phytochemical, substance_class, complex_mixture, inorganic_element, generic_ambiguous)
- Added patent_count_method column (query methodology transparency)
- RESIN/RESINS CID correction (CID 133110026 was alpha-Copaene, set to NULL)
- Forensic audit corrections for inorganic/generic compounds
- PubChem CID/SMILES coverage: 75.4% (unchanged from v2.3)
- DOI: 10.5281/zenodo.19660107

## v2.3 Changelog
- PubChem CID/SMILES coverage: 75.4% (up from 71.8% in v2.2)
- CTS worker resolved 997 additional compounds via PubChem PUG-REST name-to-CID
- 2,741 records improved in correction pass
- DOI: 10.5281/zenodo.19660107

## Buyer Notifications
All dataset buyers receive email notification when a new version is available.
Buyers of v2.0, v2.1, v2.2, v2.3, or v2.3.1 receive the v2.4.0 update free of charge.

## Breaking Changes
Schema changes are announced minimum 30 days in advance via GitHub Discussions.

## Known Limitations
See METHODOLOGY.md for full documentation of data quality limitations and noise exclusions.

## Manifest Scope
`MANIFEST_v2.json` in this repository validates the public 400-row sample artifacts only.
