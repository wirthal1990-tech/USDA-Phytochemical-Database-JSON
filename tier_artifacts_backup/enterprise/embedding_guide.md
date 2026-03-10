# Ethno-API v2.0 — Embedding & RAG Integration Guide

## Overview

This guide explains how to embed the Ethno-API dataset into vector databases
for use in RAG (Retrieval-Augmented Generation) pipelines. The dataset's 4
enrichment layers make each record a high-signal embedding candidate.

---

## Recommended Embedding Models

| Model | Dimensions | Cost | Best For |
|-------|-----------|------|----------|
| `text-embedding-3-small` (OpenAI) | 1,536 | ~$0.02/1M tokens | Production RAG, best recall |
| `all-MiniLM-L6-v2` (sentence-transformers) | 384 | Free (local) | Dev/testing, no API cost |
| `BiomedBERT-base` (Hugging Face) | 768 | Free (local) | Biomedical domain-specific |
| `ClinicalBERT` (Hugging Face) | 768 | Free (local) | Clinical text, highest relevance |
| Pinecone `multilingual-e5-large` | 1,024 | Managed | Pinecone-native inference |

**Recommendation for production:** `text-embedding-3-small` (best price/performance)
**Recommendation for biomedical accuracy:** `ClinicalBERT` or `BiomedBERT`

---

## Document Text Construction

Each record is converted to a structured text string before embedding:

```python
def build_text(row):
    return (
        f"Compound: {row['chemical']} | "
        f"Plant: {row['plant_species']} | "
        f"Application: {row.get('application', 'unspecified')} | "
        f"PubMed mentions 2026: {row['pubmed_mentions_2026']} | "
        f"Clinical trials: {row['clinical_trials_count_2026']} | "
        f"ChEMBL bioassays: {row['chembl_bioactivity_count']} | "
        f"Patents since 2020: {row['patent_count_since_2020']}"
    )
```

**Why this structure?**
- Prefix labels (`Compound:`, `Plant:`) improve retrieval for natural language queries
- Numeric evidence scores are included for hybrid search relevance
- Structured format enables consistent chunking (1 record = 1 document)

---

## Chunking Strategy

| Strategy | Records/Chunk | Token Count | Recommendation |
|----------|:------------:|:-----------:|:---------------|
| **1 record = 1 document** | 1 | ~40–80 tokens | **Recommended** — maximum granularity |
| Multi-record grouping (by compound) | 5–50 | 200–4,000 tokens | Good for compound-level RAG |
| Full species document | 10–100 | 500–8,000 tokens | Use for species-focused queries |

**Recommended: 1 record = 1 document.** This gives the finest-grained retrieval and
works best with typical RAG top-k settings (5–20 results).

---

## Metadata Filtering

Both ChromaDB and Pinecone support metadata filtering at query time:

### ChromaDB

```python
results = collection.query(
    query_texts=["anti-inflammatory flavonoid"],
    n_results=10,
    where={
        "$and": [
            {"pubmed_mentions_2026": {"$gt": 1000}},
            {"clinical_trials_count_2026": {"$gt": 10}}
        ]
    }
)
```

### Pinecone

```python
results = index.query(
    vector=embedding,
    top_k=10,
    filter={
        "pubmed_mentions_2026": {"$gt": 1000},
        "clinical_trials_count_2026": {"$gt": 10}
    },
    include_metadata=True,
    namespace="ethno_api"
)
```

---

## Cost Estimation

### Embedding Costs (OpenAI text-embedding-3-small)

| Dataset Size | Token Estimate | Cost |
|:------------|:--------------|:-----|
| Sample (400 records) | ~24,000 tokens | < $0.01 |
| Full (104,388 records) | ~6.3M tokens | ~$0.13 |

### Vector DB Hosting Costs

| Provider | Free Tier | Production Tier |
|:---------|:----------|:----------------|
| ChromaDB (self-hosted) | Free forever | Free (runs locally) |
| Pinecone (Starter) | 100K vectors free | $70/mo (5M vectors) |
| Pinecone (Standard) | — | $0.096/GB-hr |

---

## Quickstart: 5-Minute RAG Pipeline

```python
# 1. Ingest (run once)
# python3 chromadb_ingest.py --input ethno_dataset_2026_v2.json

# 2. Query in your RAG application
import chromadb

client = chromadb.PersistentClient(path="./chroma_ethno_db")
collection = client.get_collection("ethno_phytochemical_v2")

# Semantic search
results = collection.query(
    query_texts=["What compounds have anti-cancer properties with strong clinical trial evidence?"],
    n_results=10,
    include=["documents", "metadatas", "distances"]
)

# Use in LLM prompt
context = "\n".join(results["documents"][0])
prompt = f"""Based on the following phytochemical research data:

{context}

Answer the user's question: What are the most promising anti-cancer compounds?"""
```

---

## Advanced: Hybrid Search with Evidence Scoring

Combine vector similarity with evidence-based re-ranking:

```python
def hybrid_search(query: str, collection, top_k=20, rerank_top=5):
    """Retrieve by semantic similarity, then re-rank by composite evidence score."""
    results = collection.query(
        query_texts=[query],
        n_results=top_k,
        include=["metadatas", "documents", "distances"]
    )

    # Re-rank by composite evidence score
    scored = []
    for meta, doc, dist in zip(
        results["metadatas"][0],
        results["documents"][0],
        results["distances"][0]
    ):
        evidence_score = (
            meta["pubmed_mentions_2026"] * 0.30 +
            meta["clinical_trials_count_2026"] * 0.35 +
            meta["chembl_bioactivity_count"] * 0.20 +
            meta["patent_count_since_2020"] * 0.15
        )
        # Combine semantic similarity (1 - distance) with evidence score
        final_score = (1 - dist) * 0.5 + min(evidence_score / 10000, 1.0) * 0.5
        scored.append((final_score, meta, doc))

    scored.sort(key=lambda x: x[0], reverse=True)
    return scored[:rerank_top]
```

---

## Switching from Sample to Full Dataset

All scripts use an `INPUT_FILE` variable at the top:

```python
# Current (sample):
INPUT_FILE = "ethno_sample_400.json"

# After enrichment completion, change to:
INPUT_FILE = "ethno_dataset_2026_v2.json"
```

No other changes are required. The ingest scripts will automatically process
all 104,388 records.

---

## Troubleshooting

| Issue | Solution |
|:------|:---------|
| `chromadb not installed` | `pip install chromadb` |
| `pinecone-client not installed` | `pip install pinecone-client` |
| ChromaDB OOM on full dataset | Set `BATCH_SIZE = 50` and use `--resume` flag |
| Pinecone rate limit | Reduce `BATCH_SIZE` to 50, add `time.sleep(0.5)` between batches |
| OpenAI API timeout | Use `--embedding local` for free local embeddings |
| Resume after interruption | Run with `--resume` flag to skip already-ingested records |

---

## File Reference

| File | Description | Tier |
|:-----|:------------|:-----|
| `chromadb_ingest.py` | ChromaDB local vector DB ingest | Enterprise |
| `pinecone_ingest.py` | Pinecone cloud vector DB ingest | Enterprise |
| `embedding_guide.md` | This guide | Enterprise |
| `duckdb_queries.sql` | 20 DuckDB analytics queries | Team + Enterprise |
| `snowflake_load.sql` | Snowflake import script | Enterprise |
