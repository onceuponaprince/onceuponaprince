# Cheap protocols compound

The home cluster's swarm pipeline was *hardened* in Scene 01b and *extended* in Scene 01c. Across the two scenes, twelve gap items closed. The work in 01c was conceptual rather than diagnostic — adding mechanism on top, rather than fixing mechanism in. Three of the additions share the same shape: each one chose the smallest workable protocol and let the rest of the design be process around it. This essay is about that pattern.

## The setting

01c took on four extensions: multi-round refinement (Coder→Reviewer→Coder until approval), model routing (a Python prompt selects a different model than a TypeScript prompt), LAN authentication (bearer-token auth between orchestrator and workers), and an HTTP API (a FastAPI wrapper that the chapter's eventual webapp can call). Each could have shipped with a richer abstraction. None did.

## Approval as a one-word protocol

Multi-round refinement needed an exit signal. The Coder writes code, the Reviewer critiques, the Coder refines — but the loop has to stop somewhere. Either at a maximum round count (three, in the implementation), or when the Reviewer says *good enough*. What does *good enough* look like in the wire format?

The richer answer: a structured JSON envelope. The Reviewer returns `{"approved": true, "comments": [...]}` and the orchestrator parses it. Clean schema, machine-friendly, types you can validate.

What shipped: the Reviewer's response, as a string, starts with `Approved.` when the code is correct. The orchestrator calls `review.strip().startswith("Approved.")`. That is the entire protocol.

The simpler protocol wins for one specific reason: both ends of the wire are the same author's code. The orchestrator writes the persona that tells the Reviewer to emit `Approved.`; the orchestrator parses for `Approved.`. There is no third party to negotiate with. Ceremony — types, envelopes, schemas — earns its place when contributors diverge. When both ends are the same author, the protocol can be cheap.

The atom of the protocol is the literal string `"Approved."` Adding a richer signal later is one constant edit. Adding it now would be three abstractions in search of a use.

## Routing without embeddings

Model selection — *use a different Coder model for Python prompts than for TypeScript prompts* — has many possible implementations. Three real ones:

- **Embedding similarity**: compute a vector for the prompt, compute vectors for each model's description, pick the closest match.
- **LLM classifier**: ask a small model *which language is this prompt about*, route on the answer.
- **Substring lookup**: check whether the prompt contains *"python"*, *"django"*, *"typescript"*, *"react"*. Map matches to env keys. Done.

The substring lookup is what shipped. A dictionary of ten keywords, a case-insensitive `in` check, a fallback to the default model. Sixty lines of code including tests. Debuggable in one read; editable in one keystroke when a new keyword is needed.

The smarter implementations would be smarter, in the sense that they would route some prompts the substring lookup misses. They would also be more expensive in three ways: implementation cost, latency cost (embeddings or classifier calls per request), and debugging cost (when the routing goes wrong, the failure mode is *the model output a wrong answer* rather than *the keyword wasn't in the list*).

For a swarm with two workers and four prompt languages routinely seen by this user, the routing surface is small. The smart implementations have their place; this wasn't it. The atom of the policy is the `LANGUAGE_KEYWORDS` dict, and that dict can grow until the substring approach genuinely breaks. *Then* embedding similarity earns its place.

## Auth split across the wire

LAN authentication between the orchestrator and the two worker Ollama instances needed two changes in two places:

- On the orchestrator: send an `Authorization: Bearer <token>` header with every request when `WORKER_AUTH_TOKEN` is set in `.env`.
- On each worker host: front Ollama with a tiny reverse proxy that validates the bearer token.

The orchestrator side ships in code with full unit coverage. The worker side ships as a four-line caddy config (or eight-line nginx config). The two changes do not bundle: they live in different repositories on different hosts, deployed at different times by different processes.

The temptation, given they implement *one feature* together, is to make them ship together — a workflow that deploys both, a config schema that encompasses both, an installer that knows how to install caddy. None of that earned its place. The orchestrator code can ship and be unit-tested without the worker proxy existing. The worker proxy can be deployed and tested for unauthenticated-rejection without the orchestrator changing. They compose at runtime via a shared secret; that is the only coupling that needed to ship.

The atom of the policy is the bearer token string. Everything else is mechanism around it — header construction on the orchestrator side, header validation on the worker side. Two atoms, one secret, no bundle.

## What compounds

The three observations look like notes about specific design choices for a specific home-cluster swarm. They are also notes about how to size protocols for the actual surface area in front of you.

In all three cases the cheap protocol carries the work the substrate actually needs to do. *None of the three implementations is permanent.* The substring routing can grow keywords until it doesn't fit; then it can be replaced with something semantic. The `Approved.` prefix can grow structure if a third party joins the wire; then it can be replaced with a JSON envelope. The pre-shared bearer token can be replaced with KMS-issued short-lived tokens if the substrate ever runs outside the home LAN. The point is *not* that the cheap protocols are good forever. The point is that they are good *now*, and *now* is the only time their cost-benefit ratio matters.

The temptation in greenfield work is to design for the substrate's eventual size. The pattern that landed in 01c argues the other way: design for the substrate's current shape, name the atoms cleanly so they can be replaced when growth forces it, and stop. Build should feel like play; play does not require importing the entire abstraction toolkit on day one.

Eight items shipped in 01b, four in 01c, twelve in two scenes. The chapter's webapp climax now opens against a substrate with no remaining debt. The next scene's work stands on this layer rather than competing with it for attention.
