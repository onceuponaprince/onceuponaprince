# Claude (cold) — raw dump 2026-04-27

**Routing role:** Independent first-principles synthesis from training, before seeing other source dumps.
**Tool:** None — direct write from this subagent's own knowledge.
**Brief:** Episode 2 — The router we cannot yet build. See ../episodes/02-the-router-we-cannot-yet-build.md.

---

## Frame before answering

The claim under test sharpens Episode 1's open work. Episode 1 established that agent architecture is a spectrum, position is task-contingent, and framework primitives (LangGraph `Command`, OpenAI handoff filters, Claude SDK subagent isolation, Pydantic AI's three layers, DSPy's optimisation surface) are mostly in place. Episode 2 asks whether the *router* — the thing that picks the position per task — is buildable today by a solo founder. The candidate hypothesis is that it is buildable, and that the bottleneck is not modelling but feature engineering and labelled data.

I want to flag one upfront uncertainty before answering. The literature on routing is thin in two specific ways. First, RouteLLM-style work routes between *models* (strong/weak), not between *architectures* (monolith/handoff/swarm/debate). The transfer is non-trivial. Second, MasRouter and Arch-Router papers define taxonomies but do not (to my knowledge) report ablations that isolate which features carry the predictive load. So when I rank features below, I am extrapolating from adjacent work — model routing, query difficulty estimation, mixture-of-experts gating, multi-armed bandit task allocation — onto a problem that has not been cleanly studied. Treat the rankings as priors, not measurements.

---

## 1. Predictive features — what the router needs to know

The brief lists candidate features: parallelisability, tool count, state coupling, expected context noise, prior single-agent baseline accuracy, task horizon, verifier availability. I'll go through them and add a few the brief misses.

### High-signal, inferable from task statement

**Parallelisability.** The single strongest feature, and the one most cleanly inferable from the brief alone. A task is parallelisable if its sub-goals are independent — multi-file refactor where files don't share state, multi-source synthesis where sources are unrelated, comparative analysis across N candidates. A small classifier (or even a hand-written rule using verb counts and conjunctive structure) can detect this with reasonable precision. The signal: explicit list structures in the prompt ("for each X, do Y"), explicit cardinality ("ten companies", "all the files in this directory"), conjunctive verbs without sequential markers. Failure mode: false positives on tasks that *look* parallel but have hidden coupling — refactoring three files that all import from a shared module.

**Tool count and tool diversity.** The number of tools the agent will need, and how heterogeneous they are. High tool count favours granular agents because tool-selection accuracy degrades sharply with tool catalogue size — the *Lost in the Tools* effect, Anthropic and others have measured selection accuracy collapse past ~30–50 tools. Crucially, this is about *active* tool count for the task, not the framework's total catalogue. A task that needs only file-reading and one shell command sees a small tool-count regardless of what's available. The signal: domain keywords in the brief that imply tool families. Failure mode: tool count is a proxy for something else — really we want to know whether tool-selection is the bottleneck, which depends on tool-name overlap and description quality, not just count.

