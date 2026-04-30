# When the addendum sharpens the call instead of softening it

*Episode 2 of the agent-architecture campaign committed on five-of-seven sources because two browser-based research CLIs failed on Chromium launch. The addendum recovers Perplexity, fails to recover Grok, and tightens the verdict in one specific direction the original synthesis hadn't seen.*

## What the original verdict said

Episode 2 — *The router we cannot yet build* — asked a single question: could a solo founder build a working task-feature classifier today, and if so, what does the v0 cost? Five of seven sources answered. Their convergence was sharp: yes, a v0 is buildable; no, the v0 is not a classifier. The v0 that pays off first is **rules plus instrumentation**. 5–7 hand-engineered features inferable from the task statement, hand-tuned scoring rules, a frontier-LLM fallback for ambiguous cases, and trace fidelity end-to-end. The classifier is the wrong v0. The premature optimisation is the model. The under-discussed primitive is the taxonomy.

The two missing sources covered different gaps. Perplexity is the production-blog corpus — what teams shipped, what broke, what they migrated away from. Grok is the contrarian X discourse — *"we removed the router"*, *"the router was the wrong primitive"*, the loud minority opinions that go against the academic literature's direction of travel. Both gaps were declared explicitly in the original synthesis. The addendum was scheduled the moment the environment was unblocked.

## What the addendum recovered

Perplexity ran cleanly under `xvfb-run` after killing a stale `zsh` background loop that had been holding the chromiumoxide runner from a parallel job in another session. The earlier handover note's diagnosis — *Chromium handshake broken, BrowserConfig flags incomplete* — was half right. The display half was true on the prior session; on this run, xvfb plus a clean runner directory was sufficient. No patch to `~/code/ghostroute/ask-perplexity-cli/` was required.

Grok, in contrast, stayed broken — but the failure mode this addendum diagnosed is **not** the failure mode the prior session reported. Two re-fires (one with `headless=true`, one with `headless=false`) reached `[Timing] Input located` reliably. Both then hung silently for 30+ minutes with no further log output, no stderr, and no exit. The hang is *after* the input field is located, somewhere in the synthetic-paste or response-watch path of the CLI's automation module. Grok's web UI has shifted between Episode 1 (working) and Episode 2 (failing) — most likely the response-container selector or the input-field DOM hierarchy. The fix is upstream in `~/code/ghostroute/ask-grok-cli/src/automation/` and `src/config/mod.rs`. Out of scope for the campaign. Escalated.

## How Perplexity sharpened the call

The Perplexity dump did three things to Episode 2's verdict, none of which was a contradiction.

**It put a number on the under-100–300-queries-per-day threshold.** Episode 2 named *"narrow task domain"* as the contraindication for routing. Perplexity names the threshold directly: *"Below ~100–300 high-quality LLM queries per day, the overhead of maintaining a router usually outweighs the cost savings."* Solo founders sitting under that bar should not be building a router; the marginal effort is better spent on better base prompts, better tool descriptions, or simply a stronger fixed model. The threshold is empirical, drawn from production deployments, and it lands above where most pre-launch products live.

**It foregrounded the routing-collapse failure mode as the canonical risk.** The *"When Routing Collapses"* paper (arXiv 2602.03478v1) — surfaced first by Cursor, but underplayed in the original synthesis as one failure among many — gets centre stage in Perplexity's reading. The mechanism is **objective-decision mismatch**: learned routers are trained to predict scalar scores, but the act of routing is an argmax over those scores. Small prediction errors flip relative model rankings. As cost budgets rise, the router systematically defaults to the strongest model, completely undermining the cost-savings promise that justified building it in the first place.

**It made Episode 2's recommended fallback policy slightly worse than Episode 2 admitted.** The original synthesis said *low confidence → cheaper architecture*. That fallback, applied to a router that is already drifting under cost pressure, *accelerates* routing collapse — it ratchets traffic toward the strong model on every uncertain call. Interactive 2, which Episode 2's commitments paragraph promised to ship into `pilot.html`, takes the opposite line: low confidence falls back to **monolith**, not to the more expensive route. The router never tries hard; when uncertain, it defers to the cheapest baseline. That single inversion is the load-bearing change the addendum makes, and it is in the demo code.

## What Grok would have changed, and what the campaign loses for not having it

Cursor's coverage of Reddit, GitHub, and arXiv from the original round partially fills the contrarian gap — `r/LLMDevs/1nsi2g7`, the LangGraphJS #779 silent-failure thread, RouteLLM's LiteLLM regression #25629, the OpenAI Agents SDK handoff bugs (#2216, #617, #771). Those are the production failure surface, named with citations. What is missing is X-native voices: 2026 threads from solo founders who shipped a router, lost six months to debugging it, and removed it. Anti-DSPy takes from the routing-specific angle. *"Just pick a good base model"* posts that explicitly weigh routing against the alternative.

Without those, the verdict is **confirmed and sharpened by the production corpus, but not stress-tested against the 2026 contrarian discourse.** The campaign documents the gap in the addendum's *Source-coverage status* table; the sources table now reads six-of-seven, with Grok flagged as *escalated to user — fix is upstream in ghostroute*.

## The Episode 3 trigger decision

Episode 3's candidate question is *should BorAI build a v0 router right now?* The addendum's commitments paragraph commits to **queued, not now**. Two reasons.

First, Perplexity's 100–300 queries/day threshold lands above BorAI's current traffic. The pre-launch volume does not yet justify the maintenance overhead of a router, even a rule-based one. Below the threshold, the rules-plus-instrumentation that Episode 2 already recommends is sufficient — the router *is* the rules, the instrumentation is the trace fidelity, and there is nothing else to add until production traffic accumulates.

Second, the routing-collapse mechanism argues against deploying a *learned* router before rules-and-instrumentation have generated production logs. The training data for a router that doesn't drift is the production logs the rules-based version produces. Deploying a learned router before that data exists invites the exact failure mode the addendum just sharpened. The order matters: rules first, logs from rules, classifier from logs. Skipping a step makes the failure mode worse, not better.

No ADR opens from the addendum. The first ADR in `decisions/` lands when Episode 3's synthesis commits — most likely as a concrete spec for BorAI's feature taxonomy, the 100-task validation set, and the fallback policy. Until then, Episode 2's verdict stands as the campaign's working call: *the router we cannot yet build is the model; the router we can build today is rules and instrumentation, and that is enough for the traffic levels solo founders actually have.*

## What shipped

- **Episode 2 addendum** appended to `episodes/02-the-router-we-cannot-yet-build.md` as a delta. Original synthesis is not retro-edited.
- **Interactive 2 — Router-in-a-box** shipped into `pilot.html`. Six features, hand-tuned rule, exposed confidence threshold, visible fallback. No learned model. The argument the interactive makes is the argument the synthesis makes.
- **Sources** updated. `2026-04-27-perplexity.md` is the new dump. `2026-04-27-grok.md` carries the new diagnosis under an addendum block.
- **Campaign metadata** updated. Episode 2's verdict line on `campaign.md` reads *sharpened*. Interactive 2 status reads *shipped*. The Episode 3 candidate question reads *queued*.

The thing the addendum got out of the system was a slightly worse fallback policy. The thing it left in was the verdict it tested. The contrarian-X gap is the only un-closed source.
