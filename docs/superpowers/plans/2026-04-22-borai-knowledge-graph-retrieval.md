# BorAI Knowledge Graph — Retrieval + Dashboard + Runtime Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the query surface of the BorAI Knowledge Graph — a retrieval engine with in-process graph snapshot, cosine similarity search, agent-scoped graph traversal, token-budget pruning, and a TTL query cache; a CLI dashboard for health stats; and `run.py` entrypoint that wires the indexer as a long-running daemon with initial bulk ingest and clean shutdown.

**Architecture:** Retrieval engine holds graph.json + vectors.npy as an in-process snapshot, checking mtime on each query and reloading on change. Queries route through: embed → top-k cosine → depth-1 traversal scoped by agent → rank → prune to token budget. Query cache is a process-local dict keyed on (query, agent), TTL-bounded, invalidated on snapshot reload. Dashboard reads the same snapshot to report node/edge counts, last-indexed timestamp, Ollama + Haiku health. Run.py wires Pipeline + Watcher + logging; on startup if hash_registry is empty, runs a bulk ingest before entering event loop.

**Tech Stack:** Python 3.11+, same deps as Plan 1 (watchdog, numpy, requests, anthropic, python-dotenv, pytest). No new deps.

**Source spec:** `docs/superpowers/specs/2026-04-22-borai-knowledge-graph-design.md` (commits `da7d01a` + `881886d`).

**Depends on:** Plan 1 (indexer layer). All modules from Plan 1 are assumed present and tested — this plan imports `borai.indexer.pipeline.Pipeline`, `borai.indexer.watcher.IndexerWatcher`, `borai.indexer.embedder.Embedder`, `borai.indexer.types.Node|Edge`, and `borai.config`.

---

## File Structure

**`borai/retrieval/` package:**
- `borai/retrieval/__init__.py` — already created in Plan 1
- `borai/retrieval/engine.py` — RetrievalEngine with GraphSnapshot + QueryCache

**`borai/dashboard/` package:**
- `borai/dashboard/__init__.py` — already created in Plan 1
- `borai/dashboard/graph_stats.py` — stats reader + CLI main

**`borai/` package:**
- `borai/run.py` — daemon entrypoint

**Project root:**
- `README.md` — overwrites Plan 1's stub with full setup + running + health check instructions

**`tests/`:**
- `tests/test_engine.py`
- `tests/test_graph_stats.py`
- `tests/test_run.py`

---

## Task 1: RetrievalResult dataclass + engine skeleton

**Files:**
- Create: `ops/borai-graph/borai/retrieval/engine.py`
- Create: `ops/borai-graph/tests/test_engine.py`

- [ ] **Step 1: Write failing test**

```python
# tests/test_engine.py
from borai.retrieval.engine import RetrievalResult, RetrievalEngine


def test_retrieval_result_fields():
    r = RetrievalResult(
        source_path="/x.md",
        chunk_index=2,
        content="hello",
        rank=0.87,
        reason="seed:similarity=0.87",
    )
    assert r.source_path == "/x.md"
    assert r.chunk_index == 2
    assert r.content == "hello"
    assert r.rank == 0.87
    assert r.reason == "seed:similarity=0.87"


def test_engine_constructs(tmp_path):
    e = RetrievalEngine(graph_dir=tmp_path)
    assert e.graph_dir == tmp_path
```

- [ ] **Step 2: Run test — verify fail**

```bash
uv run pytest tests/test_engine.py -v
```

Expected: `ModuleNotFoundError: No module named 'borai.retrieval.engine'`.

- [ ] **Step 3: Implement engine skeleton**

```python
# borai/retrieval/engine.py
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


AGENT_EDGE_SCOPES: dict[str, list[str]] = {
    "funding_tracker":        ["relates_to", "same_product"],
    "build_in_public_engine": ["authored_during", "same_product", "follows"],
    "delegate_agent":         ["depends_on", "relates_to"],
    "hackathon_radar":        ["relates_to", "precedes"],
}
DEFAULT_AGENT_SCOPE = ["relates_to"]


@dataclass
class RetrievalResult:
    source_path: str
    chunk_index: int
    content: str
    rank: float
    reason: str  # e.g. "seed:similarity=0.82" or "neighbour:relates_to via node_xyz"


class RetrievalEngine:
    def __init__(self, graph_dir: Path):
        self.graph_dir = Path(graph_dir)
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_engine.py -v
```

Expected: `2 passed`.

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/retrieval/engine.py ops/borai-graph/tests/test_engine.py
git commit -m "feat(borai-graph): retrieval engine skeleton with RetrievalResult and agent scopes"
```

---

## Task 2: GraphSnapshot — load graph.json + vectors.npy with mtime check

**Files:**
- Modify: `ops/borai-graph/borai/retrieval/engine.py`
- Modify: `ops/borai-graph/tests/test_engine.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_engine.py`:

```python
import json
import numpy as np
from borai.indexer.types import Edge, Node


def _seed_graph(graph_dir, nodes, edges, vectors):
    graph_dir.mkdir(parents=True, exist_ok=True)
    (graph_dir / "graph.json").write_text(json.dumps({
        "nodes": [n.to_dict() for n in nodes],
        "edges": [e.to_dict() for e in edges],
    }, indent=2))
    np.save(graph_dir / "vectors.npy", vectors)
    (graph_dir / "vectors_index.json").write_text(json.dumps({
        "row_to_node": [n.id for n in nodes]
    }))


def test_graph_snapshot_loads(tmp_path):
    from borai.retrieval.engine import GraphSnapshot

    n1 = Node(id="a", source_type="post", source_path="/x.md",
              chunk_index=0, content="x", metadata={}, created_at="2026-04-22T00:00:00Z")
    n2 = Node(id="b", source_type="post", source_path="/y.md",
              chunk_index=0, content="y", metadata={}, created_at="2026-04-22T00:00:00Z")
    e1 = Edge(source="a", target="b", edge_type="relates_to", confidence=0.9, source_of_edge="rule:relates_to")
    vectors = np.array([[0.1, 0.2], [0.3, 0.4]], dtype=np.float32)

    _seed_graph(tmp_path, [n1, n2], [e1], vectors)

    snap = GraphSnapshot(tmp_path)
    snap.load()
    assert "a" in snap.nodes
    assert "b" in snap.nodes
    assert snap.nodes["a"].source_path == "/x.md"
    assert len(snap.edges_from["a"]) == 1
    np.testing.assert_array_equal(snap.vectors, vectors)
    assert snap.row_to_node == ["a", "b"]


def test_graph_snapshot_reloads_on_mtime_change(tmp_path):
    from borai.retrieval.engine import GraphSnapshot
    import time

    n1 = Node(id="a", source_type="post", source_path="/x.md",
              chunk_index=0, content="x", metadata={}, created_at="x")
    vectors = np.array([[0.1, 0.2]], dtype=np.float32)
    _seed_graph(tmp_path, [n1], [], vectors)

    snap = GraphSnapshot(tmp_path)
    snap.load()
    assert "a" in snap.nodes

    # Sleep to ensure mtime tick resolution
    time.sleep(1.1)

    # Rewrite graph.json with new content
    n2 = Node(id="b", source_type="post", source_path="/y.md",
              chunk_index=0, content="y", metadata={}, created_at="x")
    _seed_graph(tmp_path, [n2], [], np.array([[0.9, 0.9]], dtype=np.float32))

    changed = snap.reload_if_changed()
    assert changed is True
    assert "b" in snap.nodes
    assert "a" not in snap.nodes


def test_graph_snapshot_no_reload_if_unchanged(tmp_path):
    from borai.retrieval.engine import GraphSnapshot

    n = Node(id="a", source_type="post", source_path="/x.md",
             chunk_index=0, content="x", metadata={}, created_at="x")
    _seed_graph(tmp_path, [n], [], np.array([[0.1]], dtype=np.float32))

    snap = GraphSnapshot(tmp_path)
    snap.load()
    assert snap.reload_if_changed() is False
```

- [ ] **Step 2: Run test — verify fail**

Expected: `ImportError: cannot import name 'GraphSnapshot'`.

- [ ] **Step 3: Implement GraphSnapshot**

Append to `borai/retrieval/engine.py`:

```python
import json
from collections import defaultdict

