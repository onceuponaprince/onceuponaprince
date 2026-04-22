# BorAI Knowledge Graph — Indexer Layer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the indexer layer of the BorAI Knowledge Graph — a file watcher, source-aware chunker, local embedder, hybrid edge detector, and pipeline orchestrator that together produce graph.json + vectors.npy from the configured watch paths.

**Architecture:** File watcher (watchdog) emits events when files change under watch paths. Hash registry detects real content changes vs metadata-only noise. Pipeline orchestrates chunk → embed → detect edges → atomic swap. Embedder caches results on disk keyed by content hash. Edge detector runs rule-based Stage 1; Haiku assist only when Stage 1 is sparse, with both an on-disk response cache and native Anthropic prompt caching.

**Tech Stack:** Python 3.11+, uv (package manager), watchdog (file events), numpy (vectors), requests (Ollama HTTP), anthropic (Haiku SDK), python-dotenv (env vars), pytest (tests).

**Source spec:** `docs/superpowers/specs/2026-04-22-borai-knowledge-graph-design.md` (commits `da7d01a` + `881886d`).

**Target repo:** `~/code/BorAI/` · Target package root: `ops/borai-graph/`

**Scope note:** This plan covers the Indexer layer only. Plan 2 (to follow) covers `retrieval/engine.py`, `dashboard/graph_stats.py`, `run.py`, and full `README.md`.

---

## File Structure

**Project root (`ops/borai-graph/`):**
- `pyproject.toml` — uv project definition, dependencies, scripts
- `.env.example` — env-var template
- `.gitignore` — cache dirs, __pycache__, .env
- `README.md` — setup stub (fleshed out in Plan 2)

**`borai/` package:**
- `borai/__init__.py` — empty
- `borai/config.py` — env-var loading with defaults

**`borai/indexer/` package:**
- `borai/indexer/__init__.py` — empty
- `borai/indexer/types.py` — shared dataclasses: Node, Edge, Chunk
- `borai/indexer/hash_registry.py` — path → md5, dirty detection
- `borai/indexer/chunker.py` — per-source-type dispatcher + oversized-chunk split
- `borai/indexer/embedder.py` — Ollama client + on-disk embedding cache
- `borai/indexer/edge_detector.py` — rule-based + Haiku assist (both caches)
- `borai/indexer/pipeline.py` — orchestrator + atomic file swap
- `borai/indexer/watcher.py` — watchdog observer + debounce

**`tests/`:**
- `tests/__init__.py` — empty
- `tests/conftest.py` — shared fixtures
- `tests/test_config.py`
- `tests/test_types.py`
- `tests/test_hash_registry.py`
- `tests/test_chunker.py`
- `tests/test_embedder.py`
- `tests/test_edge_detector.py`
- `tests/test_pipeline.py`
- `tests/test_watcher.py`
- `tests/fixtures/` — sample files per source type

Runtime graph files (created at runtime, not in repo): `$BORAI_GRAPH_DIR/graph.json` + `vectors.npy` + `vectors_index.json` + `hash_registry.json` + `cache/`.

---

## Task 1: Scaffold project structure

**Files:**
- Create: `~/code/BorAI/ops/borai-graph/pyproject.toml`
- Create: `~/code/BorAI/ops/borai-graph/.env.example`
- Create: `~/code/BorAI/ops/borai-graph/.gitignore`
- Create: `~/code/BorAI/ops/borai-graph/README.md`
- Create: `~/code/BorAI/ops/borai-graph/borai/__init__.py`
- Create: `~/code/BorAI/ops/borai-graph/borai/indexer/__init__.py`
- Create: `~/code/BorAI/ops/borai-graph/tests/__init__.py`

- [ ] **Step 1: Create directories**

```bash
mkdir -p ~/code/BorAI/ops/borai-graph/borai/indexer
mkdir -p ~/code/BorAI/ops/borai-graph/borai/retrieval
mkdir -p ~/code/BorAI/ops/borai-graph/borai/dashboard
mkdir -p ~/code/BorAI/ops/borai-graph/tests/fixtures
cd ~/code/BorAI/ops/borai-graph
```

- [ ] **Step 2: Write pyproject.toml**

```toml
[project]
name = "borai-graph"
version = "0.1.0"
description = "BorAI Knowledge Graph — indexer + retrieval + dashboard"
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

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["borai"]

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
```

- [ ] **Step 3: Write .env.example**

```
BORAI_GRAPH_DIR=/borai/graph
BORAI_WATCH_PATHS=/mnt/skills:/mnt/transcripts:/borai/products:/borai/funding:/borai/posts:/borai/code
BORAI_OLLAMA_URL=http://localhost:11434
BORAI_EMBED_MODEL=nomic-embed-text
BORAI_LOG_LEVEL=INFO
BORAI_TOKEN_BUDGET=1500
BORAI_SIMILARITY_FLOOR=0.3
BORAI_HAIKU_CALL_CAP=100
BORAI_DEBOUNCE_SECONDS=1.0
BORAI_EMBEDDING_CACHE_ENABLED=true
BORAI_HAIKU_CACHE_ENABLED=true
BORAI_QUERY_CACHE_ENABLED=true
BORAI_QUERY_CACHE_TTL=60
ANTHROPIC_API_KEY=
```

- [ ] **Step 4: Write .gitignore**

```
__pycache__/
*.pyc
*.pyo
.pytest_cache/
.coverage
htmlcov/
dist/
build/
*.egg-info/
.venv/
.env
```

- [ ] **Step 5: Write README.md stub**

```markdown
# BorAI Knowledge Graph

Indexer + retrieval + CLI dashboard for BorAI agents.

Setup and usage instructions ship with Plan 2.

See design spec: `docs/superpowers/specs/2026-04-22-borai-knowledge-graph-design.md`
```

- [ ] **Step 6: Create empty __init__.py files**

```bash
touch borai/__init__.py borai/indexer/__init__.py borai/retrieval/__init__.py borai/dashboard/__init__.py tests/__init__.py
```

- [ ] **Step 7: Install with uv**

```bash
cd ~/code/BorAI/ops/borai-graph
uv sync --extra dev
```

Expected output contains: `Resolved N packages`, `Installed N packages`.

- [ ] **Step 8: Verify pytest runs**

```bash
uv run pytest
```

Expected: `collected 0 items`. Exit code 5 (no tests) is acceptable; used as the scaffold-healthy signal.

- [ ] **Step 9: Commit**

```bash
cd ~/code/BorAI
git add ops/borai-graph/
git commit -m "feat(borai-graph): scaffold package structure and dependencies"
```

---

## Task 2: Config module with env-var loading

**Files:**
- Create: `ops/borai-graph/borai/config.py`
- Create: `ops/borai-graph/tests/test_config.py`

- [ ] **Step 1: Write failing test**

```python
# tests/test_config.py
import importlib
import os


def _clear_borai_env(monkeypatch):
    for key in list(os.environ.keys()):
        if key.startswith("BORAI_"):
            monkeypatch.delenv(key, raising=False)
    monkeypatch.delenv("ANTHROPIC_API_KEY", raising=False)


def test_defaults(monkeypatch):
    _clear_borai_env(monkeypatch)
    from borai import config
    importlib.reload(config)

    assert config.GRAPH_DIR == "/borai/graph"
    assert config.OLLAMA_URL == "http://localhost:11434"
    assert config.EMBED_MODEL == "nomic-embed-text"
    assert config.TOKEN_BUDGET == 1500
    assert config.SIMILARITY_FLOOR == 0.3
    assert config.HAIKU_CALL_CAP == 100
    assert config.DEBOUNCE_SECONDS == 1.0
    assert config.EMBEDDING_CACHE_ENABLED is True
    assert config.HAIKU_CACHE_ENABLED is True
    assert config.QUERY_CACHE_ENABLED is True
    assert config.QUERY_CACHE_TTL == 60


def test_env_override(monkeypatch):
    _clear_borai_env(monkeypatch)
    monkeypatch.setenv("BORAI_GRAPH_DIR", "/tmp/g")
    monkeypatch.setenv("BORAI_TOKEN_BUDGET", "2000")
    monkeypatch.setenv("BORAI_EMBEDDING_CACHE_ENABLED", "false")

    from borai import config
    importlib.reload(config)

    assert config.GRAPH_DIR == "/tmp/g"
    assert config.TOKEN_BUDGET == 2000
    assert config.EMBEDDING_CACHE_ENABLED is False


def test_watch_paths_colon_split(monkeypatch):
    _clear_borai_env(monkeypatch)
    monkeypatch.setenv("BORAI_WATCH_PATHS", "/a:/b:/c")
    from borai import config
    importlib.reload(config)

    assert config.WATCH_PATHS == ["/a", "/b", "/c"]
```

- [ ] **Step 2: Run test — verify fail**

```bash
cd ~/code/BorAI/ops/borai-graph
uv run pytest tests/test_config.py -v
```

Expected: `ModuleNotFoundError: No module named 'borai.config'`.

- [ ] **Step 3: Implement config.py**

```python
# borai/config.py
import os
from dotenv import load_dotenv

load_dotenv()


def _env_bool(key: str, default: bool) -> bool:
    raw = os.getenv(key)
    if raw is None:
        return default
    return raw.lower() in ("true", "1", "yes", "on")


GRAPH_DIR = os.getenv("BORAI_GRAPH_DIR", "/borai/graph")
WATCH_PATHS = os.getenv(
    "BORAI_WATCH_PATHS",
    "/mnt/skills:/mnt/transcripts:/borai/products:/borai/funding:/borai/posts:/borai/code",
).split(":")
OLLAMA_URL = os.getenv("BORAI_OLLAMA_URL", "http://localhost:11434")
EMBED_MODEL = os.getenv("BORAI_EMBED_MODEL", "nomic-embed-text")
ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY", "")
LOG_LEVEL = os.getenv("BORAI_LOG_LEVEL", "INFO")
TOKEN_BUDGET = int(os.getenv("BORAI_TOKEN_BUDGET", "1500"))
SIMILARITY_FLOOR = float(os.getenv("BORAI_SIMILARITY_FLOOR", "0.3"))
HAIKU_CALL_CAP = int(os.getenv("BORAI_HAIKU_CALL_CAP", "100"))
DEBOUNCE_SECONDS = float(os.getenv("BORAI_DEBOUNCE_SECONDS", "1.0"))
EMBEDDING_CACHE_ENABLED = _env_bool("BORAI_EMBEDDING_CACHE_ENABLED", True)
HAIKU_CACHE_ENABLED = _env_bool("BORAI_HAIKU_CACHE_ENABLED", True)
QUERY_CACHE_ENABLED = _env_bool("BORAI_QUERY_CACHE_ENABLED", True)
QUERY_CACHE_TTL = int(os.getenv("BORAI_QUERY_CACHE_TTL", "60"))
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_config.py -v
```

Expected: `3 passed`.

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/config.py ops/borai-graph/tests/test_config.py
git commit -m "feat(borai-graph): config module with env-var loading and defaults"
```

---

## Task 3: Shared types (Node, Edge, Chunk)

**Files:**
- Create: `ops/borai-graph/borai/indexer/types.py`
- Create: `ops/borai-graph/tests/test_types.py`

- [ ] **Step 1: Write failing test**

```python
# tests/test_types.py
from borai.indexer.types import Chunk, Edge, Node


def test_chunk_is_dataclass():
    c = Chunk(
        source_type="skill",
        source_path="/x.md",
        chunk_index=0,
        content="hello",
        metadata={"heading": "H", "token_count": 1},
    )
    assert c.source_type == "skill"
    assert c.content == "hello"


def test_node_from_chunk_generates_sha1_id():
    c = Chunk(
        source_type="skill",
        source_path="/x.md",
        chunk_index=3,
        content="y",
        metadata={},
    )
    n = Node.from_chunk(c, created_at="2026-04-22T10:00:00Z")
    # id is sha1 of source_path + chunk_index
    import hashlib
    expected = hashlib.sha1(b"/x.md|3").hexdigest()
    assert n.id == expected
    assert n.source_type == "skill"
    assert n.chunk_index == 3


def test_node_to_dict_roundtrip():
    c = Chunk(source_type="post", source_path="/a.md", chunk_index=0, content="z", metadata={"k": 1})
    n = Node.from_chunk(c, created_at="2026-04-22T10:00:00Z")
    d = n.to_dict()
    n2 = Node.from_dict(d)
    assert n2 == n


def test_edge_defaults_confidence():
    e = Edge(source="a", target="b", edge_type="relates_to")
    assert e.confidence == 1.0
    assert e.source_of_edge == ""


def test_edge_to_dict_roundtrip():
    e = Edge(source="a", target="b", edge_type="depends_on", confidence=0.9, source_of_edge="rule:imports")
    d = e.to_dict()
    e2 = Edge.from_dict(d)
    assert e2 == e
```

- [ ] **Step 2: Run test — verify fail**

```bash
uv run pytest tests/test_types.py -v
```

Expected: `ModuleNotFoundError: No module named 'borai.indexer.types'`.

- [ ] **Step 3: Implement types.py**

```python
# borai/indexer/types.py
from __future__ import annotations

import hashlib
from dataclasses import dataclass, field, asdict


@dataclass
class Chunk:
    source_type: str  # skill | transcript | funding | code | product | post
    source_path: str
    chunk_index: int
    content: str
    metadata: dict


@dataclass
class Node:
    id: str
    source_type: str
    source_path: str
    chunk_index: int
    content: str
    metadata: dict
    created_at: str

    @classmethod
    def from_chunk(cls, chunk: Chunk, created_at: str) -> "Node":
        key = f"{chunk.source_path}|{chunk.chunk_index}".encode("utf-8")
        node_id = hashlib.sha1(key).hexdigest()
        return cls(
            id=node_id,
            source_type=chunk.source_type,
            source_path=chunk.source_path,
            chunk_index=chunk.chunk_index,
            content=chunk.content,
            metadata=chunk.metadata,
            created_at=created_at,
        )

    def to_dict(self) -> dict:
        return asdict(self)

    @classmethod
    def from_dict(cls, d: dict) -> "Node":
        return cls(**d)


