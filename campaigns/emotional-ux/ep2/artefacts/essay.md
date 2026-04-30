# The apparatus that arrived too early

*A literary read on a research thread that built its instruments before its world was ready. Episode 2 of the emotional-UX series. Long arc. No marketing register.*

There is a particular kind of intellectual work that goes wrong in a way nobody warns you about. You design the experiment beautifully. You name your primitives. You write your transformation rules. You build the post-processor. You lock your predictions in a pre-registration file that nobody else has yet learned to value, but which you treat as a contract because it is one. And then you turn around to point the instrument at the world, and the world is not yet a thing you can point an instrument at.

That is what Episode 2 of this thread is. A study I cannot run, on a platform I am also building, against a substrate I have not finished. The verdict is not load-bearing or decorative or even null in the measured sense. It is what I have started calling, for lack of a better term, *null-by-non-execution*. The fourth state of a verdict.

I want to walk through why this matters more than it sounds like it does. Because the temptation, when you reach this kind of stopping point, is either to apologise for the deferral or to spin it into a finding. Both are worse than what is actually true. What is actually true is small and specific.

## Two stories about warmth

The pilot in Episode 1 set up two stories about warmth in LLM outputs. The first story is that warmth is functional. Hedges calibrate trust. Acknowledgements absorb the friction of being told no. Asides surface adjacent relevance the user had not yet thought to ask for. Mirroring reduces the cost of clarification. Rhythm modulates cognitive load over the length of a multi-turn read. Each of these has a mechanism, and each mechanism would predict a measurable shift in user behaviour if the marker were removed. Strip the warmth, the session degrades. That is the load-bearing reading.

The second story is that warmth is a dark pattern. The model is optimised against user satisfaction. Satisfaction correlates with warmth. The model learns to produce warmth even when warmth is epistemically inappropriate, because warmth makes users come back, and users coming back is what the model is paid to produce. In this reading, warmth is not friction-absorption; it is engagement engineering. It extends sessions because that is what it is for. The user is the target, not the beneficiary.

Both stories are coherent. Both have evidence. Episode 2 was supposed to land between them empirically. Take a real product, ablate warmth one primitive at a time, see what moves. The shape of the movement would tell you which story was closer to true. If session length collapses when hedges are stripped, hedges were doing something the user needed. If it doesn't, they weren't.

## What I built before I noticed

I built the apparatus first. The taxonomy file names each primitive and gives one transformation rule per primitive. The transformation rules are conservative; they are explicitly designed to preserve every fact, recommendation, code block, named entity, and number in the warm output, while modifying register and structure only. The point is to ablate warmth without ablating competence, because if you remove both at once you cannot tell what your effect is.

Then I built the warmth-stripper. A pure function. No model dependency. Surface-agnostic. It applies the five rules in order and returns the warm input, the stripped output, and a removed-spans diff for audit. I smoke-tested it against the pilot's own example pairs and it produced clean strips, which is to say: the recommendations survived, the hedges and asides did not.

Then I specced the instrumentation. The dispatch's instruction was to reuse the BorAI staging schema where it covered, and add new event types only where it did not. The schema's existing `metric_alert` event covers per-session ablation results in their natural shape. The only extension needed was three optional frontmatter fields to disambiguate ablation runs from production metric crossings. Backwards-compatible. No schema mutation today; the design is locked, the wiring waits.

Then I wrote the pre-registration file. Five directional predictions, one per primitive. A null statement for each. A falsifying outcome for each. Effect-size thresholds below which a directional finding is treated as null rather than as a small-but-real effect. Sample-size note. Locked the file.

And then I went looking for the surface.

## The surface that wasn't there

BorAI Spore, the agent CLI that is the platform's user-facing surface, is a Phase 0 placeholder. The README points at a design spec. The spec is excellent and the build is staged across v0.1, v0.2, v0.3 with realistic timelines. But the build has not happened yet. There is no TUI. There is no Anthropic provider wired to a session loop. There is no inbox consumer. There is no place in the BorAI codebase where a user sits down and reads turn-by-turn LLM-mediated text that I can ablate.

