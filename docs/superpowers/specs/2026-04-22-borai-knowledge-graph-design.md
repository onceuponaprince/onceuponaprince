---
title: "BorAI Knowledge Graph — Indexer + Retrieval + CLI Dashboard"
date: 2026-04-22
status: approved
scope: borai-infrastructure
target_repo: "~/code/BorAI"
target_path: "ops/borai-graph/"
---

# BorAI Knowledge Graph — Indexer + Retrieval + CLI Dashboard

## Context

BorAI is an agent delegation ecosystem. Multiple agents (`funding_tracker`, `build_in_public_engine`, `delegate_agent`, `hackathon_radar`) need contextual knowledge at query time. Today that context is fetched ad-hoc — each agent reads files directly, with no shared index and no cross-document awareness.

This spec defines a lightweight knowledge graph + RAG system that indexes BorAI's content surfaces (skills, transcripts, products, funding, posts, code), surfaces semantic similarity and typed edges between them, and answers retrieval queries from agents within a token budget.

The system is invisible to agents at query time (they call `retrieval.engine.query(...)` — nothing about the graph leaks into prompts) and runs as a background process that re-indexes on file changes.

## Goals

- Local-only embedding (nomic-embed-text via Ollama) — no external API cost on indexing.
- Hybrid edge detection — rules first, Haiku LLM assist only as fallback.
- File-watcher driven, hash-based dirty detection — no manual reindex.
- Agent-scoped retrieval — each agent sees edges relevant to its domain.
- CLI health dashboard — no web UI, no deployment surface.

## Non-goals

- External vector DB (no Neo4j, no Pinecone, no Qdrant).
- Web UI or HTTP service.
- Multi-tenant / multi-user support.
- Real-time streaming queries.
- Retrieval-quality evaluation harness (future concern once agent usage reveals gaps).

## Package location

`~/code/BorAI/ops/borai-graph/` — follows precedent set by `ops/ai-swarm-infra/` and `ops/borai-inbox/`. Python package root `borai/` inside honours the import paths in the brief (`from borai.retrieval.engine import ...`). `pyproject.toml` + `uv.lock` at `ops/borai-graph/`.

```
ops/borai-graph/
├── borai/
│   ├── __init__.py
│   ├── indexer/
│   │   ├── __init__.py
│   │   ├── watcher.py
│   │   ├── chunker.py
│   │   ├── embedder.py
│   │   ├── edge_detector.py
│   │   └── pipeline.py
│   ├── retrieval/
│   │   ├── __init__.py
│   │   └── engine.py
│   ├── dashboard/
│   │   ├── __init__.py
│   │   └── graph_stats.py
│   └── run.py
├── tests/
│   ├── test_chunker.py
│   ├── test_edge_detector.py
│   ├── test_embedder.py
│   ├── test_pipeline.py
│   ├── test_engine.py
│   └── fixtures/
├── pyproject.toml
├── uv.lock
├── .env.example
└── README.md
```

## Data layout

Runtime graph files in `$BORAI_GRAPH_DIR` (default `/borai/graph/`):

| File | Purpose |
|---|---|
| `graph.json` | Nodes (metadata only, no embeddings) + edges. Human-readable; diffable. |
| `vectors.npy` | numpy float32 matrix, shape `(N, embedding_dim)`. One row per node. |
| `vectors_index.json` | `{"row_to_node": [...node_ids...]}` — maps row index to node id. |
| `hash_registry.json` | `{"/path/to/file.md": "md5hash"}` — watcher's dirty detection. |

**Node schema:**

```json
{
  "id": "sha1(source_path + chunk_index)",
  "source_type": "skill | transcript | funding | code | product | post",
  "source_path": "/mnt/skills/funding-tracker/references/uk-grants.md",
  "chunk_index": 3,
  "content": "...chunk text...",
  "metadata": {
    "heading": "Innovate UK",
    "token_count": 287,
    "created_at": "2026-04-22T10:15:00Z"
  }
}
```

