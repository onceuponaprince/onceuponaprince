# Session handoff — 2026-04-30 close · vault schema + commit discipline rationalised · pushed to origin/main

Read BEFORE the standard session-open ritual. This queue carries cross-scene work the ritual (which lands on the active in-progress scene) won't surface on its own.

## TL;DR

2026-04-30. Vault-wide schema + commit-rules pass. Four commits today (`60541d3` template, `2523258` docs(claude-md), `b078176` schema, `0933aa4` conclude(02b/01) backfill) plus 10 prior unpushed commits all synced to `origin/main`. Vault HEAD: `0933aa4`. Working tree level with origin (modulo unrelated dirty files in `agent-architecture/` and `docs/superpowers/` from in-flight work — flagged, not folded).

Three pillars of today's pass:

1. **Frontmatter schema collapsed.** `artifact_format` + `artifact_file` (drifted into three syntactic forms across ten scenes) replaced with single `artifacts:` list of `{format, file}` objects. All 10 scenes migrated. 02a/02 + 02a/03 path-form artefact files rewritten as wikilinks. 01/01 dates backfilled to 2026-04-17.

2. **Blocker-clear-before-conclude invariant.** New rule: `status: concluded` requires `blockers: []`. 02b/01 was retroactively in violation — five blockers on a concluded scene. Cleared frontmatter (the Conclude block already named Scene 2b-01b as inheritor). Drafted the essay + thread artefacts that 02b/01 had been concluded without — *Design authority lives in the asset register* (essay) and a seven-tweet superseded-spec compression (thread).

3. **Commit discipline section added to CLAUDE.md.** Vault verbs (`set-stage`, `capture`, `conclude`, `ship`, `pivot`, `schema`, `template`, `chapter`, `campaign`, `character`) override the global `feat/fix` set. Eight rules. All four of today's commits authored under the new rules.

Caught up from intermediate sessions (commits between 2026-04-27 and today, identified via the unpushed log):

- ✓ pilot.html topology switcher built (`608834e`)
- ✓ `agent-architecture/` graduated from `research/` to `campaigns/` (`a7b26ea`)
- ✓ Episode 2 — *the router we cannot yet build* — 5-of-7-source cold round landed (`cda5063`)
- ✓ fast-travel-cli Phase 2 spec (`06f8946`)
- ✓ borai-spore design + monorepo migration plan + superpowers feature list

**Immediate next action:** open. Recommend Scene 2b-01b (teenyweeny URL ship) since 02b/01's blockers now legibly point there. Alternatively, agent-architecture Episode 2 synthesis if the cold round is ripe.

## Immediate queue

### 1. pilot.html — topology switcher (interactive #1 of 5)

Per the synthesis's commitment paragraph in `research/agent-architecture/episodes/01-context-and-granularity.md`. Self-contained single-file HTML, hybrid essay + interactive, matching `emotional-ux-pilot/pilot.html`'s style tokens. Switcher should manipulate the four-axis policy (not just agent count) and surface a live SVG topology diagram. Subsequent interactives in agreed order: drift-vs-context slider, same-task walkthrough, coordination-overhead visualiser, cost/quality scatter.

### 2. ghostroute uncommitted patches

```
~/code/ghostroute/ask-grok-cli/src/config/mod.rs       # RESPONSE_TIMEOUT_MS + RESPONSE_SELECTOR
~/code/ghostroute/ask-grok-cli/src/automation/response.rs  # whitespace-collapse comparison fix
```

Plus yesterday's two prior uncommitted patches (typing.rs newline normalisation, main.rs context paste — noted in `one-shots/2026-04-22_ask-grok-cli-walkie-talkie-test.md`). A clean commit pass when next in ghostroute would be:

- `fix(response): structural selector + whitespace-collapse to filter user prompt bubble`
- `fix(config): bump RESPONSE_TIMEOUT_MS to 900_000`
- `fix(typing): normalise whitespace for CDP keymap`

That ghostroute beat is also part of Scene 2a-02 closure (the *ghostroute retroactive docs* trailing beat) — could fold the patches into that session.

### 3. Strategic next — Vespa-style ranking (carried)

See §Strategic next step below — Vespa-inspired BM25 + RRF as the next major scene; smart chunk-collapsing + query-aware `max_results` as riders on the same PR.

### 4. Scene queue (carried)