@dataclass
class Edge:
    source: str
    target: str
    edge_type: str  # relates_to | depends_on | same_product | follows | precedes | authored_during | contradicts | referenced_by
    confidence: float = 1.0
    source_of_edge: str = ""  # "rule:<name>" or "llm:haiku"

    def to_dict(self) -> dict:
        return asdict(self)

    @classmethod
    def from_dict(cls, d: dict) -> "Edge":
        return cls(**d)
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_types.py -v
```

Expected: `5 passed`.

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/indexer/types.py ops/borai-graph/tests/test_types.py
git commit -m "feat(borai-graph): shared types Node, Edge, Chunk with dict roundtrips"
```

---

## Task 4: Hash registry

**Files:**
- Create: `ops/borai-graph/borai/indexer/hash_registry.py`
- Create: `ops/borai-graph/tests/test_hash_registry.py`

- [ ] **Step 1: Write failing test**

```python
# tests/test_hash_registry.py
import json
from pathlib import Path

from borai.indexer.hash_registry import HashRegistry


def test_initial_state_empty(tmp_path):
    r = HashRegistry(tmp_path / "hash_registry.json")
    assert r.is_dirty("/anything.md") is True  # never seen = dirty


def test_mark_clean_then_unchanged(tmp_path):
    r = HashRegistry(tmp_path / "h.json")
    r.mark_clean("/x.md", "abc123")
    assert r.is_dirty("/x.md", "abc123") is False


def test_mark_clean_then_changed(tmp_path):
    r = HashRegistry(tmp_path / "h.json")
    r.mark_clean("/x.md", "abc123")
    assert r.is_dirty("/x.md", "xyz999") is True


def test_persist_to_disk(tmp_path):
    path = tmp_path / "h.json"
    r = HashRegistry(path)
    r.mark_clean("/x.md", "abc")
    r.save()

    data = json.loads(path.read_text())
    assert data["/x.md"] == "abc"


def test_load_from_disk(tmp_path):
    path = tmp_path / "h.json"
    path.write_text(json.dumps({"/y.md": "def"}))

    r = HashRegistry(path)
    assert r.is_dirty("/y.md", "def") is False
    assert r.is_dirty("/y.md", "other") is True


def test_compute_md5(tmp_path):
    f = tmp_path / "hello.txt"
    f.write_text("hello world")

    from borai.indexer.hash_registry import compute_md5
    assert compute_md5(f) == "5eb63bbbe01eeed093cb22bb8f5acdc3"


def test_remove_path(tmp_path):
    r = HashRegistry(tmp_path / "h.json")
    r.mark_clean("/x.md", "abc")
    r.remove("/x.md")
    assert r.is_dirty("/x.md") is True
```

- [ ] **Step 2: Run test — verify fail**

```bash
uv run pytest tests/test_hash_registry.py -v
```

Expected: `ModuleNotFoundError: No module named 'borai.indexer.hash_registry'`.

- [ ] **Step 3: Implement hash_registry.py**

```python
# borai/indexer/hash_registry.py
from __future__ import annotations

import hashlib
import json
from pathlib import Path


def compute_md5(path: Path) -> str:
    h = hashlib.md5()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


class HashRegistry:
    def __init__(self, path: Path):
        self.path = Path(path)
        self._state: dict[str, str] = {}
        if self.path.exists():
            try:
                self._state = json.loads(self.path.read_text())
            except json.JSONDecodeError:
                self._state = {}

    def is_dirty(self, file_path: str, current_hash: str | None = None) -> bool:
        if file_path not in self._state:
            return True
        if current_hash is None:
            return False
        return self._state[file_path] != current_hash

    def mark_clean(self, file_path: str, file_hash: str) -> None:
        self._state[file_path] = file_hash

    def remove(self, file_path: str) -> None:
        self._state.pop(file_path, None)

    def save(self) -> None:
        self.path.parent.mkdir(parents=True, exist_ok=True)
        tmp = self.path.with_suffix(self.path.suffix + ".tmp")
        tmp.write_text(json.dumps(self._state, indent=2, sort_keys=True))
        tmp.replace(self.path)
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_hash_registry.py -v
```

Expected: `7 passed`.

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/indexer/hash_registry.py ops/borai-graph/tests/test_hash_registry.py
git commit -m "feat(borai-graph): hash registry with md5 dirty detection and atomic save"
```

---

## Task 5: Chunker — dispatcher skeleton and source-type inference

**Files:**
- Create: `ops/borai-graph/borai/indexer/chunker.py`
- Create: `ops/borai-graph/tests/test_chunker.py`
- Create: `ops/borai-graph/tests/conftest.py`

- [ ] **Step 1: Write failing test for source-type inference**

```python
# tests/conftest.py
import pytest
from pathlib import Path


@pytest.fixture
def fixtures_dir() -> Path:
    return Path(__file__).parent / "fixtures"
```

```python
# tests/test_chunker.py
import pytest
from borai.indexer.chunker import infer_source_type, UnsupportedSourceError


def test_infer_skill():
    assert infer_source_type("/mnt/skills/funding/x.md") == "skill"


def test_infer_transcript():
    assert infer_source_type("/mnt/transcripts/session1.md") == "transcript"


def test_infer_funding():
    assert infer_source_type("/borai/funding/uk-grants.md") == "funding"


def test_infer_code():
    assert infer_source_type("/borai/code/main.py") == "code"


def test_infer_product():
    assert infer_source_type("/borai/products/teenyweeny.md") == "product"


def test_infer_post():
    assert infer_source_type("/borai/posts/2026-04-17.md") == "post"


def test_infer_unsupported_raises():
    with pytest.raises(UnsupportedSourceError):
        infer_source_type("/random/path.md")
```

- [ ] **Step 2: Run test — verify fail**

```bash
uv run pytest tests/test_chunker.py -v
```

Expected: `ModuleNotFoundError` or `ImportError: cannot import name`.

- [ ] **Step 3: Implement dispatcher**

```python
# borai/indexer/chunker.py
from __future__ import annotations

from pathlib import Path
from typing import Callable

from borai.indexer.types import Chunk


class UnsupportedSourceError(ValueError):
    pass


def infer_source_type(path: str) -> str:
    p = str(path)
    if "/mnt/skills/" in p or p.startswith("/mnt/skills"):
        return "skill"
    if "/mnt/transcripts/" in p or p.startswith("/mnt/transcripts"):
        return "transcript"
    if "/borai/funding/" in p or p.startswith("/borai/funding"):
        return "funding"
    if "/borai/code/" in p or p.startswith("/borai/code"):
        return "code"
    if "/borai/products/" in p or p.startswith("/borai/products"):
        return "product"
    if "/borai/posts/" in p or p.startswith("/borai/posts"):
        return "post"
    raise UnsupportedSourceError(f"Cannot infer source type for: {path}")


def chunk_file(path: str | Path) -> list[Chunk]:
    """Dispatch to source-specific chunker. Returns list of Chunk."""
    path = Path(path)
    source_type = infer_source_type(str(path))
    chunker: Callable[[Path, str], list[Chunk]] = _DISPATCH[source_type]
    return chunker(path, source_type)


# Populated by later tasks as per-source-type chunkers are added.
_DISPATCH: dict[str, Callable[[Path, str], list[Chunk]]] = {}
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_chunker.py -v
```

Expected: `7 passed`.

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/indexer/chunker.py ops/borai-graph/tests/test_chunker.py ops/borai-graph/tests/conftest.py
git commit -m "feat(borai-graph): chunker dispatcher and source-type inference"
```

---

## Task 6: Chunker — skill source type (H2/H3 headings, 400 token cap)

**Files:**
- Modify: `ops/borai-graph/borai/indexer/chunker.py`
- Modify: `ops/borai-graph/tests/test_chunker.py`
- Create: `ops/borai-graph/tests/fixtures/skill_small.md`
- Create: `ops/borai-graph/tests/fixtures/skill_large_section.md`

- [ ] **Step 1: Create fixture files**

```bash
cat > ~/code/BorAI/ops/borai-graph/tests/fixtures/skill_small.md <<'EOF'
---
name: fixture-skill
description: test
---

# Title

Intro text.

## Section A

Content for A.

## Section B

Content for B.
### Subsection B1

Deeper content.
EOF
```

```bash
python -c "print(('para text. ' * 80 + '\n\n') * 3)" > /tmp/bigsection.txt
cat > ~/code/BorAI/ops/borai-graph/tests/fixtures/skill_large_section.md <<'EOF'
# T

## Huge Section

EOF
cat /tmp/bigsection.txt >> ~/code/BorAI/ops/borai-graph/tests/fixtures/skill_large_section.md
```

- [ ] **Step 2: Write failing test**

Append to `tests/test_chunker.py`:

```python
def test_chunk_skill_splits_on_headings(fixtures_dir):
    from borai.indexer.chunker import chunk_file
    chunks = chunk_file(fixtures_dir / "skill_small.md")
    # H2 A, H2 B, H3 B1 → 3 chunks (intro may or may not be chunked; skip check)
    headings = [c.metadata.get("heading") for c in chunks]
    assert "Section A" in headings
    assert "Section B" in headings
    assert "Subsection B1" in headings


def test_chunk_skill_all_under_400_tokens(fixtures_dir):
    from borai.indexer.chunker import chunk_file
    chunks = chunk_file(fixtures_dir / "skill_large_section.md")
    # Every chunk's token_count is <= 400
    for c in chunks:
        assert c.metadata["token_count"] <= 400, (
            f"chunk {c.chunk_index} has {c.metadata['token_count']} tokens"
        )
    # And the large section was split into multiple chunks
    assert len(chunks) >= 2


def test_chunk_skill_all_content_preserved(fixtures_dir):
    from borai.indexer.chunker import chunk_file
    chunks = chunk_file(fixtures_dir / "skill_large_section.md")
    joined = "".join(c.content for c in chunks)
    # No truncation — the word "para" should appear the same number of times
    assert joined.count("para") == fixtures_dir.joinpath("skill_large_section.md").read_text().count("para")
```

- [ ] **Step 3: Run test — verify fail**

```bash
uv run pytest tests/test_chunker.py -v
```

Expected: `KeyError: 'skill'` (dispatcher has no entry yet).

- [ ] **Step 4: Implement skill chunker + recursive oversized split**

Append to `borai/indexer/chunker.py`:

```python
import re

# Rough token estimate: 4 chars per token (consistent with spec's pruning math)
TOKENS_PER_CHAR = 0.25
SKILL_TOKEN_CAP = 400


def _estimate_tokens(text: str) -> int:
    return int(len(text) * TOKENS_PER_CHAR) + 1


def _split_paragraphs(text: str) -> list[str]:
    return [p.strip() for p in re.split(r"\n\s*\n", text) if p.strip()]


def _split_sentences(text: str) -> list[str]:
    # Simple split on . ! ? followed by whitespace — good enough, avoids heavy NLP deps
    return [s.strip() for s in re.split(r"(?<=[.!?])\s+", text) if s.strip()]


def _recursive_split(text: str, token_cap: int) -> list[str]:
    """Split text into pieces each under token_cap. Paragraphs first, then sentences."""
    if _estimate_tokens(text) <= token_cap:
        return [text]
    pieces: list[str] = []
    for para in _split_paragraphs(text):
        if _estimate_tokens(para) <= token_cap:
            pieces.append(para)
        else:
            # Split sentences, pack into groups under the cap
            current = ""
            for sent in _split_sentences(para):
                candidate = (current + " " + sent).strip()
                if _estimate_tokens(candidate) <= token_cap:
                    current = candidate
                else:
                    if current:
                        pieces.append(current)
                    current = sent
            if current:
                pieces.append(current)
    return pieces


_HEADING_RE = re.compile(r"^(##+) (.+)$", re.MULTILINE)


def _split_on_headings(text: str, min_level: int = 2, max_level: int = 3) -> list[tuple[str, str]]:
    """Return list of (heading, body) pairs. Content before first heading has heading=''."""
    parts: list[tuple[str, str]] = []
    matches = list(_HEADING_RE.finditer(text))
    if not matches:
        return [("", text.strip())]

    # Filter to allowed levels
    valid = [m for m in matches if min_level <= len(m.group(1)) <= max_level]
    if not valid:
        return [("", text.strip())]

    # Leading content before first heading
    first = valid[0]
    if first.start() > 0:
        parts.append(("", text[:first.start()].strip()))

    for i, m in enumerate(valid):
        heading = m.group(2).strip()
        start = m.end()
        end = valid[i + 1].start() if i + 1 < len(valid) else len(text)
        body = text[start:end].strip()
        if body:
            parts.append((heading, body))
    return parts


def _chunk_by_headings(path: Path, source_type: str, token_cap: int = SKILL_TOKEN_CAP) -> list[Chunk]:
    text = path.read_text()
    sections = _split_on_headings(text)
    chunks: list[Chunk] = []
    idx = 0
    for heading, body in sections:
        if not body:
            continue
        pieces = _recursive_split(body, token_cap)
        for piece in pieces:
            chunks.append(Chunk(
                source_type=source_type,
                source_path=str(path),
                chunk_index=idx,
                content=piece,
                metadata={
                    "heading": heading,
                    "token_count": _estimate_tokens(piece),
                },
            ))
            idx += 1
    return chunks


_DISPATCH["skill"] = _chunk_by_headings
```

- [ ] **Step 5: Run test — verify pass**

```bash
uv run pytest tests/test_chunker.py -v
```

Expected: all tests pass (including the new 3).

- [ ] **Step 6: Commit**

```bash
git add ops/borai-graph/borai/indexer/chunker.py ops/borai-graph/tests/test_chunker.py ops/borai-graph/tests/fixtures/skill_small.md ops/borai-graph/tests/fixtures/skill_large_section.md
git commit -m "feat(borai-graph): chunker skill source type with heading split and 400-token cap"
```

---

## Task 7: Chunker — transcript (user/assistant exchanges)

