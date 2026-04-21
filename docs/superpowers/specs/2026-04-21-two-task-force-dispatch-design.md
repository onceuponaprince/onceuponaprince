---
date: 2026-04-21
topic: two-task-force-dispatch
status: approved
session: build session 2026-04-21 (post-Scene-05 close)
related:
  - docs/handoffs/2026-04-21-misled-task-7-handoff.md
  - docs/superpowers/plans/2026-04-20-misled-ethos-page.md
  - .claude/PROGRESS.md
  - campaigns/command-centre/chapters/01-origin/scenes/04-misled-ethos-page.md
  - campaigns/command-centre/chapters/01-origin/scenes/05-source-ai-swarm-infra-catalogue.md
---

# Two-Task-Force Dispatch — Design Spec

Parallel orchestration of two subagent task forces working simultaneously in isolated git worktrees: one to close the Misled Scene 04 to ship-minus-send state; one to bring ai-swarm-infra from scaffold to first-runnable plus bootstrap-ready state. Delegation pattern is Approach C (hybrid staged dispatch) with external LLM CLIs (Gemini, Copilot, Cursor) handling generative sub-tasks per the `delegate-agent` routing table.

---

## 1. Goal state by end of day 2026-04-21

### Misled Task Force deliverables

1. Smoke-test report on `https://misled.vercel.app/` covering all eight sections, form interaction, console errors.
2. Supabase `subscribers` table migration SQL plus schema applied.
3. Resend double-opt-in wired: API route, confirmation email template, env vars scaffolded.
4. Cron-based deletion of unconfirmed rows older than seven days (Vercel Cron or Supabase Edge Function; decided during Phase 2).
5. Draft client message in Prince's voice, ready for his final pass.
6. Draft Scene 04 Conclude block (five-beat, voice-matched) ready for his edit.

Scene 04 concludes the moment Prince sends the client message. The mobile viewport check (375px on a real device) remains his responsibility. `misled.london` domain registration stays deferred until explicit sign-off.

### ai-swarm-infra Task Force deliverables

1. Runnable Python pipeline: `main.py "task string"` dispatches to Coder node, pipes output to Reviewer node, saves final reviewed code to `output/`.
2. Hardened `network_client.py` with timeout handling, retries, structured error returns.
3. `orchestrator.py` with explicit Coder-then-Reviewer state machine.
4. `.env.example` plus config loader for worker IPs and model names.
5. Updated `pyproject.toml` with real dependencies (requests, python-dotenv, rich).
6. `README.md` updated with run instructions and configuration section.
7. **Three bootstrap tutorials**:
   - Windows (Ryzen 5 7535HS, Coder node): Ollama install, `qwen2.5-coder:7b` pull, firewall rules for port 11434, bind on `0.0.0.0`, LAN IP discovery.
   - macOS (2019 Intel MacBook Pro i9, Reviewer node): Ollama install, `llama3.2:3b` pull, `launchctl` configuration, pf firewall rules, thermal management notes given the Intel hardware.
   - Linux (Ryzen 5 36GB, Orchestrator host): uv install, Python 3.11 virtualenv via uv, `.env` configuration, smoke test against workers.

The software plus tutorials ship today. Prince runs the tutorials tonight on the worker machines to close the loop. The Task Force does not attempt to SSH into the worker nodes.

---

## 2. Branch and worktree topology

| Task Force | Repo | Branch | Worktree path |
|---|---|---|---|
| Misled | BorAI (github.com/onceuponaprince/borai.cc) | `feature/misled-ethos-page` (existing, pushed) | `~/code/BorAI-misled-wt/` |
| ai-swarm-infra | BorAI | `feature/ai-swarm-infra-impl` (new, off `main`) | `~/code/BorAI-swarm-wt/` |
| Vault writes (both TFs) | build-in-public | `main` | `~/code/build-in-public/` (shared, serialised through orchestrator) |

**Rationale.** Worktrees isolate filesystem state so concurrent Cursor invocations cannot stomp on each other's staged changes. Both task forces operate inside BorAI because that is the authoritative monorepo per Scene 05 merges (PR #1 `ace243b`, PR #2 `35cc0a8`). `feature/misled-ethos-page` is the live Vercel preview source and must not merge to main. `feature/ai-swarm-infra-impl` branches off main because main already contains the merged scaffold.

**Filesystem constraint.** Vault writes (scene capture, this spec, any new artefacts) serialise through the orchestrator to avoid two Cursor instances editing `~/code/build-in-public/` at once.

---

## 3. Approach C: hybrid staged dispatch

