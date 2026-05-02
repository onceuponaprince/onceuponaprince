# When the addendum sharpens the call instead of softening it

*Episode 2 of the agent-architecture campaign committed on five-of-seven sources because two browser-based research CLIs failed on Chromium launch. The addendum recovers Perplexity, fails to recover Grok, and tightens the verdict in one specific direction the original synthesis hadn't seen.*

## What the original verdict said

Episode 2 — *The router we cannot yet build* — asked a single question: could a solo founder build a working task-feature classifier today, and if so, what does the v0 cost? Five of seven sources answered. Their convergence was sharp: yes, a v0 is buildable; no, the v0 is not a classifier. The v0 that pays off first is **rules plus instrumentation**. 5–7 hand-engineered features inferable from the task statement, hand-tuned scoring rules, a frontier-LLM fallback for ambiguous cases, and trace fidelity end-to-end. The classifier is the wrong v0. The premature optimisation is the model. The under-discussed primitive is the taxonomy.

The two missing sources covered different gaps. Perplexity is the production-blog corpus — what teams shipped, what broke, what they migrated away from. Grok is the contrarian X discourse — *"we removed the router"*, *"the router was the wrong primitive"*, the loud minority opinions that go against the academic literature's direction of travel. Both gaps were declared explicitly in the original synthesis. The addendum was scheduled the moment the environment was unblocked.

## What the addendum recovered

Perplexity ran cleanly under `xvfb-run` after killing a stale `zsh` background loop that had been holding the chromiumoxide runner from a parallel job in another session. The earlier handover note's diagnosis — *Chromium handshake broken, BrowserConfig flags incomplete* — was half right. The display half was true on the prior session; on this run, xvfb plus a clean runner directory was sufficient. No patch to `~/code/ghostroute/ask-perplexity-cli/` was required.

Grok recovered five days later, after eight composing fixes in `~/code/ghostroute/ask-grok-cli/`. The full debugging arc is its own essay — `artifacts/02a-systems-and-tools/04-debugging-grok-cli-essay.md` — but the headline is that the failure had eight layers, each masking the next: a Unicode keymap in chromiumoxide, an obsolete input selector, missing chromium hardening flags, polluted memory state, single-cookie loading where SSO needed multi, a `keydown`-less paste that left React's controlled-input state stale, a response selector that matched the user bubble before the assistant's reply existed, and bullet content silently dropped because `innerText` skips closed `<details>`. The Grok dump landed at `sources/2026-04-27-grok.md`. Four further fixes today (probe-on-timeout, details-aware innerText, project-scoped memory path, probe extraction) brought the CLI to a state durable enough to fire next time without preceding it with a four-hour debugging session.

## How Perplexity sharpened the call

The Perplexity dump did three things to Episode 2's verdict, none of which was a contradiction.

**It put a number on the under-100–300-queries-per-day threshold.** Episode 2 named *"narrow task domain"* as the contraindication for routing. Perplexity names the threshold directly: *"Below ~100–300 high-quality LLM queries per day, the overhead of maintaining a router usually outweighs the cost savings."* Solo founders sitting under that bar should not be building a router; the marginal effort is better spent on better base prompts, better tool descriptions, or simply a stronger fixed model. The threshold is empirical, drawn from production deployments, and it lands above where most pre-launch products live.

**It foregrounded the routing-collapse failure mode as the canonical risk.** The *"When Routing Collapses"* paper (arXiv 2602.03478v1) — surfaced first by Cursor, but underplayed in the original synthesis as one failure among many — gets centre stage in Perplexity's reading. The mechanism is **objective-decision mismatch**: learned routers are trained to predict scalar scores, but the act of routing is an argmax over those scores. Small prediction errors flip relative model rankings. As cost budgets rise, the router systematically defaults to the strongest model, completely undermining the cost-savings promise that justified building it in the first place.

**It made Episode 2's recommended fallback policy slightly worse than Episode 2 admitted.** The original synthesis said *low confidence → cheaper architecture*. That fallback, applied to a router that is already drifting under cost pressure, *accelerates* routing collapse — it ratchets traffic toward the strong model on every uncertain call. Interactive 2, which Episode 2's commitments paragraph promised to ship into `pilot.html`, takes the opposite line: low confidence falls back to **monolith**, not to the more expensive route. The router never tries hard; when uncertain, it defers to the cheapest baseline. That single inversion is the load-bearing change the addendum makes, and it is in the demo code.

## How the web-framework primaries sharpened it further

A third coverage gap surfaced after the Perplexity recovery: every framework-specific claim Episode 2 made — Anthropic Workflows subagent dispatch, LangGraph supervisor pattern, DSPy router modules, OpenAI handoff filters — had been quoted via LLM recall, not against the framework's own canon. Sources 8+ (`sources/2026-05-02-web-framework.md`) closed that gap with primary material read directly via WebFetch + `gh`: the RouteLLM repo and paper, the LangGraph graph API, the DSPy production guide, Anthropic's *Building Effective Agents* essay, and Vellum's failure-routing post.

