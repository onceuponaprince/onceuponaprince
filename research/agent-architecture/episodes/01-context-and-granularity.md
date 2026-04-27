# Episode 1 — Context and granularity

**Status: sources firing 2026-04-23. Posture (a) — all seven sources fired cold in parallel; synthesis sees the field whole. Raw dumps land in `../sources/`.**

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
| ChatGPT | Structured brainstorming of candidate architectures and alternatives |

Targeted web fetches, per-framework docs:

- LangGraph
- AutoGen
- CrewAI
- Claude Agent SDK
- OpenAI Agents SDK
- Pydantic AI

Manifest accretes as new frameworks surface during research.

## Synthesis

### Verdict

The claim holds. All seven sources converge on it: agent architecture is a spectrum, the correct position is task-contingent, and product-level commitment to a single position is the wrong abstraction. What the field has not solved — and what every source either circles around or names directly — is the *routing primitive*: the mechanism that picks the position per task. The episode question is therefore answered with a yes-and. Yes, position can and should be chosen per task. And the primitive that does the choosing is the genuine unsolved problem, not the spectrum itself. Grok puts it most directly: *"the correct position changes per task — but building the router that reliably knows is the real unsolved primitive."*

### 1 — Literature on monolithic vs granular performance, 2022–2026

The arc is now legible. **2022–2023** is the monolithic baseline era — ReAct (Yao et al., 2022) and Reflexion (Shinn et al., 2023) frame the agent as a single reasoning loop. **2023–2024** is the multi-agent rush: AutoGPT, BabyAGI, CAMEL (Li et al., March 2023), MetaGPT (Hong et al., August 2023), ChatDev (Qian et al.) shift the assumption from "one model, many tools" to "many model calls, planner-on-top." MetaGPT reaches 46.67% on SWE-Bench Lite (Aug 2024). **2025–2026** is the swing back. Reasoning-token models (o1/o3, Claude Mythos) restore monolithic performance: Verdent reports 76.1% on SWE-bench Verified with a single-loop Plan-Code-Verify pattern (Gemini); Claude Code (Mythos Preview, 2026) reaches 93.9% on the same benchmark. The December 2025 arXiv paper *Towards a Science of Scaling Agent Systems* (Perplexity, Grok) — 260 configurations across six benchmarks — is now the load-bearing reference. Its headline: relative performance vs single-agent ranges from **+80.8% to –70.0%**, entirely depending on task type. Decomposable tasks gain from coordination; sequential planning is actively harmed by it.

The methodologically honest read, which Claude (cold) names and the other sources implicitly share: most "monolithic vs multi-agent" comparisons don't hold compute constant. Multi-agent systems often win because they spend more tokens, not because the architecture helped. When inference compute is normalised, the multi-agent advantage shrinks substantially. Granularity wins genuinely only on tasks with **natural parallelism** (literature search, multi-file refactor, multi-source synthesis) or where **context contamination** is the failure mode (debugging poisoned by prior failed attempts). 

ChatGPT names the underlying axis cleanly: *"the real comparison is often not 1 agent vs N agents, but 1 long-context pass vs N short-context passes + cheap synthesis."* Self-consistency and voting (Wang et al., 2022) are simpler points on the spectrum and often dominate fancy interpersonal-role setups. *More Agents Is All You Need* (arXiv:2402.05120) and *Are More LLM Calls All You Need?* (arXiv:2403.02419) together establish the non-monotonicity: more calls help easy queries, hurt hard ones, and there is an optimal count per task class.

*Suspect citation flagged: Gemini's arXiv:2604.02460 has a 2026-04 paper ID format that is internally inconsistent with arXiv numbering and is not corroborated by Perplexity's 43-source pass. Treat that specific reference as unverified pending checking against the actual arXiv listing.*

### 2 — Frameworks that expose the spectrum vs frameworks that assume a position

A taxonomy emerges across Cursor, Copilot, Claude (cold), ChatGPT, Gemini, and Perplexity:

**Spectrum-exposing.** **LangGraph** is the cleanest expression — `StateGraph`, `add_conditional_edges`, `Send` for dynamic fan-out, and `Command(goto=..., update=...)` for state-and-control-flow in one return. Cursor surfaces the trenches gotcha: `Command` adds dynamic edges but **static edges still run** — combining `Command(goto=...)` with `add_edge(node_a, node_b)` produces unintended parallel execution. The graph API is the architecture. **OpenAI Agents SDK** exposes handoffs as first-class tools (`transfer_to_*`), with `handoff(..., input_filter=...)` and run-level `RunConfig.handoff_input_filter` reshaping what the next agent sees — the transcript surgery is the spectrum knob, not just the agent count. **Claude Agent SDK** treats sub-agents as hard isolation: `AgentDefinition` registers programmatic subagents on `ClaudeAgentOptions`, and the parent receives only the final result. Cursor names the deeper point: *"that is not a limitation — it is the routing primitive: you are buying focus and parallelisability by paying information loss."* **Pydantic AI** offers three layers — tool delegation (parent resumes after child returns), programmatic hand-off (application code owns the router), and graph-based control. **DSPy** is orthogonal: it exposes the optimisation surface over the architecture, treating pipeline shape as something to be searched rather than designed.

**Position-assuming.** **CrewAI** assumes role-based multi-agent. `Process.sequential` is architecture-as-constant; `Process.hierarchical` is architecture-as-runtime-policy where a manager delegates. Cursor surfaces the silent failure: forum threads (Issue #1220, the "only manager visible in self.agents" thread) document **delegation failing silently** — the manager executes everything itself. *"That looks like a granularity win in diagrams and a monolith in traces."* **AutoGen** has split trajectories — Microsoft's `microsoft/autogen` 0.4 rewrite vs **AG2** continuing 0.2.x ergonomics — and Cursor flags that documentation collisions cause Copilot-generated code to hallucinate which package's `GroupChat` is meant. **MetaGPT** assumes a software-development role hierarchy (PM, architect, engineer, QA), position-locked. **CAMEL, ChatDev, AgentVerse** assume decomposition and explicit role separation as the default framing.

The pattern: frameworks that grew out of a specific task assumption bake that assumption into their primitives. Frameworks that grew out of graph theory or compiler thinking expose the spectrum natively. The split is not technical sophistication — it is conceptual heritage.

What's missing across all of them, surfaced by ChatGPT and Claude (cold) and implied by Grok: **a learned architecture router** that chooses monolith, self-consistency, handoff, subagent tree, or debate based on task features and live telemetry. Most routing in production today is prompt-level and symbolic, not empirical.

### 3 — Where context-stripping improves output, where it degrades it

Strongest convergence across all seven sources. The improvement and degradation regimes are differentiable in advance for a non-trivial fraction of tasks, and that differentiability is what makes per-task routing viable.

**Improves when:** prior context contains failed attempts (anchor bias); prior context contains conflicting instructions (averaging effect); the task is mechanical and well-specified; parallel exploration is the goal (no cross-contamination); the context exceeds the effective attention window (Liu et al. 2023's *Lost in the Middle* U-shape; NoLiMa benchmark 2025 shows even top-tier models drop to 50% short-context accuracy at 32K tokens); privacy or scope isolation matters; tool-heavy environments where too many tools worsens selection behaviour.

The Perplexity dump anchors this empirically: *Chain of Agents* (Zhang et al., NeurIPS 2024) is "basically a formal proof-by-construction that smaller local contexts can beat one giant context on long-input tasks." Amazon Science (April 2026): *"context length alone hurts LLM performance even when retrieval is perfect."* The Anthropic 2025 *context rot* finding — models use only ~1–5% of their advertised context window effectively — is now load-bearing in practitioner discourse (Grok, Cursor).

**Degrades when:** the task depends on conversational style or established voice; the task depends on prior decisions that aren't easily summarisable; the task is exploratory and the model needs to know what's been tried; the task spans multiple sub-agents that need shared context (someone has to be the source of truth); the user-model relationship is part of the product; tool outputs need interpretation in context.

The actionable rule, integrating Claude (cold), ChatGPT, and Cursor: **context curation, not context maximisation or minimisation, is the correct frame.** ChatGPT's framing is the sharpest — *"the important variable is which invariants survive compression."* Some tasks want context stripping for solving but full-context replay for auditing. The asymmetric architecture — narrow execution, wide verification — is the under-noted production pattern.

The contrarian read from Grok preserves the danger: @lodewykbronn's rollback on a hybrid system where context stripping went too far — *"the persona layer wasn't overhead — it was doing real cognitive work."* Stripping is a knob, not a virtue.

### 4 — Coordination-cost curve and the granularity threshold

The threshold is shockingly low and the field underplays it.

**Quantitative anchors** (treat as directional, not universal): Multi-agent orchestration consumes ~200% more tokens than single-agent as a baseline overhead (Perplexity, citing 2026 framework benchmarks). Token overhead by framework: Direct API 1×, LangGraph 1.3–1.8×, LangChain 1.5–2.5×, AutoGen 2–5×, CrewAI 3–4×. Google/MIT scaling work cited by Grok: hybrid 6.2× more turns than single-agent (44.3 vs 7.2); single-agent token efficiency 67.7 successes per 1K tokens vs hybrid's 13.6. *Stop Wasting Your Tokens* (arXiv:2510.26585) reports supervisor overhead on the order of ~15% of tokens and meaningful latency inflation in supervisory patterns. Error amplification in decentralised multi-agent reaches **17.2×** the single-agent rate; centralised verification reduces this to ~4.4×.

**Threshold convergence across sources:**

- Gemini: DeepMind's *Towards a Science of Scaling Agent Systems* (2026) — optimal cluster size **3–4 agents**; beyond, coordination noise outweighs gains.
- Perplexity: capability-saturation effect — once single-agent baseline crosses a task-specific performance threshold, coordination yields diminishing returns.
- Claude (cold): pairwise-share dominates past N≈5; hub-and-spoke past N≈20–30; task-isolated past N≈100+.
- Grok (X-discourse): *"Gains plateau or reverse beyond 3-4 agents… At n=6+, turns explode (predictions 3-6×+). MAST: coordination 36.9% of failures."* @Th3RealSocrates: *"5 agents = 5 failure modes."*
- Cursor: "coordination threshold at ~45% single-agent accuracy or 16+ tools."
- Copilot: 1–2 agents big gains; 3–5 flatten; >5 overhead frequently dominates.
- ChatGPT: non-monotonicity confirmed by *Are More LLM Calls All You Need?* (arXiv:2403.02419).

The deeper point ChatGPT names that no one else does cleanly: the scaling variable is not `N agents`. It is closer to *"coordination cost ~ message count × average message entropy × synchronization depth × verification load."* Parallel workers are cheap. **Reconciliation is expensive.** Agent systems scale like distributed systems — throughput rises before consistency costs crush latency.

The field-level admission, surfaced by Grok via @reinamora_137 citing arXivs: *"Single agent with tools wins on cost and performance. The multi-agent default assumption needs more scrutiny."* Production blogs claim 340% efficiency. Reality: token costs 2–15× higher, often without proportional gains.

### 5 — Measurement surfaces that make the spectrum visible

The brief listed token spend, task completion, drift rate, user interventions. The sources extend the list considerably and split it sharply between vanity and load-bearing metrics.

**Vanity metrics** (what marketing reports): raw agent count; "autonomy score"; demo success without token-budget baselines; benchmark scores divorced from task class; "processing efficiency 340%" claims without equal-compute comparison; framework-fixed setups that ignore implementation variance (MASEval, surfaced by Grok).

**Load-bearing metrics** (what serious teams instrument):

- **Tokens-per-decision** (Claude cold) — total tokens divided by user-meaningful decisions made. The crossover point between monolith and granular is the visible spectrum position.
- **Token-per-task (TPT)** (Perplexity, citing LinkedIn) — single best unit-economics signal for architecture decisions.
- **Coordination tax ratio** (ChatGPT) — fraction of tokens/calls spent on inter-agent communication vs environment interaction vs final answer generation. *"High ratio means team talking to itself."*
- **Constraint preservation score** (ChatGPT) — inject known global constraints, measure how often they survive decomposition hops.
- **Error propagation depth** (ChatGPT, corroborated by Grok's 4–17× amplification figures) — how many downstream steps inherit an early mistake before detection.
- **Goal drift rate** (Perplexity, METR May 2025 technical report) — correlates strongly with context length and adversarial pressure.
- **METR's task-completion time-horizon** (April 2026) — fits a logistic curve to predict success probability as a function of human-expert task duration.
- **Wall-clock time to result** and **time-to-first-useful-output** (Claude cold) — granularity buys parallelism, monolith trades latency for depth; the user-facing tradeoff lives here.
- **Reproducibility variance** (Claude cold) — run the same task N times; variance reveals architectural fragility.
- **Audit completeness** (Perplexity, Portkey 2026 framework) — percentage of requests with full trace coverage, tracked as a governance KPI because missing-trace events are the highest-cost failure class.
- **Per-handoff transcript fidelity** (Cursor, Copilot) — what survives a handoff, what is filtered out, what is reconstructed.

The visibility problem, named by Claude (cold) and implicit in Grok: most teams instrument tokens and latency because their billing depends on it. They do not instrument drift or intervention rate because those require human-in-the-loop measurement. *"So the spectrum is invisible to them — they see cost and speed, not fit."*

The observability stack the sources converge on: **LangSmith** (deep LangChain/LangGraph integration), **Langfuse** (OSS-friendly tracing), **AgentOps** (session-oriented), **OpenTelemetry GenAI** (vendor-neutral spans, still stabilising — expect `OTEL_SEMCONV_STABILITY_OPT_IN` flags). Cursor's load-bearing point: *"Copilot reads README feature lists; production teams read whether your router increments a span attribute that lets you aggregate p(success | agent=X) — without that, architectural debates are astrology."*

### 6 — Blind task execution and debugging cost

The genuine tension. All sources address it; none deliver a clean verdict because the answer is conditional on which kind of failure dominates.

**Granularity reduces debugging cost when:** failures are within-task (the model gets the bounded task wrong); the brief and output are the entire surface area; reproducibility is high (stripped context = inputs visible and re-runnable); blast radius is small (one failed sub-agent does not poison the rest if the orchestrator is well-designed).

**Granularity increases debugging cost when:** failures are cross-task (integration wrong, routing wrong, assumptions don't match); the *why* is missing (the sub-agent does not know why it was asked to do this thing); failures cascade in non-obvious ways (sub-agent A returns a slightly off result; sub-agent B treats it as ground truth; failure surfaces three steps later); trace tooling is immature (multi-agent runs still require significant manual work to read).

The often-missed asymmetry, named by Claude (cold): **a monolithic agent that fails can usually tell you what it was trying to do and why, in the same conversation. A failed sub-agent is dead — its context is gone, you can re-run it but you cannot ask it post-hoc what it was thinking.** This is a real debugging asymmetry that the granularity-helps-debugging case underrates.

The temporal point, also from Claude (cold): granularity reduces debugging cost for *predictable, bounded* failures and increases it for *emergent, cross-task* failures. As a system matures and the bounded failures get fixed, the remaining failures are increasingly the cross-task kind. **The debugging benefit of granularity decays over the life of a product.** Early on, granularity helps. Late on, it hurts.

The X-surfaced reality (Grok): @bygregorr's *"agent 3 failed, agent 7 kept going"* captures the silent-failure mode. Multi-agent error propagation 4–17×. ~30% recovery/failure floor; multi-agent setups worsen it. Cursor confirms with named GitHub issues: Claude subagent skill leakage (Issue #23257, "extremely costly"), MCP leakage into subagent tool output (Issue #47118), unbounded execution showing 39 vs 234 tool calls on identical tasks (Issue #36727). LangGraph CVE-2026-27794 RCE in checkpointing — granular state is also attack surface.

The economically rational pattern, surfaced by Cursor (citing arXiv:2505.18286) and corroborated by Perplexity's MasRouter: **cascade between granular and monolithic modes — route wide, execute narrow, escalate to wide context when metrics say you must.**

### Closing: the routing primitive as the genuine open work

The sources converge on the spectrum claim and diverge on what the routing primitive should look like. The divergence is the actual finding.

**Named candidates from the sources:**

- **MasRouter** (Perplexity, citing ACL 2025) — three-layer cascaded controller: collaboration mode determiner (one or many?), role allocator (what specialisations?), LLM router (which model backbone?). Concrete and tested.
- **TRouter, Arch-Router, MoMA** (Gemini) — task-aware routing with multi-level taxonomy (Domain → Subcategory → Difficulty); semantic matching against API contracts; context-aware state machines selecting per-step.
- **RouteLLM** (Perplexity) — BERT-class classifier trained on human preference data, routing strong/weak model pairs, achieving 85% cost reduction at 95% quality parity.
- **`route(task, state, telemetry) → graph`** (ChatGPT) — policy over inference graphs specifying number of workers, topology, context slice per worker, communication rules, verification plan, stop/escalate thresholds. Test-time adaptive: probe, choose provisional graph, monitor disagreement, re-route mid-task.
- **`route(task) → {execution_unit, context_projection, budget, stop_policy}`** (Copilot) — execution unit (monolith or specialist), context projection (full / projected / filtered), budget (token/turn/tool limits), stop policy (termination/guardrails). The cleanest concrete signature.
- **Lightweight task-feature classifier** (Grok) — features include parallelism score, tool count, coupling (interrelated steps?), expected context noise, single-agent baseline accuracy. Dynamic: start monolithic, spawn granular on branches if parallelism detected and coordination tax modelled low. Hybrid with central verifier.
- **In-model routing / graph routing / application routing** (Cursor) — three implementation strata: cheap to build but expensive to debug (in-model); explicit and testable but easy to wire wrong (graph); maximum control with own observability (application).

The convergence under the divergence: **the routing primitive is a policy that prices four things together** — local difficulty, context entanglement, coordination tax, and debugging liability. ChatGPT names this directly. Claude (cold) circles it via the orchestrator-with-taxonomy framing. Grok preserves the cynicism: *"most teams fake it with prompt heuristics — hence failures. Real primitive needs observability (trace handoffs, measure fidelity) and fallback to human/single."*

What the field has shipped: framework primitives that *enable* per-task routing (LangGraph's `Command`, OpenAI's `handoff(input_filter=...)`, Claude SDK's subagent isolation, Pydantic AI's programmatic hand-off). What the field has not shipped: the *taxonomy* — the human design work that says "this kind of task benefits from dispatch, this kind doesn't." That is the load-bearing missing piece.

The closing line that organises Episode 1's contribution: **the spectrum is real, the position is task-contingent, the framework primitives mostly exist — and the router that reliably picks the position is the one thing the field cannot yet build.** That is the open problem Episode 2 should attack.

### What this commits us to (and doesn't)

No ADRs land in `../decisions/` from this synthesis. The rule in `decisions/README.md` is that decisions are commitments to real systems, not abstract recommendations — and the synthesis above is a map of the field, not a commitment. Decisions land when the first interactive (topology switcher) forces an architectural choice for the BorAI / vault / future-product context.

What this synthesis *does* commit us to: a working hypothesis for the interactives.

- The **topology switcher** should let the reader manipulate the four-axis policy (execution unit, context projection, budget, stop policy) rather than just toggling agent count, since the count axis is misleading on its own.
- The **drift-vs-context slider** should expose the asymmetry — narrow execution / wide verification — rather than treat context as a single dial.
- The **same-task walkthrough** should run a task through at least one configuration that the literature calls correct and one that the literature calls wrong, so the reader sees the spectrum's bite.
- The **coordination-overhead visualiser** should anchor on the ChatGPT formula (`message count × message entropy × synchronization depth × verification load`) rather than agent count, and surface the 3–4 agent threshold the sources converge on.
- The **cost/quality scatter** should foreground the load-bearing metrics (tokens-per-decision, coordination tax ratio, error propagation depth) and explicitly omit the vanity metrics (agent count, autonomy score) so the contrast is visible.

Episode 2 candidate question, surfaced by the divergence: **what would a working task-feature classifier look like — what features, what training data, what measurement loop?** The sources name the gap. The next episode could attempt to close it.

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
