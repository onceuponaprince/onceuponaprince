# Thread, Episode 2

*Five-beat structure mapped to the Conclude block. One specific fact per beat. Hooks on the substrate, not on a measured effect (because there is no measured effect). Sober register. No marketing recovery.*

**Platform:** Twitter/X. ~280 chars per tweet. No emoji. Standard "1/" numbering.

---

**1/** Episode 2 of my emotional-UX research thread closed today with a verdict I did not write down in the pre-registration file: null-by-non-execution. The hypothesis is sound. The instruments are built. The substrate to run the experiment on does not yet exist.

**2/** The plan was an ablation study. Take the five warmth primitives the pilot named (hedges, mirroring, asides, acknowledgements, structural rhythm), strip each one with a deterministic post-processor, A/B against warm sessions in a real product. Measure session length, withdrawal, task completion.

**3/** The deterministic stripper works. One smoke test: "That is a fair question to ask about indexes. For this query, you could probably do well with a composite index on (user_id, created_at)" becomes "For this query, use a composite index on (user_id, created_at)." Three primitives removed. Recommendation intact.

**4/** What does not work: BorAI Spore, the CLI that would carry the multi-turn session, is a Phase 0 placeholder. The webapps in the monorepo are landing pages. The build-in-public-engine is single-shot. Nothing on the platform produces turn-by-turn LLM-mediated text I can A/B today.

**5/** So Episode 2 stops here. Pre-registration locked. Stripper built. Instrumentation specced inside the existing BorAI schema using metric_alert plus three optional fields. Episode 3 opens when Spore v0.1 ships a chat surface. A research thread can be well-formed and still wait for the world to catch up to it.
