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

The infrastructure that makes the product possible. Command Centre is currently markdown + founder discipline. This chapter installs the systems underneath so the webapp can stand on real infrastructure. Four pieces in scope:

1. **ai-swarm-infra** — set up. Python skeletons became a running distributed swarm across the home cluster (Ryzen Coder + MacBook Reviewer + this machine as Orchestrator).
2. **browser-bot** — the consolidation of `fast-travel-cli` and the delegate-agent scraper work into a single context-hygiene service. The two prior tools converged once the operational pattern was clear; browser-bot is what they became.
3. **borai-rs Rust DePIN coordinator** — the software infrastructure for context-hygiene and LLM-data management at scale. Lives at `ops/borai-cc/borai-rs/` on the monorepo (the throwaway `~/borai.cc` local checkout that hosted earlier slices is **retired**, per Scene 06). Coordinator + node + Leptos+WASM frontend; PoC verification, capability-aware reputation dispatch, and Postgres+pgvector storage all green.
4. **Command Centre webapp MVP** — the original Chapter 2 plan from `campaign.md`. Set Stage + Conclude only.

The webapp is this chapter's **climax**; the swarm, browser-bot, and the Rust coordinator are the scaffolding it rests on.

## Thesis progress

Chapter 1 tested the method with paying-client work anchoring it. Chapter 2a removes the external client and tests whether the method still produces publishable narrative when the only user is the founder. If yes, the method is a method. If no, the method was a client-facing ritual mistaken for a general one.

## Scenes

- [ ] **01 — ai-swarm hello-world** — Single Coder→Reviewer round-trip across the home cluster. Opens on orchestrator code + tutorials already committed on `feature/ai-swarm-infra-impl`; closes when the first end-to-end run completes.
- [x] **01b — ai-swarm hardening** — Sibling to 01. Tier 1+2 shipped: pre-flight probe, `keep_alive`, Reviewer persona tightening, retry policy, test coverage, dockerised orchestrator, structured logging, streaming. Tier 3 (multi-round, model routing, auth, HTTP API) carried to 01c.
- [x] **01c — ai-swarm extensions** — Tier 3 shipped: FastAPI wrapper (3.12), multi-round refinement (3.9), model routing (3.10), LAN auth orchestrator side (3.11). Worker-side auth proxy deferred to operational deploy. All twelve gap items across 01b+01c closed; chapter substrate debt cleared.
- [x] **02 — reaching-past-claude** — `fast-travel-cli` (Gemini, standalone Rust binary, live build) and `ghostroute` (monorepo of providers — Grok documented, Perplexity scaffolded, more to come) shipped as the context-hygiene layer. Unblocks Scene 07.
- [x] **03 — near-proximal-and-the-stream** — borai-graph edge model split into stored `near` (d=1) and computed `proximal` (d>1 with blended relevance). Adds a two-layer tag system (author YAML + reserved-prefix indexer-minted) and a progressive data-stream retrieval mode. Cheap indexer riders ship in the same PR. Runs parallel to Scene 02.
- [ ] **04 — borai-graph-ship retroactive** — Files the orphaned `artifacts/borai-graph-ship/` set (research-paper, retrospective, twitter-thread) shipped 2026-04-23 into the scene structure. Reconstructs Set Stage from the artefacts; Conclude same-day.
- [ ] **05 — claude-code edge bridge** — Hybrid: a custom Ollama image with `nomic-embed-text` baked in, a `borai-graph-query` CLI entry point, and a host-side Claude Code subprocess bridge for semantic edge enrichment via `host.docker.internal`. Bridge is the central beat; CLI + image ship as riders.
- [x] **06 — the handoff board** — Five-task parallel-handoff dispatched across Codex (sandbox-DOA → Claude subagent fallback), Gemini, Copilot, and Claude subagents in isolated git worktrees off a contract-freeze prework commit. Ships the BorAI Rust workspace (coordinator + node + Leptos+WASM frontend) and the `forks/` submodules (mem0, litellm, chonkie). Eight commits, one PR, fast-forward merge to `origin/main` at `ops/borai-cc/`. Retires `~/borai.cc` as a local checkout — BorAI ops work now lives in the monorepo.
- [ ] **07 — Scrapers into delegate-agent** — Integrates `fast-travel-cli` and `ghostroute` into delegate-agent routing. Unblocks the delegation path Chapter 1 Scene 05 flagged as dead. *(was 04, then 06)*
- [ ] **08 — v0.3 lands on main** — The hour the parallel v0.3 SPORE worktrees were consolidated onto one `origin/main`: separated infra/WIP commits, six worktree merges, full test gate (cargo 409 / pytest 44), origin reconcile, push, worktree + branch cleanup. Retroactive-leaning; Conclude pending. *(new — see scene 2a-08)*
- [ ] **09 — Two-layer orchestration pattern** — Scene on the fractal-dispatch pattern the Scene 07 work itself demonstrated. Raw material in `docs/handoffs/2026-04-21-two-task-force-dispatch-close.md`. *(was 05, then 07, then 08)*
- [ ] **10+ — Command Centre webapp MVP** — Set Stage + Conclude only, per `campaign.md`. Chapter 2a's climax. Exact scene count TBD during build. *(was 06+, then 08+, then 09+)*

## Climax

The Command Centre webapp shipping its first Set Stage + Conclude round. The moment the vault's own product can open a scene and close it inside the app — not via the markdown files directly. That is Chapter 2a's answer to the question *does the method still work without a client*.

## Constraints for this chapter

- **Runs in parallel with [[02b-products-that-sell]].** Scenes may cross-reference; neither chapter blocks the other.
- **Webapp stays thin.** Set Stage + Conclude only. Capture layer belongs to Chapter 3 (*The watcher*). Publication layer belongs later still.
- **Infra precedes product.** ai-swarm and scraper scenes close before the webapp scene opens, unless a deliberate inversion is named in that scene's Set Stage.
- **Honest scaffold state.** Every scene names whether its output is *runnable*, *structural only*, or *in progress*. No implying readiness ai-swarm did not have when Scene 05 ingested it.

## Carry-over to Chapter 3

- *(Filled at chapter close)*
