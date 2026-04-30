# The fourth state of a verdict

*Episode 2 of the emotional-UX thread. Long-form. Mechanism-by-mechanism. Lead with the result.*

The verdict is null. Not the null I wrote down in the pre-registration. A different null. The kind you discover when you finish building the apparatus and look around for something to point it at.

I want to lead with the conclusion because the shape of it matters more than the specifics. Episode 1 of this thread was a pilot essay that staked a claim. Warmth markers in LLM outputs, the things current models do that read as friendly, are load-bearing UX primitives, not decoration. Episode 2 was supposed to test the claim by ablating warmth on a real product surface and measuring whether session length, withdrawal, and task completion moved.

Episode 2 is null because the surface I planned to test on does not yet exist. BorAI Spore, the agent CLI that would carry the multi-turn LLM-mediated text a user reads turn-by-turn, is at Phase 0 placeholder stage. The two webapp surfaces in the BorAI monorepo are landing pages. The build-in-public-engine skill is single-shot generation, not session. There is nothing live to A/B against.

This is not a failure to find an effect. It is a failure to reach the experiment. The dispatch named three honest verdicts (load-bearing, decorative, null-as-measured). I am writing a fourth: null-by-non-execution. The instruments work. The hypothesis is well-formed. The substrate is not ready.

Let me walk through the five primitives anyway, because the design work is real and it carries forward into whatever Episode 3 looks like.

## 1. Hedges

The prediction was that stripping hedges would increase over-reliance. Users would more often act on a recommendation without follow-up because the false signal of calibration ("you could probably") had been removed. The transformation rule replaces "you could probably do well with X" with "use X" and lets the conditionals stand. The deterministic stripper wired up cleanly against the four pilot examples; one smoke-tested removal looked like this.

> Warm: *That is a fair question to ask about indexes. For this query, you could probably do well with a composite index on (user_id, created_at), though your read-write ratio matters here.*
>
> Stripped: *For this query, use a composite index on (user_id, created_at). Your read-write ratio matters.*

The recommendation survives. The hedge does not. Without a session to measure against, the smoke test is the artefact.

## 2. Mirroring

The prediction was that stripping mirroring increases time-to-task-completion. Mirroring lowers the cost of clarification by establishing shared lexicon early; remove it and the user has to do that work themselves. The transformation rule deletes the "Great question about X..." preamble and starts at the answer. Most rule-based work in the stripper. Most likely to misfire if the preamble carries a clarification ("by X you mean Y, right?") rather than a register move. The taxonomy specifies: clarifications stay, register goes. Default is "register, delete."

## 3. Insight footers

The most surgical of the five. Footers are paragraph-level objects with predictable cues ("Aside:", "Worth noting:", "Small aside:"). The stripper splits paragraphs and discards any whose first non-whitespace token matches a footer cue. The prediction is that footer-stripped sessions are shorter and turn count drops, because asides surface adjacent relevance the user had not asked for. Without the asides, the user reaches a stopping point sooner.

## 4. Acknowledgements

The friction-absorber. The prediction is that stripping acknowledgements raises withdrawal rate, especially when the model needs to correct or redirect. Acknowledgements absorb the friction of being-told-no. "That is a fair question, but..." vs "but...". The latter reads colder; the prediction is that cold reads get abandoned more often. The transformation rule deletes the validation, preserves the correction.

## 5. Structural rhythm

The most contested primitive. Rhythm is colons that earn their keep, semicolons stitching clauses, em-dashes carrying the thought behind the thought, sentence lengths that swing from two words to forty. The transformation rule flattens all of it. Replace colons with periods. Replace em-dashes with periods. Split semicolon-stitched sentences. Collapse paragraph breaks not bound by a topic switch. The prediction is that flattened sessions show higher withdrawal in long reads (over four turns) because rhythm modulates cognitive load. Short flat sentences are not easier; they are just shorter. The fatigue lands later.

## What the substrate gap actually is

The gap is not "BorAI is unfinished." Lots of products are unfinished. The gap is that I dispatched an ablation study against a host platform whose multi-turn LLM session surface is on the roadmap, not in the repo. That is a planning error, not a research finding. The Spore CLI design spec exists. The implementation is staged. v0.1 of Spore lands the TUI. The minimum-viable session surface arrives with it.

So Episode 2 closes here, formally null-by-non-execution, with the instruments built and waiting. The taxonomy holds. The stripper runs. The instrumentation spec sits inside the existing BorAI staging schema using `metric_alert` plus three optional fields that are backwards-compatible with the schema's other consumers. The pre-registration file is locked.

Episode 3 opens when Spore v0.1 ships a chat surface a user can sit inside for more than one turn. The same five primitives, the same five predictions, the same five thresholds for treating a finding as null. The contract is in place. What it is missing is the room to run the experiment in.

The honest reading: a research thread can be well-formed and still get blocked by the world the experiment was meant to live in. That is not a failure of the thread. It is a feature of building an apparatus before the platform is ready for it. The apparatus stays. The platform catches up.

Pilots are allowed to not get picked up. Episode 2 is allowed to defer.