### Phase 1 — Parallel state-mapping

Two Claude Code `Explore` subagents run concurrently, one per worktree, read-only.

**Misled explorer:**
- Inputs: `docs/handoffs/2026-04-21-misled-task-7-handoff.md`, `docs/superpowers/plans/2026-04-20-misled-ethos-page.md`, `apps/misled/` tree, `campaigns/command-centre/chapters/01-origin/scenes/04-misled-ethos-page.md`.
- Output: bounded task list for Phase 2 with exact file paths and delegation assignments, plus any deltas between the handoff and current code state.

**ai-swarm-infra explorer:**
- Inputs: `ops/ai-swarm-infra/` tree (scaffold state), `ops/ai-swarm-infra/README.md`, `campaigns/command-centre/chapters/01-origin/scenes/05-source-ai-swarm-infra-catalogue.md`.
- Output: bounded task list for Phase 2 with exact file paths, Ollama API endpoint shape, persona prompts verified against `personas.py`.

Neither explorer writes code. Both return under 300 words of structured output.

### Phase 2 — Parallel dispatch per routing table

The orchestrator (Claude Code main) fans out sub-tasks to external CLIs based on task type, per `~/.claude/commands/delegate-agent/references/routing-table.md`. Each CLI operates inside one worktree.

**Misled TF delegations:**

| Sub-task | Tool | Review gate |
|---|---|---|
| Smoke-test live preview (eight sections, form interaction, console) | Claude Code general-purpose subagent | None (read-only) |
| Supabase `subscribers` table migration SQL | Copilot | Tier 1 |
| Resend double-opt-in (API route + template + env + client wiring) | Cursor | Tier 2 (diff-reviewer) |
| Cron deletion of unconfirmed rows past seven days | Copilot | Tier 1 |
| Client message draft (British English, peer register) | Gemini | Tier 3 (Prince) |
| Scene 04 Conclude block draft (five-beat, voice-matched) | Gemini | Tier 3 (Prince) |

**ai-swarm-infra TF delegations:**

| Sub-task | Tool | Review gate |
|---|---|---|
| `pyproject.toml` dependencies (requests, python-dotenv, rich) | Copilot | Tier 1 |
| `network_client.py` implementation (timeout, retry, JSON handling) | Cursor | Tier 2 |
| `orchestrator.py` pipeline logic (Coder → Reviewer, state machine) | Cursor | Tier 2 |
| `main.py` CLI entry (argparse, `.env` loading, output file write) | Cursor | Tier 2 |
| `.env.example` plus config loader | Copilot | Tier 1 |
| `README.md` run and configuration section | Gemini | Tier 3 |
| Windows bootstrap tutorial (Ryzen 7535HS, Coder) | Gemini | Tier 3 |
| macOS bootstrap tutorial (2019 MBP, Reviewer) | Gemini | Tier 3 |
| Orchestrator host bootstrap tutorial (Linux) | Gemini | Tier 3 |

### Phase 3 — Review and consolidate

- `diff-reviewer` subagent reviews each Tier 2 Cursor output. PASS verdicts auto-apply. FLAG verdicts escalate to Tier 3 and await Prince.
- All Tier 3 Gemini outputs queue until Phase 3 close, then present to Prince in a single consolidated batch (two client-facing pieces, four docs).
- Orchestrator runs Misled's smoke-test report, cross-checks against the `apps/misled/` post-deploy expectations in the handoff, flags any regression.
- Orchestrator commits each Task Force's branch with atomic conventional commits (one logical change per commit) following global CLAUDE.md rules.

---

## 4. Orchestrator protocol

1. Orchestrator stays in main context; dispatches and monitors only.
2. Tier 1 Copilot outputs validate against Tier 1 checklist (scope, deps, conventions, secrets, syntax) then auto-apply. Log `[delegate-agent] Tier 1 applied: ...`.
3. Tier 2 Cursor outputs route through `diff-reviewer` subagent per `~/.claude/commands/delegate-agent/references/review-gates.md`. Apply on PASS; escalate on FLAG.
4. Tier 3 Gemini outputs collect in a batch; present to Prince at end of run with one-line context note each.
5. Context pressure: if orchestrator context crosses 40%, any remaining generative sub-task forces to external delegation regardless of original routing. Hard ceiling at 60%: orchestrator pauses and alerts Prince before any direct generation.
6. No em-dashes in delegation prompts or log lines per delegate-agent voice rules.
7. Delegation prompts stay under 800 tokens to keep orchestrator context cost low.

---

## 5. Out of scope (hard limits)