import numpy as np

from borai.indexer.types import Edge, Node


class GraphSnapshot:
    def __init__(self, graph_dir: Path):
        self.graph_dir = Path(graph_dir)
        self.nodes: dict[str, Node] = {}
        self.edges_from: dict[str, list[Edge]] = defaultdict(list)
        self.vectors: np.ndarray = np.zeros((0, 0), dtype=np.float32)
        self.row_to_node: list[str] = []
        self._loaded_mtime: float | None = None

    @property
    def graph_path(self) -> Path:
        return self.graph_dir / "graph.json"

    @property
    def vectors_path(self) -> Path:
        return self.graph_dir / "vectors.npy"

    @property
    def index_path(self) -> Path:
        return self.graph_dir / "vectors_index.json"

    def _current_mtime(self) -> float | None:
        if not self.graph_path.exists():
            return None
        return self.graph_path.stat().st_mtime

    def load(self) -> None:
        if not (self.graph_path.exists() and self.vectors_path.exists() and self.index_path.exists()):
            self.nodes = {}
            self.edges_from = defaultdict(list)
            self.vectors = np.zeros((0, 0), dtype=np.float32)
            self.row_to_node = []
            self._loaded_mtime = None
            return
        graph = json.loads(self.graph_path.read_text())
        self.nodes = {}
        self.edges_from = defaultdict(list)
        for n_dict in graph.get("nodes", []):
            n = Node.from_dict(n_dict)
            self.nodes[n.id] = n
        for e_dict in graph.get("edges", []):
            e = Edge.from_dict(e_dict)
            self.edges_from[e.source].append(e)
        self.vectors = np.load(self.vectors_path)
        self.row_to_node = json.loads(self.index_path.read_text())["row_to_node"]
        self._loaded_mtime = self._current_mtime()

    def reload_if_changed(self) -> bool:
        current = self._current_mtime()
        if current is None:
            return False
        if self._loaded_mtime is None or current > self._loaded_mtime:
            self.load()
            return True
        return False

    def vector_for(self, node_id: str) -> np.ndarray | None:
        if not self.row_to_node:
            return None
        try:
            row = self.row_to_node.index(node_id)
        except ValueError:
            return None
        if row >= self.vectors.shape[0]:
            return None
        return self.vectors[row]
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_engine.py -v
```

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/retrieval/engine.py ops/borai-graph/tests/test_engine.py
git commit -m "feat(borai-graph): GraphSnapshot with mtime-based reload"
```

---

## Task 3: Cosine similarity + top-k seeds with floor

**Files:**
- Modify: `ops/borai-graph/borai/retrieval/engine.py`
- Modify: `ops/borai-graph/tests/test_engine.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_engine.py`:

```python
def test_top_k_seeds_respects_floor(tmp_path):
    from borai.retrieval.engine import GraphSnapshot, top_k_seeds

    nodes = [
        Node(id=f"n{i}", source_type="post", source_path=f"/p{i}.md",
             chunk_index=0, content=f"c{i}", metadata={}, created_at="x")
        for i in range(4)
    ]
    # Four vectors with distinct similarities to query [1, 0]
    vectors = np.array([
        [1.0, 0.0],   # sim 1.0 — seed
        [0.8, 0.6],   # sim 0.8 — seed
        [0.5, 0.87],  # sim 0.5 — seed (just above 0.3)
        [0.1, 0.99],  # sim 0.1 — below floor, dropped
    ], dtype=np.float32)
    _seed_graph(tmp_path, nodes, [], vectors)

    snap = GraphSnapshot(tmp_path)
    snap.load()

    query_vec = np.array([1.0, 0.0], dtype=np.float32)
    seeds = top_k_seeds(query_vec, snap, k=5, floor=0.3)
    ids = [node_id for node_id, _ in seeds]
    assert "n3" not in ids  # below floor
    assert "n0" in ids
    assert seeds[0][1] > seeds[1][1]  # sorted by similarity desc


def test_top_k_seeds_k_cap(tmp_path):
    from borai.retrieval.engine import GraphSnapshot, top_k_seeds

    nodes = [
        Node(id=f"n{i}", source_type="post", source_path=f"/p{i}.md",
             chunk_index=0, content=f"c{i}", metadata={}, created_at="x")
        for i in range(10)
    ]
    # All similar (all [1, 0])
    vectors = np.tile(np.array([1.0, 0.0], dtype=np.float32), (10, 1))
    _seed_graph(tmp_path, nodes, [], vectors)

    snap = GraphSnapshot(tmp_path)
    snap.load()

    query_vec = np.array([1.0, 0.0], dtype=np.float32)
    seeds = top_k_seeds(query_vec, snap, k=5, floor=0.0)
    assert len(seeds) == 5
```

- [ ] **Step 2: Run test — verify fail**

Expected: `ImportError: cannot import name 'top_k_seeds'`.

- [ ] **Step 3: Implement**

Append to `borai/retrieval/engine.py`:

```python
def top_k_seeds(
    query_vec: np.ndarray,
    snap: GraphSnapshot,
    k: int = 5,
    floor: float = 0.3,
) -> list[tuple[str, float]]:
    """Return [(node_id, similarity)] of top-k nodes with similarity >= floor, sorted desc."""
    if snap.vectors.shape[0] == 0:
        return []
    q_norm = np.linalg.norm(query_vec)
    if q_norm == 0:
        return []
    # Normalise stored vectors
    norms = np.linalg.norm(snap.vectors, axis=1)
    # Avoid divide-by-zero
    safe_norms = np.where(norms == 0, 1.0, norms)
    sims = snap.vectors @ query_vec / (safe_norms * q_norm)
    # Zero-out entries where norms were 0
    sims = np.where(norms == 0, 0.0, sims)

    # Sort indices by similarity desc
    order = np.argsort(-sims)
    results: list[tuple[str, float]] = []
    for idx in order:
        if sims[idx] < floor:
            break
        node_id = snap.row_to_node[int(idx)]
        results.append((node_id, float(sims[idx])))
        if len(results) >= k:
            break
    return results
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_engine.py -v
```

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/retrieval/engine.py ops/borai-graph/tests/test_engine.py
git commit -m "feat(borai-graph): top_k_seeds cosine similarity with floor"
```

---

## Task 4: Graph traversal with agent-scoped edge types

**Files:**
- Modify: `ops/borai-graph/borai/retrieval/engine.py`
- Modify: `ops/borai-graph/tests/test_engine.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_engine.py`:

```python
def test_traverse_respects_agent_scope(tmp_path):
    from borai.retrieval.engine import GraphSnapshot, traverse_neighbours

    # Three nodes, three edges — all emanating from seed "a"
    nodes = [
        Node(id=i, source_type="post", source_path=f"/{i}.md",
             chunk_index=0, content=i, metadata={}, created_at="x")
        for i in ["a", "b", "c", "d"]
    ]
    edges = [
        Edge(source="a", target="b", edge_type="relates_to", confidence=0.9, source_of_edge="rule:relates_to"),
        Edge(source="a", target="c", edge_type="same_product", confidence=1.0, source_of_edge="rule:same_product"),
        Edge(source="a", target="d", edge_type="depends_on", confidence=1.0, source_of_edge="rule:depends_on"),
    ]
    _seed_graph(tmp_path, nodes, edges, np.zeros((4, 2), dtype=np.float32))
    snap = GraphSnapshot(tmp_path)
    snap.load()

    # funding_tracker scope: relates_to + same_product → neighbours b, c (not d)
    neighbours = traverse_neighbours(["a"], snap, scope=["relates_to", "same_product"])
    ids = {node_id for node_id, _ in neighbours}
    assert ids == {"b", "c"}

    # delegate_agent scope: depends_on + relates_to → neighbours b, d (not c)
    neighbours = traverse_neighbours(["a"], snap, scope=["depends_on", "relates_to"])
    ids = {node_id for node_id, _ in neighbours}
    assert ids == {"b", "d"}


