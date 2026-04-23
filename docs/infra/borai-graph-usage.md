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

First run walks every watched path and indexes all `.md .txt .py .json .yaml` files. Subsequent runs are incremental (md5 hash skip).

Background run:

```bash
nohup uv run borai-graph > /home/onceuponaprince/borai/graph/logs/run.log 2>&1 &
```

Health check:

```bash
cd ~/code/BorAI-graph/ops/borai-graph && uv run borai-graph-stats
```

## Querying from a session

Use this one-liner inline. Replace `YOUR QUERY` and `AGENT_SLUG`.

```bash
cd ~/code/BorAI-graph/ops/borai-graph && uv run python -c "
from borai.retrieval.engine import RetrievalEngine
import json
engine = RetrievalEngine(graph_dir='/home/onceuponaprince/borai/graph')
results = engine.query(query_text='YOUR QUERY', agent='AGENT_SLUG', token_budget=1500)
print(json.dumps([{'path': r.source_path, 'rank': round(r.rank, 3), 'reason': r.reason, 'content': r.content[:400]} for r in results], indent=2))
"
```

### Agent slugs

| Skill                       | Slug                      | Edge scope                                     |
|-----------------------------|---------------------------|------------------------------------------------|
| build-in-public-engine      | `build_in_public_engine`  | authored_during, same_product, follows         |
| funding-tracker             | `funding_tracker`         | relates_to, same_product                       |
| hackathon-radar             | `hackathon_radar`         | relates_to, precedes                           |
| delegate-agent              | `delegate_agent`          | depends_on, relates_to                         |
| (any other / session work)  | `default`                 | relates_to                                     |

Unknown slugs fall back to `default` (`relates_to` only).

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
- **Query cache hit** → stale result until daemon next writes graph.json. Normally fine; set `BORAI_QUERY_CACHE_ENABLED=false` to debug.

Treat borai-graph as a **cache of prior context**, not a source of truth. The file on disk wins if they conflict.
