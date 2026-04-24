# borai-graph usage

Local RAG index over the vault, BorAI ops, and user-level skills. Query it before generating substantive content — it surfaces prior scenes, specs, plans, posts, and related product context you might otherwise miss.

## Where it lives

- **Code**: `~/code/BorAI-graph/ops/borai-graph/` (worktree of BorAI `main`).
- **Graph data**: `/home/onceuponaprince/borai/graph/` (override with `BORAI_GRAPH_DIR`).
- **Watched paths** (re-indexed on change):
  - `/home/onceuponaprince/code/build-in-public` — the vault
  - `/home/onceuponaprince/code/BorAI/ops` — BorAI ops (ai-swarm-infra, borai-graph itself)
  - `/home/onceuponaprince/.claude/commands` — user-level skills

## Running the daemon

```bash
cd ~/code/BorAI-graph/ops/borai-graph && uv run borai-graph
```

First run walks every watched path and indexes all `.md .txt .py .json .yaml` files. Subsequent runs are incremental (md5 hash skip). Progress logs fire every 60 s during bulk ingest.

Background run:

```bash
nohup uv run borai-graph > /home/onceuponaprince/borai/graph/logs/run.log 2>&1 &
```

Health check:

```bash
cd ~/code/BorAI-graph/ops/borai-graph && uv run borai-graph-stats
```

Tag inventory (what labels exist across the graph):

```bash
cd ~/code/BorAI-graph/ops/borai-graph && uv run borai-graph-tags --min-count 5
cd ~/code/BorAI-graph/ops/borai-graph && uv run borai-graph-tags --prefix chapter:
```

## Querying from a session

`query()` defaults to **shallow mode** — it returns `ShallowResult` objects with `source_path`, `chunk_index`, `tags`, `rank`, `reason`, and an `expand_handle`, but no body text. Call `engine.expand(handle)` on a shallow result to fetch its full content.

### Shallow mode (default — surface names first)

Use this when you want to see candidates, scan tags, and selectively expand. Cheap on tokens.

```bash
cd ~/code/BorAI-graph/ops/borai-graph && uv run python -c "
from borai.retrieval.engine import RetrievalEngine
import json
engine = RetrievalEngine(graph_dir='/home/onceuponaprince/borai/graph')
results = engine.query(query_text='YOUR QUERY', agent='AGENT_SLUG', token_budget=1500)
print(json.dumps([
    {'path': r.source_path, 'chunk': r.chunk_index, 'rank': round(r.rank, 3),
     'reason': r.reason, 'tags': r.tags[:4], 'handle': r.expand_handle}
    for r in results
], indent=2))
"
```

Expand a single handle:

```bash
cd ~/code/BorAI-graph/ops/borai-graph && uv run python -c "
from borai.retrieval.engine import RetrievalEngine
engine = RetrievalEngine(graph_dir='/home/onceuponaprince/borai/graph')
full = engine.expand('PASTE_HANDLE_HERE')
print(full.content if full else 'no such handle')
"
```

### Full mode (everything in one call)

Use this when you want bodies immediately — most of the registered skills run in this mode because their downstream logic needs the text.

```bash
cd ~/code/BorAI-graph/ops/borai-graph && uv run python -c "
from borai.retrieval.engine import RetrievalEngine
import json
engine = RetrievalEngine(graph_dir='/home/onceuponaprince/borai/graph')
results = engine.query(query_text='YOUR QUERY', agent='AGENT_SLUG', token_budget=1500, mode='full')
print(json.dumps([
    {'path': r.source_path, 'rank': round(r.rank, 3), 'reason': r.reason, 'content': r.content[:400]}
    for r in results
], indent=2))
"
```

### Readable `reason` strings

The `reason` field is terse by default (`seed:similarity=0.61`, `neighbour:near via <id>`). For human-readable explanations, use the explain helper:

```python
from borai.retrieval.explain import explain
print(explain(result, snapshot=engine.snapshot))
# → "Adjacent chunk in scenes/03-near.md (chunk 490)."
```

## What each retrieval mechanism does

