---
campaign: "[[command-centre]]"
chapter: 02a
title: "Systems and tools"
status: in-progress
date_opened: 2026-04-21
date_concluded: 
climax_artifact: 
tags:
  - chapter
  - chapter-2a
  - systems
  - tools
  - infrastructure
---

# Chapter 02a — Systems and tools

*Campaign: [[command-centre]] · Runs concurrently with [[02b-products-that-sell]]*

## Arc

The infrastructure that makes the product possible. Command Centre is currently markdown + founder discipline. This chapter installs the systems underneath so the webapp can stand on real infrastructure. Four tools in scope:

1. **ai-swarm-infra** — Python skeletons become a running distributed swarm across the home cluster (Ryzen Coder + MacBook Reviewer + this machine as Orchestrator).
2. **Reaching past Claude** — `fast-travel-cli` (Gemini, Rust) and `ghostroute` (Grok, Node) shipped as sibling CLI tools in the same context-hygiene layer.
3. **Delegate-agent integration** — wires the scrapers into delegate-agent routing, replacing the exhausted xAI credits Scene 05 flagged as dead.
4. **Command Centre webapp MVP** — the original Chapter 2 plan from `campaign.md`. Set Stage + Conclude only.

The webapp is this chapter's **climax**; ai-swarm, the scrapers, and the delegate-agent wiring are the scaffolding it rests on.

## Thesis progress

Chapter 1 tested the method with paying-client work anchoring it. Chapter 2a removes the external client and tests whether the method still produces publishable narrative when the only user is the founder. If yes, the method is a method. If no, the method was a client-facing ritual mistaken for a general one.

## Scenes

- [ ] **01 — ai-swarm hello-world** — Single Coder→Reviewer round-trip across the home cluster. Opens on orchestrator code + tutorials already committed on `feature/ai-swarm-infra-impl`; closes when the first end-to-end run completes.
- [x] **02 — reaching-past-claude** — `fast-travel-cli` (Gemini, standalone Rust binary, live build) and `ghostroute` (monorepo of providers — Grok documented, Perplexity scaffolded, more to come) shipped as the context-hygiene layer. Unblocks Scene 04.
- [x] **03 — near-proximal-and-the-stream** — borai-graph edge model split into stored `near` (d=1) and computed `proximal` (d>1 with blended relevance). Adds a two-layer tag system (author YAML + reserved-prefix indexer-minted) and a progressive data-stream retrieval mode. Cheap indexer riders ship in the same PR. Runs parallel to Scene 02.
- [ ] **04 — Scrapers into delegate-agent** — Integrates `fast-travel-cli` and `ghostroute` into delegate-agent routing. Unblocks the delegation path Scene 05 flagged as dead.
- [ ] **05 — Two-layer orchestration pattern** — Scene on the fractal-dispatch pattern the Scene 04/05 work itself demonstrated. Raw material in `docs/handoffs/2026-04-21-two-task-force-dispatch-close.md`.
- [ ] **06+ — Command Centre webapp MVP** — Set Stage + Conclude only, per `campaign.md`. Chapter 2a's climax. Exact scene count TBD during build.

## Climax

The Command Centre webapp shipping its first Set Stage + Conclude round. The moment the vault's own product can open a scene and close it inside the app — not via the markdown files directly. That is Chapter 2a's answer to the question *does the method still work without a client*.

## Constraints for this chapter

- **Runs in parallel with [[02b-products-that-sell]].** Scenes may cross-reference; neither chapter blocks the other.
- **Webapp stays thin.** Set Stage + Conclude only. Capture layer belongs to Chapter 3 (*The watcher*). Publication layer belongs later still.
- **Infra precedes product.** ai-swarm and scraper scenes close before the webapp scene opens, unless a deliberate inversion is named in that scene's Set Stage.
- **Honest scaffold state.** Every scene names whether its output is *runnable*, *structural only*, or *in progress*. No implying readiness ai-swarm did not have when Scene 05 ingested it.

## Carry-over to Chapter 3

- *(Filled at chapter close)*
