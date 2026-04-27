# Claude (cold) — raw dump 2026-04-23

**Routing role:** Independent synthesis from training, before seeing other source dumps.
**Tool:** None — direct write from this subagent's own knowledge.
**Brief:** Episode 1 — Context and granularity. See ../episodes/01-context-and-granularity.md for full sub-questions and claim.

---

## Frame before answering

The claim under test reads "agent architecture is a spectrum, not a choice — and the correct position on it changes per task, not per product." Before I answer the six sub-questions, the framing I'm going to carry through:

The spectrum has at least two orthogonal axes that often get collapsed into one. **Granularity** (one agent vs many) and **context volume** (full session memory vs task-only brief) move together in practice but they don't have to. A monolithic LLM run with a deliberately stripped prompt is a context-poor monolith; a swarm where every sub-agent inherits the orchestrator's full conversation buffer is a context-rich swarm. The interesting failure modes live in the corners that the field treats as illegal moves.

A second orientation: most of what the literature calls "multi-agent systems" since 2023 is actually **multi-call systems with role prompts**, not autonomous agents in the Wooldridge sense. The distinction matters for sub-question 4 (coordination cost) because the coordination overhead between role-prompted calls and between truly autonomous agents diverges by an order of magnitude.

---

## 1. Literature on monolithic vs granular task performance, 2022–2026

The arc I see in training:

**2022 — pre-agent baseline.** Chain-of-thought (Wei et al. 2022) is still framed as a prompting technique, not an architecture. ReAct (Yao et al. 2022) is the first widely-cited paper to interleave reasoning and tool use inside one call — implicitly monolithic. Toolformer (Schick et al. 2023, but submitted late 2022) similarly frames tools as something one model invokes, not a coordination problem.

**2023 — the multi-agent rush.** AutoGPT and BabyAGI in March/April 2023 trigger an architectural shift in the public conversation: the assumption flips from "one model, many tools" to "many model calls, planner-on-top." The MetaGPT paper (Hong et al., August 2023) and CAMEL (Li et al., March 2023) make role-based multi-agent the dominant pattern in the literature. Performance claims are noisy because evaluation harnesses are inconsistent — HumanEval and MBPP get re-used past their ecological validity for agentic tasks.

