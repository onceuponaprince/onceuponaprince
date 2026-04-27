# Agent architecture — living research campaign

**Status: graduated to campaign 2026-04-27. Episodes 1 and 2 synthesised. Pilot Interactive 1 (topology switcher) shipped; Interactive 2 (router-in-a-box) queued. Originally lived as `research/agent-architecture/` from 2026-04-23; preserved in git history. See `campaign.md` for the campaign's metadata + episode index.**

## What this is

A lateral research thread exploring the tradeoff between context-rich monolithic LLMs and granular single-task agents — with the space between them as the interesting territory. Framed as living research in the television sense: episodes that each stand alone, together forming a wider map. Unlike `emotional-ux-pilot/`, this thread is born living — the directory is built to grow.

The claim under test is stated once and tested across episodes:

> **Agent architecture is a spectrum, not a choice — and the correct position on it changes per task, not per product.**

If the claim holds, the implication is uncomfortable: most teams are committing to a point on the spectrum at the product level when they should be varying it at the task level. If the claim falls, the more defensible product-level commitments stand.

## How to read it

- For the framing question, read this file.
- For the current episode, open `episodes/01-context-and-granularity.md`.
- For the publishable artifact (once built), open `pilot.html` in a browser.
- For raw per-source research dumps before synthesis, see `sources/`.
- For working architecture decisions distilled from the research, see `decisions/`.

## Structure

```
campaigns/agent-architecture/
├── README.md              — this file
├── episodes/              — one file per episode; each a standalone research question
├── sources/               — raw multi-model + web research dumps, named by date and source
├── decisions/             — ADR-style architecture decisions made from the research
└── pilot.html             — the publishable artifact (single self-contained HTML,
                            accretes interactives one episode at a time)
```

## Research method

Each episode follows the same routing:

1. A single research brief goes to six sources cold and in parallel — Gemini, Claude (as a cold source), Grok, Copilot CLI, Cursor Agent, Perplexity. Each has a routing role (literature, current practice, contrarian read, framework specifics).
2. Raw dumps are saved to `sources/` as `YYYY-MM-DD-<source>.md`. Nothing is rewritten.
3. Targeted web fetches cover specific named frameworks (LangGraph, AutoGen, CrewAI, Claude Agent SDK, OpenAI Agents SDK, Pydantic AI — manifest updated per episode).
4. Claude synthesises. Synthesis lands in the episode file and, when appropriate, in a consolidated `research-notes.md` per episode.
5. Interactives for the episode ship one-by-one into `pilot.html`.

The rule is *show your work* — raw dumps stay in `sources/` even when superseded. The synthesis is a reading of the sources, not a replacement.

## Publishable and spec outputs

Three outputs roll out on different cadences:

1. **ADRs** — working architectural decisions for BorAI and vault tooling accrete in `decisions/` as the research answers real questions.
2. **Formal design spec** — forks out to `docs/superpowers/specs/YYYY-MM-DD-agent-architecture-design.md` when the spectrum stabilises into actionable architecture.
3. **Generic framework template** — emerges after enough episodes; a reusable shape others can adopt.

## Posture

Episode 1 used the *wait-and-fire-cold* posture (all seven sources fired cold in one parallel pass). Episode 2 used the same posture but landed five-of-seven sources due to environment failures (Perplexity and Grok both blocked on Chromium launch — see source files for unblock paths). Later episodes may adopt different postures; the choice is recorded per episode.

## Relationship to Command Centre

Originally lateral (sibling to `emotional-ux-pilot/`), now its own campaign. Triggered as a new line of enquiry on 2026-04-23. Graduated to `campaigns/` on 2026-04-27 when Episode 2's synthesis committed.

Decisions made via this campaign may feed specific future scenes — agent architecture for BorAI Knowledge Graph follow-on work, the webapp layer, future Yurika products. Those future scenes, when opened, can reference the relevant ADR in `decisions/` via the `spec_file` frontmatter key. The Episode 3 candidate question (*should we build a v0 router for BorAI right now?*) is the most likely trigger for the first ADR.

## Graduation (complete)

This campaign graduated from `research/agent-architecture/` to `campaigns/agent-architecture/` on 2026-04-27 when Episode 2's synthesis committed. Per the per-thread-graduation rule. The original `research/` tree is preserved in git history; current state lives here. See `campaign.md` for campaign metadata.