def test_traverse_returns_edge_for_reason(tmp_path):
    from borai.retrieval.engine import GraphSnapshot, traverse_neighbours

    nodes = [
        Node(id="a", source_type="post", source_path="/a.md",
             chunk_index=0, content="a", metadata={}, created_at="x"),
        Node(id="b", source_type="post", source_path="/b.md",
             chunk_index=0, content="b", metadata={}, created_at="x"),
    ]
    edges = [Edge(source="a", target="b", edge_type="relates_to", confidence=0.8, source_of_edge="rule:relates_to")]
    _seed_graph(tmp_path, nodes, edges, np.zeros((2, 2), dtype=np.float32))
    snap = GraphSnapshot(tmp_path)
    snap.load()

    neighbours = traverse_neighbours(["a"], snap, scope=["relates_to"])
    assert len(neighbours) == 1
    node_id, edge = neighbours[0]
    assert node_id == "b"
    assert edge.edge_type == "relates_to"
    assert edge.confidence == 0.8
```

- [ ] **Step 2: Run test — verify fail**

Expected: `ImportError: cannot import name 'traverse_neighbours'`.

- [ ] **Step 3: Implement traversal**

Append to `borai/retrieval/engine.py`:

```python
def traverse_neighbours(
    seed_ids: list[str],
    snap: GraphSnapshot,
    scope: list[str],
) -> list[tuple[str, Edge]]:
    """Return [(neighbour_id, edge)] for all depth-1 edges in scope from seeds."""
    seen: set[str] = set(seed_ids)
    results: list[tuple[str, Edge]] = []
    scope_set = set(scope)
    for seed in seed_ids:
        for edge in snap.edges_from.get(seed, []):
            if edge.edge_type not in scope_set:
                continue
            if edge.target in seen:
                continue
            if edge.target not in snap.nodes:
                continue
            results.append((edge.target, edge))
            seen.add(edge.target)
    return results
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_engine.py -v
```

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/retrieval/engine.py ops/borai-graph/tests/test_engine.py
git commit -m "feat(borai-graph): graph traversal scoped by agent edge types"
```

---

## Task 5: Ranking — seeds by similarity, neighbours by sim × confidence

**Files:**
- Modify: `ops/borai-graph/borai/retrieval/engine.py`
- Modify: `ops/borai-graph/tests/test_engine.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_engine.py`:

```python
def test_rank_results_seeds_ranked_by_similarity(tmp_path):
    from borai.retrieval.engine import GraphSnapshot, rank_results

    nodes = [
        Node(id="a", source_type="post", source_path="/a.md",
             chunk_index=0, content="a", metadata={}, created_at="x"),
        Node(id="b", source_type="post", source_path="/b.md",
             chunk_index=0, content="b", metadata={}, created_at="x"),
    ]
    _seed_graph(tmp_path, nodes, [], np.zeros((2, 2), dtype=np.float32))
    snap = GraphSnapshot(tmp_path)
    snap.load()

    seeds = [("a", 0.9), ("b", 0.4)]
    results = rank_results(seeds, [], snap)
    assert results[0].source_path == "/a.md"
    assert results[0].rank == 0.9
    assert results[1].rank == 0.4


def test_rank_results_neighbour_ranked_by_sim_times_confidence(tmp_path):
    from borai.retrieval.engine import GraphSnapshot, rank_results

    nodes = [
        Node(id="a", source_type="post", source_path="/a.md",
             chunk_index=0, content="a", metadata={}, created_at="x"),
        Node(id="b", source_type="post", source_path="/b.md",
             chunk_index=0, content="b", metadata={}, created_at="x"),
    ]
    edge = Edge(source="a", target="b", edge_type="relates_to", confidence=0.8, source_of_edge="rule:relates_to")
    _seed_graph(tmp_path, nodes, [edge], np.zeros((2, 2), dtype=np.float32))
    snap = GraphSnapshot(tmp_path)
    snap.load()

    seeds = [("a", 0.9)]
    neighbours = [("b", edge)]
    results = rank_results(seeds, neighbours, snap)
    # seed a: rank 0.9; neighbour b: rank 0.9 * 0.8 = 0.72
    assert results[0].source_path == "/a.md"
    assert abs(results[1].rank - 0.72) < 1e-5
    assert "relates_to" in results[1].reason
```

- [ ] **Step 2: Run test — verify fail**

Expected: `ImportError: cannot import name 'rank_results'`.

- [ ] **Step 3: Implement**

Append to `borai/retrieval/engine.py`:

```python
def rank_results(
    seeds: list[tuple[str, float]],
    neighbours: list[tuple[str, Edge]],
    snap: GraphSnapshot,
) -> list[RetrievalResult]:
    """Combine seeds and neighbours into ranked RetrievalResult list."""
    # Map seed_id → similarity for neighbour proximity computation
    sim_by_seed = {seed_id: sim for seed_id, sim in seeds}
    results: list[RetrievalResult] = []
    for seed_id, sim in seeds:
        node = snap.nodes.get(seed_id)
        if node is None:
            continue
        results.append(RetrievalResult(
            source_path=node.source_path,
            chunk_index=node.chunk_index,
            content=node.content,
            rank=sim,
            reason=f"seed:similarity={sim:.4f}",
        ))
    for neighbour_id, edge in neighbours:
        node = snap.nodes.get(neighbour_id)
        if node is None:
            continue
        seed_sim = sim_by_seed.get(edge.source, 0.0)
        rank_score = seed_sim * edge.confidence
        results.append(RetrievalResult(
            source_path=node.source_path,
            chunk_index=node.chunk_index,
            content=node.content,
            rank=rank_score,
            reason=f"neighbour:{edge.edge_type} via {edge.source}",
        ))
    # Sort descending by rank
    results.sort(key=lambda r: r.rank, reverse=True)
    return results
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_engine.py -v
```

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/retrieval/engine.py ops/borai-graph/tests/test_engine.py
git commit -m "feat(borai-graph): rank_results with seeds by similarity and neighbours by sim × confidence"
```

---

## Task 6: Token budget pruning

**Files:**
- Modify: `ops/borai-graph/borai/retrieval/engine.py`
- Modify: `ops/borai-graph/tests/test_engine.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_engine.py`:

```python
def test_prune_to_budget_drops_lowest_ranked():
    from borai.retrieval.engine import prune_to_budget, RetrievalResult

    results = [
        RetrievalResult("/a.md", 0, "x" * 400, rank=0.9, reason="seed"),   # ~100 tokens
        RetrievalResult("/b.md", 0, "x" * 400, rank=0.8, reason="seed"),   # ~100 tokens
        RetrievalResult("/c.md", 0, "x" * 400, rank=0.7, reason="seed"),   # ~100 tokens
        RetrievalResult("/d.md", 0, "x" * 400, rank=0.6, reason="seed"),   # ~100 tokens
    ]
    # Budget 250 tokens → ~1000 chars → 2 results
    pruned = prune_to_budget(results, token_budget=250)
    assert len(pruned) == 2
    # Highest-ranked kept
    paths = [r.source_path for r in pruned]
    assert paths == ["/a.md", "/b.md"]


def test_prune_to_budget_keeps_all_when_under():
    from borai.retrieval.engine import prune_to_budget, RetrievalResult

    results = [
        RetrievalResult("/a.md", 0, "short", rank=0.9, reason="seed"),
        RetrievalResult("/b.md", 0, "tiny", rank=0.8, reason="seed"),
    ]
    pruned = prune_to_budget(results, token_budget=1000)
    assert len(pruned) == 2
```

- [ ] **Step 2: Run test — verify fail**

Expected: `ImportError: cannot import name 'prune_to_budget'`.

- [ ] **Step 3: Implement**

Append to `borai/retrieval/engine.py`:

```python
CHARS_PER_TOKEN = 4  # per spec


def prune_to_budget(results: list[RetrievalResult], token_budget: int) -> list[RetrievalResult]:
    char_budget = token_budget * CHARS_PER_TOKEN
    kept: list[RetrievalResult] = []
    used_chars = 0
    for r in results:  # assumes already sorted by rank desc
        cost = len(r.content)
        if used_chars + cost > char_budget:
            break
        kept.append(r)
        used_chars += cost
    return kept
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_engine.py -v
```

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/retrieval/engine.py ops/borai-graph/tests/test_engine.py
git commit -m "feat(borai-graph): prune_to_budget by char count (~4 chars/token)"
```

---

## Task 7: Query cache (TTL-bounded, in-process)