**Edge schema:**

```json
{
  "source": "node_id_1",
  "target": "node_id_2",
  "edge_type": "relates_to",
  "confidence": 0.82,
  "source_of_edge": "rule:same_product | llm:haiku"
}
```

## Chunking strategies

Implemented in `borai/indexer/chunker.py` with dispatch based on source type inferred from path.

| Source type | Path pattern | Strategy | Token cap |
|---|---|---|---|
| skill | `/mnt/skills/**/*.md` | Split on H2/H3 headings | 400 (recursive split on paragraphs/sentences if exceeded) |
| transcript | `/mnt/transcripts/**/*.{md,txt,json}` | One chunk per user+assistant exchange | N/A |
| funding | `/borai/funding/**/*.md` | Split on `---` delimiters | N/A |
| code | `/borai/code/**/*.py` | One chunk per function or class (AST-based) | N/A |
| product | `/borai/products/**/*.md` | H2/H3 heading split | 400 |
| post | `/borai/posts/**/*.md` | H2/H3 heading split | 400 |

**Oversized sections** (skill/product/post): recursive split — paragraphs first, then sentences. Never truncate content.

**Transcript format detection**: the chunker tries markdown (`## user` / `## assistant` alternation), JSON (`[{role, content}, ...]`), and plain-text (double-newline alternation) in order. Whole-file fallback if none recognised, with a WARN log.

## Edge detection

Two-stage hybrid. Stage 1 runs always; Stage 2 runs only when Stage 1 is sparse.

### Stage 1 — rule-based

Applied at pipeline time against the newly-indexed node's relationship to every existing node.

| Rule | Produces | Condition |
|---|---|---|
| same-product | `same_product` | Both nodes' paths contain the same product name from `/borai/products/` subdir names |
| authored-during | `authored_during` | Transcript `created_at` overlaps (±60 min) with post/code file mtime |
| depends-on | `depends_on` | Code chunk imports a symbol defined in another code chunk (AST parse) |
| follows | `follows` | Same directory, file mtime later by < 24h |
| precedes | `precedes` | Same directory, file mtime earlier by < 24h |
| relates-to | `relates_to` | Cosine similarity > 0.7 between chunk embeddings |

### Stage 2 — Haiku LLM assist

**Trigger**: Stage 1 produces fewer than 2 `relates_to` edges for the new node. Similarity floor 0.7 can miss semantic links that humans would make.

**Prompt shape**: given the new chunk and the top-10 nearest-neighbour chunks by similarity, return edges among `relates_to`, `contradicts`, `referenced_by` with brief justifications. Max 5 edges per call.

**Rate limiting**: cap at 100 Haiku calls per pipeline run (configurable via `BORAI_HAIKU_CALL_CAP`). Caller is `anthropic` SDK with existing API key. Model: `claude-haiku-4-5-20251001` per current family. Prompt caching enabled on the system prompt to reduce per-call cost.

### Edge types reference

All edges unidirectional (source → target) except `same_product` and `relates_to` which are symmetric (stored twice for query-time simplicity).

| Edge type | Produced by | Direction |
|---|---|---|
| `relates_to` | rule (similarity > 0.7) + Haiku | symmetric |
| `depends_on` | rule (code imports) | directed |
| `same_product` | rule (path match) | symmetric |
| `follows` | rule (mtime) | directed |
| `precedes` | rule (mtime) | directed |
| `authored_during` | rule (timestamp overlap) | directed (transcript → artifact) |
| `contradicts` | Haiku only | directed |
| `referenced_by` | Haiku only | directed |

## Retrieval engine

`borai/retrieval/engine.py` — single public function:

```python
def query(
    query_text: str,
    agent: str = "default",
    token_budget: int = 1500,
) -> list[RetrievalResult]:
    ...
```

Behaviour:

1. **Embed query** via local nomic-embed-text (Ollama).
2. **Cosine similarity** — numpy matrix multiply against `vectors.npy`, top 5 seed nodes with similarity ≥ 0.3 (floor; below that, drop).
3. **Graph traversal** — from seeds, depth-1 neighbours via edge types scoped per agent (below).
4. **Rank** — seeds by similarity; neighbours by `similarity × edge_confidence`.
5. **Prune to token budget** — default 1500 tokens (~4 chars/token ≈ 6000 chars). Drop lowest-ranked chunks until under budget.

Returns ordered list of `RetrievalResult(source_path, chunk_index, content, rank, reason)` where `reason` indicates `"seed:similarity=0.82"` or `"neighbour:relates_to via node_xyz"`.

## Agent edge scopes

```python
AGENT_EDGE_SCOPES = {
    "funding_tracker":        ["relates_to", "same_product"],
    "build_in_public_engine": ["authored_during", "same_product", "follows"],
    "delegate_agent":         ["depends_on", "relates_to"],
    "hackathon_radar":        ["relates_to", "precedes"],
}
```

Default (unknown agent): `["relates_to"]`.

## Concurrency model

**Atomic file swap.** Pipeline writes new state to `graph.json.tmp`, `vectors.npy.tmp`, `vectors_index.json.tmp`, then `os.rename()` to final names. Rename is atomic on POSIX; readers either see old state or new state, never partial.

**Retrieval loads fresh per query.** Reads graph.json + vectors.npy on every query call. At expected scale (≤ 10k nodes, ~50MB total) this is sub-100ms and avoids stale-cache concerns. Add a cached snapshot with explicit invalidation if scale exceeds comfortable load time; not first-version work.

**Watcher debounce.** File events batched over a 1s window; bulk changes (git checkout, bulk edit) process as one pipeline run.

## Configuration

All via environment variables. Production defaults assume mount layout; dev overrides freely.

```
BORAI_GRAPH_DIR         default: /borai/graph
BORAI_WATCH_PATHS       default: /mnt/skills:/mnt/transcripts:/borai/products:/borai/funding:/borai/posts:/borai/code
BORAI_OLLAMA_URL        default: http://localhost:11434
BORAI_EMBED_MODEL       default: nomic-embed-text
ANTHROPIC_API_KEY       required (existing in BorAI .env.local)
BORAI_LOG_LEVEL         default: INFO
BORAI_TOKEN_BUDGET      default: 1500
BORAI_SIMILARITY_FLOOR  default: 0.3
BORAI_HAIKU_CALL_CAP    default: 100
BORAI_DEBOUNCE_SECONDS  default: 1.0
```

Loaded via `python-dotenv` from `ops/borai-graph/.env` with override from process env.

## Error handling

- **Ollama unreachable** → pipeline skips the embedding step, logs ERROR, continues to next file-event cycle. Watcher does not crash. Retrieval returns empty with a warning if vectors.npy is empty.
- **Haiku rate limit / API error** → fall back to rule-based edges only; log WARN with counter. Pipeline does not block.
- **Chunker parse failure** → log WARN with file path; file is skipped (not marked clean in hash registry, so retried next cycle).
- **File disappears mid-pipeline** → caught, logged, node pruned from graph on next cycle.
- **Corrupt graph.json / vectors.npy** → run.py detects on startup (JSON parse, numpy load); logs ERROR and rebuilds from scratch by clearing hash_registry.

## Testing

Pytest, colocated in `ops/borai-graph/tests/`. Coverage priorities:

- **Chunker per source type** — fixtures for each, verify chunk boundaries and oversized-split behaviour.
- **Edge detector rules** — fixtures for `same_product`, `depends_on` (AST), `follows`/`precedes` (mtime), `relates_to` (similarity threshold).
- **Pipeline end-to-end** — given a fixture directory, run pipeline, assert graph.json shape.
- **Retrieval engine** — fixture graph, query returns expected top-k with correct edge scoping per agent.
- **Atomic swap** — kill pipeline mid-write (simulated), assert graph state is consistent on next read.