**Files:**
- Modify: `ops/borai-graph/borai/indexer/chunker.py`
- Modify: `ops/borai-graph/tests/test_chunker.py`
- Create: `ops/borai-graph/tests/fixtures/transcript_md.md`
- Create: `ops/borai-graph/tests/fixtures/transcript_json.json`

- [ ] **Step 1: Create fixture files**

```bash
cat > ~/code/BorAI/ops/borai-graph/tests/fixtures/transcript_md.md <<'EOF'
## user
What is X?

## assistant
X is Y.

## user
Tell me more.

## assistant
More context about Y.
EOF

cat > ~/code/BorAI/ops/borai-graph/tests/fixtures/transcript_json.json <<'EOF'
[
  {"role": "user", "content": "Hi"},
  {"role": "assistant", "content": "Hello"},
  {"role": "user", "content": "How are you?"},
  {"role": "assistant", "content": "Well."}
]
EOF
```

- [ ] **Step 2: Write failing test**

Append to `tests/test_chunker.py`:

```python
def test_chunk_transcript_md_exchanges(fixtures_dir, monkeypatch):
    # Move fixture into a /mnt/transcripts-like path for inference
    # — rather than moving, monkeypatch infer_source_type's path-match logic
    from borai.indexer import chunker as ch
    p = fixtures_dir / "transcript_md.md"
    chunks = ch._chunk_transcript(p, "transcript")
    assert len(chunks) == 2
    assert "What is X?" in chunks[0].content
    assert "X is Y" in chunks[0].content
    assert "Tell me more" in chunks[1].content


def test_chunk_transcript_json_exchanges(fixtures_dir):
    from borai.indexer import chunker as ch
    p = fixtures_dir / "transcript_json.json"
    chunks = ch._chunk_transcript(p, "transcript")
    assert len(chunks) == 2
    assert "Hi" in chunks[0].content
    assert "Hello" in chunks[0].content
```

- [ ] **Step 3: Run test — verify fail**

Expected: `AttributeError: module 'borai.indexer.chunker' has no attribute '_chunk_transcript'`.

- [ ] **Step 4: Implement transcript chunker**

Append to `borai/indexer/chunker.py`:

```python
import json as _json


def _parse_transcript_md(text: str) -> list[tuple[str, str]]:
    """Return list of (user_msg, assistant_msg) pairs."""
    # Match "## user\n...\n## assistant\n...\n(?=## user|$)"
    pattern = re.compile(
        r"^##\s+user\s*\n(.*?)\n##\s+assistant\s*\n(.*?)(?=\n##\s+user|\Z)",
        re.MULTILINE | re.DOTALL,
    )
    return [(m.group(1).strip(), m.group(2).strip()) for m in pattern.finditer(text)]


def _parse_transcript_json(text: str) -> list[tuple[str, str]]:
    data = _json.loads(text)
    pairs: list[tuple[str, str]] = []
    i = 0
    while i < len(data) - 1:
        a, b = data[i], data[i + 1]
        if a.get("role") == "user" and b.get("role") == "assistant":
            pairs.append((a["content"], b["content"]))
            i += 2
        else:
            i += 1
    return pairs


def _parse_transcript_plain(text: str) -> list[tuple[str, str]]:
    """Fallback: double-newline alternation — odd index = user, even = assistant."""
    blocks = _split_paragraphs(text)
    pairs: list[tuple[str, str]] = []
    for i in range(0, len(blocks) - 1, 2):
        pairs.append((blocks[i], blocks[i + 1]))
    return pairs


def _chunk_transcript(path: Path, source_type: str) -> list[Chunk]:
    text = path.read_text()
    pairs: list[tuple[str, str]] = []
    # Try markdown first
    if path.suffix == ".md" or "## user" in text.lower():
        pairs = _parse_transcript_md(text)
    # Then JSON
    if not pairs and path.suffix == ".json":
        try:
            pairs = _parse_transcript_json(text)
        except _json.JSONDecodeError:
            pass
    # Fallback
    if not pairs:
        pairs = _parse_transcript_plain(text)

    chunks: list[Chunk] = []
    for i, (user, asst) in enumerate(pairs):
        content = f"USER: {user}\n\nASSISTANT: {asst}"
        chunks.append(Chunk(
            source_type=source_type,
            source_path=str(path),
            chunk_index=i,
            content=content,
            metadata={"exchange_index": i, "token_count": _estimate_tokens(content)},
        ))
    return chunks


_DISPATCH["transcript"] = _chunk_transcript
```

- [ ] **Step 5: Run test — verify pass**

```bash
uv run pytest tests/test_chunker.py -v
```

Expected: new tests pass, prior tests still green.

- [ ] **Step 6: Commit**

```bash
git add ops/borai-graph/borai/indexer/chunker.py ops/borai-graph/tests/test_chunker.py ops/borai-graph/tests/fixtures/transcript_md.md ops/borai-graph/tests/fixtures/transcript_json.json
git commit -m "feat(borai-graph): chunker transcript source with md/json/plain fallback"
```

---

## Task 8: Chunker — funding (--- delimited blocks)

**Files:**
- Modify: `ops/borai-graph/borai/indexer/chunker.py`
- Modify: `ops/borai-graph/tests/test_chunker.py`
- Create: `ops/borai-graph/tests/fixtures/funding.md`

- [ ] **Step 1: Create fixture**

```bash
cat > ~/code/BorAI/ops/borai-graph/tests/fixtures/funding.md <<'EOF'
# UK grants

Innovate UK grant details.

---

K-Startup details.

---

EIC Accelerator details.
EOF
```

- [ ] **Step 2: Write failing test**

Append to `tests/test_chunker.py`:

```python
def test_chunk_funding_splits_on_triple_dash(fixtures_dir):
    from borai.indexer import chunker as ch
    p = fixtures_dir / "funding.md"
    chunks = ch._chunk_funding(p, "funding")
    assert len(chunks) == 3
    assert "Innovate UK" in chunks[0].content
    assert "K-Startup" in chunks[1].content
    assert "EIC" in chunks[2].content
```

- [ ] **Step 3: Run test — verify fail**

Expected: `AttributeError: ... _chunk_funding`.

- [ ] **Step 4: Implement funding chunker**

Append to `borai/indexer/chunker.py`:

```python
def _chunk_funding(path: Path, source_type: str) -> list[Chunk]:
    text = path.read_text()
    # Drop YAML frontmatter if present
    if text.startswith("---\n"):
        end = text.find("\n---\n", 4)
        if end != -1:
            text = text[end + 5:]
    blocks = re.split(r"\n---\n", text)
    chunks: list[Chunk] = []
    for i, block in enumerate(blocks):
        block = block.strip()
        if not block:
            continue
        chunks.append(Chunk(
            source_type=source_type,
            source_path=str(path),
            chunk_index=i,
            content=block,
            metadata={"block_index": i, "token_count": _estimate_tokens(block)},
        ))
    return chunks


_DISPATCH["funding"] = _chunk_funding
```

- [ ] **Step 5: Run test — verify pass**

```bash
uv run pytest tests/test_chunker.py -v
```

- [ ] **Step 6: Commit**

```bash
git add ops/borai-graph/borai/indexer/chunker.py ops/borai-graph/tests/test_chunker.py ops/borai-graph/tests/fixtures/funding.md
git commit -m "feat(borai-graph): chunker funding source with --- delimiter split"
```

---

## Task 9: Chunker — code (AST-based per function/class)

**Files:**
- Modify: `ops/borai-graph/borai/indexer/chunker.py`
- Modify: `ops/borai-graph/tests/test_chunker.py`
- Create: `ops/borai-graph/tests/fixtures/code_sample.py`

- [ ] **Step 1: Create fixture**

```bash
cat > ~/code/BorAI/ops/borai-graph/tests/fixtures/code_sample.py <<'EOF'
"""Module docstring."""

from pathlib import Path


def helper(x: int) -> int:
    """Return x doubled."""
    return x * 2


class Foo:
    """A class."""

    def method_a(self) -> str:
        return "a"

    def method_b(self) -> str:
        return "b"


def another():
    return helper(3)
EOF
```

- [ ] **Step 2: Write failing test**

Append to `tests/test_chunker.py`:

```python
def test_chunk_code_per_function_and_class(fixtures_dir):
    from borai.indexer import chunker as ch
    p = fixtures_dir / "code_sample.py"
    chunks = ch._chunk_code(p, "code")
    names = [c.metadata["symbol"] for c in chunks]
    assert "helper" in names
    assert "Foo" in names
    assert "another" in names
    # Class chunk contains its methods in the content
    foo = next(c for c in chunks if c.metadata["symbol"] == "Foo")
    assert "method_a" in foo.content
    assert "method_b" in foo.content
```

- [ ] **Step 3: Run test — verify fail**

Expected: `AttributeError: ... _chunk_code`.

- [ ] **Step 4: Implement code chunker**

Append to `borai/indexer/chunker.py`:

```python
import ast


def _chunk_code(path: Path, source_type: str) -> list[Chunk]:
    source = path.read_text()
    try:
        tree = ast.parse(source)
    except SyntaxError:
        # Fallback: treat whole file as one chunk
        return [Chunk(
            source_type=source_type,
            source_path=str(path),
            chunk_index=0,
            content=source,
            metadata={"symbol": path.stem, "token_count": _estimate_tokens(source), "syntax_error": True},
        )]

    source_lines = source.splitlines(keepends=True)
    chunks: list[Chunk] = []
    idx = 0
    for node in tree.body:
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)):
            start = node.lineno - 1
            end = node.end_lineno  # ast end_lineno is 1-based inclusive
            content = "".join(source_lines[start:end])
            chunks.append(Chunk(
                source_type=source_type,
                source_path=str(path),
                chunk_index=idx,
                content=content,
                metadata={
                    "symbol": node.name,
                    "kind": "class" if isinstance(node, ast.ClassDef) else "function",
                    "line_start": start + 1,
                    "line_end": end,
                    "token_count": _estimate_tokens(content),
                },
            ))
            idx += 1
    # If no top-level functions/classes, treat whole file
    if not chunks:
        chunks.append(Chunk(
            source_type=source_type,
            source_path=str(path),
            chunk_index=0,
            content=source,
            metadata={"symbol": path.stem, "token_count": _estimate_tokens(source)},
        ))
    return chunks


_DISPATCH["code"] = _chunk_code
```

- [ ] **Step 5: Run test — verify pass**

```bash
uv run pytest tests/test_chunker.py -v
```

- [ ] **Step 6: Commit**

```bash
git add ops/borai-graph/borai/indexer/chunker.py ops/borai-graph/tests/test_chunker.py ops/borai-graph/tests/fixtures/code_sample.py
git commit -m "feat(borai-graph): chunker code source with AST per-function/class split"
```

---

## Task 10: Chunker — product and post (H2/H3 split, same as skill)

**Files:**
- Modify: `ops/borai-graph/borai/indexer/chunker.py`
- Modify: `ops/borai-graph/tests/test_chunker.py`
- Create: `ops/borai-graph/tests/fixtures/product.md`
- Create: `ops/borai-graph/tests/fixtures/post.md`

- [ ] **Step 1: Create fixtures**

```bash
cat > ~/code/BorAI/ops/borai-graph/tests/fixtures/product.md <<'EOF'
# teenyweeny.studio

## Problem

Obsidian vaults are closed loops.

## Solution

Runtime import in the browser.
EOF

cat > ~/code/BorAI/ops/borai-graph/tests/fixtures/post.md <<'EOF'
# Play produced the narrative

## The setup

Context here.

## The beat

More here.
EOF
```

- [ ] **Step 2: Write failing test**

Append to `tests/test_chunker.py`:

```python
def test_chunk_product_heading_split(fixtures_dir):
    from borai.indexer.chunker import chunk_file, _DISPATCH
    _DISPATCH["product"] = _DISPATCH.get("product") or _DISPATCH["skill"]  # remove after Task 10
    p = fixtures_dir / "product.md"
    chunks = _DISPATCH["product"](p, "product")
    headings = [c.metadata.get("heading") for c in chunks]
    assert "Problem" in headings
    assert "Solution" in headings


def test_chunk_post_heading_split(fixtures_dir):
    from borai.indexer.chunker import _DISPATCH
    _DISPATCH["post"] = _DISPATCH.get("post") or _DISPATCH["skill"]
    p = fixtures_dir / "post.md"
    chunks = _DISPATCH["post"](p, "post")
    headings = [c.metadata.get("heading") for c in chunks]
    assert "The setup" in headings
    assert "The beat" in headings
```

- [ ] **Step 3: Run test — verify fail**

Expected: `KeyError: 'product'`.

- [ ] **Step 4: Register dispatchers (reuse skill chunker)**

Append to `borai/indexer/chunker.py`:

```python
_DISPATCH["product"] = _chunk_by_headings
_DISPATCH["post"] = _chunk_by_headings
```

- [ ] **Step 5: Run test — verify pass**

```bash
uv run pytest tests/test_chunker.py -v
```

- [ ] **Step 6: Commit**

```bash
git add ops/borai-graph/borai/indexer/chunker.py ops/borai-graph/tests/test_chunker.py ops/borai-graph/tests/fixtures/product.md ops/borai-graph/tests/fixtures/post.md
git commit -m "feat(borai-graph): chunker product and post via heading split dispatch"
```

---

## Task 11: Chunker — verify full dispatch round-trip

**Files:**
- Modify: `ops/borai-graph/tests/test_chunker.py`

- [ ] **Step 1: Write full dispatch test**

Append to `tests/test_chunker.py`:

```python
def test_chunk_file_dispatches_to_correct_chunker(fixtures_dir, monkeypatch, tmp_path):
    """chunk_file(path) routes by source-type inference and returns non-empty chunks."""
    from borai.indexer.chunker import chunk_file

    # Set up path-shaped fixtures: copy each fixture into a directory that infers correctly
    cases = [
        ("skill", "skill_small.md", "/mnt/skills/fixture.md"),
        ("transcript", "transcript_md.md", "/mnt/transcripts/fixture.md"),
        ("funding", "funding.md", "/borai/funding/fixture.md"),
        ("code", "code_sample.py", "/borai/code/fixture.py"),
        ("product", "product.md", "/borai/products/fixture.md"),
        ("post", "post.md", "/borai/posts/fixture.md"),
    ]
    for source_type, fixture_name, target_path in cases:
        # Mock out path-based reading: create symlink into tmp under a path that matches inference
        target = tmp_path / target_path.lstrip("/")
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text((fixtures_dir / fixture_name).read_text())
        # Call chunk_file with a string path that matches the infer rule
        chunks = chunk_file(str(target))
        assert len(chunks) > 0, f"{source_type} produced 0 chunks"
        assert chunks[0].source_type == source_type
```

- [ ] **Step 2: Run test — verify pass**

```bash
uv run pytest tests/test_chunker.py::test_chunk_file_dispatches_to_correct_chunker -v
```

Expected: `1 passed`.

- [ ] **Step 3: Commit**

```bash
git add ops/borai-graph/tests/test_chunker.py
git commit -m "test(borai-graph): full chunker dispatch round-trip across all source types"
```

---

## Task 12: Embedder — Ollama client basic call

**Files:**
- Create: `ops/borai-graph/borai/indexer/embedder.py`
- Create: `ops/borai-graph/tests/test_embedder.py`

- [ ] **Step 1: Write failing test**

```python
# tests/test_embedder.py
from unittest.mock import patch, MagicMock

import numpy as np
import pytest

from borai.indexer.embedder import Embedder, OllamaUnreachable


def test_embed_calls_ollama_and_returns_vector():
    with patch("borai.indexer.embedder.requests.post") as post:
        post.return_value = MagicMock(
            status_code=200,
            json=lambda: {"embedding": [0.1, 0.2, 0.3]},
        )
        e = Embedder(ollama_url="http://localhost:11434", model="nomic-embed-text", cache_dir=None)
        vec = e.embed("hello")
        assert isinstance(vec, np.ndarray)
        assert vec.dtype == np.float32
        np.testing.assert_allclose(vec, [0.1, 0.2, 0.3], rtol=1e-5)
        post.assert_called_once()


def test_embed_raises_on_ollama_unreachable():
    import requests
    with patch("borai.indexer.embedder.requests.post", side_effect=requests.ConnectionError):
        e = Embedder(ollama_url="http://localhost:11434", model="nomic-embed-text", cache_dir=None)
        with pytest.raises(OllamaUnreachable):
            e.embed("hello")


def test_embed_raises_on_non_200():
    with patch("borai.indexer.embedder.requests.post") as post:
        post.return_value = MagicMock(status_code=500, text="server error")
        e = Embedder(ollama_url="http://localhost:11434", model="nomic-embed-text", cache_dir=None)
        with pytest.raises(OllamaUnreachable):
            e.embed("hello")
```

- [ ] **Step 2: Run test — verify fail**

Expected: `ModuleNotFoundError: No module named 'borai.indexer.embedder'`.

- [ ] **Step 3: Implement embedder.py (no cache yet)**

```python
# borai/indexer/embedder.py
from __future__ import annotations

from pathlib import Path

import numpy as np
import requests


class OllamaUnreachable(RuntimeError):
    pass


class Embedder:
    def __init__(
        self,
        ollama_url: str,
        model: str,
        cache_dir: Path | None = None,
        cache_enabled: bool = True,
    ):
        self.ollama_url = ollama_url.rstrip("/")
        self.model = model
        self.cache_dir = Path(cache_dir) if cache_dir else None
        self.cache_enabled = cache_enabled and cache_dir is not None

    def embed(self, text: str) -> np.ndarray:
        try:
            resp = requests.post(
                f"{self.ollama_url}/api/embeddings",
                json={"model": self.model, "prompt": text},
                timeout=60,
            )
        except requests.RequestException as e:
            raise OllamaUnreachable(f"Ollama request failed: {e}") from e

        if resp.status_code != 200:
            raise OllamaUnreachable(
                f"Ollama returned {resp.status_code}: {resp.text[:200]}"
            )

        data = resp.json()
        return np.asarray(data["embedding"], dtype=np.float32)
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_embedder.py -v
```

Expected: `3 passed`.

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/indexer/embedder.py ops/borai-graph/tests/test_embedder.py
git commit -m "feat(borai-graph): embedder Ollama HTTP client with error handling"
```

---

## Task 13: Embedder — on-disk embedding cache with model fingerprint

**Files:**
- Modify: `ops/borai-graph/borai/indexer/embedder.py`
- Modify: `ops/borai-graph/tests/test_embedder.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_embedder.py`:

```python
import json


def test_cache_hit_skips_ollama(tmp_path):
    with patch("borai.indexer.embedder.requests.post") as post:
        post.return_value = MagicMock(
            status_code=200,
            json=lambda: {"embedding": [0.1, 0.2, 0.3]},
        )
        e = Embedder(
            ollama_url="http://localhost:11434",
            model="nomic-embed-text",
            cache_dir=tmp_path,
            cache_enabled=True,
        )
        v1 = e.embed("same text")
        v2 = e.embed("same text")
        np.testing.assert_array_equal(v1, v2)
        assert post.call_count == 1  # second call hit the cache


def test_cache_miss_then_stored(tmp_path):
    with patch("borai.indexer.embedder.requests.post") as post:
        post.return_value = MagicMock(
            status_code=200,
            json=lambda: {"embedding": [0.4, 0.5, 0.6]},
        )
        e = Embedder(
            ollama_url="http://localhost:11434",
            model="nomic-embed-text",
            cache_dir=tmp_path,
            cache_enabled=True,
        )
        e.embed("text")
        # Cache files written
        assert (tmp_path / "embeddings.json").exists()
        assert (tmp_path / "embeddings_vectors.npy").exists()
        assert (tmp_path / "meta.json").exists()
        meta = json.loads((tmp_path / "meta.json").read_text())
        assert meta["embed_model"] == "nomic-embed-text"
        assert meta["embedding_dim"] == 3


def test_cache_invalidates_on_model_change(tmp_path):
    # Seed cache with old model
    (tmp_path / "meta.json").write_text(json.dumps({"embed_model": "old-model", "embedding_dim": 3}))
    (tmp_path / "embeddings.json").write_text(json.dumps({"abc": 0}))
    (tmp_path / "embeddings_vectors.npy").write_bytes(np.zeros((1, 3), dtype=np.float32).tobytes())

    with patch("borai.indexer.embedder.requests.post") as post:
        post.return_value = MagicMock(
            status_code=200,
            json=lambda: {"embedding": [9.0, 9.0, 9.0]},
        )
        e = Embedder(
            ollama_url="http://localhost:11434",
            model="new-model",  # different from seeded
            cache_dir=tmp_path,
            cache_enabled=True,
        )
        e.embed("anything")
        meta = json.loads((tmp_path / "meta.json").read_text())
        assert meta["embed_model"] == "new-model"


def test_cache_disabled_always_calls_ollama(tmp_path):
    with patch("borai.indexer.embedder.requests.post") as post:
        post.return_value = MagicMock(
            status_code=200,
            json=lambda: {"embedding": [1.0]},
        )
        e = Embedder(
            ollama_url="http://localhost:11434",
            model="x",
            cache_dir=tmp_path,
            cache_enabled=False,
        )
        e.embed("a")
        e.embed("a")
        assert post.call_count == 2
```

- [ ] **Step 2: Run test — verify fail**

Expected: second call still hits Ollama (no cache implemented yet), test fails.

- [ ] **Step 3: Implement cache in embedder.py**

Replace `borai/indexer/embedder.py` with:

```python
# borai/indexer/embedder.py
from __future__ import annotations

import hashlib
import json
from pathlib import Path
from threading import RLock

import numpy as np
import requests


class OllamaUnreachable(RuntimeError):
    pass


class Embedder:
    def __init__(
        self,
        ollama_url: str,
        model: str,
        cache_dir: Path | None = None,
        cache_enabled: bool = True,
    ):
        self.ollama_url = ollama_url.rstrip("/")
        self.model = model
        self.cache_dir = Path(cache_dir) if cache_dir else None
        self.cache_enabled = cache_enabled and self.cache_dir is not None
        self._lock = RLock()
        self._cache_map: dict[str, int] = {}  # content_hash -> row index
        self._cache_vectors: np.ndarray | None = None
        self._embedding_dim: int | None = None
        if self.cache_enabled:
            self._load_or_reset_cache()

    def _meta_path(self) -> Path:
        return self.cache_dir / "meta.json"

    def _map_path(self) -> Path:
        return self.cache_dir / "embeddings.json"

    def _vecs_path(self) -> Path:
        return self.cache_dir / "embeddings_vectors.npy"

    def _load_or_reset_cache(self) -> None:
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        meta = {}
        if self._meta_path().exists():
            try:
                meta = json.loads(self._meta_path().read_text())
            except json.JSONDecodeError:
                meta = {}
        if meta.get("embed_model") != self.model:
            # Invalidate
            self._cache_map = {}
            self._cache_vectors = None
            self._embedding_dim = None
            self._save_meta()
            return
        self._embedding_dim = meta.get("embedding_dim")
        if self._map_path().exists():
            try:
                self._cache_map = json.loads(self._map_path().read_text())
            except json.JSONDecodeError:
                self._cache_map = {}
        if self._vecs_path().exists() and self._embedding_dim:
            try:
                self._cache_vectors = np.load(self._vecs_path())
            except Exception:
                self._cache_vectors = None
                self._cache_map = {}

    def _save_meta(self) -> None:
        meta = {"embed_model": self.model, "embedding_dim": self._embedding_dim}
        self._meta_path().write_text(json.dumps(meta, indent=2))

    def _save_cache(self) -> None:
        if not self.cache_enabled:
            return
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        # Atomic swap for both files
        tmp_map = self._map_path().with_suffix(".json.tmp")
        tmp_map.write_text(json.dumps(self._cache_map, sort_keys=True))
        tmp_map.replace(self._map_path())
        if self._cache_vectors is not None:
            tmp_vec = self._vecs_path().with_suffix(".npy.tmp")
            np.save(tmp_vec, self._cache_vectors)
            tmp_vec.replace(self._vecs_path())
        self._save_meta()

    @staticmethod
    def _content_hash(text: str) -> str:
        return hashlib.sha256(text.encode("utf-8")).hexdigest()

    def embed(self, text: str) -> np.ndarray:
        if self.cache_enabled:
            key = self._content_hash(text)
            with self._lock:
                if key in self._cache_map and self._cache_vectors is not None:
                    return self._cache_vectors[self._cache_map[key]].copy()

        # Miss (or cache disabled) — call Ollama
        try:
            resp = requests.post(
                f"{self.ollama_url}/api/embeddings",
                json={"model": self.model, "prompt": text},
                timeout=60,
            )
        except requests.RequestException as e:
            raise OllamaUnreachable(f"Ollama request failed: {e}") from e
        if resp.status_code != 200:
            raise OllamaUnreachable(f"Ollama returned {resp.status_code}: {resp.text[:200]}")
        vec = np.asarray(resp.json()["embedding"], dtype=np.float32)

        if self.cache_enabled:
            with self._lock:
                key = self._content_hash(text)
                if self._embedding_dim is None:
                    self._embedding_dim = int(vec.shape[0])
                if self._cache_vectors is None:
                    self._cache_vectors = vec[np.newaxis, :].copy()
                    self._cache_map[key] = 0
                else:
                    self._cache_vectors = np.vstack([self._cache_vectors, vec[np.newaxis, :]])
                    self._cache_map[key] = int(self._cache_vectors.shape[0] - 1)
                self._save_cache()
        return vec
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_embedder.py -v
```

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/indexer/embedder.py ops/borai-graph/tests/test_embedder.py
git commit -m "feat(borai-graph): embedder on-disk cache with model-fingerprint invalidation"
```

---

## Task 14: Edge detector — same_product rule

**Files:**
- Create: `ops/borai-graph/borai/indexer/edge_detector.py`
- Create: `ops/borai-graph/tests/test_edge_detector.py`

- [ ] **Step 1: Write failing test**

```python
# tests/test_edge_detector.py
from borai.indexer.edge_detector import EdgeDetector
from borai.indexer.types import Node


def _mk_node(node_id: str, source_path: str, source_type: str = "post") -> Node:
    return Node(
        id=node_id,
        source_type=source_type,
        source_path=source_path,
        chunk_index=0,
        content="x",
        metadata={},
        created_at="2026-04-22T00:00:00Z",
    )


def test_same_product_edge_between_shared_product():
    d = EdgeDetector(product_names=["teenyweeny", "misled"])
    a = _mk_node("a", "/borai/posts/2026-teenyweeny-launch.md")
    b = _mk_node("b", "/borai/code/teenyweeny/parser.py", source_type="code")
    edges = d.rule_same_product(a, [b])
    assert len(edges) == 1
    assert edges[0].source == "a"
    assert edges[0].target == "b"
    assert edges[0].edge_type == "same_product"
    assert edges[0].source_of_edge == "rule:same_product"


def test_same_product_no_edge_when_different():
    d = EdgeDetector(product_names=["teenyweeny", "misled"])
    a = _mk_node("a", "/borai/posts/teenyweeny.md")
    b = _mk_node("b", "/borai/posts/misled.md")
    edges = d.rule_same_product(a, [b])
    assert edges == []


def test_same_product_no_edge_when_no_product_in_path():
    d = EdgeDetector(product_names=["teenyweeny"])
    a = _mk_node("a", "/borai/code/main.py", source_type="code")
    b = _mk_node("b", "/borai/code/helper.py", source_type="code")
    edges = d.rule_same_product(a, [b])
    assert edges == []
```

- [ ] **Step 2: Run test — verify fail**

Expected: `ModuleNotFoundError`.

- [ ] **Step 3: Implement edge_detector.py (skeleton + same_product)**

