---
campaign: "[[command-centre]]"
chapter: "02a-systems-and-tools"
scene: "01c"
title: "ai-swarm extensions"
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
  - multi-round
  - model-routing
  - lan-auth
  - http-api
  - webapp-precondition
---

# Scene 2a-01c — ai-swarm extensions

*Chapter 2a — Systems and tools · Campaign: [[command-centre]]*

Successor to 01b. Tier 3 items carry forward — the extensions that turn a calmly-trustable substrate into a substrate the 2a-08+ webapp can call. Four items, ordered by chapter-spine weight rather than by tier number.

---

## Set the Stage

### How did we get here?

Scene 01 stood up the swarm. Scene 01b hardened it — pre-flight probe, `keep_alive`, Reviewer persona, retry, test coverage, dockerised orchestrator, structured logging, streaming. Eight of twelve gap items closed; four carry. This scene takes the four.

The four are not equal in their relationship to the chapter arc. One (HTTP API) is functionally a precondition for the climax — without it, the 2a-08+ webapp scene cannot open. The other three (multi-round refinement, model routing, LAN auth) are quality extensions that compound the substrate's value but do not unlock the climax. The scene orders by spine weight, not by tier number.

### Where are we going?

A substrate the webapp can call without re-architecting. Concretely:

1. **HTTP API (carrying from 3.12).** A thin FastAPI wrapper exposing `POST /pipeline` (accepts a goal, runs the orchestrator, returns the artefact pair) and `GET /artefacts/{ts}` (returns the persisted coder + reviewer files by timestamp). Same Path A files on disk; the HTTP layer is read-write thin. This unblocks 2a-08+.
2. **LAN bearer-token auth (carrying from 3.11).** Workers currently accept any request on the LAN — Ollama doesn't ship native auth. Solution: a small reverse-proxy layer (caddy or nginx) in front of each worker's Ollama, validating a bearer token. Orchestrator carries the token via `.env`. Defends against accidental cross-LAN exposure if the home network changes shape.
3. **Multi-round refinement (carrying from 3.9).** Orchestrator loops Coder→Reviewer→Coder until the Reviewer emits an explicit approval token (or `MAX_ROUNDS` reached). Approval detection by pattern match on the Reviewer's first-line: "Approved." vs. a numbered critique list. Adds a maximum-round constant; respects 01b's retry and persona work.
4. **Model routing per task (carrying from 3.10).** A small dispatcher in `orchestrator.py` selects Coder/Reviewer pairs from `.env`-declared routes keyed by detected language or task type. e.g. `CODER_MODEL_PYTHON`, `CODER_MODEL_TYPESCRIPT`, fallback `CODER_MODEL`. Language detection by simple heuristics on the user goal text.

### State of the world (project context)

`ops/ai-swarm-infra/` on `borai` `main` at the close of 01b:

- `main.py`, `orchestrator.py`, `network_client.py`, `config.py`, `personas.py`, `swarm_logging.py` — all green, 31 tests.
- `Dockerfile`, `docker-compose.yml`, `.dockerignore` — orchestrator dockerised. `docker compose run --rm orchestrator "<prompt>"` is the canonical invocation.
- `keep_alive: "30m"` resident on probe + generate payloads; retry policy tolerates the four named transient errors; structured JSONL audit trail per run.
- Worker hosts: Ryzen + MBP, Ollama running natively (docker installed but the canonical containerised-Ollama path from the Pivot is still pending — orthogonal to 01c's scope).

### State of the hero ([[solo-thesis-holder]])

The hero now wants extension capability, not reliability. 01b earned them a substrate they can forget about; 01c earns them a substrate they can compose against. The dominant objection shifts: from *will this surprise me at 11pm Friday?* to *can I actually use this for the next thing without re-architecting?* The scene's read for them depends on whether the HTTP API and routing layer land in a shape that survives contact with whatever the webapp scene actually needs — that is, whether the extensions are correctly abstracted or merely correctly implemented.

### State of the protagonist ([[prince]])

Confident from 01b's close, with a calibrated sense of how the substrate behaves under stress. The risk in this state is over-engineering: now that the substrate is solid, the temptation is to build the extensions to a higher bar than the webapp will actually call for. The scene budgets against that by ordering the spine-weight item (HTTP API) first and making the other three deliver-or-defer decisions based on what the API design actually surfaces.

### This moment in relation to goals

01c is the last 2a substrate scene before the webapp climax. After 01c, the chapter has no remaining substrate debt. The 2a-04 (`borai-graph ship retroactive`) and 2a-05 (`claude-code edge bridge`) scenes can proceed in parallel; they do not gate on 01c. Scenes 06, 07, 08+ all stand on the post-01c substrate.

### Why now?

The 01b substrate is fresh and the model of *how it behaves* is still loaded. The HTTP API and routing layer are best designed against a substrate the protagonist understands in detail; deferring 01c would cost re-loading that model. Multi-round refinement (3.9) specifically depends on the retry + `keep_alive` work landing first, which it has. Now is when 3.9 is cheapest to design — the retry policy is two days old in protagonist memory.

---

## Progress the moment

### Goal for this session

**Closing condition for the scene:** HTTP API (3.12) shipped end-to-end with verified `POST /pipeline` and `GET /artefacts/{ts}` against the home cluster. LAN auth (3.11) shipped on at least one worker. Multi-round refinement (3.9) and model routing (3.10) ship if the API design surfaces them naturally, otherwise carry to a sibling 01d.

By-item-success criteria:

- **3.12 (must-land):** `uvicorn` (or similar) entry runs `app.main:app`; `curl -X POST http://localhost:8000/pipeline -d '{"goal":"..."}'` returns the artefact pair as JSON; `curl http://localhost:8000/artefacts/{ts}` returns the coder + reviewer files for that run. Uses the existing `run_pipeline` underneath — no orchestrator changes needed.
- **3.11 (should-land):** Worker-side reverse-proxy (caddy on the MBP and Windows simultaneously, since docker is installed on both) validates `Authorization: Bearer <token>`. Orchestrator's `NetworkClient` adds the header from `.env`'s `WORKER_AUTH_TOKEN`. Unauthenticated request returns 401.
- **3.9 (opportunistic):** `MAX_ROUNDS = 3` in orchestrator; Reviewer system prompt amended to prepend `Approved.` on a clean review. Loop: dispatch Coder → Reviewer; if Reviewer's first line is `Approved.`, return; else feed Reviewer's critique back to Coder and round again. Token detection by `startswith("Approved.")`.
- **3.10 (opportunistic):** `CODER_MODEL_<LANG>` env keys read by a small `select_coder_model(goal)` function in `orchestrator.py`. Heuristic language detection: substring match on the goal for "python", "typescript", "rust", etc.; fallback to `CODER_MODEL`.

### Moment-by-moment capture

- [ ] 3.12.1 — FastAPI app skeleton (`app/main.py`) with `POST /pipeline` and `GET /artefacts/{ts}` endpoints; integration test against mocked NetworkClient.
- [ ] 3.12.2 — `uvicorn` ENTRYPOINT alternative in Dockerfile (multi-stage or compose profile so CLI and API modes are both invokable from compose).
- [ ] 3.12.3 — E2E verification: `curl POST /pipeline` triggers a real round-trip and returns the artefact pair.
- [ ] 3.11.1 — Reverse-proxy choice (caddy vs nginx) and worker-side container compose entry.
- [ ] 3.11.2 — `NetworkClient` carries `Authorization` header from `WORKER_AUTH_TOKEN` env; existing tests adapted.
- [ ] 3.11.3 — Unauthenticated probe against the proxied worker returns 401, verifying the policy.
- [ ] 3.9.1 — `MAX_ROUNDS` constant + loop in `orchestrator.run_pipeline`; Reviewer persona amended to prepend `Approved.` on clean review.
- [ ] 3.9.2 — Test that orchestrator stops at first `Approved.` line; test that orchestrator iterates up to MAX_ROUNDS otherwise.
- [ ] 3.10.1 — `select_coder_model(goal)` heuristic in `orchestrator.py`; `.env` schema extended with `CODER_MODEL_<LANG>` keys.
- [ ] 3.10.2 — Test that "write a Python function..." selects `CODER_MODEL_PYTHON`; test that an unrecognised language falls back to `CODER_MODEL`.

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

01c orders by chapter-spine weight rather than tier number. 3.12 (HTTP API) is first because it unblocks the 08+ webapp climax; the other three compound substrate value but do not gate the chapter arc. If session bandwidth forces a split, the natural break is *3.12 + 3.11 in 01c, 3.9 + 3.10 carrying to 01d* — but the scene's *Goal for this session* explicitly allows that opportunistic close rather than forcing the split up front.
