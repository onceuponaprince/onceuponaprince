---
campaign: "[[command-centre]]"
chapter: "02a-systems-and-tools"
scene: 01
title: "ai-swarm hello-world"
status: in-progress
date_opened: 2026-04-21
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
  - distributed-inference
  - home-cluster
  - first-run
---

# Scene 2a-01 — ai-swarm hello-world

*Chapter 2a — Systems and tools · Campaign: [[command-centre]]*

First scene of the systems-and-tools branch. The home cluster closes its first loop: orchestrator on this machine, coder on the Ryzen, reviewer on the MBP, a single round-trip from prompt to reviewed output.

---

## Set the Stage

### How did we get here?

Scene 05 catalogued `ai-swarm-infra` as a set of Python skeletons — architectural claim, not live infrastructure. The two-task-force dispatch session (`docs/handoffs/2026-04-21-two-task-force-dispatch-close.md`) upgraded those skeletons into runnable code: a `SwarmConfig` loader, a `NetworkClient` with explicit exception types, a two-stage `Orchestrator` (Coder → Reviewer), a `main.py` CLI with timestamped output writes, 5 passing tests, and three bootstrap tutorials (Windows-Coder, macOS-Reviewer, Linux-Orchestrator). The branch `feature/ai-swarm-infra-impl` is ready-to-PR pending a first end-to-end run. Nothing has actually *run* yet across real hardware.

### Where are we going?

A first successful round-trip. The orchestrator on this machine dispatches a trivial prompt — *write a Python function that adds two numbers* — over the home LAN to the Ryzen running `qwen2.5-coder:7b`. The Coder returns code. The Orchestrator forwards the Coder's output to the 2019 MBP running `llama3.2:3b`. The Reviewer returns annotated output. The Orchestrator writes the result to `./output/swarm-YYYYMMDD-HHMMSS.txt`. The point is the network + two-model pipeline *working end-to-end*, not the quality of the generated code. On success, the scene closes with a PR from `feature/ai-swarm-infra-impl` into `main` and a merge.

### State of the world (project context)

BorAI monorepo. `ops/ai-swarm-infra/` scaffolded, tested in isolation, committed on `feature/ai-swarm-infra-impl`. Three machines:

- **Ryzen 5 7535HS (Coder).** Ollama + `qwen2.5-coder:7b` pulled. `OLLAMA_HOST=0.0.0.0:11434` on boot. Firewall exposing :11434 on LAN. Static LAN IP captured in `.env`.
- **2019 Intel MBP (Reviewer).** Ollama via homebrew + `llama3.2:3b` pulled. `launchctl` plist sets `OLLAMA_HOST=0.0.0.0:11434` on login. `pf` firewall allows :11434. Thermal throttling is a live constraint — sustained load may require reboot cycles.
- **This Linux box (Orchestrator).** `uv sync` in `ops/ai-swarm-infra/`. `.env` carries both worker URLs. Runs `uv run python main.py "prompt"`.

Home LAN; all three on the same subnet. No routing, no NAT, no reverse tunnels. If the network is the wrong thing, everything else is moot.

### State of the hero ([[solo-thesis-holder]])

The audience for the eventual artifact. Suspicious of home-cluster stories: *why would I care about your three machines?* Earns their read only if the scene's narrative beat lands for someone without three machines. The universalisable beat is orchestration tempo — distributed inference is a specific proof of a more general thesis, that a single operator can now dispatch specialised workers the way small teams used to. The hardware is incidental; the pattern is the point.

### State of the protagonist ([[prince]])

Has the three machines tonight. Has the tutorials committed. Has the code tested in isolation. Is about to leave the orchestrator's known territory — single-file codebases, single-machine execution — and enter the territory of *inter-machine fault surfaces*: firewall rules, stale IPs, model-not-loaded errors, Ollama version drift across three operating systems. First-time home-LAN distributed inference in this codebase. Expect the first run to fail; the scene's real test is whether the *second* run succeeds and whether the failure mode is legible rather than silent.

### This moment in relation to goals

Chapter 2a's first scene. Without a successful round-trip the chapter's arc is abstract; the climax (webapp MVP) has no infrastructure to rest on. With it, the whole chapter becomes concrete: infra exists, is reachable, dispatches work, returns results. Every subsequent 2a scene (Grok scraper, webapp) assumes this scene landed.

### Why now?

The hardware is available tonight. The code + tests + tutorials are ready. The PR is gated on a first end-to-end run. No further orchestrator work can advance this — the next action has to be a manual machine-setup sequence by the founder. This is the first 2a scene that ends when the *founder* closes the loop, not when the orchestrator does.

---

## Progress the moment

### Goal for this session

- Ryzen Coder reachable from Orchestrator over LAN (`curl $CODER_URL/api/tags` returns).
- MBP Reviewer reachable from Orchestrator over LAN (`curl $REVIEWER_URL/api/tags` returns).
- `uv run python main.py "write a python function that adds two numbers"` completes without error.
- Output file written to `ops/ai-swarm-infra/output/swarm-*.txt` with both Coder and Reviewer sections.
- PR opened from `feature/ai-swarm-infra-impl` to `main` (title + body drafted); merged on approval.