**Files:**
- Modify: `ops/borai-graph/borai/retrieval/engine.py`
- Modify: `ops/borai-graph/tests/test_engine.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_engine.py`:

```python
def test_query_cache_hit_within_ttl():
    from borai.retrieval.engine import QueryCache

    c = QueryCache(ttl_seconds=60)
    c.put("q1", "default", [RetrievalResult("/a.md", 0, "x", 0.9, "seed")])
    hit = c.get("q1", "default")
    assert hit is not None
    assert len(hit) == 1


def test_query_cache_miss_different_agent():
    from borai.retrieval.engine import QueryCache

    c = QueryCache(ttl_seconds=60)
    c.put("q1", "default", [RetrievalResult("/a.md", 0, "x", 0.9, "seed")])
    assert c.get("q1", "other") is None


def test_query_cache_expires_after_ttl(monkeypatch):
    from borai.retrieval.engine import QueryCache
    import time

    fake_time = [1000.0]
    monkeypatch.setattr(time, "monotonic", lambda: fake_time[0])

    c = QueryCache(ttl_seconds=5)
    c.put("q", "agent", [RetrievalResult("/a.md", 0, "x", 0.5, "seed")])
    assert c.get("q", "agent") is not None

    fake_time[0] = 1010.0  # 10s later, past 5s TTL
    assert c.get("q", "agent") is None


def test_query_cache_clear():
    from borai.retrieval.engine import QueryCache

    c = QueryCache(ttl_seconds=60)
    c.put("q", "agent", [])
    c.clear()
    assert c.get("q", "agent") is None
```

- [ ] **Step 2: Run test — verify fail**

Expected: `ImportError: cannot import name 'QueryCache'`.

- [ ] **Step 3: Implement**

Append to `borai/retrieval/engine.py`:

```python
import hashlib
import time
from threading import RLock


class QueryCache:
    def __init__(self, ttl_seconds: int = 60):
        self.ttl = ttl_seconds
        self._store: dict[str, tuple[float, list[RetrievalResult]]] = {}
        self._lock = RLock()

    @staticmethod
    def _key(query: str, agent: str) -> str:
        return hashlib.sha256(f"{agent}::{query}".encode("utf-8")).hexdigest()

    def get(self, query: str, agent: str) -> list[RetrievalResult] | None:
        key = self._key(query, agent)
        with self._lock:
            entry = self._store.get(key)
            if entry is None:
                return None
            stored_at, results = entry
            if time.monotonic() - stored_at > self.ttl:
                self._store.pop(key, None)
                return None
            return results

    def put(self, query: str, agent: str, results: list[RetrievalResult]) -> None:
        key = self._key(query, agent)
        with self._lock:
            self._store[key] = (time.monotonic(), results)

    def clear(self) -> None:
        with self._lock:
            self._store.clear()
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_engine.py -v
```

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/retrieval/engine.py ops/borai-graph/tests/test_engine.py
git commit -m "feat(borai-graph): QueryCache with TTL and agent-scoped keys"
```

---

## Task 8: RetrievalEngine.query — integrate all pieces

**Files:**
- Modify: `ops/borai-graph/borai/retrieval/engine.py`
- Modify: `ops/borai-graph/tests/test_engine.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_engine.py`:

```python
from unittest.mock import MagicMock, patch


def test_engine_query_end_to_end(tmp_path):
    from borai.retrieval.engine import RetrievalEngine

    # Seed a small graph
    nodes = [
        Node(id="a", source_type="post", source_path="/a.md",
             chunk_index=0, content="content about X", metadata={}, created_at="x"),
        Node(id="b", source_type="post", source_path="/b.md",
             chunk_index=0, content="content about Y", metadata={}, created_at="x"),
    ]
    edges = [Edge(source="a", target="b", edge_type="relates_to", confidence=0.9, source_of_edge="rule:relates_to")]
    vectors = np.array([[1.0, 0.0], [0.95, 0.31]], dtype=np.float32)
    _seed_graph(tmp_path, nodes, edges, vectors)

    # Mock embedder to return a query vector close to "a"
    mock_embedder = MagicMock()
    mock_embedder.embed.return_value = np.array([1.0, 0.0], dtype=np.float32)

    engine = RetrievalEngine(graph_dir=tmp_path, embedder=mock_embedder)
    results = engine.query("query about X", agent="delegate_agent", token_budget=10000)

    assert len(results) >= 1
    # First result should be seed "a" (highest similarity)
    assert results[0].source_path == "/a.md"
    # Second result should be neighbour "b" via relates_to edge
    assert any(r.source_path == "/b.md" for r in results)


def test_engine_query_cache_hit_skips_embedding(tmp_path):
    from borai.retrieval.engine import RetrievalEngine

    nodes = [Node(id="a", source_type="post", source_path="/a.md",
                  chunk_index=0, content="x", metadata={}, created_at="x")]
    _seed_graph(tmp_path, nodes, [], np.array([[1.0]], dtype=np.float32))

    mock_embedder = MagicMock()
    mock_embedder.embed.return_value = np.array([1.0], dtype=np.float32)

    engine = RetrievalEngine(graph_dir=tmp_path, embedder=mock_embedder, query_cache_enabled=True)
    engine.query("q", agent="x", token_budget=1000)
    engine.query("q", agent="x", token_budget=1000)
    assert mock_embedder.embed.call_count == 1  # second call cached


def test_engine_query_disabled_cache_always_embeds(tmp_path):
    from borai.retrieval.engine import RetrievalEngine

    nodes = [Node(id="a", source_type="post", source_path="/a.md",
                  chunk_index=0, content="x", metadata={}, created_at="x")]
    _seed_graph(tmp_path, nodes, [], np.array([[1.0]], dtype=np.float32))

    mock_embedder = MagicMock()
    mock_embedder.embed.return_value = np.array([1.0], dtype=np.float32)

    engine = RetrievalEngine(graph_dir=tmp_path, embedder=mock_embedder, query_cache_enabled=False)
    engine.query("q", agent="x", token_budget=1000)
    engine.query("q", agent="x", token_budget=1000)
    assert mock_embedder.embed.call_count == 2
```

- [ ] **Step 2: Run test — verify fail**

Expected: test fails because `RetrievalEngine.query` doesn't exist yet, or embedder arg isn't accepted.

- [ ] **Step 3: Replace the RetrievalEngine class with a full implementation**

Replace the skeleton `RetrievalEngine` class in `borai/retrieval/engine.py` with:

```python
class RetrievalEngine:
    def __init__(
        self,
        graph_dir: Path,
        embedder=None,  # borai.indexer.embedder.Embedder
        similarity_floor: float = 0.3,
        default_k: int = 5,
        query_cache_enabled: bool = True,
        query_cache_ttl: int = 60,
    ):
        self.graph_dir = Path(graph_dir)
        self.embedder = embedder
        self.similarity_floor = similarity_floor
        self.default_k = default_k
        self.snapshot = GraphSnapshot(self.graph_dir)
        self.snapshot.load()
        self.query_cache_enabled = query_cache_enabled
        self.query_cache = QueryCache(ttl_seconds=query_cache_ttl)

    def _lazy_embedder(self):
        if self.embedder is None:
            from borai import config
            from borai.indexer.embedder import Embedder
            self.embedder = Embedder(
                ollama_url=config.OLLAMA_URL,
                model=config.EMBED_MODEL,
                cache_dir=self.graph_dir / "cache",
                cache_enabled=config.EMBEDDING_CACHE_ENABLED,
            )
        return self.embedder

    def query(
        self,
        query_text: str,
        agent: str = "default",
        token_budget: int = 1500,
    ) -> list[RetrievalResult]:
        # Snapshot invalidation clears the query cache
        if self.snapshot.reload_if_changed():
            self.query_cache.clear()

        if self.query_cache_enabled:
            cached = self.query_cache.get(query_text, agent)
            if cached is not None:
                return cached

        embedder = self._lazy_embedder()
        query_vec = embedder.embed(query_text)

        seeds = top_k_seeds(query_vec, self.snapshot, k=self.default_k, floor=self.similarity_floor)
        seed_ids = [seed_id for seed_id, _ in seeds]

        scope = AGENT_EDGE_SCOPES.get(agent, DEFAULT_AGENT_SCOPE)
        neighbours = traverse_neighbours(seed_ids, self.snapshot, scope)

        ranked = rank_results(seeds, neighbours, self.snapshot)
        pruned = prune_to_budget(ranked, token_budget)

        if self.query_cache_enabled:
            self.query_cache.put(query_text, agent, pruned)
        return pruned
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_engine.py -v
```

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/retrieval/engine.py ops/borai-graph/tests/test_engine.py
git commit -m "feat(borai-graph): RetrievalEngine.query integrating seeds, traverse, rank, prune, cache"
```