- ~~Review + merge PR #5~~ — merged 2026-04-24 as squash commit `2f7464a`.
- ~~Scene 2a-03 artefacts~~ — drafted and committed (`1e0c604`); pending external publish only.
- **Scene 2a-02 closure** — brief at `docs/handoffs/2026-04-24-scene-2a-02-closure-brief.md`. Fresh session in `~/code/` handles fast-travel-cli first-run + ghostroute retroactive docs, optionally via parallel subagents.
- **Scene 2a-01** — ai-swarm hello-world round-trip. Hardware-dependent.
- **Scene 2b-01b** — teenyweeny URL. Still unopened.

## Strategic next step — search quality (carried from 2026-04-24)

The retrieval layer now has honest signal (near/proximal/relates_to over 144K edges, not 1.6M). The next frontier is **ranking quality** and **token efficiency** — getting the most useful results to the caller in the smallest response.

### Vespa.ai-style search (likely next major scene)

Vespa's value in one line: *first-phase cheap ranking over all candidates, then second-phase expensive re-ranking of the top-K, with hybrid sparse+dense signals fused at the end.* Adapted to borai-graph:

1. **Add BM25 (or TF-IDF) as a sparse signal** alongside cosine embeddings. Lives in the indexer — builds a per-chunk term-frequency table, persisted alongside `vectors.npy`.
2. **Two-phase ranking.** First phase: cheap top-200 by BM25 + cosine sum. Second phase: expensive re-rank using proximal expansion + relates_to traversal.
3. **Reciprocal rank fusion (RRF).** Each mechanism produces its own ranking; RRF fuses via `1 / (k + rank)`. Beats weighted linear combinations in practice.
4. **Learning-to-rank (future).** Out of scope for v1; flag for Chapter 3+.

A scene-sized first slice: (1) + (3) — BM25 + RRF. New `borai.retrieval.sparse` module for BM25, add `sparse_similarity` to `top_k_seeds`, fuse via RRF in `rank_results`. 4–6 hours including tests.

### Token reduction strategies (orthogonal)

- **Smart chunk-collapsing.** Same-file adjacent chunks → single "spans X-Y" response. Cheap (~30 LOC). Cuts response tokens ~30% for scene queries.
- **Sentence-level pruning inside chunks.** Return only sentences overlapping the query. Medium cost. Cuts tokens 40–60% per result on long chunks.
- **Result deduplication by content hash.** Cheap. Variable payoff.
- **Tag-only shallow responses.** Even-shallower mode than `shallow`. Medium cost.
- **Query-aware result caps.** Add `max_results` separate from `token_budget`. Cheap.
- **Semantic query-cache coalescing.** Embed query; cache keyed by embedding bucket. Medium cost, high value for repeated drafting sessions.

**Recommended next-scene shape:** Vespa-inspired BM25 + RRF as the main beat; smart chunk-collapsing + query-aware `max_results` as riders. Token-reduction gets a second scene once ranking quality is on solid ground.

## State snapshots

### Vault

- Active campaign: `[[command-centre]]`.
- In-progress scenes:
  - `[[02a-01-ai-swarm-hello-world]]` — hardware-dependent; untouched this session.
  - `[[02-reaching-past-claude]]` — fast-travel-cli first-run + ghostroute retroactive docs still open.
