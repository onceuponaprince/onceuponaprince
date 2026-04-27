---
type: campaign
campaign: agent-architecture
title: "Agent Architecture"
status: in-progress
date_opened: 2026-04-23
graduated_from: "research/agent-architecture/"
date_graduated: 2026-04-27
thesis_one_liner: "Agent architecture is a spectrum, not a choice — and the correct position on it changes per task, not per product."
universe: "yurika, the-guild, agency"
tags:
  - campaign
  - research
  - agents
  - lateral-graduated
---

# Campaign: Agent Architecture

*A living research campaign. Started lateral at `research/agent-architecture/` on 2026-04-23. Graduated to its own campaign 2026-04-27 when Episode 2 committed.*

## Thesis (claim under test)

> **Agent architecture is a spectrum, not a choice — and the correct position on it changes per task, not per product.**

If the claim holds, the implication is uncomfortable: most teams are committing to a position at the product level when they should be varying it at the task level. If it falls, the more defensible product-level commitments stand.

## Episodes

Each episode is a research file in `episodes/`. Each opens a question; the cold round answers it; the synthesis stands as the episode's load-bearing record.

| # | Episode | Status | Verdict |
|---|---|---|---|
| 1 | [Context and granularity](episodes/01-context-and-granularity.md) | Synthesised 2026-04-23 | Claim holds. Spectrum is real, position task-contingent, framework primitives mostly exist, *router that picks per task* is the genuine open problem. |
| 2 | [The router we cannot yet build](episodes/02-the-router-we-cannot-yet-build.md) | Synthesised 2026-04-27 | Claim holds with reframing: v0 buildable today is **rules + instrumentation, not a model**. Taxonomy and labels are the bottleneck, not the classifier. |

## Pilot

`pilot.html` at the campaign root carries the publishable artefact. Single self-contained HTML, hybrid essay + interactives. Builds incrementally, one interactive per episode.

| # | Interactive | Episode | Status |
|---|---|---|---|
| 1 | Topology switcher (four-axis policy) | 1 | Shipped |
| 2 | Router-in-a-box (rules + confidence + fallback) | 2 | Pending |
| 3+ | Drift/context slider, walkthrough, coordination visualiser, cost/quality scatter | TBD | Queued |

## Decisions

`decisions/` holds ADRs distilled from the research. None yet — synthesis is a map of the field, not a commitment to ship anything. ADRs land when an interactive build or a real system implementation forces an architectural choice. The Episode 3 candidate question (*should we build a v0 router for BorAI right now?*) is the most likely trigger for the first ADR.

## Sources

`sources/` holds the raw multi-source dumps from each episode's cold round. Show-your-work posture: nothing rewritten, nothing summarised. The synthesis is a reading of these dumps; the dumps are the evidence the reading rests on.

## Method

Each episode follows the `living-research` skill (`~/.claude/skills/living-research/`):

1. **Intake** — six-question clarifying loop on subject, location, depth, output, claim, episode boundary.
2. **Scaffold** — the directory above, populated from templates.
3. **Cold round** — seven sources fired in parallel via subagents (Gemini, Perplexity, Claude cold, Grok, Copilot, Cursor, ChatGPT). Raw dumps land in `sources/YYYY-MM-DD-<source>.md`.
4. **Synthesise** — Claude reads all dumps, drafts verdict + per-sub-question + closing + commitments into the episode file.
5. **Pilot** — interactive added to `pilot.html` per the synthesis's commitments paragraph.
6. **ADRs and graduation** — ADRs land in `decisions/` when forced; campaign already graduated on Episode 2.

This campaign is the first living-thread to graduate; the methodology was codified into the skill *during* Episode 2 and applied to its own ongoing work as a smoke-test.

## Voice and posture

British English, sophisticated, declarative. No marketing speak. The synthesis is a *direct call* on the claim — no consensus-safe mush. Episode 1's verdict is `holds`; Episode 2's is `holds with reframing`. Both stay declarative.

The campaign's load-bearing line, surfaced by Grok in Episode 1: *"the correct position changes per task — but building the router that reliably knows is the real unsolved primitive."* Episode 2 took that line as its question and answered it: *"the router is buildable, but the router that pays off first is rules and instrumentation, not a model."*

## Out of scope (campaign-wide)

- Model-architecture research (LLM internals, attention mechanisms, MoE)
- Tool-vendor reviews ("which LLM is best for X")
- Agent-as-product debates (Devin vs Cursor vs Cognition aesthetics)

This campaign is about *the routing primitive between architectures*, not the architectures themselves.