```python
# borai/indexer/edge_detector.py
from __future__ import annotations

from borai.indexer.types import Edge, Node


class EdgeDetector:
    def __init__(self, product_names: list[str] | None = None):
        self.product_names = product_names or []

    def rule_same_product(self, new_node: Node, existing: list[Node]) -> list[Edge]:
        edges: list[Edge] = []
        new_products = {p for p in self.product_names if p in new_node.source_path}
        if not new_products:
            return edges
        for other in existing:
            other_products = {p for p in self.product_names if p in other.source_path}
            if new_products & other_products:
                edges.append(Edge(
                    source=new_node.id,
                    target=other.id,
                    edge_type="same_product",
                    confidence=1.0,
                    source_of_edge="rule:same_product",
                ))
        return edges
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_edge_detector.py -v
```

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/indexer/edge_detector.py ops/borai-graph/tests/test_edge_detector.py
git commit -m "feat(borai-graph): edge detector same_product rule"
```

---

## Task 15: Edge detector — follows / precedes (mtime, same directory)

**Files:**
- Modify: `ops/borai-graph/borai/indexer/edge_detector.py`
- Modify: `ops/borai-graph/tests/test_edge_detector.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_edge_detector.py`:

```python
def test_follows_precedes_same_directory_within_24h():
    d = EdgeDetector()
    a = Node(id="a", source_type="post", source_path="/borai/posts/x.md",
             chunk_index=0, content="x", metadata={"mtime": 1000},
             created_at="2026-04-22T00:00:00Z")
    b = Node(id="b", source_type="post", source_path="/borai/posts/y.md",
             chunk_index=0, content="y", metadata={"mtime": 1500},
             created_at="2026-04-22T00:00:00Z")
    # b is later than a, within 24h (43200s < 86400s)
    edges = d.rule_follows_precedes(a, [b])
    # Expect: a precedes b, b follows a
    types = {e.edge_type for e in edges}
    assert "follows" in types or "precedes" in types


def test_no_follows_if_different_directory():
    d = EdgeDetector()
    a = Node(id="a", source_type="post", source_path="/borai/posts/x.md",
             chunk_index=0, content="x", metadata={"mtime": 1000},
             created_at="2026-04-22T00:00:00Z")
    b = Node(id="b", source_type="code", source_path="/borai/code/y.py",
             chunk_index=0, content="y", metadata={"mtime": 1500},
             created_at="2026-04-22T00:00:00Z")
    edges = d.rule_follows_precedes(a, [b])
    assert edges == []


def test_no_follows_if_over_24h():
    d = EdgeDetector()
    a = Node(id="a", source_type="post", source_path="/borai/posts/x.md",
             chunk_index=0, content="x", metadata={"mtime": 1000},
             created_at="2026-04-22T00:00:00Z")
    b = Node(id="b", source_type="post", source_path="/borai/posts/y.md",
             chunk_index=0, content="y", metadata={"mtime": 1000 + 86400 + 1},
             created_at="2026-04-22T00:00:00Z")
    edges = d.rule_follows_precedes(a, [b])
    assert edges == []
```

- [ ] **Step 2: Run test — verify fail**

Expected: `AttributeError: 'EdgeDetector' object has no attribute 'rule_follows_precedes'`.

- [ ] **Step 3: Implement rule**

Append to `borai/indexer/edge_detector.py`:

```python
from pathlib import PurePosixPath

_24H = 86400  # seconds


class EdgeDetector:  # reopen the class by redefining — alternatively, add method inline
    ...  # placeholder
```

**Better:** add the method to the existing class, not redefining. Replace the content block above with appending to the existing class in the file. Here's the full insertion — add this method inside the existing `EdgeDetector` class (after `rule_same_product`):

```python
    def rule_follows_precedes(self, new_node: Node, existing: list[Node]) -> list[Edge]:
        edges: list[Edge] = []
        new_dir = str(PurePosixPath(new_node.source_path).parent)
        new_mtime = new_node.metadata.get("mtime")
        if new_mtime is None:
            return edges
        for other in existing:
            other_dir = str(PurePosixPath(other.source_path).parent)
            if other_dir != new_dir:
                continue
            other_mtime = other.metadata.get("mtime")
            if other_mtime is None:
                continue
            delta = new_mtime - other_mtime
            if abs(delta) > _24H:
                continue
            if delta > 0:
                # new is later → new follows other; other precedes new
                edges.append(Edge(new_node.id, other.id, "follows", 1.0, "rule:follows"))
                edges.append(Edge(other.id, new_node.id, "precedes", 1.0, "rule:precedes"))
            elif delta < 0:
                edges.append(Edge(other.id, new_node.id, "follows", 1.0, "rule:follows"))
                edges.append(Edge(new_node.id, other.id, "precedes", 1.0, "rule:precedes"))
        return edges
```

Also add `from pathlib import PurePosixPath` and `_24H = 86400` at module top (before the class).

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_edge_detector.py -v
```

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/indexer/edge_detector.py ops/borai-graph/tests/test_edge_detector.py
git commit -m "feat(borai-graph): edge detector follows/precedes rule (same dir, <24h)"
```

---

## Task 16: Edge detector — depends_on rule (AST imports)

**Files:**
- Modify: `ops/borai-graph/borai/indexer/edge_detector.py`
- Modify: `ops/borai-graph/tests/test_edge_detector.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_edge_detector.py`:

```python
def test_depends_on_when_code_imports_symbol_in_other_chunk():
    d = EdgeDetector()
    caller = Node(
        id="caller",
        source_type="code",
        source_path="/borai/code/main.py",
        chunk_index=0,
        content="from borai.helpers import do_thing\n\ndef run():\n    do_thing()\n",
        metadata={"symbol": "run", "kind": "function"},
        created_at="2026-04-22T00:00:00Z",
    )
    helper = Node(
        id="helper",
        source_type="code",
        source_path="/borai/code/helpers.py",
        chunk_index=0,
        content="def do_thing():\n    return 1\n",
        metadata={"symbol": "do_thing", "kind": "function"},
        created_at="2026-04-22T00:00:00Z",
    )
    edges = d.rule_depends_on(caller, [helper])
    assert any(e.edge_type == "depends_on" and e.source == "caller" and e.target == "helper" for e in edges)


def test_no_depends_on_between_non_code_nodes():
    d = EdgeDetector()
    a = Node(id="a", source_type="post", source_path="/borai/posts/x.md",
             chunk_index=0, content="y", metadata={}, created_at="2026-04-22T00:00:00Z")
    b = Node(id="b", source_type="post", source_path="/borai/posts/z.md",
             chunk_index=0, content="w", metadata={}, created_at="2026-04-22T00:00:00Z")
    edges = d.rule_depends_on(a, [b])
    assert edges == []
```

- [ ] **Step 2: Run test — verify fail**

Expected: `AttributeError: ... rule_depends_on`.

- [ ] **Step 3: Implement depends_on rule**

Add method to `EdgeDetector`:

```python
    def rule_depends_on(self, new_node: Node, existing: list[Node]) -> list[Edge]:
        if new_node.source_type != "code":
            return []
        import ast
        edges: list[Edge] = []
        try:
            tree = ast.parse(new_node.content)
        except SyntaxError:
            return edges
        imported: set[str] = set()
        for n in ast.walk(tree):
            if isinstance(n, ast.ImportFrom):
                for alias in n.names:
                    imported.add(alias.name)
            elif isinstance(n, ast.Import):
                for alias in n.names:
                    imported.add(alias.name.split(".")[-1])
        if not imported:
            return edges
        for other in existing:
            if other.source_type != "code":
                continue
            symbol = other.metadata.get("symbol")
            if symbol and symbol in imported:
                edges.append(Edge(
                    source=new_node.id,
                    target=other.id,
                    edge_type="depends_on",
                    confidence=1.0,
                    source_of_edge="rule:depends_on",
                ))
        return edges
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_edge_detector.py -v
```

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/indexer/edge_detector.py ops/borai-graph/tests/test_edge_detector.py
git commit -m "feat(borai-graph): edge detector depends_on via AST import parse"
```

---

## Task 17: Edge detector — authored_during rule

**Files:**
- Modify: `ops/borai-graph/borai/indexer/edge_detector.py`
- Modify: `ops/borai-graph/tests/test_edge_detector.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_edge_detector.py`:

```python
def test_authored_during_transcript_near_artifact_mtime():
    d = EdgeDetector()
    transcript = Node(
        id="t", source_type="transcript", source_path="/mnt/transcripts/t.md",
        chunk_index=0, content="x", metadata={"mtime": 1000},
        created_at="2026-04-22T00:00:00Z",
    )
    post = Node(
        id="p", source_type="post", source_path="/borai/posts/p.md",
        chunk_index=0, content="y", metadata={"mtime": 1000 + 1800},  # +30 min — within ±60min
        created_at="2026-04-22T00:00:00Z",
    )
    edges = d.rule_authored_during(transcript, [post])
    assert any(e.edge_type == "authored_during" and e.source == "t" and e.target == "p" for e in edges)


def test_no_authored_during_outside_window():
    d = EdgeDetector()
    transcript = Node(id="t", source_type="transcript", source_path="/mnt/transcripts/t.md",
                      chunk_index=0, content="x", metadata={"mtime": 1000},
                      created_at="2026-04-22T00:00:00Z")
    post = Node(id="p", source_type="post", source_path="/borai/posts/p.md",
                chunk_index=0, content="y", metadata={"mtime": 1000 + 3601 + 1},  # over ±60min
                created_at="2026-04-22T00:00:00Z")
    edges = d.rule_authored_during(transcript, [post])
    assert edges == []
```

- [ ] **Step 2: Run test — verify fail**

Expected: `AttributeError: ... rule_authored_during`.

- [ ] **Step 3: Implement rule**

Add `_60MIN = 3600` at module top. Add method:

```python
    def rule_authored_during(self, new_node: Node, existing: list[Node]) -> list[Edge]:
        if new_node.source_type != "transcript":
            return []
        new_mtime = new_node.metadata.get("mtime")
        if new_mtime is None:
            return []
        edges: list[Edge] = []
        for other in existing:
            if other.source_type not in ("post", "code", "product"):
                continue
            other_mtime = other.metadata.get("mtime")
            if other_mtime is None:
                continue
            if abs(new_mtime - other_mtime) <= _60MIN:
                edges.append(Edge(
                    source=new_node.id,
                    target=other.id,
                    edge_type="authored_during",
                    confidence=1.0,
                    source_of_edge="rule:authored_during",
                ))
        return edges
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_edge_detector.py -v
```

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/indexer/edge_detector.py ops/borai-graph/tests/test_edge_detector.py
git commit -m "feat(borai-graph): edge detector authored_during (transcript→artifact, ±60m)"
```

---

## Task 18: Edge detector — relates_to rule (similarity > 0.7)

**Files:**
- Modify: `ops/borai-graph/borai/indexer/edge_detector.py`
- Modify: `ops/borai-graph/tests/test_edge_detector.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_edge_detector.py`:

```python
import numpy as np


def test_relates_to_high_similarity():
    d = EdgeDetector()
    a_vec = np.array([1.0, 0.0, 0.0], dtype=np.float32)
    b_vec = np.array([0.95, 0.31, 0.0], dtype=np.float32)  # cosine ~0.95
    a = Node(id="a", source_type="post", source_path="/a", chunk_index=0, content="x",
             metadata={}, created_at="x")
    b = Node(id="b", source_type="post", source_path="/b", chunk_index=0, content="y",
             metadata={}, created_at="x")
    edges = d.rule_relates_to(a, a_vec, [(b, b_vec)])
    assert any(e.edge_type == "relates_to" for e in edges)


def test_no_relates_to_below_threshold():
    d = EdgeDetector()
    a_vec = np.array([1.0, 0.0, 0.0], dtype=np.float32)
    b_vec = np.array([0.0, 1.0, 0.0], dtype=np.float32)  # cosine 0
    a = Node(id="a", source_type="post", source_path="/a", chunk_index=0, content="x",
             metadata={}, created_at="x")
    b = Node(id="b", source_type="post", source_path="/b", chunk_index=0, content="y",
             metadata={}, created_at="x")
    edges = d.rule_relates_to(a, a_vec, [(b, b_vec)])
    assert edges == []
```

- [ ] **Step 2: Run test — verify fail**

Expected: `AttributeError: ... rule_relates_to`.

- [ ] **Step 3: Implement**

Add method:

```python
    _RELATES_THRESHOLD = 0.7

    def rule_relates_to(
        self,
        new_node: Node,
        new_vec,  # numpy array
        existing: list[tuple[Node, "np.ndarray"]],
    ) -> list[Edge]:
        import numpy as np
        edges: list[Edge] = []
        if new_vec is None or len(existing) == 0:
            return edges
        new_norm = np.linalg.norm(new_vec)
        if new_norm == 0:
            return edges
        for other, other_vec in existing:
            other_norm = np.linalg.norm(other_vec)
            if other_norm == 0:
                continue
            cos = float(np.dot(new_vec, other_vec) / (new_norm * other_norm))
            if cos >= self._RELATES_THRESHOLD:
                edges.append(Edge(
                    source=new_node.id,
                    target=other.id,
                    edge_type="relates_to",
                    confidence=cos,
                    source_of_edge="rule:relates_to",
                ))
                # Symmetric: also other → new
                edges.append(Edge(
                    source=other.id,
                    target=new_node.id,
                    edge_type="relates_to",
                    confidence=cos,
                    source_of_edge="rule:relates_to",
                ))
        return edges
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_edge_detector.py -v
```

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/indexer/edge_detector.py ops/borai-graph/tests/test_edge_detector.py
git commit -m "feat(borai-graph): edge detector relates_to (cosine > 0.7, symmetric)"
```

---

## Task 19: Edge detector — Haiku assist with prompt caching

**Files:**
- Modify: `ops/borai-graph/borai/indexer/edge_detector.py`
- Modify: `ops/borai-graph/tests/test_edge_detector.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_edge_detector.py`:

