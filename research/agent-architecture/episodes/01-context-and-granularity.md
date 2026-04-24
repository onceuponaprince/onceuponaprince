# Episode 1 — Context and granularity

**Status: scaffolded. Awaiting `ask-perplexity` skill before firing sources. Posture (a) — all sources fired cold in one pass, synthesis sees the field whole.**

## The question

Context richness and agent granularity are the same lever viewed from two sides.

- **Context-rich monolith.** One model. All the state. Long session. Ambient memory. Rich instructions. Fewer coordination costs. Higher drift surface over time. Every request bears the cost of the whole context.
- **Granular single-task agents.** Many agents. Each blind past the brief. Short lifecycle. Stateless between tasks. Minimal per-task cost. No drift because there is nothing to drift. Coordination becomes the product.

The interesting territory is the middle — and the position on the spectrum that is correct for one task is wrong for the next.

Episode 1 asks: **can the choice of position be made at the task level rather than the product level, and if so, what does the routing primitive look like?**

## Sub-questions for the sources

1. What is the current literature on monolithic-agent vs granular-agent task performance (2022–2026)?
2. Which frameworks expose the spectrum explicitly, and which assume a position?
3. Where is context-stripping known to *improve* output, and where is it known to degrade it?
4. What is the coordination-cost curve as agent count scales, and does it dominate any gains from granularity past a threshold?
5. What measurement surfaces make the spectrum visible — token spend, task completion, drift rate, user interventions?
6. What does blind task execution cost in debugging — is the loss of context a net reduction or net increase in failure cost?

## Source manifest

Fires cold and in parallel once `ask-perplexity` is ready. Each source receives the same six-question brief plus its routing role.

| Source | Routing role |
|---|---|
| Gemini | Academic and HCI / systems literature |
| Perplexity | Current practice 2024–2026, production post-mortems |
| Claude (cold) | Independent synthesis before seeing other dumps |
| Grok | Contrarian read, recency bias on 2026 posts |
| Copilot CLI | Framework-specific code patterns |
| Cursor Agent | Framework-specific code patterns, cross-check with Copilot |

Targeted web fetches, per-framework docs:

- LangGraph
- AutoGen
- CrewAI
- Claude Agent SDK
- OpenAI Agents SDK
- Pydantic AI

Manifest accretes as new frameworks surface during research.

## Synthesis

*To be written after all sources land. Claude as synthesis layer, reading the raw dumps in `../sources/`.*

## Interactives shipped

Build order agreed:

1. **Topology switcher** — monolith / linear chain / DAG / swarm, same task routed differently with live diagram
2. **Drift-vs-context slider** — full context → task-brief-only, watch sample output degrade or improve in real time
3. **Same-task walkthrough** — one prompt through four architectures side-by-side
4. **Coordination-overhead visualiser** — tokens-as-coordination vs tokens-as-work as swarm scales
5. **Cost/quality scatter** — live scatter across architectures, draggable

Target: `../pilot.html` at the root of `research/agent-architecture/`. None shipped yet.

## Decisions triggered

*ADRs land in `../decisions/` as the research answers real questions for BorAI, vault tooling, or a future scene's implementation. None yet.*
