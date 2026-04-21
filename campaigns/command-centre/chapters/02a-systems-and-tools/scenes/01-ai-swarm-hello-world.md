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
artifact_format: 
artifact_file: 
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

- [ ] Scene opened, Set Stage signed off.

### What's changing?

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
