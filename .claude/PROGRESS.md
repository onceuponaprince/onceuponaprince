# Session handoff — 2026-04-24 close · scene 2a-03 shipped + five parallel additions · next strategic step is search-quality work

Read BEFORE the standard session-open ritual. This queue carries cross-scene work the ritual (which lands on the active in-progress scene) won't surface on its own.

## TL;DR

2026-04-24. Scene 2a-03 (`near-proximal-and-the-stream`) opened, built, concluded, shipped. The temporal-edge decision from 2026-04-23's retrospective is now live. Five parallel agents then landed the first round of follow-on work on the same PR. Doc refresh followed.

1. **Scene 2a-03 shipped.** Four features + four cheap riders, atomic commits on `feat/near-proximal-stream`. Graph reingested fresh under the new schema — 3,968 nodes / 144,482 edges (**89% edge-count reduction** from 1,614,528). Zero `follows`/`precedes` edges. `near` + `proximal` + two-layer tags + progressive data stream all firing in a single end-to-end query.
2. **PR #5 open** — https://github.com/onceuponaprince/borai.cc/pull/5. 8 commits total. 164 tests passing.
3. **Five parallel agents landed on the same PR** after sign-off — scene-aware chunker (7 tests), per-agent `PROXIMAL_ALPHA` (3 tests), `borai-graph-tags` CLI (8 tests), reason `explain()` helper (11 tests), and the four agent skills updated in-place for the new API shape (`mode="full"` on three, shallow default on `delegate_agent`).
4. **BorAI main pushed** — pre-push hook typecheck step now guarded with `--if-present` (`be42e6e`).
5. **Vault main pushed** — scene file opened, captured, concluded, chapter checklist ticked, and `docs/infra/borai-graph-usage.md` refreshed for the new API.
6. **Scene 2a-03 artifact queue**: `thread, essay, newsletter` — three registers of the same story, not yet drafted.

**Immediate next actions (mostly independent):**

- **Review + merge PR #5.** 8 commits + a 4-commit parallel-agent layer, all green. Worth a read-through.
- **Scene 2a-03 artefacts** — draft the thread, essay, newsletter. Three variants of the 91.6% → specificity story.
- **Scene 2a-02** — fast-travel-cli first-run or ghostroute retroactive docs (either completes its closure).
- **Scene 2a-01** — ai-swarm hello-world round-trip. Hardware-dependent.
- **Scene 2b-01b** — teenyweeny URL. Still unopened.
- **New strategic scenes** — see §Strategic next step below.

## Strategic next step — search quality

The retrieval layer now has honest signal (near/proximal/relates_to over 144K edges, not 1.6M). The next frontier is **ranking quality** and **token efficiency** — getting the most useful results to the caller in the smallest response.

### Vespa.ai-style search (likely next major scene)

Vespa's value in one line: *first-phase cheap ranking over all candidates, then second-phase expensive re-ranking of the top-K, with hybrid sparse+dense signals fused at the end.* Adapted to borai-graph:

1. **Add BM25 (or TF-IDF) as a sparse signal** alongside cosine embeddings. Lives in the indexer — builds a per-chunk term-frequency table, persisted alongside `vectors.npy`. Cheap to query, catches keyword-heavy questions that embeddings gloss over ("what did we decide about α?" where `α` is a sparse hit).
2. **Two-phase ranking.** First phase: cheap top-200 by BM25 + cosine sum. Second phase: expensive re-rank of that top-200 using proximal expansion + relates_to traversal. Cuts compute from "every query touches the whole graph" to "every query touches 200 candidates."
3. **Reciprocal rank fusion (RRF)** between the signals. Standard hybrid-search move: each mechanism (seed / near / proximal / relates_to / BM25) produces its own ranking; RRF fuses them into a single ordering via `1 / (k + rank)`. Avoids tuning weights manually; generally beats weighted linear combinations in practice.
4. **Learning-to-rank (future)**. If there's judgement data — mark which results were actually useful per query — train a small LambdaMART-style re-ranker on top of the features. Out of scope for v1; worth flagging for a Chapter 3+ scene.

