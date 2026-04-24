# A portable, self-hosted knowledge graph for solo-founder vaults: implementation review and design notes

*Implementation review of BorAI Knowledge Graph v1.0, shipped 2026-04-23 across PR #3 and PR #4 on `github.com/onceuponaprince/borai.cc`. Claims about external tools are cited where they are load-bearing to the argument.*

---

## Abstract

This paper documents the implementation of a Docker-wrapped retrieval-augmented generation system built over a markdown command-centre vault, tracing the motivation from corpus fragmentation in solo-founder workflows through the concrete design choices — rules-only edge detection, extension-fallback chunking, read-only bind mounts — to a tested 3,760-node, 1.6-million-edge index assembled in seventeen minutes of cold ingest time on commodity CPU. The aim is not to advance the state of retrieval systems; it is to demonstrate that a working knowledge graph can be written, dockerised, and handed to another human being inside a single working session, and that doing so materially rewires the founder's relationship to the corpus the system was authored against. Where the implementation departs from current best practice, the departure is named and the justification recorded.

**Keywords:** retrieval-augmented generation, knowledge graph, self-hosting, markdown vault, solo-founder tooling, docker-compose, Ollama, build-in-public

---

## 1. Introduction

A command-centre vault is a working space for a project. Scenes inside chapters inside campaigns; characters; templates; published artefacts; design specs; plans; handoffs; reference data for a dozen external systems. By day ninety, the founder has thousands of markdown files and no mechanism for recalling them beyond `grep` and muscle memory. The corpus becomes a library whose catalogue exists only as a lossy projection inside the founder's head. New scenes accrete context the old scenes already contained; the empire in their head diverges from the files on disk.

This paper reviews the implementation that closed that gap: an indexer that watches the vault, embeds its content via a locally-hosted model, detects structural and semantic edges between chunks, and exposes a retrieval engine scoped per-agent. The system ships as a docker-compose stack with read-only bind mounts and zero published ports. Total authored code: roughly 2,500 lines of Python plus ops scaffolding. Total paid-API dependency: zero.

The review is organised around five questions: why the graph was necessary, what shape it ended up with, what it changes for the agents that were already in flight, what remains unresolved, and what the act of shipping it meant for the founder — a question conventionally absent from implementation reviews, and conventionally louder for it.

## 2. Motivation: why a graph, why local, why now

Three pressures converged.

The first was recall failure. Scene 05 of Chapter 1 — a post about running two side-projects through shared workflow infrastructure — closed two days before the graph shipped. Its Conclude block contained lessons the founder would not have surfaced without re-reading the scene in full, because the relevant specs had been superseded under the forward-only-rename pattern and the old paths no longer appeared in search. The failure was not of writing. The writing was there. The failure was of retrieval.

The second was agent context starvation. The four agent-facing skills — `build-in-public-engine`, `funding-tracker`, `hackathon-radar`, `delegate-agent` — each generate substantive content (posts, staged events, delegated prompts) that ought to be informed by prior work. Without a graph, they were informed only by what the founder remembered to paste into the invocation. The cost of that omission compounds: each skill drafts in a vacuum, and each draft then lands in the vault as a new node that the next skill will also not see.

The third was the shipping-to-others pressure. The vault's thesis — *building a startup should feel like playing a game, and the act of playing it should produce the narrative that sells it* — presumes the game is playable by humans other than the author. An operating manual that cannot be handed to another founder is a closed system. Dockerising the graph was not an engineering preference. It was a statement about whose tool this is.

On the local-versus-hosted axis: at the corpus's present scale (3,760 chunks), a managed vector database is trivially cheaper in dollars than running Ollama on a laptop's electricity. Self-hosting only becomes cost-competitive with managed services in the range of 5M+ vectors or 1M+ queries per month [1]. The cost argument is therefore weaker than it sounds. The real argument is sovereignty. The vault contains commercially-sensitive material (spec drafts, funding eligibility notes, client handoffs) and personal material (visa status, founder profile, voice profile). Those files have no business living on a third-party SaaS, whatever the price per vector. Self-hosted Ollama running `nomic-embed-text` [2] produces adequate embeddings on consumer CPU, and the rent-equivalent cost of running it to the end of time is electricity.

