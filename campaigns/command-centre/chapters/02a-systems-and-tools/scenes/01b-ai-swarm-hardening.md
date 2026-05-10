---
campaign: "[[command-centre]]"
chapter: "02a-systems-and-tools"
scene: "01b"
title: "ai-swarm hardening"
status: not-started
date_opened: 2026-05-10
date_concluded: 
characters:
  - "[[prince]]"
  - "[[solo-thesis-holder]]"
spec_file: null
blockers: []
supersedes: null
artifacts: []
tags:
  - chapter-2a
  - ai-swarm
  - production-readiness
  - reliability
  - tier-1
  - tier-2
  - tier-3
---

# Scene 2a-01b — ai-swarm hardening

*Chapter 2a — Systems and tools · Campaign: [[command-centre]]*

Sibling to Scene 01. The home cluster's pipeline runs; this scene budgets the work between *runs once* and *runs reliably enough for the rest of the chapter to forget about*. Tier 1 fixes the failure modes Scene 01's session surfaced. Tier 2 takes the substrate to production-grade. Tier 3 stretches the architecture toward the patterns the webapp climax will eventually call.

---

## Set the Stage

### How did we get here?

Scene 2a-01 closed its substrate beat on 2026-05-10: three smoke prompts ran end-to-end, six Path A artefact files landed, the orchestration tempo of the home cluster became a fact rather than a claim. The same session surfaced twelve specific failure surfaces — sharp edges that the round-trip route stepped around rather than removed. The gap analysis was written down. The sharp edges are still there.

A working substrate with twelve named failure modes is a different kind of incomplete than an unworking substrate. Scene 01's success made *this* scene addressable: there is now a real thing to harden, with real measurements to harden it against.

### Where are we going?

A substrate the rest of Chapter 2a can rest on without surprises. Concretely, three tiers of work, ordered by criticality:

**Tier 1 — sharp edges that bit in the Scene 01 session.**
1. **Pre-flight health probe in `orchestrator.run_pipeline`.** A cheap `num_predict:1` ping to both worker nodes before dispatching the real prompt. Surfaces RAM gates, subscription gates, and TCP drops in ~2s rather than failing 45s into the round-trip.
2. **`keep_alive` on the `network_client` payload.** Default Ollama unloads a model 5 minutes after the last call; the first standalone invocation pays a 10-30s cold-load. Setting `keep_alive: "30m"` on the generate payload eliminates this for back-to-back development.
3. **Reviewer persona tightening in `personas.py`.** The small distilled R1 model rewrote the Django prompt's working code into something that didn't compile. The persona currently invites rewrite; constraining it to *critique only — do not regenerate the code* limits the damage on under-resourced Reviewer hardware.
4. **Retry on transient runner crashes.** `unexpected EOF` and `llama runner process has terminated` are not currently retried. Two to three retries with backoff in `NetworkClient.generate` cover the OS-OOM-killer class of failures.

**Tier 2 — production readiness.**
5. **Test coverage for `config.py`, `network_client.py`, `personas.py`.** Zero unit tests on those three modules today.
6. **Docker + Compose entry for the orchestrator itself.** Scene 01's Pivot moved the *workers* to docker (now installed on both); the orchestrator stays bare Linux. Closing that loop makes the whole pipeline reproducible from one `compose up`.
7. **Structured logging — file plus JSON.** Currently rich-console output only. No audit trail of a failed run after the fact.
8. **Streaming output (`stream: true`).** Long generations show no progress signal today. Switching to streamed response with token-by-token forwarding lets the orchestrator log live and feels less like waiting.

**Tier 3 — architecture stretch.**
9. **Multi-round refinement.** One Coder pass + one Reviewer pass = done. Looping until the Reviewer approves or N rounds is the next-order pattern.
10. **Model routing per task.** Same Coder/Reviewer every prompt; routing by language / domain / complexity earns the layer above persona selection.
11. **LAN auth on the Ollama endpoints.** Currently unauthenticated — anyone on the subnet can hit them. Bearer-token middleware on the worker side; orchestrator carries the token from `.env`.
12. **HTTP API to feed the eventual Command Centre webapp.** CLI-only today. A thin FastAPI wrapper exposing `POST /pipeline` and `GET /artefacts/{ts}` makes the substrate consumable by the webapp climax without re-architecting.

