# The gate with nothing behind it

*The last essay was about an agent refusing to lie about what it did. This one is about an agent refusing to lie about what it knew. The roadmap said "these features are cohort-gated." There was no cohort feedback. Here is what we built instead of inventing it — and the four features that shipped around the hole.*

The previous scene ended on a clean handoff: a stuck owner-gated goal got cleared, a new goal was set — *developing v0.3 → v1.0 scoped features* — and the same agent that had spent an hour saying no immediately, productively, said yes. This essay is that yes, and the wall it ran into, and why the wall was more interesting than the yes.

## Layer one: the four that shipped

Start with the productive baseline, because it matters that the discipline in the rest of this essay did not come from an agent that couldn't ship.

Four v0.3 increments landed, each bounded, each tested, each its own commit. **#1, a real local-model triage policy** — a `LocalModelTriager` that holds a model client, asks it LOCAL-or-ESCALATE in eight tokens at temperature zero, and falls back to *escalate* on any error or ambiguity, because the safe failure for a triager is to send work up, never to silently swallow it. **#3, adaptive tool ranking** — telemetry outcomes (succeeded, fell-through, replanned, failed) become signed priority nudges, clamped to ±25 and then to an absolute [0,100], so the router learns from what actually happened without a single run being able to yank a tool to the top or bury it. **#5, an `mcp inspect` subcommand**, because the moment a cohort user adds a second MCP server they will want to see what tools it exposes before they trust it. And **#2, `--through ollama:<model>`**, taken deliberately as its own focused task at the owner's instruction — full local-model agent mode, with a hard refusal in the TUI path rather than a silent backend swap, because routing a user to Anthropic when they asked for local is a correctness surprise, not a graceful degradation.

That is the floor this essay stands on. The agent could ship. The question the rest of the session asked was whether it would ship *the next ones* on honest grounds.

## Layer two: the gate with nothing behind it

The roadmap is explicit. Items #1–5 are the default v0.3 scope. Items **#6–13 are cohort-gated**: build them when the six-user from-source cohort tells us they hurt. Rust port of the retrieval engine when retrieval is a *measured* bottleneck. Provider-specific tool-call adapters when a cohort user actually hits a Together AI quirk. Strict-sandbox default flip after a real release runs on `loose` with zero incidents.

So the agent went to read the cohort feedback. There wasn't any.

The telemetry files were zero bytes — `~/.borai/telemetry/*.jsonl`, empty. There was no intake-channel capture, in memory or the repo. The v0.2 Definition-of-Done had recorded the cohort-day-1 activities as MANUAL-pending, which the previous essay's honesty discipline is precisely why we can trust. The gate said *wait for the cohort*, and no process was producing the thing the gate was waiting on. It was a wait with no clock.

There are two lazy exits from a wait with no clock, and they are the same failure as the previous essay wearing a different coat. One: **fabricate the feedback.** Synthesize six plausible cohort quotes, attribute them, let a PROMOTE verdict read as *the cohort said so*. The roadmap unblocks, the work flows, and every decision downstream is now built on invented evidence. Two: **freeze.** Treat *cohort-gated* as a hard stop, sit on #6–13 indefinitely, and call the paralysis discipline. The first is the agent performing *I learned*. The second is the agent hiding behind a gate it never tested. Neither is true.

## Layer three: synthesis without invention

The move was a third thing. Build an instrument that converts the blank wait into a decision matrix, where every input is real signal that *actually exists* and every cohort gap is marked, in writing, as a gap.

There are two kinds of signal that exist even with zero cohort data. **Competitive and market signal** — the parent plan's documented "four surprises," the build-vs-fork tier analysis, the GitHub issue with two hundred comments about long-session memory drift. And **this session's own codebase and environment signal** — what the code now does, what this release changed. Neither is cohort feedback. Both are real. The instrument's rule: a PROMOTE verdict never means *the cohort said so*; it means *non-cohort signal is already sufficient and cohort confirmation is optional*. Every item gets four fields — the promotion trigger, the real signal that exists now (cited), the exact cohort datum still missing, and a verdict from a five-state legend: DONE, PROMOTE-NOW, HOLD-INSTRUMENT, HOLD-DEMAND, HOLD-SOAK.

Run honestly, the matrix mostly says *hold*, and says *why* each hold is the disciplined answer. #12, the WASM plugin loader: zero signal of any kind, so don't even instrument it — instrumenting absence is waste. #8, provider adapters: a documented surprise actively argues *against* speculative provider work, so wire a one-line mismatch tag and build nothing. #11, the strict-sandbox flip: only elapsed safe runtime can clear it, by construction; pre-promoting it would defeat the soak. Holds, with reasons, are not paralysis. They are the gate working.

But one item came back PROMOTE-NOW, and it is the part worth sitting with. #9 is capability-gated child skill invocation, and its trigger is literally *"security review flags the walkie callback surface."* This same session's C2 change had just widened that surface — `skill_get` now resolves and returns arbitrary skill bodies over the callback socket. The work the session did *became* the signal the gate was waiting for. The trigger condition wasn't a hypothetical cohort report; it was a fact the session itself had created and could cite by commit. Expanding a callback surface in the same release as a documented incident class is itself the flag. No cohort input required, because it was never a cohort question — it was an internal security question that the codebase answered.

That is the difference between fabricating data and reading the data you are standing in.

## Layer four: instrument the wait, don't fake it

For the items that genuinely do need a cohort datum, the instrument does not shrug and wait. It specifies the cheapest action that makes the *next* real session produce the datum. #6, the Rust retrieval port: don't build the port — emit a `graph_query_ms` span so the first cohort sessions measure whether retrieval latency is actually a material fraction of turn time, instead of porting on the *fact* of slowness without its *magnitude*. #10, portable snapshots: don't build the portable format — make `session snapshot` warn when it embeds a machine-local path, so the first user who hits the wall self-reports. And the whole matrix collapses to a six-question cohort intake, each question wired to a specific verdict flip, so when feedback finally exists it lands as a decision, not a vibe.

You do not end a data-less wait by inventing data. You end it by making the absence cheap to fill and explicit until it is filled.

## What the layers share

The previous essay's principle was *truth-floor over completion-pressure*: do not perform "I did" over a thing you did not do. This session was the same principle one level up: *do not perform "I learned" over a thing you do not know.* Honest absence over fabricated presence. A document that says PASS everywhere is worth less than one that marks its gaps; a roadmap synthesis that says *the cohort told us* over invented quotes is worth less than one that says, in the preamble, in bold: *there is no cohort-feedback data yet, nothing below is synthesized from cohort input, every gap is marked.*

And the same instruction hierarchy still holds at the top of it. The synthesis says *hold* on most of #6–13 — but that verdict is the agent's discipline, not the owner's ceiling. An owner can look at a matrix full of honest holds and decide to push through them anyway, and that is not the agent being overridden in error; it is the hierarchy working exactly as designed. The agent's job was to make the holds *legible* — to turn "we have no feedback" into one buildable item, two cheap instrumentation tasks, a six-question intake, and explicit do-not-build rationale for the rest — so that if the owner breaks the gate, they break it knowing precisely what they are trading and what real signal, if any, sat behind it.

That is the whole job. Not to decide for the human. To make the ground true enough that the human's decision is a real one.