Run: `uv run pytest` from `ops/borai-graph/`.

Haiku calls stubbed via `anthropic` test client — tests never hit the real API. Ollama stubbed via local HTTP fixture.

## Dependencies

`pyproject.toml`:

```toml
[project]
name = "borai-graph"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "watchdog>=4.0",
    "numpy>=1.26",
    "requests>=2.31",
    "anthropic>=0.40",
    "python-dotenv>=1.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0",
    "pytest-cov>=5.0",
]

[project.scripts]
borai-graph = "borai.run:main"
borai-graph-stats = "borai.dashboard.graph_stats:main"
```

Installed via `uv sync` from `ops/borai-graph/`.

## Dashboard (Option A — CLI)

`borai/dashboard/graph_stats.py` exposes a `main()` entrypoint invokable via the `borai-graph-stats` script. Two output modes:

- **Default (human-readable)** — pretty-printed table of node counts, edge counts, last-indexed timestamp, dirty file count, Ollama/Haiku health.
- **`--json`** — machine-readable JSON for subprocess consumption (Yuri agent, shell pipelines).

Example human output:

```
$ uv run borai-graph-stats
NODES        TOTAL           12,483
             by source       skill: 1,204 | transcript: 8,120 | funding: 450 | code: 2,400 | product: 180 | post: 129
EDGES        TOTAL           43,891
             by type         relates_to: 18,200 | same_product: 4,500 | depends_on: 3,800 | ...
INDEX        last updated    2026-04-22 10:15:23 UTC
             dirty files     0
             pending         0
HEALTH       ollama          reachable
             haiku quota     87 / 100 calls used this hour
```

Yuri's dashboard (whenever it exists) invokes `borai-graph-stats --json` via subprocess and parses. No HTTP surface, no web UI to deploy.

## Setup (README contents)

```markdown
# BorAI Knowledge Graph

## One-time setup

1. Install Ollama:
   curl -fsSL https://ollama.com/install.sh | sh

2. Pull embedding model:
   ollama pull nomic-embed-text

3. Install package:
   cd ops/borai-graph
   uv sync

4. Configure env:
   cp .env.example .env
   # fill ANTHROPIC_API_KEY (shares BorAI's existing key)

## Running

Foreground (dev):
   uv run borai-graph

Background (prod):
   nohup uv run borai-graph > /borai/graph/logs/run.log 2>&1 &

Health check:
   uv run borai-graph-stats
   uv run borai-graph-stats --json | jq
```

## First-time indexing

On first run, hash_registry.json is empty; every file under watch paths is treated as dirty. Pipeline batches by source type, logs progress every 100 chunks. Expected duration for a cold BorAI vault: minutes to low tens of minutes (depending on Ollama throughput). Subsequent runs are incremental via hash comparison.

## Implementation order (recommended)

1. **Scaffold** — directory structure, pyproject.toml, tests skeleton, .env.example.
2. **pipeline.py** — the orchestrator. Stub every module it touches; write end-to-end with fake data flowing through. This establishes the data contracts before individual modules are real.
3. **chunker.py** — source-aware, per-source-type dispatch. Fixtures for each type.
4. **embedder.py** — Ollama HTTP client. Graceful on connection errors.
5. **edge_detector.py** — rule-based Stage 1 first; Haiku Stage 2 second. Rules unit-tested individually.
6. **watcher.py** — watchdog observer + hash registry + debounce queue. Daemon thread orchestration.
7. **retrieval/engine.py** — query → embed → similarity → traverse → prune.
8. **dashboard/graph_stats.py** — read graph.json + vectors.npy, print stats.
9. **run.py** — wire all together; CLI entrypoint.
10. **README + .env.example** — setup instructions per above.

Writing-plans phase turns this into a checkpointed plan with verification gates between each step.