**2024 — the swing back.** Two empirical strands matter. First, papers showing that single-agent ReAct-style loops match or beat multi-agent systems on most reasoning benchmarks when token budget is held constant (I'm thinking of the AgentBench follow-ups and the SWE-bench leaderboard pattern, where the top systems through 2024 were often less architecturally elaborate than the multi-agent contenders). Second, the "inference-time compute" narrative — o1-style extended reasoning shows that depth-of-thought inside one model can substitute for breadth-of-coordination across many. The implication: granularity was sometimes a workaround for weak base models.

**2025 — convergence on hybrid patterns.** SWE-agent (Yang et al.), Devin's published architecture, Anthropic's computer-use post-mortems, and the OpenAI Swarm/Agents SDK release all converge on a similar shape: a strong monolithic agent as the primary worker, with **task-scoped sub-agents spawned for clearly-bounded sub-problems** — usually search, parallel exploration, or context window relief. This is the "spectrum-per-task" pattern in the wild, even though no one names it that way.

**2026 (training cutoff Jan 2026).** I have less crystallised evidence here, but the visible direction is **dynamic dispatch** — frameworks shipping primitives for the orchestrator to choose granularity at runtime rather than at architecture time. LangGraph's "subgraph as tool" pattern and Anthropic's Claude Agent SDK's sub-agent invocation with isolated context windows are both in this category.

**Caveat I want to name explicitly.** The "monolithic vs multi-agent" comparison literature is methodologically weak. Most papers don't hold model strength constant, don't normalise for total token spend, and don't separate "the architecture helped" from "the architecture forced more compute, and more compute helped." When you control for total inference compute, the multi-agent advantage shrinks substantially on most benchmarks I can recall. The genuine wins for granularity show up in tasks with **natural parallelism** (literature search, multi-file refactor, multi-source synthesis) and in tasks where **context contamination** is the failure mode (debugging where prior failed attempts poison the model).

---

## 2. Frameworks that expose the spectrum vs frameworks that assume a position

A taxonomy from training:

**Position-assuming frameworks:**

- **CrewAI.** Assumes role-based multi-agent. The unit is a Crew of Agents with assigned Roles. Going monolithic is fighting the framework. Strength: opinionated, fast to scaffold. Weakness: encourages architectural over-fitting to a problem that may not need it.
- **AutoGen (early versions).** Assumed conversational multi-agent — the GroupChat pattern was central. AutoGen 0.4+ (late 2024) refactored toward a more explicit event-driven core that exposes more of the spectrum, but the docs still nudge you toward multi-agent.
- **MetaGPT.** Assumes a software-development role hierarchy (PM, architect, engineer, QA). Position-locked. Useful when your task fits the assumption; awkward otherwise.
- **BabyAGI / AutoGPT lineage.** Assumed single-agent autonomous loop with task queue. Position-locked at the other end of the spectrum.

**Spectrum-exposing frameworks:**

- **LangGraph.** The most explicit. The graph is the architecture; nodes can be LLM calls, tools, sub-graphs, or human-in-the-loop checkpoints. You can build a monolithic ReAct loop, a linear chain, a DAG, or a swarm in the same primitive. Cost: higher cognitive load to design the graph; you have to know what you want.
- **Pydantic AI.** Exposes single-agent + tool primitives cleanly, with multi-agent as a composition pattern rather than a built-in. Closer to the monolith end but doesn't lock you there.
- **Claude Agent SDK.** Sub-agent invocation with isolated context windows is a first-class primitive. The orchestrator agent decides per-task whether to handle inline or dispatch. This is the closest production-ready expression of the per-task routing the brief is asking about.
- **OpenAI Agents SDK / Swarm (the lineage).** Handoffs are first-class — an agent can hand off to another agent with explicit context transfer rules. Exposes the spectrum but biases toward handoff-style coordination rather than parallel sub-agent dispatch.
- **DSPy.** Orthogonal but worth naming — exposes the *optimisation* surface over the architecture, treating the choice of pipeline shape as something to be searched rather than designed.

**Frameworks that pretend to expose the spectrum but don't really:**

- LangChain (pre-LangGraph) had primitives for agents and chains, but the agent abstraction was so leaky that "exposing the spectrum" was more "leaving you to figure it out yourself." LangGraph is the proper answer to that gap.
- Many vendor-specific orchestrators (cloud-provider agent services) expose configuration knobs but enforce a particular topology under the hood.

**The pattern.** Frameworks that grew out of a specific task assumption (CrewAI from creative collaboration, MetaGPT from software dev) bake that assumption into their primitives. Frameworks that grew out of graph theory or compiler thinking (LangGraph, DSPy) expose the spectrum natively. The Claude Agent SDK is interesting because it grew from production agent failures and ended up exposing dispatch-as-primitive, which is closer to what the brief is asking about than anything else I know of.

---

## 3. Where context-stripping improves output, where it degrades it

This is the most empirically grounded sub-question I can answer.

**Context-stripping IMPROVES output when:**

- **The prior context contains failed attempts.** Models anchor on their previous wrong answers. A fresh sub-agent given only the corrected brief outperforms the same model continuing from the failed thread. This is well-documented in debugging benchmarks and in long-form coding tasks.
- **The prior context contains conflicting instructions.** Long sessions accumulate "actually, do it this other way" reversals; the model averages them. A stripped sub-agent gets the latest brief without the noise.
- **The task is mechanical and well-specified.** Code formatting, type annotations, schema validation, format conversion — anything where a strong prior is more likely wrong than right benefits from a clean slate.
- **Parallel exploration is the goal.** Multiple stripped sub-agents exploring different hypotheses don't contaminate each other. Tree-of-thoughts and similar patterns rely on this.
- **The context exceeds the effective attention window.** Long-context models technically support 200K+ tokens but exhibit the classic "lost in the middle" degradation past ~32–64K of dense reasoning content. Stripping to a focused brief outperforms feeding the full thread when the relevant facts are buried.
- **Privacy or scope isolation matters.** A sub-agent that only sees the data it needs can't accidentally exfiltrate or condition on data it shouldn't.

**Context-stripping DEGRADES output when:**

- **The task depends on conversational style or established voice.** Anything in this vault, for instance — a stripped agent can't reproduce the British-English-sober register without the accumulated examples.
- **The task depends on prior decisions that aren't easily summarisable.** Architectural choices made three exchanges ago, with their reasoning, often can't be compressed into a brief without losing the load-bearing nuance.
- **The task is exploratory and the model needs to know what's been tried.** Stripping causes re-treading. The drift the brief mentions is real, but so is the rediscovery cost.
- **The task spans multiple sub-agents that need shared context.** Stripping each one creates coordination overhead — someone has to be the source of truth for what the others know.
- **The user-model relationship is part of the product.** Anything resembling a personal assistant degrades sharply under context-stripping; the value is in the accumulated model-of-the-user.
- **Tool outputs need interpretation in context.** A stripped sub-agent given a stack trace without the codebase context will hallucinate causes more readily than a contextualised one.

**The actionable rule from this.** Context-stripping is closest to a free lunch when the task is **well-bounded, mechanical, and prone to anchor bias from prior context**. It's actively harmful when the task is **stylistic, decisional, or relational**. Most real workflows mix both — which is exactly the per-task routing the brief is asking about.

---

## 4. Coordination cost curve as agent count scales

The shape, from training and reasoning:

For N agents with full pairwise context-sharing, coordination tokens scale approximately O(N²) — every agent needs to know what every other agent has done. This is what kills naive multi-agent patterns past N≈5–7.

For N agents with hub-and-spoke coordination (one orchestrator, N workers), coordination scales O(N) — each worker syncs with the hub. This is the dominant production pattern. Costs stay manageable up to N≈20–50 depending on per-task token weight.

For N agents with **task-scoped isolation** (workers don't sync; orchestrator collates results), coordination scales O(N) on the dispatch side and O(N) on the collation side, but the per-message size is small. This scales furthest — hundreds of agents become viable.

**The threshold question.** "Does coordination cost dominate gains from granularity past a threshold?" — yes, and the threshold is shockingly low for full context-sharing patterns. My estimate from training:

- **Pairwise-share multi-agent:** dominates past N≈5.
- **Hub-and-spoke with full results back to hub:** dominates past N≈20–30 for non-trivial tasks.
- **Task-isolated with structured result schemas:** dominates past N≈100+ but is bottlenecked by the orchestrator's ability to synthesise.

**Hidden coordination costs that the field underestimates:**

- **Re-reading cost.** When a sub-agent returns a result, the orchestrator pays tokens to re-read and integrate. This compounds.
- **Schema-fitting cost.** Forcing structured output adds tokens both in the prompt (schema description) and in the output (JSON overhead).
- **Failure cascading cost.** One sub-agent failing forces the orchestrator to decide retry/skip/escalate, which itself costs tokens and often a re-read of the sub-agent's brief.
- **Debugging amortisation.** When the architecture goes wrong, the cost of figuring out which sub-agent failed at which step is borne by the human, not the model. This is a real cost the token-counting doesn't see.

**Where granularity wins despite coordination cost:**

- Embarrassingly parallel tasks (search across N sources, evaluate N candidates).
- Tasks where the orchestrator's context window would blow past 200K without dispatch.
- Tasks where some sub-task has different model-strength requirements (use Haiku for the cheap thing, Opus for the hard thing).

**My honest read.** Most production multi-agent systems I'd guess are running at N=2–4 sub-agents per task because past that the coordination overhead is visible in latency and cost without proportional quality gains. The "swarm" framing in the literature is usually aspirational.

---

## 5. Measurement surfaces that make the spectrum visible

The brief lists token spend, task completion, drift rate, user interventions. I'd add several more and rank them:

**First-class measurements that directly expose the spectrum:**

1. **Tokens-per-decision.** Total tokens (input + output, all calls) divided by user-meaningful decisions made. Monolithic systems often look efficient on this metric until the context grows. Granular systems look expensive per-call but cheap per-decision once tasks parallelise. The crossover point is the visible spectrum position.

2. **Wall-clock time to result.** Granularity buys parallelism, which buys latency reduction. Monoliths with extended reasoning trade latency for depth. The user-facing tradeoff lives here.

3. **User intervention rate per session.** How often does the human have to step in and correct? A well-positioned architecture minimises this. Both ends of the spectrum can fail this badly: monoliths drift and need correction; granular swarms misroute and need correction. The shape of the failure differs (drift vs misroute) and is itself a measurement.

4. **Drift rate.** Specifically: rate at which the model's output diverges from the user's intent over a session. Hard to measure rigorously — usually requires post-hoc human labelling. Proxy metrics: rate of "actually I meant" turns, rate of context-clarification questions from the model.

5. **Completion rate at fixed budget.** Hold token budget constant, vary architecture. Which architecture completes more tasks? This is the cleanest comparison but requires careful task-equivalent matching.

**Second-tier measurements that surface the spectrum indirectly:**

6. **Reproducibility variance.** Run the same task N times. Variance in output quality reveals architectural fragility. Granular systems with race conditions or routing nondeterminism show up here.

7. **Cost-per-quality-unit.** Quality scored 1–5 by human rater, divided by dollar cost. Lets you compare architectures on a frontier rather than a single metric.

8. **Time-to-first-useful-output.** Does the user get something they can react to quickly, or do they wait for a long pipeline? Affects the felt experience even when total time is similar.

9. **Failure mode taxonomy frequency.** Drift, misroute, infinite loop, schema violation, tool-call error, context overflow, hallucinated handoff. The relative frequencies of these failure modes are diagnostic of architectural position.

10. **Sub-agent return-to-orchestrator rate vs first-pass success rate.** In hub-and-spoke patterns, how often does the orchestrator have to ping the sub-agent again? High rate suggests under-specified briefs; low rate with poor outcomes suggests over-isolated sub-agents.

**Measurements that the field talks about but mostly mislead:**

- **Benchmark scores** (HumanEval, MMLU, etc.). These don't capture architectural fit at all and have been Goodharted.
- **Number of agents.** A vanity metric. More agents is not better.
- **Tool call count.** Sometimes more tool calls is better (richer grounding); sometimes worse (the model is flailing). Without context, it's noise.

**The visibility problem.** Most teams instrument tokens and latency because their billing depends on it. They don't instrument drift or intervention rate because those require human-in-the-loop measurement. So the spectrum is invisible to them — they see cost and speed, not fit. **A genuinely useful observability layer for agent architecture would foreground the qualitative metrics.**

---

## 6. Blind task execution and debugging cost — net reduction or net increase in failure cost?

The real question hidden in this: when a granular sub-agent fails, is the lack of context a debugging *liability* (you can't see what it was trying to do in the broader frame) or a debugging *asset* (the failure is small, isolated, easy to reproduce)?

**The case for net reduction (granularity helps debugging):**

- Failures are scoped. A sub-agent that fails on "extract the date from this string" can be debugged in isolation. The brief and the output are the entire surface area.
- Reproducibility is high. Stripped context means the inputs are visible and re-runnable.
- The blast radius is small. One failed sub-agent doesn't poison the rest of the run if the orchestrator is well-designed.
- Failure modes are narrower. A bounded task has a bounded set of ways to fail.

**The case for net increase (granularity hurts debugging):**

- The *why* is missing. The sub-agent doesn't know why it was asked to do this thing, which means when it fails subtly (wrong-but-plausible output), the human has to reconstruct the intent.
- Failures cascade across sub-agents in non-obvious ways. Sub-agent A returns a slightly off result; sub-agent B treats it as ground truth; the failure surfaces three steps later.
- The orchestrator's reasoning is the actual locus of failure most of the time. Sub-agents are rarely individually wrong; the *routing* and *integration* logic is where bugs live. That logic is harder to debug than a single agent's reasoning chain.
- Trace tooling is immature. LangSmith, Langfuse, Helicone, and similar tools have improved a lot but tracing a multi-agent run still requires significant manual work to understand. Single-agent traces are linear and trivially readable.
- Each new sub-agent is a new contract that can drift. If you change one, you have to verify the others still consume its output correctly.

**My read.** Net effect depends on which kind of failure dominates your workload:

- **If failures are mostly within-task (the model gets the bounded task wrong):** granularity reduces debugging cost. The bounded surface helps.
- **If failures are mostly cross-task (the integration is wrong, the routing is wrong, the assumptions don't match):** granularity *increases* debugging cost significantly. You're now debugging a distributed system, which is much harder than debugging a single agent's reasoning.

**The often-missed point.** Single-agent debugging benefits from a property that gets lost in granular systems: **the model can explain its own reasoning when asked.** A monolithic agent that fails can usually tell you what it was trying to do and why, in the same conversation. A failed sub-agent is dead — its context is gone, you can re-run it but you can't ask it post-hoc what it was thinking. This is a real debugging asymmetry that the granularity-helps-debugging case underrates.

**The actionable framing.** Granularity reduces debugging cost for *predictable, bounded* failures and increases it for *emergent, cross-task* failures. As a system matures and the bounded failures get fixed, the remaining failures are increasingly the cross-task kind — which means **the debugging benefit of granularity decays over the life of a product**. Early on, granularity helps. Late on, it hurts.

---

## Returning to the claim

The claim says architecture is a spectrum and the right position changes per task. From the six sub-questions:

- The literature supports task-level routing for tasks with natural parallelism and context contamination risk; the literature does *not* support granularity as a default.
- Frameworks are starting to expose dispatch-as-primitive (Claude Agent SDK, LangGraph subgraphs) but most still assume a position.
- Context-stripping has clear cases where it helps and clear cases where it hurts, and the cases are differentiable in advance for a non-trivial fraction of tasks. **This is what makes per-task routing viable.**
- Coordination cost dominates earlier than the field admits; this argues for *bias toward monolith with selective dispatch* rather than *swarm-by-default*.
- The measurement surfaces exist but most teams don't instrument the qualitative metrics, which means the spectrum is invisible to them in practice.
- Debugging cost cuts both ways and the balance shifts over a product's life.

**The routing primitive that falls out of all this:** an orchestrator with a strong base model, a clear taxonomy of "this kind of task benefits from dispatch / this kind doesn't," and a dispatch decision made at the orchestrator level per call. The Claude Agent SDK's pattern is the closest production expression. The LangGraph subgraph-as-tool pattern is the closest framework-level expression. Neither yet provides the *taxonomy* — that's the human design work.

**Where I'm uncertain:**

- The Jan 2026 frontier may have shipped primitives or empirical results I don't know about. Treat my "current state" framing as *as of training cutoff*.
- I have low confidence on specific 2025–2026 benchmark numbers; I've avoided citing exact figures because I'd be guessing.
- The "coordination cost dominates at N≈5" threshold is my reasoned estimate, not a published number. I'd want it tested against a current benchmark.
- I'm probably underweighting the case for granularity in agent-based simulations (game NPCs, multi-stakeholder negotiation simulations) where the granularity *is* the product. My answers are biased toward task-completion contexts.

**What I'd want from the other sources:** Gemini's literature scan should sharpen sub-question 1 with actual paper citations. Perplexity should sharpen sub-questions 2 and 5 with current production post-mortems. Grok and ChatGPT should pressure-test my coordination-cost estimates and the "monolith + selective dispatch" recommendation. The framework agents (Copilot, Cursor) should ground sub-question 2 with actual code patterns from the named frameworks.