Tier 1 is the must-land set — without it the substrate is friable. Tier 2 is the should-land set — without it the substrate is fragile rather than friable. Tier 3 is the may-land set — earns its place inside this scene if Tier 1 + Tier 2 close cleanly, otherwise carries to a sibling scene.

### State of the world (project context)

`ops/ai-swarm-infra/` on `borai` `main`:

- `orchestrator.py` — `run_pipeline` returns `tuple[str, str]` (Path A shipped).
- `main.py` — writes paired `swarm-{ts}-coder.txt` + `swarm-{ts}-reviewer.txt`.
- `network_client.py` — synchronous `requests.post` to `/api/generate`, no `keep_alive`, no retry, raises `WorkerError` on transport or `error` field.
- `config.py` — dotenv-loaded `SwarmConfig` dataclass. No tests.
- `personas.py` — static `CODER_PERSONA` + `REVIEWER_PERSONA`. The reviewer persona does not forbid rewrite.
- `tests/` — covers `orchestrator` and `main` only. Five tests, all green.
- `.env` — current model assignment `ministral-3:3b` + `deepseek-r1:1.5b`, `REQUEST_TIMEOUT=3600`. Worker URLs are LAN-bound, no auth.
- Worker hosts: Ryzen + MBP. Docker now installed on both as of 2026-05-10; native Ollama is what tonight's round-trip used. The Pivot's canonical docker-runner state hasn't moved.

### State of the hero ([[solo-thesis-holder]])

The hero wants infrastructure they can forget about. Sharp edges they hit themselves are accepted; sharp edges that hit at 11pm on a Friday when they were trying to ship something else are the texture of *filing taxes*, not of play. This scene's read for them turns on whether the hardening earns its place — whether the audit trail it produces is itself something to *play with* (the structured logs as data, the streaming UI as feel, the retry policy as a tiny game with the OS scheduler) rather than a list of chores against the substrate.

The dominant objection: *most of these are routine engineering chores, not story material.* The scene answers by structuring the work as tiers — Tier 1 is failure-mode storytelling (the four bugs we hit), Tier 2 is *empire in their head* (the substrate I trust enough to forget), Tier 3 is *the atom of the webapp* (each Tier 3 item is a primitive the webapp scene will need). The chores compound into a story even when each chore is small.

### State of the protagonist ([[prince]])

Just shipped Scene 01. The substrate works. The cognitive state is *enthusiastic plus aware of exactly which corners of the substrate hurt* — the rare condition where the engineer remembers both why a fix matters and where the fix goes. This scene wants to land before that memory decays into *I'll deal with it when it breaks again*.

The risk in the protagonist's state: scope inflation. Twelve items is a lot; the temptation is to fold all twelve into one heroic session. The scene structure budgets against that by ordering tiers and naming a closing condition that does not require all twelve.

### This moment in relation to goals

Chapter 2a's climax is the Command Centre webapp MVP. The webapp scene's Set Stage will read against whatever substrate exists at that point. Tier 3 item 12 (`HTTP API`) is the *atom* of the webapp's integration with the swarm — it is named here as a Tier 3 item but it is functionally a precondition for the climax scene to even open. The hardening scene therefore sits closer to the chapter spine than its sibling numbering suggests; calling it `01b` rather than its own primary number is a *sibling* claim about substrate continuity with Scene 01, not a *minor* claim about scope.

### Why now?

Three reasons, in order of weight:

1. **Memory decay.** The exact failure modes are loaded right now; in a week they'll be a list, in a month they'll be a paragraph in the artefact. Hardening compounds faster when the bugs are still warm.
2. **Substrate dependency.** Scenes 04 and 05 (`borai-graph ship retroactive`, `claude-code edge bridge`) presume the swarm exists. Scenes 06, 07, 08+ presume it is reliable. Tier 1 closing makes those scenes openable without the *will the substrate hold?* question shadowing each one.
3. **Sequencing the artefact.** Scene 01's Conclude draft commits to an *essay* on the model-gating debugging trace. Scene 01b's eventual artefact is the natural sibling — *how the substrate hardened*. Two essays from the same arc compound into more than one essay twice as long; the artefact pair is its own pacing beat.

---

## Progress the moment

### Goal for this session

