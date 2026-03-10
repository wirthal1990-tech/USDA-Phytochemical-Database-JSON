#!/usr/bin/env python3
"""
Ethno-API Dataset v2.0 — ChromaDB Vector Ingest Script
=======================================================
Ingests all records into a local ChromaDB collection for RAG pipelines.

Usage:
    pip install chromadb pandas
    python3 chromadb_ingest.py

    # Resume interrupted ingest:
    python3 chromadb_ingest.py --resume

    # Custom input file:
    python3 chromadb_ingest.py --input /path/to/ethno_dataset_2026_v2.json

    # Custom ChromaDB persist directory:
    python3 chromadb_ingest.py --db ./my_chroma_db

After ingest, use:
    import chromadb
    client = chromadb.PersistentClient(path="./chroma_ethno_db")
    col = client.get_collection("ethno_phytochemical_v2")
    results = col.query(query_texts=["anti-inflammatory quercetin"], n_results=10)
"""

import argparse
import json
import os
import sys
import pandas as pd

# ─── CONFIGURATION — change INPUT_FILE to switch to full dataset ─────────────
INPUT_FILE    = "ethno_sample_400.json"       # CHANGE TO: ethno_dataset_2026_v2.json
COLLECTION    = "ethno_phytochemical_v2"
PERSIST_DIR   = "./chroma_ethno_db"
BATCH_SIZE    = 100
# ─────────────────────────────────────────────────────────────────────────────


def build_document_text(row: dict) -> str:
    """Constructs human-readable text for embedding from record fields."""
    parts = [f"Compound: {row['chemical']}"]
    if row.get("plant_species"):
        parts.append(f"Plant: {row['plant_species']}")
    if row.get("application"):
        parts.append(f"Application: {row['application']}")
    if row.get("dosage"):
        parts.append(f"Dosage: {row['dosage']}")
    parts.append(f"PubMed mentions (2026): {row['pubmed_mentions_2026']}")
    parts.append(f"Clinical trials (2026): {row['clinical_trials_count_2026']}")
    parts.append(f"ChEMBL bioassays: {row['chembl_bioactivity_count']}")
    parts.append(f"Patents since 2020: {row['patent_count_since_2020']}")
    return " | ".join(parts)


def build_metadata(row: dict) -> dict:
    """Returns all 8 fields as typed metadata for ChromaDB filtering."""
    return {
        "chemical":                   str(row["chemical"]),
        "plant_species":              str(row["plant_species"]),
        "application":                str(row.get("application") or ""),
        "dosage":                     str(row.get("dosage") or ""),
        "pubmed_mentions_2026":       int(row["pubmed_mentions_2026"]),
        "clinical_trials_count_2026": int(row["clinical_trials_count_2026"]),
        "chembl_bioactivity_count":   int(row["chembl_bioactivity_count"]),
        "patent_count_since_2020":    int(row["patent_count_since_2020"]),
    }


def main():
    parser = argparse.ArgumentParser(description="Ethno-API ChromaDB Ingest")
    parser.add_argument("--input",  default=INPUT_FILE,  help="Path to JSON dataset")
    parser.add_argument("--db",     default=PERSIST_DIR, help="ChromaDB persist dir")
    parser.add_argument("--resume", action="store_true", help="Skip existing IDs")
    args = parser.parse_args()

    try:
        import chromadb
    except ImportError:
        print("ERROR: chromadb not installed. Run: pip install chromadb")
        sys.exit(1)

    print(f"Loading dataset: {args.input}")
    df = pd.read_json(args.input)
    print(f"  Records: {len(df):,} | Columns: {list(df.columns)}")

    print(f"Connecting to ChromaDB: {args.db}")
    client = chromadb.PersistentClient(path=args.db)

    collection = client.get_or_create_collection(
        name=COLLECTION,
        metadata={"hnsw:space": "cosine", "description": "Ethno-API v2.0 phytochemical records"}
    )

    # Resume: get already-ingested IDs
    existing_ids = set()
    if args.resume:
        existing_ids = set(collection.get(include=[])["ids"])
        print(f"  Resume mode: {len(existing_ids):,} records already ingested")

    records    = df.to_dict(orient="records")
    total      = len(records)
    ingested   = 0
    skipped    = 0
    errors     = 0

    try:
        from tqdm import tqdm
        iterator = tqdm(range(0, total, BATCH_SIZE), desc="Ingesting")
    except ImportError:
        iterator = range(0, total, BATCH_SIZE)

    for batch_start in iterator:
        batch = records[batch_start : batch_start + BATCH_SIZE]

        ids, documents, metadatas = [], [], []
        for i, row in enumerate(batch):
            doc_id = f"{row['chemical']}::{row['plant_species']}::{batch_start + i}"
            if doc_id in existing_ids:
                skipped += 1
                continue
            ids.append(doc_id)
            documents.append(build_document_text(row))
            metadatas.append(build_metadata(row))

        if not ids:
            continue

        try:
            collection.add(ids=ids, documents=documents, metadatas=metadatas)
            ingested += len(ids)
        except Exception as e:
            print(f"  BATCH ERROR at {batch_start}: {e}")
            errors += 1
            continue

        if not hasattr(iterator, "update"):  # no tqdm
            print(f"  Progress: {min(batch_start + BATCH_SIZE, total):,}/{total:,}", end="\r")

    print(f"\nIngest complete:")
    print(f"  Ingested: {ingested:,}")
    print(f"  Skipped:  {skipped:,} (resume)")
    print(f"  Errors:   {errors}")
    print(f"  Collection count: {collection.count():,}")

    # Verification query
    print("\nVerification query (test: 'quercetin anti-inflammatory'):")
    results = collection.query(
        query_texts=["quercetin anti-inflammatory bioactivity"],
        n_results=3,
        include=["documents", "metadatas", "distances"]
    )
    for i, (doc, meta, dist) in enumerate(zip(
        results["documents"][0],
        results["metadatas"][0],
        results["distances"][0]
    )):
        print(f"  [{i+1}] {meta['chemical']} ({meta['plant_species']}) dist={dist:.4f}")

    expected = total - skipped
    if collection.count() >= expected - errors:
        print("\nINGEST_VERIFY_OK")
    else:
        print(f"\nINGEST_VERIFY_WARN: expected ~{expected}, got {collection.count()}")


if __name__ == "__main__":
    main()
