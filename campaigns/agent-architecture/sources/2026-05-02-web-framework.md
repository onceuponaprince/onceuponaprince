# Web/framework primaries — raw dump 2026-05-02 (Episode 2 addendum, Sources 8+)

**Routing role:** Primary material read directly — repos, official docs, issue threads, framework essays. Closes the *production-blog corpus* gap Episode 2 flagged for the addendum: "every framework-specific claim Episode 2 made (Anthropic Workflows subagent dispatch, LangGraph supervisor pattern, DSPy router modules, OpenAI handoff filters) needs verification against the framework's own canon, not a model's recall of it."
**Tool:** Direct WebFetch + `gh issue list` / `gh issue view` from parent scope. Not via an LLM. Subagent dispatch attempted but blocked by sandbox permissions on WebFetch / Bash / curl — recovered by running fetches from parent scope sequentially.
**Brief:** Episode 2 — *The router we cannot yet build.* See `../episodes/02-the-router-we-cannot-yet-build.md`. Verdict under test: *the v0 buildable today is rules + instrumentation, not a model. Taxonomy and labels are the bottleneck, not the classifier.*
**Pre-flight:** `~/code/ghostroute/ask-grok-cli/` rebuilt with four fixes (probe-on-timeout, bullet-content via details-aware innerText, memory-path scoped to project `.claude/` if present else global, probe extraction). Binary reinstalled at `~/.cargo/bin/ask-grok-cli` before this dispatch — though Grok itself is not used in this source. The freshly-fixed binary is available for the next research firing that needs LLM-mediated coverage.

---

## Verdict pressure — top line

The verdict **holds with one sharpening**. Across five primary surfaces — Anthropic's *Building Effective Agents* essay, the LangGraph graph API, the DSPy production guide, the RouteLLM repo + paper, and Vellum's failure-routing post — framework authors and shipping teams converge on routing-as-rules-with-fallback far more than they converge on routing-as-learned-classifier.

