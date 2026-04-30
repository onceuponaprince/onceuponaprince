---
campaign: "[[command-centre]]"
chapter: "01-origin"
scene: 05
title: "Two side-projects — additional workflow infra"
status: concluded
date_opened: 2026-04-20
date_concluded: 2026-04-21
characters:
  - "[[prince]]"
spec_file: null
blockers: []
supersedes: null
artifacts:
  - format: thread
    file: "[[05-orchestration-shape-inverted-thread]]"
  - format: essay
    file: "[[05-vault-as-user-data]]"
tags:
  - side-project
  - infra
  - workflow
---

# Scene 05 — Two side-projects — additional workflow infra

*Chapter 1 — Origin · Campaign: [[command-centre]]*

One-line summary: capture and review two recently built side-projects that add workflow infrastructure, iterate decisions in tandem, and record any carry-over patterns for the BorAI monorepo.

---

## Set the Stage

### How did we get here?
Two small workflow-focused projects were built recently to help personal productivity and the BorAI developer experience: lightweight infra that automates parts of the day-to-day (repo scaffolding, CI helpers, local runners, deploy shortcuts). They live outside the chapter's client work but affect how future scenes ship and how the monorepo is managed.

### Where are we going?
Review both projects in parallel, run their workflows where possible, capture gaps and integration points, and decide what stays as a personal tool vs what should be absorbed into BorAI as shared infra.

### State of the world (project context)
- BorAI monorepo present at `~/code/BorAI/`.
- Chapter 1 constraints: discipline-first, manual proof; these side-projects are internal aids, not client deliverables.
- No CI-standard for sibling apps yet; infra projects aim to reduce friction and standardise common ops.

### State of the hero ([[prince]])
Tired but optimistic; built two tools to reduce friction. Wants reduced context-switching; needs clear decisions so the tools don't create more cognitive debt.

### State of the protagonist ([[prince]])
Has the local code and CLI entrypoints for both side-projects. Ready to run them, take notes, and decide which parts are mission-critical for BorAI.

### This moment in relation to goals
These side-projects could either accelerate Chapter 2 (webapp) by reducing operational friction or become tech debt. The scene tests whether they earn their place in the shared monorepo.

### Why now?
The tools were just built and are fresh — running them now catches issues early and prevents them from becoming conventions by accident.

---

## Progress the moment

### Goal for this session
- Run both side-project workflows end-to-end (smoke test).
- Capture any conflicting assumptions, pin decisions, and list tasks to integrate useful pieces into BorAI.
- Produce a short implementation plan: keep, adapt, or archive per project.

### Moment-by-moment capture
- [x] Scene opened and Set Stage recorded — Set Stage signed off (2026-04-20).
- [x] Ground-truth audit (2026-04-20): both side-projects live as standalone folders at `~/code/study-buddy/` and `~/code/ai-swarm-infra/`, not inside BorAI. Neither is a git repo. study-buddy is an Obsidian vault of curriculum notes across Rust, Django, Next.js, Solana, NLP, RL. ai-swarm-infra contains only `swarm-architecture.md` (3791 bytes). Prior capture entries reflected intent, not reality; corrected here.
- [x] Scope redefined (2026-04-20): scene is now a cataloguing pass, not a keep/adapt/archive decision. Both projects integrate into BorAI as part of the build-in-public story. study-buddy additionally seeds a future platform app — this scene delivers the spec and trigger criteria, not the build itself (Chapter 1 constraint: no webapp built).
- [x] Branches and push (2026-04-20): `feature/misled-ethos-page` pushed to origin (`e461023..6cf1715`); `feature/ai-swarm-infra` and `feature/study-buddy` already exist on origin with scaffolds committed outside this orchestration session.
- [x] Pre-existing scaffolds discovered on branches (2026-04-20):
    - `feature/ai-swarm-infra` — `d40af65 scaffold(ops): ai-swarm-infra`. Promotes `swarm-architecture.md` to `ops/ai-swarm-infra/README.md`; adds Python skeleton (`main.py`, `orchestrator.py`, `personas.py`, `network_client.py`, `requirements.txt`).
    - `feature/study-buddy` — two commits: `9e487e0 scaffold: study-buddy app placeholder` and `6b7ef3f feat(study-buddy): add vault importer + parser scaffold`. Architecture is *runtime import* (`jszip` + `gray-matter` + `react-markdown` + `localforage`): platform ingests any Obsidian vault the user uploads, parses client-side, stores in IndexedDB. Diverges from the original "copy vault into monorepo" intent; represents a first-class architectural decision worth cataloguing.
