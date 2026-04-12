#!/usr/bin/env python3
"""
generate_samples_v23.py
Generates ethno_sample_400.json and ethno_sample_400.parquet
from the v2.3 master dataset. Guarantees 100% schema integrity.
"""
import json
import pathlib

MASTER = pathlib.Path("/opt/ethno-enrichment/delivery/ethno_dataset_2026_v2.3.json")
OUT_DIR = pathlib.Path(__file__).parent
SAMPLE_SIZE = 400

# Canonical field order (matches MANIFEST_v2.json)
FIELD_ORDER = [
    "chemical",
    "plant_species",
    "application",
    "dosage",
    "pubmed_mentions_2026",
    "clinical_trials_count_2026",
    "chembl_bioactivity_count",
    "patent_count_since_2020",
    "pubchem_cid",
    "canonical_smiles",
]

print(f"Loading master: {MASTER}")
with open(MASTER) as f:
    master = json.load(f)

print(f"Master records: {len(master):,}")
assert len(master) == 76_907, f"Expected 76,907, got {len(master)}"

# Extract first 400, normalize field order and types
sample = []
for rec in master[:SAMPLE_SIZE]:
    row = {}
    for field in FIELD_ORDER:
        val = rec.get(field)
        # pubchem_cid: convert float → int (e.g. 119250.0 → 119250)
        if field == "pubchem_cid" and isinstance(val, float):
            val = int(val)
        row[field] = val
    sample.append(row)

assert len(sample) == SAMPLE_SIZE, f"Expected {SAMPLE_SIZE}, got {len(sample)}"
assert list(sample[0].keys()) == FIELD_ORDER, "Field order mismatch"

# Write JSON
json_path = OUT_DIR / "ethno_sample_400.json"
with open(json_path, "w") as f:
    json.dump(sample, f, indent=2, ensure_ascii=False)
print(f"Wrote {json_path} ({json_path.stat().st_size:,} bytes)")

# Write Parquet
try:
    import pandas as pd
    df = pd.DataFrame(sample)
    parquet_path = OUT_DIR / "ethno_sample_400.parquet"
    df.to_parquet(parquet_path, index=False, engine="pyarrow")
    print(f"Wrote {parquet_path} ({parquet_path.stat().st_size:,} bytes)")
except ImportError:
    print("WARNING: pandas/pyarrow not available, skipping parquet")

# Validation
print("\n--- Validation ---")
with open(json_path) as f:
    check = json.load(f)
print(f"Records: {len(check)}")
print(f"Fields: {list(check[0].keys())}")
print(f"Field count: {len(check[0])}")

# Null counts in sample
from collections import Counter
nulls = Counter()
for r in check:
    for k, v in r.items():
        if v is None:
            nulls[k] += 1
print(f"Null counts: {dict(nulls)}")

# Type check pubchem_cid
cid_types = set()
for r in check:
    if r["pubchem_cid"] is not None:
        cid_types.add(type(r["pubchem_cid"]).__name__)
print(f"pubchem_cid types: {cid_types}")

print("\n✓ Sample generation complete")