A scene-sized first slice would be (1) + (3): BM25 + RRF. Implementation sketch: new `borai.retrieval.sparse` module for BM25, add `sparse_similarity` to `top_k_seeds`, fuse via RRF in `rank_results`. 4-6 hours including tests.

### Token reduction strategies

Orthogonal to ranking quality — once the right results are surfacing, return them in fewer tokens. Named candidates, rough cost/value:

- **Smart chunk-collapsing.** When two results come from the same file and adjacent chunks, collapse into a single "spans X-Y" response with the union of content. Today `near` hits produce two separate result rows; in practice they're one answer. Cheap (maybe 30 LOC in `rank_results`). Cuts response tokens ~30% for scene queries.
- **Sentence-level pruning inside chunks.** Return only the sentences that actually overlap with the query, not the full chunk. Requires a small sentence-splitter (already exists via `_split_sentences` in chunker) and a scoring pass. Medium cost. Cuts tokens 40-60% per result on long chunks.
- **Result deduplication by content hash.** If the same text appears in multiple files (scripts duplicated, specs superseded), return once with a `seen_in: [...]` list. Cheap. Variable payoff — depends on how much the corpus actually duplicates.
- **Tag-only shallow responses.** An even-shallower mode than current `shallow`: return just `source_path[chunk]` + top 3 tags. Caller picks which to expand. Useful for "give me 50 candidates to scan" flows where the webapp wants to render a dense list. Medium cost.
- **Query-aware result caps.** Currently `token_budget` is a hard cap on content chars. Add `max_results` as a separate cap so a short-query with 20 tiny results doesn't blow the char budget while still capping count. Cheap.
- **Semantic query-cache coalescing.** Today the query cache keys on `hash(agent::mode::query)`. Two queries that are synonyms miss the cache. Embed the query; cache keyed by embedding bucket. Medium cost, high value for repeated drafting sessions. Worth its own scene.

**My recommended next-scene shape**: Vespa-inspired BM25 + RRF as the main beat; smart chunk-collapsing + query-aware `max_results` as riders on the same PR. Token-reduction gets a second scene once ranking quality is on solid ground.

## State snapshots

### BorAI repo (github.com/onceuponaprince/borai.cc)

- `main` at `be42e6e` — pre-push hook typecheck guard added this session.
- `feat/near-proximal-stream` at `b21fb2c` — 8 commits, PR #5 open.
- `feature/misled-ethos-page` at `02b7bc2` — unchanged; live production at `misled.vercel.app/`; must not merge to main.
- `feature/ai-swarm-infra-impl` at `e5a9715` — unchanged; ready to PR after end-to-end validation.

### Docker stack (running on this host)

- Worktree: `~/code/BorAI-graph` on `feat/near-proximal-stream` (rebased onto `main` this session).
- Compose file: `~/code/BorAI-graph/docker-compose.yml`.
- Named volumes: `borai-ollama-models` (persistent, `nomic-embed-text` cached), `borai-graph-data` (fresh ingest under new schema).
- Stack is UP with the new schema loaded — validated via end-to-end query at scene close.
- Operations:
  - `docker compose exec borai-graph borai-graph-stats` — graph health.
  - `docker compose exec borai-graph borai-graph-tags --min-count 5` — tag inventory (new CLI).
  - **After any `ops/borai-graph/` source edit:** `docker compose build --no-cache borai-graph && docker compose up -d`. `--build` alone has been hitting the cache-masks-source-edits landmine repeatedly.
  - `docker compose down -v` wipes both volumes; `down` alone keeps them.

### Vault

- Active campaign: `[[command-centre]]`.
- In-progress scenes:
  - `[[02a-01-ai-swarm-hello-world]]` — hardware-dependent; untouched this session.
  - `[[02-reaching-past-claude]]` — fast-travel-cli first-run + ghostroute retroactive docs still open.
