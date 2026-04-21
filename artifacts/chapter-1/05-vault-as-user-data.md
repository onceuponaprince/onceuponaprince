# Vault as user data

Monday morning. Two feature branches already pushed. `feature/ai-swarm-infra` has a Python skeleton and a README. `feature/study-buddy` has an importer scaffold — `jszip`, `gray-matter`, `localforage`. I sat down to plan the scaffolding session. The scaffolding had already happened.

The scene I'd opened was built around plan → execute → review. Two of those three were already in the past tense. The orchestration shape had inverted before the first session started.

That inversion is the small story. The larger one is what the scaffolds decided on my behalf.

## What the scene was

Chapter 1 runs on client work. Scene 05 was the first internal-infra exception. Two side-projects that lived outside the chapter's through-line: `ai-swarm-infra`, a Python orchestrator for an LLM cluster split across two machines I happen to own; and `study-buddy`, an Obsidian vault parser that wants to be a study tool. Neither was a git repo at the start of the week. Both were folders on my machine.

The question when the scene opened was *keep / adapt / archive*. The question when it closed was *when do I start building study-buddy properly* — a different question, with a decision framework for an answer.

## The divergence I hadn't written down

`study-buddy`'s scaffold shipped with an architecture that wasn't in the spec. The plan I'd written down said *copy the vault into the monorepo*. The code said something else: the browser takes a zipped vault from the user, `jszip` uncompresses it in memory, `gray-matter` parses the frontmatter, `localforage` stores progress in IndexedDB. The vault never touches the server. There is no server.

The formal term for this is runtime import. The useful framing is *vault as user data, not system data*. The markdown notes belong to the person studying them, and the application is — correctly — a renderer rather than a database.

That's an architectural commitment, not a stack choice. A database-first design makes the curator's vault into content the platform owns. A runtime-import design makes the application a player — more like a PDF reader than a SaaS. Operating cost drops to static hosting. Privacy posture is absolute by construction. The feature ceiling is lower because the application can't know anything the browser doesn't know. All three consequences matter more than the framework.

## Why the decision belongs in the narrative

The scene structure caught this divergence only because the Conclude block asked the question. The Moment-by-moment capture had the scaffold state but not the reasoning. If I'd drafted the essay from the capture directly, the architecture would have been background. The Conclude step asks *what did we learn*, and the answer turned out to be a design precedent.

Future BorAI apps that can honour "data never leaves the device" probably will. Not because of a written rule but because the first non-trivial architecture decision in this campaign went that way, and the scene absorbed it explicitly. Precedents in a young project are set by accident; the scene structure catches them before they set silently.

## The other project, briefly

`ai-swarm-infra` is the counterweight. It got the same polish pass — `pyproject.toml`, `uv`, sibling-aligned. It is not functionally runnable. The Python modules are skeletons. The README names its position in the 2026 local-LLM stack — an agent-layer manager above the model layer, sitting on top of inference clusters rather than sharding models itself — not its readiness. Honest scaffold state: a structural claim to a future capability, not a live component.

The point isn't that one scaffold is finished and the other isn't. It's that `ops/` can hold unfinished work legibly, as long as the framing says so. The scene catalogued each project on its own terms. Neither had to pretend to be the other.

## A pattern Chapter 1 produced by accident

Scene 05 wasn't supposed to happen. Chapter 1's constraint is *no webapp, no building*. The chapter's through-line is client work. This was internal infra.

What it produced is worth naming: *structural polish without the build* — aligning scaffolds to sibling conventions without writing application logic. It preserves momentum without violating the chapter's constraint. Scene 05 stayed inside the rules by drafting two PR-ready branches, a decision framework, and two synthesised catalogues — not by writing the platform. The chapter's discipline-first aesthetic got another kind of scene it can absorb.

## Next

Scene 06 is the Chapter 1 close. A weekly synthesis — five scenes' Conclude blocks collapsed into a single essay that reports whether the manual proof worked. Chapter 2 builds the webapp.

Source: [github.com/onceuponaprince/borai.cc](https://github.com/onceuponaprince/borai.cc) — `feature/ai-swarm-infra` and `feature/study-buddy`.

---

*Fifth post in the AI Command Centre build-in-public series. Chapter 1 — Origin, Scene 05. Previous: [The backend the frontend invented](04-the-backend-the-frontend-invented.md).*