### Moment-by-moment capture

- [x] Scene opened, Set Stage signed off (2026-04-21).
- [x] Ollama installed on the MBP via homebrew per the original plan (2026-04-21 → 2026-05-01).
- [x] Decision taken to containerise the LLM runner across all three machines rather than continue native Ollama installs per OS (2026-05-01). See Pivot below.
- [x] Docker installed on the Ryzen and on the MBP between 2026-05-01 and 2026-05-10. Host-level prerequisite for the Pivot's canonical state is now in place on both workers.
- [ ] Docker + Ollama image running on Ryzen (Coder), model pulled inside container, :11434 reachable on LAN.
- [ ] Docker + Ollama image running on MBP (Reviewer), model pulled inside container, :11434 reachable on LAN.
- [x] Native-Ollama fallback path taken on 2026-05-10 to unblock the round-trip ahead of the docker-runner rebuild. The two `Docker + Ollama image running` checkboxes stay open — the Pivot's canonical state hasn't moved, only this session's route around it.
- [x] Reachability verified from Orchestrator: `curl $CODER_URL/api/tags` returns the Ryzen catalogue; `curl $REVIEWER_URL/api/tags` returns the MBP catalogue. Ryzen ICMP is silently dropped by Windows firewall while TCP/HTTP on :11434 passes — a layer-3-versus-layer-4 surprise worth naming.
- [x] Model selection diverged from Set Stage's `qwen2.5-coder:7b` + `llama3.2:3b`. Three RAM gates and one subscription gate later, settled on `ministral-3:3b` (Coder, Ryzen) + `deepseek-r1:1.5b` (Reviewer, MBP, after the 7b variant failed Ollama's hard upfront RAM check at 4.3 GiB-needs vs 1.2 GiB-available). The 2019 Intel MBP genuinely cannot host a usable local Reviewer above ~1.8B without app-shutdown discipline — that is the hardware ceiling, not a configuration issue.
- [x] Path A artifact persistence shipped this session: `orchestrator.run_pipeline` now returns `tuple[str, str]`, `main` writes a paired `swarm-{ts}-coder.txt` + `swarm-{ts}-reviewer.txt`. The Coder's raw output is preserved alongside the Reviewer's critique rather than overwritten. Tests updated to assert the pair. 5/5 green.
- [x] Round-trip: three smoke prompts (fibonacci with memoisation, CSV threshold-filter, Django REST `/login` with JWT) ran end-to-end. Six artefact files in `output/`. Cold-load on the first prompt cost 4:55; warm runs settled at 1:21–1:46. The pipeline is alive.
- [x] Honest assessment of output quality: the Coder's output is usable on all three prompts. The Reviewer's output is usable on prompt 1 (fib), passable on prompt 2 (CSV), and *broken* on prompt 3 (Django) — `deepseek-r1:1.5b` confidently rewrote the working code into something that imports `AllowAny` from the wrong module and references `AbstractUser.objects.get` as if it were a manager. Format of review preserved, capability for review not. Captured as a feedback memory for future model selection.
- [x] PR-step reconciled with reality: `feature/ai-swarm-infra-impl` merged off-stage earlier in the chapter's life. Tonight's Path A increment (paired coder + reviewer artefact files) lands directly on `main` as `feat(ai-swarm-infra): persist coder and reviewer artifacts`. The "PR from feature branch" ritual the scene anticipated did not survive the chapter's actual git history; the substance — code merged, tests green — did.

### What's changing?

The setup path. The original plan was three OS-specific Ollama installs (homebrew on macOS, scoop on Windows, curl-install on Linux), each with its own firewall ritual and `OLLAMA_HOST` configuration. After installing on the MBP, the cost of maintaining three setup playbooks across three drift surfaces became visible. Containerising the LLM runner — same Docker image, same exposed port, same model-pull commands inside the container — collapses the variance.

The thesis beat is unaffected. Orchestration tempo remains the universalisable pattern; the hardware was always incidental. If anything the docker-first path makes the scene's eventual artefact stronger: *one repeatable container image* is more legible to the audience than *three OS-specific setup posts.*

What the 2026-05-10 session added is a second, narrower observation: model selection on RAM-constrained hardware is its own kind of orchestration. The session burned through five model candidates before the pipeline closed — two RAM-gated 9B-class models, two subscription-gated cloud passthroughs, and the eventual 3B / 1.5B local pair. Ollama gates *upfront* on resident-RAM rather than swap-thrashing through inference, which is the right behaviour but means *pulled* and *callable* are not the same state. The scene's artefact should name that distinction. It is the kind of thing the audience will only learn by hitting it themselves; surfacing it is what earns the post its read.

---

## Pivot — 2026-05-01