**Expected context noise / context entanglement.** How much irrelevant prior state the task will have to swim through. High for debugging where prior failed attempts contaminate; low for fresh single-shot tasks. This is partially inferable from the brief (a debugging brief signals contamination risk) and partially requires runtime probing (you don't know the conversation has accumulated 40K of dead-end context until you look at it). I'd argue this is *the* signal that justifies stripping context — and Episode 1 confirmed context-stripping wins in exactly this regime.

**Verifier availability.** Whether the task has an external oracle — unit tests, type-check, schema validation, deterministic output the agent can self-check against. This matters because verifier-availability changes the optimal architecture: with a verifier, asymmetric narrow-execution / wide-verification (the under-noted production pattern from Episode 1) becomes viable; without, you need a different debugging strategy. Inferable from task domain: code tasks have verifiers, prose tasks usually don't, structured-output tasks have schema verifiers.

### High-signal, requires runtime probing

**Prior single-agent baseline accuracy.** The most predictive feature in principle — if a single agent already solves this class of task at 95%, the router should default to monolith and only escalate. But you can only know this by running the baseline, which costs tokens, and the result is a function of model + prompt + task, not just task. This makes it less a feature than a *prior* the router accumulates over time. RouteLLM uses preference data (which model wins on a query) to fit an analogous curve.

**State coupling between sub-goals.** Whether sub-goal B depends on the *output of* sub-goal A vs merely the *existence of* sub-goal A. A planning task with sequential dependencies is high-coupling; a parallel literature search is low-coupling. Hard to infer from brief alone — a task that says "first do X, then do Y" might have high or low coupling depending on what X produces. Often only knowable mid-execution.

**Coordination tax estimate.** What ChatGPT (per Episode 1) called the load-bearing variable: `message count × message entropy × synchronization depth × verification load`. This is a *predicted* cost of running the task in granular mode. Hard to know upfront — you can estimate message count from sub-goal count, but message entropy depends on how decomposable the work actually is.

### Low-signal or noise

**Task horizon (turns/wall-clock duration).** Tempting because long tasks feel like they need orchestration. But Episode 1's METR work fits a logistic curve where success probability falls with task duration *regardless of architecture*. Long horizon is more a confounder than a feature. Use it as a budget input, not a routing input.

**Domain keywords ("code", "research", "writing").** Surface-level but weak. Within "code" you have tasks ranging from one-line fixes to multi-repo refactors. Domain is a feature only insofar as it correlates with tool count and verifier availability, which you should measure directly.

**Prompt length.** Often used as a proxy for task complexity (RouteLLM uses BERT embeddings of the query, which captures length implicitly). Probably weak signal — long prompts can be elaborate single-step tasks; short prompts can be open-ended explorations. Don't lean on it.

### Features the brief misses

**Reversibility.** Whether actions are undoable. Tasks that write to disk, send emails, make payments need different routing than read-only tasks. High-reversibility tasks tolerate aggressive granular exploration; low-reversibility tasks want monolithic supervision. This is a *risk* feature, not a *performance* feature, and it should drive the budget/stop-policy axis of the router output, not the execution-unit axis.

**Schema-determined output structure.** If the task output is a known schema (JSON, function call, structured form), the architecture choice collapses — you want the cheapest thing that produces valid schema, almost always monolith with structured output mode. Schema-determined tasks shouldn't even reach the router in many cases.

**User intervention budget.** How much human-in-the-loop is acceptable. Tasks where the user is watching tolerate lower-confidence routing (escalate to human on ambiguity). Tasks running unattended need higher router confidence or aggressive fallback. This is a context feature, not a task feature, but it changes routing materially.

### Ranking summary

If I had to pick the top five for a v0 — features that are both predictive and cheaply inferable from the task statement — I'd pick: parallelisability, active tool count, expected context noise, verifier availability, reversibility. These five together discriminate the four corners of the spectrum (monolith vs swarm × narrow context vs wide context) reasonably well. The remaining features are second-order refinements.

---

## 2. Training data — what exists, what can be cheaply made

The training-data question is where this whole thing is hardest, and where I think the "buildable today" claim gets pressure-tested. The honest answer: there is no clean labelled dataset for "task X performed best with architecture Y" at the scale needed for a learned classifier. What exists:

### Benchmark traces, partially usable

**SWE-bench / SWE-bench Verified.** Has thousands of tasks with ground-truth solutions and pass/fail signals. Multiple agent architectures have been evaluated on it (SWE-agent, AutoCodeRover, Aider, MetaGPT, Verdent, Claude Code). If you can recover per-task pass rates by architecture, you have implicit labels: "task ID 1234 was solved by monolith but not by hierarchical multi-agent" → label this task as monolith-favouring. The challenge is most published results report aggregate scores, not per-task breakdowns. You'd need to either re-run the architectures (expensive) or scrape per-task results from leaderboards/papers that reported them (sparse).

**GAIA.** General AI Assistant benchmark, multi-step tool-use tasks. Similar shape — implicit per-task labels recoverable if you have access to traces.

**AgentBench.** Multi-environment benchmark covering OS, DB, code, web, etc. Strong on diversity but each environment has small task counts, so per-task labels are noisy.

**τ-bench (tau-bench).** Tool-use focused, conversational tasks. Useful for the tool-count dimension specifically.

**HumanEval / MBPP.** Too narrow for architecture routing — almost all tasks are short enough that monolith wins.

The realistic claim about benchmark traces: you can probably get 1–5K labelled task-architecture pairs by aggregating across these benchmarks, but the labels will be noisy (single run, possibly stale), the task distribution will skew toward code tasks, and the architecture coverage will be uneven (every benchmark has 5–15 tested architectures, not 50). This is enough to fit a small classifier with significant variance, not enough to fit a good one.

### Production execution logs

Where the real signal would live, if it existed at scale. Anthropic has internal traces from Claude Code. OpenAI has ChatGPT agent traces. Cursor, Cognition (Devin), Replit Agent, Sourcegraph all have meaningful traces. None of them are available to a solo founder.

What a solo founder can do: run their own agent system in production, instrument it heavily, and accumulate logs. This is the bootstrapping path — start with a rule-based router, log everything (task features + chosen architecture + outcome metrics), use the logs to fit a better router. RouteLLM's preference data was generated this way, by running both strong and weak models and observing wins.

The realistic time estimate: to get 10K usable production traces, you need real users running real tasks for weeks-to-months. Not achievable in v0.

### Synthetic generation

The most viable cheap path. Use a strong model (Claude Opus, GPT-5, Gemini 2.5 Pro) to:

1. Generate task descriptions across the feature axes (parallelisable + tool-heavy + low-coupling, vs monolithic + simple + high-coupling, etc.).
2. For each generated task, predict which architecture would win (using the strong model's judgement as a proxy oracle).
3. Use the (task, predicted-winning-architecture) pairs as training data.

The obvious circularity: you're training a classifier to predict what the strong model thinks, which is just distillation of the strong model's intuitions about routing. This is fine if the strong model has good routing intuitions (we don't know that it does — Episode 1 didn't surface any benchmark of strong models as routing oracles). But it's a defensible v0: you bootstrap a small classifier from a strong model's predictions, deploy it cheaply, then iterate against real outcomes.

Estimated cost: 10K synthetic task-architecture pairs at $0.01-0.05 per generation (strong model + reasoning) = $100-500 in API spend. Cheap. The bottleneck is *prompt design for the synthetic generator* — making sure the generated tasks span the feature space rather than clustering around easy cases.

### Human labelling

A solo founder can label 200-500 tasks themselves in a focused day or two. Useful as a validation set, not as training data. The high-leverage move is to have the founder label the *edge cases* the synthetic data won't cover well — tasks where the strong model's routing intuition is suspect, tasks at the boundaries of the feature space.

### Preference data (RouteLLM-style)

The cleanest known precedent. Run two architectures on the same task, ask a judge (LLM-as-judge or human) which output is better, accumulate preferences, fit a classifier on (task → preferred architecture). Cost: 2× execution cost per labelled pair, plus judge cost. For a v0 with 5K pairs at maybe $0.10-0.50 per pair = $500-2500. Doable.

The trap: pairwise preferences over outputs are well-defined for model routing (which output is better?) but less clean for architecture routing (architectures differ on cost, latency, debuggability, not just output quality). You need a multi-dimensional preference judgement, which is harder to get and harder to fit.

### My recommended v0 data path

Synthetic generation as the bulk training set (10K pairs, $200 in API), benchmark trace mining for whatever you can get (1–2K pairs, free if you can find published traces), human labelling for a 200-task held-out validation set (one focused day of founder time). Skip preference data for v0 — defer until you have production traffic to generate it organically. Total: a week of solo-founder time, $200 in spend.

---

## 3. Classifier shape — cheapest thing that moves the needle

The question is what model architecture to put behind the (task → architecture-config) mapping. Four candidates, in increasing complexity.

### Rule-based heuristic

A handful of if-statements over the top features. "If task mentions multiple files explicitly, route to parallel-handoff with N=file_count. If task is single-shot code generation, route to monolith. If task is debugging with prior failed attempts in context, route to fresh-context monolith. If task involves >20 tool calls predicted, route to specialist subagent with curated tool subset. Else default to monolith with full context."

This is what most production systems actually run today, including (per my reading) Claude Code's subagent dispatch and Cursor's agent mode selection. It's not glamorous but it's *deployable* and *debuggable*. Estimated effort: 1–2 days for a solo founder to write and tune.

Where it fails: edge cases the rules don't anticipate; long-tail tasks; tasks where a feature is borderline (parallelisable but with hidden coupling). It also doesn't improve with data — every improvement is a manual rule edit.

The honest take: a rule-based heuristic with 6–10 well-chosen rules will likely capture 60–80% of the gain available from routing on most production workloads. The rest of this answer assumes the v0 will be rule-based with a learned component bolted on for ambiguous cases.

### BERT-class small classifier

What RouteLLM uses. Small encoder model (DistilBERT, MiniLM, or similar at 50–200M params), fine-tuned on (task description → architecture label) pairs. Cheap to run (sub-10ms inference on CPU), cheap to train (hours on a single GPU or in a Colab notebook), cheap to retrain.

Where it fails: features like "active tool count" and "verifier availability" are not directly visible in the task text — the BERT classifier has to learn to infer them, which is harder than reading them off explicitly. Also fails when tasks are very long (BERT's 512-token limit; you'd need to truncate or chunk).

The pattern that probably works: feed BERT the task description *and* a structured feature vector (parallelism estimate, tool count guess, etc.) extracted by a small pre-classifier or rule-based extractor. Two-stage: extract features → classify configuration. RouteLLM's similarity-weighted KNN approach is a variant on this.

Estimated effort: 1–2 weeks for a solo founder, including data prep, training, and integration. Latency: <50ms per classification. Cost: <$0.0001 per classification at inference. Probably the right v0 if you have the training data.

### Fine-tuned LLM (small)

Take a 1B–3B parameter model (Llama 3.2, Qwen 2.5, similar) and fine-tune it to output architecture configurations as JSON. More expressive than BERT classifier, can handle longer contexts, can output rich configurations rather than discrete labels.

Where it fails: 10× more expensive to run than BERT, 10× more expensive to fine-tune, harder to debug. Diminishing returns over BERT-class for a discrete classification task.

I'd skip this for v0. Revisit when the BERT classifier starts hitting a ceiling.

### Learned policy via RL

The "real" version of the router — treat routing as a sequential decision problem, train via RL on outcome rewards (task success × cost-efficiency × latency). This is what a Cognition or Anthropic could plausibly do internally with their trace data and infrastructure.

Where it fails for a solo founder: requires RL infrastructure, requires reward shaping (which is itself a hard research problem), requires lots of execution data to get useful gradients. Not v0 territory.

### Latency / cost tradeoff

For a router making decisions per-task in production:

- Rule-based: <1ms, free.
- BERT: <50ms, ~$0.0001 / decision.
- Fine-tuned LLM: 100–500ms, ~$0.001–0.01 / decision.
- Frontier LLM as router (a meta-call to Claude/GPT-5 with the task and asks for a routing decision): 1–5s, $0.01–0.10 / decision.

The frontier-LLM-as-router option is interesting because it's the cheapest to *prototype* (no training data needed) and the most expensive to *run*. For a solo founder shipping a v0, calling Claude Haiku with a routing prompt might be the right starting point — get the routing pipeline working end-to-end, validate the configuration space, *then* train a cheaper classifier on the accumulated decisions.

### My v0 recommendation

Two-phase. Phase 1 (week 1): rule-based heuristic with 6–10 hand-tuned rules covering the obvious cases, plus a frontier-LLM fallback (call Haiku with a structured prompt) for tasks the rules don't confidently handle. Phase 2 (weeks 2–4): replace the frontier-LLM fallback with a BERT classifier trained on the accumulated logs (rules → frontier-LLM → outcome). End state: rules handle 70% of traffic at zero latency, BERT handles 25% at <50ms, frontier-LLM handles the remaining 5% as a high-confidence fallback.

---

## 4. Measurement loop — what proves v0 works

The validation question is the one I'm least sure about, and I want to flag the reasoning carefully.

### Counterfactual problem

The fundamental difficulty: to know the router is good, you need to compare its decisions against decisions it *didn't* make. If the router picks monolith for task X and gets a result, you don't know what would have happened with hierarchical multi-agent on the same task. This is the off-policy evaluation problem, and it's hard.

Three options:

**A/B test with random architectures.** Randomly assign tasks to architectures, log outcomes, fit performance-by-architecture-by-task-features curves, compare against the router's choices. Clean but expensive (you're running architectures the router thinks are wrong, which costs tokens and quality).

**Counterfactual replay.** Take historical task logs, replay them with multiple architectures, build a (task, architecture, outcome) dataset, then evaluate router decisions against the dataset's best-architecture-per-task. Cheaper than A/B because tasks are reusable, but requires you to already have a corpus of completed tasks.

**Causal inference from observational data.** If you have natural variation in architecture (different users get routed differently), you can fit causal models. Solo founder doesn't have the volume.

### Smallest experiment that proves v0

A 100-task validation set, hand-curated to span the feature axes. For each task:

1. Run monolith with full context.
2. Run granular handoff (3-agent decomposition).
3. Run the router's recommendation.

Score each by a weighted metric: task success (binary, judged by hand or LLM-judge), cost (tokens), latency (wall-clock).

The router *moves the needle* if its recommendations equal-or-beat the best-fixed-architecture baseline on the weighted metric across the 100 tasks. This is a strong test — the bar isn't "router beats monolith" or "router beats granular", it's "router beats the better of monolith-or-granular fixed baseline on task-by-task basis."

If the router merely matches the best fixed baseline (because the best fixed baseline is right most of the time), you've shown the router doesn't help and you should ship the fixed baseline. If it beats the best fixed baseline, you've shown the routing claim has bite.

Estimated cost: 100 tasks × 3 architectures × ~$0.50 average = $150 in API. Plus ~1 day of founder time to score and analyse.

### What "moves the needle" should mean numerically

A 5–10% improvement on the weighted metric is plausible target. Below 5%, the routing overhead probably isn't worth the complexity. Above 20% would be surprising and would suggest the fixed-baseline comparison was poorly chosen.

I'd flag explicitly: I'm uncertain whether routing actually beats best-fixed-baseline by a meaningful margin in v0. Episode 1's evidence (MASEval, the *Towards a Science of Scaling Agent Systems* paper with -70% to +80% range) suggests *the gain is there to be had* — task-architecture mismatch is real and costly. Whether a v0 router captures enough of that gain to be worth building, I genuinely don't know. The honest answer is *probably yes for a heterogeneous task distribution, probably no for a focused one*.

### Continuous measurement post-v0

Once shipped, instrument the router with:

- Tokens-per-decision (Episode 1's load-bearing metric).
- Coordination tax ratio (fraction of tokens on inter-agent communication).
- Per-route success rate (success conditional on route).
- Confidence-vs-outcome calibration (does the router's confidence predict outcomes?).
- Fallback trigger rate (how often does the router defer to the frontier-LLM fallback or the human?).

The router improves if you can identify routes where success rate is below average and either (a) add rules to redirect those tasks elsewhere, or (b) retrain the classifier with the new logs.

---

## 5. Failure modes and fallbacks

The router becomes the new single point of failure if it routes confidently to a wrong architecture and the wrong architecture fails silently. Episode 1's Cursor citation about CrewAI silent delegation failure is the canonical example: the *system shape* says granular but the *trace shape* shows monolith.

### Where the classifier fails

**Out-of-distribution tasks.** Tasks unlike anything in training data. Solo-founder training data will have heavy code-task bias; a writing task or a research task might get badly mis-routed. Failure mode: confidently wrong.

**Adversarial-looking-tasks.** Tasks that match the surface features for one architecture but have hidden structure favouring another. The hidden-coupling case in parallelisable-looking tasks is the canonical example.

**Distribution shift.** Real production tasks drift over time as users learn what the system can do. Router trained at t=0 gets stale. Failure mode: gradual degradation, hard to notice without ongoing measurement.

**Rare high-stakes tasks.** Long-tail tasks the router has never seen, where being wrong is expensive (production deploy, payment processing). Failure mode: random architecture choice, possibly catastrophic.

### Fallback policy

The right fallback is *not* always-monolith or always-graph. Either fixed fallback is wrong sometimes. The right fallback is *escalation by stakes*:

- **Low stakes, low confidence:** default to cheapest architecture (monolith with reasonable context). Bias toward what the user can easily re-run.
- **Low stakes, high confidence:** trust the router.
- **High stakes, low confidence:** human-in-loop. Surface the routing decision to the user with one-line rationale, let them override.
- **High stakes, high confidence:** still surface the routing decision (the user should know they're getting a non-default architecture for a high-stakes task), but don't gate execution.

The escalation needs *stakes detection* as a separate feature — reversibility of actions, presence of "production"/"deploy"/"payment" keywords, file paths in protected directories. This is a feature the router uses to decide its *own confidence threshold*, not the architecture.

### Avoiding the SPOF problem

The router becomes SPOF if it's deterministic and silent. Two mitigations:

**Confidence thresholds with graceful fallback.** Router outputs a configuration *and* a confidence score. Below threshold, fall back to a known-good fixed architecture (probably monolith, since it's the most legible failure mode). The router never "tries hard" — when uncertain, it defers.

**Trace visibility.** Every routing decision is a span in the agent's trace, queryable post-hoc. When something fails, you can ask: was this routed to the right place? If routing was suspicious, that's where to look first. This is non-negotiable — a router without traceability is worse than no router.

**Periodic baseline runs.** Once a week, randomly route 5% of traffic to the always-monolith baseline regardless of what the router says. Compare aggregate outcomes. If the baseline starts winning, the router has degraded.

### The deeper failure mode

The router can be wrong in a way that *looks* like the architecture failed, when really the routing failed. Debugging this requires telling these apart, and that requires the *trace fidelity* Episode 1 surfaced as a load-bearing metric. If you can't see why the router picked what it picked, you can't fix it.

---

## 6. Cost of v0 — solo-founder time and money

I'll commit to a specific estimate, then note where I'm uncertain.

### Time estimate

Assuming a solo founder with prior experience in LLM agents, framework primitives, and basic ML:

- **Week 1: feature engineering and rule-based v0.** Define the feature set (top 5 from §1). Write feature extractors (regex + small LLM calls for ambiguous features). Hand-craft 6–10 routing rules. Wire to a frontend that exposes execution-unit / context-projection / budget / stop-policy as a struct. Plug into one framework (LangGraph or Claude Agent SDK).
- **Week 2: synthetic data generation.** Design synthetic task generator (probably a structured prompt over Claude Sonnet that produces tasks across the feature axes). Generate 5K tasks with strong-model-predicted architecture labels. Validate sample by hand.
- **Week 3: BERT classifier and integration.** Fine-tune DistilBERT or MiniLM on the synthetic data. Wire to the router as the fallback for ambiguous-rule cases. Integrate confidence threshold and frontier-LLM tertiary fallback.
- **Week 4: validation and iteration.** Hand-curate 100-task validation set. Run all-three-architecture comparison. Score, analyse, fix the worst routing failures by adjusting rules and retraining.

Total: 4 weeks of focused solo-founder time. Probably 1.5–2× that in calendar weeks for a part-time effort.

### Money estimate

- Synthetic data generation: ~$200 (5K Claude Sonnet calls at $0.04 average).
- Validation comparison: ~$150 (100 tasks × 3 architectures).
- BERT fine-tuning: free on Colab or ~$10 on a rented GPU.
- Ongoing inference: negligible at v0 scale (<$0.001 per routing decision).

Total: ~$400 in spend. Within hobby-project budget.

### Where I'm uncertain

The 4-week estimate assumes the framework integration is clean. If it isn't — if you discover that the framework's routing primitives don't actually compose the way you need (Episode 1's Cursor anecdote about LangGraph `Command` + `add_edge` interaction is a warning) — you can lose a week to plumbing. Realistic range: 4–8 weeks calendar.

The estimate also assumes no breakthroughs are needed. If the synthetic data turns out to be too noisy for the BERT classifier to converge (which I think is plausible — distillation-from-strong-model has known failure modes), Phase 2 collapses and you're stuck with the rule-based router. That's still a working v0, just a less ambitious one.

### When routing is *not* worth building

The honest counter to the "v0 is buildable" claim: routing is only worth building if your task distribution is heterogeneous. Three contraindications:

**Narrow task domain.** If your product is "answer customer support tickets" and 95% of tickets fit a narrow template, the best fixed architecture probably wins. Routing adds complexity for marginal gain.

**Strong base model improvements imminent.** If a frontier model release is expected to push monolithic performance up 10 points on your benchmark, that's the better investment than building a router that adds 5 points by routing around current monolith failures. Episode 1's evidence about reasoning-token models restoring monolithic performance is exactly this dynamic.

**Compound system improvements available.** If your system has 30%+ remaining gains from prompt engineering, RAG quality, tool descriptions, or basic eval-driven iteration, those are higher-leverage than routing. Routing is what you do *after* you've squeezed those.

The pattern: routing is worth building when you've exhausted single-architecture improvements and your task distribution is wide enough that no fixed point on the spectrum dominates. For most solo-founder products at v1, that's not yet true. By v2 or v3 it often is.

### The thing the brief asks indirectly

The Episode 2 question is really: *should a solo founder build a router, or wait?* The buildable-yes claim isn't the same as the build-it-now claim.

My read: build the *taxonomy* now, defer the classifier. Define the feature set and the configuration space. Hand-write rules. Ship a rule-based router. Use it as a measurement instrument that lets you see the spectrum in your own product's traces. *Then* — six months later, with real production data — decide whether to upgrade to a learned classifier. The premature optimisation is the classifier; the underrated-and-cheap move is the taxonomy plus rules plus instrumentation.

If Episode 2's claim ("v0 is buildable today") survives, the practical guidance is: yes, but the v0 is rules + instrumentation, not a model. The model is v1, after data accumulates. Episode 1's diagnosis — that the field has the primitives but lacks the taxonomy — implies the same shape: the missing layer is human design work, codified as rules, validated against data, only later replaced by a learned component.

---

## Closing flag on uncertainty

Two things I genuinely don't know and want to surface explicitly so the synthesiser doesn't over-trust this dump:

1. Whether the synthetic-data approach (distil routing decisions from a strong model) actually produces a usable training signal. I think it probably does for clear cases and probably doesn't for ambiguous cases — but I haven't seen a benchmark of LLMs as routing oracles, so this is intuition not evidence.

2. Whether the per-task routing gain (router > best-fixed-baseline) is large enough to justify the complexity in real production. Episode 1's evidence range (-70% to +80%) tells us the *potential* is there but not the *captureable fraction*. RouteLLM showed 85% cost reduction at 95% quality on the model-routing problem, which is a decent proxy but not the same problem.

Both uncertainties should resolve quickly with the validation experiment in §4. A 100-task A/B/router comparison answers both: if the router beats the best fixed baseline by >10% on weighted metric, the answer is clearly yes-build. If it ties or loses, the answer is wait-and-improve-fundamentals.