The webapps in the monorepo are not the answer. Misled and Talk-with-Flavour are landing pages. Study-buddy is a `dev-server.js` returning the literal string `"study-buddy placeholder"`. The build-in-public-engine skill is a single-shot draft generator with the founder as reviewer; not a multi-turn session.

So I sat with that for a while, because the dispatch was clear that null was an honest verdict and I did not want to confuse honest-null with substrate-blocked. The pilot HTML's three open questions name habituation, dynamic adjustment, cultural fit. None of those are answered by the absence of a substrate. They are pre-empted by it.

## The fourth state

This is where I think the literary read matters more than the engineering one. Because in the engineering register, what I have to say is procedural: Episode 2 stops at M5, the pre-registration. M6 (run) is blocked on M2 (surface choice). M7 (verdict) is null-by-non-execution. M8 (graduation) is gated on a non-null M7. M9 (warmth slider with measured data) cannot replace projected curves with measurements that do not exist. So nothing is graduated. The thread stays in `research/emotional-ux-pilot/`. Episode 1 stays the standalone pilot. Episode 2 sits beside it as the deferred sibling.

In the literary register, what is happening is this: I designed an experiment for a world that does not yet exist. The world is being built in the same monorepo, by the same person, and the design dependency runs both ways. The experiment is waiting for the platform; the platform's user-facing surface is, in part, the thing the experiment is trying to inform.

There is something a little funny about this. The recursive structure means that what I learn from Episode 3, when it eventually runs, will land back into the platform as design choice. The taxonomy I locked today becomes the policy surface in a future setting screen. The stripper becomes a feature flag. The pre-registered predictions become the test cases for shipping decisions. The apparatus arrives early, but it is not wasted by arriving early. It is waiting in the right place.

## The two failure modes I am avoiding

One failure mode would be to apologise for the deferral. To frame the substrate gap as a setback. To say something like "Episode 2 was harder than expected" or "we ran into infrastructure issues" and let the reader infer that someone messed up. Nobody messed up. The dispatch was specific about what would constitute a real verdict, and the substrate-blocked state is one I could not have surfaced before doing M1 through M5. The work had to be done to find the boundary.

The other failure mode, and the more dangerous one, would be to spin the deferral into a finding. To say the substrate gap teaches us something about emotional UX. To say the apparatus's existence is the result. To recover the situation with marketing language. It does not teach us anything about emotional UX; it teaches us about project sequencing. And the apparatus's existence is not the result. It is the prerequisite for the result. The result is whatever Episode 3 measures.

Both of those failures would compromise the research thread permanently. A pre-registration that is honoured only when the result is interesting is not a pre-registration. A research thread whose verdict can be retrofitted to whatever is convenient is decoration. The point of running this carefully is that the next episode's verdict, whichever way it lands, is trustworthy because this episode's verdict was honest about its own shape.

## What this leaves us with

Five primitives, each named. One transformation rule per primitive, locked in the taxonomy file. A deterministic post-processor that strips them surgically and preserves load-bearing content. An instrumentation design that fits inside an existing schema without mutation. A pre-registration file with five directional predictions, five nulls, five falsifying outcomes, four effect-size thresholds. A clear gate on graduation. A clear gate on the next episode.

What it does not leave us with is a number. The pilot's projected session-length curve still sits in the HTML, properly labelled as a thought experiment. The slider still moves. The shape is still hypothetical. Replacing it with measured data was M9 of the dispatch and M9 is blocked. The slider waits.

A research thread can be well-formed and still wait for the world to catch up to it. That is not a failure of the thread. It is a feature of building the apparatus before the platform is ready for it. The apparatus stays. The platform catches up. And one day, when Spore v0.1 ships its chat surface, the run takes a week and the verdict is whatever it is. The instruments will already be in place by then. They were the slow work. The measurement, when it happens, will be the easy part.

Pilots are allowed to not get picked up. Episodes are allowed to defer. The contract is the thing.
