---
campaign: "[[command-centre]]"
chapter: "02a-systems-and-tools"
scene: 03
title: "near-proximal-and-the-stream"
status: concluded
date_opened: 2026-04-23
date_concluded: 2026-04-24
characters:
  - "[[prince]]"
  - "[[solo-thesis-holder]]"
spec_file: "artifacts/borai-graph-ship/retrospective.md"
blockers: []
supersedes: null
artifacts:
  - format: thread
    file: "[[03-near-proximal-and-the-stream-thread]]"
  - format: essay
    file: "[[03-near-proximal-and-the-stream-essay]]"
  - format: newsletter
    file: "[[03-near-proximal-and-the-stream-newsletter]]"
tags:
  - chapter-2a
  - borai-graph
  - retrieval
  - edges
  - tags
  - data-stream
---

# Scene 2a-03 — near-proximal-and-the-stream

*Chapter 2a — Systems and tools · Campaign: [[command-centre]]*

*The borai-graph's every-pair temporal edge becomes three sharper mechanisms: a stored `near` edge at distance 1, a computed `proximal` relation at distance > 1 with a blended relevance score, and a tag-and-stream layer that makes retrieval progressive by default.*

---

## Set the Stage

### How did we get here?

Yesterday shipped borai-graph via PR #3 (indexer + retrieval + dashboard) and PR #4 (docker + starter kit), wired the vault into it, and published three closing artefacts including a retrospective that named the real residue. 91.6% of the graph's edges — 1,478,598 of 1,614,528 — are every-pair `follows`/`precedes` temporal edges. 425 edges per node from within-file cross-products. The ranker drowns in them; the hero's skill queries feel the confusion before anyone else does.

The retrospective proposed three defensible shapes: drop the temporal edges entirely, cap at distance 1, keep every-pair and downweight. Its recommendation was distance-1. The founder's call is richer and runs against the retrospective's grain: cap the stored edge at distance 1, but compute distance > 1 at query time with a proper relevance signal. *Become more specific, not less.* Two further design commitments earn their slot in the same scene — a two-layer tag system and a progressive data-stream retrieval mode.

### Where are we going?

Four code changes shipped behind one PR to `main` on `~/code/BorAI-graph`:

1. **`near` edge.** The old `follows`/`precedes` edge, capped at distance 1 within a file. Stored in the graph. Legible.
2. **`proximal` relation, computed.** Distance > 1 sibling relationships surfaced at query time, not ingest. Relevance = α·(1/d) + (1−α)·cos(embedding_a, embedding_b). α starts at a named default; retuning is a follow-on scene.
3. **Tag system, two layers.** Author-provided YAML `tags:` stay sovereign. The indexer mints a reserved-prefix structured layer alongside — `type:scene`, `status:in-progress`, `chapter:02a`, `campaign:command-centre`. The reserved prefix is the contract that stops the two layers colliding.
4. **Progressive data stream.** Retrieval gains a shallow mode — frontmatter + tags first, chunk body on expansion. Shallow by default; callers opt into depth.

Riders shipped in the same PR: `/api/embed` migration; delete the hardcoded `/mnt/skills/` rules in `chunker.py::infer_source_type`; periodic "processed N/M" INFO logs in `run.py`; `pnpm --if-present` guard on the BorAI pre-push hook's typecheck step.

Scene closes when the graph rebuilds under the new edge model, a retrieval query exercises both the tag layer and the data stream end-to-end, and the PR lands on `main`.

### State of the world (project context)

`~/code/BorAI-graph` on `main` at `2b3e123`. Stack running — `borai-ollama` and `borai-graph` both healthy. Graph state: 3,916 nodes / 1,614,528 edges. `docker compose exec borai-graph borai-graph-stats` for health.

The edge-schema change invalidates the existing graph — `docker compose down -v` wipes volumes, reingest is ~17 min. Rebuild is cheaper than migration. After any `ops/borai-graph/` source edit, `docker compose up -d --build` — the plain form's cache masked source edits twice yesterday.

Test floor: 107 passing. New tests land for each of the four additions; regression on the 107 is non-negotiable. Embeddings cached in the persistent `borai-ollama-models` volume — no re-pull.

### State of the hero ([[solo-thesis-holder]])