**Closing condition for the scene:** Tier 1 (items 1-4) landed and verified end-to-end on the home cluster. Tier 2 (items 5-8) landed in code, optionally verified depending on hardware availability. Tier 3 (items 9-12) — Tier 3 items 9-11 are stretch; item 12 (HTTP API) lands inside this scene only if Tier 1 + Tier 2 close cleanly with enough session left, otherwise carries to a sibling scene named in the Conclude's *Next scene*.

By-tier-success criteria:

- **Tier 1 verified:** pre-flight probe surfaces a deliberately-misconfigured worker URL in <3s; cold-load on a back-to-back run is sub-3s rather than 10-30s; Reviewer persona rejects a "rewrite this for me" instruction by emitting critique only; a forced `unexpected EOF` (worker killed mid-stream) recovers via retry within 30s.
- **Tier 2 verified:** unit tests for the three uncovered modules pass; `docker compose up` from `ops/ai-swarm-infra/` brings the orchestrator container online and connects to the two workers; one round-trip's logs land as both rich-console output and a structured JSON file in `logs/`; one streamed run shows token-by-token forward in the console.
- **Tier 3 verified (stretch):** Reviewer-approval loop closes on the fibonacci prompt within N≤3 rounds; a non-default Coder is selected for a Python prompt versus a TypeScript prompt; an unauthenticated request to a worker endpoint is rejected; `POST /pipeline` from a separate shell triggers a round-trip and returns the artefact pair.

### Moment-by-moment capture

*Commits, decisions, surprises.*

- [ ] Tier 1.1 — pre-flight health probe added to `orchestrator.run_pipeline`. Tested against a deliberately wrong CODER_NODE_URL.
- [ ] Tier 1.2 — `keep_alive: "30m"` added to `NetworkClient.generate` payload. Verified by back-to-back runs.
- [ ] Tier 1.3 — `REVIEWER_PERSONA` tightened to critique-only. Verified by re-running the Django prompt against `deepseek-r1:1.5b` and observing no rewrite.
- [ ] Tier 1.4 — Retry-on-transient-error in `NetworkClient.generate` (2-3 retries, exponential backoff). Verified by killing the worker mid-stream and observing recovery.
- [ ] Tier 2.5 — Unit tests added for `config.py`, `network_client.py`, `personas.py`. Coverage > 80% for each.
- [ ] Tier 2.6 — Orchestrator Dockerfile + `docker-compose.yml` entry. `compose up` brings the orchestrator + the two-worker network expectation into one playbook.
- [ ] Tier 2.7 — Structured JSON logging via `python-json-logger` (or equivalent) alongside rich console. One file per run under `logs/swarm-{ts}.jsonl`.
- [ ] Tier 2.8 — `stream: true` on the generate payload; orchestrator forwards tokens to console as they arrive.
- [ ] Tier 3.9 — Multi-round refinement: orchestrator loops Coder→Reviewer→Coder until Reviewer emits an explicit approval token or `MAX_ROUNDS` reached.
- [ ] Tier 3.10 — Model routing: a tiny dispatcher in `orchestrator.py` selects Coder/Reviewer pairs from `.env` declarations keyed by detected language or task type.
- [ ] Tier 3.11 — Bearer-token auth between orchestrator and workers; token in `.env`, middleware on worker side rejects unauthenticated requests.
- [ ] Tier 3.12 — FastAPI wrapper: `POST /pipeline` with prompt body, `GET /artefacts/{ts}` returning the artefact pair. Same Path A files on disk; the HTTP layer is read-write thin.

### What's changing?

*To be filled as the session progresses.*

- 

---

## Conclude

*Filled at end of session.*

### How is now different from the start?

### What are the consequences?

### What did we learn?

### Progress to thesis

### Progress to goal

### Next scene

### Artifact format
*Thread / newsletter / video / essay / none.*

---

## Notes

The twelve items came from Scene 2a-01's session-end gap analysis (2026-05-10). The tiering is deliberate: T1 is *what would have prevented the failure modes the session burned time on*; T2 is *what makes the substrate calmly trustable*; T3 is *what makes the substrate compose into the next layer*. The closing condition does not require all twelve — over-promising twelve items into one scene is the failure mode the *State of the protagonist* names. The honest landing is Tier 1 must close, Tier 2 should close, Tier 3 closes opportunistically or carries.