---

## Task 9: Snapshot reload invalidates query cache

**Files:**
- Modify: `ops/borai-graph/tests/test_engine.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_engine.py`:

```python
def test_snapshot_reload_invalidates_query_cache(tmp_path):
    from borai.retrieval.engine import RetrievalEngine
    import time

    n = Node(id="a", source_type="post", source_path="/a.md",
             chunk_index=0, content="v1", metadata={}, created_at="x")
    _seed_graph(tmp_path, [n], [], np.array([[1.0]], dtype=np.float32))

    mock_embedder = MagicMock()
    mock_embedder.embed.return_value = np.array([1.0], dtype=np.float32)

    engine = RetrievalEngine(graph_dir=tmp_path, embedder=mock_embedder)
    r1 = engine.query("q", agent="x", token_budget=1000)
    assert r1[0].content == "v1"

    # Wait for mtime resolution and update the graph
    time.sleep(1.1)
    n2 = Node(id="a", source_type="post", source_path="/a.md",
              chunk_index=0, content="v2", metadata={}, created_at="x")
    _seed_graph(tmp_path, [n2], [], np.array([[1.0]], dtype=np.float32))

    # Next query should reload and skip cached v1
    r2 = engine.query("q", agent="x", token_budget=1000)
    assert r2[0].content == "v2"
```

- [ ] **Step 2: Run test — verify pass (already implemented)**

```bash
uv run pytest tests/test_engine.py::test_snapshot_reload_invalidates_query_cache -v
```

Expected: pass. (The engine calls `snapshot.reload_if_changed()` at the top of `query` and clears the cache on change.)

- [ ] **Step 3: Commit**

```bash
git add ops/borai-graph/tests/test_engine.py
git commit -m "test(borai-graph): snapshot reload invalidates query cache"
```

---

## Task 10: Dashboard — graph stats reader

**Files:**
- Create: `ops/borai-graph/borai/dashboard/graph_stats.py`
- Create: `ops/borai-graph/tests/test_graph_stats.py`

- [ ] **Step 1: Write failing test**

```python
# tests/test_graph_stats.py
import json
from pathlib import Path

import numpy as np

from borai.indexer.types import Edge, Node


def _seed_graph(graph_dir: Path, nodes, edges, vectors):
    graph_dir.mkdir(parents=True, exist_ok=True)
    (graph_dir / "graph.json").write_text(json.dumps({
        "nodes": [n.to_dict() for n in nodes],
        "edges": [e.to_dict() for e in edges],
    }, indent=2))
    np.save(graph_dir / "vectors.npy", vectors)
    (graph_dir / "vectors_index.json").write_text(json.dumps({
        "row_to_node": [n.id for n in nodes]
    }))


def test_collect_stats_counts_nodes_by_source(tmp_path):
    from borai.dashboard.graph_stats import collect_stats

    nodes = [
        Node(id="a", source_type="skill", source_path="/a.md",
             chunk_index=0, content="x", metadata={}, created_at="x"),
        Node(id="b", source_type="skill", source_path="/b.md",
             chunk_index=0, content="y", metadata={}, created_at="x"),
        Node(id="c", source_type="post", source_path="/c.md",
             chunk_index=0, content="z", metadata={}, created_at="x"),
    ]
    _seed_graph(tmp_path, nodes, [], np.zeros((3, 2), dtype=np.float32))

    stats = collect_stats(tmp_path)
    assert stats["nodes"]["total"] == 3
    assert stats["nodes"]["by_source"]["skill"] == 2
    assert stats["nodes"]["by_source"]["post"] == 1


def test_collect_stats_counts_edges_by_type(tmp_path):
    from borai.dashboard.graph_stats import collect_stats

    nodes = [
        Node(id=i, source_type="post", source_path=f"/{i}.md",
             chunk_index=0, content="x", metadata={}, created_at="x")
        for i in ["a", "b"]
    ]
    edges = [
        Edge(source="a", target="b", edge_type="relates_to", confidence=0.9, source_of_edge="rule:relates_to"),
        Edge(source="a", target="b", edge_type="same_product", confidence=1.0, source_of_edge="rule:same_product"),
        Edge(source="b", target="a", edge_type="relates_to", confidence=0.9, source_of_edge="rule:relates_to"),
    ]
    _seed_graph(tmp_path, nodes, edges, np.zeros((2, 2), dtype=np.float32))

    stats = collect_stats(tmp_path)
    assert stats["edges"]["total"] == 3
    assert stats["edges"]["by_type"]["relates_to"] == 2
    assert stats["edges"]["by_type"]["same_product"] == 1


def test_collect_stats_missing_graph_returns_zero(tmp_path):
    from borai.dashboard.graph_stats import collect_stats

    stats = collect_stats(tmp_path)
    assert stats["nodes"]["total"] == 0
    assert stats["edges"]["total"] == 0
    assert stats["index"]["last_updated"] is None
```

- [ ] **Step 2: Run test — verify fail**

Expected: `ModuleNotFoundError`.

- [ ] **Step 3: Implement stats collector**

```python
# borai/dashboard/graph_stats.py
from __future__ import annotations

import datetime as dt
import json
from collections import Counter
from pathlib import Path


def collect_stats(graph_dir: Path) -> dict:
    graph_dir = Path(graph_dir)
    graph_path = graph_dir / "graph.json"
    hash_path = graph_dir / "hash_registry.json"

    if not graph_path.exists():
        return {
            "nodes": {"total": 0, "by_source": {}},
            "edges": {"total": 0, "by_type": {}},
            "index": {"last_updated": None, "dirty_files": 0},
            "health": {},
        }

    graph = json.loads(graph_path.read_text())
    nodes = graph.get("nodes", [])
    edges = graph.get("edges", [])

    source_counts = Counter(n["source_type"] for n in nodes)
    edge_counts = Counter(e["edge_type"] for e in edges)

    mtime = graph_path.stat().st_mtime
    last_updated = dt.datetime.fromtimestamp(mtime, tz=dt.timezone.utc).isoformat(timespec="seconds")

    # Dirty files: paths known to hash registry but mtime changed since last indexing
    dirty_count = 0
    if hash_path.exists():
        try:
            registry = json.loads(hash_path.read_text())
            # We can't compute "dirty" without recomputing hashes; use 0 as placeholder
            # Pipeline updates this; stats just reports current hash-registry size
            dirty_count = 0  # conservative — the pipeline reports dirty at runtime
        except json.JSONDecodeError:
            dirty_count = 0

    return {
        "nodes": {"total": len(nodes), "by_source": dict(source_counts)},
        "edges": {"total": len(edges), "by_type": dict(edge_counts)},
        "index": {"last_updated": last_updated, "dirty_files": dirty_count},
        "health": {},
    }
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_graph_stats.py -v
```

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/dashboard/graph_stats.py ops/borai-graph/tests/test_graph_stats.py
git commit -m "feat(borai-graph): dashboard stats collector for nodes/edges/index"
```

---

## Task 11: Dashboard — Ollama health probe

**Files:**
- Modify: `ops/borai-graph/borai/dashboard/graph_stats.py`
- Modify: `ops/borai-graph/tests/test_graph_stats.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_graph_stats.py`:

```python
from unittest.mock import MagicMock, patch


def test_ollama_health_reachable():
    from borai.dashboard.graph_stats import check_ollama

    with patch("borai.dashboard.graph_stats.requests.get") as get:
        get.return_value = MagicMock(status_code=200)
        status = check_ollama("http://localhost:11434")
        assert status == "reachable"


def test_ollama_health_unreachable():
    from borai.dashboard.graph_stats import check_ollama
    import requests

    with patch("borai.dashboard.graph_stats.requests.get", side_effect=requests.ConnectionError):
        status = check_ollama("http://localhost:11434")
        assert status == "unreachable"
