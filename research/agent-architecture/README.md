# Agent architecture — living research

**Status: Episode 1 scaffolded, awaiting sources. A living, multi-episode research thread. Not a one-shot pilot — the structure is built to accrete.**

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
research/agent-architecture/
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

Episode 1 uses the *wait-and-fire-cold* posture: all sources fire in one parallel pass once the `ask-perplexity` skill lands, so synthesis sees the field whole rather than in halves. Later episodes may adopt different postures; the choice is recorded per episode.

## Relationship to Command Centre

Lateral. Not inside any chapter. A sibling to `emotional-ux-pilot/`. Triggered as a new line of enquiry on 2026-04-23 during a vault session not tied to any in-progress scene.

Decisions made via this thread may feed specific future scenes — agent architecture for BorAI Knowledge Graph follow-on work, the webapp layer, future Yurika products. Those future scenes, when opened, can reference the relevant ADR in `decisions/` via the `spec_file` frontmatter key.

## Graduation

When Episode 2 is committed, this folder moves to `campaigns/agent-architecture/` and becomes its own campaign — matching the rule stated in `emotional-ux-pilot/README.md`. Until then it lives here.