Runs four agent skills (`build-in-public-engine`, `funding-tracker`, `hackathon-radar`, `delegate-agent`), each wired to query the graph before drafting. Notices first when the graph misleads — a funding query surfacing a scene about typography, a content draft pulling the wrong receipt. Every-pair edges are the proximate cause. The hero doesn't want more results; they want results that fit the question, with a clean route to depth only when they choose it. *Surface me the names first. I'll ask for the body when I want it.*

### State of the protagonist ([[prince]])

Picking the blend over the sage's pure-decay recommendation, on purpose. Reason: the embeddings are already paid for at ingest; refusing to use them is cheapness for its own sake. The project's thesis is that specificity compounds — a retrieval engine that only uses distance is one waiting to be retrained on signal it already has. The α-tuning cost is real and acknowledged; it earns its place as a follow-on scene, not a pre-emptive anxiety.

Aware that "become more specific, not less" is a design stance taken against an explicit warning. If the blend proves unstable, the fallback to pure decay is a three-line change. The warning is logged; the experiment proceeds.

Unfamiliar ground: the tag vocabulary and the data-stream expansion contract. Both are first-versions that will carry biases for months. Keep the tag prefix narrow. Keep the stream's expansion handle boring.

### This moment in relation to goals

Chapter 2a's *infra precedes product* rule binds here. The webapp climax (Scene 02a-06+, pushed down by this insertion) cannot honestly open while the graph underneath it misleads callers. Scene 02 (`reaching-past-claude`) runs in parallel — different subsystem, no dependency. Neither blocks the other.

Thesis-wise: a solo founder tightening their own knowledge graph rather than outsourcing the problem to a managed vector DB that would serve institutional users first. Same arc, smaller scale, one more time.

### Why now?

- The 91.6% diagnostic is fresh. Cheapest moment to fix is before skill queries accumulate confused routing around it.
- The cheap riders are each ten-line fixes the next scene would carry anyway. Once cleanly > accumulated as tax.
- The edge-schema rebuild forces a full reingest regardless. Right moment to validate the tag layer and the data stream against a fresh graph.
- The blend recommendation is about to go off the cliff of hypothetical. Quickest way to learn whether α-tuning is a Thursday-afternoon problem or a month-long one is to ship it and query it.

---

## Progress the moment

### Goal for this session

- `near` edge: `follows`/`precedes` collapsed into a single stored edge type at distance 1 only. Test coverage for the cap.
- `proximal` relation: computed at query time. Relevance blend with named α default. Fallback path to pure 1/d documented in-code.
- Tag system: both layers queryable. Reserved-prefix contract enforced by the indexer.
- Progressive data stream: shallow-by-default retrieval mode; expansion handle tested end-to-end.
- Cheap riders: `/api/embed` migration, `/mnt/skills/` rules deleted, ingest progress logs, pre-push hook guard.
- Graph reingested cleanly under new schema. Retrieval query exercises tag layer + data stream.
- Tests at session close ≥ 107 + new coverage for the four additions.
- PR opened against `main` on `~/code/BorAI-graph`.

### Moment-by-moment capture

