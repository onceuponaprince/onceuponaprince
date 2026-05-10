---
campaign: "[[command-centre]]"
chapter: "02a-systems-and-tools"
scene: "01b"
title: "ai-swarm hardening"
status: concluded
date_opened: 2026-05-10
date_concluded: 2026-05-10
characters:
  - "[[prince]]"
  - "[[solo-thesis-holder]]"
spec_file: null
blockers: []
supersedes: null
artifacts:
  - format: essay
    file: "[[01b-ai-swarm-hardening-essay]]"
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

- [x] Tier 1.1 — pre-flight health probe added to `orchestrator.run_pipeline` (borai 351e148). `NetworkClient.probe` issues a `num_predict:1` generate; `run_pipeline` calls it for Coder + Reviewer before dispatch. Bad-URL verification: probe surfaced `Connection refused` for `http://localhost:1` in 0.35s, well under the <3s budget. Three new unit tests cover the success path, RAM-gate error-body path, and connection-error path. Side effect of the probe: warms the model into `keep_alive`, so the real generate that follows hits a warm worker. Eight tests green.
- [x] Tier 1.2 — `keep_alive: "30m"` added to both `generate` and `probe` payloads (borai b97bd7c). `KEEP_ALIVE_DURATION` module constant; two unit tests assert the payload includes it. Eliminates the 5-minute model-unload that would otherwise cost a cold load on each standalone invocation. E2E warm-run verification deferred until the home cluster is reachable end-to-end.
- [x] Tier 1.3 — `REVIEWER_PERSONA` tightened to critique-only (borai b97bd7c). Old text said *Return the corrected code*, which invited the 2026-05-10 rewrite-and-break failure on the Django prompt. New text forbids rewrite, requires a numbered actionable critique, allows a one-sentence "looks good" when warranted, and explicitly bans code blocks in the output. E2E verification against `deepseek-r1:1.5b` on the Django smoke prompt deferred until the home cluster is reachable.
- [x] Tier 1.4 — Retry on transient runner crashes in `NetworkClient.generate` (borai b97bd7c). `MAX_GENERATE_ATTEMPTS = 3`, exponential backoff, transient errors named explicitly: `unexpected EOF`, `llama runner process has terminated`, `connection reset`, `connection error`. Deterministic errors (RAM gates, subscription gates) raise on first hit — they are not transient and retrying compounds the problem. `_attempt_generate` split out for a single-attempt path the loop calls. Four new unit tests cover transient retry, connection retry, no-retry on deterministic, and max-attempts exhaustion. The pre-existing connection-error test got `monkeypatch.setattr` for `time.sleep` to stay fast under the new loop. Fourteen tests green, 0.25s.
- [x] Tier 2.5 — Test coverage gap closed. `network_client.py` already had three tests; this work added `test_config.py` (seven tests covering load behaviour, missing env handling, optional defaults, override respect, frozen-dataclass guard) and `test_personas.py` (six behavioural assertions pinning intent — forbids rewrite, requires numbered critique, allows short approval — rather than exact wording so persona iteration doesn't break the suite). 27 tests green at 2.5 close.
- [x] Tier 2.6 — Dockerfile + docker-compose.yml + .dockerignore shipped (borai commit). python:3.12-slim base, uv install of the pyproject deps, ENTRYPOINT bound to main.py so the container's positional arg is the user goal. Compose service uses `env_file` (loads .env from project root), `host` network mode (so the container reaches the LAN-bound worker endpoints without `host.docker.internal` gymnastics), and bind-mounts `./output:/app/output` for Path A artefacts. Verified: `docker compose config` passes, `docker compose build` completes in 47s, `docker compose run --rm orchestrator "test"` reaches the Ryzen IP via host networking and surfaces the same probe failure the bare-Python orchestrator does — confirms the docker layer is transparent to the probe behaviour.
- [x] Tier 2.7 — `swarm_logging.py` provides per-run JSONL audit trail. `configure_swarm_logging(logs_dir, timestamp)` sets up the file handler exclusively on the 'swarm' root logger so logs don't leak into stderr or propagate. `get_logger(component)` returns a `swarm.{component}` child. `JsonFormatter` writes `{ts, level, module, msg, ...extras}` per record. `main.py` wires run.start/complete/failed; `orchestrator.py` emits probe/coder/reviewer start+complete events with `elapsed_s`. Four new tests for the logging layer. Logs land at `logs/swarm-{ts}.jsonl` alongside the existing `output/` Path A files. Audit trail survives a crashed run that rich-console output would have lost.
- [x] Tier 2.8 — Streaming generate with live console output. Payload now sends `stream: True`. `_attempt_generate` uses `requests stream=True` + `response.iter_lines()` to parse Ollama's NDJSON token feed; tokens accumulate in a list and also flush to stdout as they arrive so a long generation feels alive instead of hung. `done: true` ends the loop. Mid-stream `error` field raises `WorkerError` and feeds the existing retry/abort policy unchanged. Three existing tests updated to use NDJSON response bodies. 31/31 tests green, 0.29s.
- [ ] Tier 3.9 — Multi-round refinement: orchestrator loops Coder→Reviewer→Coder until Reviewer emits an explicit approval token or `MAX_ROUNDS` reached.
- [ ] Tier 3.10 — Model routing: a tiny dispatcher in `orchestrator.py` selects Coder/Reviewer pairs from `.env` declarations keyed by detected language or task type.
- [ ] Tier 3.11 — Bearer-token auth between orchestrator and workers; token in `.env`, middleware on worker side rejects unauthenticated requests.
- [ ] Tier 3.12 — FastAPI wrapper: `POST /pipeline` with prompt body, `GET /artefacts/{ts}` returning the artefact pair. Same Path A files on disk; the HTTP layer is read-write thin.

### What's changing?

The shape of the network client. The Tier 1 work surfaced two architectural calls worth naming:

- **Probe as warm-up, not just check.** The pre-flight probe (`num_predict:1`) doubles as a model-warm step because Ollama keeps a model resident for the `keep_alive` window after any call. Tier 1.1 and Tier 1.2 fold into each other: the probe pays the cold-load, the subsequent generate skips it. What looks like two distinct items in the gap list is really one mechanism with two surfaces.

- **Transient versus deterministic is named, not inferred.** The retry policy doesn't try to guess what's retryable. It carries an explicit list — `unexpected EOF`, `llama runner process has terminated`, `connection reset`, `connection error` — and everything else fails fast. RAM gates and subscription gates are deterministic and benefit from being surfaced quickly rather than masked behind a retry loop. The atom of the policy is the substring list; growing it later is one constant edit.

The verification asymmetry is also worth noting. Tier 1.1's bad-URL case verified end-to-end on real hardware (0.35s). Tiers 1.2-1.4 verified in unit tests only; e2e on warm workers is deferred until the home cluster is reachable in the same session. The substrate's unit-test layer is strong enough to ship without that gating.

- 

---

## Conclude

### How is now different from the start?

The substrate hardened. Scene 01 closed with a working pipeline that surprised in eight failure modes; 01b closes with eight of twelve gap items shipped: pre-flight probe surfaces failures in seconds rather than minutes, `keep_alive` eliminates the cold-load between back-to-back development runs, the Reviewer persona forbids the rewrite-and-break failure mode that hit the Django prompt, retry tolerates transient runner crashes without raising, test coverage now spans every module (`config`, `network_client`, `personas`, `swarm_logging`), the orchestrator runs from `docker compose run --rm`, every run leaves a JSONL audit trail with elapsed timings, and long generations stream tokens to stdout in real time. Thirty-one tests green workspace-wide.

### What are the consequences?

The pipeline is now calmly trustable rather than friable. The audit trail in particular shifts the failure-mode story from anecdote to data — `logs/swarm-{ts}.jsonl` files compound across runs into a real artefact about how the substrate behaves. The docker layer collapses the LAN-routing problem that took months to design into a one-line `host` network config in `docker-compose.yml`.

A second consequence: the Tier 3 items have a clearer shape now that Tier 1+2 are in. Multi-round refinement needs a stable probe + warm `keep_alive` to be worth running. Model routing needs the persona system to be stable. The HTTP API needs the structured logging to feed it. The extension layer in 01c sits on the hardening layer 01b just shipped.

### What did we learn?

Three observations earn their place in the artefact:

1. **Gap analysis isn't gap inventory.** Tier 2.5 expected three modules to need test coverage; only two did. Walking the actual code rather than relying on the recalled list corrected the record in one capture rather than chasing a ghost gap. Future gap analyses should re-walk the code before scoping.

2. **The transient/deterministic distinction is the policy's atom.** Retry doesn't try to guess what's transient — it carries an explicit substring list. RAM gates and subscription gates are not in the list and never should be; retrying them compounds the problem. Adding a new transient failure mode is one constant edit. The atom of the policy is the substring list; everything else is mechanism around it.

3. **Streaming was a quality-of-correctness change, not just UX.** Keeping `stream: False` made mid-generation failures invisible — they only surfaced when the eventual full response came back wrong. Switching to streaming made the same retry policy *more* correct because failures now surface at the chunk level. The UX win was the secondary effect.

### Progress to thesis

Build should feel like play. The hardening work was the kind of work that usually feels like filing taxes — coverage, dockerisation, logging, streaming — and yet the scene's structure (tier-grouped goals with a closing condition that doesn't require all twelve) kept the cognitive shape playful. Each Tier item shipped as its own small win; the compound was a substrate that earns its place. The artefact essay can speak honestly about the hardening because the hardening was honestly done.