These are deliberately excluded. The orchestrator refuses to take them even if a subagent suggests otherwise.

1. **Mobile viewport check**: Prince only, on a real phone. Browser emulation at 375px is not equivalent.
2. **Send the client message**: Prince only, after final pass. The agent drafts; Prince sends.
3. **Register `misled.london`**: deferred until explicit sign-off. Not today.
4. **Merge `feature/misled-ethos-page` to `main`**: forbidden per Task 7 handoff. This branch is the live preview source.
5. **SSH into Ryzen 7535HS or 2019 MBP**: the orchestrator cannot reach those machines. Prince runs the bootstrap tutorials himself.
6. **End-to-end swarm live-run verification**: only possible after Prince has completed the worker bootstraps. The Task Force's deliverable is software plus tutorials; the close-the-loop run is Prince's.
7. **Fix the Scene 05 Vercel regression** (`apps/study-buddy` breaking `talk-with-flavour` deploys): separate queued item from `PROGRESS.md`, not in this dispatch. Misled's preview is unaffected because it deploys from `feature/misled-ethos-page`.

---

## 6. Risk register

1. **Cursor scope creep.** Cursor Agent can modify files outside the stated scope. Mitigation: delegation prompts list exact file paths, not directory globs, per `tool-registry.md`. `diff-reviewer` catches out-of-scope modifications as FLAG.
2. **Ollama default bind address.** Ollama binds `127.0.0.1:11434` by default. Without explicit `OLLAMA_HOST=0.0.0.0` the swarm pipeline silently fails. Both worker tutorials must include a firewall plus bind-address section verified before tutorial ships.
3. **Resend double-opt-in environment secrets.** The API route will need `RESEND_API_KEY` and a `FROM_ADDRESS` env var. These must appear in `.env.example` but never in committed code. Tier 2 review checks for hardcoded credentials.
4. **Gemini preamble verbosity.** Gemini occasionally prefixes output with "Sure, here is..." text. Orchestrator strips any lines before the first `#` heading per `tool-registry.md` before showing Prince.
5. **Parallel vault writes.** If both Task Forces try to update `~/code/build-in-public/` simultaneously (scene capture plus artefact), commits collide. Mitigation: vault writes serialise through the orchestrator. Subagents return vault content to the orchestrator as text; the orchestrator commits.
6. **Intel MBP thermal throttling.** The 2019 MBP i9 under sustained `llama3.2:3b` inference may thermal-throttle, slowing the Reviewer stage. Tutorial notes this and recommends running on a cooled surface with `stats` monitoring.

---

## 7. Acceptance criteria

Dispatch complete when all of the following hold.

**Misled TF:**
- Smoke-test report committed to `docs/handoffs/2026-04-21-misled-smoke-test.md` covering all eight sections plus form interaction plus console state.
- `apps/misled/` contains wired Supabase + Resend double-opt-in flow, form posts real rows to `subscribers` table, confirmation email sends, unconfirmed rows past seven days auto-delete.
- Client message draft committed to `docs/handoffs/2026-04-21-misled-client-message-draft.md`.
- Scene 04 Conclude block drafted into `campaigns/command-centre/chapters/01-origin/scenes/04-misled-ethos-page.md`, `status: concluded` not yet set (Prince flips that on send).
- `feature/misled-ethos-page` branch has clean conventional commits, pushed, Vercel preview builds.

**ai-swarm-infra TF:**
- `uv run python ops/ai-swarm-infra/main.py "write a fastapi login route"` completes without error on the orchestrator host, assuming dummy responses from mocked Ollama endpoints (since worker nodes are not yet up). Integration path documented.
- `ops/ai-swarm-infra/.env.example` lists `CODER_NODE_URL`, `REVIEWER_NODE_URL`, `CODER_MODEL`, `REVIEWER_MODEL`.
- All three bootstrap tutorials committed under `ops/ai-swarm-infra/bootstrap/` as markdown files: `windows-coder.md`, `macos-reviewer.md`, `linux-orchestrator.md`.
- `feature/ai-swarm-infra-impl` branch has clean conventional commits, pushed.

**Shared:**
- This spec committed to `docs/superpowers/specs/2026-04-21-two-task-force-dispatch-design.md`.
- Session handoff written to `docs/handoffs/2026-04-21-two-task-force-dispatch-close.md` capturing: what shipped, what is pending your review, what you owe the system (mobile check, send message, run bootstraps).

---

## 8. Next step

After spec approval from Prince, orchestrator invokes the `superpowers:writing-plans` skill to produce the numbered implementation plan that the Phase 1 explorers operate from. Only then does dispatch begin.