- [x] **2026-04-23 — `near` edge landed.** TDD red-green-refactor on `rule_near` in `edge_detector.py`. Replaces `rule_follows_precedes` which was the 91.6%-bloat source (same-directory, mtime-driven, every-pair). New contract: within-file (`source_path` exact match) and adjacent-by-`chunk_index` only (`|Δ| == 1`), bidirectional `near` edges. Cross-file sequential signal dropped by design; `authored_during` still handles genuine cross-file temporal windows. 5 new tests, 3 obsolete `follows_precedes` tests deleted. Dead `PurePosixPath` import and `_24H` constant swept out. Full suite: 109 passing (was 107).
- [x] **2026-04-24 — `proximal` relation computed.** TDD on `compute_proximal` in `engine.py::retrieval`. Query-time only — no storage. Blended relevance: α·(1/d) + (1−α)·cosine(seed_vec, target_vec). `config.PROXIMAL_ALPHA = 0.5` as named default, env-overridable via `BORAI_PROXIMAL_ALPHA`. Fallback to pure decay is a single env flip. Dedup across seeds: highest relevance wins. Scope-free by design — `query()` always includes proximal alongside `traverse_neighbours`. 8 new tests (including degenerate α=0 / α=1 / α=0.5 cases). Full suite: 117 passing.
- [x] **2026-04-24 — Two-layer tag system landed.** YAML frontmatter parser in `chunker.py` (minimal, supports scalars and block lists). `_mint_tags` derives `source_type:`, `campaign:`, `chapter:`, `status:` from path + frontmatter. `_merge_tags` strips reserved prefixes from the author layer so the minted layer stays sovereign. `chunk_file` now attaches merged tags to every chunk's metadata. `GraphSnapshot.nodes_with_tag(tag)` surfaces node ids across both layers uniformly. 9 new tests. Full suite: 126 passing.
- [x] **2026-04-24 — Progressive data stream shipped.** `ShallowResult` dataclass alongside `RetrievalResult`; `RetrievalResult` gained a `node_id` field so shallow conversion has a stable expand handle. `query(mode="shallow" \| "full")` with `"shallow"` as the default — breaking API change, opt-in for callers that need content in the initial response. `engine.expand(handle)` fetches full body post-hoc. Query cache key now scopes by mode. One existing test updated to `mode="full"`. 7 new tests. Full suite: 133 passing.
- [x] **2026-04-24 — Four cheap riders bundled.** (1) Embedder migrated from deprecated `/api/embeddings` to `/api/embed` — response shape now `{"embeddings": [[...]]}`, request key `input` not `prompt`. All embedder tests updated. (2) Hardcoded `/mnt/skills/`, `/borai/code/`, `/borai/products/`, `/borai/posts/` path rules deleted from `infer_source_type`; extension fallback covers them identically. `/mnt/transcripts/` and `/borai/funding/` retained — their chunkers are format-specific and not extension-inferable. (3) `initial_bulk_ingest` now enumerates files up front, logs `scanning N paths, M files` at start and `processed X/M files (Y%)` either every 60 s or at completion — whichever comes first. Required extracting a `Pipeline.iter_files` generator so the count is known pre-flight. (4) BorAI pre-push hook's typecheck step now guarded with `--if-present` so scaffold apps without a `typecheck` script don't fail the hook. Full suite: 135 passing.
- [x] **2026-04-24 — Atomic commits on `feat/near-proximal-stream`.** Three beats landed: `ce67333` (near edge), `0097a0a` (retrieval layer refactor — proximal + tags + data stream), `750558c` (riders — embedder + path-rule purge + progress logs). BorAI pre-push hook fix committed separately on BorAI `main` at `be42e6e` (not yet pushed — awaiting graph validation).
- [x] **2026-04-24 — Docker rebuild landed, reingest running.** First attempt with `docker compose up -d --build` produced a stale image — BuildKit cache masked the source edits (the repeat-offender landmine from yesterday). Second attempt with `docker compose build --no-cache` + `up -d` picked up the new code, verified by `grep -n "files to process"` inside the running container. Fresh volume, 151 files to process, ingest running at ~13 files/min under the new schema. Progress log fires every 60 s as designed.
- [x] **2026-04-24 — Ingest complete under new schema.** 151/151 files at 00:38:22 (18m 40s). Graph: 3,968 nodes / 144,482 edges — **89% edge-count reduction from 1,614,528**. Zero follows/precedes (as intended). 7,640 near (≈1.9 per node — within-file adjacency). 136,842 relates_to. Watcher live on /watch/vault:/watch/borai-ops:/watch/skills.
- [x] **2026-04-24 — Scope-fix commit (`5df0ea9`ish).** End-to-end validation caught a live bug: `AGENT_EDGE_SCOPES` still referenced the deleted `follows`/`precedes` types for `build_in_public_engine` and `hackathon_radar` scopes. Those agents would have silently returned zero scoped neighbours under the new schema. Replaced both with `near` across every scope; added `near` to `DEFAULT_AGENT_SCOPE`. Test suite still 135 green; container rebuilt.
- [x] **2026-04-24 — End-to-end validation green.** Full-mode query `"temporal edge decision"` returned 53 results split as `{seed: 5, near: 10, proximal: 14, relates_to: 24}` — every mechanism firing, clean provenance in `r.reason`. Proximal scores sensible (0.35–0.37 range) given α=0.5 blend with embedding cosine on within-file siblings. `funding_tracker` query for `"Korea F-6 founder visa"` surfaces `references/founder-profile.md` + `references/eligibility-checker.md` at 0.79 similarity — tag-scoped routing behaves as intended.
- [ ]

### What's changing?

-

---

## Conclude

### How is now different from the start?

