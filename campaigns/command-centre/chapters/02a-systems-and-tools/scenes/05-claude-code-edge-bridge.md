---
campaign: "[[command-centre]]"
chapter: "02a-systems-and-tools"
scene: 05
title: "claude-code edge bridge"
status: in-progress
date_opened: 2026-05-01
date_concluded: 
characters:
  - "[[prince]]"
  - "[[solo-thesis-holder]]"
spec_file: null
blockers: []
supersedes: null
artifacts: []
tags:
  - chapter-2a
  - borai-graph
  - claude-code
  - subprocess-bridge
  - cli
  - docker-image
---

# Scene 2a-05 — claude-code edge bridge

*Chapter 2a — Systems and tools · Campaign: [[command-centre]]*

*The borai-graph graduates from "shipped" to "polished and semantically smart": a host-side Claude Code subprocess bridge enriches edge classification at subscription cost, a `borai-graph-query` CLI replaces the Python one-liner, and a custom Ollama image bakes the embedding model in for fresh clones. Bridge is the central beat; CLI and image ship as riders.*

---

## Set the Stage

### How did we get here?

Scene 03 (`near-proximal-and-the-stream`) shipped the borai-graph retrospective's highest-leverage refactor: stored `near` (d=1) + computed `proximal` (d>1 with blended relevance), the two-layer tag system, the progressive data-stream retrieval mode, plus four cheap riders from the retrospective's "next session" list (`/api/embed` migration, hardcoded path-rule deletion, periodic progress logs, pre-push hook fix). The retrospective's improvements 1–5 are now done.

Three open beats remain:

- **#6** — Bake the embedding model into a custom Ollama image, saving the 5-minute first-boot pull for fresh clones.
- **#7** — A proper `borai-graph-query` CLI entry point (currently requires a Python one-liner).
- **#8** — Claude Code subprocess bridge for semantic edge enrichment, replacing the absent Haiku fallback the original spec planned for.

The bridge is the central beat — it changes the *quality* of the graph's edges by routing semantic-relationship judgement through Claude Code at subscription cost rather than per-token API. The CLI and image are riders that improve ergonomics for anyone (founder included) standing up the stack.

### Where are we going?

Three changes shipped behind one PR to `main` on `~/code/BorAI`:

1. **Custom Ollama image.** A `Dockerfile.ollama` derived from `ollama/ollama:0.4.4` that runs `ollama serve & sleep 5 && ollama pull nomic-embed-text` during build, baking the 274 MB model into the image. Fresh clones boot in seconds rather than five minutes.
2. **`borai-graph-query` CLI.** Replaces the Python one-liner with a real command surface. Exact verbs and flag shape decided during implement-and-discover (see *What's changing?*), but the minimum viable surface is `borai-graph-query --agent <slug> "<query text>"` with a JSON-or-pretty output toggle.
3. **Claude Code subprocess bridge.** A small HTTP service running on the host that accepts chunk pairs and returns JSON edge classifications. The borai-graph container reaches it over `host.docker.internal` (with Linux `extra_hosts: host.docker.internal:host-gateway` mapping per the research-paper's footnote). The bridge holds Claude Code auth on the host; the container stays hermetic.

Scene closes when the new image builds and is referenced by `docker-compose.yml`, the CLI is invokable end-to-end against the live graph, the bridge classifies a non-trivial chunk pair correctly, and the PR lands on `main`.

### State of the world (project context)

borai-graph stack running locally on commodity CPU. PRs #3, #4, #5 merged on `~/code/BorAI`. Latest stats flush: 3,916 nodes / 1,614,528 edges / Ollama reachable. Two containers: `borai-ollama` (the embedding model server) + `borai-graph` (the indexer + retrieval daemon). Watcher live-indexing within ~1 second of file change.

Host: Linux Docker (not Docker Desktop), so `host.docker.internal` does not resolve by default — the `extra_hosts: host.docker.internal:host-gateway` mapping in `docker-compose.yml` is mandatory for the bridge to be reachable from inside the container. Claude Code installed and authed on the host with subscription cost in place; the bridge inherits that auth via its position on the host filesystem.

Chapter 02a's checklist updates as part of scene 04's commit — slots 04 and 05 become these two scenes, the previously-planned Scrapers (was 04) and Two-layer (was 05) shift to 06 and 07, webapp moves to 08+.

### State of the hero ([[solo-thesis-holder]])

Three different leverage points on one persona. The CLI helps the hero **use** the graph — query it without copy-pasting a Python invocation, get readable output. The baked image helps the hero **stand up** the graph — clone the repo, `docker compose up`, productive within minutes rather than a quarter-hour. The bridge helps the graph **be smart** for the hero — semantic edges that catch thematic echoes the rules-only detector misses, raising retrieval quality on the kind of cross-chapter queries the hero will actually run.

The universalisable beat: the difference between *shipped* and *serious*. Shipped means it works once, on your machine, for you. Serious means a stranger can clone it tonight and have it answering their queries with semantically meaningful results by morning. This scene closes that gap.

### State of the protagonist ([[prince]])

*TODO — founder to write.*

*Ask: 2-3 sentences. The bridge is interesting infrastructure but it's also the kind of work that can sprawl — host-side service, container reach pattern, auth surface, error handling for the Claude Code subprocess. What's your headspace for that scope today? Energetic and ready to discover the design? Conservative and want to ship the ergonomic riders first and earn the bigger beat? Tired and this is realistically a two-session scene? The honest answer shapes the goal-bullets below.*

### This moment in relation to goals

Chapter 02a's penultimate-borai-graph beat before the narrative pivots to the scrapers work (now scene 06). With this scene closed, borai-graph is no longer just *the thing that was shipped two weeks ago* — it is a piece of load-bearing infrastructure that any subsequent agent skill or automation in chapter 02a can rely on for both pleasant ergonomics and semantically rich retrieval. The webapp climax (scene 08+) becomes more plausible because the agent layer it will surface has a graph behind it that is genuinely worth surfacing.

### Why now?

*TODO — founder to write.*

*Ask: 2-3 sentences. The retrospective surfaced these three open beats fifteen days ago. Why this session, not the one after the scrapers work? Is the bridge the unblock for some specific agent skill that's underperforming? Is the CLI ergonomic gap finally biting? Is this the natural shape of the next two hours? The Why-now answer changes the scene's pacing — pre-emptive infra is a different rhythm from forced-by-friction infra.*

---

## Progress the moment

### Goal for this session

*Implement-and-discover: the design choices for each sub-beat land during capture, not here. The bullets below are the minimum scope; the founder picks which sub-beats are in vs. deferred to a follow-on scene.*

- [ ] **Custom Ollama image** — `Dockerfile.ollama` written, build succeeds locally, image referenced from `docker-compose.yml`, fresh-clone first boot ≤ 30s.
- [ ] **`borai-graph-query` CLI** — entry point scaffolded, at least one query verb working end-to-end, output format chosen and documented.
- [ ] **Claude Code subprocess bridge** — host service running, container reaches it via `host.docker.internal`, one non-trivial chunk pair classified correctly with a `relates_to` edge added to the graph.
- [ ] **End-to-end test** — `docker compose up`; CLI query; query response includes a semantic edge the bridge classified.
- [ ] PR opened from `feature/<branch>` on `~/code/BorAI` to `main`; merged on approval.

*Founder ask: which of these five bullets stay in for this session, and which (if any) defer to a follow-on scene? The bridge is the central beat; the CLI is half-day; the custom image is hour-of-work; the e2e test depends on all three landing. If scope needs to shrink, the natural cuts are the e2e test (defer to a verification scene) and the custom image (orthogonal hour of work).*

### Moment-by-moment capture

- [x] Scene opened, Set Stage drafted (2026-05-01).
- [ ] Founder fills *State of the protagonist*, *Why now?*, and the goal-scope decision.
- [ ] Branch cut from `~/code/BorAI` `main`.
- [ ] *(further entries land during work)*

### What's changing?

*Implement-and-discover: this section fills as the design choices land. Open questions for now:*

- **CLI surface.** Single `borai-graph-query` binary with subcommands, or one-shot CLI with flags? Output: pretty-printed by default, `--json` for machine-readable, or the inverse?
- **Bridge protocol.** REST with JSON bodies, or unix domain socket with newline-delimited JSON? Auth: assume localhost-only and no auth, or token-in-header? Error shape: HTTP status codes, or always-200 with `{ok: bool, error: ...}`?
- **Bridge invocation pattern.** Per-pair synchronous calls during ingest, or batched async with a queue? The synchronous version is simpler; the batched version is what the production system will eventually want.
- **Edge enrichment trigger.** Run the bridge on every chunk pair where rule evidence is thin, or only on demand (a flag on `borai-graph-query`)? On-by-default is more useful; on-demand is cheaper and easier to reason about during development.

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