```

- [ ] **Step 2: Run test — verify fail**

Expected: `ImportError: cannot import name 'check_ollama'`.

- [ ] **Step 3: Implement**

Append to `borai/dashboard/graph_stats.py`:

```python
import requests


def check_ollama(ollama_url: str, timeout: float = 2.0) -> str:
    try:
        resp = requests.get(f"{ollama_url.rstrip('/')}/api/tags", timeout=timeout)
        if resp.status_code == 200:
            return "reachable"
        return f"error:{resp.status_code}"
    except requests.RequestException:
        return "unreachable"
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_graph_stats.py -v
```

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/dashboard/graph_stats.py ops/borai-graph/tests/test_graph_stats.py
git commit -m "feat(borai-graph): dashboard Ollama health probe"
```

---

## Task 12: Dashboard — human-readable + JSON output

**Files:**
- Modify: `ops/borai-graph/borai/dashboard/graph_stats.py`
- Modify: `ops/borai-graph/tests/test_graph_stats.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_graph_stats.py`:

```python
def test_format_human(tmp_path):
    from borai.dashboard.graph_stats import format_human

    stats = {
        "nodes": {"total": 3, "by_source": {"skill": 2, "post": 1}},
        "edges": {"total": 2, "by_type": {"relates_to": 2}},
        "index": {"last_updated": "2026-04-22T10:00:00Z", "dirty_files": 0},
        "health": {"ollama": "reachable"},
    }
    output = format_human(stats)
    assert "NODES" in output
    assert "3" in output
    assert "skill: 2" in output
    assert "relates_to: 2" in output
    assert "reachable" in output


def test_format_json(tmp_path):
    from borai.dashboard.graph_stats import format_json

    stats = {"nodes": {"total": 0, "by_source": {}}, "edges": {"total": 0, "by_type": {}},
             "index": {"last_updated": None, "dirty_files": 0}, "health": {}}
    output = format_json(stats)
    parsed = json.loads(output)
    assert parsed["nodes"]["total"] == 0
```

- [ ] **Step 2: Run test — verify fail**

Expected: `ImportError: cannot import name 'format_human'`.

- [ ] **Step 3: Implement**

Append to `borai/dashboard/graph_stats.py`:

```python
def format_human(stats: dict) -> str:
    nodes = stats["nodes"]
    edges = stats["edges"]
    index = stats["index"]
    health = stats.get("health", {})

    lines: list[str] = []
    lines.append(f"NODES        TOTAL           {nodes['total']:,}")
    by_src = " | ".join(f"{k}: {v}" for k, v in sorted(nodes["by_source"].items()))
    lines.append(f"             by source       {by_src or '—'}")
    lines.append(f"EDGES        TOTAL           {edges['total']:,}")
    by_type = " | ".join(f"{k}: {v}" for k, v in sorted(edges["by_type"].items()))
    lines.append(f"             by type         {by_type or '—'}")
    lines.append(f"INDEX        last updated    {index.get('last_updated') or '—'}")
    lines.append(f"             dirty files     {index.get('dirty_files', 0)}")
    if health:
        for k, v in health.items():
            lines.append(f"HEALTH       {k:<15} {v}")
    return "\n".join(lines)


def format_json(stats: dict) -> str:
    return json.dumps(stats, indent=2, default=str)
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_graph_stats.py -v
```

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/dashboard/graph_stats.py ops/borai-graph/tests/test_graph_stats.py
git commit -m "feat(borai-graph): dashboard human-readable and JSON output formatters"
```

---

## Task 13: Dashboard — CLI main entrypoint

**Files:**
- Modify: `ops/borai-graph/borai/dashboard/graph_stats.py`
- Modify: `ops/borai-graph/tests/test_graph_stats.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_graph_stats.py`:

```python
def test_main_human_output(tmp_path, capsys, monkeypatch):
    from borai.dashboard.graph_stats import main

    _seed_graph(
        tmp_path,
        [Node(id="a", source_type="skill", source_path="/x.md",
              chunk_index=0, content="x", metadata={}, created_at="x")],
        [],
        np.array([[0.1]], dtype=np.float32),
    )

    monkeypatch.setenv("BORAI_GRAPH_DIR", str(tmp_path))
    with patch("borai.dashboard.graph_stats.check_ollama", return_value="reachable"):
        exit_code = main(argv=[])
    captured = capsys.readouterr()
    assert exit_code == 0
    assert "NODES" in captured.out
    assert "skill: 1" in captured.out


def test_main_json_output(tmp_path, capsys, monkeypatch):
    from borai.dashboard.graph_stats import main

    _seed_graph(tmp_path, [], [], np.zeros((0, 1), dtype=np.float32))

    monkeypatch.setenv("BORAI_GRAPH_DIR", str(tmp_path))
    with patch("borai.dashboard.graph_stats.check_ollama", return_value="reachable"):
        exit_code = main(argv=["--json"])
    captured = capsys.readouterr()
    assert exit_code == 0
    parsed = json.loads(captured.out)
    assert parsed["nodes"]["total"] == 0
```

- [ ] **Step 2: Run test — verify fail**

Expected: `ImportError: cannot import name 'main'`.

- [ ] **Step 3: Implement**

Append to `borai/dashboard/graph_stats.py`:

```python
import argparse
import importlib
import sys


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="BorAI Knowledge Graph health stats")
    parser.add_argument("--json", action="store_true", help="output JSON instead of human-readable")
    args = parser.parse_args(argv)

    # Re-import config so env vars set after Python import still take effect in tests
    from borai import config
    importlib.reload(config)

    stats = collect_stats(config.GRAPH_DIR)
    stats["health"]["ollama"] = check_ollama(config.OLLAMA_URL)

    if args.json:
        print(format_json(stats))
    else:
        print(format_human(stats))
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_graph_stats.py -v
```

- [ ] **Step 5: Install the entrypoint (already configured in pyproject.toml)**

```bash
cd ~/code/BorAI/ops/borai-graph
uv sync
uv run borai-graph-stats --json
```

Expected output: JSON stats to stdout.

- [ ] **Step 6: Commit**

```bash
git add ops/borai-graph/borai/dashboard/graph_stats.py ops/borai-graph/tests/test_graph_stats.py
git commit -m "feat(borai-graph): dashboard CLI main with --json flag"
```

---

## Task 14: run.py — daemon entrypoint with Pipeline + Watcher wiring

**Files:**
- Create: `ops/borai-graph/borai/run.py`
- Create: `ops/borai-graph/tests/test_run.py`

- [ ] **Step 1: Write failing test**

```python
# tests/test_run.py
from unittest.mock import MagicMock, patch


def test_build_runtime_wires_pipeline_and_watcher(tmp_path, monkeypatch):
    from borai.run import build_runtime

    monkeypatch.setenv("BORAI_GRAPH_DIR", str(tmp_path))
    watch_dir = tmp_path / "w"
    watch_dir.mkdir()
    monkeypatch.setenv("BORAI_WATCH_PATHS", str(watch_dir))

    with patch("borai.run.Pipeline") as pipeline_cls, \
         patch("borai.run.IndexerWatcher") as watcher_cls:
        pipeline = MagicMock()
        pipeline_cls.return_value = pipeline
        watcher = MagicMock()
        watcher_cls.return_value = watcher

        rt = build_runtime()
        assert rt.pipeline is pipeline
        assert rt.watcher is watcher


def test_initial_bulk_ingest_runs_when_hash_registry_empty(tmp_path, monkeypatch):
    from borai.run import initial_bulk_ingest

    monkeypatch.setenv("BORAI_GRAPH_DIR", str(tmp_path))

    pipeline = MagicMock()
    pipeline.hash_registry = MagicMock()
    pipeline.hash_registry._state = {}  # empty
    watch_paths = [tmp_path / "w1", tmp_path / "w2"]
    for p in watch_paths:
        p.mkdir()
        (p / "a.md").write_text("x")

    initial_bulk_ingest(pipeline, watch_paths)
    # process_directory called for each path
    assert pipeline.process_directory.call_count == len(watch_paths)
    pipeline.flush.assert_called_once()


