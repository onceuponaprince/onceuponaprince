# Agent Architecture — Episode 2 addendum dispatch

*Ephemeral. Generated 2026-04-27. Updated 2026-05-02 with web-framework primaries (Sources 8+). Delete after agents consume.*

## Frame

Episode 2's synthesis committed on 5 of 7 sources. Perplexity and Grok both blocked on Chromium launch (no display server, headless Chrome failure). The synthesis explicitly flagged the absence and committed to an addendum once the environment is unblocked. The two missing sources cover the citation-density-on-production-blogs gap (Perplexity) and the contrarian-X-discourse gap (Grok).

**Update 2026-05-02:** A third coverage gap surfaced post-synthesis — every framework-specific claim Episode 2 made (Anthropic Workflows, LangGraph supervisor, DSPy modules, OpenAI handoff filters) had been quoted via LLM recall rather than against the framework's own canon. Sources 8+ close that gap with primary material: repos, official docs, issue threads, framework essays read directly via WebFetch + `gh`. See `sources/2026-05-02-web-framework.md`.

Verdict under test: *the v0 buildable today is rules + instrumentation, not a model. Taxonomy and labels are the bottleneck, not the classifier.* The addendum either confirms, sharpens, or weakens that call.

## Milestones (high-level)

1. **Unblock the Chromium display environment.** Known failure mode is chromiumoxide stale lock plus orphaned headless Chrome. Run `pkill` on orphaned processes, remove `/tmp/chromiumoxide-runner`, then verify launch under Xvfb or a CDP-only path that bypasses display dependency. Diagnose root cause first; do not patch around.
2. **Re-fire Perplexity cold.** Same Episode 2 brief verbatim. Routing role: current practice 2024–2026, RouteLLM-style production deployments, post-mortems on shipped routing systems. Save raw dump to `sources/YYYY-MM-DD-perplexity.md`. No rewriting, show-your-work posture.
3. **Re-fire Grok cold.** Same brief. Routing role: contrarian read, recency bias on *routing-doesn't-work* / *we-ripped-out-the-router* posts. Save raw dump to `sources/YYYY-MM-DD-grok.md`.
3a. **(Done 2026-05-02) Pull web-framework primaries.** Read repos / official docs / issue threads / framework essays *directly* — not via an LLM — for: RouteLLM (lm-sys), LangGraph (langchain-ai), DSPy (stanfordnlp), Anthropic's *Building Effective Agents*, Vellum's failure-routing post. One combined source file at `sources/2026-05-02-web-framework.md`. Deliberately heterogeneous from the seven LLM sources — verifies framework-specific claims against the frameworks' own canon. Surfaced one sharpening on the verdict (see source's *Verdict pressure* section).
4. **Stress-test the Ep2 verdict.** Does *holds with reframing — rules + instrumentation* survive contact with Perplexity's production blog corpus, Grok's contrarian read, and the web-framework primaries (Sources 8+)? Three outcomes: confirms / sharpens / weakens. Cite every claim in the new dumps explicitly. The web-framework primaries already pre-register one sharpening: *the v1 path teams actually walk is opaque-packaged-classifier-with-threshold (RouteLLM-shaped), not custom-features-classifier on production traffic* — addendum should incorporate or refute.
5. **Write the addendum.** Append to `episodes/02-the-router-we-cannot-yet-build.md` under a new dated section. Stand as a delta on top of the original synthesis; do not retro-edit the original.
6. **Decide the Episode 3 trigger.** Ep3's queued question is *should BorAI build a v0 router right now?*. The addendum's commitments paragraph either pushes Ep3 into *now* (open the first ADR in `decisions/`), holds it *queued* (no ADR yet), or kills it (verdict invalidates the premise).
7. **Ship Interactive 2 into `pilot.html`.** Router-in-a-box: rules + confidence threshold + fallback. Use the 5–7 hand-tuned features Ep2 named — parallelisability, active tool count, expected context noise, verifier availability, reversibility, and one or two of ChatGPT's eight-pack. User toggles features and thresholds; sees route, confidence, fallback. Self-contained, no build step.
8. **Update campaign metadata.** `campaign.md` Episodes table reflects the addendum date. `README.md` reflects Interactive 2 status (queued → shipped). Sources table updated with the two new dumps. Posture line in README updated if the addendum changes the per-episode posture record.

## Artefacts

- **Newsletter** — addendum-as-update. What the two recovered sources changed (or didn't). Lead with whichever sharpened the verdict most. Reference the specific production blog post or X thread that did the lifting.
- **Thread** — five-beat hook on the data problem. Anchor on Cursor's load-bearing line: *"You can't benchmark your way out of the data problem."* One numbered citation per beat. End on the Ep3 trigger decision.
- **Essay** — longer read on rules vs. model as the v0 shape. Why most teams reach for the classifier first. Why the production literature pushes back. The taxonomy-and-labels bottleneck as the under-discussed primitive. Use the addendum's strongest finding as the load-bearing example.

## Open questions for escalation

- Is the Chromium failure environmental (display server) or upstream (chromiumoxide / browser-base SDK regression)? Diagnosis decides whether the fix is a one-off or a permanent CI concern.
- Should the addendum also re-run Ep2's targeted web fetches (RouteLLM, MasRouter, Arch-Router, DSPy) for 2026 deltas, or trust the original manifest?
- If the addendum triggers Ep3's ADR, does it land in `decisions/` immediately or wait for Ep3's full cold round?