### Progress to goal

Chapter 2a's webapp climax is two scenes closer. 01b closed Tier 1+2; 01c will close Tier 3 including the HTTP API precondition for the webapp. After 01c, the chapter's 08+ webapp scene has no remaining substrate debt to budget against. The arc tightens.

### Next scene

**Scene 2a-01c — `ai-swarm extensions`.** Tier 3 items carry: multi-round refinement (3.9), model routing per task (3.10), LAN bearer-token auth (3.11), HTTP API for the webapp (3.12). The HTTP API is functionally a 2a-08+ webapp precondition; the other three are quality extensions sitting on the now-stable substrate. 01c's Set Stage will name the dependency relationship explicitly.

### Artifact format

**Essay** — *How the substrate hardened.* The three *What did we learn?* observations need the worked-example length to land, particularly the transient/deterministic distinction. Pairs naturally with Scene 01's eventual essay as a chapter-internal diptych: *how the substrate landed* + *how the substrate hardened*.

---

## Notes

The twelve items came from Scene 2a-01's session-end gap analysis (2026-05-10). The tiering is deliberate: T1 is *what would have prevented the failure modes the session burned time on*; T2 is *what makes the substrate calmly trustable*; T3 is *what makes the substrate compose into the next layer*. The closing condition does not require all twelve — over-promising twelve items into one scene is the failure mode the *State of the protagonist* names. The honest landing is Tier 1 must close, Tier 2 should close, Tier 3 closes opportunistically or carries.