- Concluded prior session: `[[03-near-proximal-and-the-stream]]` — shipped 2026-04-24.
- New on lateral track: `research/agent-architecture/` — Episode 1 *Context and granularity* synthesised today. Pilot.html scaffold next.
- Vault HEAD: `973e422` (this session's commit). Not yet pushed.
- Working tree dirty: this PROGRESS.md (about to be committed).

### Lateral research threads

- `research/emotional-ux-pilot/` — Episode 1 pilot, complete. Self-contained `pilot.html` with three interactives.
- `research/agent-architecture/` — Episode 1 cold round + synthesis landed; pilot.html in queue (interactive #1 of 5: topology switcher).

When agent-architecture earns Episode 2, it graduates to `campaigns/agent-architecture/` per the rule in `research/agent-architecture/README.md`.

### BorAI repo (github.com/onceuponaprince/borai.cc)

- `main` at `2f7464a` — PR #5 squash-merged 2026-04-24 late-day. Pre-push hook typecheck guard landed earlier on `main` (`be42e6e`).
- `feature/misled-ethos-page` at `02b7bc2` — unchanged; live production at `misled.vercel.app/`; must not merge to main.
- `feature/ai-swarm-infra-impl` at `e5a9715` — unchanged; ready to PR after end-to-end validation.

### Ghostroute repo (`~/code/ghostroute`)

- HEAD at `bf004a1` (`docs: integrate fast-travel-cli into root README + architecture`).
- **Two uncommitted source patches from this session:** `ask-grok-cli/src/config/mod.rs` (timeout + selector) and `ask-grok-cli/src/automation/response.rs` (whitespace-collapse). Plus prior session's uncommitted patches on `typing.rs` and `main.rs` (newline normalisation).
- Binary installed to `~/.cargo/bin/ask-grok-cli` from current source (so working binary depends on uncommitted patches).
- Cookies fresh at `~/.claude/cookie-configs/grok.com-cookies.json` (refreshed 2026-04-27 00:43:01).

### Docker stack

- Worktree: `~/code/BorAI-graph` on `feat/near-proximal-stream` (rebased onto `main` 2026-04-24).
- Compose file: `~/code/BorAI-graph/docker-compose.yml`.
- Named volumes: `borai-ollama-models` (persistent), `borai-graph-data` (fresh ingest under new schema 2026-04-24).
- Ops:
  - `docker compose exec borai-graph borai-graph-stats` — graph health.
  - `docker compose exec borai-graph borai-graph-tags --min-count 5` — tag inventory.
  - **After any `ops/borai-graph/` source edit:** `docker compose build --no-cache borai-graph && docker compose up -d`.
  - `docker compose down -v` wipes both volumes; `down` alone keeps them.

### Agent skills (not version-controlled)

Four files modified at `~/.claude/commands/*/SKILL.md` (state from 2026-04-24):

- `build-in-public-engine/SKILL.md` — `mode='full'` added.
- `funding-tracker/SKILL.md` — `mode='full'` added; live-validated.
- `hackathon-radar/SKILL.md` — `mode='full'` added.
- `delegate-agent/SKILL.md` — kept `mode='shallow'`; print line emits `tags` + `expand_handle`.

## Cross-scene carries (from prior sessions, still open)

### Scene 2a-02

- **fast-travel-cli first-run** → fresh session in `~/code/fast-travel-cli/`, starts from `.claude/PROGRESS.md` + vault spec at `docs/superpowers/specs/2026-04-23-fast-travel-cli-design.md`. Seven-commit build sequence.
- **ghostroute retroactive docs** → fresh session in `~/code/ghostroute/`. Monorepo-of-providers shape. **Fold today's ask-grok-cli patches into this beat.**

Either beat closes Scene 2a-02 independently. Both still required for the scene to conclude.

### Scene 2b-01b

Still unopened. Scene 2b-01's Conclude named it: ship the `teenyweeny.studio` URL. Register domain, Supabase project, Resend sending domain, Vercel link, scaffold landing per `docs/superpowers/specs/2026-04-22-teenyweeny-studio-landing-design.md`. Chapter 2b rule *landing before build* blocks Scene 2b-02 (parser) until this lands.

### Scene 05 artefacts (Chapter 1)

Drafted and committed at `artifacts/chapter-1/`:
- `05-orchestration-shape-inverted-thread.md`
- `05-vault-as-user-data.md`

Both in voice. Pending external posting only — `status: shipped` flips when each goes up.

### Scene 04 downstream

- Client message at `docs/handoffs/2026-04-21-misled-client-message-draft.md` — check if sent.
- Scene 04 artefact publication — still open.
- Register `misled.london` once client signs off on the ethos page.

### Scene 2a-03 artefacts — external posting

Drafted at `artifacts/02a-systems-and-tools/03-near-proximal-and-the-stream-{thread,essay,newsletter}.md`. Pending external publish only — `status: shipped` flips when each goes up.

## Landmines (repeat offenders)

- **Docker cache masks source edits.** Default to `build --no-cache` when the change is in `ops/borai-graph/`. Worth baking into a helper script.
- **BorAI pre-push hook** needs `node_modules` in worktree. `pnpm install` before pushing; discard `pnpm-lock.yaml` drift with `git checkout -- pnpm-lock.yaml`. Typecheck step now `--if-present`-guarded.
- **Skill-list dumps.** Available-skills catalogue re-injected as system reminder repeatedly per session. Logged at `docs/upstream-issues.md`. Worth pursuing the disable-locally option.
- **`/etc/gitconfig` permission denied** for `gh pr create` — prefix with `GIT_CONFIG_NOSYSTEM=1`.
- **`np.save` silently appends `.npy`** — use `.tmp.npy` suffix pattern for atomic swap.
- **Docker bind-mounts bind at container-create time.** Tear down with `docker compose down` before removing a bound worktree.
- **BorAI-graph and BorAI share a git repo via worktrees.** Feature branches from old `main` miss hook fixes; `git rebase origin/main` before pushing.
- **Vercel preview deploys fail** on `apps/misled` (pre-existing). Not a blocker.
- **`ask-grok-cli` Stateful Memory Campfire amplifies prompt-length bugs.** Each call accretes prior session turns into the prompt; long-prompt runs grow further out of any timeout. Mitigation: wipe `.claude/.swarm-memory.json` between long-prompt runs. Proper fix would be opt-out flag in ask-grok-cli source.

## Active tooling state

- **Ollama (containerised):** running, `nomic-embed-text` cached, healthy.
- **Gemini CLI:** AUTHED. Quota-rate-limited under load — retries kick in but log noise lands in dumps.
- **Perplexity (`ask-perplexity` skill):** AVAILABLE and tested (43 cited sources delivered cleanly in Episode 1 cold round). First call may time out at 60s; retry succeeds.
- **ChatGPT (`ask-chatgpt` skill):** Available but the subagent fell back to `codex exec -m gpt-5.4` for Episode 1 — note that the dump is from Codex CLI, GPT-5.4 model, not the skill's own surface.
- **Copilot CLI:** AUTHED (`-p --deny-tool=shell --deny-tool=write`). Hit weekly rate limit during Episode 1's first round; retry ~3 hours later succeeded.
- **Cursor CLI (`cursor-agent`):** AUTHED. Required `--force --model claude-4.5-sonnet` for Episode 1 (default `auto` and `sonnet-4-thinking` failed — model list has shifted). Cursor unilaterally writes its own files unless told not to; clean up after.
- **Grok (`ask-grok-cli`):** AVAILABLE this session via `~/.cargo/bin/ask-grok-cli` (CDP scraper at `~/code/ghostroute/ask-grok-cli`). Cookies fresh. Three patches in source uncommitted.
- **Anthropic API key:** NOT set. Graph runs rules-only by design.

## Session-open ritual for the next session

1. Read `CLAUDE.md` at vault root.
2. Read `campaigns/command-centre/campaign.md`.
3. If touching the graph: `cd ~/code/BorAI-graph && docker compose ps` for stack state, `docker compose exec borai-graph borai-graph-stats` for health.
4. Depending on intent:
   - **pilot.html topology switcher** (interactive #1 of 5) → no scene to load; work directly in `research/agent-architecture/`. Synthesis at `episodes/01-context-and-granularity.md` is the source.
   - **Scene 2a-02 closure** → `cd ~/code/` then *"Read `~/code/build-in-public/docs/handoffs/2026-04-24-scene-2a-02-closure-brief.md` and execute it."* Covers fast-travel-cli first-run + ghostroute retroactive docs. **Fold the ask-grok-cli uncommitted patches into the ghostroute beat.**
   - **Strategic next — Vespa-style ranking** → `/set-stage` a new Scene 2a-04 (or 2a-04b). See §Strategic next step.
   - **Scene 2a-01 — ai-swarm round-trip** → hardware across three machines.
   - **Scene 2b-01b** — `/set-stage` under chapter 2b.
   - **Scene 2a-03 artefacts — external posting** → flip `status: shipped` per artefact.
   - **Chapter 1 Scene 05 artefacts — external posting** → same flip-on-post pattern.
5. Greet with one line: *"Episode 1 of agent-architecture synthesised; pilot.html topology switcher is next. Or pick from carries: 2a-02 closure (brief saved), Vespa ranking, scene 2b-01b, artefact postings."*

## Out-of-scope but noted

- ~~`copilot-instructions.md` at vault root~~ — dropped 2026-04-24.
- ~~`one-shots/` directory~~ — committed 2026-04-24, seeded with the ask-grok-cli walkie-talkie test log.
- ~~`research/agent-architecture/` directory~~ — scaffold committed 2026-04-24; Episode 1 cold round + synthesis committed 2026-04-27 (`973e422`).
- `artifacts/chapter-1/` — pre-existing; contains scene 05 artefacts.
- Old session files under `.claude/projects/` — auto-generated transcripts.