- [x] Grok unavailable (2026-04-20): xAI team credits exhausted. Falling back to Claude Code web search for the recency scan; deferred until just before Gemini synthesis.
- [x] Orchestration shape revised (2026-04-20): scaffold execution was done out-of-band, so the scene collapses from plan + execute + review to review + synthesize + narrate. Curator, not conductor.
- [ ] Review pass: `feature-dev:code-reviewer` subagents on both scaffolds (parallel), briefed with `aligning-monorepo-siblings` checklist; findings presented to Prince.
- [ ] Polish pass: Cursor on each branch in turn (`feature/ai-swarm-infra` first, then `feature/study-buddy`), applying alignment fixes and any concerns from review; Tier 2 diff-review per branch.
- [ ] Web search recency scan (Grok fallback): local-LLM intranet tooling (Ollama clustering, LocalAI, exo, Petals, llama.cpp RPC, vLLM distributed serving) in the last 30 days; feeds narrative framing for ai-swarm-infra.
- [ ] Gemini synthesis: per-project catalogue notes (origin, problem solved, BorAI fit); full study-platform product spec with alternative architectures weighed (runtime import vs static bundle vs CMS-backed vs server-side parsing) and a recommendation; decision framework for when to start building the platform. Tier 3.
- [ ] Conclude block drafted from Gemini synthesis (vault `conclude` skill).
- [ ] Gemini: build-in-public thread draft — compressed, punchy.
- [ ] Gemini: build-in-public essay draft — long-arc, reflective.
- [ ] Frontmatter: flip `artifact_format: none` → `thread, essay`.
- [ ] Open two PRs (`feature/ai-swarm-infra` → `main`, `feature/study-buddy` → `main`); merge on approval BEFORE Scene 05 concludes.
- [ ] Mark scene `status: concluded`, set `date_concluded`.
- Protagonist reflection (2026-04-21): the pull to do everything in parallel — open the next scene, merge both PRs, fire the artifact drafts, start a new side project — is strong. The discipline is to finish what is open before starting what is next. Focus is the constraint that produces output.
- Post-conclusion note (2026-04-21): today's two-task-force dispatch (Misled close-out plus ai-swarm-infra buildout) is deliberately run as an instrument, not just a workflow. The orchestration pattern this scene catalogued — hybrid staged dispatch via delegate-agent to Gemini, Copilot, Cursor — is under test. The point is to surface where parallelism actually compounds versus where it only adds coordination overhead, where delegation boundaries hold versus where they leak out of scope, and which sub-tasks expose learning points worth extracting into their own scenes later. The scene the dispatch runs inside is 04; the scene whose thesis it tests is 05.
- UX research note (2026-04-21): the orchestrator's off-topic Insight footers — the aside blocks that sit outside the actual task output — register as smoothing. They do no direct work but they change the texture of the exchange: interaction reads as collaborative rather than transactional. Worth extracting into its own research thread: deliberate emotional quirks baked into LLMs as a UX device, not a stylistic choice. Hypothesis: warmth is functional. It extends session length and reduces friction enough to be a measurable UX primitive. File as a candidate scene for later in the chapter or a lateral research piece.

### What's changing?
- Potential new defaults for CI, scaffolding, or local-run patterns.
- Decisions here will influence how future sibling apps are scaffolded and how onboarding works.
- study-buddy's runtime-import architecture (user-uploaded vault parsed client-side) is the first substantive architecture decision in this campaign; how it is narrated sets precedent for how future architecture decisions become artifact material.

---

## Conclude

### How is now different from the start?

At the start: two side-projects sat in `~/code/` as standalone folders, neither tracked by git, and the scene's Set Stage claimed they had already been scaffolded into BorAI. They hadn't. The open question was keep / adapt / archive.