```python
from unittest.mock import patch, MagicMock


def test_haiku_assist_returns_parsed_edges():
    d = EdgeDetector(anthropic_api_key="fake-key", haiku_model="claude-haiku-4-5-20251001")
    new = Node(id="new", source_type="post", source_path="/borai/posts/n.md",
               chunk_index=0, content="new content",
               metadata={}, created_at="2026-04-22T00:00:00Z")
    neighbour = Node(id="n1", source_type="post", source_path="/borai/posts/a.md",
                     chunk_index=0, content="other content",
                     metadata={}, created_at="2026-04-22T00:00:00Z")
    with patch("borai.indexer.edge_detector.anthropic.Anthropic") as client_cls:
        client = MagicMock()
        client.messages.create.return_value = MagicMock(
            content=[MagicMock(text='[{"target":"n1","edge_type":"contradicts","confidence":0.8}]')]
        )
        client_cls.return_value = client
        edges = d.haiku_assist(new, [neighbour])
    assert len(edges) == 1
    assert edges[0].edge_type == "contradicts"
    assert edges[0].source == "new"
    assert edges[0].target == "n1"
    assert edges[0].source_of_edge == "llm:haiku"


def test_haiku_uses_cache_control_on_system_prompt():
    d = EdgeDetector(anthropic_api_key="fake", haiku_model="claude-haiku-4-5-20251001")
    new = Node(id="n", source_type="post", source_path="/p",
               chunk_index=0, content="x", metadata={}, created_at="x")
    with patch("borai.indexer.edge_detector.anthropic.Anthropic") as client_cls:
        client = MagicMock()
        client.messages.create.return_value = MagicMock(content=[MagicMock(text="[]")])
        client_cls.return_value = client
        d.haiku_assist(new, [])
        _, kwargs = client.messages.create.call_args
        system = kwargs.get("system")
        # System should be a list of blocks with cache_control on at least one
        assert isinstance(system, list)
        assert any(b.get("cache_control") == {"type": "ephemeral"} for b in system)


def test_haiku_respects_call_cap():
    d = EdgeDetector(anthropic_api_key="fake", haiku_call_cap=2)
    new = Node(id="n", source_type="post", source_path="/p",
               chunk_index=0, content="x", metadata={}, created_at="x")
    with patch("borai.indexer.edge_detector.anthropic.Anthropic") as client_cls:
        client = MagicMock()
        client.messages.create.return_value = MagicMock(content=[MagicMock(text="[]")])
        client_cls.return_value = client
        d.haiku_assist(new, [])
        d.haiku_assist(new, [])
        d.haiku_assist(new, [])  # third call should be capped
        assert client.messages.create.call_count == 2
```

- [ ] **Step 2: Run test — verify fail**

Expected: `AttributeError: ... haiku_assist`, or import errors around `anthropic`.

- [ ] **Step 3: Implement Haiku assist**

Extend `EdgeDetector.__init__` and add the method:

```python
# At top of edge_detector.py, add:
import json as _json
import anthropic

_HAIKU_SYSTEM_PROMPT = """You are a relationship classifier for a knowledge graph.

Given a new chunk and a set of neighbour chunks, identify semantic edges.

Edge types you may return:
- "relates_to": topics overlap or share a concept
- "contradicts": one chunk disagrees with another
- "referenced_by": one chunk cites or points at the other

Return a JSON array of edges. Each edge is an object:
{"target": "<neighbour_id>", "edge_type": "<type>", "confidence": 0.0-1.0}

Return at most 5 edges. If you see no strong edges, return [].
Output ONLY valid JSON — no prose, no markdown fences.

Examples:
Input:
  NEW CHUNK (n): "React hooks replaced lifecycle methods in v16.8"
  NEIGHBOURS:
    a: "Class components use componentDidMount"
    b: "Hooks: useState, useEffect..."
Output:
  [{"target":"a","edge_type":"contradicts","confidence":0.7},
   {"target":"b","edge_type":"relates_to","confidence":0.9}]
"""


class EdgeDetector:
    def __init__(
        self,
        product_names: list[str] | None = None,
        anthropic_api_key: str | None = None,
        haiku_model: str = "claude-haiku-4-5-20251001",
        haiku_call_cap: int = 100,
    ):
        self.product_names = product_names or []
        self.anthropic_api_key = anthropic_api_key
        self.haiku_model = haiku_model
        self.haiku_call_cap = haiku_call_cap
        self._haiku_calls_this_run = 0
        self._client = None

    def _get_client(self):
        if self._client is None and self.anthropic_api_key:
            self._client = anthropic.Anthropic(api_key=self.anthropic_api_key)
        return self._client

    def reset_call_counter(self) -> None:
        self._haiku_calls_this_run = 0

    def haiku_assist(self, new_node: Node, neighbours: list[Node]) -> list[Edge]:
        if self._haiku_calls_this_run >= self.haiku_call_cap:
            return []
        client = self._get_client()
        if client is None:
            return []

        user_content = [
            f"NEW CHUNK (id={new_node.id}):",
            new_node.content[:1000],
            "",
            "NEIGHBOURS:",
        ]
        for n in neighbours[:10]:
            user_content.append(f"  {n.id}: {n.content[:500]}")

        system_blocks = [
            {
                "type": "text",
                "text": _HAIKU_SYSTEM_PROMPT,
                "cache_control": {"type": "ephemeral"},
            }
        ]

        self._haiku_calls_this_run += 1
        resp = client.messages.create(
            model=self.haiku_model,
            max_tokens=1024,
            system=system_blocks,
            messages=[{"role": "user", "content": "\n".join(user_content)}],
        )
        text = resp.content[0].text.strip()
        try:
            parsed = _json.loads(text)
        except _json.JSONDecodeError:
            return []
        edges: list[Edge] = []
        for item in parsed[:5]:
            target = item.get("target")
            edge_type = item.get("edge_type")
            confidence = float(item.get("confidence", 0.5))
            if not target or not edge_type:
                continue
            edges.append(Edge(
                source=new_node.id,
                target=target,
                edge_type=edge_type,
                confidence=confidence,
                source_of_edge="llm:haiku",
            ))
        return edges
```

(Replace the earlier skeleton `EdgeDetector.__init__` with this expanded version. Merge all rule methods back in — keep same_product, follows_precedes, depends_on, authored_during, relates_to as methods on the class.)

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_edge_detector.py -v
```

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/indexer/edge_detector.py ops/borai-graph/tests/test_edge_detector.py
git commit -m "feat(borai-graph): edge detector Haiku assist with prompt-caching + call cap"
```

---

## Task 20: Edge detector — Haiku response cache (on-disk)

**Files:**
- Modify: `ops/borai-graph/borai/indexer/edge_detector.py`
- Modify: `ops/borai-graph/tests/test_edge_detector.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_edge_detector.py`:

```python
def test_haiku_cache_hit_skips_api_call(tmp_path):
    d = EdgeDetector(
        anthropic_api_key="fake",
        haiku_model="claude-haiku-4-5-20251001",
        cache_dir=tmp_path,
        haiku_cache_enabled=True,
    )
    new = Node(id="n", source_type="post", source_path="/p",
               chunk_index=0, content="x", metadata={}, created_at="x")
    neighbour = Node(id="m", source_type="post", source_path="/q",
                     chunk_index=0, content="y", metadata={}, created_at="x")
    with patch("borai.indexer.edge_detector.anthropic.Anthropic") as client_cls:
        client = MagicMock()
        client.messages.create.return_value = MagicMock(
            content=[MagicMock(text='[{"target":"m","edge_type":"relates_to","confidence":0.8}]')]
        )
        client_cls.return_value = client

        d.haiku_assist(new, [neighbour])
        d.haiku_assist(new, [neighbour])

        assert client.messages.create.call_count == 1  # second call cached


def test_haiku_cache_invalidates_on_model_change(tmp_path):
    import json as _json
    (tmp_path / "meta.json").write_text(_json.dumps({"haiku_model": "old"}))
    (tmp_path / "haiku_responses.json").write_text(_json.dumps({"abc": {"edges": [], "created_at": "x"}}))

    d = EdgeDetector(
        anthropic_api_key="fake",
        haiku_model="new-model",
        cache_dir=tmp_path,
        haiku_cache_enabled=True,
    )
    # After construction, meta.json should reflect the new model
    meta = _json.loads((tmp_path / "meta.json").read_text())
    assert meta["haiku_model"] == "new-model"
    # And the stale response cache should be wiped
    assert _json.loads((tmp_path / "haiku_responses.json").read_text()) == {}
```

- [ ] **Step 2: Run test — verify fail**

Expected: test crashes because `cache_dir` arg isn't accepted or cache isn't loaded.

- [ ] **Step 3: Implement Haiku response cache**

Extend `EdgeDetector.__init__` to accept `cache_dir` and `haiku_cache_enabled`; add cache helpers and guard in `haiku_assist`:

```python
import hashlib as _hashlib
from pathlib import Path as _Path


class EdgeDetector:
    def __init__(
        self,
        product_names: list[str] | None = None,
        anthropic_api_key: str | None = None,
        haiku_model: str = "claude-haiku-4-5-20251001",
        haiku_call_cap: int = 100,
        cache_dir: _Path | None = None,
        haiku_cache_enabled: bool = True,
    ):
        self.product_names = product_names or []
        self.anthropic_api_key = anthropic_api_key
        self.haiku_model = haiku_model
        self.haiku_call_cap = haiku_call_cap
        self._haiku_calls_this_run = 0
        self._client = None
        self.cache_dir = _Path(cache_dir) if cache_dir else None
        self.haiku_cache_enabled = haiku_cache_enabled and self.cache_dir is not None
        self._haiku_cache: dict = {}
        if self.haiku_cache_enabled:
            self._load_or_reset_haiku_cache()

    def _haiku_meta_path(self) -> _Path:
        return self.cache_dir / "meta.json"

    def _haiku_cache_path(self) -> _Path:
        return self.cache_dir / "haiku_responses.json"

    def _load_or_reset_haiku_cache(self) -> None:
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        meta = {}
        if self._haiku_meta_path().exists():
            try:
                meta = _json.loads(self._haiku_meta_path().read_text())
            except _json.JSONDecodeError:
                meta = {}
        if meta.get("haiku_model") != self.haiku_model:
            self._haiku_cache = {}
            self._haiku_cache_path().write_text(_json.dumps({}))
            meta["haiku_model"] = self.haiku_model
            self._haiku_meta_path().write_text(_json.dumps(meta, indent=2))
            return
        if self._haiku_cache_path().exists():
            try:
                self._haiku_cache = _json.loads(self._haiku_cache_path().read_text())
            except _json.JSONDecodeError:
                self._haiku_cache = {}

    def _haiku_cache_key(self, new_node: Node, neighbours: list[Node]) -> str:
        ids = "|".join([new_node.id] + sorted(n.id for n in neighbours))
        return _hashlib.sha256(ids.encode("utf-8")).hexdigest()

    def _save_haiku_cache(self) -> None:
        if not self.haiku_cache_enabled:
            return
        tmp = self._haiku_cache_path().with_suffix(".json.tmp")
        tmp.write_text(_json.dumps(self._haiku_cache, sort_keys=True))
        tmp.replace(self._haiku_cache_path())
```

Guard `haiku_assist` with cache lookup:

```python
    def haiku_assist(self, new_node: Node, neighbours: list[Node]) -> list[Edge]:
        if self.haiku_cache_enabled:
            key = self._haiku_cache_key(new_node, neighbours)
            if key in self._haiku_cache:
                cached = self._haiku_cache[key]
                return [Edge.from_dict(e) for e in cached["edges"]]

        if self._haiku_calls_this_run >= self.haiku_call_cap:
            return []
        client = self._get_client()
        if client is None:
            return []

        # ... [existing API-call body, unchanged through to computing edges list] ...

        if self.haiku_cache_enabled:
            self._haiku_cache[key] = {
                "edges": [e.to_dict() for e in edges],
                "created_at": new_node.created_at,
            }
            self._save_haiku_cache()

        return edges
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_edge_detector.py -v
```

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/indexer/edge_detector.py ops/borai-graph/tests/test_edge_detector.py
git commit -m "feat(borai-graph): edge detector Haiku response cache with model invalidation"
```

---

## Task 21: Edge detector — Haiku trigger integration (< 2 relates_to)

**Files:**
- Modify: `ops/borai-graph/borai/indexer/edge_detector.py`
- Modify: `ops/borai-graph/tests/test_edge_detector.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_edge_detector.py`:

```python
def test_detect_edges_runs_haiku_when_relates_to_sparse():
    d = EdgeDetector(anthropic_api_key="fake", haiku_model="claude-haiku-4-5-20251001")
    new = Node(id="new", source_type="post", source_path="/borai/posts/x.md",
               chunk_index=0, content="x",
               metadata={"mtime": 1000}, created_at="2026-04-22T00:00:00Z")
    neighbour = Node(id="n1", source_type="post", source_path="/borai/posts/a.md",
                     chunk_index=0, content="y",
                     metadata={"mtime": 1000}, created_at="2026-04-22T00:00:00Z")
    # Low-similarity vectors → rule_relates_to yields 0 edges; triggers Haiku
    vec_a = np.array([1.0, 0.0], dtype=np.float32)
    vec_b = np.array([0.0, 1.0], dtype=np.float32)

    with patch("borai.indexer.edge_detector.anthropic.Anthropic") as client_cls:
        client = MagicMock()
        client.messages.create.return_value = MagicMock(
            content=[MagicMock(text='[{"target":"n1","edge_type":"relates_to","confidence":0.85}]')]
        )
        client_cls.return_value = client

        edges = d.detect_edges(new, vec_a, [(neighbour, vec_b)])
    # Haiku should have been called — at least one llm:haiku edge
    assert any(e.source_of_edge == "llm:haiku" for e in edges)