The verdict survived intact at the framework primitive level. LangGraph's `add_conditional_edges` is, in the docs' own words, *"a function the developer writes that takes state and returns a node name"* — literally rules-as-code, with a learned classifier permitted *inside* the function but never as the primitive. DSPy treats routing as out-of-scope for production guidance entirely; the maintainer's stated position when asked to integrate the LiteLLM router is *"DSPy doesn't need to be involved"*. Anthropic's essay defines routing as workable *"either by an LLM or a more traditional classification model/algorithm"* — explicitly refusing to privilege the classifier.

The sharpening: when teams *do* reach for learned routing in production, they reach for **opaque-packaged-classifier-with-threshold** (RouteLLM-shaped: `model="router-mf-0.5"`), not custom-features-classifier on production traffic. Episode 2's *"5–7 hand-tuned features feeding a small classifier"* framing of v1 has no shipping examples in the corpus. The taxonomy-and-labels bottleneck lives at a different layer than imagined — in **cost-band calibration per query class**, not in feature engineering for a custom classifier. RouteLLM's own GitHub issues corpus is surprisingly thin (top engagement: three comments), which itself pressures any framing that treats the v1 classifier as load-bearing.

## What Grok added when it came back

The recovered Grok dump did not contradict the production-blog corpus — it triangulated against it. Grok's pass through 2026 X discourse surfaced the *survivors / ripped out* split that academic literature smooths over: hybrid patterns (small classifier → confidence threshold → LLM judge fallback) win when shipped, with DSPy commonly used to optimise the whole pipeline despite acknowledged bloat. The contrarian read on RouteLLM-style learned routers — *"hybrids win, pure-classifier rollouts get yanked at 5–10% bad-routing rates"* — held up, and the sharpening it delivered was the **0.7–0.9 confidence threshold range** that production teams converge on before falling back to a strong model or a human. Grok also flagged MasRouter's reproduction gap (academic strong claims, sparse independent reproductions in the wild) — consistent with the web-framework primaries' finding.

Source coverage closed at **seven-of-seven plus Sources 8+**. The contrarian-X gap the original draft of this newsletter named as un-closed is closed.

## The Episode 3 trigger decision

Episode 3's candidate question is *should BorAI build a v0 router right now?* The addendum's commitments paragraph commits to **queued, not now**. Two reasons.

First, Perplexity's 100–300 queries/day threshold lands above BorAI's current traffic. The pre-launch volume does not yet justify the maintenance overhead of a router, even a rule-based one. Below the threshold, the rules-plus-instrumentation that Episode 2 already recommends is sufficient — the router *is* the rules, the instrumentation is the trace fidelity, and there is nothing else to add until production traffic accumulates.

Second, the routing-collapse mechanism argues against deploying a *learned* router before rules-and-instrumentation have generated production logs. The training data for a router that doesn't drift is the production logs the rules-based version produces. Deploying a learned router before that data exists invites the exact failure mode the addendum just sharpened. The order matters: rules first, logs from rules, classifier from logs. Skipping a step makes the failure mode worse, not better.

No ADR opens from the addendum. The first ADR in `decisions/` lands when Episode 3's synthesis commits — most likely as a concrete spec for BorAI's feature taxonomy, the 100-task validation set, and the fallback policy. Until then, Episode 2's verdict stands as the campaign's working call: *the router we cannot yet build is the model; the router we can build today is rules and instrumentation, and that is enough for the traffic levels solo founders actually have.*

## What shipped

- **Episode 2 addendum** appended to `episodes/02-the-router-we-cannot-yet-build.md` as a delta. Original synthesis is not retro-edited.
- **Interactive 2 — Router-in-a-box** shipped into `pilot.html`. Six features, hand-tuned rule, exposed confidence threshold, visible fallback. No learned model. The argument the interactive makes is the argument the synthesis makes.
- **Sources.** `2026-04-27-perplexity.md` recovered the production-blog corpus. `2026-04-27-grok.md` recovered the contrarian X-discourse read after eight upstream fixes. `2026-05-02-web-framework.md` added Sources 8+ — primary material from RouteLLM, LangGraph, DSPy, Anthropic, Vellum, read directly via WebFetch + `gh`.
- **Upstream tooling.** `ask-grok-cli` is now durable enough to fire on demand. Eight layered fixes through commit `5ef8045`; four further fixes today (response-state probe on timeout, bullet-content via details-aware innerText, project-scoped memory path with global fallback, probe extraction). Documented in `artifacts/02a-systems-and-tools/04-debugging-grok-cli-essay.md`.
- **Campaign metadata** updated. Episode 2's verdict line on `campaign.md` reads *sharpened*. Interactive 2 status reads *shipped*. The Episode 3 candidate question reads *queued*.

The thing the addendum got out of the system was a slightly worse fallback policy and a sharper v1 framing. The thing it left in was the verdict it tested. Source coverage closed: seven-of-seven plus the web-framework primaries that gave Episode 2's framework-specific claims their own canonical floor.
