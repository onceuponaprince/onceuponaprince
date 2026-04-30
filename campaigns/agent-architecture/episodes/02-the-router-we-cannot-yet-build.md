# Episode 2 — The router we cannot yet build

**Status: synthesised 2026-04-27 on 5/7 sources. Perplexity and Grok blocked by environment (Chromium launch failure, no display server). Synthesis sees five-sevenths of the field; the missing sources are flagged in the verdict. Addendum lands when the display environment is unblocked.**

## The handoff from Episode 1

Episode 1 confirmed: agent architecture is a spectrum, the position is task-contingent, and the framework primitives for moving along the spectrum mostly exist. What it could not resolve was the *router* — the mechanism that picks the position per task without a human configuring it for every workload. Six candidate routing primitives surfaced (MasRouter, TRouter / Arch-Router / MoMA, RouteLLM, ChatGPT's `route(task, state, telemetry) → graph`, Copilot's `route(task) → {execution_unit, context_projection, budget, stop_policy}`, Grok's lightweight task-feature classifier). None has won. None has been deployed at scale. The hard part, the synthesis suggested, is not the model but the *taxonomy* — the human design work that says which task wants which configuration.

Episode 2 takes the question from *what should the router look like?* (Episode 1's open work) to *could a solo founder build a v0 today, and if so, what does that v0 cost?* If the answer is no, the spectrum stays theory; the practical guidance remains *pick a position per product and accept the mismatch*. If the answer is yes, the spectrum becomes operationalisable — a real piece of infrastructure, not a research claim.

## The question

Episode 2 asks: **could a solo founder build a working task-feature classifier today — and if so, what does v0 cost?**

## Sub-questions for the sources

1. **Predictive features.** Which task features are most predictive of correct spectrum position — parallelisability, tool count, state coupling, expected context noise, prior single-agent baseline accuracy, task horizon, verifier availability? Which are noise? Which require runtime probing vs. can be inferred from the task statement alone?

2. **Training data.** What labelled training data exists or can be cheaply generated — benchmark traces (SWE-bench, GAIA, AgentBench, τ-bench), execution logs from production agent systems, synthetic task generation via a stronger model, human labelling at scale, RLHF-style preference data on architecture configurations?

3. **Classifier shape.** What's the cheapest classifier that moves the needle — rule-based heuristic, BERT-class small classifier, fine-tuned LLM, learned policy via RL? Where does each fail? What's the latency / cost tradeoff that decides which to pick?

4. **Measurement loop.** What's the validation mechanism — A/B against a fixed-architecture baseline, counterfactual replay against historical execution logs, causal inference from observational data? What's the smallest experiment that would prove or disprove a v0?

5. **Failure modes and fallbacks.** Where does the classifier fail safely? What's the fallback when confidence is low — always-monolith, always-graph, human-in-loop, escalation to a stronger router? How do you avoid the classifier becoming the new single point of failure?

6. **Cost of v0.** What does a working v0 actually cost — week, month, quarter of solo-founder time? At what point is the marginal effort better spent on better base models or on better framework primitives instead of on a router that picks between them?

## Source manifest

Fires cold and in parallel. Each source receives the same brief plus its routing role.

| Source | Routing role |
|---|---|
| Gemini | Academic and HCI / systems literature on task classification, meta-routing, MoE models, learned scheduling |
| Perplexity | Current practice 2024–2026, production routing post-mortems, RouteLLM-style deployments |
| Claude (cold) | Independent first-principles synthesis on what a task-feature classifier would need to know |
| Grok | Contrarian read, recency bias on routing-doesn't-work posts |
| Copilot CLI | Framework-specific code patterns for routing primitives in production |
| Cursor Agent | Framework code, cross-check with Copilot — trenches read on what teams ship vs. what frameworks document |
| ChatGPT | Divergent brainstorming of candidate classifier architectures and training-data sources |

Targeted web fetches:

- **RouteLLM** (LMSYS) — BERT-class classifier between strong/weak models; the closest production precedent
- **MasRouter** (ACL 2025) — three-layer cascaded controller; named explicitly in Ep1's synthesis
- **Anthropic Workflows / Claude Agent SDK subagent dispatch** — current production routing surface
- **OpenAI Agents SDK handoff filters + RunConfig** — handoff-as-routing primitive
- **DSPy** — optimisation-over-architecture pattern; could be the v0 vehicle
- **TRouter / Arch-Router / MoMA** — task-aware routing patterns from Ep1 Gemini dump
- Recent arXiv on classifier-for-agents, learned scheduling, or compound inference routing (2025–2026)

Manifest accretes as new frameworks surface during research.

## Synthesis

### Verdict

The claim holds, with one important reframing: the v0 buildable today is **rules plus instrumentation**, not a model. The five working sources (Gemini, Claude cold, Cursor's trenches read, Copilot's code-grounded pass, ChatGPT's divergent brainstorm) converge sharply on the diagnosis Episode 1 anticipated — the framework primitives are production-ready, the hard part is feature engineering and label acquisition, and the v0 a solo founder should ship is a hand-tuned rule-based router with shadow-mode telemetry, with the learned classifier deferred until the rules generate enough signal to train on. **The model is not the bottleneck. The taxonomy and the labels are.** Cursor's verdict states it most plainly: *"You can't benchmark your way out of the data problem."* Two sources (Perplexity, Grok) failed on environment issues (Chromium launch failure under no-display headless conditions); their absence shows up most as a citation-density gap on production blog posts and a contrarian-X-discourse gap. Cursor partially compensates for both with named GitHub issues, Reddit threads, and rollback stories.

### 1 — Predictive features

Strong convergence across all five sources on which features actually carry predictive load. Claude cold's ranking of the top five — *parallelisability, active tool count, expected context noise, verifier availability, reversibility* — gets corroborated, with caveats, by every other source.

**Parallelisability.** Claude cold names this as the strongest feature and the cleanest one inferable from the task statement alone. ChatGPT echoes it under *coordination-tax pack* — predicted subtask count, dependency depth, handoff count. Copilot makes it operational with a regex-based extractor (numbered lists, file mention counts, action-verb hits) producing a `decomposition_score` between 0 and 1. The signal is consistent: explicit list structures, cardinality markers, conjunctive verbs without sequential markers.

**Active tool count.** Claude cold flags this is about *active for this task*, not the framework's catalogue. Anthropic's "Lost in the Tools" effect (selection accuracy collapses past ~30–50 tools, per Cursor's read of community discussions) makes this load-bearing. Cursor adds the operational point: NVIDIA's Prompt Task and Complexity Classifier survives production contact only when combined with model-criteria frameworks, not used standalone.

**Expected context noise / context entanglement.** All sources name this. Claude cold positions it as *the* signal that justifies stripping context. ChatGPT names it *observation-deficit pack*: unresolved pronouns, absent file references, implicit goals, "fix this" without an artefact. Cursor cites the production failure mode: history contamination from prior session leakage (Cursor agent issue #74563, where summaries from unrelated projects inject into new chat sessions and cause hallucinated requirements).

**Verifier availability.** Claude cold names this the under-discussed feature — whether the task has an external oracle (unit tests, type-check, schema validation). ChatGPT lists it as *verification affordance pack* and explicitly tags it `[Rare]`, surfacing it as one of the field's unsaid options. Both sources argue this changes the architecture choice — narrow-execution / wide-verification becomes viable when verifiers exist; without them, you need a different debugging strategy.

**Reversibility.** Claude cold flags this as missing from the brief, naming it as a *risk* feature distinct from the *performance* features. The router output should reflect it (driving the budget/stop-policy axis, not the execution-unit axis). ChatGPT corroborates with *user-preference pack* and *temporal-state pack* — context features that change routing without being task features.

**What the field calls predictive but is actually noise.** Claude cold flags task horizon (turns / wall-clock) as more confounder than feature, since METR's logistic curve fits regardless of architecture. Surface telemetry (prompt length) is similarly weak. Cursor confirms via production reports: regex/keyword routing is the first casualty in production (arXiv 2505.12601v1: *"Regex and keyword-based routing fail to capture the intent or complexity of a query"*). Domain keywords ("code", "research", "writing") are weak — within "code" you have one-line fixes through multi-repo refactors.

The convergent recommendation: **5–7 hand-engineered features, mostly inferable from task text, with one or two requiring runtime probing**. ChatGPT's eight-pack list and Copilot's regex-based extractor are the two most concrete instantiations. Together they describe the same animal from different angles.

### 2 — Training data

This is where Episode 2's claim gets pressure-tested, and where all sources agree the cost lives.

**Existing benchmark traces are partially usable but limited.** Gemini cites the HAL (Holistic Agent Leaderboard) dataset — Princeton PLI, 2.5B tokens of agent logs, 21,730 trajectories across τ-bench, AgentBench, GAIA. *Treat the specific HAL figures as suspect-pending-verification: only Gemini surfaced this dataset, and Cursor's gap-analysis explicitly notes "no replication trail" for several 2025–2026 routing papers.* Claude cold offers a more conservative estimate: 1–5K labelled task-architecture pairs are recoverable by aggregating across SWE-bench Verified, GAIA, AgentBench, τ-bench *if* you can extract per-task pass rates by architecture, which most published results don't break out. Copilot grounds this with concrete SWE-bench schema (`instance_id`, `problem_statement`, `patch`, `test_patch`) and τ-bench's evaluation criteria — usable raw material.

**Production execution logs are where the real signal lives, and a solo founder doesn't have them.** Anthropic, OpenAI, Cursor, Cognition, Replit Agent, Sourcegraph all hold meaningful traces. None are available externally. Claude cold's bootstrap path — instrument your own production system, accumulate logs over weeks-to-months — is the path RouteLLM took. ChatGPT names it *self-instrumented founder traces* and tags it `[Rare]` because most teams don't think to mine their own Claude Code / Agents SDK sessions.

**Synthetic generation is the cheap viable path, but the failure modes are real.** Claude cold sketches the recipe: 10K synthetic task-architecture pairs at $0.01–0.05 per generation = $100–500 in API. Cursor surfaces the failure modes from production literature: *model collapse / autophagy* (recursive training on synthetic data loses variance), *fidelity gaps* (synthetic data fails to capture real-world complexities like temporal patterns, hierarchies, "messy" human inputs), *artifactual relationships* (generative methods create false correlations). The trap is circularity: you're training a classifier to predict what the strong model thinks, which is just distillation of the strong model's intuitions about routing — fine if those intuitions are good, unknown if they aren't.

**RouteLLM's preference-data approach is the cleanest precedent.** Cursor surfaces the operational reality: the published 65K dataset (`D_arena` from LMSYS Chatbot Arena) was not released; community fork (Liqs-v2) reports preprocessing yielded **only 19K usable instances**. RouteLLM also suffers BERT-router majority-class overfitting (macro F1 0.23–0.35) — symptomatic of imbalanced training data (51% strong-model wins). Reproduction is infeasible without the original dataset.

**ChatGPT's divergent contributions.** Public agent trace dumps on Hugging Face (`huggingface.co/datasets/REXX-NEW/my-personal-claude-code-data`, `lelouch0110/claudeset-community`) are weak but abundant supervision. Prediction-market labelling (raters bet on winning routes; market confidence becomes both label and uncertainty signal) is genuinely novel. User-paid labels via product credits (ask users "was this route worth the latency/cost?" with credit rewards) is plausible at v1 but not v0.

The convergent v0 data path: **synthetic generation (~10K pairs, ~$200 API) + benchmark trace mining where available + a 200-task hand-curated validation set from the founder**. Skip preference data for v0; defer to v1 once production traffic exists. Cursor's cost benchmarks corroborate: text classification labels cost $0.10–$0.40 each manually; LLM-as-oracle cuts cost 70–85% per arXiv 2502.16892v2.

### 3 — Classifier shape

The most-converged answer in the cold round, because every source independently arrived at the same v0 recommendation: **rule-based heuristic plus a fallback layer**.

**Rule-based heuristic.** Claude cold: 6–10 hand-tuned rules covering obvious cases. *"What most production systems actually run today, including Claude Code's subagent dispatch and Cursor's agent mode selection."* Copilot makes it concrete:

```python
def rule_router(features: dict) -> tuple[str, float]:
    score = 0.0
    score += 0.35 if features["token_est"] > 180 else 0
    score += 0.25 if features["file_mention_count"] >= 2 else 0
    score += 0.15 if features["code_fence_count"] > 0 else 0
    score += 0.15 if features["action_verb_hits"] >= 3 else 0
    score += 0.10 if features["ambiguity_score"] > 0.3 else 0
    label = "orchestrated_decomposed" if score >= 0.45 else "single_shot_monolith"
    return label, score
```

ChatGPT names this `rule-prefix + learned tail` and recommends it as the cheapest viable v0. The pattern captures 60–80% of available routing gain on most production workloads, per Claude cold's estimate.

**BERT-class small classifier.** Claude cold pegs this as the right v1 once data exists. Copilot grounds it with code: MiniLM (`sentence-transformers/all-MiniLM-L6-v2`) producing embeddings, sklearn LogisticRegression on top, sub-50ms inference on CPU, hours-of-training cost on a single GPU. RouteLLM's `bert` router family is the production reference (router selection via `bert-mf`, `causal_llm`, `sw_ranking`, `random` — all configurable as `router-<name>-<threshold>` model strings). ChatGPT calls the same shape `kNN over solved-task embeddings` and rates it the strongest cheap v0 — nearest solved tasks vote on route, cost target, and fallback.

**Fine-tuned LLM (small).** Gemini's recommendation — a 1.5B parameter generative model (Llama-3-1B fine-tuned on a Domain-Action Taxonomy) with ~51ms inference latency, is the *Arch-Router* pattern (Katanemo, 2025). All other sources flag this as month-1 work, not v0. Claude cold: *"10× more expensive to run than BERT, 10× more expensive to fine-tune, harder to debug. Diminishing returns over BERT-class for a discrete classification task. Skip for v0."* Copilot's LoRA-on-Mistral-7B sketch is similar in spirit — feasible but not first.

**Frontier-LLM-as-router.** Calling Claude Haiku or GPT-4 with a structured routing prompt. Claude cold's surprising recommendation as the *prototype* tier — no training data needed, validates the configuration space end-to-end, *then* you train a cheaper classifier on accumulated decisions. ChatGPT surfaces the failure mode: Cursor's read confirms *"Avoid LLM-as-a-Router — early attempts to use a large LLM to decide routing are often reported as too costly and unreliable"* (r/LLMDevs/1nsi2g7). The arXiv 2602.03478v1 paper *"When Routing Collapses"* documents the systematic-default-to-expensive-models failure mode.

**Convergent v0 architecture.** A two-phase progression Claude cold articulates cleanly:

- *Phase 1 (week 1):* rule-based heuristic with 6–10 hand-tuned rules + frontier-LLM (Haiku) fallback for ambiguous cases
- *Phase 2 (weeks 2–4):* replace the frontier-LLM fallback with a BERT classifier trained on the rules → frontier-LLM → outcome logs

End state: rules handle ~70% of traffic at zero latency; BERT handles ~25% at <50ms; frontier-LLM handles ~5% as a high-confidence fallback.

Cursor's production data corroborates the cost target: Morph LLM Router reports ~430ms classification latency, $0.001 per classification, 40–70% cost reduction at <2% quality loss — these are achievable numbers for a solo-founder v0.

### 4 — Measurement loop

The least-converged sub-question, because the right validation methodology depends on what you're trying to prove and how much production traffic you have.

**The counterfactual problem is fundamental.** Claude cold names it explicitly: to know the router is good, you need to compare its decisions against decisions it didn't make. Three options for the solo founder, in increasing data requirements:

- *A/B test with random architectures* — randomly assign tasks to architectures, log outcomes, fit performance-by-architecture-by-task-features curves, compare router decisions against the dataset's best-architecture-per-task. Clean but expensive.
- *Counterfactual replay* — take historical task logs, replay with multiple architectures, build a (task, architecture, outcome) corpus. Cheaper because tasks are reusable.
- *Causal inference from observational data* — fit causal models from natural variation. Solo founder doesn't have the volume.

**Smallest experiment that proves v0.** Claude cold's specific proposal: a 100-task validation set, hand-curated to span the feature axes. For each task, run monolith (full context), granular handoff (3-agent decomposition), and the router's recommendation. Score by weighted metric (task success × cost × latency). Router *moves the needle* if recommendations equal-or-beat the best-fixed-architecture baseline on the weighted metric across the 100 tasks. Estimated cost: ~$150 in API + 1 day of founder time. The bar is sharp: not "router beats monolith" or "router beats granular", but "router beats the better of monolith-or-granular fixed baseline on a task-by-task basis." Below 5% improvement, routing overhead probably isn't worth the complexity. Above 20% would be surprising.

**Production measurement surfaces post-v0.** ChatGPT's eight-pack — *expected session regret*, *recovery-aware eval*, *shadow replay*, *route stability tests*, *Pareto frontier dashboard*, *golden-cluster regression*, *confidence calibration* — extends what Episode 1 already named. The most under-noted: ChatGPT's `route stability under paraphrase` test, where you paraphrase the same task and check if routing flips too easily. Unstable routers look smart on benchmarks and fail in products. Cursor surfaces the production cousin — distribution drift detection via Population Stability Index (PSI) and KL divergence, plus the "agent drift" pattern from medium.com/adnanmasood where routing logic becomes stale.

**Measurement traps.** Cursor's trenches read names them: *Goodhart's Law / metric rot* (high offline pass rates mask real-world degradation; static "golden datasets" rot as user behaviour evolves), *deterministic leakage* (model generates conversational text when a structured tool call is required), *evaluation leakage* (eval datasets not updated with novel production edge cases), *silent failures* (LangGraphJS issue #779: graph stops executing entirely without surfacing an error). Galileo.ai's specific finding: numeric scales (0–100) introduce more noise than binary (pass/fail) verdicts.

**Frameworks and observability.** Copilot grounds the measurement loop with concrete code patterns — LangGraph's `StateGraph` + `add_conditional_edges` for branching A/B harnesses, OpenAI Agents SDK's `RunConfig` + `ModelSettings.tool_choice` for global controls, Claude Agent SDK's `ClaudeAgentOptions(agents={...})` + `AgentDefinition` for subagent dispatch, RouteLLM's built-in `calibrate_threshold.py` and `evaluate.py` modules. The infrastructure for measurement is shipped; the test set is what you have to build.

### 5 — Failure modes and fallbacks

**Fixed fallbacks are wrong sometimes; the right fallback is escalation by stakes.** Claude cold's framing is the cleanest:

- Low stakes / low confidence → cheapest architecture (monolith with reasonable context). User can re-run.
- Low stakes / high confidence → trust the router.
- High stakes / low confidence → human-in-loop. Surface the routing decision with rationale; let the user override.
- High stakes / high confidence → still surface the decision (the user should know they're getting a non-default architecture for high stakes), but don't gate execution.

**This requires stakes detection as a separate feature.** Reversibility of actions, presence of "production"/"deploy"/"payment" keywords, file paths in protected directories. The router uses this to decide its *own confidence threshold*, not the architecture choice.

**Avoiding the SPOF problem.** Three mitigations the sources converge on:

- *Confidence thresholds with graceful fallback* — router outputs a configuration *and* a confidence score; below threshold, fall back to monolith. The router never "tries hard"; when uncertain, it defers.
- *Trace visibility* — every routing decision becomes a span in the agent's trace, queryable post-hoc. Non-negotiable: a router without traceability is worse than no router.
- *Periodic baseline runs* — once a week, randomly route 5% of traffic to always-monolith regardless of router output. If the baseline starts winning, the router has degraded.

**Concrete failure modes from production.** Cursor's catalogue from real GitHub issues: OpenAI Agents SDK issue #2216 (*all handoffs route to last handoff in list* — closure-related bug); issue #617 (*orchestrator agents fail to trigger multiple handoffs*); issue #771 (*only one handoff getting called no matter what*); RouteLLM's LiteLLM regression #25629 (broke OpenRouter routing on `custom_llm_provider='openrouter'`). LangGraphJS issue #779 (graphs fail silently in conditional edges). These aren't corner cases — they're the canonical production failure surface.

**ChatGPT's seven fallback patterns.** *False decomposition → collapse to monolith* (when coordination-tax estimate is high or confidence low); *under-routing discovery tasks → route to scout/discovery agent first*; *catastrophic low-confidence choice → abstain, ask clarifying question, or require human approval for irreversible actions*; *cheap-route overconfidence → escalate on validator fail*; *OOD/new-domain prompts → freeze to safest general route and log for labelling*; *history contamination → reroute using current turn only plus compressed facts*; *close-margin ambiguity → run top-2 routes in parallel for high-value tasks, pick by validator/judge*.

The deepest failure mode, which Claude cold names: **the router can be wrong in a way that *looks* like the architecture failed, when really the routing failed.** Debugging requires telling these apart, which requires the trace fidelity Episode 1 surfaced as a load-bearing metric. If you can't see why the router picked what it picked, you can't fix it.

### 6 — Cost of v0

The widest divergence across sources, because cost depends sharply on what counts as "v0".

**Cheapest plausible v0 — weekend to two weeks, $0–$300.** ChatGPT's lowest tier: 3–7 days, rules + kNN, 200–500 self-labelled tasks, no paid data. Copilot corroborates: 400–900 LOC, weekend scope, $20–$150/month infrastructure. This is the rule-based-with-frontier-fallback that every source recommends as the actual v0.

**Cheap real-data v0 — 1–4 weeks, $200–$1,500.** Claude cold's specific recipe: synthetic generation (~$200 API), validation comparison (~$150 API), BERT fine-tuning free on Colab. Total ~$400. Copilot's "2–4 week v1" tier matches: MiniLM/BERT classifier + threshold calibration + online dashboards + drift checks, 1.2K–3K LOC, $100–$800/month infrastructure.

**Month-scale robust v0 — 3–5 weeks, $1K–$15K.** ChatGPT's middle tier: 5K–20K tasks, kNN or tiny encoder, synthetic augmentation, recovery policies, cluster evals.

**Quarter-scale serious solo build — 2–3 months, $10K–$100K+.** ChatGPT's high tier or Gemini's recommended scope. Contextual bandit + shadow traffic + paired judging + fallback validators. The marginal effort here is better spent on better base models or better framework primitives, per Gemini's *"once a router achieves 90% of the Pareto frontier, marginal effort is better spent on DSPy-style architecture optimisation rather than better routing classifiers."*

**The economic pivot point all sources name.** ChatGPT's load-bearing observation: *"Current API pricing makes classifier inference cheap; gpt-5.4-mini is $0.75/M input and $4.50/M output, while Claude Haiku 3.5 is $0.80/M input and $4/M output. The expensive part is collecting route-outcome labels, not training the classifier."* Cursor confirms: solo founders have shipped v0 routers (neuralrouting.io, Frugger, LLmHub.dev) — but the universal regret is skipping structured logging for routing decisions, which leaves you flying blind when drift hits.

**When routing is *not* worth building.** Claude cold's three contraindications:

- *Narrow task domain* — if 95% of tasks fit a narrow template, the best fixed architecture probably wins. Routing adds complexity for marginal gain.
- *Strong base model improvements imminent* — if a frontier model release is expected to push monolithic performance up by 10 points, that's the better investment.
- *Compound system improvements available* — if your system has 30%+ remaining gains from prompt engineering, RAG quality, tool descriptions, or basic eval-driven iteration, those are higher-leverage than routing.

The pattern: routing is worth building when single-architecture improvements are exhausted *and* the task distribution is wide enough that no fixed point on the spectrum dominates. For most solo-founder products at v1, that's not yet true. By v2 or v3 it often is.

### Closing — what this commits us to

The sources converge on a different recommendation than the brief implicitly proposed. The brief asked *can a solo founder build a v0 today*. The sources answered *yes, but the v0 is rules + instrumentation, not a model*. The classifier is the wrong v0. The premature optimisation is the model; the underrated-and-cheap move is **the taxonomy plus rules plus instrumentation**.

Claude cold articulates this most directly: *"Build the taxonomy now, defer the classifier. Define the feature set and the configuration space. Hand-write rules. Ship a rule-based router. Use it as a measurement instrument that lets you see the spectrum in your own product's traces. Then — six months later, with real production data — decide whether to upgrade to a learned classifier."* This matches Episode 1's diagnosis exactly: the field has the primitives but lacks the taxonomy. The missing layer is human design work, codified as rules, validated against data, only later replaced by a learned component.

Cursor's gap analysis underwrites this with what it could *not* find: no production deployment stories for MasRouter (the ACL 2025 paper darling) outside academia, no GitHub repos for TRouter / Arch-Router / MoMA, no replication trail for several 2025–2026 routing papers. The literature is ahead of the production surface; the production surface is hand-tuned rules with confidence thresholds.

**Suspect citation flags from this round.** Gemini surfaced several routing-specific items not corroborated by any other source: *ProbPol*, *SIRP IETF standard 2026*, *WRP (Workload-Router-Pool)*, *Foster et al. 2026* on linear difficulty representations, *Chen et al. 2026* on Pareto-frontier consensus. Treat these as unverified pending direct check. The HAL dataset (Princeton PLI, 2.5B tokens / 21,730 trajectories) is plausible but only Gemini surfaced it — flag for verification before any external publication. The arXiv IDs from Cursor (2602.03478v1, 2604.02367v1, 2604.16790v1, 2604.14531v1, 2604.09377) are dated within plausible 2026 ranges and matched against named GitHub issues / Reddit threads — treat as plausible-pending-individual-check, not pre-flagged.

### What this commits us to (and doesn't)

No ADRs land in `../decisions/` from this synthesis. The synthesis is a *map of the v0 landscape*, not a commitment to ship a router. ADRs land when an actual implementation forces the architectural call — most likely when BorAI's routing layer or a future Yurika product reaches the v0-build decision.

What this synthesis *does* commit us to — for the pilot.html extension:

- **Router-in-a-box (Episode 2's planned interactive #1)** must demonstrate the *rules-plus-fallback* pattern, not pretend to be a learned model. The reader inputs a task; the page extracts features (parallelisability, tool count, context-noise estimate, verifier availability); rule-based scoring produces a configuration and confidence; ambiguous cases visibly fall through to a frontier-LLM mock. The interactive's argument is the synthesis's argument: *the v0 is rules with traceability, not a model.*
- **Feature explanations are load-bearing.** Each feature on the input panel should have a one-line explanation drawn from this synthesis, not generic ML-101 hand-waving. Parallelisability explanation cites the explicit-list-and-cardinality signal Copilot surfaced; verifier availability cites the asymmetric narrow-execution / wide-verification pattern Episode 1 surfaced.
- **Confidence threshold exposure.** The router outputs *configuration + confidence*. Below threshold, the diagram visibly falls back to monolith with a *low confidence* annotation. Hide the model behind the rules-and-fallback pattern; don't pretend the router is opaque.
- **Cost panel.** Show approximate cost per classification ($0.001 budget per Morph LLM Router), and the labour cost multiplier between rules-only and learned-classifier paths.

**Episode 3 candidate question.** The synthesis surfaces it cleanly: *should we build a v0 router for BorAI right now, or wait?* The decision-not-the-research version. If yes, what's the specific feature taxonomy for BorAI's task distribution, what's the 100-task validation set, what's the fallback policy? Episode 3 turns the abstract framework into a concrete spec for a real system — and triggers the first ADR in `../decisions/`.

**Source-coverage gap to fix before Episode 3.** Perplexity's production-blog citation density and Grok's contrarian X discourse both blocked on Chromium launch failures (no display server in this environment). Either install xvfb (`sudo apt-get install -y xvfb`) and re-fire both sources, or accept the gap and proceed to Episode 3 with five-source synthesis as the working baseline. The gap is documented in `../sources/2026-04-27-perplexity.md` and `../sources/2026-04-27-grok.md` as BLOCKED with unblock instructions.

## Interactives shipped

Build order:

1. **Router-in-a-box** — reader inputs a task description; the page calculates feature scores (parallelisability, tool count, state coupling, expected context noise, baseline accuracy estimate); displays a recommended position on the four-axis spectrum with a confidence score and a one-line rationale. Embodies the v0-could-it-work claim.
2. (TBD — depends on synthesis findings; candidates: feature-importance visualiser, training-data-source decision tree, cost-of-v0 calculator)

Target: `../pilot.html` at the root of `research/agent-architecture/`. Episode 1's topology switcher stays; this one extends.

## Decisions triggered

*ADRs land in `../decisions/` if Episode 2 forces architectural choices for BorAI's routing layer or for an upcoming Yurika product. Likely candidates if v0-is-buildable lands as the verdict: (1) which features the BorAI router uses, (2) whether to use a rule-based or learned classifier for v0, (3) what the fallback policy is when the classifier is uncertain.*

## Graduation trigger

When this episode's synthesis commits, the thread graduates from `research/agent-architecture/` to `campaigns/agent-architecture/` per the rule in `../README.md` and `~/.claude/skills/living-research/references/adr-and-graduation.md`.

---

## Addendum — 2026-04-27 evening (Perplexity recovered, Grok still blocked)

*Delta on the original synthesis. The 5-of-7 verdict above stands as historical record; this section is the update once the Chromium re-fire ran. Original synthesis is not retro-edited.*

### What unblocked, what didn't

Chromium launch unblocked for **Perplexity**: `ask-perplexity-cli` ran cleanly under `xvfb-run -a -s "-screen 0 1920x1080x24"` after killing a stale `zsh until` loop that had been holding the chromiumoxide runner from a parallel job. The earlier handover note's diagnosis (display server missing, BrowserConfig flags incomplete) was half-right — the display half was true on the older session, but on this run xvfb plus a clean runner directory was sufficient. Chromiumoxide does work; the prior session's failures were a process-orchestration issue, not a chromiumoxide regression. Patches to `~/code/ghostroute/ask-perplexity-cli/src/browser/mod.rs` are not required for Perplexity. The new dump is in `../sources/2026-04-27-perplexity.md`.

**Grok stayed blocked** for a different reason. `ask-grok-cli` reaches `[Timing] Input located: 8826ms` reliably under both `headless=true` and `headless=false` (with xvfb), then hangs after the "Drunk-Typist" paste step with no further output for 30+ minutes — same point at which the prior session reported `Failed to paste previous context into input field: Key not found: ≥`. Wiping `.claude/.swarm-memory.json` to remove non-ASCII characters resolves the explicit Unicode error but does not unblock the underlying typing/submit flow. The grok.com DOM has likely shifted: the input field is found, but the synthetic paste either fails silently or the response selector no longer matches. **Fix is upstream in `~/code/ghostroute/ask-grok-cli/src/automation/`, not in the vault.** This is the single open question raised back to the user. The Grok dump for 2026-04-27 keeps its prior status (`STATUS: EXTRACTION STILL FAILED`) plus a note recording today's diagnosis.

### Verdict under stress test

**Perplexity sharpens the verdict.** It does not weaken it. The original synthesis said *the v0 is rules + instrumentation, not a model*; Perplexity's production survey turns that from a recommendation into a documented production pattern. Three concrete sharpenings:

- **The under-100–300-queries-per-day threshold.** Perplexity names it explicitly: *"Below ~100–300 high-quality LLM queries per day, the overhead of maintaining a router usually outweighs the cost savings."* Episode 1 already implied this; Episode 2 hand-waved at *"narrow task domain"*; the addendum makes the threshold a number. Solo founders below that bar should not be building a router.
- **Routing collapse is the canonical failure, not the SPOF.** Perplexity foregrounds the *"When Routing Collapses"* paper (arXiv 2602.03478v1, also surfaced by Cursor in the original round) as the single biggest documented failure mode: *"learned routers start to over-use the strongest model as cost-budgets rise, even when weaker models are sufficient, completely undermining the cost-savings promise."* The mechanism is **objective-decision mismatch** — predicting a scalar score versus making an argmax decision. This is a sharper version of Episode 2's SPOF concern. The naive confidence-based fallback that Episode 2 recommended (low confidence → cheaper architecture) actively makes routing collapse *worse*, by ratcheting traffic toward the strong model. Interactive 2 implements the inverse: low confidence → fall back to *monolith*, not to the more expensive route.
- **RouterBench is a real dataset; the production routers use it.** Original synthesis flagged HAL as suspect-pending-verification because only Gemini surfaced it. Perplexity replaces it with **RouterBench** (35–36k prompt-response pairs across ~11 models, 8 benchmark domains; arxiv.org/abs/2403.12031, ACL/MLSys community-maintained), which LLMRank, EquiRouter, and SCORE-style deployments all train on. This is a meaningful upgrade to the v0 training-data path: synthetic generation plus RouterBench-derived labels gets a solo founder closer to a usable preference signal than the synthetic-only recipe Episode 2 originally named.

What Perplexity *does not* contradict: every framework-specific claim Episode 2 made (Anthropic Workflows subagent dispatch, OpenAI handoff filters, RouteLLM's `bert-mf` family, MasRouter's three-layer cascade) survives intact. The new sources Perplexity surfaces — *Causal LLM Routing* (NeurIPS 2025, openreview), *EquiRouter*, *LLMRank*, *SkillRouter* — are additive, not corrective.

What Perplexity *does* contradict: the original synthesis listed task horizon as noise (Claude cold's call). Perplexity reports turn count and prompt length *are* the working features in production routers — *"Long-turn / multi-tool trajectories are often routed to more capable, but slower, agents."* Reframing: turn count is noise as a *predictor of architecture choice*, but a working signal as a *predictor of model tier*. The two are not the same routing decision. Interactive 2's score function uses tool count but not turn count, by design.

### Grok absence — what we cannot see

The contrarian-X-discourse gap remains. The original synthesis's Grok quote from Episode 1 (*"the correct position changes per task — but building the router that reliably knows is the real unsolved primitive"*) still does the load-bearing work. What is missing: 2026 X threads naming specific rip-outs (*"we removed the router"*) and anti-DSPy takes. Without those, the verdict is *confirmed/sharpened by the production blog corpus, untested against the 2026 contrarian discourse*. Cursor's Reddit-and-GitHub coverage from the original round partially fills the gap — `r/LLMDevs/1nsi2g7`, the LangGraphJS #779 silent-failure thread — but X-native voices remain absent.

### Net call

The Episode 2 verdict — **the v0 buildable today is rules + instrumentation, not a model. Taxonomy and labels are the bottleneck, not the classifier.** — is **sharpened**, not weakened, by the Perplexity dump. The routing-collapse mechanism makes the original "naive confidence fallback" recommendation slightly more dangerous than Episode 2 admitted; Interactive 2 ships with the inverse rule (fall back to monolith, never to the strong model on low confidence) on that basis.

### Commitments paragraph (revised)

The Episode 3 trigger question — *should BorAI build a v0 router right now?* — moves from **queued** to **queued (with an Episode 3 cold round to follow)**. The decision is *not* now. No ADR opens in `decisions/` from the addendum alone. The reason: Perplexity's 100–300 queries/day threshold lands above BorAI's current traffic, and the routing-collapse risk argues against deploying a learned router before the rules and instrumentation have generated production logs to validate against. BorAI ships with rules-and-instrumentation by default per the original synthesis; Episode 3 will determine whether and when to graduate to a learned classifier. The first ADR in `decisions/` lands when Episode 3's synthesis commits, not before.

### Source-coverage status (revised)

| Source | Status | Date |
|---|---|---|
| Gemini | Recovered (2026-04-27 original round) | 04-27 |
| Perplexity | **Recovered (addendum)** | 04-27 evening |
| Claude (cold) | Recovered (original round) | 04-27 |
| Grok | **Still blocked** — upstream `~/code/ghostroute/ask-grok-cli/` Drunk-Typist / response-selector regression. Escalated to user. | 04-27 (both attempts) |
| Copilot CLI | Recovered (original round) | 04-27 |
| Cursor Agent | Recovered (original round) | 04-27 |
| ChatGPT | Recovered (original round) | 04-27 |

Five-of-seven became **six-of-seven**. The contrarian-X gap remains the single un-closed source. The verdict's load-bearing work survives the recovery without needing it.