**Trigger.** First setup pass on the MBP (native Ollama via homebrew, per Set Stage's plan) surfaced the cost of three different OS-level installs: macOS `launchd` plist, Windows service, Linux `systemd`, each with its own firewall and `OLLAMA_HOST` ritual. Three operating systems, three setup playbooks, three drift surfaces. Containerising the runner once and shipping the same image to all three machines collapses that variance into one playbook.

**Old → New.** Native Ollama on each machine → Docker container running Ollama on each machine. Same image, same `OLLAMA_HOST=0.0.0.0:11434`, same `ollama pull` commands inside the container. Host-OS responsibility shrinks to: Docker installed, port :11434 exposed on LAN.

**Carries forward.** Orchestrator / Coder / Reviewer roles. Model choices (`qwen2.5-coder:7b` on Ryzen, `llama3.2:3b` on MBP). Home-LAN subnet topology. The `feature/ai-swarm-infra-impl` branch and its tested-in-isolation Python code. The five-bullet goal for the session — adjusted only in *how* it gets met, not *what* gets met. The thesis beat (orchestration tempo as the universal pattern).

**Supersedes.** The three OS-specific bootstrap tutorials (Windows-Coder, macOS-Reviewer, Linux-Orchestrator) as the canonical setup path — they remain valid as native fallbacks but are no longer the recommended route. The "Ollama + homebrew / scoop / curl-install" sub-passages of Set Stage's State of the world.

---

## Conclude

*Draft — for founder edit before status flip.*

### How is now different from the start?

The pipeline exists in motion rather than in proof. Three machines on the home LAN now dispatch a prompt, return code, review code, and persist both artefacts to disk in roughly ninety seconds when warm. The configuration is captured in `.env`; the Path A pair (`swarm-{ts}-coder.txt` + `swarm-{ts}-reviewer.txt`) lands in `output/`; the surrounding test suite still goes green. None of that was running on 2026-04-21 when the scene opened. The orchestration tempo of the home cluster is a fact rather than a claim.

### What are the consequences?

Subsequent 2a scenes rest on a real substrate. The Grok scraper, the delegate-agent integration, the Command Centre webapp — each had been planning against *`ai-swarm-infra` exists, somewhere*. They now plan against an endpoint that responds.

A second consequence: the model-selection surface is now load-bearing. The pipeline runs, but it runs on `ministral-3:3b` + `deepseek-r1:1.5b` rather than the Set Stage's planned `qwen2.5-coder:7b` + `llama3.2:3b`, because Ollama's resident-RAM check refused the heavier choices. The hardware ceiling — 16 GB on each worker, of which 1.3 to 3.6 GiB was free after OS overhead — is a real constraint the chapter will need to budget around rather than wish away.

### What did we learn?

Three observations earn their place in the artefact:

1. **Pulled is not callable.** Ollama gates inference on resident-RAM upfront and refuses cleanly rather than swap-thrashing. The check is honest but means a successful `ollama pull` tells you nothing about runtime feasibility. The scene burned through five model candidates before the pipeline closed — two RAM-gated, two subscription-gated, one that worked.

2. **Cloud passthroughs are gated invisibly.** Models tagged `:cloud` in `/api/tags` are *visible* but not necessarily *callable*. `kimi-k2.6:cloud` and `deepseek-v4-pro:cloud` both returned `model requires a subscription` only on the first generate call, not on tag enumeration. The `/api/tags` endpoint is a catalogue, not a capability list.

3. **Small distilled R1 models fabricate confident broken code.** `deepseek-r1:1.5b` in the Reviewer role produced a structurally plausible Django REST view that imports `AllowAny` from the wrong module and treats `AbstractUser` as a manager. The format of code review survived the distillation; the capability did not. The Reviewer persona will need either a larger model or a critique-only constraint to be load-bearing.

### Progress to thesis

Build should feel like play. Tonight's session was play — five model candidates, two cache-truncation rabbit holes, one ICMP-but-not-TCP surprise from Windows firewall, three smoke prompts producing six artefact files. The narrative writes itself because the dispatch-and-fail-and-retry loop *is* a narrative. The thesis says play should write the story; this scene's debugging trace is exactly the kind of story that wouldn't exist under a hidden-success build process.

### Progress to goal

Chapter 2a's climax (webapp MVP) is now one substrate closer. Every subsequent 2a scene presumed this scene's success; the presumption is no longer a debt. The chapter arc remains in shape.

### Next scene

Scene 2a-04 (`borai-graph ship retroactive`) is the next open infrastructure scene; 2a-05 (`claude-code edge bridge`) follows. Both can proceed against a working swarm. A near-term follow-up inside this scene's substrate — pre-flight health probe, `keep_alive` on the generate payload, Reviewer persona tightening, retry on transient runner crashes — is captured as Tier 1 gaps in the session's parallel gap analysis; whether to address them inside this scene or open a sibling scene is a founder call.

### Artifact format

**Essay.** The model-gating debugging trace plus the orchestration-tempo thesis beat together carry more substance than a thread can compress without losing the *pulled is not callable* / *visible is not callable* distinctions that earn the post its read. Thread is the natural fallback if audience response on the essay tells us we over-spent.

---

## Notes
