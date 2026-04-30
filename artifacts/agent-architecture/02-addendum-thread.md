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

6/ Grok stayed blocked — for a different reason than first diagnosed.

Original session: chromiumoxide handshake fails. False. Chromium launches cleanly under xvfb. The hang is *after* `[Timing] Input located`, in the synthetic-paste / response-watch loop. Grok's web UI shifted between Episode 1 (working) and Episode 2 (failing). Fix is upstream in `~/code/ghostroute/ask-grok-cli/`, not in the vault.

7/ Episode 3 trigger: queued, not now.

The candidate question — *should BorAI build a v0 router right now?* — moves to **queued**. BorAI's traffic sits below Perplexity's 100–300/day threshold, and routing collapse argues against deploying a learned router before rules-and-instrumentation have generated logs to validate against. No ADR opens from the addendum alone. First ADR lands when Episode 3 commits.

[essay →]
