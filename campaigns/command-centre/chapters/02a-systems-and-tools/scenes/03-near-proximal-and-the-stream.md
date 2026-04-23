---
campaign: "[[command-centre]]"
chapter: "02a-systems-and-tools"
scene: 03
title: "near-proximal-and-the-stream"
status: in-progress
date_opened: 2026-04-23
date_concluded:
characters:
  - "[[prince]]"
  - "[[solo-thesis-holder]]"
spec_file: "artifacts/borai-graph-ship/retrospective.md"
blockers: []
supersedes: null
artifact_format:
artifact_file:
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
- [ ]

### What's changing?

-

---

## Conclude

*Filled at end of session.*

### How is now different from the start?

### What are the consequences?

### What did we learn?

### Progress to thesis

### Progress to goal

### Next scene

### Artifact format

*Thread / newsletter / video / essay / none.*

---

## Notes

*Free space.*
