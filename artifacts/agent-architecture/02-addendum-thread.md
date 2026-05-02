1/ Agent-architecture campaign, Episode 2 addendum.

The original synthesis stood on five-of-seven sources because two browser-based research CLIs failed on Chromium launch. We re-fired both. Perplexity recovered. Grok stayed broken — but at a different layer than the first session diagnosed.

2/ Recovered source: Perplexity, current-practice 2024–2026, RouteLLM-style production deployments.

It did not weaken Episode 2's verdict. It sharpened it. The verdict — *the v0 buildable today is rules + instrumentation, not a model* — survived the production-blog corpus intact. Three things changed.

3/ Threshold becomes a number.

Episode 2 hand-waved at *"narrow task domain"* as the contraindication for routing. Perplexity names it: <100–300 high-quality LLM queries per day, the overhead of a router exceeds the savings. Solo founders below that bar should not build one.

4/ The canonical failure mode is *routing collapse*, not the SPOF.

"When Routing Collapses" (arXiv 2602.03478v1): learned routers default to the strongest model as cost budgets rise. Cause: predicting a scalar score versus making an argmax decision. The naive *low-confidence → cheaper architecture* fallback Episode 2 recommended makes this *worse*, by ratcheting traffic toward the strong model.

5/ Interactive 2 ships with the inverse rule.

Below confidence threshold, the router falls back to **monolith**, not to the more expensive route. Stakes and reversibility lift the threshold; they do not flip the fallback target. Cursor's load-bearing line still stands: *"You can't benchmark your way out of the data problem."*

6/ Grok recovered five days later, after eight composing fixes — plus four more this week.

`~/code/ghostroute/ask-grok-cli/` shipped through eight layered bugs (Unicode keymap, stale input selector, missing chromium hardening, polluted memory, single-cookie SSO break, paste without keydown, prompt-echo capture, bullet-content drop) plus four further today (probe-on-timeout, details-aware innerText, project-scoped memory, probe extraction). Grok dump is on file. Full essay: `artifacts/02a-systems-and-tools/04-debugging-grok-cli-essay`.

7/ Web-framework primaries (Sources 8+) sharpened the v1 framing.

Five sources read directly — RouteLLM repo + paper, LangGraph graph API, DSPy production guide, Anthropic's *Building Effective Agents* essay, Vellum's failure-routing post — not via an LLM. Verdict held at the primitive level: LangGraph's `conditional_edges` *is* rules-as-code in the framework's own grammar. The sharpening: when teams reach for learned routing they reach for **opaque-packaged-classifier-with-threshold** (RouteLLM-shaped: `model="router-mf-0.5"`), not custom-features. Episode 2's hand-tuned-features-feeding-a-small-classifier v1 framing has no shipping examples.

8/ Episode 3 trigger: queued, not now.

The candidate question — *should BorAI build a v0 router right now?* — moves to **queued**. BorAI's traffic sits below Perplexity's 100–300/day threshold, and routing collapse argues against deploying a learned router before rules-and-instrumentation have generated logs to validate against. No ADR opens from the addendum alone. First ADR lands when Episode 3 commits.

[essay →]