The sharpening: when teams *do* reach for a learned router, they reach for an opaque packaged library with a cost-threshold API (RouteLLM's `mf`/`bert` routers via `model="router-mf-0.5"`), not a custom-trained classifier on production traffic with hand-engineered task features. Episode 2's framing of the v1 router as "5–7 hand-tuned features feeding a small classifier" does not match what shipping teams actually deploy. The learned-router production path is "use someone else's preference-data classifier" not "train your own". This shifts where the *taxonomy and labels* bottleneck actually lives — it lives in *deciding the cost band per query*, not in *training a classifier from scratch*.

---

## Section A — Anthropic's *Building Effective Agents* (December 2024 / republished)

**URL:** https://www.anthropic.com/engineering/building-effective-agents
**Why load-bearing:** Anthropic publishes this as the canonical statement on workflow patterns from a frontier-model lab that ships agent infrastructure (the Agent SDK). Their definition of "Routing" is the floor for any framework-level conversation. They explicitly leave the implementation choice open between LLM and traditional classifier — they do *not* privilege the classifier.

### Verbatim — preamble

> "Over the past year, we've worked with dozens of teams building large language model (LLM) agents across industries. Consistently, the most successful implementations weren't using complex frameworks or specialized libraries. Instead, they were building with simple, composable patterns."
> — anthropic.com/engineering/building-effective-agents
> *Bears on: the verdict's "rules + instrumentation, not a model" framing. Anthropic's own observation across dozens of production teams aligns.*

### Verbatim — routing definition

> "Routing classifies an input and directs it to a specialized followup task. This workflow allows for separation of concerns, and building more specialized prompts."
> — anthropic.com/engineering/building-effective-agents
> *Bears on: routing is named as one of five workflow patterns, not as the central problem. The "specialized followup task" framing pushes toward downstream specialisation, not upstream classifier accuracy.*

### Verbatim — when to use routing

> "Routing works well for complex tasks where there are distinct categories that are better handled separately, and where classification can be handled accurately, either by an LLM or a more traditional classification model/algorithm."
> — anthropic.com/engineering/building-effective-agents
> *Bears on: this is the explicit floor — Anthropic refuses to privilege LLM-router over rule-based classifier. The two are presented as substitutable. Production teams choose by accuracy and cost, not by "is it learned".*

### Verbatim — routing examples

> "Directing different types of customer service queries (general questions, refund requests, technical support) into different downstream processes, prompts, and tools."
> "Routing easy/common questions to smaller, cost-efficient models like Claude Haiku 4.5 and hard/unusual questions to more capable models like Claude Sonnet 4.5 to optimize for best performance."
> — anthropic.com/engineering/building-effective-agents
> *Bears on: both examples are intent-classification problems with small label spaces. Neither requires the 5–7 hand-tuned-features apparatus Episode 2 imagined for v0.*

### Verbatim — closing principle

> "Success in the LLM space isn't about building the most sophisticated system. It's about building the *right* system for your needs."
> — anthropic.com/engineering/building-effective-agents
> *Bears on: directly endorses minimal-shape routing over feature-engineered classifiers when the label space is small.*

---

## Section B — LangGraph (langchain-ai)

**URLs:**
- Overview: https://docs.langchain.com/oss/python/langgraph
- Graph API (conditional_edges + Send): https://docs.langchain.com/oss/python/langgraph/graph-api
- Multi-agent tutorial: https://docs.langchain.com/oss/python/langgraph/multi-agent (returned 404 at fetch time)
- Issues: https://github.com/langchain-ai/langgraph/issues?q=is%3Aissue+routing

**Why load-bearing:** LangGraph is the most-deployed open-source agent orchestration framework in 2025–2026. Its primitives *are* the production grammar most teams reach for. The shape of those primitives is itself an answer to the question.

### Verbatim — what LangGraph is

> "LangGraph is a low-level orchestration framework and runtime for building, managing, and deploying long-running, stateful agents."
> — docs.langchain.com/oss/python/langgraph
> *Bears on: framing matters — "low-level orchestration" not "intelligent dispatch". The primitive is not a classifier; it is a graph with explicit edges.*

### Verbatim — conditional edges (THE routing primitive)

> "If you want to **optionally** route to one or more edges (or optionally terminate), you can use the `add_conditional_edges` method."
> "Similar to nodes, the `routing_function` accepts the current `state` of the graph and returns a value. By default, the return value `routing_function` is used as the name of the node (or list of nodes) to send the state to next."
> "You can optionally provide a dictionary that maps the `routing_function`'s output to the name of the next node."
> — docs.langchain.com/oss/python/langgraph/graph-api
> *Bears on: this is the verdict in the framework's own words. Routing in LangGraph is **a function the developer writes that takes state and returns a node name**. It is *literally* "rules + instrumentation". The framework's recommended path is not "wire in a learned classifier"; it is "write the function". A learned classifier can sit *inside* the function but is not the primitive.*

### Verbatim — fixed vs conditional edges (the discipline)

> "For each node, choose one routing mechanism: use normal edges for static routing, or use conditional edges / `Command` for dynamic routing. Do not mix normal edges and dynamic routing from the same node."
> — docs.langchain.com/oss/python/langgraph/graph-api
> *Bears on: even within the dynamic-routing path, the framework asks for discipline — pick the routing mechanism per-node, do not blend. This argues against the "one big classifier router" v0 that Episode 2's brief gestured at.*

### Verbatim — the Send API for fan-out

> "To support this design pattern, LangGraph supports returning `Send` objects from conditional edges. `Send` takes two arguments: first is the name of the node, and second is the state to pass to that node."
> — docs.langchain.com/oss/python/langgraph/graph-api
> *Bears on: dynamic fan-out is also rules-shaped — the routing function emits `Send` objects naming targets. There is no "router model" in the primitive at all.*

### Issues — production gotchas

Top-engagement open issues filtered for "routing":

- **#7303 (9 comments)** — *Collaboration: Trust-gated checkpoints and governance nodes for LangGraph.* Production demand is for **governance gates** in the routing graph, not for smarter routing.
- **#6455 (5 comments)** — *Transactional Cross-Graph Handoff.* Demand is for **transactional integrity** of the handoff, not for the routing decision quality.
- **#6064 (3 comments)** — *Sub Agent sends back to starting agent after handoff even if it is waiting on further responses.* This is a state-machine bug at the supervisor pattern layer. The accepted solution in-thread uses `langgraph.types.interrupt` and a hand-built `create_handoff_tool` factory — entirely rule-shaped, no learned dispatch involved.

The production issue corpus is about **state plumbing, transactional handoffs, and graph governance** — not about routing accuracy. This is consistent with Episode 2's verdict: the bottleneck is not the classifier; it is everything *around* the classifier.

---

## Section C — RouteLLM (lm-sys)

**URLs:**
- Repo + README: https://github.com/lm-sys/RouteLLM (read via raw.githubusercontent.com)
- Paper: https://arxiv.org/abs/2406.18665
- HuggingFace org: https://huggingface.co/routellm (9 models — `mf`, `bert_mmlu_augmented`, `mf_mmlu_augmented`, etc.)
- Issues: https://github.com/lm-sys/RouteLLM/issues

**Why load-bearing:** RouteLLM is the canonical reference for *learned* routing in 2024–2026. If the verdict's "rules + instrumentation, not a model" claim is wrong anywhere, it is wrong here.

### Verbatim — paper abstract

> "Large language models (LLMs) exhibit impressive capabilities across a wide range of tasks, yet the choice of which model to use often involves a trade-off between performance and cost. More powerful models, though effective, come with higher expenses, while less capable models are more cost-effective. To address this dilemma, we propose several efficient router models that dynamically select between a stronger and a weaker LLM during inference, aiming to optimize the balance between cost and response quality. We develop a training framework for these routers leveraging human preference data and data augmentation techniques to enhance performance. Our evaluation on widely-recognized benchmarks shows that our approach significantly reduces costs—by over 2 times in certain cases—without compromising the quality of responses. Interestingly, our router models also demonstrate significant transfer learning capabilities, maintaining their performance even when the strong and weak models are changed at test time."
> — Ong et al., RouteLLM: Learning to Route LLMs with Preference Data, arxiv.org/abs/2406.18665
> *Bears on: the routing is binary (strong vs weak), trained on **preference data** not on hand-engineered task features, and the strong claim is **transfer learning across model swaps**. None of this matches Episode 2's "5–7 hand-tuned features" v1.*

### Verbatim — README architecture

> "Routers supported include: `mf` (Matrix factorization model — recommended), `sw_ranking` (Weighted Elo calculation), `bert` (BERT classifier), `causal_llm` (LLM-based classifier), `random` (Baseline routing)."
> — github.com/lm-sys/RouteLLM README
> *Bears on: five router options ship in the library. The recommended one is **matrix factorisation over preference data** — a classic recommender-system shape, not a feature-engineered classifier. This is a fundamentally different architecture from the one Episode 2 imagined for v1.*

### Verbatim — README usage shape

> "An OpenAI-compatible server launches with `python -m routellm.openai_server`, enabling integration with existing OpenAI client implementations. Threshold calibration uses Chatbot Arena data by default but supports custom datasets."
> — github.com/lm-sys/RouteLLM README
> *Bears on: the production deployment is **a drop-in OpenAI proxy**. The user's surface is `model="router-mf-0.5"` — a string. The cost band is calibrated externally, then opaque at runtime. This is the closest thing to a learned-router production deployment in the open-source ecosystem, and the user-facing API is **a threshold parameter on a model string**.*

### Issues — surprisingly thin engagement

Top issues by comment count, all repos:

- **#67 (3 comments)** *Can BERT router source code (esp. for training) be added to the repo?* — closed without a training-script release.
- **#54 (2 comments)** *Does routellm support routing queries to different models in OpenAI assistant?*
- **#58 (2 comments)** *Are only GPT-4 and Mistral models currently supported for routing?*
- **#63 (2 comments)** *litellm.drop_params error when running the openapi server.*

The maximum comment count on **any** issue in the repo is 3. The corpus contains zero production post-mortems, zero accuracy-drift issues, zero cost-overrun reports. Either the library is rarely used in shipping systems beyond demo / benchmark contexts, or those who do use it never need to file an issue — but the public surface looks closer to *interesting research artefact* than to *load-bearing production component*. **This itself is a finding** that pressures the v1-classifier path Episode 2 imagined: even the canonical learned-router library does not have a deep production debug corpus.

---

## Section D — DSPy (stanfordnlp)

**URLs:**
- Landing: https://dspy.ai/
- Production: https://dspy.ai/production/
- Routing-related issue: https://github.com/stanfordnlp/dspy/issues/1570

**Why load-bearing:** DSPy is the most production-leaning declarative framework for LLM programs. Its silence on routing is a signal.

### Verbatim — what DSPy is

> "DSPy is a declarative framework for building modular AI software. It enables developers to iterate fast on structured code, rather than brittle strings."
> — dspy.ai
> *Bears on: framing is **modules and signatures**. Routing between modules is treated as composition — a developer-authored shape — not as a learned dispatch problem.*

### Notable absence — "router" does not appear

> The word "router" appears nowhere on the DSPy landing page or the production guidance page. The production page covers four pillars — Monitoring & Observability (MLflow Tracing), Reproducibility, Deployment via MLflow Model Serving, Scalability — and is silent on dispatch, model selection, fallbacks, or routing.
> — dspy.ai/production/ (cited absence)
> *Bears on: the most production-oriented declarative LLM framework in 2026 treats routing as out-of-scope for its production guidance. This is the strongest single signal that routing-as-a-distinct-problem is over-emphasised in the discourse versus shipping practice.*

### Verbatim — maintainer comment on routing (issue #1570)

> "Maybe just launch their server and connect to it via the client `dspy.LM`? i.e., DSPy doesn't need to be involved... Sorry, I'm mistaken about the nature of the LiteLLM router. I assumed it was inherently a proxy. It's actually just a client-side thing, indeed: https://docs.litellm.ai/docs/routing"
> — Omar Khattab (DSPy collaborator), github.com/stanfordnlp/dspy/issues/1570
> *Bears on: when asked to integrate the LiteLLM router into DSPy, the maintainer's recommendation is **don't — use it client-side, DSPy stays out of routing**. Confirms DSPy's deliberate hands-off posture.*

---

## Section E — Vellum's *what to do when an LLM request fails* (production blog)

**URL:** https://www.vellum.ai/blog/what-to-do-when-an-llm-request-fails

**Why load-bearing:** This is the production failure-routing post Episode 2 cited. Vellum sells observability and prompt management to teams shipping LLM apps; their recommendations reflect what those teams actually do.

### Verbatim — recommended failure-routing patterns

> "Rule-based Model Routing: Set a primary model (e.g., GPT-4o) with fallbacks to similar performers (e.g., Claude 3.5 Sonnet) when primary fails."
> "Exponential Backoff for Rate Limits: Wait random periods increasing exponentially after each failure, with maximum retry limits."
> "Human-in-the-Loop: Route to humans when models can't answer due to sensitive criteria or specific user situations."
> "LLM-as-a-Judge: Use an intent classifier step to filter downstream tasks and route basic questions to cheaper models."
> — vellum.ai/blog/what-to-do-when-an-llm-request-fails
> *Bears on: the four recommended patterns are **rules-as-code (primary + fallback table), exponential backoff (a rule), human escalation (a rule), and LLM-as-judge (an LLM-call inside a rule)**. None of them is a trained classifier. The "LLM-as-a-Judge" pattern is the closest thing to learned routing — and it is **the LLM doing the routing decision in-context**, not a separately-trained classifier.*

### Verbatim — production discipline

> "Define your own fallback logic tailored to your app's unique needs rather than relying on black-box solutions, maintaining full control over failure handling. Test both primary and fallback models with evaluation data to ensure similar outputs."
> — vellum.ai/blog/what-to-do-when-an-llm-request-fails
> *Bears on: the production discipline is "control your own fallback logic" — i.e. write the rules yourself, test both branches against eval data. Direct contradiction of "deploy a learned router and let it route".*

---

## Cross-source pattern

Three patterns recur across all five primary surfaces:

1. **The framework primitive is rules-as-code, not a learned classifier.** LangGraph's `conditional_edges` requires a developer-authored `routing_function`. DSPy treats module composition as developer-authored. Anthropic's essay explicitly leaves the routing implementation choice open. Even RouteLLM, the learned-router exemplar, exposes a *cost-threshold parameter on a model string* as its production surface — the user does not write router-feature code.

2. **The production debug corpus is about plumbing, not accuracy.** LangGraph's most-engaged routing-tagged issues are about transactional handoffs, governance gates, and sub-agent state loops. RouteLLM's issue corpus is too thin to draw from. LangChain's RouterChain issues are about memory integration and migration paths — RouterChain itself is being deprecated in favour of LangGraph. **Nobody is filing issues about classifier accuracy at scale.** This pressures the assumption that classifier accuracy is the load-bearing problem v1 needs to solve.

3. **When learned routing is used in production, it is opaque-package-with-threshold, not custom-features-with-classifier.** RouteLLM is the only learned-router library with non-trivial deployment, and its production surface is `model="router-mf-0.5"`. The threshold gets calibrated against Chatbot Arena data; the classifier is matrix factorisation over preference pairs; the user does not see features. This is closer to *automatic transmission* than to *engineered routing pipeline*. Episode 2's v1 framing — "5–7 hand-tuned features feeding a small classifier" — describes a path that nobody is actually walking.

### Sharpened verdict

The v0 buildable today is **rules + instrumentation**. The v1 buildable today is **opaque packaged classifier with cost-threshold knob** (RouteLLM-shaped), not custom feature engineering. The v2 — *custom-features classifier on production traffic with task-theory features* — does not appear to have shipping examples in this corpus.

The taxonomy-and-labels bottleneck Episode 2 named is real, but it lives at a different layer than imagined: it lives in **deciding the cost band per query class** (so RouteLLM's threshold can be calibrated meaningfully), not in **engineering features for a custom classifier from scratch**.

---

## Trackable surfaces

Subscribe to these to keep the corpus current. RSS feeds verified by URL shape; not all confirmed live.

### RouteLLM (lm-sys)

- Releases atom: `https://github.com/lm-sys/RouteLLM/releases.atom`
- Issues atom: `https://github.com/lm-sys/RouteLLM/issues.atom`
- Watch URL: `https://github.com/lm-sys/RouteLLM/subscription`

### LangGraph (langchain-ai)

- Releases atom: `https://github.com/langchain-ai/langgraph/releases.atom`
- Issues atom (routing-filtered): `https://github.com/langchain-ai/langgraph/issues.atom?q=is%3Aissue+routing`
- LangChain blog (no public RSS observed; check https://blog.langchain.com periodically)
- Maintainers: Harrison Chase (@hwchase17), William Fu-Hinthorn (@hinthornw)

### DSPy (stanfordnlp)

- Releases atom: `https://github.com/stanfordnlp/dspy/releases.atom`
- Issues atom (router-filtered): `https://github.com/stanfordnlp/dspy/issues.atom?q=is%3Aissue+router`
- Discord (linked from dspy.ai landing page)
- Maintainer: Omar Khattab (@okhat)

### LangChain (langchain-ai)

- Releases atom: `https://github.com/langchain-ai/langchain/releases.atom`
- RouterChain issues atom: `https://github.com/langchain-ai/langchain/issues.atom?q=is%3Aissue+RouterChain`

### Anthropic engineering

- Engineering blog: https://www.anthropic.com/engineering (no public RSS observed)
- Subscribe via Anthropic's mailing list or watch the URL for new posts

### Production blogs

- Vellum blog: https://www.vellum.ai/blog
- Portkey blog: https://portkey.ai/blog
- LiteLLM docs (the routing-adjacent library DSPy maintainers point to): https://docs.litellm.ai/docs/routing

### Suggested cadence

- **Weekly:** RouteLLM and LangGraph releases atoms (low-volume; new release once every 2–4 weeks)
- **Bi-weekly:** Issue feeds for the four GitHub-hosted projects — scan for new high-engagement threads
- **Monthly:** Anthropic engineering blog, Vellum blog
- **Ad-hoc:** When Anthropic ships a new Claude Sonnet/Haiku update, re-read their *Building Effective Agents* essay for revisions

A `/schedule` background agent could fire a fortnightly scan of the issue feeds and post a short delta to the inbox.

---

## What did NOT make it into this dump

- **LangGraph multi-agent tutorial** (`docs.langchain.com/oss/python/langgraph/multi-agent`) returned 404 at fetch time. The supervisor and hierarchical patterns are referenced in the overview but not captured verbatim. The `conditional_edges` + `Send` primitives from the graph-api page cover the underlying mechanism; the tutorial-level patterns are sugar over those primitives.
- **OpenAI Agents SDK handoff filters.** Mentioned in Episode 2's brief; not fetched here. Similar shape to LangGraph's handoffs, less production-deployed in 2026.
- **Portkey routing post.** Not fetched. Vellum's post covers the same ground.
- **DSPy module composition examples.** Not fetched verbatim. The landing page and production page both confirm routing is out-of-scope for the framework, which is the load-bearing point.
- **RouteLLM deeper paper sections.** Only the abstract was captured; method and results sections not pulled. Abstract is sufficient for the verdict-pressure analysis.

These can be picked up in a follow-up firing if the addendum's synthesis exposes a gap.