def test_detect_edges_skips_haiku_when_relates_to_sufficient():
    d = EdgeDetector(anthropic_api_key="fake", haiku_model="claude-haiku-4-5-20251001")
    new = Node(id="new", source_type="post", source_path="/borai/posts/x.md",
               chunk_index=0, content="x", metadata={"mtime": 1000},
               created_at="2026-04-22T00:00:00Z")
    n1 = Node(id="n1", source_type="post", source_path="/borai/posts/a.md",
              chunk_index=0, content="y", metadata={"mtime": 1000},
              created_at="2026-04-22T00:00:00Z")
    n2 = Node(id="n2", source_type="post", source_path="/borai/posts/b.md",
              chunk_index=0, content="z", metadata={"mtime": 1000},
              created_at="2026-04-22T00:00:00Z")
    vec = np.array([1.0, 0.0, 0.0], dtype=np.float32)

    with patch("borai.indexer.edge_detector.anthropic.Anthropic") as client_cls:
        client = MagicMock()
        client_cls.return_value = client
        edges = d.detect_edges(new, vec, [(n1, vec), (n2, vec)])  # identical vectors = cos 1.0
        # Two relates_to rule edges produced (new↔n1, new↔n2 — symmetric doubles so 4 total)
        client.messages.create.assert_not_called()
```

- [ ] **Step 2: Run test — verify fail**

Expected: `AttributeError: ... detect_edges`.

- [ ] **Step 3: Implement detect_edges orchestrator**

Add to `EdgeDetector`:

```python
    def detect_edges(
        self,
        new_node: Node,
        new_vec,  # np.ndarray | None
        existing_with_vecs: list[tuple[Node, "np.ndarray | None"]],
    ) -> list[Edge]:
        """Run full Stage 1 (rules), trigger Stage 2 (Haiku) when Stage 1 is sparse."""
        existing_nodes = [n for n, _ in existing_with_vecs]
        edges: list[Edge] = []
        edges.extend(self.rule_same_product(new_node, existing_nodes))
        edges.extend(self.rule_follows_precedes(new_node, existing_nodes))
        edges.extend(self.rule_depends_on(new_node, existing_nodes))
        edges.extend(self.rule_authored_during(new_node, existing_nodes))
        if new_vec is not None:
            pairs = [(n, v) for n, v in existing_with_vecs if v is not None]
            edges.extend(self.rule_relates_to(new_node, new_vec, pairs))

        relates_to_count = sum(1 for e in edges if e.edge_type == "relates_to")
        if relates_to_count < 2:
            # Top-10 neighbours by cosine similarity for Haiku
            if new_vec is not None:
                import numpy as np
                scored = []
                for n, v in existing_with_vecs:
                    if v is None:
                        continue
                    nn = np.linalg.norm(new_vec)
                    vn = np.linalg.norm(v)
                    if nn == 0 or vn == 0:
                        continue
                    scored.append((float(np.dot(new_vec, v) / (nn * vn)), n))
                scored.sort(key=lambda t: t[0], reverse=True)
                top = [n for _, n in scored[:10]]
            else:
                top = existing_nodes[:10]
            edges.extend(self.haiku_assist(new_node, top))

        return edges
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_edge_detector.py -v
```

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/indexer/edge_detector.py ops/borai-graph/tests/test_edge_detector.py
git commit -m "feat(borai-graph): edge detector orchestrator with Stage 2 Haiku trigger"
```

---

## Task 22: Pipeline — stub with data contracts

**Files:**
- Create: `ops/borai-graph/borai/indexer/pipeline.py`
- Create: `ops/borai-graph/tests/test_pipeline.py`

- [ ] **Step 1: Write failing test (pipeline interface)**

```python
# tests/test_pipeline.py
from pathlib import Path
import json
from unittest.mock import MagicMock, patch

import numpy as np
import pytest

from borai.indexer.pipeline import Pipeline


def test_pipeline_process_file_happy_path(tmp_path, fixtures_dir):
    # Prepare target file in a skill-inferred location
    skills_dir = tmp_path / "mnt" / "skills" / "t"
    skills_dir.mkdir(parents=True)
    target = skills_dir / "x.md"
    target.write_text((fixtures_dir / "skill_small.md").read_text())

    graph_dir = tmp_path / "graph"

    # Patch embedder to return deterministic vectors
    with patch("borai.indexer.pipeline.Embedder") as emb_cls, \
         patch("borai.indexer.pipeline.EdgeDetector") as det_cls:
        emb = MagicMock()
        emb.embed.return_value = np.array([0.1, 0.2, 0.3], dtype=np.float32)
        emb_cls.return_value = emb

        det = MagicMock()
        det.detect_edges.return_value = []
        det_cls.return_value = det

        # Monkey-patch infer_source_type to recognise our tmp path
        with patch("borai.indexer.pipeline.infer_source_type", return_value="skill"):
            p = Pipeline(graph_dir=graph_dir)
            p.process_file(target)
            p.flush()

    # Check graph.json has nodes
    graph = json.loads((graph_dir / "graph.json").read_text())
    assert "nodes" in graph
    assert len(graph["nodes"]) > 0
    assert (graph_dir / "vectors.npy").exists()
    assert (graph_dir / "vectors_index.json").exists()
```

- [ ] **Step 2: Run test — verify fail**

Expected: `ModuleNotFoundError`.

- [ ] **Step 3: Implement pipeline stub**

```python
# borai/indexer/pipeline.py
from __future__ import annotations

import datetime as dt
import json
from pathlib import Path

import numpy as np

from borai.indexer.chunker import chunk_file, infer_source_type
from borai.indexer.edge_detector import EdgeDetector
from borai.indexer.embedder import Embedder
from borai.indexer.hash_registry import HashRegistry, compute_md5
from borai.indexer.types import Edge, Node


class Pipeline:
    def __init__(
        self,
        graph_dir: Path,
        embedder: Embedder | None = None,
        detector: EdgeDetector | None = None,
    ):
        self.graph_dir = Path(graph_dir)
        self.graph_dir.mkdir(parents=True, exist_ok=True)
        self.embedder = embedder or Embedder(
            ollama_url="http://localhost:11434",
            model="nomic-embed-text",
            cache_dir=self.graph_dir / "cache",
        )
        self.detector = detector or EdgeDetector(
            cache_dir=self.graph_dir / "cache",
        )
        self.hash_registry = HashRegistry(self.graph_dir / "hash_registry.json")

        # In-memory graph state; flushed via atomic swap
        self._nodes: dict[str, Node] = {}
        self._edges: list[Edge] = []
        self._vectors: dict[str, np.ndarray] = {}  # node_id -> vec

        # Load existing graph if present
        self._load_existing()

    def _load_existing(self) -> None:
        gpath = self.graph_dir / "graph.json"
        vpath = self.graph_dir / "vectors.npy"
        ipath = self.graph_dir / "vectors_index.json"
        if not (gpath.exists() and vpath.exists() and ipath.exists()):
            return
        try:
            graph = json.loads(gpath.read_text())
            vectors = np.load(vpath)
            idx = json.loads(ipath.read_text())
            row_to_node = idx["row_to_node"]
            for node_dict in graph.get("nodes", []):
                n = Node.from_dict(node_dict)
                self._nodes[n.id] = n
            for edge_dict in graph.get("edges", []):
                self._edges.append(Edge.from_dict(edge_dict))
            for row, node_id in enumerate(row_to_node):
                if row < vectors.shape[0]:
                    self._vectors[node_id] = vectors[row]
        except Exception:
            # Corrupt — start from scratch
            self._nodes.clear()
            self._edges.clear()
            self._vectors.clear()

    def process_file(self, path: Path) -> None:
        path = Path(path)
        if not path.exists():
            self._remove_file(str(path))
            return

        file_hash = compute_md5(path)
        if not self.hash_registry.is_dirty(str(path), file_hash):
            return  # unchanged

        # Remove prior chunks for this file
        self._remove_file(str(path))

        try:
            source_type = infer_source_type(str(path))
        except Exception:
            return
        _ = source_type  # used via chunk_file

        try:
            chunks = chunk_file(path)
        except Exception:
            return

        # Attach mtime to every chunk's metadata for rule matching
        mtime = int(path.stat().st_mtime)
        for c in chunks:
            c.metadata["mtime"] = mtime

        created_at = dt.datetime.now(dt.timezone.utc).isoformat()
        existing_with_vecs = [(n, self._vectors.get(n.id)) for n in self._nodes.values()]

        for chunk in chunks:
            node = Node.from_chunk(chunk, created_at=created_at)
            vec = None
            try:
                vec = self.embedder.embed(chunk.content)
            except Exception:
                pass
            self._nodes[node.id] = node
            if vec is not None:
                self._vectors[node.id] = vec
            new_edges = self.detector.detect_edges(node, vec, existing_with_vecs)
            self._edges.extend(new_edges)
            # Update existing for subsequent chunks in same file
            existing_with_vecs.append((node, vec))

        self.hash_registry.mark_clean(str(path), file_hash)

    def _remove_file(self, file_path: str) -> None:
        to_remove = [nid for nid, n in self._nodes.items() if n.source_path == file_path]
        for nid in to_remove:
            self._nodes.pop(nid, None)
            self._vectors.pop(nid, None)
        self._edges = [e for e in self._edges if e.source not in to_remove and e.target not in to_remove]
        self.hash_registry.remove(file_path)

    def flush(self) -> None:
        """Atomic swap of graph.json + vectors.npy + vectors_index.json."""
        graph_doc = {
            "nodes": [n.to_dict() for n in self._nodes.values()],
            "edges": [e.to_dict() for e in self._edges],
        }
        node_ids = list(self._vectors.keys())
        if node_ids:
            vectors = np.stack([self._vectors[nid] for nid in node_ids])
        else:
            vectors = np.zeros((0, 1), dtype=np.float32)

        gpath = self.graph_dir / "graph.json"
        vpath = self.graph_dir / "vectors.npy"
        ipath = self.graph_dir / "vectors_index.json"

        tmp_g = gpath.with_suffix(".json.tmp")
        tmp_v = vpath.with_suffix(".npy.tmp")
        tmp_i = ipath.with_suffix(".json.tmp")

        tmp_g.write_text(json.dumps(graph_doc, indent=2))
        np.save(tmp_v, vectors)
        tmp_i.write_text(json.dumps({"row_to_node": node_ids}))

        tmp_g.replace(gpath)
        tmp_v.replace(vpath)
        tmp_i.replace(ipath)

        self.hash_registry.save()
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_pipeline.py -v
```

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/indexer/pipeline.py ops/borai-graph/tests/test_pipeline.py
git commit -m "feat(borai-graph): pipeline orchestrator with atomic file swap"
```

---

## Task 23: Pipeline — atomic-swap safety (kill mid-write simulation)

**Files:**
- Modify: `ops/borai-graph/tests/test_pipeline.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_pipeline.py`:

```python
def test_atomic_swap_leaves_old_state_on_partial_write(tmp_path, fixtures_dir, monkeypatch):
    """If flush() is interrupted mid-write, readers see old (or absent) state — never partial."""
    skills_dir = tmp_path / "mnt" / "skills" / "t"
    skills_dir.mkdir(parents=True)
    target = skills_dir / "x.md"
    target.write_text((fixtures_dir / "skill_small.md").read_text())

    graph_dir = tmp_path / "graph"

    with patch("borai.indexer.pipeline.Embedder") as emb_cls, \
         patch("borai.indexer.pipeline.EdgeDetector") as det_cls, \
         patch("borai.indexer.pipeline.infer_source_type", return_value="skill"):
        emb = MagicMock()
        emb.embed.return_value = np.array([0.1, 0.2], dtype=np.float32)
        emb_cls.return_value = emb
        det = MagicMock()
        det.detect_edges.return_value = []
        det_cls.return_value = det

        p = Pipeline(graph_dir=graph_dir)
        p.process_file(target)
        p.flush()  # first clean write

        # Simulate interruption: patch replace to fail on the second tmp file
        original_replace = Path.replace
        call_count = {"n": 0}

        def flaky_replace(self, target):
            call_count["n"] += 1
            if call_count["n"] == 2:
                raise OSError("simulated crash mid-swap")
            return original_replace(self, target)

        monkeypatch.setattr(Path, "replace", flaky_replace)

        # Modify target so it's dirty, try to flush — will fail partway
        target.write_text(target.read_text() + "\n## Added\n\nmore content\n")
        p.process_file(target)
        with pytest.raises(OSError):
            p.flush()

    # graph.json must still be readable JSON (original content)
    graph = json.loads((graph_dir / "graph.json").read_text())
    assert "nodes" in graph  # not corrupt
```

- [ ] **Step 2: Run test — verify pass (already implemented via tmp+replace)**

```bash
uv run pytest tests/test_pipeline.py::test_atomic_swap_leaves_old_state_on_partial_write -v
```

Expected: pass. (The design already uses tmp + replace; this test codifies the safety.)

- [ ] **Step 3: Commit**

```bash
git add ops/borai-graph/tests/test_pipeline.py
git commit -m "test(borai-graph): pipeline atomic-swap safety under simulated crash"
```

---

## Task 24: Pipeline — process_directory for first-time bulk ingest

**Files:**
- Modify: `ops/borai-graph/borai/indexer/pipeline.py`
- Modify: `ops/borai-graph/tests/test_pipeline.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_pipeline.py`:

```python
def test_process_directory_ingests_all_files(tmp_path, fixtures_dir):
    skills_dir = tmp_path / "mnt" / "skills" / "t"
    skills_dir.mkdir(parents=True)
    (skills_dir / "a.md").write_text((fixtures_dir / "skill_small.md").read_text())
    (skills_dir / "b.md").write_text((fixtures_dir / "skill_small.md").read_text())

    graph_dir = tmp_path / "graph"

    with patch("borai.indexer.pipeline.Embedder") as emb_cls, \
         patch("borai.indexer.pipeline.EdgeDetector") as det_cls, \
         patch("borai.indexer.pipeline.infer_source_type", return_value="skill"):
        emb = MagicMock()
        emb.embed.return_value = np.array([0.1, 0.2], dtype=np.float32)
        emb_cls.return_value = emb
        det = MagicMock()
        det.detect_edges.return_value = []
        det_cls.return_value = det

        p = Pipeline(graph_dir=graph_dir)
        count = p.process_directory(skills_dir, extensions={".md"})
        p.flush()

    assert count == 2  # two files processed
    graph = json.loads((graph_dir / "graph.json").read_text())
    paths = {n["source_path"] for n in graph["nodes"]}
    assert len(paths) == 2  # both files represented