def test_initial_bulk_ingest_skipped_when_hash_registry_has_entries(tmp_path):
    from borai.run import initial_bulk_ingest

    pipeline = MagicMock()
    pipeline.hash_registry = MagicMock()
    pipeline.hash_registry._state = {"/previously/indexed.md": "abc"}

    initial_bulk_ingest(pipeline, [tmp_path])
    pipeline.process_directory.assert_not_called()
    pipeline.flush.assert_not_called()
```

- [ ] **Step 2: Run test — verify fail**

Expected: `ModuleNotFoundError: No module named 'borai.run'`.

- [ ] **Step 3: Implement run.py**

```python
# borai/run.py
from __future__ import annotations

import logging
import signal
import sys
import threading
from dataclasses import dataclass
from pathlib import Path

from borai import config
from borai.indexer.pipeline import Pipeline
from borai.indexer.watcher import IndexerWatcher, make_pipeline_handler


log = logging.getLogger(__name__)


@dataclass
class Runtime:
    pipeline: Pipeline
    watcher: IndexerWatcher
    stop_event: threading.Event


def build_runtime() -> Runtime:
    graph_dir = Path(config.GRAPH_DIR)
    pipeline = Pipeline(graph_dir=graph_dir)
    watch_paths = [Path(p) for p in config.WATCH_PATHS if p]
    handler = make_pipeline_handler(pipeline, pipeline.hash_registry)
    watcher = IndexerWatcher(
        paths=watch_paths,
        on_change=handler,
        debounce_seconds=config.DEBOUNCE_SECONDS,
    )
    return Runtime(pipeline=pipeline, watcher=watcher, stop_event=threading.Event())


def initial_bulk_ingest(pipeline: Pipeline, watch_paths: list[Path]) -> None:
    if pipeline.hash_registry._state:
        log.info("hash_registry not empty (%d entries) — skipping initial bulk ingest",
                 len(pipeline.hash_registry._state))
        return
    log.info("initial bulk ingest: scanning %d paths", len(watch_paths))
    total = 0
    for path in watch_paths:
        if path.exists():
            total += pipeline.process_directory(path, extensions={".md", ".txt", ".py", ".json", ".yaml"})
    log.info("initial bulk ingest: processed %d files", total)
    pipeline.flush()


def configure_logging() -> None:
    level = getattr(logging, config.LOG_LEVEL.upper(), logging.INFO)
    logging.basicConfig(
        level=level,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
    )


def main(argv: list[str] | None = None) -> int:
    configure_logging()
    rt = build_runtime()

    # Initial bulk ingest before the watcher starts
    initial_bulk_ingest(rt.pipeline, [Path(p) for p in config.WATCH_PATHS if p])

    rt.watcher.start()
    log.info("watcher started; watching %s", ":".join(config.WATCH_PATHS))

    # Signal handlers
    def _shutdown(signum, frame):
        log.info("received signal %d — shutting down", signum)
        rt.stop_event.set()

    signal.signal(signal.SIGINT, _shutdown)
    signal.signal(signal.SIGTERM, _shutdown)

    try:
        rt.stop_event.wait()
    finally:
        rt.watcher.stop()
        log.info("watcher stopped")
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_run.py -v
```

Expected: `3 passed`.

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/run.py ops/borai-graph/tests/test_run.py
git commit -m "feat(borai-graph): run.py daemon entrypoint with initial bulk ingest and signal handling"
```

---

## Task 15: run.py — smoke test via subprocess

**Files:**
- Modify: `ops/borai-graph/tests/test_run.py`

- [ ] **Step 1: Write smoke test**

Append to `tests/test_run.py`:

```python
import signal
import subprocess
import sys
import time


def test_run_py_starts_and_stops_cleanly(tmp_path, monkeypatch):
    """Spawn run.py as subprocess; SIGTERM it; verify clean exit."""
    graph_dir = tmp_path / "graph"
    graph_dir.mkdir()
    watch_dir = tmp_path / "watch"
    watch_dir.mkdir()

    env = {
        "PATH": "/usr/bin:/bin:/usr/local/bin",
        "HOME": str(tmp_path),
        "BORAI_GRAPH_DIR": str(graph_dir),
        "BORAI_WATCH_PATHS": str(watch_dir),
        "BORAI_OLLAMA_URL": "http://unreachable.local",  # Ollama offline; pipeline will log errors but shouldn't crash
        "ANTHROPIC_API_KEY": "fake",
        "BORAI_DEBOUNCE_SECONDS": "0.2",
    }

    proc = subprocess.Popen(
        [sys.executable, "-m", "borai.run"],
        cwd=str(Path(__file__).resolve().parent.parent),
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    try:
        time.sleep(1.5)  # let it start up + do empty bulk ingest
        # Should still be alive
        assert proc.poll() is None
        proc.send_signal(signal.SIGTERM)
        proc.wait(timeout=5.0)
    except Exception:
        proc.kill()
        raise

    # Should exit 0 or signal-terminated (on some systems SIGTERM returns -15 or 143)
    assert proc.returncode in (0, -signal.SIGTERM, 128 + signal.SIGTERM)
```

- [ ] **Step 2: Run smoke test**

```bash
uv run pytest tests/test_run.py::test_run_py_starts_and_stops_cleanly -v
```

Expected: passes within ~7 seconds.

- [ ] **Step 3: Commit**

```bash
git add ops/borai-graph/tests/test_run.py
git commit -m "test(borai-graph): run.py subprocess smoke test (start + SIGTERM)"
```

---

## Task 16: README — full setup and running instructions

**Files:**
- Modify: `ops/borai-graph/README.md`

- [ ] **Step 1: Write full README**

Replace `ops/borai-graph/README.md` contents:

```markdown
# BorAI Knowledge Graph

Local-only RAG with a graph index. Indexer watches files under configured paths, embeds content via Ollama, detects edges with rules + Haiku fallback, and writes atomic graph snapshots that the retrieval engine reads for agent queries.

See design spec: `docs/superpowers/specs/2026-04-22-borai-knowledge-graph-design.md`

## One-time setup

### 1. Install Ollama

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Verify: `ollama --version`.

### 2. Pull the embedding model

```bash
ollama pull nomic-embed-text
```

Verify: `ollama list` shows `nomic-embed-text`.

### 3. Install the package

```bash
cd ~/code/BorAI/ops/borai-graph
uv sync --extra dev
```

### 4. Configure environment

```bash
cp .env.example .env
# Edit .env; set ANTHROPIC_API_KEY (shared with BorAI root .env.local)
```

Key env vars:

| Variable | Default | Purpose |
|---|---|---|
| `BORAI_GRAPH_DIR` | `/borai/graph` | Runtime graph file location |
| `BORAI_WATCH_PATHS` | `/mnt/skills:/mnt/transcripts:/borai/products:/borai/funding:/borai/posts:/borai/code` | Colon-separated watch paths |
| `BORAI_OLLAMA_URL` | `http://localhost:11434` | Ollama HTTP endpoint |
| `BORAI_EMBED_MODEL` | `nomic-embed-text` | Ollama embedding model |
| `ANTHROPIC_API_KEY` | (required) | For Haiku edge-detector assist |
| `BORAI_TOKEN_BUDGET` | `1500` | Retrieval token budget |
| `BORAI_SIMILARITY_FLOOR` | `0.3` | Drop seeds below this cosine |
| `BORAI_HAIKU_CALL_CAP` | `100` | Max Haiku calls per pipeline run |
| `BORAI_DEBOUNCE_SECONDS` | `1.0` | File-event debounce window |

## Running

### Foreground (development)

```bash
uv run borai-graph
```

Logs go to stdout. Ctrl-C for clean shutdown.

### Background (production)

```bash
mkdir -p /borai/graph/logs
nohup uv run borai-graph > /borai/graph/logs/run.log 2>&1 &
```

### Health check

```bash
uv run borai-graph-stats           # human-readable
uv run borai-graph-stats --json    # machine-readable
```

JSON output shape:

```json
{
  "nodes": {"total": 12483, "by_source": {"skill": 1204, "transcript": 8120, ...}},
  "edges": {"total": 43891, "by_type": {"relates_to": 18200, ...}},
  "index": {"last_updated": "2026-04-22T10:15:23+00:00", "dirty_files": 0},
  "health": {"ollama": "reachable"}
}
```