At the end: both are in BorAI on feature branches, polished to sibling conventions, catalogued honestly (ai-swarm-infra as `ops/` infrastructure; study-buddy as an `apps/` platform seed with its runtime-import architecture named as a first-class decision). The question has shifted from keep / adapt / archive to *when to start building the platform*, with a behavioural decision framework in hand.

### What are the consequences?

- BorAI's `ops/` now has a Python convention (`pyproject.toml` + uv) where there was none. Future Python work under `ops/` inherits a shape.
- Root `.gitignore` now covers Python bytecode. Monorepo-wide hygiene gain.
- study-buddy's runtime-import (user uploads vault; parsing stays in the browser) is named as a design precedent. Future BorAI apps that can honour "data never leaves the device" probably will.
- Two PR-ready branches wait for merge to main.
- A measurable, non-aspirational answer exists to *when to start building study-buddy*: four behavioural signals with thresholds and sources. No more "when I feel ready."

### What did we learn?

The scene absorbs out-of-band work, but only if the capture is corrected honestly at ingestion. The first version of this scene's capture logged intent as action — "scaffolds committed into BorAI" when nothing of the sort had happened. Scenes degrade the moment they start confusing plans for events.

Option (b) — structural polish without the build — turns out to be a real sweet spot Chapter 1 created by accident. It preserves momentum (scaffolds get aligned with sibling conventions) without violating "no building the webapp." Worth naming as a pattern for later Chapter 1 scenes.

Tool unavailability is a live operational cost, not a hypothetical. Cursor and Gemini both gated on auth mid-session; Grok's xAI team was out of credits entirely. The delegate-agent skill's "halt and alert" protocol earned its place: the orchestrator did not silently take over multi-file work.

The most interesting architectural decision this scene captured was not the orchestrator's to make. The runtime-import for study-buddy (vault as user data, not system data) diverged from the "copy vault into monorepo" plan initially proposed. The scene structure caught it only because the Conclude phase asked the question; otherwise the divergence would have gone unnamed.

Orchestration shape can invert inside a scene. This one started as plan → execute → review and ended as review → synthesise → narrate, because two commits already existed. The scene still held. The capture just needed honest labelling.

### Progress to thesis

Two personal tools got catalogued through the same five-beat structure that produced Scenes 02 and 03. The catalogue outputs (the Gemini syntheses) are ready source material for publishable artifacts. The pattern holds: work happens, scene absorbs, artifact falls out. The "act of playing" this time was ordinary (polish, commit, review). The "narrative that sells it" is the decision framework for study-buddy — a when-to-build-it criteria set that is itself a marketable thesis about resisting premature construction.

### Progress to goal

Chapter 1's goal is *from insight to manual proof on real client work*. This scene wasn't client work; it was internal infra. But it proves something adjacent: the scene structure absorbs internal work too, not only client deliverables. The chapter's "manual proof" condition is strengthened by that, not weakened.

The scene-specific goal (run both workflows, capture overlaps, decide per-project outcome, produce an implementation plan) is delivered and slightly exceeded: both projects integrated and polished; per-project catalogue notes; a full platform spec with four weighed architectures; a decision framework for when to start the build.

### Next scene

Return to **[[04-misled-ethos-page]]**. It is open in the chapter checklist, client-facing, and Chapter 1's arc is explicitly about the method proving itself on *client* work. Coming off an internal-infra scene, returning to client work restores the chapter's through-line. The merge of Scene 05's branches can happen in-flight (two PRs, reviewed, merged) without needing a whole scene of its own; Scene 04's Set Stage can note that Scene 05 shipped first.

Chapter 1 close (weekly synthesis) then follows as the chapter's final scene after Misled lands.

### Artifact format

**thread, essay** — two distinct drafts:
- **Thread** — compressed, punchy. Opens with the inversion (orchestration shape flipped mid-scene). Five-beat cadence. Lands on the decision framework as a shareable artefact in its own right.
- **Essay** — long-arc. Reflects on why "runtime-import" (vault as user data) is a more interesting architectural commitment than it appears. Uses ai-swarm-infra's honest scaffold-state as a counterweight: not everything in `ops/` has to run yet.

---

## Notes
- Replace "Project A/Project B" placeholders with the projects' real names and repo paths when provided.