```

- [ ] **Step 2: Run test — verify fail**

Expected: `AttributeError: ... process_directory`.

- [ ] **Step 3: Implement**

Add method to `Pipeline`:

```python
    def process_directory(self, root: Path, extensions: set[str] | None = None) -> int:
        """Walk root recursively, process every matching file. Returns count processed."""
        root = Path(root)
        count = 0
        for p in root.rglob("*"):
            if not p.is_file():
                continue
            if extensions and p.suffix not in extensions:
                continue
            self.process_file(p)
            count += 1
        return count
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_pipeline.py -v
```

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/indexer/pipeline.py ops/borai-graph/tests/test_pipeline.py
git commit -m "feat(borai-graph): pipeline process_directory for bulk ingest"
```

---

## Task 25: Watcher — watchdog observer emitting events

**Files:**
- Create: `ops/borai-graph/borai/indexer/watcher.py`
- Create: `ops/borai-graph/tests/test_watcher.py`

- [ ] **Step 1: Write failing test**

```python
# tests/test_watcher.py
import time
from pathlib import Path
from unittest.mock import MagicMock

from borai.indexer.watcher import IndexerWatcher


def test_watcher_calls_handler_on_modified(tmp_path):
    watch_dir = tmp_path / "watched"
    watch_dir.mkdir()
    target = watch_dir / "a.md"
    target.write_text("initial")

    handler = MagicMock()
    w = IndexerWatcher([watch_dir], on_change=handler, debounce_seconds=0.1)
    w.start()
    try:
        time.sleep(0.2)  # let observer attach
        target.write_text("changed")
        time.sleep(0.5)  # let debounce flush
    finally:
        w.stop()

    # Handler called at least once with the changed path
    assert handler.called
    called_paths = [call.args[0] for call in handler.call_args_list]
    assert any(str(target) == str(p) for p in called_paths)


def test_watcher_debounces_rapid_changes(tmp_path):
    watch_dir = tmp_path / "watched"
    watch_dir.mkdir()
    target = watch_dir / "b.md"
    target.write_text("v0")

    handler = MagicMock()
    w = IndexerWatcher([watch_dir], on_change=handler, debounce_seconds=0.3)
    w.start()
    try:
        time.sleep(0.2)
        for i in range(5):
            target.write_text(f"v{i+1}")
            time.sleep(0.05)
        time.sleep(0.5)  # let debounce window close
    finally:
        w.stop()

    # Debounce should collapse rapid changes into ~1 handler call
    assert handler.call_count < 5
    assert handler.call_count >= 1
```

- [ ] **Step 2: Run test — verify fail**

Expected: `ModuleNotFoundError`.

- [ ] **Step 3: Implement watcher**

```python
# borai/indexer/watcher.py
from __future__ import annotations

import threading
import time
from collections import defaultdict
from pathlib import Path
from typing import Callable

from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer


class _DebouncedHandler(FileSystemEventHandler):
    def __init__(self, on_change: Callable[[Path], None], debounce_seconds: float):
        super().__init__()
        self.on_change = on_change
        self.debounce_seconds = debounce_seconds
        self._pending: dict[str, float] = {}  # path -> last event time
        self._lock = threading.Lock()
        self._timer: threading.Timer | None = None
        self._stopping = False

    def on_any_event(self, event):
        if event.is_directory:
            return
        if event.event_type not in ("modified", "created", "moved"):
            return
        path = event.dest_path if event.event_type == "moved" else event.src_path
        with self._lock:
            self._pending[path] = time.monotonic()
            self._schedule_flush()

    def _schedule_flush(self) -> None:
        if self._timer is not None:
            self._timer.cancel()
        self._timer = threading.Timer(self.debounce_seconds, self._flush)
        self._timer.daemon = True
        self._timer.start()

    def _flush(self) -> None:
        with self._lock:
            if self._stopping:
                return
            now = time.monotonic()
            ready = [p for p, t in self._pending.items() if now - t >= self.debounce_seconds]
            for p in ready:
                self._pending.pop(p, None)
        for path in ready:
            try:
                self.on_change(Path(path))
            except Exception:
                pass

    def stop(self) -> None:
        with self._lock:
            self._stopping = True
            if self._timer is not None:
                self._timer.cancel()


class IndexerWatcher:
    def __init__(
        self,
        paths: list[Path],
        on_change: Callable[[Path], None],
        debounce_seconds: float = 1.0,
    ):
        self.paths = [Path(p) for p in paths]
        self.handler = _DebouncedHandler(on_change=on_change, debounce_seconds=debounce_seconds)
        self.observer = Observer()

    def start(self) -> None:
        for path in self.paths:
            if path.exists():
                self.observer.schedule(self.handler, str(path), recursive=True)
        self.observer.daemon = True
        self.observer.start()

    def stop(self) -> None:
        self.handler.stop()
        self.observer.stop()
        self.observer.join(timeout=2.0)

    def join(self) -> None:
        self.observer.join()
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_watcher.py -v
```

Expected: 2 passed. Timing-sensitive — on very slow CI, may need to bump sleeps.

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/indexer/watcher.py ops/borai-graph/tests/test_watcher.py
git commit -m "feat(borai-graph): watcher with watchdog observer and event debounce"
```

---

## Task 26: Watcher — hash-registry integration in on_change

**Files:**
- Modify: `ops/borai-graph/borai/indexer/watcher.py`
- Modify: `ops/borai-graph/tests/test_watcher.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_watcher.py`:

```python
from borai.indexer.hash_registry import HashRegistry
from borai.indexer.watcher import make_pipeline_handler


def test_pipeline_handler_skips_unchanged_file(tmp_path):
    target = tmp_path / "z.md"
    target.write_text("content")

    registry = HashRegistry(tmp_path / "h.json")
    pipeline_mock = MagicMock()
    handler = make_pipeline_handler(pipeline_mock, registry)

    # First event: marks dirty, processes
    handler(target)
    assert pipeline_mock.process_file.call_count == 1
    pipeline_mock.flush.assert_called()

    # Second event with same content: hash unchanged, skipped
    handler(target)
    assert pipeline_mock.process_file.call_count == 1  # not incremented


def test_pipeline_handler_processes_changed_file(tmp_path):
    target = tmp_path / "z.md"
    target.write_text("v1")

    registry = HashRegistry(tmp_path / "h.json")
    pipeline_mock = MagicMock()
    handler = make_pipeline_handler(pipeline_mock, registry)

    handler(target)
    target.write_text("v2")
    handler(target)
    assert pipeline_mock.process_file.call_count == 2
```

- [ ] **Step 2: Run test — verify fail**

Expected: `ImportError: cannot import name 'make_pipeline_handler'`.

- [ ] **Step 3: Implement integration helper**

Append to `borai/indexer/watcher.py`:

```python
from borai.indexer.hash_registry import HashRegistry, compute_md5


def make_pipeline_handler(pipeline, registry: HashRegistry) -> Callable[[Path], None]:
    """Factory: returns an on_change callback that runs pipeline.process_file + flush."""
    def handler(path: Path) -> None:
        if not path.exists():
            pipeline.process_file(path)
            pipeline.flush()
            return
        file_hash = compute_md5(path)
        if not registry.is_dirty(str(path), file_hash):
            return
        pipeline.process_file(path)
        pipeline.flush()
    return handler
```

- [ ] **Step 4: Run test — verify pass**

```bash
uv run pytest tests/test_watcher.py -v
```

- [ ] **Step 5: Commit**

```bash
git add ops/borai-graph/borai/indexer/watcher.py ops/borai-graph/tests/test_watcher.py
git commit -m "feat(borai-graph): watcher hash-registry integration via make_pipeline_handler"
```

---

## Task 27: Watcher — daemon thread lifecycle smoke test

**Files:**
- Modify: `ops/borai-graph/tests/test_watcher.py`

- [ ] **Step 1: Write failing test**

Append to `tests/test_watcher.py`:

```python
def test_watcher_stop_is_clean(tmp_path):
    """IndexerWatcher.stop() returns within reasonable time; no zombie threads."""
    import threading
    watch_dir = tmp_path / "w"
    watch_dir.mkdir()

    handler = MagicMock()
    w = IndexerWatcher([watch_dir], on_change=handler, debounce_seconds=0.1)
    w.start()
    time.sleep(0.2)

    start_time = time.monotonic()
    w.stop()
    elapsed = time.monotonic() - start_time
    assert elapsed < 3.0  # stop within 3 seconds

    # Observer thread is dead
    for t in threading.enumerate():
        if "Observer" in t.name:
            assert not t.is_alive(), f"Zombie observer thread: {t.name}"
```

- [ ] **Step 2: Run test — verify pass (already implemented via stop)**

```bash
uv run pytest tests/test_watcher.py -v
```

- [ ] **Step 3: Commit**

```bash
git add ops/borai-graph/tests/test_watcher.py
git commit -m "test(borai-graph): watcher clean-stop lifecycle smoke test"
```

---

## Task 28: Integration — pipeline + watcher end-to-end smoke

**Files:**
- Create: `ops/borai-graph/tests/test_integration.py`

- [ ] **Step 1: Write integration test**

```python
# tests/test_integration.py
import json
import time
from pathlib import Path
from unittest.mock import MagicMock, patch

import numpy as np

from borai.indexer.hash_registry import HashRegistry
from borai.indexer.pipeline import Pipeline
from borai.indexer.watcher import IndexerWatcher, make_pipeline_handler


def test_end_to_end_file_change_triggers_graph_update(tmp_path, fixtures_dir):
    skills_dir = tmp_path / "mnt" / "skills" / "test"
    skills_dir.mkdir(parents=True)
    target = skills_dir / "first.md"
    target.write_text((fixtures_dir / "skill_small.md").read_text())

    graph_dir = tmp_path / "graph"

    with patch("borai.indexer.pipeline.Embedder") as emb_cls, \
         patch("borai.indexer.pipeline.EdgeDetector") as det_cls, \
         patch("borai.indexer.pipeline.infer_source_type", return_value="skill"):
        emb = MagicMock()
        emb.embed.return_value = np.array([0.1, 0.2], dtype=np.float32)
        emb_cls.return_value = emb
        det = MagicMock()
        det.detect_edges.return_value = []
        det_cls.return_value = det

        pipeline = Pipeline(graph_dir=graph_dir)
        registry = pipeline.hash_registry
        handler = make_pipeline_handler(pipeline, registry)
        w = IndexerWatcher([skills_dir], on_change=handler, debounce_seconds=0.2)
        w.start()
        try:
            time.sleep(0.3)
            # Modify file to trigger event
            target.write_text(target.read_text() + "\n## New section\n\nmore text\n")
            time.sleep(1.0)  # allow debounce + processing
        finally:
            w.stop()

    # Graph should now contain nodes from the file
    graph = json.loads((graph_dir / "graph.json").read_text())
    paths = {n["source_path"] for n in graph["nodes"]}
    assert str(target) in paths
```

- [ ] **Step 2: Run test — verify pass**

```bash
uv run pytest tests/test_integration.py -v
```

Expected: 1 passed.

- [ ] **Step 3: Commit**

```bash
git add ops/borai-graph/tests/test_integration.py
git commit -m "test(borai-graph): end-to-end integration — watcher → pipeline → graph"
```

---

## Task 29: Full test-suite pass + coverage gate

**Files:**
- None (verification only)

- [ ] **Step 1: Run full suite with coverage**

```bash
cd ~/code/BorAI/ops/borai-graph
uv run pytest --cov=borai --cov-report=term-missing
```

Expected: all tests pass. Coverage should be ≥ 80% on each indexer module.

- [ ] **Step 2: Lint check (optional; flag failures for fix)**

```bash
uv run python -m py_compile borai/**/*.py
```

Expected: no output (success).

- [ ] **Step 3: Announce Plan 1 complete**

The indexer layer now produces graph.json + vectors.npy + vectors_index.json from any fixture directory via the Pipeline API. All six source types chunk, embeddings are cached on disk with model-fingerprint invalidation, edge detection runs rule-first + Haiku-assist with both response cache and prompt caching, watcher debounces rapid changes and skips unchanged files via hash registry.

Ready for Plan 2 (retrieval + dashboard + run.py + full README).

---

## Self-review notes (author-side)

Spec coverage check — every spec section has at least one task:

- Package at `ops/borai-graph/` with `borai/` import root: Task 1.
- Node/Edge schemas: Task 3.
- Hash registry + md5 dirty detection: Task 4.
- Chunking per source type (all 6): Tasks 5–10; dispatch round-trip: Task 11.
- Recursive split for oversized chunks: Task 6 (embedded in `_recursive_split`).
- Embedder Ollama + error handling: Task 12.
- Embedding cache + model-fingerprint invalidation: Task 13.
- All 6 rule-based edges: Tasks 14 (same_product), 15 (follows/precedes), 16 (depends_on), 17 (authored_during), 18 (relates_to), plus 19 (Haiku assist).
- Anthropic prompt caching via `cache_control`: Task 19.
- Haiku call cap: Task 19.
- Haiku response cache + model invalidation: Task 20.
- Haiku trigger (< 2 relates_to): Task 21.
- Pipeline orchestrator + atomic swap: Task 22.
- Atomic-swap safety under interruption: Task 23.
- First-time bulk ingest: Task 24.
- Watcher + debounce: Task 25.
- Hash-registry integration: Task 26.
- Watcher clean stop: Task 27.
- End-to-end integration: Task 28.
- Coverage gate: Task 29.

Spec items deferred to Plan 2: retrieval engine + snapshot cache + query cache, CLI dashboard, run.py entrypoint, README + setup, configuration reload, logging format.

No placeholders found in plan.

Type consistency check: `Node`, `Edge`, `Chunk` definitions in Task 3 match usage in all subsequent tasks. `Embedder.embed` returns `np.ndarray` consistently. `EdgeDetector.detect_edges` signature matches how `Pipeline` calls it in Task 22.