At session open the graph was 3,916 nodes / 1,614,528 edges, 91.6% of them the every-pair mtime-driven `follows`/`precedes` bloat — a ranker drowning in within-directory noise. At session close the graph is being rebuilt under a four-part model: `near` (stored, d=1, within-file, bidirectional); `proximal` (computed at query time, d>1, blended α·(1/d) + (1−α)·cosine); two-layer tags (author YAML + reserved-prefix indexer-minted); progressive data stream (shallow-first retrieval with `expand()` on demand). The query API's default mode is now shallow — a deliberate breaking change that inverts the "give me everything" posture into "surface me the names first."

### What are the consequences?

**For retrieval quality.** The ranker stops competing for attention with 425 edges per node. The new signal is differentiated — same-file siblings split into d=1 (always the closest prior, cheap to traverse) vs d>1 (relevance-ranked, computed only when the query needs them). The blend over pure decay was the founder's call against the sage's recommendation; α = 0.5 is the starting position, fallback to pure decay is a one-env-flip away if it proves unstable.

**For callers.** `query()` is now progressive by default. Every skill one-liner calling `engine.query(...)` today returns shallow results — tags and handles, not content. Callers must pass `mode="full"` to get bodies in one call, or call `engine.expand(handle)` on the shallow result. This is a breaking change; skill one-liners in `~/.claude/commands/` need updating in the next PR.

**For tagging.** The vault can now be queried by path-derived structure (`campaign:command-centre`, `chapter:02a-systems-and-tools`, `source_type:note`) without depending on whatever the author remembered to type into the YAML. The two layers coexist via a reserved-prefix contract — author tags that collide with reserved prefixes get stripped at ingest.

**For the riders.** Embedder ready for batched `/api/embed`. Ingest emits periodic progress so the next 17-minute run isn't a black box. The vestigial `/mnt/skills/` path rules are gone from `infer_source_type` — the extension fallback carried them anyway.

### What did we learn?

- **The retrospective's "cap at 1" recommendation was conservative.** The call that actually earned its place was splitting the signal in two — cheap stored contract at d=1, richer computed signal at d>1. "Become more specific, not less" was a better design frame than "cut the noise."
- **The blend's cost is α-tuning, not compute.** The embeddings are already paid for at ingest; using them at retrieval time is free. The real tax is retuning α per query type, which the project deferred by naming a sensible default and an env-var escape hatch.
- **Shallow-by-default is load-bearing for the webapp.** Making the data stream progressive means the webapp's first render is a list of candidate results with tags, not a token-budget fight over chunk bodies. The shape of the retrieval API is now the shape the webapp needs.
- **The Docker cache landmine is real and costs ~17 minutes per hit.** Even a `docker compose up -d --build` can keep stale source if the COPY layer's cache key doesn't invalidate — today it hit once, recovered with `build --no-cache`. This is a repeat offender from yesterday's session; worth a one-line comment in the compose file's header.

### Progress to thesis

Specificity compounds. A retrieval engine that treats `follows`/`precedes` as a single undifferentiated stream is a retrieval engine that cannot tell sibling-that-matters from sibling-that-happens-to-share-a-file. Splitting the signal is the thesis running at the infrastructure layer — the founder's tool becomes more sophisticated *because the founder noticed the undifferentiated stream was noise*, not because a better algorithm arrived. The webapp's first user — the founder — will feel the difference the moment they query.

### Progress to goal

Chapter 2a's infrastructure layer now has a retrieval engine that can honestly carry a product on top. The webapp climax (Scene 02a-06+) can open when this PR lands and the four skill one-liners in `~/.claude/commands/` are updated to the new API. The skill-update beat is the natural opener for whichever next scene comes first — could ride with Scene 04 (delegate-agent integration) or land as a short scene of its own.

### Next scene

Either Scene 2a-04 (scrapers into delegate-agent — delayed since Chapter 1 Scene 05) or a short scene updating the four agent skills (`build-in-public-engine`, `funding-tracker`, `hackathon-radar`, `delegate-agent`) to the new `mode="full"` or shallow+expand pattern. The skill update is small enough to ride with Scene 04, so leaning 2a-04 next.

### Artifact format

Thread, essay, and newsletter. The three map to three registers for the same story:
- **Thread** — the 91.6% → specificity punch. Lead with the edge-count drop, land on *become more specific, not less*.
- **Essay** — the progressive-data-stream design choice, argued at length. The sage's pure-decay recommendation, the founder's blend override, α as the open question, and why the breaking API change earns its place.
- **Newsletter** — narrative of the whole session: from the retrospective's three options, through the fourth shape that emerged, to the graph that now carries a webapp.

---

## Notes

*Free space.*