- Concluded this session:
  - `[[03-near-proximal-and-the-stream]]` — shipped. `status: concluded`, `date_concluded: 2026-04-24`, `artifact_format: thread, essay, newsletter`.
- Vault HEAD: pushed to `origin/main`. Recent commits: scene-2a-03 open, Progress capture + Conclude, scene conclude + checklist, docs refresh.
- Dirty state left alone this session: `references/misled/*.png` (binaries), untracked `artifacts/borai-graph-ship/`, `copilot-instructions.md`, `one-shots/`, `research/agent-architecture/`, `.claude/scheduled_tasks.lock`.

### Agent skills (not version-controlled)

Four files modified in-place at `~/.claude/commands/*/SKILL.md`. Not in any git repo — edits live on disk:

- `build-in-public-engine/SKILL.md` — added `mode='full'`; query snippet unchanged otherwise.
- `funding-tracker/SKILL.md` — added `mode='full'`; live-validated against running stack.
- `hackathon-radar/SKILL.md` — added `mode='full'`.
- `delegate-agent/SKILL.md` — kept `mode='shallow'` (aligns with skill's "source paths, not content" posture); print line now emits `tags` + `expand_handle`; comment added pointing at `engine.expand(handle)` for future follow-up.

## Queue (behind the strategic scenes)

### Small wins (can ride alongside the next PR)

- **`borai-graph-query` CLI** — the skills still invoke via a Python one-liner. A proper `borai-graph-query --agent X --mode shallow 'text'` wrapper would clean that up.
- **Bake `nomic-embed-text` into a custom Ollama image** — saves first-boot pull for anyone cloning.
- **Host graph_dir documentation** — skills currently hardcode `/home/onceuponaprince/borai/graph`. When the skills ship to another user, that path breaks. Env-var-first with a sensible fallback.

### Medium (a scene each)

- **Vespa-inspired BM25 + RRF** — see §Strategic next step.
- **Semantic query-cache coalescing** — see §Strategic next step.
- **Claude Code subprocess bridge for semantic edge enrichment** — original paper §7 idea; worth picking up once ranking-quality work is in.
- **Web UI for retrieval** — paper §7. Becomes concrete once the API shape stabilises after the Vespa work.

## Cross-scene carries (from prior sessions, still open)

### Scene 2a-02

- **fast-travel-cli first-run** → fresh session in `~/code/fast-travel-cli/`, starts from `.claude/PROGRESS.md` + vault spec at `docs/superpowers/specs/2026-04-23-fast-travel-cli-design.md`. Seven-commit build sequence.
- **ghostroute retroactive docs** → fresh session in `~/code/ghostroute/`. Monorepo-of-providers shape.

Either beat closes Scene 2a-02 independently. Both still required for the scene to conclude.

### Scene 2b-01b

Still unopened. Scene 2b-01's Conclude named it as: ship the `teenyweeny.studio` URL. BorAI-side execution beat — register domain, Supabase project, Resend sending domain, Vercel link, scaffold landing per design spec at `docs/superpowers/specs/2026-04-22-teenyweeny-studio-landing-design.md`. Chapter 2b rule *landing before build* blocks Scene 2b-02 (parser) until this lands.

### Scene 05 artifact publication (Chapter 1)

Thread + essay both still pending. Source: Scene 05's Conclude block + the two catalogue files at `chapters/01-origin/catalogues/`. Paths:

- `/artifacts/01-origin/05-two-side-projects-additional-workflow-infra-thread.md` — delegate to Gemini for British-English voice polish.
- `/artifacts/01-origin/05-two-side-projects-additional-workflow-infra-essay.md` — hook: runtime-import (vault as user data, not system data).

### Scene 04 downstream

- Client message at `docs/handoffs/2026-04-21-misled-client-message-draft.md` — check if sent.
- Scene 04 artifact publication — still open.
- Register `misled.london` once client signs off on the ethos page.

## Landmines (repeat offenders)

- **Docker cache masks source edits.** Hit **twice** this session. `docker compose up -d --build` does NOT reliably invalidate the COPY layer. Default to `build --no-cache` when the change is in `ops/borai-graph/`. Yesterday's session hit this once; today's twice. Worth baking `--no-cache` into a helper script.
- **BorAI pre-push hook** needs `node_modules` in the worktree. `pnpm install` before pushing; discard the `pnpm-lock.yaml` drift with `git checkout -- pnpm-lock.yaml`. Typecheck step now guarded with `--if-present` (fixed this session).
- **Skill-list dumps.** The available-skills catalogue was re-injected as a system reminder **seven times** this session, up from five yesterday. Still logged at `docs/upstream-issues.md`. Worth genuinely pursuing the disable-locally option if it keeps growing.
- **`/etc/gitconfig` permission denied** for `gh pr create` — prefix with `GIT_CONFIG_NOSYSTEM=1`. Known, persistent.
- **`np.save` silently appends `.npy`** — use `.tmp.npy` suffix pattern for atomic swap. Inherited through the codebase.
- **Docker bind-mounts bind at container-create time.** Tear down with `docker compose down` before removing a bound worktree.
- **BorAI-graph and BorAI share a git repo via worktrees.** Feature branches cut from an old `main` will miss hook fixes etc.; `git rebase origin/main` before pushing.
- **Vercel preview deploys fail** on `apps/misled` (pre-existing). Not a blocker.

## Active tooling state

- **Ollama (containerised):** running, `nomic-embed-text` cached, healthy.
- **Gemini CLI:** AUTHED (parallel rate-limited).
- **Copilot CLI:** AUTHED (`-p --deny-tool=shell --deny-tool=write`).
- **Cursor CLI:** AUTHED, unused.
- **Grok:** UNAVAILABLE as of last check; not re-verified.
- **Anthropic API key:** NOT set. Graph runs rules-only by design.

## Session-open ritual for the next session

1. Read `CLAUDE.md` at vault root.
2. Read `campaigns/command-centre/campaign.md`.
3. If touching the graph: `cd ~/code/BorAI-graph && docker compose ps` for stack state, `docker compose exec borai-graph borai-graph-stats` for health, `docker compose exec borai-graph borai-graph-tags --min-count 10` if curious about tag layer.
4. Depending on intent:
   - **Review + merge PR #5** → GitHub review, then `gh pr merge 5 --squash` (or merge via UI).
   - **Scene 2a-03 artefacts** — draft the thread, essay, newsletter from the Conclude block. Source: `campaigns/command-centre/chapters/02a-systems-and-tools/scenes/03-near-proximal-and-the-stream.md`.
   - **Strategic next — Vespa-style ranking** → `/set-stage` a new Scene 2a-04 (inserted ahead of the existing Scene 04 — delegate-agent integration — if that still feels right, else as Scene 2a-04b). See §Strategic next step above for the scope sketch.
   - **Scene 2a-02 — fast-travel-cli first-run** → `cd ~/code/fast-travel-cli`, read `.claude/PROGRESS.md`.
   - **Scene 2a-02 — ghostroute retroactive docs** → fresh session in `~/code/ghostroute/`.
   - **Scene 2a-01 — ai-swarm round-trip** → hardware across three machines.
   - **Scene 2b-01b** — `/set-stage` under chapter 2b.
5. Greet with one line: *"PR #5 ready to merge; Scene 2a-03 concluded. Next is either artefacts, Vespa-style ranking, or one of the open 2a scenes. Pick."*

## Out-of-scope but noted

- `copilot-instructions.md` at vault root — still untracked; symlinked to CLAUDE.md.
- `one-shots/` directory — still untracked; not touched.
- `research/agent-architecture/` directory — surfaced in `git status`; not explored.
- `artifacts/chapter-1/` — pre-existing from Chapter 1; not touched.
- Old session files under `.claude/projects/` — auto-generated transcripts.
- `.claude/scheduled_tasks.lock` — scheduler state; leave alone.