| Mechanism     | Stored?  | When it fires                                                    |
|---------------|----------|------------------------------------------------------------------|
| `seed`        | n/a      | Direct similarity match between query and chunk embedding.       |
| `near`        | yes      | Chunks that sit literally next to each other in the same file.  |
| `proximal`    | computed | Same-file siblings at chunk_index distance > 1. Always on.       |
| `relates_to`  | yes      | Semantically similar chunks elsewhere (cosine ≥ 0.7).            |
| `same_product`| yes      | Chunks whose paths mention the same product name.                |
| `depends_on`  | yes      | Python import-based dependency between code chunks.              |
| `authored_during` | yes  | Transcript + post/code/product authored within 60 min of each other. |

Proximal relevance = `α·(1/d) + (1−α)·cos(seed, target)`. α is per-agent (see below) with `PROXIMAL_ALPHA = 0.5` as the default for unknown agents.

## Agent slugs

| Skill                       | Slug                      | Edge scope                                     | Proximal α |
|-----------------------------|---------------------------|------------------------------------------------|------------|
| build-in-public-engine      | `build_in_public_engine`  | `authored_during`, `same_product`, `near`     | 0.3        |
| funding-tracker             | `funding_tracker`         | `relates_to`, `same_product`, `near`          | 0.95       |
| hackathon-radar             | `hackathon_radar`         | `relates_to`, `near`                           | 0.5        |
| delegate-agent              | `delegate_agent`          | `depends_on`, `relates_to`, `near`            | 0.5        |
| (any other / session work)  | `default`                 | `relates_to`, `near`                           | 0.5        |

Unknown slugs fall back to `default` scope and the global 0.5 α. `proximal` is not scope-gated — it fires on every query regardless of agent.

## The tag system

Every chunk carries a `tags` list in its metadata, split across two layers:

- **Author layer**: whatever you wrote in the YAML frontmatter's `tags:` list. Sovereign — you own these.
- **Minted layer**: reserved-prefix tags the indexer computes from path + frontmatter: `source_type:`, `chapter:`, `campaign:`, `status:`, and `block:` (for scene blocks). Author tags using these prefixes are stripped at ingest — the minted layer wins.

Scene files get extra structure: the chunker splits them by named block (`Set Stage`, `Progress the moment`, `Pivot`, `Conclude`, `Notes`) and mints a `block:<name>` tag on each chunk. So `block:conclude` + `chapter:02a-systems-and-tools` is a valid narrow query surface.

Query by tag directly (bypassing embeddings) via `snapshot.nodes_with_tag(tag)`:

```python
engine = RetrievalEngine(graph_dir='/home/onceuponaprince/borai/graph')
conclude_nodes = engine.snapshot.nodes_with_tag('block:conclude')
in_progress = engine.snapshot.nodes_with_tag('status:in-progress')
```

## When to query

- **Before** drafting a scene's Set Stage block (load prior scene Concludes + related specs).
- **Before** running any of the four registered skills — the skills' own instructions include a query step.
- **Before** answering questions that may have been answered before ("what did we decide about X", "when did we ship Y").
- **Before** proposing architecture — surface any prior spec that supersedes.

Don't query for:
- Trivial lookups (`ls`, `git status`).
- Work where the live file is the source of truth and cheaper to read directly.
- When the graph returned nothing on a previous query this session (it won't on a re-query of the same text).

## When it fails gracefully

- **Daemon not running** → graph is stale but still readable. Stats CLI shows `last_updated`.
- **Ollama not running** → query fails to embed. Nothing returned. Start Ollama, retry.
- **Graph empty / missing** → `RetrievalEngine.query` returns `[]`. Proceed without, note it in your reasoning.
- **Query cache hit** → stale result until daemon next writes graph.json. Cache key includes mode, so shallow and full queries don't cross-contaminate. Set `BORAI_QUERY_CACHE_ENABLED=false` to debug.
- **Unknown agent slug** → falls back to `default` scope. No error; results are just narrower.

Treat borai-graph as a **cache of prior context**, not a source of truth. The file on disk wins if they conflict.
