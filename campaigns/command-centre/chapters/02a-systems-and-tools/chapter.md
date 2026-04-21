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

The infrastructure that makes the product possible. Command Centre is currently markdown + founder discipline. This chapter installs the systems underneath so the webapp can stand on real infrastructure. Three tools in scope:

1. **ai-swarm-infra** — Python skeletons become a running distributed swarm across the home cluster (Ryzen Coder + MacBook Reviewer + this machine as Orchestrator).
2. **Grok scraper** — integrated into delegate-agent routing to replace the exhausted xAI credits Scene 05 flagged as dead.
3. **Command Centre webapp MVP** — the original Chapter 2 plan from `campaign.md`. Set Stage + Conclude only.

The webapp is this chapter's **climax**; ai-swarm and the scraper are the scaffolding it rests on.

## Thesis progress

Chapter 1 tested the method with paying-client work anchoring it. Chapter 2a removes the external client and tests whether the method still produces publishable narrative when the only user is the founder. If yes, the method is a method. If no, the method was a client-facing ritual mistaken for a general one.

## Scenes

- [ ] **01 — ai-swarm hello-world** — Single Coder→Reviewer round-trip across the home cluster. Opens on orchestrator code + tutorials already committed on `feature/ai-swarm-infra-impl`; closes when the first end-to-end run completes.
- [ ] **02 — Grok scraper into delegate-agent** — Integrates `~/code/scraper/` into delegate-agent routing. Unblocks the delegation path Scene 05 flagged as dead.
- [ ] **03 — Two-layer orchestration pattern** — Scene on the fractal-dispatch pattern the Scene 04/05 work itself demonstrated. Raw material in `docs/handoffs/2026-04-21-two-task-force-dispatch-close.md`.
- [ ] **04+ — Command Centre webapp MVP** — Set Stage + Conclude only, per `campaign.md`. Chapter 2a's climax. Exact scene count TBD during build.

## Climax

The Command Centre webapp shipping its first Set Stage + Conclude round. The moment the vault's own product can open a scene and close it inside the app — not via the markdown files directly. That is Chapter 2a's answer to the question *does the method still work without a client*.

## Constraints for this chapter

- **Runs in parallel with [[02b-products-that-sell]].** Scenes may cross-reference; neither chapter blocks the other.
- **Webapp stays thin.** Set Stage + Conclude only. Capture layer belongs to Chapter 3 (*The watcher*). Publication layer belongs later still.
- **Infra precedes product.** ai-swarm and scraper scenes close before the webapp scene opens, unless a deliberate inversion is named in that scene's Set Stage.
- **Honest scaffold state.** Every scene names whether its output is *runnable*, *structural only*, or *in progress*. No implying readiness ai-swarm did not have when Scene 05 ingested it.

## Carry-over to Chapter 3

- *(Filled at chapter close)*
