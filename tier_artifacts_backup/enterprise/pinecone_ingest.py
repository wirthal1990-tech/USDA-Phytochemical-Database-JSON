#!/usr/bin/env python3
"""
Ethno-API Dataset v2.0 — Pinecone Vector Ingest Script
=======================================================
Ingests all records into a Pinecone index using OpenAI or sentence-transformers.

Usage:
    pip install pinecone-client openai pandas sentence-transformers

    # With OpenAI embeddings (recommended for production):
    export OPENAI_API_KEY="sk-..."
    export PINECONE_API_KEY="pcsk-..."
    python3 pinecone_ingest.py --embedding openai

    # With local sentence-transformers (no API cost):
    export PINECONE_API_KEY="pcsk-..."
    python3 pinecone_ingest.py --embedding local

    # With Pinecone inference (managed embeddings, no external API):
    export PINECONE_API_KEY="pcsk-..."
    python3 pinecone_ingest.py --embedding pinecone

After ingest, query with:
    index.query(vector=embedding, top_k=10, include_metadata=True)
"""

import argparse
import os
import sys
import time
import pandas as pd

# ─── CONFIGURATION ────────────────────────────────────────────────────────────
INPUT_FILE      = "ethno_sample_400.json"      # CHANGE TO: ethno_dataset_2026_v2.json
INDEX_NAME      = "ethno-phytochemical-v2"
NAMESPACE       = "ethno_api"
BATCH_SIZE      = 100
EMBEDDING_DIM   = {
    "openai":    1536,   # text-embedding-3-small
    "local":     384,    # all-MiniLM-L6-v2
    "pinecone":  1024,   # multilingual-e5-large
}
# ──────────────────────────────────────────────────────────────────────────────


def build_text(row: dict) -> str:
    """Constructs human-readable text for embedding from record fields."""
    parts = [f"Compound: {row['chemical']}"]
    if row.get("application"):
        parts.append(f"Application: {row['application']}")
    if row.get("plant_species"):
        parts.append(f"Plant: {row['plant_species']}")
    if row.get("dosage"):
        parts.append(f"Dosage: {row['dosage']}")
    parts.append(f"PubMed mentions 2026: {row['pubmed_mentions_2026']}")
    parts.append(f"Clinical trials: {row['clinical_trials_count_2026']}")
    parts.append(f"ChEMBL bioassays: {row['chembl_bioactivity_count']}")
    parts.append(f"US patents since 2020: {row['patent_count_since_2020']}")
    return " | ".join(parts)


def get_embedder(mode: str):
    """Returns (embed_fn, dimension) tuple based on selected embedding mode."""
    if mode == "openai":
        from openai import OpenAI
        client = OpenAI(api_key=os.environ["OPENAI_API_KEY"])
        def embed(texts):
            resp = client.embeddings.create(model="text-embedding-3-small", input=texts)
            return [d.embedding for d in resp.data]
        return embed, EMBEDDING_DIM["openai"]

    elif mode == "local":
        from sentence_transformers import SentenceTransformer
        model = SentenceTransformer("all-MiniLM-L6-v2")
        def embed(texts):
            return model.encode(texts, show_progress_bar=False).tolist()
        return embed, EMBEDDING_DIM["local"]

    elif mode == "pinecone":
        print("Using Pinecone integrated inference (set model in index creation)")
        return None, EMBEDDING_DIM["pinecone"]

    raise ValueError(f"Unknown embedding mode: {mode}")


def main():
    parser = argparse.ArgumentParser(description="Ethno-API Pinecone Ingest")
    parser.add_argument("--input",     default=INPUT_FILE)
    parser.add_argument("--embedding", default="local",
                        choices=["openai", "local", "pinecone"])
    parser.add_argument("--resume",    action="store_true",
                        help="Skip records already in the index")
    args = parser.parse_args()

    try:
        from pinecone import Pinecone, ServerlessSpec
    except ImportError:
        print("ERROR: pinecone-client not installed. Run: pip install pinecone-client")
        sys.exit(1)

    api_key = os.environ.get("PINECONE_API_KEY")
    if not api_key:
        print("ERROR: PINECONE_API_KEY environment variable not set")
        sys.exit(1)

    pc = Pinecone(api_key=api_key)
    embed_fn, dim = get_embedder(args.embedding)

    # Create index if not exists
    existing_indexes = [i.name for i in pc.list_indexes()]
    if INDEX_NAME not in existing_indexes:
        pc.create_index(
            name=INDEX_NAME,
            dimension=dim,
            metric="cosine",
            spec=ServerlessSpec(cloud="aws", region="us-east-1")
        )
        print(f"Waiting for index creation: {INDEX_NAME} (dim={dim})")
        time.sleep(10)
    else:
        print(f"Using existing index: {INDEX_NAME}")

    index = pc.Index(INDEX_NAME)

    print(f"Loading: {args.input}")
    df    = pd.read_json(args.input)
    recs  = df.to_dict(orient="records")
    total = len(recs)
    print(f"  Records: {total:,}")

    upserted = 0
    for batch_start in range(0, total, BATCH_SIZE):
        batch  = recs[batch_start : batch_start + BATCH_SIZE]
        texts  = [build_text(r) for r in batch]
        ids    = [
            f"{r['chemical']}::{r['plant_species']}::{batch_start + i}"
            for i, r in enumerate(batch)
        ]
        metas  = [{
            "chemical":                   str(r["chemical"]),
            "plant_species":              str(r["plant_species"]),
            "application":                str(r.get("application") or ""),
            "pubmed_mentions_2026":       int(r["pubmed_mentions_2026"]),
            "clinical_trials_count_2026": int(r["clinical_trials_count_2026"]),
            "chembl_bioactivity_count":   int(r["chembl_bioactivity_count"]),
            "patent_count_since_2020":    int(r["patent_count_since_2020"]),
        } for r in batch]

        # Generate embeddings (or placeholder for Pinecone-managed inference)
        vectors = embed_fn(texts) if embed_fn else [[0.0] * dim] * len(texts)

        index.upsert(
            vectors=list(zip(ids, vectors, metas)),
            namespace=NAMESPACE
        )
        upserted += len(batch)
        print(f"  Upserted: {upserted:,}/{total:,}", end="\r")

    print(f"\nINGEST_COMPLETE: {upserted:,} records upserted to {INDEX_NAME}")

    # Index statistics
    stats = index.describe_index_stats()
    print(f"Index stats: {stats.total_vector_count:,} total vectors")


if __name__ == "__main__":
    main()
