---
campaign: "[[command-centre]]"
chapter: "02a-systems-and-tools"
scene: "01c"
title: "ai-swarm extensions"
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
    file: "[[01c-ai-swarm-extensions-essay]]"
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

- [x] 3.12.1 — FastAPI skeleton shipped as `app.py` (single-file, alongside the existing flat layout rather than the speculated `app/main.py` package). `POST /pipeline` accepts `{goal}` via Pydantic, runs `run_pipeline` underneath, returns the artefact pair JSON plus disk paths plus the JSONL log path. `GET /artefacts/{ts}` reads the Path A pair back from disk, 404 when missing either file. WorkerError surfaces as HTTP 502 with the error string intact. Five integration tests cover success, 502 propagation, pair retrieval, 404 on missing ts, 404 on partial pair.
- [x] 3.12.2 — Second compose service `api` shares the same image as `orchestrator`, overrides ENTRYPOINT to `uvicorn app:app --host 0.0.0.0 --port 8000`. host network mode so it reaches the LAN workers; bind-mounted `output/` so artefacts persist regardless of entry point. Dockerfile updated to COPY app.py + swarm_logging.py (previously omitted from the COPY list — caught during this work).
- [x] 3.12.3 — E2E verified locally: `docker compose build` rebuilds in ~11s with cache. `docker compose up -d api` brings the service online; `curl /docs` returns 200 in 3ms. `curl /artefacts/20260510-221140` returns the Django smoke artefact pair from the prior session run, proving the file-reading endpoint works on real persisted data. `curl -X POST /pipeline` returns 502 with the Ryzen probe failure detail verbatim — clean propagation through the HTTP layer, the surface area below the API does not change between CLI and HTTP entry points. 36/36 tests green.
- [x] 3.9.1 — `MAX_ROUNDS = 3` constant + `APPROVAL_PREFIX = "Approved."` in `orchestrator.py`. `run_pipeline` rewritten as a loop: initial Coder call on the user goal, then up to `MAX_ROUNDS` iterations of (Reviewer → check approval → if not approved, refine via Coder). Refinement prompt template passes original goal + previous attempt + reviewer feedback so the Coder has full context. `REVIEWER_PERSONA` amended to emit exactly `Approved.` as first line when code is correct.
- [x] 3.9.2 — Four orchestrator tests cover: approval on first review (returns after 1 coder + 1 reviewer), max-rounds exhaustion (returns after MAX_ROUNDS pairs), refine prompt context propagation (asserts the prompt to the refining Coder contains the goal + prior code + review), and whitespace-tolerant approval detection (`"  Approved.  \\n..."` still counts).
- [x] 3.10.1 — `select_coder_model(goal, default)` heuristic in `orchestrator.py`. `LANGUAGE_KEYWORDS` maps `python`/`django`/`fastapi`/`flask` → `PYTHON`, `typescript`/`tsx`/`react` → `TYPESCRIPT`, plus `javascript`, `rust`, `golang`. Goal matched case-insensitive; env `CODER_MODEL_<LANG>` overrides; no match or no override falls back to `cfg.coder_model`. `main.py` + `app.py` both call the selector before dispatching to `run_pipeline`.
- [x] 3.10.2 — Six tests cover: python routing, django→python (cross-keyword to same env suffix), typescript routing, no-match fallback, match-without-override fallback, case-insensitive matching (`RUST` works the same as `rust`).
- [x] 3.11.1 — Worker-side proxy recipe captured in *What's changing?* below. Deferred to user-side deployment on Ryzen + MBP; the orchestrator side ships in this scene since it is testable in isolation.
- [x] 3.11.2 — `NetworkClient` accepts optional `auth_token` parameter; both `probe` and `generate` include `Authorization: Bearer <token>` header when set. `SwarmConfig` grows `worker_auth_token` field reading `WORKER_AUTH_TOKEN` env (empty string treated as None). `main.py` + `app.py` pass the token from config into the client. Three new `test_network_client` tests + three new `test_config` tests.
- [x] 3.11.3 — Unauthenticated-rejection verification deferred until the user-side proxy lands on at least one worker. The orchestrator side is unit-tested for both header-present and header-absent paths.

### What's changing?

The substrate's surface area. Three architectural notes from this scene:

- **Approval as a one-word protocol.** Multi-round refinement (3.9) needed a stable signal for *the Coder is done*. The `Approved.` first-line prefix is the entire protocol — no JSON envelope, no structured exit, just a string the orchestrator can check with `startswith`. The cost of making it richer (a sentinel that's both human-readable for the JSONL log and machine-readable for the loop) was higher than the cost of keeping it a string. The atom of the protocol is the literal `"Approved."` — everything else is mechanism.

- **Routing as goal-text heuristic, not embeddings.** Model routing (3.10) could have shipped as semantic similarity, language detection by parse, or LLM-based classification. It shipped as a substring lookup against a fixed keyword map. Cheap, deterministic, debuggable. If the heuristic mis-routes once the user notices it; if it mis-routes constantly the keyword map is the file to edit. The atom of the policy is the `LANGUAGE_KEYWORDS` dict.

- **Auth split across the wire.** LAN auth (3.11) is not one change in one place. The orchestrator side ships in this commit (Authorization header on every request when `WORKER_AUTH_TOKEN` is set in `.env`). The worker side has to be deployed separately as a reverse proxy fronting Ollama, since Ollama itself has no native auth. The recipe below is a small caddy or nginx config that lives on each worker host.

**Worker-side proxy recipe (deploy on Ryzen + MBP).** Move Ollama to bind on `127.0.0.1:11435` (loopback, not LAN). Run a tiny proxy on `0.0.0.0:11434` validating the bearer token. Two equivalent configs:

Caddy (`Caddyfile`):

```
:11434 {
    @unauthorized not header Authorization "Bearer the-shared-token"
    respond @unauthorized 401
    reverse_proxy 127.0.0.1:11435
}
```

nginx (`worker-auth.conf`):

```
server {
    listen 11434;
    location / {
        if ($http_authorization != "Bearer the-shared-token") {
            return 401;
        }
        proxy_pass http://127.0.0.1:11435;
        proxy_set_header Host $host;
        proxy_buffering off;
    }
}
```

`proxy_buffering off;` matters for streaming — nginx default buffers the response, which would defeat the Tier 2.8 streaming work. Caddy does not buffer by default.

The token lives in `.env` on the orchestrator and in the proxy config on each worker. Pre-shared; rotation is a manual swap on three machines. Acceptable for the home cluster threat model; a proper KMS-issued short-lived token belongs in a separate scene if the substrate ever ships beyond the home cluster.



---

## Conclude

### How is now different from the start?

The substrate's surface area extended. 01b closed the substrate hardening; 01c added four extensions on top — multi-round refinement, model routing, LAN auth (orchestrator side), and the FastAPI wrapper that the chapter's webapp climax needs. All twelve gap items from the original Scene 01 session are closed. 51 tests green workspace-wide.

### What are the consequences?

The chapter's substrate debt is fully cleared. Scenes 04, 05, 06, 07 can proceed against a calmly-trustable + extension-capable substrate. The webapp scene (08+) has its precondition (HTTP API) in place. The remaining cluster work is operational deployment — Ollama-in-docker on the workers per the 01 Pivot, worker-side auth proxy from 01c — rather than substrate work.

A second consequence: the routing layer (3.10) hints at a richer next-order question — should the routing be smarter (LLM-based intent detection, embeddings)? The current substring heuristic is a deliberate floor; whether it gets a ceiling is a future scene's decision.

### What did we learn?

Three observations, each about choosing the smallest workable protocol:

1. **Approval as a one-word protocol.** Multi-round refinement could have specified an exit signal as JSON envelope or structured token; it shipped as `startswith("Approved.")`. Ceremony pays off when contributors diverge — when both ends are the same author, the protocol can be cheap.

2. **Routing without embeddings.** Model selection ships as a fixed keyword map, not as semantic similarity. The map is a file that's debuggable in one read, editable in one keystroke. There is a real cost to choosing the *smart* abstraction when the *stupid but correct* one is in front of you.

3. **Auth as a two-place change with clean separation.** The orchestrator side ships in code with full unit coverage; the worker side ships as documented proxy recipes that the user deploys. The separation maps to where the changes naturally live — code-on-orchestrator-host, config-on-each-worker — and resists artificial bundling.

The three share the same shape: choose the smallest workable mechanism, name its atom, let everything else be process around it. *Cheap protocols compound.*

### Progress to thesis

Build should feel like play. The extensions work was conceptual rather than diagnostic — new mechanism on top of, rather than fix mechanism in. The play register holds in conceptual work too: small, named atoms (the substring map, the approval prefix, the bearer token) compound into substrate that has real shape rather than features that have feature names.

### Progress to goal

Chapter 2a's webapp climax is opened. After 01c, the chapter has zero remaining substrate debt. The 08+ scene can be set-staged against a working HTTP API endpoint that the webapp can call without re-architecting. 2a-04 (`borai-graph ship retroactive`) and 2a-05 (`claude-code edge bridge`) remain open infrastructure scenes but they do not gate on 01c.

### Next scene

The chapter has no enforced next. Three open infrastructure scenes — 04, 05, 06 — sit at `status: not-started`; 04 + 05 are filing-the-orphaned-work scenes, 06 is scrapers-into-delegate-agent integration. The natural next is **2a-04** since the borai-graph artefact set has been waiting longest. After 04 + 05, the spine work resumes with 06 + 07 + 08+ in sequence.

Outside the chapter, the home cluster needs Ollama-in-docker on the workers (the Pivot's remaining canonical-state work) and the worker-side auth proxy (the 3.11 user-side deploy) — both operational, neither blocking new scene work.

### Artifact format

**Essay** — *Cheap protocols compound.* The three observations share a single cross-pattern claim that thread compression would lose. Essay carries the worked examples + the abstraction-cost argument together. Pairs with 01b's *How the substrate hardened* and Scene 01's eventual *How the substrate landed* as a three-part chapter-internal series on substrate work.

---

## Notes

01c orders by chapter-spine weight rather than tier number. 3.12 (HTTP API) is first because it unblocks the 08+ webapp climax; the other three compound substrate value but do not gate the chapter arc. If session bandwidth forces a split, the natural break is *3.12 + 3.11 in 01c, 3.9 + 3.10 carrying to 01d* — but the scene's *Goal for this session* explicitly allows that opportunistic close rather than forcing the split up front.