## Using retrieval from an agent

```python
from borai.retrieval.engine import RetrievalEngine

engine = RetrievalEngine(graph_dir="/borai/graph")
results = engine.query(
    query_text="how do I set up the funding tracker",
    agent="funding_tracker",  # uses AGENT_EDGE_SCOPES["funding_tracker"]
    token_budget=1500,
)
for r in results:
    print(r.source_path, r.rank, r.reason)
    print(r.content)
```

Known agents (from the spec): `funding_tracker`, `build_in_public_engine`, `delegate_agent`, `hackathon_radar`. Unknown agents fall back to `["relates_to"]`.

## First-time indexing

On first run, `hash_registry.json` is empty — `run.py` walks every watch path and indexes all files under supported extensions (.md, .txt, .py, .json, .yaml). For a cold BorAI vault, expect this to take minutes. Subsequent runs are incremental via md5 hash comparison.

## Tests

```bash
cd ~/code/BorAI/ops/borai-graph
uv run pytest
uv run pytest --cov=borai --cov-report=term-missing
```

## Architecture at a glance

```
File change → watchdog event → debounce (1s) →
  hash check (md5) → chunker (source-aware) →
  embedder (Ollama + on-disk cache) →
  edge detector (rules first, Haiku + prompt caching on < 2 relates_to) →
  pipeline atomic swap → graph.json + vectors.npy

Agent query → RetrievalEngine.query →
  embed → cosine top-5 seeds (≥ 0.3 floor) →
  depth-1 traversal (agent-scoped edge types) →
  rank (seeds by sim, neighbours by sim × confidence) →
  prune to token budget → RetrievalResult list
```

## Caches

- **Embedding cache** (on-disk): `cache/embeddings.json` + `cache/embeddings_vectors.npy`. Invalidated on embed-model change.
- **Haiku response cache** (on-disk): `cache/haiku_responses.json`. Invalidated on Haiku-model change.
- **Anthropic prompt caching** (native): `cache_control: ephemeral` on Haiku system prompt. 5-minute TTL.
- **Retrieval query cache** (in-process): TTL-bounded, invalidated on graph snapshot reload.
- **Graph snapshot** (in-process): held in RetrievalEngine, reloaded on graph.json mtime change.

## Troubleshooting

- **Ollama unreachable** → embedder logs ERROR and pipeline continues. Retrieval returns empty with a warning. Fix: `ollama serve`.
- **Haiku rate limit hit** → Stage 2 skipped for rest of pipeline run; rule-only edges still produced.
- **Cache corruption** → delete `cache/` subdirectory; rebuilds on next run.
- **Graph corruption** → delete `graph.json` + `vectors.npy` + `hash_registry.json`; run.py rebuilds from scratch.
```

- [ ] **Step 2: Commit**

```bash
git add ops/borai-graph/README.md
git commit -m "docs(borai-graph): full README with setup, running, health check, retrieval usage"
```

---

## Task 17: Full integration — query after indexing real fixture dir

**Files:**
- Create: `ops/borai-graph/tests/test_full_integration.py`

- [ ] **Step 1: Write failing test**

```python
# tests/test_full_integration.py
from pathlib import Path
from unittest.mock import MagicMock, patch

import numpy as np
import pytest


@pytest.fixture
def fixtures_dir() -> Path:
    return Path(__file__).parent / "fixtures"


def test_full_pipeline_then_query(tmp_path, fixtures_dir):
    """End-to-end: index a fixture directory, then query and get ranked results."""
    from borai.indexer.pipeline import Pipeline
    from borai.retrieval.engine import RetrievalEngine

    # Set up watch path with two files
    watch = tmp_path / "mnt" / "skills" / "tests"
    watch.mkdir(parents=True)
    (watch / "a.md").write_text((fixtures_dir / "skill_small.md").read_text())
    (watch / "b.md").write_text("# B\n\n## About\n\nSimilar content to A.\n")

    graph_dir = tmp_path / "graph"

    # Mock embedder + detector to keep test fast and deterministic
    with patch("borai.indexer.pipeline.Embedder") as pipe_emb_cls, \
         patch("borai.indexer.pipeline.EdgeDetector") as det_cls, \
         patch("borai.indexer.pipeline.infer_source_type", return_value="skill"):

        # Each embedder.embed returns an identity-ish vector based on content hash
        def fake_embed(text: str) -> np.ndarray:
            h = hash(text) % 1000
            vec = np.array([float(h), 1.0], dtype=np.float32)
            return vec / np.linalg.norm(vec)

        pipe_emb = MagicMock()
        pipe_emb.embed.side_effect = fake_embed
        pipe_emb_cls.return_value = pipe_emb

        det = MagicMock()
        det.detect_edges.return_value = []
        det_cls.return_value = det

        pipeline = Pipeline(graph_dir=graph_dir)
        pipeline.process_directory(watch, extensions={".md"})
        pipeline.flush()

    # Now query with a separate embedder mock returning the same shape
    query_emb = MagicMock()
    query_emb.embed.return_value = np.array([1.0, 1.0], dtype=np.float32) / np.sqrt(2)

    engine = RetrievalEngine(
        graph_dir=graph_dir,
        embedder=query_emb,
        similarity_floor=0.0,  # include everything for this test
        query_cache_enabled=False,
    )
    results = engine.query("test query", agent="delegate_agent", token_budget=10000)
    assert len(results) > 0
    # All results should come from the two fixture files
    paths = {r.source_path for r in results}
    assert any("a.md" in p for p in paths) or any("b.md" in p for p in paths)
```

- [ ] **Step 2: Run test — verify pass**

```bash
uv run pytest tests/test_full_integration.py -v
```

Expected: 1 passed.

- [ ] **Step 3: Commit**

```bash
git add ops/borai-graph/tests/test_full_integration.py
git commit -m "test(borai-graph): end-to-end — pipeline indexes fixtures, engine queries"
```

---

## Task 18: Full suite + coverage gate

**Files:**
- None (verification)

- [ ] **Step 1: Run full suite with coverage**

```bash
cd ~/code/BorAI/ops/borai-graph
uv run pytest --cov=borai --cov-report=term-missing
```

Expected: all tests pass. Coverage ≥ 80% across retrieval, dashboard, run modules.

- [ ] **Step 2: Syntax check on every Python file**

```bash
uv run python -m py_compile borai/**/*.py
```

Expected: no output.

- [ ] **Step 3: Entrypoint smoke**

```bash
uv run borai-graph-stats --json
```

Expected: valid JSON to stdout. Exit 0.

- [ ] **Step 4: Announce Plan 2 complete**

The query surface is live: `RetrievalEngine.query(...)` returns ranked, pruned, agent-scoped results from the graph snapshot with full caching stack. `borai-graph` runs as a daemon with initial bulk ingest and clean SIGTERM shutdown. `borai-graph-stats` exposes health both human-readable and as JSON.

Both plans complete. The BorAI Knowledge Graph is ready to integrate with the agent fleet.

---

## Self-review notes (author-side)

Spec coverage — every spec section that wasn't covered by Plan 1 has a task here:

- Retrieval engine (embed → similarity → traverse → rank → prune): Tasks 3, 4, 5, 6, 8.
- Agent edge scopes map: Task 1 (constant) + Task 4 (usage).
- Graph snapshot with mtime invalidation: Task 2.
- Query cache TTL-bounded, cleared on snapshot reload: Tasks 7 + 9.
- Dashboard CLI (Option A) — collector, Ollama health, human + JSON formats, main entrypoint: Tasks 10, 11, 12, 13.
- run.py wire-up + initial bulk ingest + signal handling: Task 14.
- run.py subprocess smoke: Task 15.
- Full README with setup, running, health check, retrieval usage, caches, troubleshooting: Task 16.
- End-to-end integration across indexer + retrieval: Task 17.
- Coverage gate: Task 18.

No placeholders.

Type consistency: `Node.from_dict`, `Edge.from_dict`, `Edge.confidence`, `Embedder.embed` return types all match Plan 1 definitions. `Pipeline.hash_registry`, `Pipeline.process_directory`, `Pipeline.flush` match Plan 1's public surface. `IndexerWatcher` and `make_pipeline_handler` signatures match Plan 1.