## 3. Implementation review

### 3.1 Corpus shape

The mounted corpus at first-run indexing comprised three trees: the markdown vault at `~/code/build-in-public` (scenes, chapters, campaigns, characters, templates, docs, artefacts); the BorAI ops directory at `~/code/BorAI/ops` (the graph's own source, plus the AI-swarm infrastructure spec); and the user-level Claude Code skills at `~/.claude/commands` (the four agent skills named above, plus auxiliary commands such as `conclude`, `set-stage`, `new-scene`). Total indexable files: 142. Chunks produced: 3,760.

### 3.2 Ingestion pipeline

The pipeline is event-driven with a cold-start bulk ingest. On boot, `run.py` walks each watched root and calls `process_file` on every file matching `.md .txt .py .json .yaml`, skipping a small set of known-noise directories (`.venv`, `node_modules`, `.git`, `.obsidian`, `.pytest_cache`, and roughly twenty others). For each file, the chunker infers a source type by path first, extension second, splits by H2/H3 headings with a 400-token soft cap, and emits `Chunk` records.

The chunking strategy aligns with current best practice: header-based splitting for structured markdown is widely recommended as the single largest quality improvement available for documents with natural section boundaries, with recursive character splitting at 512 tokens with 50–100 tokens of overlap as the benchmark-validated default for unstructured text [3][4]. The 400-token cap is conservative relative to that benchmark; it reflects a deliberate preference for smaller, more granular chunks in a corpus where a single scene's Conclude block is often the minimal useful retrieval unit.

Each chunk is embedded via the locally-hosted Ollama model, cached on disk keyed by content hash, and assembled into a `Node` with source metadata. The edge detector runs rule-based checks (`same_product`, `same_author`, temporal neighbours) and a cosine-similarity `relates_to` check against existing vectors. A local `haiku_call_cap` would gate an LLM fallback if the Anthropic API key were set; in the production configuration it is not. Once the walk completes, the pipeline performs an atomic three-file swap — `graph.json`, `vectors.npy`, `vectors_index.json` — using a `.tmp.npy` suffix pattern to work around `numpy.save`'s silent extension-appending behaviour [5].

Post-bulk, the `watchdog` library [6] monitors the watched roots (using Linux `inotify` on this host) and re-processes individual files on change, with a one-second debounce. Each watch event flushes its own atomic swap, so the graph on disk is never more than ~1 second stale. Watchdog's `inotify` backend is limited by the kernel to 8192 watches per user by default — not a concern at this corpus size, but worth naming for multi-user deployments.

### 3.3 Retrieval engine

Query follows a four-stage pipeline: embed, seed, traverse, prune. The query string is embedded via the same Ollama backend. The top *k* seeds are selected by cosine similarity over the loaded vector snapshot, with a configurable floor (default 0.3) to drop weak matches. The scope of depth-1 traversal is determined by the agent slug — the four registered agents each have a different edge-type allowlist, reflecting what kind of neighbour is meaningful to them. Results are ranked (seeds by raw similarity, neighbours by `seed_sim × edge_confidence`) and pruned to a token budget using a 4-chars-per-token heuristic. A per-process TTL cache keyed by `(agent, query_text)` fronts the whole flow and is invalidated on snapshot reload.

### 3.4 Dockerisation

The stack comprises two services. Ollama runs from the official `ollama/ollama:0.4.4` image with a custom entrypoint that auto-pulls the configured embedding model on first boot and caches it in a named volume across restarts. The indexer runs from a multi-stage image: a builder stage fetches `uv` from the Astral distroless image and installs dependencies from `uv.lock` as a non-editable wheel; the runtime stage is Python 3.11-slim with a non-root user, a read-only root filesystem, dropped capabilities, `no-new-privileges`, and tmpfs mounts for the two writable directories the runtime needs.

The `--no-editable` flag is not optional here. uv installs project packages as editable by default, producing a `.pth` file that points at the source directory. In a multi-stage Docker build that copies only the venv across, the source directory does not exist at runtime and the package fails to import [7]. Switching to a non-editable install installs a real wheel inside the venv, which survives the copy.

Host content is mounted read-only into the indexer. The graph directory is the only read-write mount, and it is a named Docker volume rather than a host bind. Ollama is not published on the host; it is reachable only on the internal bridge network. Nothing in the stack can modify the host or be reached from outside. The hardening — `cap_drop: ALL`, `no-new-privileges: true`, `read_only: true`, tmpfs for the two writable paths the runtime needs — follows the OWASP Docker Security Cheat Sheet's minimum recommended posture for containers running inside trust boundaries [8]. It takes perhaps ten lines of compose configuration.

### 3.5 Portability fixes

The original chunker encoded source-type inference as a set of hardcoded path prefixes (`/mnt/skills/`, `/borai/code/`, etc.) reflecting an earlier assumed deployment layout. Mounting the vault at `/watch/vault` inside the container caused every file to be rejected with `UnsupportedSourceError`. The fix is an extension-based fallback: `.md .mdx .markdown .txt` become the new source type `note`, dispatching to the same heading-split chunker as `skill` and `product`; `.py .pyi` become `code`. Existing path rules win first, so prior deployments remain unchanged. Additionally, `process_directory` was reworked from a flat `rglob` walk into a prune-aware traversal that refuses to descend into `.venv` and its twenty-four known cousins — without which the first ingest against a real repo processed 2,111 files (of which 2,111 failed) in place of 142 real ones.

## 4. Status and tracking shape

At the end of the cold ingest against the production corpus:

| Metric | Value |
|---|---|
| Nodes | 3,760 |
| — by source | `note: 3,756`, `code: 4` |
| Edges | 1,604,734 |
| — by type | `follows: 735,443`, `precedes: 735,443`, `relates_to: 133,848`, `depends_on: 1` |
| Index last flushed | 2026-04-23T17:16:59+00:00 |
| Dirty files | 0 |
| Ingest duration | 17m 11s |
| Ollama health | reachable |

Three observations follow from the distribution.

First, the node-source ratio is extremely skewed toward `note`. This reflects the corpus honestly — the vault is markdown, the skills are markdown, the only indexed Python is the graph's own source. A future corpus including richer source code would shift the ratio; no action required until then.

Second, the edge density is conspicuous. `follows` and `precedes` account for 91.7% of all edges (1.47M of 1.60M). These are the temporal neighbours produced by the rule-based detector — every chunk within a file points forward and backward to its siblings, a dense but cheap signal. The GraphRAG literature is explicit that the retrieval quality of a knowledge graph depends on edges "reflecting semantic proximity and shared concepts" rather than raw structural proximity [9]. A 92%-temporal graph is, at best, an aggressive prior that sequential chunks are related; at worst, it dilutes the stronger `relates_to` signal by drowning it in neighbour-of-neighbour noise during depth-1 traversal. A follow-up experiment should run identical queries with `precedes` stripped from each agent's scope and measure whether the top-5 changes.

Third, the `depends_on: 1` is a curiosity. It suggests the rule that fires `depends_on` edges (reserved for `delegate_agent` traversal) is under-calibrated — possibly expecting patterns the vault does not contain, possibly a rule-ordering bug. Logged as a follow-up.

## 5. What changes for the existing framework

Before the graph, each of the four agent skills operated on whatever context the founder pasted into the invocation plus whatever the skill's own reference files contained. After the graph, each skill's workflow begins with a query.

- The **build-in-public engine** now queries for `<product-slug> + <post-topic>` under the `build_in_public_engine` agent scope (edges: `authored_during`, `same_product`, `follows`). A draft about shipping a waitlist for `airdrop-works` surfaces the archived content drafts, the voice-profile reference, and any prior scenes about the same product. The voice does not drift between posts because the voice itself is in the retrieved context.
- The **funding tracker** queries for `<region> + <programme type>` under `funding_tracker` scope (`relates_to`, `same_product`). Dedup against the BorAI inbox archive remains the authoritative check, but the graph supplements it by surfacing prior eligibility notes and founder-profile deltas.
- The **hackathon radar** queries for `<region> + <theme> + <platform>` under `hackathon_radar` scope (`relates_to`, `precedes`). It can now refuse to resurface opportunities the founder has already evaluated without re-reading the archive line by line.
- The **delegate-agent** queries only when the task being delegated is generative (specs, posts, multi-file code). The query surfaces relevant prior specs whose paths can be included in the delegation prompt, giving Gemini or Copilot the context that would otherwise require manual assembly.

None of this required rewriting the skills. Each skill gained a single new section — roughly fifteen lines — between *Required inputs* and *Workflow*. The graph is an inversion of control: rather than the founder feeding context into skills, the skills pull context from the graph.

The vault's `CLAUDE.md` gained a four-line section pointing at a usage document, which is itself load-bearing only when a session needs it. The rest of the vault is unchanged. This matters: the graph does not impose a new structure on the corpus. It indexes what is already there.

## 6. Pitfalls and critiques

**Temporal edge density is probably too high.** At 425 edges per node, depth-1 traversal risks drowning useful signals in neighbour-of-neighbour noise. The current token budget (1,500 per query) and rank function partially compensate by pruning low-scoring neighbours, but the more honest fix is to make `follows` / `precedes` directional and distance-capped so only the immediate sequential siblings participate, not the full within-file cross-product. This is the single most impactful refactor this system has left in it.

**`nomic-embed-text` is adequate, not state of the art.** On the MTEB benchmark, `nomic-embed-text` scores 62.39; `mxbai-embed-large` scores 64.68; `bge-m3` scores considerably higher on retrieval (~72% end-to-end in independent testing) thanks to its 568M parameters, larger context window, and multilingual training [10]. For an English-only, short-chunk corpus like this vault, `nomic-embed-text` is defensible. For a larger or multilingual corpus — the obvious extension once this ships to someone else — `bge-m3` would be a strictly better default. The switch is one environment variable (`BORAI_EMBED_MODEL=bge-m3`) plus a `docker compose pull ollama-models`.

**The Ollama API endpoint in use is the deprecated one.** The embedder calls `/api/embeddings`, which still works but has been superseded by `/api/embed` in recent Ollama releases. The newer endpoint returns L2-normalised vectors and accepts arrays of strings, enabling a batched-embedding fast path that would materially shorten the seventeen-minute cold-start ingest. Migration is straightforward; it simply has not been done.

**Rules-only edge detection loses the semantic layer.** The spec originally planned a Haiku fallback for pairs of chunks where rule evidence was thin (fewer than two `relates_to` edges). Running rules-only means certain useful relationships — thematic echoes across chapters, argumentative dependencies between specs that supersede each other — are simply not in the graph. The workaround of shelling out to Claude Code via subprocess is a legitimate follow-up spec; the trade-off is latency (single-digit seconds per invocation) against zero-marginal-cost. The implementation complication is that the subprocess would live on the host and the container would need to reach it; on Linux, this requires `extra_hosts: host.docker.internal:host-gateway` in the compose file, a nuance absent from Docker Desktop where `host.docker.internal` resolves by default [11].

**The hardcoded path rules survive.** The fix in §3.5 added a fallback but did not remove the original path-prefix rules. They are now redundant for anyone not running the original Docker-v1 layout. Deleting them is a five-minute change guarded by test updates; leaving them in creates quiet divergence risk as new source types are added.

**The stats CLI underreports.** `dirty_files` is hardcoded to zero in the read-only snapshot code path. This is documented as a deliberate choice in the source, because the snapshot cannot inspect the running pipeline's in-memory dirty set — but a live-dirty-count endpoint on the daemon, reachable via `docker compose exec`, would close the loop without violating the snapshot purity.

**Cold-start latency is user-hostile.** Seventeen minutes of ingest on consumer CPU is fine for a founder who knows what is happening. It is intolerable for a friend who cloned the repo to see what it does. A first-run progress indicator — even just a periodic "N/M files processed" INFO log at one-minute intervals during bulk ingest — would remove most of the anxiety without adding architectural complexity. Batched embedding via the newer `/api/embed` endpoint would additionally cut the absolute time.

**The docker-compose file assumes one user, one host.** Multi-user scenarios (household founders sharing a box, a team indexing a shared drive) would need either per-user volume namespacing or a light authentication layer in front of the retrieval engine. Neither exists. The scope of the current system is explicitly single-tenant.

## 7. Where we can build to from here

Three directions are live.

The first is **edge enrichment via Claude Code subprocess**. A small HTTP bridge on the host that accepts chunk pairs and returns JSON edge classifications, invoked from inside the container over `host.docker.internal` (with the Linux `host-gateway` mapping noted above). Cost: a few hundred lines of Python and a working Claude Code install on the host. Benefit: semantic edges at subscription prices rather than per-token API prices. The architectural subtlety is that the bridge holds the auth; the container stays hermetic.

The second is **a web UI for the retrieval engine**. The graph is queryable via Python one-liner today; that is adequate for a founder's own use and inadequate for anyone else. A small Next.js app on the same docker-compose network, proxying the retrieval engine and rendering results with source-path links and similarity scores, would make the graph a readable artefact rather than an invisible service. Three days of work, probably.

The third is **cross-vault federation**. Two founders running their own instances, with a shared read-only mount of a collaboration channel, indexing each other's consent-shared output into their own graphs. This is the direction that takes the system from solo tool to team tool. It is also the direction that introduces all the interesting privacy questions the single-user system gets to duck. Not a near-term build.

One non-direction: moving the stack to a managed cloud service. The whole point was that it runs locally, owns its own data, and costs nothing to operate. Re-platforming onto a hosted RAG provider would unwind every design choice in §3.

## 8. On shipping things that improve your own work

The conventional frame for this kind of work is *dogfooding* — building what you need, using what you build. The frame is correct but undersells the experience. What happens when a founder ships a tool for their own use is that the tool becomes part of the corpus the tool was built to serve. This paper, drafted in the vault that the graph now indexes, will be embedded and made queryable within seconds of being saved. By the next session, a query about "why we built the graph" will return this document as a top seed. The author has become a node in the author's own graph.

This produces a particular feeling that is difficult to simulate with client work or even open-source work. The founder is both writer and reader of an infinite game whose state is durable across sessions. The compounding is not notional — it is visible in the stats block at 17:17 every day, as new scenes added this morning show up in new queries this evening.

The cost to ship this was, frankly, low. Two merged PRs, 107 tests, a single working day. The cost *not* to ship it was a continuously degrading corpus that only the founder could navigate. Solo-founder work compounds only when the infrastructure compounds with it. The tool that indexes the notes is the tool that keeps the notes worth taking.

There is also, honestly, the matter of finishing something. Shipping is the only part of building that produces closure. A spec unfinished is a scene unclosed; a scene unclosed is a Conclude unwritten; a Conclude unwritten is a post undrafted. The graph earned its place in the system by being the first piece of infrastructure the vault ever pulled from rather than pushed to.

## 9. Conclusion

A local RAG over a markdown vault is not a novel artefact. Local RAGs exist in dozens of repositories, some more sophisticated than this one. The claim of this paper is narrower: that the *act of wrapping such a system in a shippable docker-compose package, hardening it to the minimum of host surface, and wiring it into an existing agent framework* turns a recall utility into a piece of load-bearing infrastructure for build-in-public work. The graph now in front of the founder is not the state of the art. It is the state of the vault — and that is the state that matters, because that is the corpus being built into.

The follow-up scenes will write themselves against it. That is the point.

---

## References

**External sources consulted during and after implementation:**

[1] OpenMetal, *When Self Hosting Vector Databases Becomes Cheaper Than SaaS*. openmetal.io. Establishes the ~5M-vector / 1M-queries-per-month crossover point where self-hosted infrastructure becomes cheaper than managed services.

[2] Ollama Library, *nomic-embed-text* model card. ollama.com/library/nomic-embed-text. 274 MB on disk; 2K context in v1 (v1.5 extends this); fp16 quantisation.

[3] Firecrawl, *Best Chunking Strategies for RAG (and LLMs) in 2026*. firecrawl.dev. Recursive character splitting at 512 tokens with 10–20% overlap is the benchmark-validated default for most RAG applications as of the 2026 Vecta benchmark across 50 academic papers.

[4] Weaviate, *Chunking Strategies to Improve LLM RAG Pipeline Performance*. weaviate.io. Recommends header-based splitting as the first move for structured markdown: "often the single biggest and easiest improvement you can make."

[5] NumPy v2.4 Manual, *numpy.save*. numpy.org/doc/stable/reference/generated/numpy.save.html. "If file is a string or Path, a .npy extension will be appended to the filename if it does not already have one." Silent.

[6] Watchdog PyPI package and documentation. pypi.org/project/watchdog. Uses `inotify` on Linux; max 8192 watches per user by default.

[7] Astral, *uv docs — Locking and syncing*. docs.astral.sh/uv/concepts/projects/sync. `--no-editable` opts out of the default editable install mode, which is necessary when the source tree is absent at runtime (multi-stage Docker builds).

[8] OWASP, *Docker Security Cheat Sheet*. cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html. Recommends the combination of `cap_drop: ALL`, `no-new-privileges: true`, and `read_only: true` for least-privilege container runtimes.

[9] Zhen, L. et al. (2025), *Knowledge Graph-Guided Retrieval Augmented Generation*. ACL Anthology 2025.naacl-long.449. On the role of semantic edge quality in RAG-over-graph retrieval.

[10] Zhang, C. (2026), *Which Embedding Model Should You Actually Use in 2026?* Independent benchmark of 10 embedding models. BGE-M3 at 568M parameters achieves ~72% retrieval accuracy, materially ahead of `nomic-embed-text` at 57–62% depending on chunk length.

[11] Baeldung, *The Equivalent of --add-host=host.docker.internal:host-gateway in Docker Compose*. baeldung.com/ops/docker-compose-add-host. Documents the Linux-specific `extra_hosts` mapping required for `host.docker.internal` resolution in containers running under plain Docker Engine (not Docker Desktop).

**Internal:**

- Design spec: `docs/superpowers/specs/2026-04-22-borai-knowledge-graph-design.md`
- Plan 1 (indexer): `docs/superpowers/plans/2026-04-22-borai-knowledge-graph-indexer.md`
- Plan 2 (retrieval, dashboard, run.py, README): `docs/superpowers/plans/2026-04-22-borai-knowledge-graph-retrieval.md`
- Usage doc: `docs/infra/borai-graph-usage.md`
- PR #3 (indexer + retrieval + dashboard): `github.com/onceuponaprince/borai.cc/pull/3`
- PR #4 (docker + starter kit): `github.com/onceuponaprince/borai.cc/pull/4`
- Conventional commit archaeology: `git log --oneline --first-parent main` from `022a07e` onwards.
